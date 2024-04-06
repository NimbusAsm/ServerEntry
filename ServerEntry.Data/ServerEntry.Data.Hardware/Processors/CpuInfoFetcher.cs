using System.Text.RegularExpressions;
using Common.BasicHelper.Utils.Extensions;
using ServerEntry.Shared.Hardware.Memory.Memories;
using ServerEntry.Shared.Hardware.Processor.Processors;
using ServerEntry.Shared.Units;

namespace ServerEntry.Data.Hardware.Processors;

public partial class CpuInfoFetcher
{
    private static CpuInfoFetcher? _instance;

    public static CpuInfoFetcher Instance => _instance ??= new();

    public CpuInfo Fetch()
    {
        var result = new CpuInfo();

        if (OperatingSystem.IsLinux())
        {
            const string path = "/proc/cpuinfo";

            var info = File.ReadAllText(path);

            ModelNameRegex().Match(info).WhenSuccess(x => result.Name = x?.Groups[1].Value);

            ModelRegex().Match(info).WhenSuccess(x => result.Model = x?.Groups[1].Value);

            ManufacturerRegex().Match(info).WhenSuccess(x => result.Manufacturer = x?.Groups[1].Value);

            FrequencyRegex().Match(info).WhenSuccess(x =>
            {
                if (double.TryParse(x?.Groups[1].Value, out var frequency))
                    result.Frequency = frequency;
            });

            CacheSizeRegex().Match(info).WhenSuccess(
                x => result.TotalCacheSize = new CacheInfo()
                {
                    Capacity = BinarySize.Parse(x?.Groups[1].Value ?? ""),
                }
            );

            CoreCountRegex().Match(info).WhenSuccess(x => result.CoreCount = int.Parse(x?.Groups[1].Value ?? "-1"));

            ThreadCountRegex().Match(info).WhenSuccess(x => result.ThreadCount = int.Parse(x?.Groups[1].Value ?? "-1"));

            return result;
        }

        return result;
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
}
