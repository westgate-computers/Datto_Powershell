####################### OpenJDK11_Install ###########################
# Description: Install or update OpenJDK 11.0.21                    #

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 12/07/2023 - Created Script                                       #

#####################################################################

function Datto_Output {
    <#
        .SYNOPSIS
            Wrapper function to output data into Datto
        .EXAMPLE
            Datto_Output("The software was installed")
    #>
    
    param (
        # The text you want to output into Datto
        $message
    )
    # General Variables for Datto: 
    $StartResult = Write-Host "<-Start Result->" 6>&1
    $EndResult = Write-Host "<-End Result->" 6>&1
    
    $StartResult
    Write-Host "$message"
    $EndResult
}

# Env Variable changes: 
$ErrorView = 'NormalView';
$ErrorActionPreference = 'Stop';

# Get copy of OpenJDK 11: 
Invoke-WebRequest "https://api.adoptopenjdk.net/v3/installer/latest/11/ga/windows/x64/jdk/hotspot/normal/adoptopenjdk?project=jdk" -OutFile "C:\Temp\openjdk11.msi";

# Install OpenJDK 11: 
Start-Process -Wait -FilePath msiexec -ArgumentList /i, "C:\Temp\openjdk11.msi", "ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome", 'INSTALLDIR="C:\Program Files\Java"', /quiet -Verb RunAs;

# as of 12/1/2023, this installs OpenJDK 11.0.21
$javaVersion = & "C:\Program Files\Java\bin\java.exe --version";

Datto_Output($javaVersion);