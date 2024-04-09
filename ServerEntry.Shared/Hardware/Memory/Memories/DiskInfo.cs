using ServerEntry.Shared.Hardware.Memory.Memories.Partitions;
using ServerEntry.Shared.Units;

namespace ServerEntry.Shared.Hardware.Memory.Memories;

public class DiskInfo : MemoryInfo
{
    public double Load { get; set; } = 0.0;

    public BinarySize? ReadSpeedPerSecond { get; set; }

    public BinarySize? WriteSpeedPerSecond { get; set; }

    public BinarySize? MaxReadSpeedPerSecond { get; set; }

    public BinarySize? MaxWriteSpeedPerSecond { get; set; }

    public BinarySize? Formated { get; set; }

    public IEnumerable<PartitionInfo> Partitions { get; set; } = [];

    public bool IsHostingOperatingSystem { get; set; } = false;
}
