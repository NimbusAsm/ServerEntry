using ServerEntry.Shared.Hardware.Memory.Memories;

namespace ServerEntry.Shared.Hardware.Processor.Processors;

public class CpuInfo : ProcessorInfo
{
    public int ProcessCount { get; set; } = -1;

    public int ThreadCount { get; set; } = -1;

    public int HandleCount { get; set; } = -1;

    public int Slot { get; set; } = -1;

    public int CoreCount { get; set; } = -1;

    public IEnumerable<int> OnlineCpus { get; set; } = [];

    public int LogicCoreCount { get; set; } = -1;

    public bool Virtualizable { get; set; } = false;

    public CacheInfo? TotalCacheSize { get; set; }

    public IEnumerable<CpuCoreInfo> CpuCoreInfos { get; set; } = [];
}

public class CpuCoreInfo
{
    public double Usage { get; set; } = 0;

    public CacheInfo? L1DataCacheSize { get; set; }

    public CacheInfo? L1InstructionCacheSize { get; set; }

    public CacheInfo? L2CacheSize { get; set; }

    public CacheInfo? L3CacheSize { get; set; }
}
