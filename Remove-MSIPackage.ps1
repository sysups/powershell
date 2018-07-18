# First Searches for installed Java programms.
$installedpackages = get-wmiobject Win32_Product -Property * | Where-Object Name -Like "*java*" | Select-Object LocalPackage

# Then removes them using msiexec and the LocalPackagepath.
foreach ($path in $installedpackages) {
    msiexec.exe /x $path.LocalPackage /quiet
}