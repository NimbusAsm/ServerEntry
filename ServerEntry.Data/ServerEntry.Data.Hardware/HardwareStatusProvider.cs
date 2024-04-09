using ServerEntry.Data.Hardware.Memories;
using ServerEntry.Data.Hardware.Processors;
using ServerEntry.Shared.Hardware;

namespace ServerEntry.Data.Hardware;

public class HardwareStatusProvider
{
    private static HardwareStatusProvider? _instance;

    public static HardwareStatusProvider Instance => _instance ??= new();

    public HardwareStatus GetStatus()
    {
        var result = new HardwareStatus()
        {
            Processors = [CpuInfoFetcher.Instance.Fetch()],
            Memories = [RamInfoFetcher.Instance.Fetch(), .. DiskInfoFetcher.Instance.Fetch()],
        };

        return result;
    }
}
