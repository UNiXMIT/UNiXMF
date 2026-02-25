# Native vs. Managed Code

When creating a COBOL project in Visual Studio, start by navigating to:
```
File > New > Project > COBOL
```
You'll then be prompted to choose between Managed and Native.

## Managed
Managed COBOL extends the standard language to support the .NET Framework. It is compiled using the ILGEN compiler directive, which targets the .NET runtime.

## Native
Native COBOL compiles to run on the native COBOL runtime.   

## How to Tell Which Type a Project Is
Open the Properties panel for the project and go to the Application tab:

- Managed — A Target Framework is listed (e.g. .NET Framework 4.5.2 or .NET Framework 4.6.1).
- Native — No Target Framework is shown; the page only displays fields like Output Name and Output Type, indicating the project targets the native COBOL runtime rather than .NET.