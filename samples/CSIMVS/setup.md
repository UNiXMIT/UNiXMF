# CSIMVS.MICROFOCUS.COM Setup
## Connection Type
Eclipse - Micro Focus z/OS    

## Ports
V3 6000  
V4 6050  
V5 6100  
V6 6150  
V7 6160  
V8 6170  
V9 6180  
v10 6190  

## Datasets
### Names
MFIMTR.EXAMPLE.COBOL  
MFIMTR.EXAMPLE.COPYLIB  
MFIMTR.EXAMPLE.PROCLIB  
MFIMTR.EXAMPLE.JCL  

### Dataset Attributes 
Space Unit: CYL  
Primary Quantity: 3  
Secondary Quantity: 1  
Directory Blocks: 20  
Record Format: FB  
Record Length: 80  
Dataset Type: Library  

## Jobs to Submit 
ALLOCU.jcl  
COBCOMP.jcl
RUNJOB.jcl