using ServerEntry.Data.Hardware.Extensions;
using ServerEntry.Data.Hardware.Memories;
using ServerEntry.Data.Hardware.Processors;
using ServerEntry.Data.Hardware.Services;
using ServerEntry.Shared.Hardware;
using ServerEntry.Shared.Hardware.Memory;
using ServerEntry.Shared.Hardware.Processor;

namespace ServerEntry.Data.Hardware;

public class HardwareStatusProvider
{
    private static HardwareStatusProvider? _instance;

    public static HardwareStatusProvider Instance => _instance ??= new();

    public HardwareStatus GetStatus(string range = "all")
    {
        var result = new HardwareStatus()
        {
            Processors = "processors".IsInRange(range) ? GetProcessorInfos(range) : [],
            Memories = "memory".IsInRange(range) ? GetMemoryInfos(range) : [],
        };

        return result;
    }

    public IEnumerable<ProcessorInfo> GetProcessorInfos(string range = "all")
    {
        var result = new List<ProcessorInfo>();

        if ("cpu".IsInRange(range)) result.Add(CpuInfoFetcher.Instance.Fetch(range));

        return result;
    }

    public IEnumerable<MemoryInfo> GetMemoryInfos(string range = "all")
    {
        var result = new List<MemoryInfo>();

        if ("ram".IsInRange(range)) result.Add(RamInfoFetcher.Instance.Fetch(range));

        if ("disks".IsInRange(range)) result = result.Concat(DiskInfoFetcher.Instance.Fetch(range)).ToList();

        return result;
    }

    public Dictionary<DateTime, object> GetCpuUsageHistory() => ServicesManager.CpuUsageMonitor().GetValuesHistory(out _);
}
