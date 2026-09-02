      $SET DIALECT(MF) CHARSET(ASCII) ASSIGN(EXTERNAL) FCDCAT
      $SET INDD(SYSIN 80 R) OUTDD(SYSOUT 121 R)
      *SET P64

       IDENTIFICATION DIVISION.

         *>
         *> -- See paragraph "Set-ECI-Parameters"
         *> -- to experiment in a 64 bit environment
         *>

       ENVIRONMENT DIVISION.
       WORKING-STORAGE SECTION.
       01  eci-entry-pptr              procedure-pointer.
       01  eci-Bad-PPtr                procedure-pointer.

       *> -- Commarea which will be passed to the 'WRITELOG' program.
       01  ws-dfhcommarea.
           03  eci-demo-message        pic x(80).
           03  eci-error-eibresp       pic s9(8) comp.
               88  eci-eibresp-normal          value 0.
           03  eci-error-eibresp2      pic s9(8) comp.

       01  ECI-Client-Type.
           *> -- Change the following value to select client type
           03                          pic x   comp-x  value 1.
               88  ECI-MicroFocus-88           value 1.
               88  ECI-UniCli-88               value 0.

           03  ECI-Module-Name         pic x(8).
               *> Micro Focus ECI
               88  ECI-MicroFocus-Module-88    value 'casbnccl'.
               *> IBM ECI
               88  ECI-UniCli-Module-88        value 'CCLAPI32'.

       01                              pic x   comp-x.
           88  ws-interface-initialised-88     value 1 false 0.

       01  ws-runtime-error            pic x(80).

       78  78-Prompt-Region                  value
               "Enter Target CICS ES region (default IMEX)".
       78  78-Prompt-User                  value
               "Enter UserID to be used     (default CICSUSER)".
       78  78-Prompt-Password                  value
               "Enter Password to be used   (default <none>)".
       78  78-Prompt-Msg                  value
               "Enter the message you want to send to the console".

       78  78-Prompt-Value                value
               "==> ".

       78  78-Application-Error-Text       value
               "The function under MF ES returned the
      -                "following return codes.".
       78  78-CICS-ExternalCall-Cmn        value 'CICSEXTERNALCALL'.

       01  eci-error-id-Z                  pic +++9.

           COPY "cicseci.cpy".

       PROCEDURE DIVISION.

           perform Initialise-ECI-Interface
           if ws-interface-initialised-88
               perform Set-ECI-parameters
               perform Call-ECI-Program
               perform ECI-Call-summary
               if eci-no-error
                   perform ECI-No-Error-para
               else
                   perform Display-ECI-Error
               end-if
           else
               perform ECI-Initialization-Error
           end-if

           stop run
           .

      *>================================================================

      *>--------------------------------------
       initialise-eci-interface.
      *>----------------------------------------------------------------
           set ws-interface-initialised-88 to false
           set eci-Bad-PPtr to entry '/MfBadMod.BaD'

           *> -- Set correct module name
           evaluate true
               when ECI-MICROFOCUS-88
                   set ECI-MicroFocus-Module-88 to true
               when ECI-UniCli-88
                   set ECI-UniCli-Module-88     to true
           end-evaluate

           *> -- Load the client library
           set eci-entry-pptr          to entry ECI-Module-Name

           if eci-entry-pptr not = eci-Bad-PPtr
               *> -- establish a procedure-pointer to the entry
               *> -- of the ECI request module
               set eci-entry-pptr to entry 78-CICS-ExternalCall-Cmn
               if eci-entry-pptr not = eci-Bad-PPtr
                   set ws-interface-initialised-88 to true
                   *> -- initialise the ECI interface block
                   move low-values     to eci-parms
                   set ECI-Version-1A  to true
                   *> -- set up the program name that
                   *> -- we will be LINK'ing to
                   move 'WRITELOG'     to eci-program-name
                   move length of ws-dfhcommarea
                                       to eci-commarea-length
                   set eci-commarea    to address of ws-dfhcommarea
               else
                   string 'Unable to address entry point '
                                               delimited by size
                          78-CICS-ExternalCall-Cmn
                                               delimited by size
                          ' in '               delimited by size
                          ECI-Module-Name      delimited by space
                          '.dll/.so'           delimited by size
                     into ws-runtime-error
                   end-string
               end-if
           else
               string 'Unable to load '    delimited by size
                      ECI-Module-Name      delimited by space
                      '.dll/.so'           delimited by size
                 into ws-runtime-error
               end-string
           end-if
           .

      *>-----------------------------
       Set-ECI-Parameters.
      *>----------------------------------------------------------------
           *> -- (1) ---------------------------------------------------
           *> -- When using ES_REGION or ES_ECI_SOCKET
           *> -- in ES Configuration information
           *> --    [ES-Environment]
      *    move low-values         to ECI-SYSTEM-NAME
           *> -- Results:
               *> Using using ES_REGION    :  Abend with RTS 119
               *> Using using ES_ECI_SOCKET:  OK


           *> -- (2) ---------------------------------------------------
           *> -- Without ES_REGION and ES_ECI_SOCKET
           *> -- in ES Configuration information
           *> --    [ES-Environment]
           move  'MTP64'            to ECI-SYSTEM-NAME
           *> move  'MTP32'            to ECI-SYSTEM-NAME		   
           *> -- Results:
               *> ECI error -22   (ECI-ERR-UNKNOWN-SERVER)


           *> -- (3) ---------------------------------------------------
           *> -- Without ES_REGION and ES_ECI_SOCKET
           *> -- in ES Configuration information
           *> --    [ES-Environment]
           *> -- Dynamic ES_ECI_SOCKET=
           *>--     !!! to be set to regionName:WebServicePort
      *    move low-values          to ECI-SYSTEM-NAME
      *    DISPLAY 'ES_ECI_SOCKET'  UPON ENVIRONMENT-NAME
      *    DISPLAY 'MTP64:9003'     UPON ENVIRONMENT-VALUE
           *> -- Results:
               *> OK

      *    *> ----------------------------------------------------------

           move "CICSUSER"          to eci-userid
           move spaces to  eci-password
           move function current-date  to eci-demo-message
           .

      *>--------------------------------------
       Call-ECI-Program.
      *>----------------------------------------------------------------
           *> -- Initialize EIBRESP/EIBRESP2
           initialize eci-error-eibresp eci-error-eibresp2

           *> -- set up the call type
           set eci-sync-call           to true
      *    set eci-sync                to true
           set eci-no-extend           to true
           move 0                      to ECI-TIMEOUT

           call eci-entry-pptr
               using   eci-parms
             returning eci-error-id
           end-call
           .
           *> -- Note:
           *>    ECI errors are return via the return-code
           *>    but CICS errors are returned in the eci-parms interface

      *>-----------------------------
       ECI-Call-summary.
      *>----------------------------------------------------------------
           display "ECI called using:"
           display "   Server   = [" ECI-SYSTEM-NAME "]"
           display "   User     = [" eci-userid      "]"
           display "   Password = [" eci-password    "]"

           display "ECI returns:"
           display "   ECI-ERROR-ID           =["
                   eci-error-id "]"
           display "   ECI-ABEND-CODE         =["
                   ECI-ABEND-CODE "]"
           display "   ECI-CONNECTION-TYPE    =["
                   ECI-CONNECTION-TYPE "]"
           display "   ECI-CICS-SERVER-STATUS =["
                   ECI-CICS-SERVER-STATUS "]"
           display "   ECI-CICS-CLIENT-STATUS =["
                   ECI-CICS-CLIENT-STATUS "]"
           display "   ECI-ERROR-EIBRESP      =["
                   eci-error-eibresp "]"
           display "   ECI-ERROR-EIBRESP2     =["
                   eci-error-eibresp2 "]"

           display " "
           .
      *>-----------------------------
       ECI-No-Error-para.
      *>----------------------------------------------------------------
           IF eci-eibresp-normal
               display "Message sent to the console."
           ELSE
               *> -- Application program error
               display 78-Application-Error-Text
               display "   EIBRESP  : " eci-error-eibresp
               display "   EIBRESP2 : " eci-error-eibresp2
           end-if
           .

      *>--------------------------------------
       display-eci-error.
      *>----------------------------------------------------------------
           display " "
           move eci-error-id       to eci-error-id-Z
           display "*** An ECI error has occured ***"
                   "RC=" eci-error-id-Z

           .

      *>-----------------------------
       ECI-Initialization-Error.
      *>----------------------------------------------------------------
           display '*** Error initialising ECI interface'
           display ws-runtime-error
           .
