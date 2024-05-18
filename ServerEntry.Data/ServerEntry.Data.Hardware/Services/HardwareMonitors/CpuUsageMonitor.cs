using ServerEntry.Shared.Service;

namespace ServerEntry.Data.Hardware.Services.HardwareMonitors;

public class CpuUsageMonitor : MonitorBase
{
    private Thread? thread;

    private bool keepRunning = false;

    private double usage = -1;

    private (long idle, long total) lastCpuStats;

    private readonly Dictionary<DateTime, object> cpuUsageHistory = [];

    public override string GetName() => typeof(CpuUsageMonitor).Name;

    public override void OnInitialize()
    {
        keepRunning = true;

        lastCpuStats = GetCpuStats();

        thread ??= new Thread(() =>
        {
            UpdateStatus(ServiceStatus.Healthy);

            while (keepRunning)
            {
                Thread.Sleep(500);

                var endCpuStats = GetCpuStats();

                var totalCpuDiff = endCpuStats.total - lastCpuStats.total;
                var idleCpuDiff = endCpuStats.idle - lastCpuStats.idle;

                usage = 1 - idleCpuDiff * 1.0 / (totalCpuDiff * 1.0);

                cpuUsageHistory.Add(DateTime.Now, usage);

                lastCpuStats = endCpuStats;
            }
        });

        static (long idle, long total) GetCpuStats()
        {
            var procStatPath = "/proc/stat";

            var lines = File.ReadAllLines(procStatPath);

            var cpuLine = lines.FirstOrDefault(line => line.StartsWith("cpu ")) ?? throw new InvalidOperationException("Unable to find CPU information in /proc/stat");

            var fields = cpuLine.Split(' ', StringSplitOptions.RemoveEmptyEntries) ?? throw new ArgumentNullException(nameof(cpuLine));

            var stats = fields.Skip(1).Select(long.Parse).ToArray();

            return (stats[3], stats.Sum());
        }
    }

    public override void MainBody()
    {
        thread?.Start();
    }

    public override void OnStopping()
    {
        keepRunning = false;

        thread?.Join();

        thread = null;
    }

    public override bool GetValue(out object result, out Exception? exception)
    {
        result = usage;

        exception = null;

        return true;
    }

    public override Dictionary<DateTime, object> GetValuesHistory(out Exception? exception)
    {
        exception = null;
        return cpuUsageHistory;
    }
}
