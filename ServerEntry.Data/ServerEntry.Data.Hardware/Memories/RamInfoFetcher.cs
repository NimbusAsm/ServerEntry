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

            MemTotalRegex().Match(info).WhenSuccess(x => result.Capacity = BinarySize.Parse(ValueAt(x, 1)));

            MemAvailableRegex().Match(info).WhenSuccess(x => result.Available = BinarySize.Parse(ValueAt(x, 1)));

            CachedRegex().Match(info).WhenSuccess(x => result.CachedSize = BinarySize.Parse(ValueAt(x, 1)));

            CommittedRegex().Match(info).WhenSuccess(x => result.CommitedSize = BinarySize.Parse(ValueAt(x, 1)));

            return result;
        }

        return result;

        static string ValueAt(Match? x, int index) => x?.Groups[1].Value ?? "";
    }

    [GeneratedRegex(@"MemTotal:\s+(.+)")]
    private static partial Regex MemTotalRegex();

    [GeneratedRegex(@"MemAvailable:\s+(.+)")]
    private static partial Regex MemAvailableRegex();

    [GeneratedRegex(@"Cached:\s+(.+)")]
    private static partial Regex CachedRegex();

    [GeneratedRegex(@"Committed_AS:\s+(.+)")]
    private static partial Regex CommittedRegex();
}
