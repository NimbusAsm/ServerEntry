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

    public double Usage { get; set; } = double.NaN;

    public double Temperature { get; set; } = double.NaN;

    public string? Model { get; set; }

    public string? Manufacturer { get; set; }

    public string? Architecture { get; set; }

    public double Frequency { get; set; } = double.NaN;

    public double FrequencyBase { get; set; } = double.NaN;
}
