using ServerEntry.Shared.Units;

namespace ServerEntry.Shared.Hardware.Memory.Memories;

public class RamInfo : MemoryInfo
{
    public RamInfo()
    {
        Types = MemoryTypes.RAM;
    }

    public BinarySize? CompressedSize { get; set; }

    public BinarySize? CommitedSize { get; set; }

    public BinarySize? CachedSize { get; set; }

    public int UsedSlotCount { get; set; } = 0;

    public int TotalSlotCount { get; set; } = 0;
}
