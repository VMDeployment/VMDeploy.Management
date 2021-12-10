# Network

The network configuration is a set of Subnet Mask, Default Gateway and DNS Servers that are applied to the VM.
These are injected into the guest configuration deployment that is added as part of the deployment process.

Example psd1 definition:

```powershell
@{
    Name = "Contoso Network"
    Description = "Contoso internal AD network zone"
    Role = 'Network_Contoso'
    PrefixLength = 16
    DefaultGateway = '10.1.0.1'
    DnsServer = @(
        '10.0.1.1'
        '10.0.1.2'
        '10.0.1.3'
        '10.0.1.4'
    )
}
```
