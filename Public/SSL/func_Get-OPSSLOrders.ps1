function Get-OPSSLOrders {
    param (
        [int]$ID,

        [switch]$ExpiringSoon
    )
    try {
        # same for both requests
        $request_body = @{
            limit  = 1000
            status = "ACT&status=REQ"
        }
        # if ID is empty
        if ($ID -eq "") {
            $request = Invoke-OPRequest -Method Get -Endpoint "ssl/orders" -Body $request_body
            $request = $request.data.results
        }
        else {
            $request = Invoke-OPRequest -Method Get -Endpoint "ssl/orders/$($ID)"
            $request = $request.data
        }

        $statusMap = [PSCustomObject]@{
            "ACT" = "Active"
            "REQ" = "Requested"
            "PAI" = "Paid"
            "REJ" = "Rejected"
            "DEL" = "Deleted"
            "EXP" = "Expired"
            "FAI" = "Failed"
        }

        # create return object
        $return_object = @()
        foreach ($order in $request) {
            $return_object += [PSCustomObject]@{
                ID               = $order.id
                Product          = $order.product_name
                Hostname         = $order.common_name
                Status           = ($statusMap | Select-Object $($order.status)).$($order.status)
                ExpirationDate   = if ($null -ne $order.expiration_date) { [datetime]$order.expiration_date } else { $null }
                Period           = $order.period
                AutoRenew        = if ($order.autorenew -eq "on") { $true } else { $false }
                ValidationMethod = $order.validation_method
                EmailApprover    = $order.email_approver
            }
        }
        if ($ExpiringSoon) {
            $dateToExpire = (Get-Date).AddDays(30)
            $return_object = $return_object | Where-Object { $_.ExpirationDate -lt $dateToExpire -and $_.ExpirationDate -gt (Get-Date) }
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }
    if ($return_object.count -eq 0) {
        Write-Error "No SSL Orders found!"
    }
    return $return_object
}