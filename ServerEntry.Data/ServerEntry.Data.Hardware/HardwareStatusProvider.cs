using ServerEntry.Data.Hardware.Memories;
using ServerEntry.Data.Hardware.Processors;
using ServerEntry.Shared.Hardware;
using ServerEntry.Shared.Hardware.Memory;
using ServerEntry.Shared.Hardware.Processor;

namespace ServerEntry.Data.Hardware;

public class HardwareStatusProvider
{
    private static HardwareStatusProvider? _instance;

    public static HardwareStatusProvider Instance => _instance ??= new();

    public HardwareStatus GetStatus()
    {
        var result = new HardwareStatus()
        {
            Processors = GetProcessorInfos(),
            Memories = GetMemoryInfos(),
        };

        return result;
    }

    public IEnumerable<ProcessorInfo> GetProcessorInfos()
    {
        return [CpuInfoFetcher.Instance.Fetch()];
    }

    public IEnumerable<MemoryInfo> GetMemoryInfos()
    {
        return [RamInfoFetcher.Instance.Fetch(), .. DiskInfoFetcher.Instance.Fetch()];
    }
}
