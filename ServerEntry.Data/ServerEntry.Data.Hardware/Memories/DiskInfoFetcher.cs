using System.Text.RegularExpressions;
using Common.BasicHelper.Utils.Extensions;
using ServerEntry.Shared.Hardware.Memory.Memories;
using ServerEntry.Shared.Hardware.Memory.Memories.Partitions;
using ServerEntry.Shared.Units;

namespace ServerEntry.Data.Hardware.Memories;

public partial class DiskInfoFetcher
{
    private static DiskInfoFetcher? _instance;

    public static DiskInfoFetcher Instance => _instance ??= new();

    public IEnumerable<DiskInfo> Fetch()
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

            result = [.. result, .. disks.Select(x => x.Value)];

            return result;
        }

        return result;

        static string ValueAt(Match? x, int index) => x?.Groups[index].Value ?? "";
    }

    [GeneratedRegex(@"(\d+)\s+(\d+)\s+(\d+)\s+(\S+)")]
    private static partial Regex PartitionRegex();
}
