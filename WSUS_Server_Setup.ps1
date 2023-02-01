### LINK: https://www.ajtek.ca/guides/how-to-setup-manage-and-maintain-wsus-part-1-choosing-your-server-os/

### WSUS Configuration Script TO BE TESTED ###


## Install WSUS with WID & UI MMC Console
Install-WindowsFeature -Name UpdateServices, UpdateServices-UI


##  Install WSUS with SQL Connectivity & UI MMC Console
Install-WindowsFeature -Name UpdateServices-DB, UpdateServices-UI


##  SQL Database location:
& "$env:ProgramFiles\Update Services\Tools\WsusUtil.exe" postinstall SQL_INSTANCE_NAME="HOSTNAME" CONTENT_DIR=C:\WSUS


##  WSUS Configuration Wizard: NOTE Do each step ONE BY ONE

    ###  Get and sync WSUS with Microsoft(?)
    $WSUSConfig = (Get-WSUSServer).GetConfiguration()
    Set-WsusServerSynchronization -SyncFromMU # Might not be possible with a dark site.


    ### Set Update Languages to English and save configuration settings
    $WSUSConfig.AllUpdateLanguagesEnabled = $false
    $WSUSConfig.SetEnabledUpdateLanguages("en")
    $WSUSConfig.Save()


    ### To be determined if needed for Subscription
    $Subscription = (Get-WSUSServer).GetSubscription()
    $Subscription.StartSynchronizationForCategoryOnly()
    $Count=0
    While ($Subscription.GetSynchronizationStatus() -ne 'NotProcessing') {
        if ($Count -eq 0) {
            Write-Output "Starting first synchronization to get available Products... This will take roughly 53-112 minutes to complete with 2GB RAM, and 8-25 Minutes with 4GB RAM."
        }
        elseif ($Count -eq 1) {
            Write-Output "$Count Minute Elapsed."
        }
        else {
            Write-Output "$Count Minutes Elapsed."
        }
        Start-Sleep -Seconds 60
        $Count++
    }
    # If you want everything including Drivers
    Get-WsusClassification | Set-WsusClassification
    # If you don’t want Drivers
    Get-WsusClassification | Where-Object { $_.Classification.Title -notlike 'Driver*' } | Set-WsusClassification

