# ADLDS ESM Configuration

Name: VSAM  
Module: vsam_esm   

```
[Operations]
signon attempts=3

[Password]
expiration=90
history=0
minimum length=6
maximum length=64
required=alphabetic, mixed-case, numeric, puncutation
complexity=2

[Trace]
Config=y
Groups=y
Modify=y
Update=y
Vsam=yes

[VSAM timeout]
retry count=30
wait length=1000
max wait=0
```