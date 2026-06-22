using System.Text.RegularExpressions;
using Common.BasicHelper.Utils.Extensions;
using ServerEntry.Data.Hardware.Services;
using ServerEntry.Shared.Hardware.Memory.Memories;
using ServerEntry.Shared.Hardware.Memory.Memories.Partitions;
using ServerEntry.Shared.Units;

namespace ServerEntry.Data.Hardware.Memories;

public partial class DiskInfoFetcher
{
    private static DiskInfoFetcher? _instance;

    public static DiskInfoFetcher Instance => _instance ??= new();

    public IEnumerable<DiskInfo> Fetch(string range = "all")
    {
        var result = new List<DiskInfo>();

        if (OperatingSystem.IsLinux())
        {
            const string partitionsInfoPath = "/proc/partitions";

            var partitions = File.ReadAllText(partitionsInfoPath).Split('\n');

            var disks = new Dictionary<string, DiskInfo>();

            foreach (var partition in partitions)
            {
                PartitionRegex().Match(partition.Trim()).WhenSuccess(x =>
                {
                    var name = ValueAt(x, 4);

                    if (name.Contains("loop", StringComparison.CurrentCultureIgnoreCase)) return;

                    if (name[^1] is >= '0' and <= '9')
                    {
                        var diskName = name[0..^1];

                        if (disks.ContainsKey(diskName) == false)
                        {
                            disks.Add(diskName, new DiskInfo()
                            {
                                Name = diskName,
                                Capacity = BinarySize.Parse(ValueAt(x, 3) + "KiB"),
                            });
                        }

                        disks[diskName].Partitions = disks[diskName].Partitions.Append(new PartitionInfo()
                        {
                            Name = name,
                            Size = BinarySize.Parse(ValueAt(x, 3) + "KiB"),
                        });
                    }
                    else
                    {
                        disks.TryAdd(name, new DiskInfo()
                        {
                            Name = name,
                            Capacity = BinarySize.Parse(ValueAt(x, 3) + "KiB"),
                        });
                    }
                });
            }

            // Enrich disk info with mount/usage data from the system
            EnrichWithMountInfo(disks);

            // Enrich with I/O speed data from the running monitor
            EnrichWithDiskMetrics(disks);

            result = [.. result, .. disks.Select(x => x.Value)];

            return result;
        }

        return result;

        static string ValueAt(Match? x, int index) => x?.Groups[index].Value ?? "";
    }

    /// <summary>
    /// Reads /proc/mounts to find mount points and DriveInfo to get usage statistics.
    /// Maps mount entries back to disk devices by matching device names.
    /// </summary>
    private static void EnrichWithMountInfo(Dictionary<string, DiskInfo> disks)
    {
        try
        {
            var drives = DriveInfo.GetDrives();

            foreach (var drive in drives)
            {
                if (!drive.IsReady) continue;

                // Match the drive's Unix device name to one of our disks
                // DriveInfo.Name on Linux is something like "/dev/sda1"
                var deviceName = Path.GetFileName(drive.Name.TrimEnd('/'));
                if (string.IsNullOrEmpty(deviceName)) continue;

                // Find the parent disk for this partition
                var diskName = FindDiskName(disks, deviceName);
                if (diskName == null) continue;

                var disk = disks[diskName];

                // Set available space from the largest partition on this disk
                // (or accumulate if multiple partitions mounted)
                if (drive.TotalSize > 0)
                {
                    disk.Formated ??= new BinarySize(0);

                    // Use the largest partition for the disk usage calculation
                    var currentAvailable = disk.Available?.ByteCount ?? 0;
                    if (drive.AvailableFreeSpace > currentAvailable)
                    {
                        disk.Available = new BinarySize(drive.AvailableFreeSpace);
                        // Update capacity to the mounted filesystem size if it's larger
                        if (drive.TotalSize > (disk.Capacity?.ByteCount ?? 0))
                        {
                            disk.Capacity = new BinarySize(drive.TotalSize);
                        }
                    }
                }

                // Mark if this disk hosts the root filesystem
                if (drive.Name == "/dev/root" || drive.RootDirectory.FullName == "/")
                    disk.IsHostingOperatingSystem = true;
            }

            // If no DriveInfo data was available, try reading /proc/mounts
            const string mountsPath = "/proc/mounts";
            if (File.Exists(mountsPath))
            {
                var mounts = File.ReadAllLines(mountsPath);
                foreach (var mount in mounts)
                {
                    var fields = mount.Split(' ', StringSplitOptions.RemoveEmptyEntries);
                    if (fields.Length < 2) continue;

                    var device = fields[0];
                    var mountPoint = fields[1];

                    var deviceName = Path.GetFileName(device.TrimEnd('/'));
                    if (string.IsNullOrEmpty(deviceName)) continue;

                    var diskName = FindDiskName(disks, deviceName);
                    if (diskName == null) continue;

                    if (mountPoint == "/")
                        disks[diskName].IsHostingOperatingSystem = true;
                }
            }
        }
        catch (Exception)
        {
            // Non-critical enrichment — silently skip
        }
    }

