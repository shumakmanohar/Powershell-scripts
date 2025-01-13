# Work In progess - This script is not yet complete

#Params For This Script File :
param (
    [int]$TimeoutInMinutes = 1 # Default 1 minutes
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
    Param ([Int32]$value = 1)  # Timeout in minutes
    
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
        [int]$TimeoutInMinutes
    )

    # Set the sleep timeout for AC power (plugged in)
    powercfg /change standby-timeout-ac $TimeoutInMinutes

    # Set the sleep timeout for battery power
    powercfg /change standby-timeout-dc $TimeoutInMinutes
}

# Function Call.
Set-ScreenSaverTimeout 
Set-OnResumeDisplayLogon
Set-ScreenTimeout -TimeoutInMinutes $TimeoutInMinutes
