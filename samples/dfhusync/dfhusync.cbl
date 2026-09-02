       copy windows.cpy.
      $set sourceformat"variable" nocancel
      *set outdd"c:\temp\debug.log" shareoutdd
       identification division.
      *----------------------------------------------------------------*
      * dfhusync.                                                      *
      *----------------------------------------------------------------*
      ******************************************************************
      *   Process Recycle Exit
      *   --------------------
      *
      *   This exit will be called on Task Start.
      *
      *   This exit will check memory usage by the SEP and recycle 
      *   if the memory usage reaches defined thresholds set via 
      *   some environment variables.
      *
      *   MF_ES_TASKCHECK_MEMLIMIT_MB=1000
      *   This is the only required variable. It sets the limit that 
      *   SEP process memory can reach before the SEP is recycled.
      *   It will default to checking process working on every task.
      *   For example setting to 1000 will check for memory exceeding
      *   1GB (1000MB).
      *
      *   MF_ES_TASKCHECK_FREQUENCY=1
      *   This variable will configure the number of tasks between
      *   checks.
      *
      *   MF_ES_TASKCHECK_MEMLIMIT_DEBUG=YES
      *   This variable will output memory information every time a 
      *   check occurs.
      *
      *   MF_ES_TASKCHECK_MEMLIMIT_TYPE=WORKINGSET or PRIVATEBYTES
      *   This will configure if the exit will check working set or
      *   the private bytes allocated by the process.
      *
      *   A log file "MemoryLog.log" will be created in the region
      *   system folder.
      *
      *   If marked Dirty the SEP will terminate at end of task causing
      *   a fresh SEP to be spawned.
      *
      *   This module is an implementation of the dfhusync exit.
      *
      *   Author : 3rd Line Support Micro Focus
      *   Date   : January 2019
      *
      *
      *   January 2025 : Rocket Software Support
      *    
      *   Due to changed in product handling of SEP DIRTY the checks on
      *   memory are being moved to Task End rather than Task start.
      *   This will prevent long running tasks being killed.
      *
      ******************************************************************
       special-names.
           call-convention 74 is winapi.

       input-output section.

       file-control.
           select log-File
               assign to dynamic ws-file-name
               organization is line sequential
               lock mode is manual
               file status is ws-file-status.

       data division.
       file section.
       fd log-file.
       01 log-record                   pic x(133).

       working-storage section.
       01  ws-env-var                  pic x(20) value spaces.
       01  ws-disp-mem                 pic 9(10).
       01  ws-cics-task                pic 9(10).
       01  ws-disp-pb                  pic 9(10).
       01  ws-disp-ws                  pic 9(10).
       01  ws-memory-type              pic 9(9) comp-5.
           88  private-bytes           value 1.
           88  working-set             value 2.
       01  ws-memory-type              pic 9(9) comp-5.
           88  debug-exit              value 1.
           88  not-debug-exit          value 2.
       01  ws-task-check               pic 9(9) comp-5 value 0.
       01  ws-mem-limitMB              pic 9(18) comp-5 value 0.  
       01  ws-mem-limit                pic 9(18) comp-5 value 0.
       01  ws-disabled                   pic x   value "Y".
           88  exit-disabled                       value "Y".
           88  not-exit-disabled                   value "N".
       01  hCurrProcess                HANDLE.
       01  ws-retval                           BOOL.
       01  ws-mem-counters.
           03  ws-cb                           DWORD.
           03  ws-PageFaultCount               DWORD.
           03  ws-PeakWorkingSetSize           SIZE-T.
           03  ws-WorkingSetSize               SIZE-T.
           03  ws-QuotaPeakPagedPoolUsage      SIZE-T.
           03  ws-QuotaPagedPoolUsage          SIZE-T.
           03  ws-QuotaPeakNonPagedPoolUsage   SIZE-T.
           03  ws-QuotaNonPagedPoolUsage       SIZE-T.
           03  ws-PagefileUsage                SIZE-T.
           03  ws-PeakPagefileUsage            SIZE-T.
           03  ws-PrivateUsage                 SIZE-T.

       01  ws-error-message            pic x(50).

       *> --
       *> -- Note: This routine can not contain any CICS
       *> --       statements or be compiled using the CICS
       *> --       peprocessor.
       *> --

      $if p64 set
       78  78-ptrlen-X                     value 8.  *> for pic x(n)
       78  78-ptrlen-9                     value 18. *> for pic s9(n)
      $else
       78  78-ptrlen-X                     value 4.  *> for pic x(n)
       78  78-ptrlen-9                     value 9.  *> for pic s9(n)
      $end
       78  78-MAX-THREAD                   value 800.
       01  ws-first-time                   pic x   value "Y".
           88  first-time-in                       value "Y".
           88  not-first-time-in                   value "N".
       01  ws-file-status                  pic xx.
       01  ws-file-name                    pic x(255)
           value "$TXRDIR\Memorylog.log".
       01  uint-pointer   pic x(78-ptrlen-X) comp-5 is typedef.
       01  ws-work.
           02  ws-save-control-ptr         pointer.
       01  ws-count                    pic 9(9) comp-5 value 0.
       01  ws-pid                      DWORD.
       01  ws-pid-disp                 pic 9(10).
       01  ws-cntThreads-disp          pic 9(10).
       01  ws-date.
           03  ws-ccyy                 pic x(4).
           03  ws-mm                   pic xx.
           03  ws-dd                   pic xx.
       01  ws-date-disp.
           03  ws-ccyy-d               pic x(4).
           03  filler                  pic x value "-".
           03  ws-mm-d                 pic xx.
           03  filler                  pic x value "-".
           03  ws-dd-d                 pic xx.
       01  ws-time.
           03  ws-hh                   pic xx.
           03  ws-min                  pic xx.
           03  ws-sec                  pic xx.
           03  ws-huns                 pic xx.
       01  ws-time-disp.
           03  ws-hh-d                 pic xx.
           03  filler                  pic x    value ":".
           03  ws-min-d                pic xx.
           03  filler                  pic x    value ":".
           03  ws-sec-d                pic xx.
           03  filler                  pic x    value ":".
           03  ws-huns-d               pic xx.
       78  78-MAX-PATH                 value h"00000104".
       01  TH32CS-SNAPPROCESS          DWORD value h"00000002".
       01  HProcess                    DWORD.
       01  ws-bool                     BOOL.
       01  ws-pe32.
           03  dwSize                  DWORD.
           03  cntUsage                DWORD.
           03  th32ProcessID           DWORD.
           03  th32DefaultHeapID       ULONG.
           03  th32ModuleID            DWORD.
           03  cntThreads              DWORD.
           03  th32ParentProcessID     DWORD.
           03  pcPriClassBase          LONG.
           03  dwFlags                 DWORD.
           03  szExeFile.
               05  szExeFileX          pic x occurs 78-MAX-PATH.

       linkage section.

       01  cics-user-task-exit-control.

           10  cics-user-task-exit-pptr    procedure-pointer.

               *> --
               *> --       +------------------ start of task    
               *> --       |
               *> --       |+----------------- syncpoint
               *> --       ||
               *> --       ||+---------------- prepare
               *> --       |||
               *> --       |||+--------------- (not used)
               *> --       ||||
               *> --       ||||+-------------- (not used)
               *> --       |||||
               *> --       |||||+------------- (not used)
               *> --       ||||||
               *> --       ||||||+------------ (not used)
               *> --       |||||||
               *> --       |||||||+----------- (not used)
               *> --       ||||||||
               *> --       76543210
               *> --
               *> --
           10  cics-user-task-exit-ctl     pic x.
               88  cics-user-exit-on-start-88      value x'80'.
               88  cics-user-exit-on-sync-88       value x'40'.
               88  cics-user-exit-on-prep-88       value x'20'.
               88  cics-user-exit-on-both-88       value x'c0'.
               88  cics-user-exit-on-all-88        value x'e0'.
               88  cics-user-exit-on-2p-commit-88  value x'60'.
               88  cics-user-exit-none-88          value x'00'.

           10  cics-syncpoint-requestor    pic x   comp-x.
               88  cics-user-syncpoint-88          value 0.
               88  cics-task-syncpoint-88          value 1.
               88  cics-task-start-88              value 2.
               88  cics-initialization-88          value 254.
               88  cics-shutdown-88                value 255.

           10  cics-syncpoint-action       pic x   comp-x.
               88  cics-syncpoint-commit-88        value 0.
               88  cics-syncpoint-rollback-88      value 1.
               88  cics-syncpoint-prepare-88       value 2.

           10  cics-syncpoint-exception    pic x   comp-x.
               88  cics-syncpoint-normal-88        value 0.
               88  cics-syncpoint-failure-88       value 1.
               88  cics-syncpoint-rolledback-88    value 2.

           10  cics-user-task-number       uint-pointer.

       procedure division using cics-user-task-exit-control.

           *> -- This entry is called once on startup
      *    call "CBL_DEBUGBREAK"
           set cics-user-task-exit-pptr
                                       to entry 'userpvt'
      *    set cics-user-exit-on-all-88
      *                                to true
      ***** Limit when this exit will get called.
