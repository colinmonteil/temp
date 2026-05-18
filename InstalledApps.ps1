Function Get-InstalledApplication {
  $Computername = $env:COMPUTERNAME

  #Registry Hives

  $Object = @()

  $excludeArray = ('Security Update for Windows',
    'Update for Windows',
    'Update for Microsoft .NET',
    'Security Update for Microsoft',
    'Hotfix for Windows',
    'Hotfix for Microsoft .NET Framework',
    'Hotfix for Microsoft Visual Studio 2007 Tools',
    'Microsoft Visual C++ 2010',
    'cwbin64a',
    'Hotfix',
    'Microsoft Edge Update')

  $excludePublisherArray = ('Microsoft Corporation')

  [long]$HIVE_HKROOT = 2147483648
  [long]$HIVE_HKCU = 2147483649
  [long]$HIVE_HKLM = 2147483650
  [long]$HIVE_HKU = 2147483651
  [long]$HIVE_HKCC = 2147483653
  [long]$HIVE_HKDD = 2147483654

  Foreach ($EachServer in $Computername) {
    
    $Query = Get-WmiObject -ComputerName $EachServer -Query 'Select AddressWidth, DataWidth,Architecture from Win32_Processor'
    foreach ($i in $Query) {
      If ($i.AddressWidth -eq 64) {
        $OSArch = '64-bit'
      }
      Else {
        $OSArch = '32-bit'
      }
    }

    Switch ($OSArch) {
      '64-bit' {
        $RegProv = Get-WmiObject -Namespace 'root\Default' -List -ComputerName $EachServer | Where-Object { $_.Name -eq 'StdRegProv' }
        $Hive = $HIVE_HKLM
        $RegKey_64BitApps_64BitOS = 'Software\Microsoft\Windows\CurrentVersion\Uninstall'
        $RegKey_32BitApps_64BitOS = 'Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
        $RegKey_32BitApps_32BitOS = 'Software\Microsoft\Windows\CurrentVersion\Uninstall'

        #############################################################################

        # Get SubKey names

        $SubKeys = $RegProv.EnumKey($HIVE, $RegKey_64BitApps_64BitOS)

        # Make Sure No Error when Reading Registry

        if ($SubKeys.ReturnValue -eq 0) {
          # Loop through all returned subkeys
          ForEach ($Name in $SubKeys.sNames) {
            $SubKey = "$RegKey_64BitApps_64BitOS\$Name"
            $ValueName = 'DisplayName'
            $ValuesReturned = $RegProv.GetStringValue($Hive, $SubKey, $ValueName)
            $AppName = $ValuesReturned.sValue
            $Version = ($RegProv.GetStringValue($Hive, $SubKey, 'DisplayVersion')).sValue
            $Publisher = ($RegProv.GetStringValue($Hive, $SubKey, 'Publisher')).sValue
            $InstallDate = ($RegProv.GetStringValue($Hive, $SubKey, 'InstallDate')).sValue
            $donotwrite = $false

            if ($AppName.length -gt '0') {

              Foreach ($exclude in $excludeArray) {
                if ($AppName.StartsWith($exclude) -eq $TRUE) {
                  $donotwrite = $true
                  break
                }
              }
              Foreach ($exclude in $excludePublisherArray) {
                if ($Publisher -eq $exclude) {
                  $donotwrite = $true
                  break
                }
              }
              if ($donotwrite -eq $false) {
                $Object += New-Object PSObject -Property @{
                  Application  = $AppName;
                  Architecture = '64-BIT';
                  ServerName   = $EachServer;
                  Version      = $Version;
                  Publisher    = $Publisher;
                  InstallDate  = $InstallDate;
                }
              }

            }

          }
        }

        #############################################################################

        $SubKeys = $RegProv.EnumKey($HIVE, $RegKey_32BitApps_64BitOS)

        # Make Sure No Error when Reading Registry

        if ($SubKeys.ReturnValue -eq 0) {

          # Loop Through All Returned SubKEys

          ForEach ($Name in $SubKeys.sNames) {

            $SubKey = "$RegKey_32BitApps_64BitOS\$Name"

            $ValueName = 'DisplayName'
            $ValuesReturned = $RegProv.GetStringValue($Hive, $SubKey, $ValueName)
            $AppName = $ValuesReturned.sValue
            $Version = ($RegProv.GetStringValue($Hive, $SubKey, 'DisplayVersion')).sValue
            $Publisher = ($RegProv.GetStringValue($Hive, $SubKey, 'Publisher')).sValue
            $InstallDate = ($RegProv.GetStringValue($Hive, $SubKey, 'InstallDate')).sValue
            $donotwrite = $false

            if ($AppName.length -gt '0') {
              Foreach ($exclude in $excludeArray) {
                if ($AppName.StartsWith($exclude) -eq $TRUE) {
                  $donotwrite = $true
                  break
                }
              }
              Foreach ($exclude in $excludePublisherArray) {
                if ($Publisher -eq $exclude) {
                  $donotwrite = $true
                  break
                }
              }
              if ($donotwrite -eq $false) {
                $Object += New-Object PSObject -Property @{
                  Application  = $AppName;
                  Architecture = '32-BIT';
                  ServerName   = $EachServer;
                  Version      = $Version;
                  Publisher    = $Publisher;
                  InstallDate  = $InstallDate;
                }
              }
            }

          }

        }

      } #End of 64 Bit

      ######################################################################################

      ###########################################################################################

      '32-bit' {

        $RegProv = Get-WmiObject -Namespace 'root\Default' -List -ComputerName $EachServer | Where-Object { $_.Name -eq 'StdRegProv' }

        $Hive = $HIVE_HKLM

        $RegKey_32BitApps_32BitOS = 'Software\Microsoft\Windows\CurrentVersion\Uninstall'

        #############################################################################

        # Get SubKey names

        $SubKeys = $RegProv.EnumKey($HIVE, $RegKey_32BitApps_32BitOS)

        # Make Sure No Error when Reading Registry

        if ($SubKeys.ReturnValue -eq 0) {
          # Loop Through All Returned SubKEys

          ForEach ($Name in $SubKeys.sNames) {
            $SubKey = "$RegKey_32BitApps_32BitOS\$Name"
            $ValueName = 'DisplayName'
            $ValuesReturned = $RegProv.GetStringValue($Hive, $SubKey, $ValueName)
            $AppName = $ValuesReturned.sValue
            $Version = ($RegProv.GetStringValue($Hive, $SubKey, 'DisplayVersion')).sValue
            $Publisher = ($RegProv.GetStringValue($Hive, $SubKey, 'Publisher')).sValue
            $InstallDate = ($RegProv.GetStringValue($Hive, $SubKey, 'InstallDate')).sValue

            if ($AppName.length -gt '0') {

              $Object += New-Object PSObject -Property @{
                Application  = $AppName;
                Architecture = '32-BIT';
                ServerName   = $EachServer;
                Version      = $Version;
                Publisher    = $Publisher;
                InstallDate  = $InstallDate;
              }
            }
          }
        }
      }#End of 32 bit
    } # End of Switch
  }
  Write-Output($Object)
}

Get-InstalledApplication