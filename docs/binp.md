# Data Explorer using BINP  

This feature was added in version 7.0 PU 3  

1. On the server, set 'MFES_BINPFH=true' in Region Configuration Information and start/restart the region.  

![1](images/binp-01.png)

2. On the client machine, set the environment variable 'DT_ENABLE_BINP=true'.  

![2](images/binp-02.png)

3. Open Micro Focus Data File Tools and navigate to File -> Data Explorer.  

![3](images/binp-03.png)

4. In the connection drop down list, select your remote server.  

![4](images/binp-04.png)

5. Expand the region you are working with and double click the dataset you want to open. Make sure 'Use Fileshare' is unchecked and click OK.  

![5](images/binp-05.png)

6. In the 'Open Data File' window, make sure 'Use temporary file for editing' is unchecked then click 'Open Shared'.  

![6](images/binp-06.png)

**NOTES:**  

When the environment variable has been set on the client, you will no longer be able to use Fileshare with Data Explorer. To enable the use of Fileshare again you need to remove the environment variable and restart Data File Tools.  

If you want to disable BINP on the client you have to delete the environment variable DT_ENABLE_BINP. It's not enough to set it to FALSE, It must be removed completely.

**Security:**  

Resources -> New Class  
Name: MFDFED  
Click resource -> New Resource  
Setup as desired for security.  
e.g.  
Name: **  
ACL: allow:* group:alter  
