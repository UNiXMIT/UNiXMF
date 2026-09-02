       program-id. Maintenance.
       environment division.
       special-names.
           cursor is cursor-pos.
       input-output section.
       
       select master-file      assign to external mastfile
                               organization is indexed
        			           access mode is dynamic
                               lock mode is manual
                               record key is master-account
                               file status is file-status.
      
       data division.
       file section.
       fd master-file.
       01 master-record.
           05 master-account    		pic x(4).
           05 master-name        		pic x(30).
           05 master-address.
               10 master-street  		pic x(30).
               10 master-city      		pic x(30).
               10 master-state   		pic x(2).
               10 master-zip       		pic x(10).
           05 master-phone.
               10 master-phone-area     pic x(3).
               10 master-phone-prefix  	pic x(3).
               10 master-phone-base    	pic x(4).
               10 master-phone-ext      pic x(5).
           05 master-start-date.
               10 master-start-yyyy     pic x(4).
               10 master-start-mm     	pic x(2).
               10 master-start-dd       pic x(2).
           05 master-balance            pic s9(5)v99.
       
       working-storage section.
       01 file-status.
	      05 fs-byte1                 pic x value space.
          05 fs-byte2                 pic x comp-5 value zeros.
       01 user-option                 pic x value space.
       01 edited-balance              pic -$$$$$9.99.
       01 yes-no                      pic x value space.
       01 enter-key                   pic x value space.
	   01 menu-title                  pic x(30).
       01 validate                    pic x value spaces.
           88 valid-data              value "Y".
           88 not-valid               value "N".
	   01 updates                     pic x value "N".
	   01 updates-account             pic x(4).
       01 cursor-pos.
           05 cursor-line  pic 9(2).
           05 cursor-col  pic 9(2).
	   01 current-date.
		   05 date-yyyy               pic 9(4).
		   05 date-mm                 pic 9(2).
		   05 date-dd                 pic 9(2).
	   01 month-table.
		   05 month pic 9(2) occurs 12 times
                             value 31 28 31 30 31 30 31 31 30 31 30 31.
	   01 month-counter pic 9(2).
      
       screen section.
       01 main-menu.
           05 blank screen.
           05 line 01 column 35 "MAIN MENU".
           05 line 04 column 15 "1 = Add Customer".
           05 line 06 column 15 "2 = View Customer".
           05 line 08 column 15 "3 = Update Customer".
           05 line 04 column 45 "4 = Delete Customer".
           05 line 06 column 45 "9 = Quit".
           05 line 11 column 30 "Choose an Option - ".
           05 line 11 column 49 to user-option required auto.
      
       01 display-record.
           05 blank screen .
           05 line 01 column 30 from menu-title.
           05 line 04 column 01 "Account Number: ".
           05 line 04 column 17 pic 9(4) using master-account required.
           05 line 06 column 01 "Name: ".
           05 line 06 column 07 pic x(30) using master-name required.
           05 line 08 column 01 "Street: ".
           05 line 08 column 09 pic x(30) using master-street required.
           05 line 10 column 01 "City: ".
           05 line 10 column 07 pic x(30) using master-city required.
           05 line 12 column 01 "State: ".
           05 line 12 column 08 pic x(2) using master-state required.
           05 line 14 column 01 "Zip Code: ".
           05 line 14 column 11 pic x(10) using master-zip required.
           05 line 16 column 01 "Telephone: ".
           05 line 16 column 12 "(".
           05 line 16 column 13 pic 9(3) using master-phone-area required auto.
           05 line 16 column 16 ")".
           05 line 16 column 18 pic 9(3) using master-phone-prefix required auto.
           05 line 16 column 21 "-".
           05 line 16 column 22 pic 9(4) using master-phone-base required.
           05 line 18 column 01 "Extension: ".
           05 line 18 column 12 pic 9(5) using master-phone-ext.
           05 line 20 column 01 "Start Date YYYYMMDD: ".
           05 line 20 column 22 pic 9(4) using master-start-yyyy required auto.
           05 line 20 column 26 "-".
           05 line 20 column 27 pic 9(2) using master-start-mm required auto.
           05 line 20 column 29 "-".
           05 line 20 column 30 pic 9(2) using master-start-dd required.
           05 line 22 column 01 "Balance: ".
           05 line 22 column 10 pic $$$$$9.99CR using master-balance required.
		   05 line 24 column 20 "Tab to move between fields. Enter to submit.".
      
       procedure division.
	   declaratives.
       
       file-error-handling section.
		   use after exception procedure on master-file.

		   evaluate file-status
              when "10"
                 display "No more records found!" at 1030
			  when "30"
				 display "Permanent Error!" at 1030
			     accept enter-key
                 stop run
			  when "35"
				 display "File not found!" at 1030
			     accept enter-key
                 stop run
              when other
        	     if fs-byte1 = "9"
                    if fs-byte2 = 65
                       display "File locked!" at 1030
                    else
                       if fs-byte2 = 68
                          display "Record locked!" at 1030
                        else
                           display "Error: File Status = " at 1030 File-status at 1052
                           accept enter-key
                           stop run
                        end-if
                    end-if
                 else
                    display "Error: File Status = " at 1030 File-status at 1052
                    accept enter-key
                    stop run
                 end-if
           end-evaluate
           accept enter-key

	   end declaratives.
           perform 100-user-entry
           goback.
       
	   *> Displays the main screen and prompts the user to select an option 1, 2, 3, 4 or 9.
       100-user-entry.
           perform until exit
               perform 200-display-initialize
			   accept current-date from date yyyymmdd
               evaluate user-option
                   when 1
					   move "ADD CUSTOMER" to menu-title
                       perform 110-add
                   when 2
					   move "VIEW CUSTOMER" to menu-title
                       perform 120-view
                   when 3
					   move "UPDATE CUSTOMER" to menu-title
                       perform 130-update
                   when 4
					   move "DELETE CUSTOMER" to menu-title
                       perform 140-delete
                   when 9
                       display "Exiting Program!" at 1430
                       perform 210-sleep
                       exit perform
                   when other
                       display "Incorrect Option!" at 1430
                       perform 210-sleep
               end-evaluate
           end-perform.
       
	   *> Displays the blank record screen allowing the user to enter the customer information.
       110-add.
           perform until exit
			   move current-date to master-start-date
               display display-record
               accept display-record
               perform 300-validate
			   if valid-data
				   initialize yes-no
				   display "Are you sure you want to ADD the record? Y/N" at 2420 erase eos
                   accept yes-no at 2465
                   if yes-no = "Y" or "y"
                       perform 220-write
                       exit perform
                   else
                       if not (yes-no = "N" or "n")
                           display "Wrong Option, Try Again!" at 2420 erase eos
						   initialize yes-no
                           perform 210-sleep
                       else
                           exit perform
                       end-if
                   end-if
			   end-if
           end-perform.

	   *> Propmts the user to enter an account number then displays the information from file.
       120-view.
           display "Enter Account Number: " at 0625 erase
           accept master-account at 0647
           open input master-file
           read master-file key is master-account
               invalid key
                   display "Account doesn't exist!" at 0625 erase
                   display "Press enter to continue." at 0825
                   accept enter-key at 0850
               not invalid key
                   display display-record
                   display "Press Enter to Return to the Main Menu!" at 2420 erase eos
                   accept enter-key at 2460
           end-read
           close master-file.
       
	   *> Propmts the user to enter an account number, displays the information from file then allows
	   *> the user to update the information.
       130-update.
		   display "Enter Account Number: " at 0625 erase
           accept master-account at 0647
		   move master-account to updates-account
		   open i-o master-file
		   read master-file key is master-account
               invalid key
                   display "Account doesn't exist!" at 0625 erase
                   display "Press enter to continue." at 0825
                   accept enter-key at 0850
               not invalid key
                   perform 230-rewrite
           end-read
           close master-file.
       
	   *> Propmts the user to enter an account number, displays the information from file then propts the
	   *> user if they want to delete that account or not.
       140-delete.
		   display "Enter Account Number: " at 0625 erase
           accept master-account at 0647
           open i-o master-file
           read master-file key is master-account
               invalid key
                   display "Account doesn't exist!" at 0625 erase
                   display "Press enter to continue." at 0825
                   accept enter-key at 0850
               not invalid key
                   display display-record
                   perform 240-delete-confirm
           end-read
           close master-file.

       *> Initializes certain records to their defaults.
       200-display-initialize.
           initialize user-option master-record edited-balance yes-no enter-key validate cursor-pos
                      menu-title updates updates-account
           display main-menu
           accept main-menu.
       
	   *> Used when the user needs to see a message but doesn't need to press enter.
       210-sleep.
           call "CBL_THREAD_SLEEP" using by value 1500.
       
	   *> Opens the master-file i-o and writes the record if it doesn't exist.
       220-write.
           open i-o master-file
           write master-record
                 invalid key
                    display "Account already exists!" at 0625 erase
                    display "Press enter to continue." at 0825
                    accept enter-key at 0850
           end-write
           close master-file.

       *> Prompts the user to confirm if they want to update the record then rewrites the record if yes.
	   230-rewrite.
		   move 0607 to cursor-pos
		   perform until exit
               display display-record
               accept display-record
			   move "Y" to updates
               perform 300-validate
			   if valid-data
				   initialize yes-no
				   display "Are you sure you want to UPDATE the record? Y/N" at 2420 erase eos
                   accept yes-no at 2468
                   if yes-no = "Y" or "y"
					   rewrite master-record
                       exit perform
                   else
                       if not (yes-no = "N" or "n")
                           display "Wrong Option, Try Again!" at 2420 erase eos
						   initialize yes-no
                           perform 210-sleep
                       else
                           exit perform
                       end-if
                   end-if
			   end-if
           end-perform.
       
	   *> Propmts the user to confirm if they want to delete the record. Deletes the record if yes.
	   240-delete-confirm.
		   perform until exit
			     initialize yes-no
		         display "Are you sure you want to DELETE this record? Y/N" at 2420 erase eos
                       accept yes-no at 2469
                       if yes-no = "Y" or "y"
					      delete master-file
                           exit perform
                       else
                           if not (yes-no = "N" or "n")
                               display "Wrong Option, Try Again!" at 2420 erase eos
						       initialize yes-no
                               perform 210-sleep
                           else
                               exit perform
                           end-if
                       end-if
		   end-perform.
       
	   *> This is tha validation section used to make sure there are no fields left blank and that data
	   *> is valid i.e. a valid date. It also checks agaisnt the current date so it cannot be in the future.
       300-validate.
		   if updates = "Y"
			   if master-account not = updates-account
				   display "You cannot update the Account Number!" at 2420 erase eos
				   accept enter-key at 2460
                   move updates-account to master-account
				   move 0417 to cursor-pos
				   exit paragraph
			   end-if
		   end-if
           if master-account = spaces
               display "Account Number is required!" at 2420 erase eos
               accept enter-key at 2450
               move 0417 to cursor-pos
               exit paragraph
           end-if
           if master-name = spaces
               display "Name is required!" at 2420 erase eos
               accept enter-key at 2450
               move 0607 to cursor-pos
               exit paragraph
           end-if
		   if master-street = spaces
			   display "Street is required!" at 2420 erase eos
			   accept enter-key at 2450
			   move 0809 to cursor-pos
			   exit paragraph
		   end-if
		   if master-city = spaces
			   display "City is required!" at 2420 erase eos
			   accept enter-key at 2450
			   move 1007 to cursor-pos
			   exit paragraph
		   end-if
		   if master-state = spaces
			   display "State is required!" at 2420 erase eos
			   accept enter-key at 2450
			   move 1208 to cursor-pos
			   exit paragraph
		   end-if
		   if master-zip = spaces
			   display "Zip Code is required!" at 2420 erase eos
			   accept enter-key at 2450
			   move 1411 to cursor-pos
			   exit paragraph
		   end-if
		   if master-phone-area = spaces
			   display "Area Code is required!" at 2420 erase eos
			   accept enter-key at 2450
			   move 1613 to cursor-pos
			   exit paragraph
		   end-if
		   if master-phone-prefix = spaces
			   display "Phone Prefix is required!" at 2420 erase eos
			   accept enter-key at 2450
			   move 1618 to cursor-pos
			   exit paragraph
		   end-if
		   if master-phone-base = spaces
			   display "Phone Number is required!" at 2420 erase eos
			   accept enter-key at 2450
			   move 1622 to cursor-pos
			   exit paragraph
		   end-if
		   if master-start-yyyy = spaces
			   display "Year is required!" at 2420 erase eos
			   accept enter-key at 2450
			   move 2022 to cursor-pos
			   exit paragraph
		   end-if
		   if master-start-mm = spaces
			   display "Month is required!" at 2420 erase eos
			   accept enter-key at 2450
			   move 2027 to cursor-pos
			   exit paragraph
		   else
			   if master-start-mm > 12
			        display "Invalid month!" at 2420 erase eos
                    accept enter-key at 2450
			        move 2027 to cursor-pos
			        exit paragraph
			   end-if
		   end-if
		   if master-start-dd = spaces
			   display "Day is required!" at 2420 erase eos
			   accept enter-key at 2450
			   move 2030 to cursor-pos
			   exit paragraph
		   end-if
	       move master-start-mm to month-counter
		   if master-start-dd > month(month-counter)
			   display "Day can't be greater than " at 2420 erase eos month(month-counter) at 2446
			   accept enter-key at 2449
               move 2030 to cursor-pos
			   exit paragraph
		   end-if
		   if master-start-date > current-date
			   display "Date cannot be in the Future!" at 2420 erase eos
               accept enter-key at 2455
			   move 2022 to cursor-pos
			   exit paragraph
		   end-if
		   if master-balance = zeros or master-balance is negative
			   display "Balance cannot be negative or zero!" at 2420 erase eos
			   accept enter-key at 2455
			   move 2210 to cursor-pos
			   initialize master-balance
			   exit paragraph
		   end-if
           set valid-data to true.