# OpenProviderPowershell

## [Changelog](./CHANGELOG.md)

## How to use

OpenProviderPowershell is available on PowerShellGallery! 

![PSGalleryVersion](https://img.shields.io/powershellgallery/v/OpenProviderPowershell?style=flat-square) ![PSGalleryDownloads](https://img.shields.io/powershellgallery/dt/OpenProviderPowershell?style=flat-square)

To install:

```powershell
Install-Module OpenProviderPowershell
```

Or to update:

```powershell
Update-Module OpenProviderPowershell
```

### Connecting/disconnecting

Connecting to OpenProvider is easy, simply run the following commands to get a connection to OpenProvider.

```powershell
Connect-OpenProvider
# or
$Credential = Get-Credential
Connect-OpenProvider -Credential $Credential
```

Connecting to the sandbox environment is now possible too! Just add ```-Sandbox``` to Connect-OpenProvider.

For security run the following at the end of your session/script.

```powershell
Disconnect-OpenProvider
```

### Nameservers

You are able to add, get, remove and update OpenProvider nameservers.

Note: to add nameservers, you must have the domain in your OpenProvider portal!

```powershell
Get-OPNameserver
Add-OPNameserver -Name "ns1.testdomain.com" -IP "123.456.789.10"
Remove-OPNameserver -Name "ns1.testdomain.com"
Update-OPNameserver -Name "ns1.testdomain.com" -IP "10.987.654.32"
```

### DNS Zones

Getting a zone is necesary for adding and setting DNS records. To get a Zone ID for a domain run the following:

```powershell
Get-OPZone -Domain "testdomain.com"
```

Query zone records with the following:

```powershell
Get-OPZoneRecords -Domain "testdomain.com"
```

Note: by default will get OpenProvider zones for a domain when both OpenProvider and Sectigo are present, you can add the parameter ```-Provider sectigo``` to get the records in the sectigo zone.

Adding records is simple: provide the domain name, Zone ID, type of record and the value. Example:

```powershell
Add-OPZoneRecord -Domain "testdomain.com" -ZoneID "12345678" -Type TXT -Value "v=SPF1 -all"
```

Note: The following DNS records can be added through this module:

- A
- AAAA
- CAA
- CNAME
- MX
- TXT
- NS

Here is an example how you could get a DNS record and adjust it to your needs:

```powershell
$domain = "testdomain.com"
# get the zone id
$zone = Get-OPZone -Domain $domain -Provider sectigo
# get the records assosciated with the domain
$zone_records = Get-OPZoneRecords -Domain $domain -Provider sectigo
# filter the original record
$original_record = $zone_records | Where-Object { ($_.type -eq "TXT") -and ($_.value -eq "v=SPF1 +all") }
```

### Domain

You can search for all domains in your OpenProvider directory:

```powershell
Get-OPDomain
```

Or you can search for a specific domain:

```powershell
Get-OpDomain -Domain "testdomain.com"
```

For a more detailed report such as nameservers connected to the domain epiry dates or renewal information add the ```-Detailed``` option.

Availability and pricing for a domain can be checked with the following command, multiple domains are accepted (they must be in a list like the example below):

```powershell
$domainlist = @(
    "iwanttocheck.com"
    "thesedomains.au"
    "ohandthisone.nl"
)
Get-OPDomainAvailability -Domain $domainlist
```

This can be useful if you want to check the availibility and price before you go ahead and register a domain.

## Disclaimer

This module has no affilation with OpenProvider, just a personal/community project.

This module is still in development, feedback is welcome and endpoint/feature requests are welcome.

Please refer to [OpenProvider API Docs](https://docs.openprovider.com/doc/all) for feature/endpoint requests.
