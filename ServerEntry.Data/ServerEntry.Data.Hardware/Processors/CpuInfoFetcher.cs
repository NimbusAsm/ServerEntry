using System.Text.RegularExpressions;
using Common.BasicHelper.Utils.Extensions;
using ServerEntry.Data.Hardware.Extensions;
using ServerEntry.Data.Hardware.Services;
using ServerEntry.Shared.Hardware.Memory.Memories;
using ServerEntry.Shared.Hardware.Processor.Processors;
using ServerEntry.Shared.Units;

namespace ServerEntry.Data.Hardware.Processors;

public partial class CpuInfoFetcher
{
    private static CpuInfoFetcher? _instance;

    public static CpuInfoFetcher Instance => _instance ??= new();

    public CpuInfo Fetch(string range = "all")
    {
        var result = new CpuInfo();

        if (OperatingSystem.IsLinux())
        {
            const string basicInfoPath = "/proc/cpuinfo";

            var info = File.ReadAllText(basicInfoPath);

            ModelNameRegex().Match(info).WhenSuccess(x => result.Name = ValueAt(x, 1));

            ModelRegex().Match(info).WhenSuccess(x => result.Model = ValueAt(x, 1));

            ManufacturerRegex().Match(info).WhenSuccess(x => result.Manufacturer = ValueAt(x, 1));

            FrequencyRegex().Match(info).WhenSuccess(x =>
            {
                if (double.TryParse(ValueAt(x, 1), out var frequency))
                    result.Frequency = frequency;
            });

            CacheSizeRegex().Match(info).WhenSuccess(
                x => result.TotalCacheSize = new CacheInfo()
                {
                    Capacity = BinarySize.Parse(ValueAt(x, 1) ?? ""),
                }
            );

            CoreCountRegex().Match(info).WhenSuccess(x => result.CoreCount = int.Parse(ValueAt(x, 1) ?? "-1"));

            ThreadCountRegex().Match(info).WhenSuccess(x => result.ThreadCount = int.Parse(ValueAt(x, 1) ?? "-1"));

            if (ServicesManager.CpuUsageMonitor().GetValue(out var v, out var e))
                result.Usage = (double)v;

            if (range.Includes(["all", "percpu"]))
            {
                const string cpuDevicesPath = "/sys/devices/system/cpu";

                const string onlineCpusPath = cpuDevicesPath + "/online";

                var onlineCpus = File.ReadAllText(onlineCpusPath).Split(',').Select(
                    x => GetItemsFromRange(GetRange(x))
                ).SelectMany(x => x).Distinct();

                result.OnlineCpus = onlineCpus;

                foreach (var cpuId in onlineCpus)
                {
                    var coreInfo = new CpuCoreInfo();

                    var infoDirPath = cpuDevicesPath + $"/cpu{cpuId}";

                    var cacheDirPath = infoDirPath + $"/cache";

                    var indexes = new DirectoryInfo(cacheDirPath).GetDirectories()
                        .Where(x => IndexRegex().IsMatch(x.Name.ToLower()))
                        .Select(x => x.Name);

                    foreach (var index in indexes)
                    {
                        var sizeInfoPath = cacheDirPath + $"/{index}/size";

                        var levelInfoPath = cacheDirPath + $"/{index}/level";

                        var size = BinarySize.Parse(File.ReadAllText(sizeInfoPath) + "B");

                        var level = int.Parse(File.ReadAllText(levelInfoPath));

                        switch (level)
                        {
                            case 1:
                                switch (index.Last() - '0')
                                {
                                    case 0:
                                        coreInfo.L1DataCacheSize = new CacheInfo()
                                        {
                                            Capacity = size,
                                        };
                                        break;
                                    case 1:
                                        coreInfo.L1InstructionCacheSize = new CacheInfo()
                                        {
                                            Capacity = size,
                                        };
                                        break;
                                }
                                break;
                            case 2:
                                coreInfo.L2CacheSize = new CacheInfo()
                                {
                                    Capacity = size,
                                };
                                break;
                            case 3:
                                coreInfo.L3CacheSize = new CacheInfo()
                                {
                                    Capacity = size,
                                };
                                break;
                        }
                    }

                    result.CpuCoreInfos = result.CpuCoreInfos.Append(coreInfo);
                }
            }

            return result;
        }

        return result;

        static string? ValueAt(Match? x, int index) => x?.Groups[index].Value;

        static Range GetRange(string x)
        {
            var se = x.Split('-');

            if (se.Length != 2) throw new ArgumentException("Invalid range expression");

            return new Range(int.Parse(se[0]), int.Parse(se[1]));
        }

        static IEnumerable<int> GetItemsFromRange(Range range) => Enumerable.Range(range.Start.Value, range.End.Value + 1);
    }

    [GeneratedRegex(@"model name\s+:\s+(.+)")]
    private static partial Regex ModelNameRegex();

    [GeneratedRegex(@"model\s+:\s+(.+)")]
    private static partial Regex ModelRegex();

    [GeneratedRegex(@"vendor_id\s+:\s+(.+)")]
    private static partial Regex ManufacturerRegex();

    [GeneratedRegex(@"cpu MHz\s+:\s+(.+)")]
    private static partial Regex FrequencyRegex();

    [GeneratedRegex(@"cache size\s+:\s+(.+)")]
    private static partial Regex CacheSizeRegex();

    [GeneratedRegex(@"cpu cores\s+:\s+(.+)")]
    private static partial Regex CoreCountRegex();

    [GeneratedRegex(@"siblings\s+:\s+(.+)")]
    private static partial Regex ThreadCountRegex();

    [GeneratedRegex(@"index\d+")]
    private static partial Regex IndexRegex();
}
