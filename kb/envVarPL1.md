# Environment variables are not available for C programs called from the PL/1 program
## Environment
Enterprise Developer  
Visual COBOL  
Windows  

## Situation

An environment variable is set before any programs are called. That environment variable is then changed in a C# program early in the call stack. That C# program executes a PL/1 program that correctly sees the modified environment variable. When the PL/1 program calls a C++ program, that program sees the original value of the environment variable and not the updated value.  

## Resolution
This is a bug with Microsoft’s getenv() C library function. Microsoft’s GetEnvironmentVariableA() function does not encounter the same issue and should be used instead of getenv().  