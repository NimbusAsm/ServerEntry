using System.Text.RegularExpressions;
using Common.BasicHelper.Utils.Extensions;

namespace ServerEntry.Shared.Units;

public partial class BinarySize
{
    public BinarySize()
    {

    }

    public BinarySize(decimal bytesCount)
    {
        BytesCount = bytesCount;
    }

    public decimal BytesCount { get; set; } = 0;

    public string DisplayText
    {
        get
        {
            const decimal lvB = 1024;
            const decimal lvKB = lvB * 1000;
            const decimal lvMB = lvKB * 1000;
            const decimal lvGB = lvMB * 1000;
            const decimal lvTB = lvGB * 1000;
            const decimal lvPB = lvTB * 1000;
            const decimal lvEB = lvPB * 1000;

            if (BytesCount < lvB)
                return $"{BytesCount} B";

            if (BytesCount < lvKB)
                return $"{BytesCount / lvB} KB";

            if (BytesCount < lvMB)
                return $"{BytesCount / lvKB} MB";

            if (BytesCount < lvGB)
                return $"{BytesCount / lvMB} GB";

            if (BytesCount < lvTB)
                return $"{BytesCount / lvGB} TB";

            if (BytesCount < lvPB)
                return $"{BytesCount / lvTB} PB";

            if (BytesCount < lvEB)
                return $"{BytesCount / lvPB} EB";

            return $"{BytesCount / lvEB} ZB";
        }
    }

    [GeneratedRegex(@"(\d+).?(\d*)\s*(B|KB|MB|GB|TB|PB|EB)", RegexOptions.IgnoreCase)]
    private static partial Regex SizeTextRegex();

    public static BinarySize? Parse(string size)
    {
        decimal bytesCount = -1;

        SizeTextRegex().Match(size).WhenSuccess(x =>
        {
            bytesCount = 0;

            var integer = x?.Groups[1].Value ?? string.Empty;
            var left = x?.Groups[2].Value ?? string.Empty;
            var unit = x?.Groups[3].Value ?? string.Empty;

            var scale = unit.ToUpper() switch
            {
                "B" => 1,
                "KB" => 1000,
                "MB" => 1000 * 1000,
                "GB" => Math.Pow(1000, 3),
                "TB" => Math.Pow(1000, 4),
                "PB" => Math.Pow(1000, 5),
                "EB" => Math.Pow(1000, 6),
                _ => 1,
            };

            if (unit.Contains('b')) scale *= 1.0 / 8.0;

            var p = 0;

            for (var i = integer.Length - 1; i >= 0; --i, ++p)
                bytesCount += (int)((integer[i] - '0') * Math.Pow(10, p) * scale);

            p = 0;

            for (var i = 0; i < left.Length; i++, --p)
                bytesCount += (int)((integer[i] - '0') * Math.Pow(10, p) * scale);
        });

        return bytesCount == -1 ? null : new BinarySize(bytesCount);
    }

    public static BinarySize operator +(BinarySize? a, BinarySize? b) => new(a?.BytesCount ?? 0 + b?.BytesCount ?? 0);

    public static BinarySize operator -(BinarySize? a, BinarySize? b) => new(a?.BytesCount ?? 0 - b?.BytesCount ?? 0);

    public static decimal operator *(BinarySize? a, BinarySize? b) => (a?.BytesCount ?? 0) * (b?.BytesCount ?? 1);

    public static decimal operator /(BinarySize? a, BinarySize? b) => (a?.BytesCount ?? 0) / (b?.BytesCount ?? 1);
}
