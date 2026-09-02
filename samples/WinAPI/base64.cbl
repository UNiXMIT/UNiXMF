       copy "windows.cpy".
      $SET SOURCEFORMAT"variable"
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BASE64.
      ******************************************************************
      *                                                                *
      *    BASE64 Demo.                                                *
      *    Demo on use of Win32 API to convert to/from BASE64 Encoding *
      *                                                                *
      ******************************************************************

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           CALL-CONVENTION 66 IS winapi.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  InputBytes PIC X(28) VALUE "This will be BASE64 encoded.".
       01  ws-buffer PIC X(1024).
       01  ws-Flags DWORD.
       88  CRYPT-STRING-BASE64    VALUE H"00000001".
       01  ws-FlagsOut DWORD.
       01  dwSkip DWORD.
       01  cbBinary DWORD.
       01  cbString DWORD.
       01  ws-bool BOOL.
       01  pp USAGE IS PROCEDURE-POINTER.
       01  ws-converted-back PIC X(1024).
       01  cbBack DWORD.

       PROCEDURE DIVISION.

           SET pp TO ENTRY "crypt32"    *> Load Windows api

           DISPLAY "You can check how large the BASE64 needs to be."

      **** First Make call to see how large the BASE64 string will be.
           SET CRYPT-STRING-BASE64 TO TRUE
           MOVE LENGTH OF InputBytes TO cbBinary
           MOVE LENGTH OF ws-buffer  TO cbString

           CALL winapi "CryptBinaryToStringA"
                USING BY REFERENCE InputBytes
                      BY VALUE     cbBinary
                      BY VALUE     ws-Flags
                      BY VALUE     0    *> If NULL will return size of output
                      BY REFERENCE cbString
                RETURNING ws-bool
           END-CALL

           PERFORM check-api

           DISPLAY "BASE64 String will be of size : " cbString
           DISPLAY " "
           DISPLAY "Now do the real call."
           DISPLAY " "

           SET CRYPT-STRING-BASE64 TO TRUE
           MOVE LENGTH OF InputBytes TO cbBinary
           MOVE LENGTH OF ws-buffer  TO cbString

           CALL winapi "CryptBinaryToStringA"
                USING BY REFERENCE InputBytes
                      BY VALUE     cbBinary
                      BY VALUE     ws-Flags
                      BY REFERENCE ws-buffer
                      BY REFERENCE cbString
                RETURNING ws-bool
           END-CALL

           PERFORM check-api

           DISPLAY "Data   : " InputBytes
           DISPLAY "    converted to"
           DISPLAY "BASE64 : " ws-buffer(1:cbString)
           DISPLAY "    now convert BASE64 back"

           MOVE LENGTH OF ws-converted-back TO cbBack

           CALL winapi "CryptStringToBinaryA"
                USING BY REFERENCE ws-buffer
                      BY VALUE     cbString
                      BY VALUE     ws-flags
                      BY REFERENCE ws-converted-back
                      BY REFERENCE cbBack
                      BY REFERENCE dwSkip
                      BY REFERENCE ws-FlagsOut
                RETURNING ws-bool
           END-CALL

           PERFORM check-api

      ***** Sanity check we get the same value back
           IF InputBytes = ws-converted-back(1:cbBack)
              DISPLAY "Success. Matched Input."
           ELSE
              DISPLAY "Failed. No match to Input."
           END-IF

           GOBACK.

       check-api SECTION.
           IF ws-bool = 0
              DISPLAY "API Failed!"
              STOP RUN
           END-IF.
