
function Get-CIPAddress
{
    <#
    .SYNOPSIS
    Gets the IP addresses in use on the local computer.

    .DESCRIPTION
    The .NET API for getting all the IP addresses in use on the current computer's network intefaces is pretty cumbersome.  If all you care about is getting the IP addresses in use on the current computer, and you don't care where/how they're used, use this function.

    If you *do* care about network interfaces, then you'll have to do it yourself using the [System.Net.NetworkInformation.NetworkInterface](http://msdn.microsoft.com/en-us/library/System.Net.NetworkInformation.NetworkInterface.aspx) class's [GetAllNetworkInterfaces](http://msdn.microsoft.com/en-us/library/system.net.networkinformation.networkinterface.getallnetworkinterfaces.aspx) static method, e.g.

        [Net.NetworkInformation.NetworkInterface]::GetNetworkInterfaces()

    .LINK
    http://stackoverflow.com/questions/1069103/how-to-get-my-own-ip-address-in-c

    .OUTPUTS
    System.Net.IPAddress.

    .EXAMPLE
    Get-CIPAddress

    Returns all the IP addresses in use on the local computer, IPv4 *and* IPv6.

    .EXAMPLE
    Get-CIPAddress -V4

    Returns just the IPv4 addresses in use on the local computer.

    .EXAMPLE
    Get-CIPAddress -V6

    Retruns just the IPv6 addresses in use on the local computer.
    #>
    [CmdletBinding(DefaultParameterSetName='NonFiltered')]
    param(
        [Parameter(ParameterSetName='Filtered')]
        [Switch]
        # Return just IPv4 addresses.
        $V4,

        [Parameter(ParameterSetName='Filtered')]
        [Switch]
        # Return just IPv6 addresses.
        $V6
    )

    Set-StrictMode -Version 'Latest'

    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    [Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() | 
        Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -ne 'Loopback' } | 
        ForEach-Object { $_.GetIPProperties() } | 
        Select-Object -ExpandProperty UnicastAddresses  | 
        Select-Object -ExpandProperty Address |
        Where-Object {
            if( $PSCmdlet.ParameterSetName -eq 'NonFiltered' )
            {
                return ($_.AddressFamily -eq 'InterNetwork' -or $_.AddressFamily -eq 'InterNetworkV6')
            }

            if( $V4 -and $_.AddressFamily -eq 'InterNetwork' )
            {
                return $true
            }

            if( $V6 -and $_.AddressFamily -eq 'InterNetworkV6' )
            {
                return $true
            }

            return $false
        }
}
