# ESCWA is unable to display Arabic characters when displaying VSAM files in the catalog
## Environment
Enterprise Developer  
Windows  

## Situation
When trying to display Arabic data in EBCIDIC within a VSAM file, the catalog in ESCWA does not display them properly and displays garbage instead.  
The data is displayed properly if viewing the VSAM data files in the Data File Editor instead.  
Setting MFCODESET=0420, for Arabic support, has no effect.  

## Resolution
To be able to view Arabic data properly in the catalog in ESCWA, the MFACCCGI_CHARSET config variable has to be set and the IBM-1256 CCSID tables need to be installed.  

1. In the regions configuration section, set the following config variable:  

```
MFACCCGI_CHARSET=windows-1256
```

2. Install the IBM-1256 CCSID translation table. The download of the full package of IBM CCSID translation tables and instructions on how to install the CCSID translation table, can be found in the documentation in the ‘To install a CCSID translation table’ section.  