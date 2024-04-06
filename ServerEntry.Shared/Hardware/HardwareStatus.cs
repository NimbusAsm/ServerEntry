using ServerEntry.Shared.Hardware.Memory;
using ServerEntry.Shared.Hardware.Processor;

namespace ServerEntry.Shared.Hardware;

public class HardwareStatus
{
    public string? Name { get; set; }

    public IEnumerable<ProcessorInfo> Processors { get; set; } = [];

    public IEnumerable<MemoryInfo> Memories { get; set; } = [];
}
