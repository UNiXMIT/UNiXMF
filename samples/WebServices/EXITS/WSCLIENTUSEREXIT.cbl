.     $SET REMOVE"JSON"
      * === Update history =============================================
      * --> Version 0 ...
      * --> Version 1 update 25/01/2017
      *       LOG only is WSLOG environment variable is set
      *       Add REST JSON WS handling
      *                "How to" example using MF "IBM zOS JSON parsing"
      * --> Version 2 update 11/12/2018
      *       handle exit-http-resp-headers WS exit ( get HTTP headers )
      * ================================================================

      $SET CONSTANT DEBUG_SOAPorJSON_HTTP(1)                             *> IF DEBUG_SOAPorJSON_HTTP     defined, you'll get more traces
                                                                         *>     SOAP-ENVELOP Get & SET written to a LOG file

      $SET CONSTANT noDEBUG_DISPLAY (1)                                  *> IF DEBUG_DISPLAY  defined, more COBOL DISPLAY Statements

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
      $DISPLAY CONSTANT DEBUG_SOAPorJSON_HTTP          defined
      $DISPLAY    -> SOAP-ENVELOP Get & SET written to a LOG file
      $DISPLAY         (IF WSLOG environment variable will be set)
      $ELSE
      $DISPLAY CONSTANT DEBUG_SOAPorJSON_HTTP      not defined -> no traces
      $END-IF

      $IF DEBUG_DISPLAY DEFINED
      $DISPLAY CONSTANT DEBUG_DISPLAY     defined
      $DISPLAY    ->    COBOL DISPLAY Statements
      $ELSE
      $DISPLAY CONSTANT DEBUG_DISPLAY not defined
      $DISPLAY    -> no COBOL DISPLAY Statements

      $END-IF


      *-----------------------------------------------------------------
      $IF DEBUG_SOAPorJSON_HTTP DEFINED                           *> !!!
      *-----------------------------------------------------
      $DISPLAY Log file to
      *---------------------------------------
      $SET CONSTANT dynDEBUG_SOAPorJSON_HTTP (1)

      $IF  dynDEBUG_SOAPorJSON_HTTP DEFINED
      $DISPLAY   to [WSname]_[DATE]-[TIME]_[PID].log                      *> SOAPenv LOG file: it's value being [WSname]-app_[DATE]-[TIME]_[PID].log
      $DISPLAY         (IF WSLOG environment variable will be set)
      $ELSE
      $DISPLAY   to [WSname]-app.log                                      *> SOAPenv LOG file: it's value being [WSname]-app.log
      $DISPLAY   or value of Environment variable SOAPENVLOG if set
      $DISPLAY         (IF WSLOG environment variable will be set)
      $END-IF
      *---------------------------------------
      $END-IF                                     *> !!!
      *-----------------------------------------------------------------

      $SET CHANGE-MESSAGE"1057 N"                                        *> COBCH1057E REFERENCE/CONTENT/VALUE phrase does not match that specified in prototype


      *=================================================================
           copy "cblproto".
      *=================================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. WSCLIENTUSEREXIT.
       WORKING-STORAGE SECTION.
       78 exit-soap-request        value "exit-soap-request".
       78 exit-soap-response       value "exit-soap-response".
JSON   78 exit-json-request        value "exit-json-request".
JSON   78 exit-json-response       value "exit-json-response".

       78 exit-http-headers        value "exit-http-headers".           .
       78 exit-http-resp-headers   value "exit-http-resp-headers".


       78 SOAP-ENVmultiply     value 1.5.
       78 MEM-UnitAllocUnit    value 512.
       78 MEM-UnitAllocIfPlus  value MEM-UnitAllocUnit * 8.              *> = 4096 bytes

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
       78 SOAP-ENV-received    value " (below SOAP-ENVELOP received) ".
       78 SOAP-ENV-retrieved   value " (below SOAP-ENVELOP retrieved)".
JSON   78 JSON-ENV-received    value " (below JSON-ENVELOP received) ".
JSON   78 JSON-ENV-retrieved   value " (below JSON-ENVELOP retrieved)".
       78 SOAPorJSON-HTTP_setHH   value
                       " (below named values injected in HTTP-HEADER)".
       78 SOAPorJSON-HTTP_getHH   value
                       " (below named values in HTTP-HEADER)".

       01 MsgIOQ                   pic x(5).
       88 MsgI                     value "In   ".
       88 MsgO                     value "Out  ".
       88 MsgQ                     value "Quit ".
       88 MsgL                     value "Loop ".
       01 MsgEntry                 pic x(24).
       88 MsgEntryRequestSOAP      value exit-soap-request.
       88 MsgEntryResponseSOAP     value exit-soap-response.
JSON   88 MsgEntryRequestJSON      value exit-json-request.
JSON   88 MsgEntryResponseJSON     value exit-json-response.
       88 MsgEntrySetHTTP          value exit-http-headers.
       88 MsgEntrygetHTTP          value exit-http-resp-headers.

       78 MsgInfoSOAPorJSONEnvLen  value 124.
       01 MsgInfoSOAPorJSONEnv     pic x(MsgInfoSOAPorJSONEnvLen).
       88 MsgInfoSOAP_EnvReceived  value SOAP-ENV-received.
       88 MsgInfoSOAP_Envretrieved value SOAP-ENV-retrieved.
JSON   88 MsgInfoJSON_EnvReceived  value JSON-ENV-received.
JSON   88 MsgInfoJSON_EnvRetrieved value JSON-ENV-retrieved.
       88 MsgInfoHttpSetHH         value SOAPorJSON-HTTP_setHH.
       88 MsgInfoHttpGetHH         value SOAPorJSON-HTTP_getHH.

       88 MsgInfoSOAP_JSON_EnvSpaces value all spaces.
      $END-IF

       78 pfx                 value "*--> ".
       78 KO                  value "<KO> ".
       78 OK                  value "<OK> ".
       78 LF                  value x"0D".
       78 FATALERROR          value "FATAL ERROR: -> PROCESS STOPPED! ".
       01 separ               pic x(80) value all "-".
       01 separ10             pic x(10) value all "-".

       01 wssSOAPorJSON-ENVmod pic x(MEM-UnitAllocIfPlus).
          *> Used when SOAPorJSON * SOAP-ENVmultiply < MEM-UnitAllocIfPlus
          *> No Dynamic Memory Allocation  then  ' paragraph:initMemWrk!

       01 intWrk               cblt-sx4-comp5.   *> = int
       01 intWrk1              cblt-sx4-comp5.


       *> CBL_ALLOC_MEM
       01 mem-pointer          cblt-pointer.
       01 mem-pointerMod       cblt-pointer value null.
       01 mem-pointerWrk       cblt-pointer value null.
       01 mem-size             cblt-os-size.
       01 flags                cblt-os-flags value 0.
       01 status-code          cblt-x4-comp5.

       78 EntryToCallLen       value 256.
       01 EntryToCall          pic x(EntryToCallLen).
       01 EntryToCallFoundOrNot pic x comp-x.
       88 EntryToCallFound     value 1.
       88 EntryToCallNotFound  value 0.

       78 SOAP                 value "SOAP".
JSON   78 JSON                 value "JSON".
       01 WStype               pic x(4) value spaces.
       88 WStypeSOAP           value SOAP.
       88 WStypeJSON           value JSON.