rstech*    set cics-user-exit-on-start-88 to true
rstech     set cics-user-exit-on-sync-88 to true
           set ws-save-control-ptr to address of
                                          cics-user-task-exit-control
           exit program
           .

       entry 'userpvt'.

           *> -- This entry is called per the "exit-on" flags.

           set address of cics-user-task-exit-control
                                       to ws-save-control-ptr

            if first-time-in
               if cics-user-task-number < 500  
                   call "CBL_DELETE_FILE" using ws-file-name
                   open output log-File  *> Clear Log on restart
                   close log-file        *> Use CICS Task to work
               end-if                    *> if system restarted.
               display "MF_ES_TASKCHECK_FREQUENCY" upon environment-name
               accept ws-env-var from environment-value
               if ws-env-var = spaces
                   move 1 to ws-task-check 
               else
                   move function numval-c(ws-env-var) to ws-task-check
                   if ws-task-check = 0 
                       move 1 to ws-task-check
                   end-if
               end-if
               display "MF_ES_TASKCHECK_MEMLIMIT_DEBUG" upon environment-name
               accept ws-env-var from environment-value
               if function upper-case(ws-env-var) = "YES"
                   set debug-exit to true
               else
                   set not-debug-exit to true
               end-if
               display "MF_ES_TASKCHECK_MEMLIMIT_TYPE" upon environment-name
               accept ws-env-var from environment-value
               evaluate true
                   when ws-env-var = "WORKINGSET"
                       set working-set to true
                   when ws-env-var = "PRIVATEBYTES"
                       set private-bytes to true
                   when other
                       set working-set to true  *> Default to the same as Task Manager
               end-evaluate
               display "MF_ES_TASKCHECK_MEMLIMIT_MB" upon environment-name
               accept ws-env-var from environment-value
               if ws-env-var = spaces
                   set exit-disabled to true
               else
                   move function numval(ws-env-var) to ws-mem-limitMB
                   if ws-mem-limitMB < 150
                       set exit-disabled to true
                   else
                       set not-exit-disabled to true
                       *> Get Current SEP Process Info
                       call winapi "GetCurrentProcess" returning hCurrProcess
                       call winapi "GetCurrentProcessId" returning ws-pid
                       *> Set Limit in Bytes
                       compute ws-mem-limit = ws-mem-limitMB * 1024 * 1024
                   end-if
               end-if
               set not-first-time-in to true
            end-if

           evaluate true

           when cics-user-syncpoint-88

               *> --
               *> -- Explicit user SYNCPOINT request
               *> --

               evaluate true

               when cics-syncpoint-commit-88  
                   *> -- set good return code
                   set cics-syncpoint-normal-88   
                                       to true

               when cics-syncpoint-rollback-88
                   *> -- set good return code
                   set cics-syncpoint-normal-88   
                                       to true

               when cics-syncpoint-prepare-88 
                   *> -- set good return code
                   set cics-syncpoint-normal-88   
                                       to true
               end-evaluate

           when cics-task-syncpoint-88

               *> --
               *> -- Implicit SYNCPOINT at end of task
               *> --

               evaluate true

               when cics-syncpoint-commit-88  
                   *> -- set good return code
                   set cics-syncpoint-normal-88   
                                       to true

               when cics-syncpoint-rollback-88
                   *> -- set good return code
                   set cics-syncpoint-normal-88   
                                       to true

               when cics-syncpoint-prepare-88 
                   *> -- set good return code
                   set cics-syncpoint-normal-88   
                                       to true
               end-evaluate
