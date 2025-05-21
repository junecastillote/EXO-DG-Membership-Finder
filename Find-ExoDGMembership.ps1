
<#PSScriptInfo

.VERSION 1.0

.GUID 2086136e-dfc8-4cc1-98f5-614228c9fab4

.AUTHOR June Castillote

.COMPANYNAME

.COPYRIGHT

.TAGS

.LICENSEURI https://github.com/junecastillote/EXO-DG-Membership-Finder/blob/main/LICENSE

.PROJECTURI https://github.com/junecastillote/EXO-DG-Membership-Finder

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

#Requires -Module ExchangeOnlineManagement

<#
.SYNOPSIS
Finds the distribution groups in Exchange Online where a specified email address is a member.

.DESCRIPTION
This script checks whether a specific user (identified by their email address) is a member of one or more Exchange Online distribution groups.
It can either evaluate all distribution groups or only a specified subset.

Results are optionally displayed on the console and/or saved to a CSV file.

.PARAMETER MemberEmailAddress
The primary SMTP address of the user whose distribution group membership is being checked. This is a required parameter.

.PARAMETER DistributionGroupEmailAddress
An optional array of distribution group email addresses to limit the membership check to specific groups.
If omitted, the script checks all distribution groups in the organization.

.PARAMETER OutCsvFile
Optional path to save the output as a CSV file. If not specified, the script will generate a filename based on the user's email and the current timestamp.

.PARAMETER ReturnResult
Switch to display matching group results on the console in addition to exporting them to CSV.

.EXAMPLE
.\Find-ExoDGMembership.ps1 -MemberEmailAddress user@example.com

Checks all distribution groups to see if 'user@example.com' is a member. Saves the results to a timestamped CSV file in the script directory.

.EXAMPLE
.\Find-ExoDGMembership.ps1 -MemberEmailAddress user@example.com -DistributionGroupEmailAddress "group1@example.com","group2@example.com"

Checks only the specified distribution groups to see if 'user@example.com' is a member.

.EXAMPLE
.\Find-ExoDGMembership.ps1 -MemberEmailAddress user@example.com -ReturnResult

Displays matching groups in the console and saves them to a CSV file.

.EXAMPLE
.\Find-ExoDGMembership.ps1 -MemberEmailAddress user@example.com -OutCsvFile "C:\Temp\membership.csv"

Saves the membership results to the specified path.

.NOTES
Author: June Castillote
Date: 2025-05-21
Requires: Exchange Online PowerShell
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $MemberEmailAddress,

    [Parameter()]
    [string[]]
    $DistributionGroupEmailAddress,

    [Parameter()]
    [string]
    $OutCsvFile,

    [Parameter()]
    [switch]
    $ReturnResult
)

$InformationPreference = 'Continue'
$ProgressPreference = 'Continue'

if (!$OutCsvFile) {
    $OutCsvFile = $("$($PSScriptRoot)\$($MemberEmailAddress)_Membership_$((Get-Date).ToString('yyyy-MM-dd_hh-mm-ss-tt')).csv")
}

$dg = [System.Collections.ArrayList]@()
if (!$DistributionGroupEmailAddress) {
    Write-Information "Getting all distribution groups.."
    $null = $dg.AddRange((Get-DistributionGroup -ResultSize Unlimited -WarningAction SilentlyContinue))
}
else {
    Write-Information "Getting specified distribution groups.."
    foreach ($item in $DistributionGroupEmailAddress) {
        $null = $dg.Add((Get-DistributionGroup -Identity $item -WarningAction SilentlyContinue))
        # $null = $dg.Add($item)
    }
}

if (!$dg) {
    Write-Information "Distribution group object not found.."
    return $null
}

$memberShipCount = 0
for ($i = 0; $i -lt $dg.Count; $i++) {
    $isMember = $false
    $percentComplete = [math]::Round(($i / $dg.Count) * 100)
    Write-Progress -Activity "Checking Distribution Group Membership" `
        -Status "$($dg[$i].Name) ($($i+1)/$($dg.Count))" `
        -PercentComplete $percentComplete

    $members = @(Get-DistributionGroupMember -Identity $dg[$i] -ResultSize Unlimited -ErrorAction SilentlyContinue)

    $isMember = $members.PrimarySmtpAddress -contains $MemberEmailAddress

    if ($isMember) {
        $result = [PSCustomObject]@{
            DistributionGroupName  = $dg[$i].Name
            DistributionGroupEmail = $dg[$i].PrimarySmtpAddress
            IsMember               = $isMember
        }
        $memberShipCount++
        $result | Export-Csv $OutCsvFile -Append -Force

        if ($ReturnResult) {
            $result
        }
    }
}

Write-Progress -Activity "Checking Distribution Group Membership" -Completed

if ($memberShipCount -eq 0) {
    Write-Information "No distribution group membership found for user $($MemberEmailAddress)."
    return $null
}

Write-Information "Result saved to $($OutCsvFile)."