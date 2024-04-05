namespace ServerEntry.Shared.Hardware.Memory;

[Flags]
public enum MemoryTypes
{
    Unknown = 0,                            // 0    Unknown Memory Type
    Cache = 0b_0000_0001,                   // 1    Cache Memory
    RAM = 0b_0000_0010,                     // 2    Random Access Memory
    ROM = 0b_0000_0100,                     // 4    Read-Only Memory
    FloppyDisk = 0b_0000_1000,              // 8    Floppy Disk
    OpticalDisc = 0b_0001_0000,             // 16   Optical Disc
    HDD = 0b_0010_0000,                     // 32   Hard Disk Drive
    SSD = 0b_0100_0000,                     // 64   Solid-State Drive
    DiskFile = 0b_1000_0000,                // 128  Disk File (e.g., qcow2)
    VirtualMemory = 0b_0001_0000_0000,      // 256  Virtual Memory
}
