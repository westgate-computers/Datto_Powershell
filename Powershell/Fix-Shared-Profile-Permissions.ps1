<#
Script to reset user folder permissions.
Uses: icacls.exe and takeown.exe
Tested on Server 2008 R2 X64

For all folders in base folder:
1. Recursively resets owner to Administrators
2. Reset folder to inherit permissions and apply to subfolders/files, clearing any existing perms
3. Add user (based on folder name) with full control and apply to subfolders/files
4. Recursivley reset owener to user (based on folder name)
#>

$mainDir = "D:\Users\"
write-output $mainDir
$dirs = gci "$mainDir" |? {$_.psiscontainer}
foreach ($dir in $dirs){
write-output $dir.fullname
takeown.exe /F $($dir.fullname) /R /D Y |out-null
icacls.exe $($dir.fullname) /reset /T /C /L /Q
icacls.exe $($dir.fullname) /grant ($($dir.basename) + ':(OI)(CI)F') /C /L /Q
icacls.exe $($dir.fullname) /setowner $($dir.basename) /T /C /L /Q
}