function Get-OPDomain {
    [CmdletBinding()]
    param (
        [parameter(Position = 0)]
        [string]$Domain,

        [switch]$Detailed
    )
    #variables for both requests
    $limit = 500

    if ($Domain -ne "") {
        $domain_request_body = @{
            full_name = $Domain
            status    = "ACT"
        }
        try {
            $domains = (Invoke-OPRequest -Method Get -Endpoint "domains" -Body $domain_request_body).data.results
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
    
    else {
        $domains = @()
        $offset = 0
        $req_body_total = @{
            status = "ACT"
        }
        $total_domains = (Invoke-OPRequest -Method Get -Endpoint "domains" -Body $req_body_total).data.total
        Write-Verbose "$total_domains found"
        try {
            do {
                if ($total_domains -gt $limit) {
                    $activity_splat = @{
                        Activity        = "Retrieving domains..."
                        Status          = "[$offset/$total_domains]"
                        PercentComplete = (($offset / $total_domains) * 100)
                    }
                    Write-Progress @activity_splat
                }
                $domain_request_body = @{
                    limit  = $limit
                    offset = $offset
                    status = "ACT"
                }
                $domains += (Invoke-OPRequest -Method Get -Endpoint "domains" -Body $domain_request_body).data.results
                $offset += 500
            } until (
                $offset -ge $total_domains
            )
        }
        catch {
            Write-Error $_.Exception.Message
        }    
    }

    #Return object, sort clutter from domains
    if ($domains.Count -ge 1) {
        $return_object = @()
        $i = 0
        foreach ($item in $domains) {
            $domain_object = [pscustomobject]@{
                ID     = $domains[$i].id
                Domain = ($domains[$i].domain.name, $domains[$i].domain.extension) -join "."
            }
            if ($Detailed) {
                $domain_object | Add-Member @{
                    ResellerID      = $domains[$i].reseller_id
                    CreationDate    = [DateTime]$domains[$i].creation_date
                    ExpirationDate  = [DateTime]$domains[$i].expiration_date
                    AutoRenew       = $domains[$i].autorenew
                    RenewalDate     = [DateTime]$domains[$i].renewal_date
                    WhoIs           = $domains[$i].is_hosted_whois
                    DNSSec          = $domains[$i].is_dnssec_enabled
                    Sectigo         = $domains[$i].is_sectigo_dns_enabled
                    NameserverGroup = $domains[$i].ns_group
                    OwnerHandle     = $domains[$i].owner_handle
                    AdminHandle     = $domains[$i].admin_handle
                    TechHandle      = $domains[$i].tech_handle

                }
            }
            $return_object += $domain_object
            $i++
        }
    }
    else {
        Write-Error "Not able to find any domains with $Domain as search query"
    }
    return $return_object 
}