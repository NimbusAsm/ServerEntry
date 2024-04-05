using ServerEntry.Shared.Hardware.Memory;

namespace ServerEntry.Shared.Hardware.Processor;

public class HardwareStatus
{
    public string? Name { get; set; }

    public ProcessorInfo? ProcessorInfo { get; set; }

    public IEnumerable<MemoryInfo> Memories { get; set; } = [];
}