    /// <summary>
    /// Attaches read/write speed metrics from the DiskUsageMonitor to each DiskInfo.
    /// </summary>
    private static void EnrichWithDiskMetrics(Dictionary<string, DiskInfo> disks)
    {
        try
        {
            var monitor = ServicesManager.DiskUsageMonitor() as DiskUsageMonitor;
            if (monitor == null) return;

            foreach (var (name, disk) in disks)
            {
                var metrics = monitor.GetDiskMetrics(name);
                if (metrics == null) continue;

                disk.ReadSpeedPerSecond = metrics.ReadSpeedPerSecond;
                disk.WriteSpeedPerSecond = metrics.WriteSpeedPerSecond;
                disk.MaxReadSpeedPerSecond ??= metrics.ReadSpeedPerSecond;
                disk.MaxWriteSpeedPerSecond ??= metrics.WriteSpeedPerSecond;

                // Track max observed speeds
                if (metrics.ReadSpeedPerSecond?.ByteCount > (disk.MaxReadSpeedPerSecond?.ByteCount ?? 0))
                    disk.MaxReadSpeedPerSecond = metrics.ReadSpeedPerSecond;

                if (metrics.WriteSpeedPerSecond?.ByteCount > (disk.MaxWriteSpeedPerSecond?.ByteCount ?? 0))
                    disk.MaxWriteSpeedPerSecond = metrics.WriteSpeedPerSecond;

                // Calculate load based on read/write activity
                if (metrics.ReadSpeedPerSecond?.ByteCount > 0 || metrics.WriteSpeedPerSecond?.ByteCount > 0)
                {
                    // Simple heuristic: load = ratio of current vs max, capped at 1.0
                    var maxSpeed = Math.Max(
                        disk.MaxReadSpeedPerSecond?.ByteCount ?? 1,
                        disk.MaxWriteSpeedPerSecond?.ByteCount ?? 1);
                    var currentSpeed = (metrics.ReadSpeedPerSecond?.ByteCount ?? 0)
                        + (metrics.WriteSpeedPerSecond?.ByteCount ?? 0);

                    disk.Load = Math.Min(1.0, (double)currentSpeed / maxSpeed);
                }
            }
        }
        catch (Exception)
        {
            // Non-critical enrichment — silently skip
        }
    }

    /// <summary>
    /// Given a partition name (e.g., "sda1", "nvme0n1p1"), find the parent disk name
    /// in the disks dictionary.
    /// </summary>
    private static string? FindDiskName(Dictionary<string, DiskInfo> disks, string partitionName)
    {
        // Direct match
        if (disks.ContainsKey(partitionName)) return partitionName;

        // Try stripping trailing digits (sda1 → sda, nvme0n1p1 → nvme0n1)
        var candidate = partitionName.TrimEnd('0', '1', '2', '3', '4', '5', '6', '7', '8', '9');
        if (candidate.Length > 0 && candidate != partitionName && disks.ContainsKey(candidate))
            return candidate;

        // For NVMe drives: nvme0n1p1 → nvme0n1
        if (partitionName.StartsWith("nvme", StringComparison.Ordinal))
        {
            var lastP = partitionName.LastIndexOf('p');
            if (lastP > 0)
            {
                candidate = partitionName[..lastP];
                if (disks.ContainsKey(candidate)) return candidate;
            }
        }

        return null;
    }

    [GeneratedRegex(@"(\d+)\s+(\d+)\s+(\d+)\s+(\S+)")]
    private static partial Regex PartitionRegex();
}
