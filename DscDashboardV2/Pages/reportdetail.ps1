New-UDPage -Url '/ReportDetail/:reportid' -Endpoint {

Param(
    $reportId
)

$session:ReportId = $reportId

# Back Button
New-UDButton -Text "Back" -Icon arrow_left -OnClick {
        Invoke-UDRedirect -Url '/Reports'
} 

$data = Get-DscDashboardReportDetail -ReportId $reportId
$Hostname = $data.NodeName

New-DscDashboardCustomHeader -Text $Hostname -icon 'chart_bar'

    New-UDCollapsible -Items {

        New-UDCollapsibleItem -Id "ReportDetails" -Title "Report Information" -Icon "chart_line" -Content {

        New-UDRow {

            New-UDColumn -SmallSize 12 -MediumSize 12 -LargeSize 6 {

                        New-UDTable -Title "$hostname" -Headers @(" ", " ") -Endpoint {
                                $dict = [ordered]@{
                                'ReportId' = $data.ReportId
                                'Id' = $data.Id
                                'OperationType' = $data.OperationType
                                'RefreshMode' = $data.RefreshMode
                                'Status' = $data.Status
                                'LCMVersion' = $data.LCMVersion
                                'ReportFormatVersion' = $data.ReportFormatVersion
                                'ConfigurationVersion' = $data.ConfigurationVersion
                                'NodeName' = $data.NodeName
                                'IPAddress' = $data.IPAddress
                                'StartTime' = $data.StartTime
                                'EndTime' = $data.EndTime
                                }
                                $dict.GetEnumerator() | Out-UDTableData -Property @("Name", "Value")
                        }
            }
            New-UDColumn -SmallSize 12 -MediumSize 12 -LargeSize 6 {

                        New-UDTable -Title "LCM Configuration" -Headers @(" ", " ") -Endpoint {
                                $data.StatusData.MetaConfiguration.PSObject.Properties.GetEnumerator() | Where-Object { $_.TypeNameOfValue -ne 'System.Object[]' -And $_.Name -ne 'AgentId' } | Sort-Object Name | Out-UDTableData -Property @("Name", "Value")
                        }
                }

            }

        } -Active:$true

        New-UDCollapsibleItem -Id "Resources" -Title "Resources" -Icon cubes -Content {
                $properties = "ModuleName","Version","ResourceId","DesiredState","StartDate","Duration","RebootReq","DependsOn"

                $ConfigNames = Get-DscDashboardReportResources -ReportId $session:ReportId  | Select-Object -ExpandProperty configurationname -Unique

                Foreach ($config in $Confignames) {
                $a = New-UDElement -Tag "DIV" -Attributes @{ className = "CARD_CONTENT" } -Content {
                    New-UDElement -Tag "i" -Attributes @{ className = "fa fa-file-text-o" }
                    New-UDElement -Tag "span" -Content { " " }
                    New-UDElement -Tag "b" -Content { $config }
                }
                $a
                # Build Scriptblock for dynamic Endpoint
                $endpoint =  [Scriptblock]::Create(
@'
                        Import-Module "UniversalDashboard.Community"
                        Import-Module "DscDashboard"

                        $properties = "ModuleName","ModuleVersion","ResourceId","InDesiredState","StartDate","Duration","RebootRequested","DependsOn"
                        $data = Get-DscDashboardNodeResources -AgentId $session:AgentID | where-object {{ $_.ConfigurationName -eq "{0}" }}
                        $data | Out-UDTableData -Property $properties
'@ -f $config)

                    New-UDTable -Title "" -Headers $properties -Endpoint $endpoint -Id test
                }
        }

        # Check for Errors
        if ($data.StatusData.Error) {
            $hasErrors = $true
            $errCount = $data.StatusData.Error | Measure-Object | Select-Object -ExpandProperty Count
        } else {
            $hasErrors = $false
            $errCount = 0
        }

        New-UDCollapsibleItem -Id "Errors" -Title "$errCount Errors" -Icon bug -Content {

            if ($hasErrors) {
                New-UDCard -Title "LCM Error" -Text $data.StatusData.Error.ToString() -FontColor red -Watermark warning -BackgroundColor '#FEF4F4'
            } else {
                New-UDCard -Title "LCM OK" -Text "No errors reported" -FontColor green -Watermark check -BackgroundColor '#F4FEF4'
            }

        } -Active:$hasErrors
    }

}
