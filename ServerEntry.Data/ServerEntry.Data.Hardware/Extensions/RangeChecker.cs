namespace ServerEntry.Data.Hardware.Extensions;

public static class RangeChecker
{
    public static bool IsInRange(this string provided, string range)
    {
        return range.ToLower().Equals("all") || range.ToLower().Contains(provided.ToLower());
    }

    public static bool Includes(this string range, string[] patterns)
    {
        foreach (var pattern in patterns)
            if (range.ToLower().Contains(pattern.ToLower()))
                return true;

        return false;
    }
}