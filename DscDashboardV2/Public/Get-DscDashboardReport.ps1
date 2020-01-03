﻿<#  MIT License

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


Function Get-DscDashboardReport
{

    $Query = @"
        select top 50 node.*, report.* from StatusReport report
        left join RegistrationData node on report.Id=node.AgentId
        WHERE (StartTime<CURRENT_TIMESTAMP)
        ORDER BY report.StartTime desc


"@

    $data = @()

    # Run the SQL query
        # Run the SQL query
        Get-ODBCData -Query $query -ConnectionString $env:DSC_CONNECTIONSTRING  |

    # Format the SQL results
    ForEach-Object {

        # Extract Additional JSON data and convert it to PSObject
        Try
        {

            $AdditionalData = $_.AdditionalData | ConvertFrom-Json
            $OSVersion = $additionalData | Where-Object { $_.key -eq "OSVersion"} | Select-Object -ExpandProperty Value | ConvertFrom-Json | Select-Object -ExpandProperty VersionString
            $PSVersion = $additionalData | Where-Object { $_.key -eq "PSVersion"} | Select-Object -ExpandProperty Value | ConvertFrom-Json | Select-Object -ExpandProperty PSVersion

            # Somehow this check is needed for react
            if ($OSVersion -eq $null) { $OSVersion = $null }
            if ($PSVersion -eq $null) { $PSVersion = $null }

        }

        # If conversion fails, treat the data as a string
        Catch
        {

            $AdditionalData = $_.AdditionalData
            $OSVerion = 'Unknown'
            $PSVerion = 'Unknown'

        }

        # Extract Additional Status data and convert it to PSObject
        # We need to make this a valid JSON string before converting it
        Try
        {

            $StatusData = '{{"JSON":{0}}}' -f $_.StatusData | ConvertFrom-Json | Select-Object -ExpandProperty 'JSON' | ConvertFrom-Json

        }

        # If conversion fails, treat the data as a regular string
        Catch
        {

            $StatusData = $_.StatusData

        }

        # Build NodeDetail Uri
        $ReportDetail = "/ReportDetail/{0}" -f $_.JobId

        # Check Compliancy:
        $Compliancy, $Status = Get-DscDashboardNodeCompliancy -Status $_.Status -StartTime $_.StartTime -Url $ReportDetail `
            -RefreshFrequencyMins $StatusData.MetaConfiguration.RefreshFrequencyMins `
            -ResourcesNotInDesiredState $StatusData.ResourcesNotInDesiredState.count

        $Configurations = ('{{"configurations":{0}}}' -f $_.ConfigurationNames | ConvertFrom-Json).configurations
        $NumConfigurations = $Configurations | Measure-Object | Select-Object -ExpandProperty Count

        # Return Custom Object
        $data += [PSCustomObject]@{

            # Default Properties
            AgentId                    = $_.AgentId
            JobId                      = $_.JobId
            OperationType              = $_.OperationType
            Icon                       = New-UDLink -Text ' ' -Url $ReportDetail -Icon hospital_o #-FontColor Black
            NodeName                   = $_.Nodename
            JobLink                    = New-UDLink -Text $_.JobId -Url $ReportDetail #-FontColor Black
            IP                         = ($_.IPAddress -split ";" | Where-Object { $_ -notin "127.0.0.1" -and $_ -notlike '*:*' }) -join ';'    # Filter out localhost end IPv6
            ConfigurationNames         = $_.ConfigurationNames
            NumConfigurations          = $NumConfigurations
            Status                     = $Status
            RebootRequested            = $_.RebootRequested
            StartTime                  = $_.StartTime #.GetDateTimeFormats()[93]

            # Calculated Properties
            NumberOfResources          = $StatusData.NumberOfResources
            ResourcesInDesiredState    = $StatusData.ResourcesInDesiredState.Count
            ResourcesNotInDesiredState = $StatusData.ResourcesNotInDesiredState.Count
            Compliancy                 = $Compliancy

            # Additional Data Properties
            OS                         = $OSVersion
            PSVersion                  = $PSVersion

        } # PSCustomObject

    } # ForEach

    Return $data

} # Function