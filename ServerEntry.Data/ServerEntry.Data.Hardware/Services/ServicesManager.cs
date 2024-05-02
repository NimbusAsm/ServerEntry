using ServerEntry.Data.Hardware.Services.HardwareMonitors;

namespace ServerEntry.Data.Hardware.Services;

public static class ServicesManager
{
    private static readonly List<IMonitorService> monitorServices = [];

    private static IMonitorService? Query<T>() where T : IMonitorService
    {
        var query = monitorServices.Where(x => x.Name.Equals(typeof(T).Name));

        return query.FirstOrDefault();
    }

    private static IMonitorService QueryOrCreate<T>() where T : IMonitorService, new()
    {
        var query = Query<T>();

        if (query is not null)
            return query;

        var monitor = new T();

        monitor.Monitor();

        monitorServices.Add(monitor);

        return monitor;
    }

    public static void StopMonitor<T>() where T : IMonitorService
    {
        var query = Query<T>();

        query?.StopMonitoring();

        if (query is not null) monitorServices.Remove(query);
    }

    public static void StopAllMonitors()
    {
        foreach (var monitor in monitorServices)
            monitor.StopMonitoring();

        monitorServices.Clear();
    }

    public static IMonitorService CpuUsageMonitor() => QueryOrCreate<CpuUsageMonitor>();
}
