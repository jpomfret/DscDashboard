<#  MIT License

    Copyright (c) 2018 fvanroie, NetwiZe.be

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
#>


##### Module Variables
#$debug = $false

# Load individual functions from scriptfiles
ForEach ($Folder in 'Private', 'Public')
{
    $FullPath = ('{0}/{1}/' -f $PSScriptRoot, $Folder)

    If (-Not (Test-Path -Path $FullPath))
    {
        Continue # to next Folder
    }

    $Scripts = Get-ChildItem -Recurse -Filter '*.ps1' -Path $FullPath | Where-Object { $_.Name -notlike '*.Tests.ps1' }

    ForEach ($Script in $Scripts)
    {

        Try
        {
            # Dot Source each function file
            . $Script.fullname

            # Export Public Functions only
            if ($Folder -eq 'Public')
            {
                Export-ModuleMember $script.basename
            }

        }
        Catch
        {
            # Display error
            Write-Error -Message ("Failed to import function {0}: {1}" -f $Script.name, $_)
        }

    } # ForEach

} # ForEach