JSON   01 SOAPorJSONenv        pic x(4).
JSON   88 SOAP-envWS           value SOAP.
JSON   88 JSON-envWS           value JSON.
JSON   88 ERR-envWS            value "????".

       78 HTTP                 value "HTTP".
       78 REQUEST              value "REQUEST".
       78 RESPONSE             value "RESPONSE".

       78 NothingspecificToDo          value 0.
       78 REQUESTspecificTodo          value 1.
       78 RESPONSEspecificTodo         value 2.
       78 REQUESTRESPONSEspecificTodo  value 3.
       *> SorJ_ for SOAPorJSON
       01 SorJ_ShallWeDoAnyThing  pic x comp-x
                                  value NothingspecificToDo.
       88 SorJ_NotToDoSpecific    value NothingspecificToDo.
       88 SorJ_todoSpecific_Req   value REQUESTspecificTodo.             *> _Req      for Request
       88 SorJ_todoSpecific_Res   value RESPONSEspecificTodo.            *> _Res      for Response
       88 SorJ_todoSpecific_ReqRes                                       *> _ReqRes   for RequestResponse
                                  value REQUESTRESPONSEspecificTodo.

       78 HTTP_SETHEADERSpecificTodo       value 1.
       78 HTTP_GETHEADERSpecificTodo       value 2.
       78 HTTP_GETSETHEADERSpecificTodo    value 3.
       01 HTTP_ShallWeDoAnyThing  pic x comp-x
                                   value NothingspecificToDo.
      *88 HTTP_NotToDoSpecific    value NothingspecificToDo.
       88 HTTP_todoSpecific_SetHeaders
                                   value HTTP_SETHEADERSpecificTodo.
       88 HTTP_todoSpecific_GetHeaders
                                   value HTTP_GETHEADERSpecificTodo.
       88 HTTP_todoSpecific_SetGetHeaders
                                   value HTTP_GETSETHEADERSpecificTodo.

      *78 UserExit                value "UE". *> old value for SET HTTP  HEADER
      *78 HeadersCtse             value "headers".
       78 HeadersCtse             value "HH".
       78 setHeaders              value "set" & HeadersCtse.
       78 getHeaders              value "get" & HeadersCtse.

       01 pptr                 procedure-pointer.
       01 pptrREQUEST          procedure-pointer.
       01 pptrRESPONSE         procedure-pointer.
       01 pptrSetHTTP          procedure-pointer.
       01 pptrGetHTTP          procedure-pointer.


      $IF DEBUG_SOAPorJSON_HTTP DEFINED
       78 SOAPENVLOG           value "SOAPENVLOG".
       78 LOGDIR               value "LOGDIR".
       01 EnvtVarName          pic x(10)  value SOAPENVLOG.
       78 EnvtVarValueLen      value EntryToCallLen * 2.
       01 EnvtVarValue         pic x(EnvtVarValueLen) value spaces.
       01 LOGDIRvalue          pic x(EnvtVarValueLen) value spaces.
       01 EnvtVarValueWrk      pic x(EnvtVarValueLen)
                                                  redefines LOGDIRvalue.


       *> CBL_GET_OS_INFO
       01 CGOI_parameter-block cblt-os-info-params.
       01 processId            cblt-x4-comp5.
       01 processIdNum         pic 9(6).
       01 separator            pic x.
       88 separatorWindows     value "\".
       88 separatorUnix        value "/".

       01 ws-date              pic 9(8).
       01 ws-time              pic 9(8).

       78 LOGextension         value "log".

       *> MF ByteStream routines
       01  fnf-access-type     cblt-x1-compx   value 0.
           88  fnf-access-read-88              value 1.
           88  fnf-access-write-88             value 2.
           88  fnf-access-rdwrt-88             value 3.
       01  fnf-deny-type       cblt-x1-compx   value 0.
           88  fnf-deny-rdwrt-88               value 0.
           88  fnf-deny-write-88               value 1.
           88  fnf-deny-read-88                value 2.
           88  fnf-deny-none-88                value 3.
       01  fnf-device          cblt-x1-compx   value 0.
      *01  fnf-file-handle     cblt-bytestream-handle   value 0.

       01 file-offset          cblt-x8-compx value 0.
       01 byte-count           cblt-x4-compx value 0.
       01 flagsbt              cblt-x1-compx value 0.

       01 ptrBufToWrt          pointer.
      $END-IF

       01  fnf-file-handle     cblt-bytestream-handle   value 0.

       78 bufferLen            value 1024.
       01 buffer               pic x(bufferLen).
       01 LSSEQterminator      pic xx value x"0D0A".
       88 LSSEQterminatorWindows value x"0D0A".
       88 LSSEQterminatorUnix    value x"0A".
       01 LSSEQterminatorLen   pic 9 value 2.

       *> CBL_GET_PROGRAM_INFO
       01 MFfunction           cblt-x4-comp5 value 0.
       *> 00 Return status information for the current program. If you want to retrieve further information on this program, then bit 0 of the cblte-gpi-flags parameter must be set to indicate that this function should return cblte-gpi-handle, which will
       *> 2 Return status information for the program that called the program currently associated with cblte-gpi-handle. This function requires that cblte-gpi-handle has been set up using functions 0 or 1. The program associated with cblte-gpi-handle is
       88 MFfunction0          value 0.
       88 MFfunction1          value 1.
       88 MFfunction2          value 2.
       88 MFfunction3          value 3.

       78 PROGnameLength       value 50.
       01 MFparam-block        cblt-prog-info-params.
       01 MFreturn-buf         pic x(PROGnameLength).
       01 AndTheCallerWasSav   pic x(PROGnameLength)
                                          redefines MFreturn-buf.
       01 MFreturn-buf-len     cblt-x4-comp5.
       01 MFstatus-code        cblt-x4-comp5 value 0.
       01 AndTheCallerWas      pic x(PROGnameLength).
       01 AndTheCallerWasLen   cblt-x4-comp5.
       01 strLenWrk            cblt-x4-comp5
                                          redefines  AndTheCallerWasLen.

       01 SOAP-ENVlenD         pic 9(8).
       01 msg                  pic x value "I".
       88 MsfInfo              value "L".
       88 MsgFatalError        value "F".                                 *> Condition set to stop to process if FATAL ERROR

       01 int                  pic s9(9) comp-5 is typedef.
WSLOG  78 WSLOGEnvtVar         value "WSLOG".
WSLOG  01 WSLOGEnvtValue       pic x.
WSLOG  88 WSLOGEnvtValueSpace  value spaces.

