function Install-ALNugetPackage
{
    [CmdletBinding()]
    Param(
        $PackageName,
        $Version,
        $Source,
        $ApiKey,
        $SourceUrl,
        $DependencyVersion='Highest',
        $TargetPath,
        $Key,
        $IdPrefix #Will be used before AppName and all Dependency names
    )
    #$sources = Get-PackageSource | Where-Object {$_.Name -eq $Source}
    #if (-not $sources) {
        #Write-Host "Adding nuget source..."
        #Write-Verbose "nuget.exe sources Add -Name `"$Source`" -Source `"$SourceUrl`""
    if ($SourceUrl) {
        $exists = nuget.exe sources list -Format short | Where-Object {$_ -like "*$($SourceUrl)"}
        if ($exists) {
            Write-Host "Source already exists"
        } else {
            nuget.exe sources Add -Name "$Source" -Source "$SourceUrl"
        }
        if ($Key) {
            Write-Host "Update source key"
            nuget.exe source update -Name "$Source" -Username 'user' -Password $Key -StorePasswordInClearText
        }
    }
    $TempFolder = Join-Path $env:TEMP 'ALNugetApps'
    if (Test-Path $TempFolder) {
        Remove-Item $TempFolder -Force | Out-Null
    }
    New-Item -Path $TempFolder -ItemType directory -Force | Out-Null
    Write-Host "Installing package '$IdPrefix$(Format-AppNameForNuget $PackageName)' from '$Source' to $TargetPath..."
    if ($Version) {
        if ($Source) {
            nuget.exe install -Source "$Source" -Version $Version -OutputDirectory $TempFolder -NoCache -DependencyVersion $DependencyVersion "$IdPrefix$(Format-AppNameForNuget $PackageName)"
        } else {
            nuget.exe install -Version $Version -OutputDirectory $TempFolder -NoCache -DependencyVersion $DependencyVersion "$IdPrefix$(Format-AppNameForNuget $PackageName)"
        }
    } else {
        if ($Source) {
            nuget.exe install -Source "$Source" -OutputDirectory $TempFolder -NoCache -DependencyVersion $DependencyVersion "$IdPrefix$(Format-AppNameForNuget $PackageName)"
        } else {
            nuget.exe install -OutputDirectory $TempFolder -NoCache -DependencyVersion $DependencyVersion "$IdPrefix$(Format-AppNameForNuget $PackageName)"
        }
    }
    Write-Host "Moving app files from $TempFolder to $TargetPath..."
    Get-ChildItem -Path $TempFolder -Filter *.app -Recurse | Copy-Item -Destination $TargetPath -Container -Force | Out-Null
    Write-Host "Removing folder $TempFolder..."
    Remove-Item $TempFolder -Force -Recurse | Out-Null
}