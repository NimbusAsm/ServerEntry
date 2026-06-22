using System.Globalization;
using ServerEntry.Shared.Hardware.Memory.Memories;
using ServerEntry.Shared.Service;
using ServerEntry.Shared.Units;

namespace ServerEntry.Data.Hardware.Services.HardwareMonitors;

public class DiskUsageMonitor : MonitorBase
{
    private Thread? thread;

    private bool keepRunning = false;

    private readonly Dictionary<string, (long readSectors, long writeSectors)> lastDiskStats = [];

    private readonly Dictionary<string, DiskStats> currentDiskMetrics = [];

    private readonly SortedDictionary<DateTime, object> usageHistory = [];

    public override string GetName() => typeof(DiskUsageMonitor).Name;

    public override void OnInitialize()
    {
        keepRunning = true;

        // Snapshot initial disk stats for delta calculation
        var initial = ReadDiskStats();
        foreach (var (name, stats) in initial)
            lastDiskStats[name] = stats;

        thread ??= new Thread(() =>
        {
            UpdateStatus(ServiceStatus.Healthy);

            while (keepRunning)
            {
                Thread.Sleep(2000);

                var current = ReadDiskStats();

                foreach (var (name, (readSectors, writeSectors)) in current)
                {
                    if (lastDiskStats.TryGetValue(name, out var last))
                    {
                        var deltaReadSectors = readSectors - last.readSectors;
                        var deltaWriteSectors = writeSectors - last.writeSectors;

                        // Linux sector size is typically 512 bytes
                        const long sectorSize = 512;
                        var readSpeedBytes = deltaReadSectors * sectorSize / 2; // per second (2s interval)
                        var writeSpeedBytes = deltaWriteSectors * sectorSize / 2;

                        currentDiskMetrics[name] = new DiskStats
                        {
                            ReadSpeedPerSecond = new BinarySize(readSpeedBytes),
                            WriteSpeedPerSecond = new BinarySize(writeSpeedBytes),
                            ReadSectorsPerSecond = deltaReadSectors / 2,
                            WriteSectorsPerSecond = deltaWriteSectors / 2,
                        };
                    }

                    lastDiskStats[name] = (readSectors, writeSectors);
                }

                RecordHistory();
            }
        });

        void RecordHistory()
        {
            if (usageHistory.Count > 60) usageHistory.Remove(usageHistory.Keys.First());

            usageHistory.Add(DateTime.Now, currentDiskMetrics.Values.ToList());
        }
    }

    public override void MainBody()
    {
        thread?.Start();
    }

    public override void OnStopping()
    {
        keepRunning = false;

        thread?.Join();

        thread = null;
    }

    public override bool GetValue(out object result, out Exception? exception)
    {
        result = currentDiskMetrics;
        exception = null;
        return true;
    }

    public override SortedDictionary<DateTime, object> GetValuesHistory(out Exception? exception)
    {
        exception = null;
        return usageHistory;
    }

    /// <summary>
    /// Reads /proc/diskstats and returns a dictionary of device name → (read_sectors, write_sectors).
    /// Filters out loop, ram, and dm devices to focus on physical/virtual block devices.
    /// </summary>
    private static Dictionary<string, (long readSectors, long writeSectors)> ReadDiskStats()
    {
        var result = new Dictionary<string, (long, long)>();

        try
        {
            const string path = "/proc/diskstats";

            if (!File.Exists(path)) return result;

            var lines = File.ReadAllLines(path);

            foreach (var line in lines)
            {
                var fields = line.Split(' ', StringSplitOptions.RemoveEmptyEntries);

                if (fields.Length < 14) continue;

                var deviceName = fields[2];

                // Filter out loopback, ram, and device-mapper (lvm/crypt) devices
                if (deviceName.StartsWith("loop", StringComparison.Ordinal)
                    || deviceName.StartsWith("ram", StringComparison.Ordinal)
                    || deviceName.StartsWith("dm-", StringComparison.Ordinal))
                    continue;

                // Field 5 (index 5): sectors read
                // Field 9 (index 9): sectors written
                var readSectors = long.Parse(fields[5], CultureInfo.InvariantCulture);
                var writeSectors = long.Parse(fields[9], CultureInfo.InvariantCulture);

                result[deviceName] = (readSectors, writeSectors);
            }
        }
        catch (Exception)
        {
            // Silently fail — disk stats are non-critical
        }

        return result;
    }

    /// <summary>
    /// Returns the current metrics for a given disk device name, or null if not tracked.
    /// </summary>
    public DiskStats? GetDiskMetrics(string deviceName)
    {
        return currentDiskMetrics.TryGetValue(deviceName, out var stats) ? stats : null;
    }
}

public class DiskStats
{
    public BinarySize? ReadSpeedPerSecond { get; set; }

    public BinarySize? WriteSpeedPerSecond { get; set; }

    public long ReadSectorsPerSecond { get; set; }

    public long WriteSectorsPerSecond { get; set; }
}
