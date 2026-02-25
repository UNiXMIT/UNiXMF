# EXE/DLL Properties and Resource Files
## Environment
Enterprise Developer  
Visual COBOL   
Windows  

## Situation
How can a resources .rc file be created and added to a Visual Studio COBOL project to populate the Details tab of an .EXE or .DLL file's Properties?  
Specifically, this would allow specification of values such as Copyright, Product Name, Product Version, and File Description.  

## Resolution
First, add a Resources .rc file to the project in Microsoft Visual Studio.  
In Solution Explorer, right-click the project and select Add > New Item > General > Resource File.  
A new resource file (for example, Resource1.rc) will be added to the project.  
Open this file and edit its contents, adding the following entries and modifying them as needed for your application:
```
1 VERSIONINFO
FILEVERSION 1,0,0,1
PRODUCTVERSION 1,0,0,1
FILEFLAGSMASK 0x3F
FILEFLAGS 0x0
FILEOS 0x40004
FILETYPE 0x1
FILESUBTYPE 0x0
BEGIN
    BLOCK "StringFileInfo"
    BEGIN
        BLOCK "040904E4"
        BEGIN
            VALUE "CompanyName", "Rocket Software"
            VALUE "FileDescription", "EXE/DLL File Info"
            VALUE "FileVersion", "1.0.0.1"
            VALUE "OriginalFilename", "EXEDLLfileinfo.exe"
            VALUE "ProductName", "Test Program"
            VALUE "ProductVersion", "1.0.0.1"
            VALUE "LegalCopyright", "(C) Copyright Rocket Software"
        END
    END
    BLOCK "VarFileInfo"
    BEGIN
        VALUE "Translation", 0x0409, 1252
    END
END
```
When the project is built in Microsoft Visual Studio, the .rc file is processed by the Windows resource compiler (rc.exe).  

During the build process:  
1. The .rc file is compiled into a binary resource file (.res).
2. The linker then embeds that compiled resource into the resulting .exe or .dll.

3. The embedded VERSIONINFO resource is what Windows reads to populate the Details tab in the file's Properties dialog.

In other words, the information defined in the VERSIONINFO block—such as Product Name, File Description, File Version, Product Version, and Copyright—is compiled and permanently embedded into the assembly at build time.  

After the build completes, Windows Explorer retrieves this version resource directly from the executable or DLL, which is why the specified values appear in the file's Properties > Details tab.  