# DNS Server

To define DNS Server, create PSD1 files in this layout:

```powershell
@{
    Name = "Contoso DNS Servers"
    Role = "DNS_Contoso"
    Addresses = @(
        '10.0.1.1'
        '10.0.1.2'
    )
}
```

Explicitly specifying any arbitrary DNS Server during deployment is possible, however unless defined here these are constrained to the admins role.

> DNS Servers assigned through the Network configuration set are unaffected by permissions defined here, as these are covered under the role assignment of the entire network config set.
