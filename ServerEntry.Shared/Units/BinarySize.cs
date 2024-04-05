namespace ServerEntry.Shared.Units;

public class BinarySize
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

    public static BinarySize operator +(BinarySize? a, BinarySize? b) => new(a?.BytesCount ?? 0 + b?.BytesCount ?? 0);

    public static BinarySize operator -(BinarySize? a, BinarySize? b) => new(a?.BytesCount ?? 0 - b?.BytesCount ?? 0);

    public static decimal operator *(BinarySize? a, BinarySize? b) => (a?.BytesCount ?? 0) * (b?.BytesCount ?? 1);

    public static decimal operator /(BinarySize? a, BinarySize? b) => (a?.BytesCount ?? 0) / (b?.BytesCount ?? 1);
}
