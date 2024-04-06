using System.Text.RegularExpressions;
using Common.BasicHelper.Utils.Extensions;
using ServerEntry.Shared.Hardware.Memory.Memories;
using ServerEntry.Shared.Units;

namespace ServerEntry.Data.Hardware.Memories;

public partial class RamInfoFetcher
{
    private static RamInfoFetcher? _instance;

    public static RamInfoFetcher Instance => _instance ??= new();

    public RamInfo Fetch()
    {
        var result = new RamInfo();

        if (OperatingSystem.IsLinux())
        {
            const string path = "/proc/meminfo";

            var info = File.ReadAllText(path);

            MemTotalRegex().Match(info).WhenSuccess(x => result.Capacity = BinarySize.Parse(x?.Groups[1].Value ?? ""));

            MemFreeRegex().Match(info).WhenSuccess(x => result.Available = BinarySize.Parse(x?.Groups[1].Value ?? ""));

            CachedRegex().Match(info).WhenSuccess(x => result.CachedSize = BinarySize.Parse(x?.Groups[1].Value ?? ""));

            return result;
        }

        return result;
    }

    [GeneratedRegex(@"MemTotal:\s+(.+)")]
    private static partial Regex MemTotalRegex();

    [GeneratedRegex(@"MemFree:\s+(.+)")]
    private static partial Regex MemFreeRegex();

    [GeneratedRegex(@"Cached:\s+(.+)")]
    private static partial Regex CachedRegex();
}