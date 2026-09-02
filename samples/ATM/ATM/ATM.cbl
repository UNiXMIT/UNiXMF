       program-id. ATM.

	   data division.
	   working-storage section.
	   01 current-date.
		   05 date-yyyy                 pic 9(4).
		   05 date-mm                   pic 9(2).
		   05 date-dd                   pic 9(2).
	   01 enter-key                     pic x value space.
	   01 menu-title                    pic x(30) value spaces.
	   01 user-option                   pic x value space.
	   01 error-flag                    pic x value spaces.
		   88 valid                     value "Y".
		   88 not-valid                 value "N".
		   88 stop-run                  value "S".
	   01 error-message                 pic x(30) value spaces.
	   01 enter-amount                  pic s9(5)v99 value zeros.
	   01 receipt-required              pic x value space.

	   01 ws-master-record.
		   05 ws-master-account    		pic x(4) value spaces.
           05 ws-master-name        	pic x(30) value spaces.
		   05 ws-master-balance         pic s9(5)v99 value zeros.

	   01 trans-count                   pic 9 value zeros.
	   01 transactions.
	      05 transaction-table occurs 3 times indexed by trans-index.
		     10 table-date.
			   15 table-year            pic 9(4).
			   15 table-month           pic 9(2).
			   15 table-day             pic 9(2).
		     10 table-time.
               15 table-hours           pic 9(2).
               15 table-minutes         pic 9(2).
               15 table-seconds         pic 9(2).
               15 table-hundreds        pic 9(2).     
             10 table-type        	    pic x.
               88 table-deposit         value "D".
               88 table-withdraw        value "W".
             10 table-amount              pic -$$$$$9.99.


	   screen section.
	   01 welcome-screen.
		   05 blank screen.
		   05 line 01 column 33 "Welcome To".
		   05 line 03 column 26 "The Bank of Visual COBOL".
		   05 line 05 column 31 from date-dd.
		   05 line 05 column 34 "/".
		   05 line 05 column 36 from date-mm.
		   05 line 05 column 39 "/".
		   05 line 05 column 41 from date-yyyy.
		   05 line 09 column 20 "Please enter your Account Code to begin".
		   05 line 11 column 36 using ws-master-account.

	   01 main-menu.
		   05 blank screen.
		   05 line 01 column 30 "Welcome".
		   05 line 01 column 38 from ws-master-name.
		   05 line 04 column 15 "1 = Withdrawl".
		   05 line 06 column 15 "2 = Deposit".
	       05 line 08 column 15 "3 = Transaction Enquiry".
		   05 line 10 column 15 "4 = Quit".
		   05 line 13 column 15 "Choose an Option - ".
           05 line 13 column 34 to user-option required auto.

	   01 amount-screen.
		   05 blank screen.
		   05 line 01 column 35 from menu-title.
		   05 line 06 column 20 "Current Balance: ".
		   05 line 06 column 38 pic -$$$$$9.99 from ws-master-balance.
		   05 line 10 column 20 "Please Enter an Amount: ".
		   05 line 10 column 43 pic -$$$$$9.99 using enter-amount.
       
	   01 transaction-screen.
		   05 blank screen.
		   05 line 01 column 20 "Transaction Enquiry for ".
		   05 line 01 column 44 using ws-master-name.
		   05 line 06 column 18 "Date".
		   05 line 06 column 31 "Time".
		   05 line 06 column 42 "Type".
		   05 line 06 column 49 "Amount".
		   05 line 08 column 18 "----------".
		   05 line 08 column 31 "--------".
		   05 line 08 column 42 "----".
		   05 line 08 column 49 "----------".
		   05 line 10 column 18 from table-day(1).
           05 line 10 column 20 "/".
		   05 line 10 column 21 from table-month(1).
		   05 line 10 column 23 "/".
		   05 line 10 column 24 from table-year(1).
		   05 line 10 column 31 from table-hours(1).
		   05 line 10 column 33 ":".
		   05 line 10 column 34 from table-minutes(1).
		   05 line 10 column 36 ":".
		   05 line 10 column 37 from table-seconds(1).
		   05 line 10 column 42 from table-type(1).
		   05 line 10 column 49 pic -$$$$$9.99 using table-amount(1).
		   05 line 12 column 18 from table-day(2).
           05 line 12 column 20 "/".
		   05 line 12 column 21 from table-month(2).
		   05 line 12 column 23 "/".
		   05 line 12 column 24 from table-year(2).
		   05 line 12 column 31 from table-hours(2).
		   05 line 12 column 33 ":".
		   05 line 12 column 34 from table-minutes(2).
		   05 line 12 column 36 ":".
		   05 line 12 column 37 from table-seconds(2).
		   05 line 12 column 42 from table-type(2).
		   05 line 12 column 49 pic -$$$$$9.99 using table-amount(2).
		   05 line 14 column 18 from table-day(3).
           05 line 14 column 20 "/".
		   05 line 14 column 21 from table-month(3).
		   05 line 14 column 23 "/".
		   05 line 14 column 24 from table-year(3).
		   05 line 14 column 31 from table-hours(3).
		   05 line 14 column 33 ":".
		   05 line 14 column 34 from table-minutes(3).
		   05 line 14 column 36 ":".
		   05 line 14 column 37 from table-seconds(3).
		   05 line 14 column 42 from table-type(3).
		   05 line 14 column 49 pic -$$$$$9.99 using table-amount(3).

       procedure division.
		   
		   perform 100-display-welcome-screen

           goback.

	   *> Displays the welcome screen and allows the user to enter their account number.
	   *> Uses the current date in the header.
	   *> Error flag is returned from the sub program and idicates if the account exists or not.
	   100-display-welcome-screen.
		   perform until exit
			   initialize ws-master-record error-message error-flag
		       accept current-date from date yyyymmdd
		       display welcome-screen
		       accept welcome-screen
               if ws-master-account = 9999
                   exit perform
               else
				   call "initial" using ws-master-record error-flag error-message error-flag
				   perform 220-error-handling
				   if valid
                       perform 110-main-menu
				   else
					   display "Account doesn't exist!" at 0625 erase
                       display "Press enter to continue." at 0825
                       accept enter-key at 0850
				   end-if
			   end-if
		   end-perform.

	   *> Displays the main menu and shows the users options.
	   110-main-menu.
           perform until exit
		       display main-menu
               accept main-menu
               evaluate user-option
				   when "1"
					   perform 120-withdrawl
				   when "2"
					   perform 130-deposit
				   when "3"
					   perform 140-enquiry
				   when "4"
					   exit perform
				   when other
				   display "Wrong Option!" at 1515
				   display "Press Enter to Continue." at 1715
				   accept enter-key at 1740
			   end-evaluate
           end-perform.

	   *> Prompts the user to enter an amount to withdraw.
	   *> Checks whether they have enough money to withdraw that amount.
	   *> Amount entered cannon be a negative or zero.
	   120-withdrawl.
		   move "WITHDRAWL" to menu-title
		   perform until exit
			   initialize enter-amount receipt-required error-message error-flag
		       display amount-screen
		       accept amount-screen
               evaluate enter-amount
				   when <= 0
					   display "Amount cannot be zero or negative!" at 2420
					   accept enter-key at 2455
				   when > ws-master-balance
					   display "Insufficient Funds! Press Enter to Continue." at 2420
					   accept enter-key at 2465
					   exit perform
				   when other
					   perform 200-receipt-check
					   call "withdrawl" using ws-master-record enter-amount receipt-required error-message error-flag
					   perform 220-error-handling
					   exit perform
               end-evaluate
           end-perform.

       *> Prompts the user to enter an amount to deposit.
	   *> Amount entered cannot be negative or zero.
	   130-deposit.
		   move "DEPOSIT" to menu-title
		   perform until exit
			   initialize enter-amount receipt-required error-message error-flag
		       display amount-screen
		       accept amount-screen
               evaluate enter-amount
				   when <= 0
					   display "Amount cannot be zero or negative!" at 2420
					   accept enter-key at 2455
				   when other
					   if (enter-amount + ws-master-balance) >= 100000
						   display "Too much money. Open an ISA!" at 2420
						   accept enter-key at 2455
					   else
					       perform 200-receipt-check
					       call "deposit" using ws-master-record enter-amount receipt-required error-message error-flag
						   perform 220-error-handling
					       exit perform
					   end-if
               end-evaluate
           end-perform.
       
	   *> Clears the current info in the transaction table then calls the subprogram.
	   *> When the subprogram returns the transaction information (or not) the display paragraph is called.
	   140-enquiry.
		   initialize trans-count transactions error-message error-flag
		   call "enquiry" using ws-master-record trans-count transactions error-message error-flag
		   perform 220-error-handling
           perform 210-display-transaction-screen.  

	   *> Prompts the user asking if they would like a receipt.
	   200-receipt-check.
		   perform until exit
		       display "Would you like a receipt? Y/N" at 2420
		       accept receipt-required at 2450
			   if receipt-required = "Y" or "y"
                   exit perform
               else
                   if not (receipt-required = "N" or "n")
                       display "Wrong Option, Try Again!" at 2420 erase eos
					   initialize receipt-required
                       accept enter-key at 2445
                   else
                       exit perform
                   end-if
               end-if
           end-perform.

       *> Evaluates the trans-count to see how many transactions there were.
	   *> Handles the screen if there are less than 3 or no transactions so that
	   *> no blank or zeros are shown for no transactions.
	   *> It then displays the available transactions.
	   210-display-transaction-screen.
		   evaluate trans-count
			   when <= 0
				   display "No Transactions Recorded!" at 0625 erase
			       display "Press Enter to Continue." at 0825
			       accept enter-key at 0850
		       when 1
		           display transaction-screen
		           display "Press Enter to Continue." at 1218 erase eos
			       accept enter-key at 1443
			   when 2
				   display transaction-screen
		           display "Press Enter to Continue." at 1418 erase eos
			       accept enter-key at 1443
			   when 3
				   display transaction-screen
		           display "Press Enter to Continue." at 1618 erase eos
			       accept enter-key at 1643
		   end-evaluate.

       220-error-handling.
		   if not (error-message = spaces)
			   display error-message at 2420 erase eos
			   accept enter-key at 2455
			   if stop-run
				   stop run
			   end-if
		   end-if.
