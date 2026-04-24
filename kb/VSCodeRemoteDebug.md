# Remote debug with VSCode
## Environment 
Visual COBOL   
Windows  
Linux/UNIX  

## Solution
### Debug on Server 1 (local) while binaries and .idy files are on Server 2 (remote).  

>NOTE: This guide assumes both Server 1 and Server 2 are running Windows. If the remote machine is Linux, adjust the commands and launch.json configuration as needed.

1. Start the debug service on Server 2:    
    ```
    SET COBANIMSRV=debug
    cobdebugremote port=nnnnn repeat
    ```

2. Start the debugger in VS Code on Server 1.  

3. Run the program on Server 2 (for example, via SSH).  

4. VS Code on Server 1 will attach automatically, loading the source and .idy files so you can step through and debug the program.     


### File locations
#### Server 1
Source Files, VS Code workspace and launch.json - C:\MFSamples
##### launch.json
```
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "cobol",
            "request": "launch",
            "name": "COBOL (native): Attach to process",
            "waitForAttachment": {
                "id": "debug" 
            },
            "pathMappings": [
                {
                    "local": "C:\\MFSamples",
                    "remote": "C:\\temp"
                }
            ],
            "remoteDebug": {
                "machine": "machine name or IP",
                "port": nnnnn
            },
            "stopOnEntry": true,
            "symbolSearchPaths": [
                "C:\\temp"
            ]
        }
    ]
}
```

##### Server 2
Binaries and .idy files - C:\temp

## Additional Information
More information can be found in the documentation:   
Home > COBOL Extension for Visual Studio Code > Debugging > Debug Launch Configurations (Native COBOL)  

The COBOL Extension for Visual Studio Code Documentation is available here:   
https://docs.rocketsoftware.com/bundle?labelkey=prod_visual_cobol&name_filter.value=Visual+Studio+Code