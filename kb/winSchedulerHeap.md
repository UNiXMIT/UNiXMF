# RTS 105 When Running COBOL Program via Windows Task Scheduler
## Environment
Visual COBOL  
COBOL Server  
Windows  

## Symptoms
A COBOL program launched via a Windows Task Scheduler task exits immediately with an RTS 105 error — without executing the program — after having run successfully earlier in the day. The same COBOL program, executed manually from a Windows console on the same machine, runs without error. Rebooting the machine temporarily resolves the issue.  

RTS 105: *The run-time system is unable to allocate sufficient memory space to successfully carry out the tried operation.*  

## Resolution
Windows Task Scheduler executes tasks in a non-interactive session. Non-interactive Windows sessions have a significantly smaller desktop heap than interactive (console) sessions. The default desktop heap for non-interactive sessions is 768 KB, compared to 20480 KB for interactive sessions (By default, based on Windows 11 64 bit).  

When the program is invoked repeatedly throughout the day, the non-interactive desktop heap becomes exhausted. At that point, the runtime cannot allocate the memory required to initialize, and exits with RTS 105. Interactive console sessions draw from a separate heap and are therefore unaffected.  

Increase the desktop heap size for non-interactive sessions by modifying the following registry value:  

**Key:** `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\SubSystems`    
**Value:** `Windows` (REG_EXPAND_SZ)  

Within that value, locate the `SharedSection` parameter. It takes the form:  

```
SharedSection=aaaa,bbbb,cccc
```

where:
- `aaaa` — system-wide heap size (KB)  
- `bbbb` — desktop heap for each interactive desktop (KB)  
- `cccc` — desktop heap for each non-interactive desktop (KB)  

Increase the third value (`cccc`) to reduce the likelihood of exhaustion. A common starting point is `1024` (1 MB) or higher, depending on the number of concurrent scheduled tasks. A reboot is required for the change to take effect.  

> **Note:** 
> - Alternatively, the task can be configured to run in an interactive session, though this is generally not recommended for production environments.  
> - Don't set a value that is over 20480 KB for the second SharedSection value.  
> - The physical RAM on the computer doesn't affect the desktop heap size. You can't improve the performance by adding physical RAM.  

## Additional Information
Microsoft documentation on the desktop heap limitation:  
https://learn.microsoft.com/en-us/troubleshoot/windows-server/performance/desktop-heap-limitation-out-of-memory  
