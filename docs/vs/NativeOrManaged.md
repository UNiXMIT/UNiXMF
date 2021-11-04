# Native Or Managed Code

When you create a COBOL project in Visual Studio you would normally start with:   

```
'File' > 'New' > 'Project' > 'COBOL'   
```

You then have the option of 'Managed' or 'Native'.  

## Managed
 
Managed COBOL provides extensions to COBOL to support the .NET framework.   
It's compiled with the ilgen directive to run on .NET    

## Native
 
Native COBOL code is compiled to run on the Micro Focus runtime. So if you are bringing a standard Net Express application into Visual Studio, and want to recompile and run using the standard Micro Focus runtime, then you'd build it as Native.  

## Is the project Manged or Native?

To determine if a COBOL project is Native or Managed is to go to the Properties 
for the project.   
 
On the 'Application' tab if it shows a 'Target Framework' eg .NET Framework 4.6.1 
or .NET Framework 4.5.2 or something similar then it is a Managed .NET Framework 
project.  
 
But if the 'Application' page just shows 'Output Name'  'Output Type' etc then it 
is a Native (unmanaged) application and is being built for the Micro Focus runtime 
instead for the .NET Framework.  