rstech         if not-exit-disabled
rstech             add 1 to ws-count
rstech             if (function mod(ws-count ws-task-check) = 0) *> Only check every n transaction
      *                perform thread-check
rstech                 perform memory-check
rstech*                CALL "CBL_DEBUGBREAK"
rstech                 move 0 to ws-count
rstech             end-if
rstech         end-if

           when cics-task-start-88
               *> -- Task start notification
      *        if cics-user-task-number = 50
      *            CALL "CBL_DEBUGBREAK"
      *        end-if
rstech*        if not-exit-disabled
rstech*            add 1 to ws-count
rstech*            if (function mod(ws-count ws-task-check) = 0) *> Only check every n transaction
      *                perform thread-check
rstech*                perform memory-check
rstech*                move 0 to ws-count
rstech*            end-if
rstech*        end-if
               continue

           when cics-initialization-88       
               *> -- CICS server initialization (before PLT PI)
               continue

           when cics-shutdown-88               
               *> -- CICS server shutdown (after PLT SD)
               continue

           end-evaluate

           exit program
           .

       thread-check section.

      ****** Enumerate Processes to find the current process.

           call winapi "CreateToolhelp32Snapshot"
               using by value TH32CS-SNAPPROCESS
                     by value 0 size 4
               returning HProcess
           end-call
           if HProcess = INVALID-HANDLE-VALUE
               goback *> Invalid. We will exit.
           end-if
           move all x"00" to ws-pe32
           move length of ws-pe32 to dwSize of ws-pe32

           call winapi "Process32First" using by value     hprocess 
                                              by reference ws-pe32
               returning ws-bool
           end-call
           if ws-bool = 1FALSE
               call winapi "CloseHandle" using by value hprocess
                   returning ws-bool
               end-call
               goback
           end-if

           call winapi "GetCurrentProcessId" returning ws-pid

           perform until exit
               if ws-pid = th32ProcessID of ws-pe32
                   exit perform
               end-if
               call winapi "Process32Next" using by value     hprocess 
                                                 by reference ws-pe32
                   returning ws-bool
               end-call
               if ws-bool = 1False
                   call winapi "CloseHandle" using by value hprocess
                       returning ws-bool
                   end-call
                   goback
               end-if
           end-perform

           call winapi "CloseHandle" using by value hprocess
               returning ws-bool
           end-call
           if ws-pid = th32ProcessID  *> This is the Current Process
                                      *> We can check the current thread
                                      *> count.
      *        display "Thread Count = " cntThreads of ws-pe32
               if cntThreads of ws-pe32 > 78-MAX-THREAD
                   CALL "mF_SetContDirty" *> Mark SEP Dirty
                                          *> ES will recycle at end
                                          *> of transaction.
                   perform log-recycle
               end-if
           end-if
           .

       log-recycle section.

           perform get-datetime

           move spaces      to log-record
           move ws-pid      to ws-pid-disp
           move cntThreads  to ws-cntThreads-disp
           string ws-date-disp 
                  " - " 
                  ws-time-disp
                  "  - DFHUSYNC : Detected High Thread Count of "
                  ws-cntThreads-disp
                  " in process " 
                  ws-pid-disp    delimited by size
               into log-record
           end-string
           perform write-log-file
           .


       memory-check section.

           call winapi "K32GetProcessMemoryInfo" using by value hCurrProcess
                                                       by reference ws-mem-counters

                                                       by value length of ws-mem-counters size 4
               returning ws-retval                                                             
           end-call
           if ws-retval = 0
               move "K32GetProcessMemoryInfo Error" to ws-error-message
               perform log-error
               set exit-disabled to true
               exit section *> Something went wrong. Exit Disabled
           end-if
           if debug-exit
               perform log-memory
           end-if
      ***** Check Memory Usage and Recycle if > Limit

           evaluate true
               when private-bytes
                   if ws-PrivateUsage > ws-mem-limit
      *                CALL "CBL_DEBUGBREAK"
                       CALL "mF_SetContDirty" *> Mark SEP Dirty
                                              *> ES will recycle at end
                                              *> of transaction.
                       perform log-memory-recycle
                   end-if
               when private-bytes
               when other
                   if ws-WorkingSetSize > ws-mem-limit
      *                CALL "CBL_DEBUGBREAK"
                       CALL "mF_SetContDirty" *> Mark SEP Dirty
                                              *> ES will recycle at end
                                              *> of transaction.
                       perform log-memory-recycle
                   end-if
           end-evaluate

           .

       log-memory-recycle section.

           perform get-datetime
           move spaces      to log-record
           move ws-pid      to ws-pid-disp
           compute ws-disp-pb = ws-PrivateUsage / (1024 * 1024)
           compute ws-disp-ws = ws-WorkingSetSize / (1024 * 1024)
           string ws-date-disp 
                  " - " 
                  ws-time-disp
                  "  - DFHUSYNC : High Memory Usage "
                  " -  WORKSET "     ws-disp-ws
                  " - PRIVATE "         ws-disp-pb
                  " in PID " ws-pid-disp
                  " : RECYCLE SEP" delimited by size
               into log-record 
           end-string
           perform write-log-file
           .


       log-message section.

           perform get-datetime
           move spaces      to log-record
           move ws-pid      to ws-pid-disp
           compute ws-disp-pb = ws-PrivateUsage / (1024 * 1024)
           compute ws-disp-ws = ws-WorkingSetSize / (1024 * 1024)
           string ws-date-disp 
                  " - " 
                  ws-time-disp
                  "  - DFHUSYNC : "
                  ws-error-message delimited by size
               into log-record 
           end-string
           perform write-log-file
           .


       log-error section.

           perform get-datetime
           move spaces      to log-record
           move ws-pid      to ws-pid-disp
           string ws-date-disp 
                  " - " 
                  ws-time-disp
                  "  - DFHUSYNC : PID " ws-pid-disp
                  " " ws-error-message " EXIT DISABLED IN PROCESS"
                  delimited by size
               into log-record
           end-string
           perform write-log-file 
           .

       get-datetime section.

           accept ws-date from date YYYYMMDD
           accept ws-time from time
           move ws-ccyy    to ws-ccyy-d
           move ws-mm      to ws-mm-d
           move ws-dd      to ws-dd-d
           move ws-hh      to ws-hh-d
           move ws-min     to ws-min-d
           move ws-sec     to ws-sec-d
           move ws-huns    to ws-huns-d
           .

       write-log-file section.

           open extend log-File
           if ws-file-status(1:1) not = 0 
               exit section
           end-if
           write log-record
           if ws-file-status(1:1) not = 0 
               exit section
           end-if
           close log-File
           .


       log-memory section. 
           perform get-datetime
           move spaces      to log-record
           move ws-pid      to ws-pid-disp
           move cics-user-task-number to ws-cics-task
           compute ws-disp-pb = ws-PrivateUsage / (1024 * 1024)
           compute ws-disp-ws = ws-WorkingSetSize / (1024 * 1024)
           string ws-date-disp
                  " - " 
                  ws-time-disp
                  " - " 
                  ws-time-disp
                  "  - DFHUSYNC : PID " ws-pid-disp
                  " - TASK "            ws-cics-task
                  " -  WORKINGSET "     ws-disp-ws
                  " - PRIVATE "         ws-disp-pb
                  delimited by size
               into log-record
           end-string
           perform write-log-file
           .

