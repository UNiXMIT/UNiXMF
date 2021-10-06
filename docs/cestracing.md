# SafeNet License Information

## Tracing

You can trace the MF licesing daemon's interaction with the applications and the SafeNet server.  
The tracing is enabled by adding the following line:  

```
daemontracelevel=7
```

to the licensing configuration file ces.ini on the client machine (the machine requesting a license).  

This file is stored in:

```
Windows:    C:\ProgramData\MicroFocus

UNIX:       /var/microfocuslicensing/bin
```

Make sure you have a carriage return at the end of the new line.  

You must restart the MF licensing daemon to force it to re-read the configuration file.  

The trace is written to a file called mfcesd.log stored in:

```
Windows:    C:\ProgramData\MicroFocus

UNIX:       /var/microfocuslicensing/logs
``` 

To turn tracing off, remove the line from the ces.ini and restart the daemon.

If you leave the trace gonig it will rename the file every 10Mb to mfcesd.log00, mfcesd.log01 etc.

## Logs

The Safenet server also logs some activity (always on).

This is lserv.log (lserv.log00 etc) in the same folders as mfcesd.log.

The system will maintain 99 separate log files before logging stops, so users need to archive/delete as appropriate.

The log file has a specific format, as defined by SafeNet, and is easily read and understood using the information below.

The license server generates a usage log file with the following format:

| Element      | Description                                                                                                             |
|--------------|-------------------------------------------------------------------------------------------------------------------------|
| Server-LFE   | No relevance to our   implementation                                                                                    |
|  License-LFE | No relevance to our   implementation                                                                                    |
|  Date        | The date the entry was made, in   the format: Day-of-week Month Day Time (hh:mm:ss) Year                                |
|  Time-stamp  |  The time stamp of the   entry.                                                                                         |
|  Feature     |  Name of the feature.                                                                                                   |
|  Ver         |  Version of the feature.                                                                                                |
|  Trans       |  The transaction type. 0   indicates an issue, 1 a denial, and 2 a release.                                             |
|              | 0 Issue                                                                                                                 |
|              | 1 Denied                                                                                                                |
|              | 2 Expired                                                                                                               |
|              | 3 Queue                                                                                                                 |
|              | 4 QueueDenialLog                                                                                                        |
|              | 5 EngageLog                                                                                                             |
|              | 6 ConvertLog                                                                                                            |
|              | 7 QueueExpiredLog                                                                                                       |
|              | 8 CommuterCheckOut                                                                                                      |
|              | 9 CommuterCheckIn                                                                                                       |
|  Numkeys     |  The number of licenses in   use after the current request/release. (Encrypted if encryption level is set   to 3 or 4.) |
|  Keylife     |  How long, in seconds, the   license was issued. Only applicable after a license release.                               |
|  User        |  The user name of the   application associated with the entry.                                                          |
|  Host        |  The host name of the   application associated with the entry.                                                          |
|  LSver       |  The version of the   Sentinel RMS Development Kit license server.                                                      |
|  Currency    |  The number of licenses   handled during the transaction. (Encrypted if encryption level is set to 3 or   4.)           |
|  Comment     |  The text passed in by the   licensed application                                                                       |