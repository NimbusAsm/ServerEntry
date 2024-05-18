using ServerEntry.Shared.Service;
using ServerEntry.Shared.Service.Monitor;

namespace ServerEntry.Data.Hardware.Services.HardwareMonitors;

public class MonitorBase : IMonitorService
{
    public string Name => GetName();

    private readonly MonitorStatus monitorStatus = new() { Status = ServiceStatus.Stopped };

    public MonitorStatus Status => monitorStatus;

    public void Monitor()
    {
        UpdateStatus(ServiceStatus.Starting);

        OnInitialize();

        UpdateStatus(ServiceStatus.Running);

        MainBody();
    }

    public void StopMonitoring()
    {
        UpdateStatus(ServiceStatus.Stopping);

        OnStopping();

        UpdateStatus(ServiceStatus.Stopped);
    }

    public virtual bool GetValue(out object result, out Exception? exception)
    {
        result = new();
        exception = new InvalidOperationException("You shouldn't call this function on it's base class");
        return false;
    }

    public virtual SortedDictionary<DateTime, object> GetValuesHistory(out Exception? exception)
    {
        exception = null;
        return [];
    }

    public virtual string GetName() { throw new NotImplementedException(); }

    public virtual void OnInitialize() { }

    public virtual void MainBody() { }

    public virtual void OnStopping() { }

    public void UpdateStatus(ServiceStatus status) => monitorStatus.Status = status;

    public void Dispose()
    {
        GC.SuppressFinalize(this);
    }
}
