# CBL_GET_PROGRAM_INFO Parameter Block Size Issue with JVM COBOL
## Environment
Enterprise Developer  
Visual COBOL  
Windows  
Linux / UNIX  

## Situation
The function CBL_GET_PROGRAM_INFO, to get the program name, does not work when using JVM COBOL. The parameter block is set to:  

```
01 cblt-prog-info-params.
    03 cblte-gpi-size       pic x(4) comp-5 value 20.
    03 cblte-gpi-flags      pic x(4) comp-5 value 1.
    03 cblte-gpi-handle     usage pointer.
    03 cblte-gpi-prog-id    usage pointer.
    03 cblte-gpi-attrs      pic x(4) comp-5.
```

Can this function work with JVM COBOL or is there an alternative function that can be used?  

## Resolution
Usually the parameter block is set to a value of 20 on 32-bit systems, or 28 on 64-bit systems. When compiling to JVM the pointers are 8 bytes, so the parameter block is not 20 bytes.
This can be solved, regardless of the pointer size, by adding the following line before calling the function:  

```
Move length of cblt-prog-info-params to cblte-gpi-size
```

This line dynamically sets the parameter block size to the correct length, ensuring compatibility with JVM COBOL.  