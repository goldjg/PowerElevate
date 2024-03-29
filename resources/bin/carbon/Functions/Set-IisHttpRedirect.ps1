
function Set-CIisHttpRedirect
{
    <#
    .SYNOPSIS
    Turns on HTTP redirect for all or part of a website.

    .DESCRIPTION
    Configures all or part of a website to redirect all requests to another website/URL.  By default, it operates on a specific website.  To configure a directory under a website, set `VirtualPath` to the virtual path of that directory.

    Beginning with Carbon 2.0.1, this function is available only if IIS is installed.

    .LINK
    http://www.iis.net/configreference/system.webserver/httpredirect#005
	
    .LINK
    http://technet.microsoft.com/en-us/library/cc732969(v=WS.10).aspx

    .EXAMPLE
    Set-CIisHttpRedirect -SiteName Peanuts -Destination 'http://new.peanuts.com'

    Redirects all requests to the `Peanuts` website to `http://new.peanuts.com`.

    .EXAMPLE
    Set-CIisHttpRedirect -SiteName Peanuts -VirtualPath Snoopy/DogHouse -Destination 'http://new.peanuts.com'

    Redirects all requests to the `/Snoopy/DogHouse` path on the `Peanuts` website to `http://new.peanuts.com`.

    .EXAMPLE
    Set-CIisHttpRedirect -SiteName Peanuts -Destination 'http://new.peanuts.com' -StatusCode 'Temporary'

    Redirects all requests to the `Peanuts` website to `http://new.peanuts.com` with a temporary HTTP status code.  You can also specify `Found` (HTTP 302), or `Permanent` (HTTP 301).
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The site where the redirection should be setup.
        $SiteName,
        
        [Alias('Path')]
        [string]
        # The optional path where redirection should be setup.
        $VirtualPath = '',
        
        [Parameter(Mandatory=$true)]
        [string]
        # The destination to redirect to.
        $Destination,
        
        [Carbon.Iis.HttpResponseStatus]
        # The HTTP status code to use.  Default is `Found`.  Should be one of `Found` (HTTP 302), `Permanent` (HTTP 301), or `Temporary` (HTTP 307).
        [Alias('StatusCode')]
        $HttpResponseStatus = [Carbon.Iis.HttpResponseStatus]::Found,
        
        [Switch]
        # Redirect all requests to exact destination (instead of relative to destination).  I have no idea what this means.  [Maybe TechNet can help.](http://technet.microsoft.com/en-us/library/cc732969(v=WS.10).aspx)
        $ExactDestination,
        
        [Switch]
        # Only redirect requests to content in site and/or path, but nothing below it.  I have no idea what this means.  [Maybe TechNet can help.](http://technet.microsoft.com/en-us/library/cc732969(v=WS.10).aspx)
        $ChildOnly
    )
    
    Set-StrictMode -Version 'Latest'

    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $settings = Get-CIisHttpRedirect -SiteName $SiteName -Path $VirtualPath
    $settings.Enabled = $true
    $settings.Destination = $destination
    $settings.HttpResponseStatus = $HttpResponseStatus
    $settings.ExactDestination = $ExactDestination
    $settings.ChildOnly = $ChildOnly
    	
    if( $pscmdlet.ShouldProcess( (Join-CIisVirtualPath $SiteName $VirtualPath), "set HTTP redirect settings" ) ) 
    {
        $settings.CommitChanges()
    }
}

