# Config variables from one region are impacting the other regions
## Environment
Enterprise Developer  
Windows  
Linux / UNIX  

## Situation
When two regions are started successively, the second region uses all the configuration variables of the first region. Any dumps taken from the second region are dumps of the first region. If the first region is stopped, the second region now works okay, having all its own configuration variables set. Both regions need to run at the same time, though, and have their own separate configuration variables.  

## Resolution
Ensure that none of the listeners in each region are duplicated. For example, verify that the 'Web Services and J2EE' listener in Region 1 does not utilize the same port as the 'Web Services and J2EE' listener in Region 2.  