# casdup
```
casdup /icasauxta.rec /fcasauxta.rec /w /d
```
### Optional Parameters
```
      /a               Use the A dataset (default)  
      /b               Use the B dataset  
      /c               Compress minimum api entries  
      /d               Display module IDs  
      /f{file-name}    Output list file name  
      /n               No page headers  
      /i{file-name}    Input trace/dump file name  
       (input trace/dump file defaults to region)  
       (overrides /a, /b, /r, /x, and "aux" )  
      /l               List summary info only  
      /m{xx,yy,zz}     Module ID's included  
      /p{nn,nnn,nnnn}  Process ID's included  
       (/m and /p screen trace entry output)  
      /r{es-name}      ES server name  
      /s{nnnnnn}       Split output  
       (trace output is split after nnnnnn lines)  
       (dump output is always complete dumps)  
      /w               Wide trace format  
      /x               Use the X dataset  
       (for external dumps produced by dfhgtrtd /d)  
      /0               Module/transaction trace  
      /1               0 level trace plus API  
      /2               0 & 1 plus RTS & EXTFH trace  
      /3               All formatted trace  
      /4               All trace (default)  
      aux              Format auxiliary trace  
      /e               Exclude user data mode  
      /h               Display usage  
```