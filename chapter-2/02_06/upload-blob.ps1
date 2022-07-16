param (
    [string]$fileName,
    [string]$containerName,
    [string]$blobAccessTier,
    [string]$content
)
try
{
    Write-Output "UTC is: $(Get-Date)"
    
    $c = Get-AzContext -ErrorAction stop
    if ($c)
    {
        Write-Output "Context is: "
        $c | Select-Object Account, Subscription, Tenant, Environment | Format-List | Out-String

        $ENV:CONTENT | Out-FIle $fileName
        Set-AzStorageBlobContent -File $fileName -Container $containerName -blob $fileName -StandardBlobTier $blobAccessTier
    }
    else
    {
        throw 'Cannot get a context'
    }
}
catch
{
    Write-Warning $_
    Write-Warning $_.exception
}