# MS Build Tools Offline Installation

1. Download MS Build Tools installer - https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=BuildTools  

2. Download layout files for offline installation:
    - Possible workloads are specified here - https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools.
    - The following example contains workloads for msbuild and C++ build tools (exe file will have some version numbers in name):
    ```
    vs_BuildTools.exe --layout C:\BToffline --add Microsoft.VisualStudio.Workload.MSBuildTools --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.WebBuildTools --add Microsoft.VisualStudio.Workload.NetCoreBuildTools --lang en-US  
    ```

3. Copy C:\BToffline to the machine on which you want to install it.

4. Open mmc and import all certificates from C:\BToffline\certificates to "Trusted Root Certification Authorities" of computer (not current user)  

5. Run the Build Tools installer in offline mode and follow the instructions:
    ```
    C:\BToffline\vs_buildtools.exe --noweb  
    ```