# VASM ESM Configuration

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
required=alphabetic, mixed-case, numeric, punctuation
complexity=2

[Trace]
Config=yes
Groups=y
Modify=fail|all|y|yes 
Update=y|yes|changes|all 
Vsam=yes

[VSAM timeout]
retry count=30
wait length=1000
max wait=0
```