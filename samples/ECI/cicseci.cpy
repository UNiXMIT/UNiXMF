      *
      * Module Name        CICSECI.CBL
      *
      * Descriptive Name   CICS External Call Interface
      *
      *                                       
      * Licensed Materials - Property of IBM
      *
      * "Restricted Materials of IBM"
      *
      * 5724-I81 5725-B65
      *
      * (c) Copyright IBM Corp. 1994, 2010 All Rights Reserved.
      *
      * US Government Users Restricted Rights - Use, duplication or
      * disclosure restricted by GSA ADP Schedule Contract with
      * IBM Corp.
      *
      * Status: Version 8 Release 0
      *                                     
      * Notes :-
      *
      * This copybook is provided with the CICS Transaction Gateway.
      *


      *
      * Parameter block for ECI
      *
      * Note, the ECI-SYS-RETURN-CODE field has been replaced by the
      * RESERVED1 field. To recompile existing applications the RESERVED1
      * field can be replaced by the following declaration:
      *    05 ECI-SYS-RETURN-CODE                 PIC S9(4) COMP-5.
      * No information will be returned in this field. All error
      * information is now written to the client log file.

       01 ECI-PARMS.
           05 ECI-CALL-TYPE                       PIC S9(4) COMP-5.
                   88 ECI-SYNC-CALL                 VALUE 0.
                   88 ECI-ASYNC-CALL                VALUE 1.
                   88 ECI-SYNC-PARALLEL             VALUE 2.
                   88 ECI-ASYNC-PARALLEL            VALUE 3.
                   88 ECI-SYNC                      VALUE 516.
                   88 ECI-ASYNC                     VALUE 517.
                   88 ECI-ASYNC-NOTIFY-MSG          VALUE 518.
                   88 ECI-ASYNC-NOTIFY-SEM          VALUE 519.
                   88 ECI-GET-REPLY                 VALUE 520.
                   88 ECI-GET-REPLY-WAIT            VALUE 521.
                   88 ECI-STATE-SYNC                VALUE 522.
                   88 ECI-STATE-ASYNC               VALUE 523.
                   88 ECI-STATE-ASYNC-SEM           VALUE 524.
                   88 ECI-STATE-ASYNC-MSG           VALUE 525.
                   88 ECI-GET-SPECIFIC-REPLY        VALUE 528.
                   88 ECI-GET-SPECIFIC-REPLY-WAIT   VALUE 529.
           05 ECI-PROGRAM-NAME                    PIC X(8).
           05 ECI-USERID                          PIC X(8).
           05 ECI-PASSWORD                        PIC X(8).
           05 ECI-TRANSID                         PIC X(4).
           05 ECI-ABEND-CODE                      PIC X(4).
           05 ECI-COMMAREA                        POINTER.
           05 ECI-COMMAREA-LENGTH                 PIC S9(4) COMP-5.
           05 ECI-TIMEOUT                         PIC S9(4) COMP-5.
           05 ECI-RESERVED1                       PIC S9(4) COMP-5.
           05 ECI-EXTEND-MODE                     PIC S9(4) COMP-5.
                   88 ECI-NO-EXTEND                 VALUE 0.
                   88 ECI-EXTENDED                  VALUE 1.
                   88 ECI-CANCEL                    VALUE 2.
                   88 ECI-COMMIT                    VALUE 2.
                   88 ECI-BACKOUT                   VALUE 3.
                   88 ECI-STATE-IMMEDIATE           VALUE 4.
                   88 ECI-STATE-CHANGED             VALUE 5.
                   88 ECI-STATE-CANCEL              VALUE 6.
           05 ECI-WINDOW-HANDLE                   PIC S9(8) COMP-5.
           05 ECI-SEM-HANDLE REDEFINES ECI-WINDOW-HANDLE
                                                  PIC S9(8) COMP-5.
           05 FILLER         REDEFINES ECI-WINDOW-HANDLE.
               10 ECI-MS-WINDOW-HANDLE            PIC S9(4) COMP-5.
               10 ECI-MS-INSTANCE-HANDLE          PIC S9(4) COMP-5.
           05 ECI-MESSAGE-ID                      PIC  9(4) COMP-5.
           05 ECI-MESSAGE-QUALIFIER               PIC S9(4) COMP-5.
           05 ECI-LUW-TOKEN                       PIC S9(8) COMP-5.
                   88 ECI-LUW-NEW                   VALUE 0.
           05 ECI-SYSID                           PIC X(4).
           05 ECI-VERSION                         PIC S9(4) COMP-5.
                   88 ECI-VERSION-1A                VALUE 2.
                   88 ECI-VERSION-MAX               VALUE 2.
           05 ECI-SYSTEM-NAME                     PIC X(8).
           05 ECI-CALLBACK                        POINTER.
           05 ECI-USERID2                         PIC X(16).
           05 ECI-PASSWORD2                       PIC X(16).
           05 ECI-TPN                             PIC X(4).

      *
      * List of error returns from CICSEXTERNALCALL
      *

       01 ECI-ERROR-ID                            PIC S9(4) COMP-5.
           88 ECI-NO-ERROR                          VALUE  0.
           88 ECI-ERR-INVALID-DATA-LENGTH           VALUE -1.
           88 ECI-ERR-INVALID-EXTEND-MODE           VALUE -2.
           88 ECI-ERR-NO-CICS                       VALUE -3.
           88 ECI-ERR-CICS-DIED                     VALUE -4.
           88 ECI-ERR-REQUEST-TIMEOUT               VALUE -5.
           88 ECI-ERR-NO-REPLY                      VALUE -5.
           88 ECI-ERR-RESPONSE-TIMEOUT              VALUE -6.
           88 ECI-ERR-TRANSACTION-ABEND             VALUE -7.
           88 ECI-ERR-EXEC-NOT-RESIDENT             VALUE -8.
           88 ECI-ERR-LUW-TOKEN                     VALUE -8.
           88 ECI-ERR-SYSTEM-ERROR                  VALUE -9.
           88 ECI-ERR-NULL-WIN-HANDLE               VALUE -10.
           88 ECI-ERR-NULL-MESSAGE-ID               VALUE -12.
           88 ECI-ERR-THREAD-CREATE-ERROR           VALUE -13.
           88 ECI-ERR-INVALID-CALL-TYPE             VALUE -14.
           88 ECI-ERR-ALREADY-ACTIVE                VALUE -15.
           88 ECI-ERR-RESOURCE-SHORTAGE             VALUE -16.
           88 ECI-ERR-NO-SESSIONS                   VALUE -17.
           88 ECI-ERR-NULL-SEM-HANDLE               VALUE -18.
           88 ECI-ERR-INVALID-DATA-AREA             VALUE -19.
           88 ECI-ERR-INVALID-VERSION               VALUE -21.
           88 ECI-ERR-UNKNOWN-SERVER                VALUE -22.
           88 ECI-ERR-CALL-FROM-CALLBACK            VALUE -23.
           88 ECI-ERR-INVALID-TRANSID               VALUE -24.
           88 ECI-ERR-MORE-SYSTEMS                  VALUE -25.
           88 ECI-ERR-NO-SYSTEMS                    VALUE -26.
           88 ECI-ERR-SECURITY-ERROR                VALUE -27.
           88 ECI-ERR-MAX-SYSTEMS                   VALUE -28.
           88 ECI-ERR-MAX-SESSIONS                  VALUE -29.
           88 ECI-ERR-ROLLEDBACK                    VALUE -30.

      *
      * Commarea layout for ECI-STATE-xxx CallType requests other than
      * when the  ExtendMode is ECI-STATE-CANCEL.
      *
      * It should be supplied with valid values for a request where the
      * ExtendMode is ECI-STATE-CHANGED.  In this case a response will be
      * returned only when the status is different to that which was supplied.
      *
      * It will be returned with the current status in these fields except
      * where  the ExtendMode is ECI-STATE-CANCEL.
      *

       01 ECI-STATUS.
           05 ECI-CONNECTION-TYPE                 PIC S9(4) COMP-5.
                   88 ECI-CONNECTED-NOWHERE         VALUE 0.
                   88 ECI-CONNECTED-TO-SERVER       VALUE 1.
                   88 ECI-CONNECTED-TO-CLIENT       VALUE 2.
           05 ECI-CICS-SERVER-STATUS              PIC S9(4) COMP-5.
                   88 ECI-SERVERSTATE-UNKNOWN       VALUE 0.
                   88 ECI-SERVERSTATE-UP            VALUE 1.
                   88 ECI-SERVERSTATE-DOWN          VALUE 2.
           05 ECI-CICS-CLIENT-STATUS              PIC S9(4) COMP-5.
                   88 ECI-CLIENTSTATE-UNKNOWN       VALUE 0.
                   88 ECI-CLIENTSTATE-UP            VALUE 1.
                   88 ECI-CLIENTSTATE-INAPPLICABLE  VALUE 2.
           05 FILLER                              PIC S9(4) COMP-5.
           05 FILLER                              PIC S9(4) COMP-5.

      *
      *  CICSECILISTSYSTEMS.
      *
      *  Note: The value '16' assigned to CICS-ECINUMSYS and the matching
      *        value in the OCCURS clause for CICS-ECISYSTEM may need
      *        be be increased if the ECI-ERR-MORE-SYSTEMS error occurs.
      *

       77 CICS-ECI-SYSTEM-MAX           PIC 9(4) COMP-5 VALUE 8.
       77 CICS-ECI-DESCRIPTION-MAX      PIC 9(4) COMP-5 VALUE 60.

       77 CICS-ECINUMSYS                PIC 9(4) COMP-5 VALUE 16.

       01 CICS-ECISYSTEM.
           02 FILLER
           OCCURS 0 TO 16 TIMES DEPENDING ON CICS-ECINUMSYS.
               05 SYSTEMNAME            PIC X(8).
               05 FILLER                PIC X.
               05 SYSTEMDESC            PIC X(60).
               05 FILLER                PIC X.

