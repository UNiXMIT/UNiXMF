# Install a CCSID Translation Table

### Default CCSID directory
```
%ProgramFiles(x86)%\Micro Focus\Enterprise Developer\etc\ccsid
```

### CCSID Download
[http://download.boulder.ibm.com/ibmdl/pub/software/dw/java/cdctables.zip](http://download.boulder.ibm.com/ibmdl/pub/software/dw/java/cdctables.zip)

### Instructions
1. Use the tabindex.txt file (located in the intro.zip file of the extracted package) to identify the package number and filename for each CCSID translation table you need to install.
2. Within the ccsid directory, create a sub-directory for each table you want to install, using the name of the CCSID translation table filename, specified in the tabindex.txt file, as the directory name.
3. For each CCSID that you want to install, open its corresponding Package.zip file (as specified in tabindex.txt) and extract the files from the appropriate CCSID .zip file to the corresponding directory you created in the previous step.
4. Set the MFCODESET environment variable to the required code set for translation.

### Example
To install a CCSID translation table to convert Spanish to USA English, create a sub-directory under ccsid named 011C01B5, and then extract the contents of package4.zip\011C01B5.zip to the 011C01B5 sub-directory.  