# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function Add-CIisDefaultDocument
{
    <#
    .SYNOPSIS
    Adds a default document name to a website.
    
    .DESCRIPTION
    If you need a custom default document for your website, this function will add it.  The `FileName` argument should be a filename IIS should use for a default document, e.g. home.html.
    
    If the website already has `FileName` in its list of default documents, this function silently returns.
    
    Beginning with Carbon 2.0.1, this function is available only if IIS is installed.

    .EXAMPLE
    Add-CIisDefaultDocument -SiteName MySite -FileName home.html
    
    Adds `home.html` to the list of default documents for the MySite website.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the site where the default document should be added.
        $SiteName,
        
        [Parameter(Mandatory=$true)]
        [string]
        # The default document to add.
        $FileName
    )
    
    Set-StrictMode -Version 'Latest'

    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $section = Get-CIisConfigurationSection -SiteName $SiteName -SectionPath 'system.webServer/defaultDocument'
    if( -not $section )
    {
        return
    }

    [Microsoft.Web.Administration.ConfigurationElementCollection]$files = $section.GetCollection('files')
    $defaultDocElement = $files | Where-Object { $_["value"] -eq $FileName }
    if( -not $defaultDocElement )
    {
        Write-IisVerbose $SiteName 'Default Document' '' $FileName
        $defaultDocElement = $files.CreateElement('add')
        $defaultDocElement["value"] = $FileName
        $files.Add( $defaultDocElement )
        $section.CommitChanges() 
    }
}

