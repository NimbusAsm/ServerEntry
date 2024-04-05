namespace ServerEntry.Shared.Hardware.Processor;

[Flags]
public enum ProcessorTypes
{
    Unknown = 0,            // 0    Unknown Processor Type
    CPU = 0b_0000_0001,     // 1    Central Processing Unit
    GPU = 0b_0000_0010,     // 2    Graphics Processing Unit
    NPU = 0b_0000_0100,     // 4    Neural Processing Unit
    TPU = 0b_0000_1000,     // 8    Tensor Processing Unit
    DSP = 0b_0001_0000,     // 16   Digital Signal Processor
    VPU = 0b_0010_0000,     // 32   Video Processing Unit
    RPU = 0b_0100_0000,     // 64   Routing Processing Unit
    ISP = 0b_1000_0000,     // 128  Image Signal Processor
    FPGA = 2048,            // 2048 Field-Programmable Gate Array
}
