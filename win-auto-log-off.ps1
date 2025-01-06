# Work In progess - This script is not yet complete

#Params For This Script File :
param (
    [int]$TimeoutInSeconds = 60  # Default value is 60 seconds (1 minute)
)

# Required for Set-ScreenSaverTimeout
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class SystemParamInfo {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int action, int param, ref int vparam, int init);

    public const int SPI_SETSCREENSAVETIMEOUT = 0x000F;
    public const int SPI_SETSCREENSAVEACTIVE = 0x0011;
    public const int SPI_SETLOCKSCREEN = 0x0014;
}
"@
# Required For Set-OnResumeDisplayLogon
$signature = @"
[DllImport("user32.dll")]
public static extern bool SystemParametersInfo(int uAction, int uParam, ref int lpvParam, int flags );
"@
# Required For Set-OnResumeDisplayLogon
$systemParamInfo = Add-Type -memberDefinition  $signature -Name ScreenSaver -passThru

Function Set-ScreenSaverTimeout {
    Param ([Int32]$value = 10)  # Timeout in minutes
    
    $seconds = $value * 60  # Convert minutes to seconds
    $nullVar = 0
    
    # Call SystemParametersInfo to set the screen saver timeout
    [SystemParamInfo]::SystemParametersInfo(15, $seconds, [REF]$nullVar, 2)
    
    Write-Host "Screen saver timeout set to $value minutes."
}

Function Set-OnResumeDisplayLogon
{
    Param ([Int32]$value = 1)
    [Int32]$nullVar = 0
    $systemParamInfo::SystemParametersInfo(119, $value, [REF]$nullVar, 2)
}

function Set-ScreenTimeout {
    param (
        [int]$TimeoutInSeconds
    )

    # Define the registry paths for screen timeout settings
    $acKey = "HKCU:\Control Panel\Desktop"
    $dcKey = "HKCU:\Control Panel\PowerCfg"

    # Set the screen timeout for AC power (plugged in)
    Set-ItemProperty -Path $acKey -Name ScreenSaveTimeOut -Value $TimeoutInSeconds

    # Set the screen timeout for battery power
    Set-ItemProperty -Path $dcKey -Name ScreenSaveTimeOut -Value $TimeoutInSeconds

    # Confirm the settings have been applied (optional)
    Write-Output "Screen timeout settings have been applied to both AC and DC power:"
    Get-ItemProperty -Path $acKey -Name ScreenSaveTimeOut
    Get-ItemProperty -Path $dcKey -Name ScreenSaveTimeOut
}

# Function Call.
Set-ScreenSaverTimeout 
Set-OnResumeDisplayLogon
Set-ScreenTimeout -TimeoutInSeconds $TimeoutInSeconds
