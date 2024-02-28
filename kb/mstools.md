# Install Error '0x8007000a - The environment is incorrect' at MS Tools download/install stage
## Environment
Visual COBOL  
Enterprise Developer  
Windows  

## Situation
The Visual COBOL / Enterprise Developer install can fail, at the Microsoft Build Tools and SDK download/install stage, with error '0x8007000a - The environment is incorrect'.  
When checking the install logs, it shows that 'cblms.exe' fails with error 0x8007000a.  

## Resolution
After the failed installation, 'cblms.exe' can be used to check if the MS Build Tools and SDK are found by the MF product (Refer to the documentation page 'The Microsoft Build Tools and Windows SDK Configuration Utility').  

Check the output from the commands 'cblms -Q' and 'cblms -L'  

If the MS Tools are installed and found, then it will show something like this:  

```
cblms -Q

Windows SDK
location = c:\Program Files (x86)\Windows Kits\10
version = 10.0.18362.0

Microsoft Build Tools
location = c:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise
version = 14.27.29110
cblms -L

Windows SDK
Id  Version       Location
0] 10.0.14393.0  c:\Program Files (x86)\Windows Kits\10
1] 10.0.15063.0  c:\Program Files (x86)\Windows Kits\10
2] 10.0.16299.0  c:\Program Files (x86)\Windows Kits\10
3] 10.0.17134.0  c:\Program Files (x86)\Windows Kits\10
4] 10.0.17763.0  c:\Program Files (x86)\Windows Kits\10


Microsoft Build Tools
Id  Version       Location
0] 14.16.27023 c:\Program Files (x86)\Microsoft Visual Studio\2017\Professional
```

If the MS Tools are NOT installed or found, then the output will look like this:

```
cblms -Q

Windows SDK
Failed: information could not be found

Microsoft Build Tools
Failed: information could not be found
cblms -L

Windows SDK
Id  Version       Location

Microsoft Build Tools
Id  Version       Location
```

MS Tools are required to perform various actions and operations within the COBOL development environment. More information on this can be found here (Refer to the documentation page 'Microsoft Package Dependencies')  
If you do not use any of the features described in the documentation page mentioned above, the install parameter (skipmstools=1) can be used that will skip the download and installation of these dependencies.  

Some reasons that the MS Tools can fail to install are:  

- The client machine has no internet access to download the MS Tools. 
- The MS Build Tools and SDK are already installed on the machine but not in the default location so that cblms.exe cannot find them. 
- An incompatibility with the MS Tools and the client machine. 


### Offline Installation
An internet connection is required so that the installer can download and install the MS Tools.  
Instructions on how to perform an offline installation can be found in the documentation:  

Visual COBOL for Visual Studio - Section 'Installing Visual COBOL in an Offline Environment'   

Visual COBOL for Eclipse - Section 'Visual COBOL Installation Options'  

Enterprise Developer for Visual Studio - Section 'Installing Enterprise Developer in an Offline Environment'  

Enterprise Developer for Eclipse - Section 'Enterprise Developer Installation Options'  

### MS Tools installed in a non-default location
If the MS Build Tools and SDK are already installed but in a non-default location, the command 'cblms -UB:xxx -US:xxx' can be used tell the MF product where these tools are located.  

For example:  

```
cblms -UB:”C:\Program Files (x86)\Micro Focus\Enterprise Developer\Microsoft” -US:"C:\Program Files (x86)\Windows Kits\10"
```

cblms -Q should now show the MS Tools correctly.  

### MS Tools Incompatibility

There could be an unknown reason why the MS Tools cannot be installed on the client machine. In this case the installer for Visual COBOL / Enterprise Developer can be told to skip the installation of MS Tools using the 'skipmstools=1' option (Refer to the documentation page 'Managing the Microsoft Build Tools and Windows SDK Packages')  

For example:  

```
vcvs2019_60.exe skipmstools=1 
```

After the MF product has installed correctly, the MS Tools can be installed separately using the installers directly from Microsoft. Microsoft installers might provide more information why the tools cannot be installed successfully - https://developer.microsoft.com/en-us/windows/downloads/  

The 'cblms -UB:xxx -US:xxx' command can then be used to tell the MF product where these tools have been installed.  

For example:  

```
cblms -UB:”C:\Program Files (x86)\Micro Focus\Enterprise Developer\Microsoft” -US:"C:\Program Files (x86)\Windows Kits\10"
```

cblms -Q should now show the MS Tools correctly.