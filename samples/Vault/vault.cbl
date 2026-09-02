      $SET CONSTANT OS "Windows"
       IDENTIFICATION DIVISION.
       PROGRAM-ID.                      vault.
       AUTHOR.  MIT. 
      * cbllink (-d) sample.cbl
      * cob (-z) sample.cbl 
      *
      * mfsecretsadmin write Rocket/MFMIT/MYPASSW strongPassword123
      *

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

       DATA DIVISION.
       FILE SECTION.

       WORKING-STORAGE SECTION.
       78  MAXSECRETLENGTH             VALUE 256.
       77  SECRETDELIM                 PIC X VALUE '/'.

       01  secretsHandler              PROCEDURE-POINTER.
       01  MfsaOpenVault               PROCEDURE-POINTER.
       01  MfsaReadSecret              PROCEDURE-POINTER.
       01  MfsaCloseVault              PROCEDURE-POINTER.
       01  secretsHandle               POINTER.
       01  secretKey                   PIC X(256).
       01  namingConvention            PIC X(256).
       01  secretBufferSize            PIC 9(9) COMP-5 VALUE
                                               MAXSECRETLENGTH.                                                    
       01  secretOutLen                PIC 9(9) COMP-5.
       01  secretBuffer                PIC X(MAXSECRETLENGTH).
       01  errorCode                   PIC 9(9) COMP-5.

       01  vaultValue                  PIC X(256) VALUE SPACES.

       01  nullPointer                 POINTER value NULL.
       01  config-info                 POINTER value NULL.
       
       01  returnCode              pic 9(4) comp-5.
       01  reasonCode              pic 9(4) comp-5.
       
       LINKAGE SECTION.

       PROCEDURE DIVISION.
           
           PERFORM SETUP-VAULT
           PERFORM OPEN-VAULT
           PERFORM INIT-VAULT
           PERFORM READ-VAULT
           DISPLAY vaultValue(1:secretOutLen)
           PERFORM CLOSE-VAULT
           GOBACK.

           
       
       SETUP-VAULT SECTION.
      $IF OS = "Windows"
           set secretsHandler to entry "mfSecretsAPI"
      $ELSE
      $    IF P64 SET
           set secretsHandler to entry "mfsecretsapi64"
      $    ELSE
          set secretsHandler to entry "mfsecretsapi"
      $    END
      $END

           if secretsHandler = null
               move 1 to returnCode
               move 1 to reasonCode
               goback
           end-if

           *> Get entry points for secrets API functions
           set MfsaOpenVault to entry "MfsaOpenVault"
           if MfsaOpenVault = null
               move 2 to returnCode
               move 1 to reasonCode
               goback
           end-if

           set MfsaReadSecret to entry "MfsaReadSecret"
           if MfsaReadSecret = null
               move 2 to returnCode
               move 2 to reasonCode
               goback
           end-if

           set MfsaCloseVault to entry "MfsaCloseVault"
           if MfsaCloseVault = null
               move 2 to returnCode
               move 3 to reasonCode
               goback
           end-if
           exit.

       OPEN-VAULT SECTION.
           *> Open the secrets vault
           call MfsaOpenVault using by value nullPointer*>default vault
                                    by reference secretsHandle
                                    by reference nullPointer*>no logging
                                    by reference config-info
                          returning errorCode
           if errorCode not = 0
               move 3 to returnCode
               move errorCode to reasonCode
               goback
           end-if
           exit.

       INIT-VAULT SECTION.
           initialize namingConvention
           string
             "Rocket" delimited size
             SECRETDELIM delimited size
             "MFMIT" delimited size
             SECRETDELIM delimited size
             "MYPASSW" delimited space
             into namingConvention
           end-string
           exit.
       
       READ-VAULT SECTION.
           move all x"00" to secretKey
           string
             namingConvention delimited space
             x"0" delimited size
             into secretKey
           end-string
           call MfsaReadSecret using by value secretsHandle
                                     by reference secretKey
                                     by value secretBufferSize
                                     by reference secretBuffer
                                     by reference secretOutLen
                           returning errorCode
           if errorCode = 0
               move x"00" to secretBuffer(secretOutLen + 1:1)
               move spaces to vaultValue
               string
                 secretBuffer delimited x"0"
                 x"0" delimited size
                 into vaultValue
               end-string
           else
               move 5 to returnCode
               move errorCode to reasonCode
               goback
           end-if
           exit.

       CLOSE-VAULT SECTION.
           call MfsaCloseVault using by value secretsHandle
                           returning errorCode
           if errorCode not = 0
               move 5 to returnCode
               move errorCode to reasonCode
               goback
           end-if
           exit.