JSON   01 SOAPorJSON_WS        pic x(4) value spaces.
JSON   88 SOAP_WS              value SOAP.
JSON   88 JSON_WS              value JSON.
JSON   88 SOAPorJSON_WS_space  value spaces.
JSON   78 JSON-ENV_1stChar     value "{".
JSON   78 SOAP-ENV_1stChar     value "<".

       *> HTTPget User Exit   -> exit-http-resp-header
       01 HTTPgetHH_headerNum      pic 9(9) usage comp-5.
       01 HTTPgetHH_headerNameLen  pic 9(9) usage comp-5.
       01 HTTPgetHH_headerValueLen pic 9(9) usage comp-5.

      *=================================================================
       LOCAL-STORAGE SECTION.
       01 wssSOAP-ENVwrk       pic x(MEM-UnitAllocIfPlus).
       01 headerNumDisp        pic zz9.
      *=================================================================
       LINKAGE SECTION.
       *> data SOAP | JSON REQUEST/RESPONSE User Exit
       01 SOAPorJSON-ENV       pic x. *> any length.
       01 SOAPorJSON-ENVptr    pointer.
       01 SOAPorJSON-ENVlen    cblt-sx4-comp5.   *> = int
       01 SOAP-ENVmod          pic x. *> any length.
       01 SOAP-ENVwrk          pic x. *> any length.

       *> HTTPset User Exit   -> exit-http-headers
       01 HTTPsetHH_headerNum    int.
       01 HTTPsetHH_headerName   pic x(256).   *>  256 = Max Length
       01 HTTPsetHH_headerValue  pic x(8192).  *> 8192 = Max Length

       *> HTTPget User Exit   -> exit-http-resp-header
       01 HTTPgetHH_headerArrayPtr pointer.
       01 HTTPgetHH_headerCount    pic 9(9) usage comp-5.
       01 HTTPgetHH_header.
         03 HTTPgetHH_namePtr      pointer.
         03 HTTPgetHH_valuePtr     pointer.
       01 HTTPgetHH_headerName     pic x(1).
       01 HTTPgetHH_headerValue    pic x(1).

      *=================================================================
      *=================================================================
      *=================================================================
       PROCEDURE DIVISION.
       main section.
      *>  Set logging
          move WSLOGEnvtVar to EnvtVarName
          move "Y"          to EnvtVarValue
          perform SetEnvtVar

           move WSLOGEnvtVar to EnvtVarName
           perform GetEnvtVar
           move EnvtVarValue to WSLOGEnvtValue
           IF WSLOGEnvtValueSpace
              display separ
              display  pfx
                   "Environment variable " WSLOGEnvtVar
                   " is not set"
              display pfx
               "There will be no logging of the Web Service consumption"
              display separ
           END-IF

           perform WhoIsTheCaller                                         *> get the program name of the caller  , retrieved in variable: AndTheCallerWas
           perform setAndTheCallerWasLen

      $IF  DEBUG_SOAPorJSON_HTTP defined
           IF NOT WSLOGEnvtValueSpace
             perform ManageLogFileName
             perform doCBL-DELETE-FILE
           END-IF
      $END-IF

           set WStypeSOAP to true
           perform WhatShallWeDoSpecificSOAPorJSON
           IF SorJ_NotToDoSpecific
            set WStypeJSON to true
            perform WhatShallWeDoSpecificSOAPorJSON
           END-IF
           perform WhatShallWeDoSpecificHTTP

      $IF  DEBUG_SOAPorJSON_HTTP defined
      * IF SorJ_todoSpecific_Req or SorJ_todoSpecific_ReqRes
           IF NOT WSLOGEnvtValueSpace
               perform doCBL-CREATE-FILE perform doCBL-CLOSE-FILE         *> Empty file created = LOG IOed with MF Byte-Stream routines
           END-IF
      * END-IF

      $END-IF

           EXIT PROGRAM.
           STOP RUN.
      *=================================================================
      *=================================================================
      *=================================================================
       S-exit-http-resp-headers section.
       entry exit-http-resp-headers using
            by value HTTPgetHH_headerArrayPtr, HTTPgetHH_headerCount.


         IF HTTP_todoSpecific_getHeaders
           or HTTP_todoSpecific_SetGetHeaders
      $IF DEBUG_SOAPorJSON_HTTP DEFINED
      *   IF HTTPgetHH_headerCount = 0   *> 0 means start of the loop
           IF NOT WSLOGEnvtValueSpace
             perform doCBL-OPEN-FILE

             set MsgEntryGetHTTP to true        set MsgI to true
             set MsgInfoHttpGetHH  to true perform doMsgIOQ

             set MsgL to true
           END-IF
      *   END-IF
      $END-IF
          set address of HTTPgetHH_header to HTTPgetHH_headerArrayPtr

          initialize HTTPgetHH_headerNum
          perform HTTPgetHH_headerCount times
              add 1 to HTTPgetHH_headerNum
              set address of HTTPgetHH_headerName
               to HTTPgetHH_namePtr  of HTTPgetHH_header
              set address of HTTPgetHH_headerValue
              to HTTPgetHH_valuePtr of HTTPgetHH_header
              perform
               varying HTTPgetHH_headerNameLen from 1 by 1
               until HTTPgetHH_headerName(HTTPgetHH_headerNameLen:1)
                       = low-value
              end-perform
              subtract 1 from HTTPgetHH_headerNameLen
              perform varying HTTPgetHH_headerValueLen
               from 1 by 1
               until HTTPgetHH_headerValue(HTTPgetHH_headerValueLen:1)
                       = low-value
              end-perform
              subtract 1 from HTTPgetHH_headerValueLen

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
          IF NOT WSLOGEnvtValueSpace
            initialize buffer
            move       HTTPgetHH_headerNum  to headerNumDisp
            string     "Named value N� " headerNumDisp ": "
                                                  delimited by size
                      HTTPgetHH_headerName(1:HTTPgetHH_headerNameLen)
                                                  delimited by size
                       " = "                      delimited by size
                      HTTPgetHH_headerValue(1:HTTPgetHH_headerValueLen)
                                                  delimited by size
                       LF                         delimited by size
                into   buffer(1:bufferLen)
            perform wrtToLogMsg
          END-IF
      $END-IF

              set address of HTTPgetHH_header up
                   by length of HTTPgetHH_header
          end-perform


      $IF DEBUG_SOAPorJSON_HTTP DEFINED                                   *> End of loop
          IF NOT WSLOGEnvtValueSpace
            set MsgQ to true
            set MsgInfoSOAP_JSON_EnvSpaces to true perform doMsgIOQ

            perform doCBL-CLOSE-FILE
          END-IF
      $END-IF

         END-IF
         exit program
         .
      *=================================================================
      *=================================================================
      *=================================================================
       S-exit-http-headers-headers section.
       entry exit-http-headers
               using   by value        HTTPsetHH_headerNum
                       by reference    HTTPsetHH_headerName
                       by reference    HTTPsetHH_headerValue.

         IF HTTP_todoSpecific_SetHeaders
           or HTTP_todoSpecific_SetGetHeaders
      $IF DEBUG_SOAPorJSON_HTTP DEFINED
          IF HTTPsetHH_headerNum = 0   *> 0 means start of the loop
           IF NOT WSLOGEnvtValueSpace
             perform doCBL-OPEN-FILE

             set MsgEntrySetHTTP to true        set MsgI to true
             set MsgInfoHttpSetHH to true perform doMsgIOQ

             set MsgL to true
           END-IF
          END-IF
      $END-IF

          call pptrSetHTTP using  by value     HTTPsetHH_headerNum
                                  by reference HTTPsetHH_headerName
                                  by reference HTTPsetHH_headerValue
                   on exception *> These lines should never be executed
                                move "  pptrSetHTTP  not found"
                                  to EnvtVarValueWrk
                                perform WouldBeA_MF_RTS173
          end-call

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
          IF  HTTPsetHH_headerName  not = low-value
          AND HTTPsetHH_headerValue not = low-value
           IF NOT WSLOGEnvtValueSpace
             initialize buffer
             move       HTTPsetHH_headerNum  to headerNumDisp
             string     "Named value N� " headerNumDisp ": "
                                                  delimited by size
                        HTTPsetHH_headerName      delimited by low-value
                        " = "                     delimited by size
                        HTTPsetHH_headerValue     delimited by low-value
                        LF                        delimited by size
                 into   buffer(1:bufferLen)
             perform wrtToLogMsg
           END-IF
          END-IF
      $END-IF

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
          IF  HTTPsetHH_headerName = low-value
                and HTTPsetHH_headerValue = low-value          *> End of loop
           IF NOT WSLOGEnvtValueSpace
             set MsgQ to true
             set MsgInfoSOAP_JSON_EnvSpaces to true perform doMsgIOQ

             perform doCBL-CLOSE-FILE
           END-IF
          END-IF
      $END-IF

         END-IF
         exit program
         .
      *=================================================================
      *=================================================================
      *=================================================================
       S-exit-soap-request section.
       ENTRY exit-soap-request using by reference  SOAPorJSON-ENVptr
                                     by reference  SOAPorJSON-ENVlen.
      $IF DEBUG_SOAPorJSON_HTTP DEFINED
         IF NOT WSLOGEnvtValueSpace
           perform doCBL-OPEN-FILE

           perform GetWS_Type_SOAPorJSON

           set MsgEntryRequestSOAP to true        set MsgI to true
           set MsgInfoSOAP_EnvReceived to true perform doMsgIOQ
         END-IF
      $END-IF

         perform getSOAPorJSON-ENVcontent *> ---------------------------

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
         IF NOT WSLOGEnvtValueSpace
           perform DispSOAPorJSON-ENVELOP *> ---------------------------
         END-IF
      $END-IF

        IF SorJ_todoSpecific_Req or SorJ_todoSpecific_ReqRes
         perform initMemWrk  *> ----------------------------------------
        END-IF


      *=================================================================
      *    SEARCH and REPLACE in SOAPorJSON-ENV done in pptrREQUEST
        IF SorJ_todoSpecific_Req or SorJ_todoSpecific_ReqRes
           call pptrREQUEST    using SOAPorJSON-ENV
                                     SOAPorJSON-ENVlen
                                     SOAP-ENVwrk
                                     SOAP-ENVmod
                                     mem-size
                   on exception *> These lines should never be executed
                                move "pptrREQUEST  not found"
                                  to EnvtVarValueWrk
                                perform WouldBeA_MF_RTS173
           end-call
        END-IF

      *=================================================================
        IF SorJ_todoSpecific_Req or SorJ_todoSpecific_ReqRes
         perform updateSOAPorJSON-ENVptrAndLen *> ----------------------

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
         IF NOT WSLOGEnvtValueSpace
           set MsgO to true
           set MsgInfoSOAP_Envretrieved to true perform doMsgIOQ

           perform DispSOAPorJSON-ENVELOPmod *> ------------------------
         END-IF
      $END-IF
        END-IF

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
         IF NOT WSLOGEnvtValueSpace
           set MsgQ to true
           set MsgInfoSOAP_JSON_EnvSpaces to true perform doMsgIOQ

           perform doCBL-CLOSE-FILE
         END-IF
      $END-IF

         exit program
         .
      *=================================================================
      *=================================================================
      *=================================================================
       S-exit-soap-response section.
       ENTRY exit-soap-response using by reference  SOAPorJSON-ENVptr
                                      by reference  SOAPorJSON-ENVlen.
      $IF DEBUG_SOAPorJSON_HTTP DEFINED
         IF NOT WSLOGEnvtValueSpace
           perform doCBL-OPEN-FILE

           perform GetWS_Type_SOAPorJSON

           set MsgEntryResponseSOAP to true       set MsgI to true
           set MsgInfoSOAP_EnvReceived to true perform doMsgIOQ
         END-IF
      $END-IF

         perform getSOAPorJSON-ENVcontent *> ---------------------------

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
         IF NOT WSLOGEnvtValueSpace
           perform DispSOAPorJSON-ENVELOP *> ---------------------------
         END-IF
      $END-IF

        IF SorJ_todoSpecific_Res or SorJ_todoSpecific_ReqRes
         perform initMemWrk  *> ----------------------------------------
        END-IF


      *=================================================================
      *    SEARCH and REPLACE in SOAPorJSON-ENV done in pptrRESPONSE
        IF SorJ_todoSpecific_Res or SorJ_todoSpecific_ReqRes
           call pptrRESPONSE   using SOAPorJSON-ENV
                                     SOAPorJSON-ENVlen
                                     SOAP-ENVwrk
                                     SOAP-ENVmod
                                     mem-size
                   on exception *> These lines should never be executed
                                move "pptrRESPONSE  not found"
                                  to EnvtVarValueWrk
                                perform WouldBeA_MF_RTS173
           end-call
        END-IF

      *=================================================================
        IF SorJ_todoSpecific_Res or SorJ_todoSpecific_ReqRes
         perform updateSOAPorJSON-ENVptrAndLen *> ----------------------

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
         IF NOT WSLOGEnvtValueSpace
           set MsgO to true
           set MsgInfoSOAP_Envretrieved to true perform doMsgIOQ

           perform DispSOAPorJSON-ENVELOPmod *> ------------------------
         END-IF
      $END-IF
        END-IF

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
         IF NOT WSLOGEnvtValueSpace
           set MsgQ to true
           set MsgInfoSOAP_JSON_EnvSpaces    to true perform doMsgIOQ

           perform doCBL-CLOSE-FILE
         END-IF
      $END-IF

         exit program
         .
      *=================================================================
      *=================================================================
      *=================================================================
       S-exit-json-request section.
       ENTRY exit-json-request using by reference  SOAPorJSON-ENVptr
                                     by reference  SOAPorJSON-ENVlen.
      $IF DEBUG_SOAPorJSON_HTTP DEFINED
         IF NOT WSLOGEnvtValueSpace

           perform doCBL-OPEN-FILE

           perform GetWS_Type_SOAPorJSON

           set MsgEntryRequestJSON to true        set MsgI to true
           set MsgInfoJSON_EnvReceived to true perform doMsgIOQ
         END-IF
      $END-IF

         perform getSOAPorJSON-ENVcontent *> ---------------------------

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
         IF NOT WSLOGEnvtValueSpace
           perform DispSOAPorJSON-ENVELOP *> ---------------------------
         END-IF
      $END-IF

        IF SorJ_todoSpecific_Req or SorJ_todoSpecific_ReqRes
         perform initMemWrk  *> ----------------------------------------
        END-IF


      *=================================================================
      *    SEARCH and REPLACE in JSON-ENV done in pptrREQUEST
        IF SorJ_todoSpecific_Req or SorJ_todoSpecific_ReqRes
           call pptrREQUEST    using SOAPorJSON-ENV
                                     SOAPorJSON-ENVlen
                                     SOAP-ENVwrk
                                     SOAP-ENVmod
                                     mem-size
                   on exception *> These lines should never be executed
                                move "pptrREQUEST  not found"
                                  to EnvtVarValueWrk
                                perform WouldBeA_MF_RTS173
           end-call
        END-IF

      *=================================================================
        IF SorJ_todoSpecific_Req or SorJ_todoSpecific_ReqRes
         perform updateSOAPorJSON-ENVptrAndLen *> ----------------------

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
         IF NOT WSLOGEnvtValueSpace
           set MsgO to true
           set MsgInfoJSON_EnvRetrieved to true perform doMsgIOQ

           perform DispSOAPorJSON-ENVELOPmod *> ------------------------
         END-IF
      $END-IF
        END-IF

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
         IF NOT WSLOGEnvtValueSpace
           set MsgQ to true
           set MsgInfoSOAP_JSON_EnvSpaces to true perform doMsgIOQ

           perform doCBL-CLOSE-FILE
         END-IF
      $END-IF

         exit program
         .
      *=================================================================
      *=================================================================
      *=================================================================
       S-exit-json-response section.
       ENTRY exit-json-response using by reference  SOAPorJSON-ENVptr
                                      by reference  SOAPorJSON-ENVlen.
      $IF DEBUG_SOAPorJSON_HTTP DEFINED
         IF NOT WSLOGEnvtValueSpace
           perform doCBL-OPEN-FILE

           perform GetWS_Type_SOAPorJSON

           set MsgEntryResponseJSON to true       set MsgI to true
           set MsgInfoJSON_EnvReceived to true perform doMsgIOQ
         END-IF
      $END-IF

         perform getSOAPorJSON-ENVcontent *> ---------------------------

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
         IF NOT WSLOGEnvtValueSpace
           perform DispSOAPorJSON-ENVELOP *> ---------------------------
         END-IF
      $END-IF

        IF SorJ_todoSpecific_Res or SorJ_todoSpecific_ReqRes
         perform initMemWrk  *> ----------------------------------------
        END-IF


      *=================================================================
      *    SEARCH and REPLACE in JSON-ENV done in pptrRESPONSE
        IF SorJ_todoSpecific_Res or SorJ_todoSpecific_ReqRes
           call pptrRESPONSE   using SOAPorJSON-ENV
                                     SOAPorJSON-ENVlen
                                     SOAP-ENVwrk
                                     SOAP-ENVmod
                                     mem-size

                   on exception *> These lines should never be executed
                                move "pptrRESPONSE  not found"
                                  to EnvtVarValueWrk
                                perform WouldBeA_MF_RTS173
           end-call
        END-IF

      *=================================================================
        IF SorJ_todoSpecific_Res or SorJ_todoSpecific_ReqRes
         perform updateSOAPorJSON-ENVptrAndLen *> ----------------------

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
         IF NOT WSLOGEnvtValueSpace
           set MsgO to true
           set MsgInfoJSON_Envretrieved to true perform doMsgIOQ

           perform DispSOAPorJSON-ENVELOPmod *> ------------------------
         END-IF
      $END-IF
        END-IF

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
         IF NOT WSLOGEnvtValueSpace
           set MsgQ to true
           set MsgInfoSOAP_JSON_EnvSpaces    to true perform doMsgIOQ

           perform doCBL-CLOSE-FILE
         END-IF
      $END-IF

         exit program
         .
      *=================================================================
      *=================================================================
      *=================================================================
      *=================================================================
      *=================================================================
      *=================================================================
       WouldBeA_MF_RTS173 section.
           perform getstrlenEnvtVarValueWrk
           initialize buffer
           string
           LSSEQterminator (1 : LSSEQterminatorLen)
           LSSEQterminator (1 : LSSEQterminatorLen)
           separ separ
           pfx KO EnvtVarValueWrk(1 : strLEnWrk)
           LSSEQterminator (1 : LSSEQterminatorLen)
           pfx KO FATALERROR
           LSSEQterminator (1 : LSSEQterminatorLen)
           separ separ
           LSSEQterminator (1 : LSSEQterminatorLen)
           into      buffer
           set       MsgFatalError to true
           perform wrtToLogMsg
           perform SFATALERROR
           .
      *=================================================================
       getSOAPorJSON-ENVcontent section.
         if SOAPorJSON-ENVptr not = NULL
               set address of SOAPorJSON-ENV to SOAPorJSON-ENVptr
         else  initialize buffer
               string
               LSSEQterminator (1 : LSSEQterminatorLen)
               LSSEQterminator (1 : LSSEQterminatorLen)
               separ separ
               pfx KO "!!!! pointer on SOAPorJSON-ENV = NULL"
               LSSEQterminator (1 : LSSEQterminatorLen)
               pfx KO FATALERROR
               LSSEQterminator (1 : LSSEQterminatorLen)
               separ separ
               LSSEQterminator (1 : LSSEQterminatorLen)
               into      buffer
               set       MsgFatalError to true
               perform wrtToLogMsg
         end-if
         .
      *=================================================================
       GetWS_Type_SOAPorJSON section.
         IF SOAPorJSON_WS_space
          perform getSOAPorJSON-ENVcontent
          initialize buffer
          evaluate SOAPorJSON-ENV( 1 : 1)
            when SOAP-ENV_1stChar
                   set SOAP_WS to true
                   String
                    LSSEQterminator (1 : LSSEQterminatorLen)
                    separ
                    LSSEQterminator (1 : LSSEQterminatorLen)
      *             pfx OK
                    SOAP " Web service"
                    "(-> " SOAPorJSON-ENV(1 : 1) " <-)"
                    LSSEQterminator (1 : LSSEQterminatorLen)
                    separ
                    into      buffer
                    set SOAP-envWS to true
            when JSON-ENV_1stChar
                   set JSON_WS to true
                   String
                    LSSEQterminator (1 : LSSEQterminatorLen)
                    separ
                    LSSEQterminator (1 : LSSEQterminatorLen)
      *             pfx OK
                    JSON " Web service"
                    "(-> " SOAPorJSON-ENV(1 : 1) " <-)"
                    LSSEQterminator (1 : LSSEQterminatorLen)
                    separ
                    LSSEQterminator (1 : LSSEQterminatorLen)
                    into      buffer
                    set JSON-envWS to true
            when other
                   String
                    LSSEQterminator (1 : LSSEQterminatorLen)
                    separ
                    LSSEQterminator (1 : LSSEQterminatorLen)
      *             pfx KO
                    "????" " Web service"
                    "(-> " SOAPorJSON-ENV(1 : 1) " <-)"
                    " (Not " SOAP " neither " JSON ")"
                    LSSEQterminator (1 : LSSEQterminatorLen)
                    pfx ko
                    " (unknown  Web service implementation) "
                    LSSEQterminator (1 : LSSEQterminatorLen)
                    separ
                    into      buffer
                    set ERR-envWS to true
          end-evaluate
          perform wrtToLogMsg
          display buffer(1 : strLenWrk)
         END-IF
         .
      *=================================================================
       updateSOAPorJSON-ENVptrAndLen SECTION.
      * update SOAPorJSON-ENVptr ---------------------------------------------
         move mem-pointerMod to SOAPorJSON-ENVptr

         IF mem-size > MEM-UnitAllocIfPlus
             move mem-pointerWrk to mem-pointer
             perform doCBL-FREE-MEM  *> --------------------------------
         END-IF
      *  update  SOAPorJSON-ENVlen
         perform varying SOAPorJSON-ENVlen from mem-size by -1
           until SOAP-ENVmod(SOAPorJSON-ENVlen : 1) not = spaces
         end-perform
         .
      *=================================================================
       initMemWrk SECTION.
         *>    of course constant SOAP-ENVmultiply can be modified / specific needs when its value = 1.5 not sufficient
         compute mem-size = SOAPorJSON-ENVlen * SOAP-ENVmultiply
         divide  mem-size by MEM-UnitAllocUnit giving intWrk
         compute mem-size = (  (intWrk * MEM-UnitAllocUnit)
                              +          MEM-UnitAllocUnit)
         IF mem-size < MEM-UnitAllocIfPlus *> No Dynamic Memory Allocation
            set mem-pointerMod to address  of    wssSOAPorJSON-ENVmod
            set mem-pointerWrk to address  of    wssSOAP-ENVwrk
            move       MEM-UnitAllocIfPlus to    mem-size
            set address of SOAP-ENVmod     to    mem-pointerMod
            set address of SOAP-ENVwrk     to    mem-pointerWrk

         else
            perform dynMemAlloc            *>    Dynamic Memory Allocation
               move mem-pointer            to    mem-pointerMod             *> This memory will be freed when process terminates
               set address of SOAP-ENVmod  to    mem-pointerMod
            perform dynMemAlloc            *>    Dynamic Memory Allocation
               move mem-pointer            to    mem-pointerWrk
               set address of SOAP-ENVwrk  to    mem-pointerWrk             *> This 'wrk' memory is freed in the code
         end-if
         initialize SOAP-ENVmod(1:mem-size)
         initialize SOAP-ENVwrk(1:mem-size)
         .
      *=================================================================
       doCBL-FREE-MEM section.
      $IF DEBUG_DISPLAY defined
         display pfx CBL-FREE-MEM " -> " with no advancing
      $END-IF

         call CBL-FREE-MEM   using by value mem-pointer
                             returning      status-code
      $IF DEBUG_DISPLAY defined
         if status-code = 0 display OK
         else               display KO status-code
                            display pfx KO  FATALERROR
                            display separ
                            perform SFatalError
         end-if
      $ELSE
         if status-code not = 0
                            display pfx CBL-FREE-MEM ": "
                                        with no advancing
                            display pfx KO  FATALERROR
                            display separ
                            perform SFatalError
         end-if
      $END-IF
         .

      *=================================================================
       dynMemAlloc SECTION.  *> Allocate dynamic Memory

      $IF DEBUG_DISPLAY defined
         display pfx CBL-ALLOC-MEM " -> Sz: " mem-size ": "
                                       with no advancing
      $END-IF
         call CBL-ALLOC-MEM    using             mem-pointer
                                       by value  mem-size
                                                 flags
                               returning         status-code
      $IF DEBUG_DISPLAY defined
         if status-code = 0 display OK
         else               display KO status-code
                            display pfx KO  FATALERROR
                            display separ
                            perform SFATALERROR
         end-if
      $ELSE
         if status-code not = 0
                            display pfx CBL-ALLOC-MEM ": "
                                        with no advancing
                            display pfx KO  FATALERROR
                            display separ
                            perform SFATALERROR
         end-if
      $END-IF
         .
