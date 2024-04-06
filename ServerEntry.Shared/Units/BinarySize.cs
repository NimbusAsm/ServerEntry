using System.Text.RegularExpressions;
using Common.BasicHelper.Utils.Extensions;

namespace ServerEntry.Shared.Units;

public partial class BinarySize
{
    public BinarySize()
    {

    }

    public BinarySize(long bytesCount)
    {
        BytesCount = bytesCount;
    }

    public long BytesCount { get; set; } = 0;

    public string DisplayText
    {
        get
        {
            const double lvB = 1000;
            const double lvKB = lvB * 1000;
            const double lvMB = lvKB * 1000;
            const double lvGB = lvMB * 1000;
            const double lvTB = lvGB * 1000;
            const double lvPB = lvTB * 1000;
            const double lvEB = lvPB * 1000;

            if (BytesCount < lvB)
                return $"{BytesCount} B";

            if (BytesCount < lvKB)
                return $"{Math.Round(BytesCount / lvB, 2)} KB";

            if (BytesCount < lvMB)
                return $"{Math.Round(BytesCount / lvKB, 2)} MB";

            if (BytesCount < lvGB)
                return $"{Math.Round(BytesCount / lvMB, 2)} GB";

            if (BytesCount < lvTB)
                return $"{Math.Round(BytesCount / lvGB, 2)} TB";

            if (BytesCount < lvPB)
                return $"{Math.Round(BytesCount / lvTB, 2)} PB";

            if (BytesCount < lvEB)
                return $"{Math.Round(BytesCount / lvPB, 2)} EB";

            return $"{Math.Round(BytesCount / lvEB, 2)} ZB";
        }
    }

    [GeneratedRegex(@"(\d+).?(\d*)\s*(B|Ki?B|Mi?B|Gi?B|Ti?B|Pi?B|Ei?B)", RegexOptions.IgnoreCase)]
    private static partial Regex SizeTextRegex();

    public static BinarySize? Parse(string size)
    {
        long bytesCount = -1;

        SizeTextRegex().Match(size).WhenSuccess(x =>
        {
            bytesCount = 0;

            var integer = x?.Groups[1].Value ?? string.Empty;
            var left = x?.Groups[2].Value ?? string.Empty;
            var unit = x?.Groups[3].Value ?? string.Empty;

            var diff = unit.ToLower().Contains('i') ? 1024 : 1000;

            var scale = unit.ToUpper() switch
            {
                "B" => 1,
                "KB" => diff,
                "MB" => diff * diff,
                "GB" => Math.Pow(diff, 3),
                "TB" => Math.Pow(diff, 4),
                "PB" => Math.Pow(diff, 5),
                "EB" => Math.Pow(diff, 6),
                _ => 1,
            };

            if (unit.Contains('b')) scale *= 1.0 / 8.0;

            var p = 0;

            for (var i = integer.Length - 1; i >= 0; --i, ++p)
                bytesCount += (long)((integer[i] - '0') * Math.Pow(10, p) * scale);

            p = 0;

            for (var i = 0; i < left.Length; i++, --p)
                bytesCount += (long)((integer[i] - '0') * Math.Pow(10, p) * scale);
        });

        return bytesCount == -1 ? null : new BinarySize(bytesCount);
    }

    public static BinarySize operator +(BinarySize? a, BinarySize? b) => new(a?.BytesCount ?? 0 + b?.BytesCount ?? 0);

    public static BinarySize operator -(BinarySize? a, BinarySize? b) => new(a?.BytesCount ?? 0 - b?.BytesCount ?? 0);

    public static long operator *(BinarySize? a, BinarySize? b) => (a?.BytesCount ?? 0) * (b?.BytesCount ?? 1);

    public static decimal operator /(BinarySize? a, BinarySize? b) => (a?.BytesCount ?? 0) / (b?.BytesCount ?? 1);
}
