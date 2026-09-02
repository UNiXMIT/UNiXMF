       copy "windows.cpy".
      $SET SOURCEFORMAT"variable"
       IDENTIFICATION DIVISION.
       PROGRAM-ID. REGISTRY.
      ******************************************************************
      *                                                                *
      *  This example demonstrates how to access and modify the system *
      *  Registry files using Windows API function calls.              *
      *                                                                *
      ******************************************************************

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           CALL-CONVENTION 66 IS winapi.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  key-handle PHKEY.
       01  key-value-buffer PIC X(100).
       01  key-value-type PIC X(4) COMP-5 VALUE ZEROES.        
       01  key-value-length PIC X(4) COMP-5 VALUE ZEROES.
       01  ws-bool BOOL.
       01  pp USAGE IS PROCEDURE-POINTER.

       PROCEDURE DIVISION.

           SET pp TO ENTRY "advapi32"

           CALL winapi RegCreateKeyExA
              USING BY VALUE       HKEY-CURRENT-USER
                    BY REFERENCE   z"TestKey"
                    BY VALUE       0
                    BY REFERENCE   0
                    BY VALUE       REG-OPTION-NON-VOLATILE
                    BY VALUE       KEY-ALL-ACCESS
                    BY VALUE       0        
                    BY REFERENCE   key-handle        
                    BY REFERENCE   0
              RETURNING ws-bool
           END-CALL

           PERFORM check-api

           CALL winapi RegSetValueEx
              USING BY VALUE          key-handle     
                    BY REFERENCE      z"StringValue" 
                    BY VALUE          0              
                    BY VALUE          REG-SZ         
                    BY REFERENCE      z"Hello"       
                    BY VALUE          6              
              RETURNING ws-bool
           END-CALL

           PERFORM check-api

           CALL winapi RegCloseKey
              USING BY VALUE key-handle
              RETURNING ws-bool
           END-CALL

           PERFORM check-api

           CALL winapi RegOpenKeyExA
                USING BY VALUE     HKEY-CURRENT-USER
                      BY REFERENCE z"TestKey"
                      BY VALUE     0
                      BY VALUE     KEY-ALL-ACCESS    
                      BY REFERENCE key-handle
                RETURNING ws-bool
           END-CALL

           PERFORM check-api

           MOVE LENGTH OF key-value-buffer TO key-value-length

           CALL winapi RegQueryValueExA
              USING BY VALUE       key-handle       
                    BY REFERENCE   z"StringValue"
                    BY VALUE       0                
                    BY REFERENCE   key-value-type
                    BY REFERENCE   key-value-buffer
                    BY REFERENCE   key-value-length    
              RETURNING ws-bool
           END-CALL

           PERFORM check-api

           DISPLAY "Value = " key-value-buffer(1:key-value-length)

           GOBACK.
       
       check-api SECTION.
           IF ws-bool NOT = 0
              DISPLAY "API Failed!"
              STOP RUN
           END-IF.
