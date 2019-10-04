function Read-ALTestResult
{
    param(
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $ContainerName=$env:ContainerName,
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $Password='',
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $Username=$env:USERNAME,
        [ValidateSet('Windows', 'NavUserPassword')]
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $Auth='Windows'
    )
    $ServerConfig = Get-NavContainerServerConfiguration -ContainerName $ContainerName
    $CompanyName = Invoke-ScriptInNavContainer -containerName $ContainerName `
                    -scriptblock {(Get-NAVCompany -ServerInstance $ServerConfig.ServerInstance | Select-object -First 1).CompanyName} 
    Write-Host "Company name = '$CompanyName'"
    $CompanyName = [uri]::EscapeDataString($CompanyName)

    if ((-not $Password) -or ($Password -eq '')) {
        $proxy = New-WebServiceProxy -Uri "http://$($ContainerName):7047/$($ServerConfig.ServerInstance)/WS/$($CompanyName)/Page/CALTestResults" -Class WS -Namespace NVRAppDevOps -UseDefaultCredential
    } else {
        Write-Host "Using passed password"
        $PWord = ConvertTo-SecureString -String $Password -AsPlainText -Force
        $User = $Username
        $credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User,$PWord
        $proxy = New-WebServiceProxy -Uri "http://$($ContainerName):7047/$($ServerConfig.ServerInstance)/WS/$($CompanyName)/Page/CALTestResults" -Class WS -Namespace NVRAppDevOps -Credential $credentials
    }

    $TestResults = $proxy.ReadMultiple(@(),'',100000)
    Write-Output $TestResults
}
