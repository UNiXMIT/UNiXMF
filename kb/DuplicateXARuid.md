# The XA Resource Open String changes value to the value of an Open String in a different region
## Environment
Enterprise Developer   
Windows  
Linux/UNIX  

## Situation
When attempting to modify the open string of an XAR within a specific region, upon saving, it inadvertently alters the open string of another XAR located in a different region.   
Additionally, upon restarting MFDS, the open string of an XAR is altered to match the open string value of an XAR in a different region.  

## Resolution
This can be caused by duplicating regions in an incorrect way, causing a XAR in multiple regions to have the same UID.  
To resolve this issue, delete the affected XAR from each region and then re-add it, to ensure that every XAR obtains a unique ID.  

## Additional Information
More information about duplicating a region correctly can be found in the documentation:   
Deployment > Configuration and Administration > Enterprise Server configuration and administration > Enterprise Server Common Web Administration > Native > Directory Servers > Regions & Servers > Regions > To copy a region in ESCWA  

The Enterprise Developer Documentation and Resources are available here:  
https://www.microfocus.com/en-us/support/Micro%20Focus%20Enterprise%20Developer   