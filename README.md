# TemplateBlender
Packaged on: 11/02/2022

Last Edited: 11/02/2022

Last Editor: Richard

### REALEASENOTES:
v1.0 Initial commit

# Required Intune Information
### Intune Installation String
powershell.exe -ExecutionPolicy Bypass -File ".\Install-Blender.ps1"

### Intune Uninstallation String
powershell.exe -ExecutionPolicy Bypass -File ".\Uninstall-Blender.ps1"

### Manual Detection Rule
#### Rule Type: File
Path: 

C:\Program Files\Blender Foundation\Blender 2.83

File: 

blender.exe.exe

Detection Method: String (version)

Operator: Greater than or equal to

Value: 

2.8.3.0

### Restart Behavior
No Specific Action

### Return Codes
0 Normal Installation

-1 Generic error during installation

-5 Pending reboot, cannot complete installation

-6 Issue creating system environment variable

# Additional Information
### Silent Install String
/i blender.msi ALLUSERS=1 /qn

### Silent Uninstall Flags
/x blender.msi /qn
