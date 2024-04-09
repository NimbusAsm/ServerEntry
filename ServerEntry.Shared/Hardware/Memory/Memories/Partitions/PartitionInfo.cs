using ServerEntry.Shared.Units;

namespace ServerEntry.Shared.Hardware.Memory.Memories.Partitions;

public class PartitionInfo
{
    public string? Name { get; set; }

    public BinarySize? Size { get; set; }
}
