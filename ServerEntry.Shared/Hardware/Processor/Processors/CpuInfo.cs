using ServerEntry.Shared.Hardware.Memory.Memories;

namespace ServerEntry.Shared.Hardware.Processor.Processors;

public class CpuInfo : ProcessorInfo
{
    public int ProcessCount { get; set; } = -1;

    public int ThreadCount { get; set; } = -1;

    public int HandleCount { get; set; } = -1;

    public int Slot { get; set; } = -1;

    public int CoreCount { get; set; } = -1;

    public int LogicCoreCount { get; set; } = -1;

    public bool Virtualizable { get; set; } = false;

    public CacheInfo? L1CacheSize { get; set; }

    public CacheInfo? L2CacheSize { get; set; }

    public CacheInfo? L3CacheSize { get; set; }

    public IEnumerable<double> PerCoreUsage { get; set; } = [];
}
