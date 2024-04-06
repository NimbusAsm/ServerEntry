using System.Text.Json.Serialization;
using ServerEntry.Shared.Hardware.Memory.Memories;
using ServerEntry.Shared.Units;

namespace ServerEntry.Shared.Hardware.Memory;

[JsonPolymorphic(UnknownDerivedTypeHandling = JsonUnknownDerivedTypeHandling.FallBackToBaseType)]
[JsonDerivedType(typeof(CacheInfo), typeDiscriminator: nameof(CacheInfo))]
[JsonDerivedType(typeof(RamInfo), typeDiscriminator: nameof(RamInfo))]
[JsonDerivedType(typeof(DiskInfo), typeDiscriminator: nameof(DiskInfo))]
public class MemoryInfo
{
    public MemoryTypes Types { get; set; } = MemoryTypes.Unknown;

    public string? Name { get; set; }

    public double Usage => (double)(Available / Capacity);

    public BinarySize? Available { get; set; }

    public BinarySize? Capacity { get; set; }

    public double Temperature { get; set; } = 0.0;

    public string? Model { get; set; }

    public string? Manufacturer { get; set; }

    public string? Architecture { get; set; }

    public double Frequency { get; set; } = 0.0;

    public double FrequencyBase { get; set; } = 0.0;
}
