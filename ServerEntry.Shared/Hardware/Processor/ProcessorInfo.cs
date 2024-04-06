using System.Text.Json.Serialization;
using ServerEntry.Shared.Hardware.Processor.Processors;

namespace ServerEntry.Shared.Hardware.Processor;

[JsonPolymorphic(UnknownDerivedTypeHandling = JsonUnknownDerivedTypeHandling.FallBackToBaseType)]
[JsonDerivedType(typeof(CpuInfo), typeDiscriminator: nameof(CpuInfo))]
[JsonDerivedType(typeof(GpuInfo), typeDiscriminator: nameof(GpuInfo))]
public class ProcessorInfo
{
    public ProcessorTypes Types { get; set; } = ProcessorTypes.Unknown;

    public string? Name { get; set; }

    public double Usage { get; set; } = 0.0;

    public double Temperature { get; set; } = 0.0;

    public string? Model { get; set; }

    public string? Manufacturer { get; set; }

    public string? Architecture { get; set; }

    public double Frequency { get; set; } = 0.0;

    public double FrequencyBase { get; set; } = 0.0;
}
