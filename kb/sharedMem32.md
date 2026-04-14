# Understanding Shared Memory Limits in 32-Bit Regions
## Environment
Enterprise Server   
Windows  
Linux/UNIX  

## Situation
What is the maximum value for Shared Memory Pages for a 32-bit region?  
When the value is set very high value like 50000 with 200 SEPs, the region appears to start OK, but it cannot be contacted by ESCWA etc.  
With a 64-bit region, there is no issue.  

## Resolution
Due to limitations of the 32-bit region, the shared memory segment may be too large for the address range available in the process.  

A maximum value for Shared Memory Pages in a 32-bit region cannot be universally recommended, as the limit varies across systems, even those with similar configurations. Factors such as the operating system, third-party DLLs, and other environmental conditions can all affect the maximum usable value.  

Determining an optimal setting requires knowledge of the specific system and setup. Identifying the most effective value typically involves some trial and error to achieve the best balance for the environment.  

The calculation provided on the 'Shared Memory Area' page of the documentation can assist in estimating the number of shared memory pages required. If this estimate exceeds the capacity of a 32-bit region, a 64-bit region should be used instead.  

## Additional Information
More information can be found in the documentation:   
Home > Enterprise Server 11.0 for Windows > Rocket® Enterprise Server 11.0 for Windows > Enterprise Server > Enterprise Server configuration and administration > Planning your Configuration > Enterprise Server Instance Configuration Issues > Shared Memory Area  

The Enterprise Server Documentation and Resources are available here:  
https://docs.rocketsoftware.com/bundle?labelkey=prod_enterprise_server  