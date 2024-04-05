using ServerEntry.Shared.Units;

namespace ServerEntry.Shared.Hardware.Processor.Processors;

public class GpuInfo : ProcessorInfo
{
    public int CoreCount { get; set; } = -1;

    public BinarySize? Memory { get; set; }

    public BinarySize? SharedMemory { get; set; }

    public BinarySize? PrivateMemory { get; set; }

    public string? Driver { get; set; }

    public string? DriverVersion { get; set; }

    public DateTime? DriverDate { get; set; }

    public IEnumerable<string> SupportedApis { get; set; } = [];

    public IDictionary<string, string> Tags { get; set; } = new Dictionary<string, string>();
}