*******=================================================================
       WhatShallWeDoSpecificSOAPorJSON section.
       *> User Exit SOAP
           initialize EntryToCall SorJ_ShallWeDoAnyThing
           set SorJ_NotToDoSpecific to true
           string  function upper-case(
                   AndTheCallerWas(1 : AndTheCallerWasLen) )
                   WStype
              into EntryToCall                                            *> [WSNAME]-SOAP

           call    function UPPER-CASE(EntryToCall)                       *>  Call UpperCase
                       on exception
                          call    function LOWER-CASE(EntryToCall)        *>  Call lowerCase
                          on exception
                                  set EntryToCallNotFound       to true
                          not on exception
                                  set EntryToCallFound          to true
      $IF DEBUG_DISPLAY DEFINED
                                  display pfx
                                  function LOWER-CASE(EntryToCall)
                                  "found"
      $END-IF
                          end-call
                   not on exception
                                  set EntryToCallFound          to true
      $IF DEBUG_DISPLAY DEFINED
                                  display pfx
                                  function UPPER-CASE(EntryToCall)
                                  "found"
      $END-IF
           end-call

           IF EntryToCallFound
                    initialize EntryToCall
                    set pptr to null
                    string
                      function upper-case(
                      AndTheCallerWas(1 : AndTheCallerWasLen) )
                      WStype
                      REQUEST
                      into            EntryToCall                         *> [WSNAME]-SOAPREQUEST
                    set pptr to entry EntryToCall
                    if pptr not = NULL
                     add REQUESTspecificTodo to SorJ_ShallWeDoAnyThing
                     move pptr               to pptrREQUEST
      $IF DEBUG_DISPLAY DEFINED
                    display pfx "Entry " EntryToCall " found"
      $END-IF
                    end-if

                    initialize EntryToCall
                    set pptr to null
                    string
                      function upper-case(
                      AndTheCallerWas(1 : AndTheCallerWasLen ) )
                      WStype
                      RESPONSE
                      into            EntryToCall                         *> [WSNAME]-SOAPRESPONSE
                    set pptr to entry EntryToCall
                    if pptr not = NULL
                     add RESPONSEspecificTodo to SorJ_ShallWeDoAnyThing
                     move pptr                to pptrRESPONSE
      $IF DEBUG_DISPLAY DEFINED
                    display pfx "Entry " EntryToCall " found"
      $END-IF
                    end-if
           END-IF
           .
     **=================================================================
       WhatShallWeDoSpecificHTTP section.
       *> User Exit HTTP
           initialize EntryToCall  HTTP_ShallWeDoAnyThing
      *    set HTTP_NotToDoSpecific to true
           string  function upper-case(
                   AndTheCallerWas(1 : AndTheCallerWasLen) )
                   HTTP
              into EntryToCall                                            *> [WSNAME]-HTTP

           call    function UPPER-CASE(EntryToCall)                       *>  Call UpperCase
                       on exception
                          call    function LOWER-CASE(EntryToCall)        *>  Call lowerCase
                          on exception
                                  set EntryToCallNotFound       to true
                          not on exception
                                  set EntryToCallFound          to true
      $IF DEBUG_DISPLAY DEFINED
                                  display pfx
                                  function LOWER-CASE(EntryToCall)
                                  "found"
      $END-IF
                          end-call
                   not on exception
                                  set EntryToCallFound          to true
      $IF DEBUG_DISPLAY DEFINED
                                  display pfx
                                  function UPPER-CASE(EntryToCall)
                                  "found"
      $END-IF
           end-call

           IF EntryToCallFound
                    initialize EntryToCall
                    set pptr to null
                    string
                      function upper-case(
                      AndTheCallerWas(1 : AndTheCallerWasLen) )
                      HTTP
                      setHeaders
                      into            EntryToCall                         *> [WSNAME]-HTTPsetHH
                    set pptr to entry EntryToCall
                    if pptr not = NULL
                       add HTTP_SETHEADERSpecificTodo
                           to HTTP_ShallWeDoAnyThing
                       move pptr               to pptrSetHTTP
      $IF DEBUG_DISPLAY DEFINED
                    display pfx "Entry " EntryToCall " found"
      $END-IF
                    end-if

                    initialize EntryToCall
                    set pptr to null
                    string
                      function upper-case(
                      AndTheCallerWas(1 : AndTheCallerWasLen) )
                      HTTP
                      getHeaders
                      into            EntryToCall                         *> [WSNAME]-HTTPsetHH
                    set pptr to entry EntryToCall
                    if pptr not = NULL
                       add HTTP_GETHEADERSpecificTodo
                           to HTTP_ShallWeDoAnyThing
                       move pptr               to pptrGetHTTP
      $IF DEBUG_DISPLAY DEFINED
                    display pfx "Entry " EntryToCall " found"
      $END-IF
                    end-if

           END-IF
           .
      *=================================================================
       SFatalError section.
      $IF  DEBUG_SOAPorJSON_HTTP defined
          if fnf-file-handle not = 0 perform doCBL-CLOSE-FILE END-IF
      $END-IF

          STOP RUN    *> PROCESSUS STOPPED HERE
          .
      *=================================================================

      *=================================================================
      *=================================================================
      *=================================================================
      *=================================================================
      *=================================================================

      $IF  DEBUG_SOAPorJSON_HTTP defined                                        *> Begin DEBUG_SOAPorJSON_HTTP defined !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      *=================================================================
       doMsgIOQ section.
         initialize buffer
         string        LSSEQterminator (1 : LSSEQterminatorLen)
                 separ LSSEQterminator (1 : LSSEQterminatorLen)
                 pfx   MsgIOQ  MsgEntry
                 MsgInfoSOAPorJSONEnv
                       LSSEQterminator (1 : LSSEQterminatorLen)
           into  buffer
         perform wrtToLogMsg

         if MsgQ
            initialize buffer
            string separ LSSEQterminator (1 : LSSEQterminatorLen)
                   separ LSSEQterminator (1 : LSSEQterminatorLen)
              into  buffer
            perform wrtToLogMsg
         end-if
         .
      *=================================================================
       DispSOAPorJSON-ENVELOPHeader section.
         initialize buffer
         move SOAPorJSON-ENVlen to SOAP-ENVlenD
         string  separ10 LSSEQterminator (1 : LSSEQterminatorLen)
                         LSSEQterminator (1 : LSSEQterminatorLen)
                 SOAPorJSONenv
                 "-ENVELOP length:  " SOAP-ENVlenD
                         LSSEQterminator (1 : LSSEQterminatorLen)
                 SOAPorJSONenv
                 "-ENVELOP content: "
                       LSSEQterminator (1 : LSSEQterminatorLen)
                       LSSEQterminator (1 : LSSEQterminatorLen)
           into  buffer
         perform wrtToLogMsg
         .
      *=================================================================
       DispSOAPorJSON-ENVELOPFoot  section..
         initialize buffer
         string  LSSEQterminator (1 : LSSEQterminatorLen)
                 separ10 LSSEQterminator (1 : LSSEQterminatorLen)
           into  buffer
         perform wrtToLogMsg
         .
      *=================================================================
       DispSOAPorJSON-ENVELOP section.
         perform DispSOAPorJSON-ENVELOPHeader
         move SOAPorJSON-ENVptr to ptrBufToWrt
         move SOAPorJSON-ENVlen to byte-count
         perform doCBL-WRITE-FILE
         perform DispSOAPorJSON-ENVELOPFoot
         .
      *=================================================================
       DispSOAPorJSON-ENVELOPmod section.
         perform DispSOAPorJSON-ENVELOPHeader
         set  ptrBufToWrt to address of SOAP-ENVmod
         move SOAPorJSON-ENVlen to byte-count
         perform doCBL-WRITE-FILE
         perform DispSOAPorJSON-ENVELOPFoot
         .

      *=================================================================
       GetEnvtVar section.
      *--> read the value of environment variable
          initialize EnvtVarValue
          display EnvtVarName  upon environment-name
          accept  EnvtVarValue from environment-value
          .
      *=================================================================
       SetEnvtVar section.
          display EnvtVarName  upon environment-name
          display EnvtVarValue upon environment-value
          .
      *=================================================================
       ManageLogFileName section.
           initialize   EnvtVarValue move LOGDIR to EnvtVarName
           perform GetEnvtVar
           move EnvtVarValue                  to LOGDIRvalue
           if   LOGDIRvalue = spaces move "." to LOGDIRvalue  end-if
           perform doCBL-GET-OS-INFO                                      *> need PID & separator set / dynDEBUG_SOAPorJSON_HTTP       if $SOAPENVLOG not set
                                                                          *>            separator set / NOT [dynDEBUG_SOAPorJSON_HTTP] if $SOAPENVLOG not set
      $IF  dynDEBUG_SOAPorJSON_HTTP defined
           accept ws-date from date YYYYMMDD
           accept ws-time from time

           initialize   EnvtVarValue move SOAPENVLOG to EnvtVarName
             string  LOGDIRvalue     delimited by space
                     separator       delimited by space
                     AndTheCallerWas(1 : AndTheCallerWasLen - 1 )        [WSname]-  -> [WSname]
                                     delimited by space
                     "_"             delimited by space
                     ws-date         delimited by space
                     "_"             delimited by space
                     ws-time         delimited by space
                     "_"             delimited by space
                     processIdNum    delimited by space
                     "."             delimited by space
                     LOGextension    delimited by space
               into       EnvtVarValue
           *>perform      SetEnvtVar
      $ELSE
           initialize   EnvtVarValue move SOAPENVLOG to EnvtVarName
           perform GetEnvtVar
           if           EnvtVarValue not = spaces
                   continue        *> SOAPENVLOG set already
           else
             string  LOGDIRvalue     delimited by space
                     separator       delimited by space
                     AndTheCallerWas(1 : AndTheCallerWasLen - 1 )        [WSname]-  -> [WSname]
                                     delimited by space
                     "."             delimited by space
                     LOGextension    delimited by space
             into       EnvtVarValue
           end-if
           *>perform      SetEnvtVar
      $END-IF
           .
      *=================================================================
       doCBL-GET-OS-INFO section.
           move length                of CGOI_parameter-block
             to cblte-osi-length      of CGOI_parameter-block
           call CBL-GET-OS-INFO using    CGOI_parameter-block
                                returning       status-code
           evaluate cblte-osi-os-type of CGOI_parameter-block
           when 131
                  perform getPIDWindows
           when 128
                  perform gztPIDUNIX
           when other
                  move 999999 to processIdNum *> abnormal to go here!
           end-evaluate
           move   processId to  processIdNum
           .
      *=================================================================
       getPIDWindows section.
           call "_getpid" returning processId
           set  separatorWindows to true
           set  LSSEQterminatorWindows to true
           move 2 to LSSEQterminatorLen
           .
      *=================================================================
       gztPIDUNIX section.
           call "getpid"  returning processId
           set  separatorUnix to true
           set LSSEQterminatorUnix    to true
           move 1 to LSSEQterminatorLen
           .
      *=================================================================
       doCBL-DELETE-FILE section.
           *> Suppress file when it would exist
           call CBL-DELETE-FILE using EnvtVarValue
           .
      *=================================================================
       doCBL-CREATE-FILE section.
           set         fnf-access-write-88     to true
           set         fnf-deny-rdwrt-88       to true
           initialize  fnf-file-handle file-offset
           move EnvtVarValue to  EnvtVarValueWrk
      $IF DEBUG_DISPLAY defined
           perform getstrlenEnvtVarValueWrk
           display pfx CBL-CREATE-FILE " -> "
                                           EnvtVarValueWrk(1: strLenWrk)
                                           ": " with no advancing
      $END-IF
           call CBL-CREATE-FILE using      EnvtVarValueWrk
                                           fnf-access-type
                                           fnf-deny-type
                                           fnf-device
                                           fnf-file-handle
                                returning  status-code
           end-call
      $IF DEBUG_DISPLAY defined
         if status-code = 0 display OK display " "
         else               display KO status-code
                            display pfx KO  FATALERROR
                            display separ
                            perform SFATALERROR
         end-if
      $ELSE
         if status-code not = 0
                            display pfx CBL-CREATE-FILE ": "
                                        with no advancing
                            display pfx KO  FATALERROR
                            display separ
                            perform SFATALERROR
         end-if
      $END-IF

         IF status-code = 0
            accept ws-date from date YYYYMMDD
            accept ws-time from time

            initialize buffer
            string separ10     LSSEQterminator (1 : LSSEQterminatorLen)
                   separ        LSSEQterminator (1 : LSSEQterminatorLen)
                   pfx
                   "Log of consumption of Web Service: "
                   AndTheCallerWasSav(1 : MFreturn-buf-len - 1 )
                   " Date: " ws-date " Time: " ws-time
                               LSSEQterminator (1 : LSSEQterminatorLen)
                   separ       LSSEQterminator (1 : LSSEQterminatorLen)
                   separ10     LSSEQterminator (1 : LSSEQterminatorLen)
                               LSSEQterminator (1 : LSSEQterminatorLen)
            into buffer
            perform wrtToLogMsg
         end-if
         .
      *=================================================================
       doCBL-OPEN-FILE section.
           set         fnf-access-write-88     to true
           set         fnf-deny-rdwrt-88       to true
           initialize  fnf-file-handle file-offset
           move EnvtVarValue to  EnvtVarValueWrk
      $IF DEBUG_DISPLAY defined
         perform getstrlenEnvtVarValueWrk
         display pfx CBL-OPEN-FILE " -> "
                                           EnvtVarValueWrk(1: strLenWrk)
                                           ": " with no advancing
      $END-IF
           call CBL-OPEN-FILE   using      EnvtVarValueWrk
                                           fnf-access-type
                                           fnf-deny-type
                                           fnf-device
                                           fnf-file-handle
                                returning  status-code
           end-call
      $IF DEBUG_DISPLAY defined
         if status-code = 0 display OK display " "
                            set MsfInfo to true
         else               display KO status-code
                            display pfx KO  FATALERROR
                            display separ
                            perform SFATALERROR
         end-if
      $ELSE
         if status-code not = 0
                            display pfx CBL-OPEN-FILE ": "
                                        with no advancing
                            display pfx KO  FATALERROR
                            display separ
                            perform SFATALERROR
         end-if
      $END-IF
         perform doCBL-READ-FILE
         .
      *=================================================================
       doCBL-CLOSE-FILE section.
         move EnvtVarValue to  EnvtVarValueWrk
      $IF DEBUG_DISPLAY defined
         perform getstrlenEnvtVarValueWrk
         display pfx CBL-CLOSE-FILE " -> "
                                         EnvtVarValueWrk(1: strLenWrk)
                                         ": " with no advancing
      $END-IF
           call CBL-FLUSH-FILE using     fnf-file-handle
           call CBL-CLOSE-FILE using     fnf-file-handle
                               returning status-code
           end-call
           initialize fnf-file-handle
      $IF DEBUG_DISPLAY defined
         if status-code = 0 display OK display " "
         else               display KO status-code
                            display pfx KO  FATALERROR
                            display separ
                            perform SFATALERROR
         end-if
      $ELSE
         if status-code not = 0
                            display pfx CBL-CLOSE-FILE ": "
                                        with no advancing
                            display pfx KO  FATALERROR
                            display separ
                            perform SFATALERROR
         end-if
      $END-IF
         .
      *=================================================================
       doCBL-WRITE-FILE section.
      $IF DEBUG_DISPLAY defined
         display pfx CBL-WRITE-FILE " -> " "/" file-offset "/"
                                       with no advancing
      $END-IF
           move 0 to                     flagsbt
           call CBL-WRITE-FILE using     fnf-file-handle
                                         file-offset
                                         byte-count
                                         flagsbt
                                     by value ptrBufToWrt
                               returning status-code
           end-call
           add byte-count to file-offset
      $IF DEBUG_DISPLAY defined
         if status-code = 0
                            display OK "/" file-offset
                                       "/" byte-count "/"
                            display " "
         else               display KO status-code
                            display pfx KO  FATALERROR
                            display separ
                            perform SFATALERROR
         end-if
      $ELSE
         if status-code not = 0
                            display pfx CBL-WRITE-FILE ": "
                                        with no advancing
                            display pfx KO  FATALERROR
                            display separ
                            perform SFATALERROR
         end-if
      $END-IF
         .
      *=================================================================
       doCBL-READ-FILE section.
      $IF DEBUG_DISPLAY defined
         display pfx CBL-READ-FILE " -> "
                                       with no advancing
      $END-IF
           move 128 to                   flagsbt                          *> 128 Return the current file size in file-offset
           initialize                    file-offset byte-count
           call CBL-READ-FILE using      fnf-file-handle
                                         file-offset
                                         byte-count
                                         flagsbt
                                    by value 0 size 4   *> NULL PTR
                               returning status-code
           end-call
      $IF DEBUG_DISPLAY defined
         if status-code = 0 display OK "/" file-offset
                                       "/" byte-count "/"
                            display " "
         else               display KO status-code
                            display pfx KO  FATALERROR
                            display separ
                            perform SFATALERROR
         end-if
      $ELSE
         if status-code not = 0
                            display pfx CBL-READ-FILE ": "
                                        with no advancing
                            display pfx KO  FATALERROR
                            display separ
                            perform SFATALERROR
         end-if
      $END-IF
         .
      *=================================================================
       getstrlenEnvtVarValueWrk section.
         move function reverse(EnvtVarValueWrk) to EnvtVarValueWrk
         inspect EnvtVarValueWrk replacing leading spaces by low-value
         move function reverse(EnvtVarValueWrk) to EnvtVarValueWrk
         call "strlen" using   EnvtVarValueWrk returning strLEnWrk
         .
      $END-IF                                                             *> End   DEBUG_SOAPorJSON_HTTP defined !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      *=================================================================
      *=================================================================
      *=================================================================
      *=================================================================
      *=================================================================

       WhoIsTheCaller section.
           perform         WhoIsATheCallersFct0
                                                                         *>  CBL_GET_PROGRAM_INFO   return-code = 500 means
           perform *>until MFstatus-code not = 0                         *>  500 End of information (returned by function 2 when there is no caller of the currently associated
                   1 times                                               *>      program, or by function 5 when no more entry points exist).
                   perform WhoIsATheCallersFct2
           end-perform
           perform         WhoIsATheCallersFct3

           .
      *=================================================================
       WhoIsATheCallersFct0 section.
           set  MFfunction0 to true
           initialize      MFparam-block
           move length of  MFparam-block
                            to cblte-gpi-size    of MFparam-block
           move 1           to cblte-gpi-flags   of MFparam-block        *>  ReturnHandle
           add  2           to cblte-gpi-flags   of MFparam-block        *>  ReturnProgramName
           move length of                           MFreturn-buf
                            to                      MFreturn-buf-len
           call CBL-GET-PROGRAM-INFO
                       using by value               MFfunction
                              by reference          MFparam-block
                              by reference          MFreturn-buf
                              by reference          MFreturn-buf-len
                       returning                    MFstatus-code
      $IF DEBUG_DISPLAY DEFINED
           display pfx CBL-GET-PROGRAM-INFO "-> " MFstatus-code
                           " Fct " MFfunction ": "
           display "Current Program: " MFreturn-buf(1: MFreturn-buf-len)
      $END-IF
           .
      *=================================================================
       WhoIsATheCallersFct2 section.
           set  MFfunction2 to true                                      *>  GetCallingProgram
           move 2           to cblte-gpi-flags   of MFparam-block        *>  ReturnProgramName
           initialize                               MFreturn-buf
           move length of                           MFreturn-buf
                            to                      MFreturn-buf-len
           call CBL-GET-PROGRAM-INFO
                       using by value               MFfunction
                              by reference          MFparam-block
                              by reference          MFreturn-buf
                              by reference          MFreturn-buf-len
                       returning                    MFstatus-code
           if  MFstatus-code = 0
               initialize AndTheCallerWas
               move MFreturn-buf(1:MFreturn-buf-len) to AndTheCallerWas
           end-if
      $IF DEBUG_DISPLAY DEFINED
           display pfx CBL-GET-PROGRAM-INFO "-> " MFstatus-code
                           " Fct " MFfunction ": "
           display "Current Program: " MFreturn-buf(1: MFreturn-buf-len)
      $END-IF
          .
      *=================================================================
       WhoIsATheCallersFct3 section.
           set  MFfunction3 to true
           move length of                           MFreturn-buf
                            to                      MFreturn-buf-len
           call CBL-GET-PROGRAM-INFO
                       using by value               MFfunction
                              by reference          MFparam-block
                              by reference          MFreturn-buf
                              by reference          MFreturn-buf-len
                       returning                    MFstatus-code
      $IF DEBUG_DISPLAY DEFINED
           display pfx CBL-GET-PROGRAM-INFO "-> " MFstatus-code
                           " Fct " MFfunction ": "
      $END-IF
           .
      *=================================================================
       setAndTheCallerWasLen section.
           IF AndTheCallerWas = spaces or LOW-VALUE
               *> We would never reach this point
               display separ
               display pfx KO
                "This program should never be invoked in 'caller' mode"
               display pfx KO  FATALERROR
               display separ
               perform SFatalError
           END-IF

           move function reverse(AndTheCallerWas) to AndTheCallerWas
           inspect AndTheCallerWas replacing leading spaces by low-value
           move function reverse(AndTheCallerWas) to AndTheCallerWas
           call "strlen" using   AndTheCallerWas returning
                                                     AndTheCallerWasLen
           perform varying AndTheCallerWasLen
                           from AndTheCallerWasLen  by -1
                   until   AndTheCallerWas(AndTheCallerWasLen : 1 )
                               = "-"                                     *> [WSNAME]-APP | [WSNAME]-PROXY  -> [WSNAME]-
                   or      AndTheCallerWasLen = 1
           end-perform
           if              AndTheCallerWasLen = 1
                           display pfx KO  FATALERROR
                           display separ10
                           display pfx KO  "- not found in CALLER name"
                           display separ10
                           display separ
                           perform SFatalError
           end-if
           move AndTheCallerWasLen to MFreturn-buf-len
           .
      *=================================================================
       wrtToLogMsg section.
         move function reverse(buffer) to buffer
         inspect buffer replacing leading spaces by low-value
         move function reverse(buffer) to buffer
         call "strlen" using   buffer returning strLenWrk

      $IF DEBUG_SOAPorJSON_HTTP DEFINED
         IF NOT WSLOGEnvtValueSpace
           set ptrBufToWrt to address of buffer
           move strLenWrk  to byte-count
           perform doCBL-WRITE-FILE
         END-IF
      $END-IF

         if MsgFatalError  *> FATAL ERROR OCCURED
      $IF DEBUG_SOAPorJSON_HTTP DEFINED
               if fnf-file-handle not = 0 perform doCBL-CLOSE-FILE
               end-if
      $ELSE
               continue
      $END-IF
               display buffer(1 : strLenWrk)
               STOP RUN    *> PROCESSUS STOPPED HERE
         end-if
         .

