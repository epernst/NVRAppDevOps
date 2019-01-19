function Read-ALConfiguration
{
    Param(
        #Path to the repository
        $Path='.\',
        #If set, scripts will work as under VSTS/TFS. If not set, it will work in "interactive" mode
        $Build,
        #Password which will be used for the container user - when WindowsAuthentication used, it is the domain password of the current user
        $Password,
        $Username=$env:USERNAME,
        [ValidateSet('Windows', 'NavUserPassword')]
        $Auth='Windows',
        [hashtable]$PathMap,
        [String]$PathMapString,
        [String]$DockerHost,
        [PSCredential]$DockerHostCred,
        [bool]$DockerHostSSL
    )
    if ($PathMapString -and (-not $PathMap)) {
        $PathMap = @{
            "$($PathMapString.Split(';')[0])" = "$($PathMapString.Split(';')[1])"
        }
        write-host "Path map $PathMap"
    }
    $SettingsScript = (Join-Path $Path 'Scripts\Settings.ps1')
    if (Test-Path $SettingsScript) {
        Write-Host "Running $SettingsScript ..."
        . (Join-Path $Path 'Scripts\Settings.ps1')
    }
    $ClientPath = Get-ALDesktopClientPath -ContainerName $ContainerName
    $Configuration = Get-ALConfiguration `
                            -ContainerName $ContainerName `
                            -ImageName $ImageName `
                            -LicenseFile $LicenseFile `
                            -VsixPath $VsixPath `
                            -PlatformVersion $AppJSON.platform `
                            -AppVersion $AppJSON.version `
                            -TestAppVersion $TestAppJSON.version `
                            -AppName $AppJSON.name `
                            -TestAppName $TestAppJSON.name `
                            -AppFile $AppFile `
                            -TestAppFile $TestAppFile `
                            -Publisher $AppJSON.publisher `
                            -TestPublisher $TestAppJSON.publisher `
                            -RepoPath $RepoPath `
                            -AppPath $AppPath `
                            -TestAppPath $TestAppPath `
                            -Build $Build `
                            -Password $Password `
                            -ClientPath $ClientPath `
                            -AppDownloadScript $AppDownloadScript `
                            -PathMap $PathMap `
                            -Auth $Auth `
                            -Username $Username `
                            -RAM $RAM `
                            -DockerHost $DockerHost `
                            -DockerHostSSL $DockerHostSSL `
                            -DockerHostCred $DockerHostCred `
                            -optionalParameters $optionalParameters

    Write-Output $Configuration
}