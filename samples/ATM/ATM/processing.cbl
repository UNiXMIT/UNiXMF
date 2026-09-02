       program-id. processing.
	   environment division.
       input-output section.
       
       select master-file          assign to external mastfile
                                   organization is indexed
        			               access mode is dynamic
                                   record key is master-account
                                   file status is file-status.
       
	   select trans-file           assign to external tranfile
							       organization is line sequential
                                   file status is file-status.

       select receipt-file         assign to dynamic receipt-name
								   organization is line sequential
								   file status is file-status.

	   select sort-file            assign to "sortfile.dat"
                                   sort status is sort-status.

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

	   fd trans-file.
       01 trans-record.
           05 trans-account     		pic x(4).
           05 trans-date.
			   10 trans-year       		pic 9(4).
			   10 trans-month      		pic 9(2).
			   10 trans-day         	pic 9(2).
           05 trans-time.
               10 trans-hours        	pic 9(2).
               10 trans-minutes   		pic 9(2).
               10 trans-seconds   		pic 9(2).
               10 trans-hundreds 		pic 9(2).     
           05 trans-type        		pic x.
               88 trans-deposit    		value "D".
               88 trans-withdraw   		value "W".
           05 trans-amount   		    pic s9(5)v99.

       fd receipt-file.
	   01 receipt-record                pic x(80).

	   sd sort-file.
	   01 sort-record.
		   05 sort-account     		    pic x(4).
           05 sort-date.
               10 sort-year       		pic 9(4).
               10 sort-month      		pic 9(2).
               10 sort-day         	    pic 9(2).
           05 sort-time.
               10 sort-hours        	pic 9(2).
               10 sort-minutes   		pic 9(2).
               10 sort-seconds   		pic 9(2).
               10 sort-hundreds 		pic 9(2).     
           05 sort-type        		    pic x.
               88 sort-deposit    		value "D".
               88 sort-withdraw   		value "W".
           05 sort-amount   		    pic s9(5)v99.

       working-storage section.
	   01 file-status.
	      05 fs-byte1                   pic x value space.
          05 fs-byte2                   pic x comp-5 value zeros.
	   01 sort-status                   pic x(2) value spaces.
	   01 enter-key                     pic x value space.
	   01 receipt-counter               pic 99 value zero.
	   01 receipt-name                  pic x(13) value spaces.

	   01 print-heading.
		   05 filler                    pic x(30) value spaces.
		   05 filler                    pic x(20) value "Bank of Visual Cobol".
	   01 print-line-1.
		   05 filler                    pic x(9) value "Account: ".
		   05 print-account             pic x(4) value spaces.
	   01 print-line-2.
		   05 filler                    pic x(6) value "Date: ".
		   05 print-date.
			   10 print-day         	pic 9(2) value zeros.
			   10 filler                pic x value "/".
               10 print-month      		pic 9(2) value zeros.
			   10 filler                pic x value "/".
			   10 print-year       		pic 9(4) value zeros.
	   01 print-line-3.
		   05 filler                    pic x(6) value "Time: ".
           05 print-time.
               10 print-hours        	pic 9(2) value zeros.
			   10 filler                pic x value ":".
               10 print-minutes   		pic 9(2) value zeros.
			   10 filler                pic x value ":".
               10 print-seconds   		pic 9(2) value zeros.
	   01 print-line-4.
		   05 filler                    pic x(19) value "Transaction Type: ".
		   05 print-type                pic x value spaces.
	   01 print-line-5.
		   05 filler                    pic x(21) value "Transaction Amount: ".
		   05 print-amount              pic $$$,$$9.99 value zeros.
	   01 print-line-6.
		   05 filler                    pic x(18) value "Current Balance: ".
		   05 print-balance             pic $$$,$$9.99 value zeros.

	   linkage section.
	   01 ws-master-record.
		   05 ws-master-account    		pic x(4) value spaces.
           05 ws-master-name        	pic x(30) value spaces.
		   05 ws-master-balance         pic s9(5)v99 value zeros.

	   01 error-flag                    pic x value spaces.
		   88 valid                     value "Y".
		   88 not-valid                 value "N".
		   88 stop-run                  value "S".
	   01 error-message                 pic x(30) value spaces.
	   01 enter-amount                  pic s9(5)v99 value zeros.
	   01 receipt-required              pic x value spaces.

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

       procedure division.
	   declaratives.
       
       file-error-handling section.
		   use after exception procedure on master-file trans-file receipt-file.
		   evaluate file-status
              when "10"
                 move "No more records found!" to error-message
			  when "30"
				 move "Permanent Error!" to error-message
			     set stop-run to true
			  when "35"
				 move "File not found!" to error-message
			     set stop-run to true
              when other
        	     if fs-byte1 = "9"
                    if fs-byte2 = 65
                       move "File locked!" to error-message
                    else
                       if fs-byte2 = 68
                          move "Record locked!" to error-message
                        else
                           string "Error: File Status = " File-status into error-message
                           set stop-run to true
                        end-if
                    end-if
                 else
                    string "Error: File Status = " File-status into error-message
                    set stop-run to true
                 end-if
           end-evaluate
           goback.  

	   sort-error-handling section.
		   use after exception procedure on sort-file.

	   *> If a file status 35 (file not found) occurs because there have been no transactions
	   *> the declaratives section that deals with this changes the trans-count to 0.
	   *> trans-count counts the transactions so that the main program knows how many are going to be displayed.
		   evaluate sort-status
			  when "30"
				 move "Permanent Error!" to error-message
			     set stop-run to true
			     goback
		      when "35"
				 move 0 to trans-count
              when other
                 string "Error: Sort Status = " sort-status into error-message
                 set stop-run to true
				 goback
           end-evaluate.

	   end declaratives.

	   *> The entry point reading a record based on the ws-master-account from the main program.
	   *> If no account is found then not-valid is set and the main program knows how to handle it.
       100-read-record.
		   entry "initial" using ws-master-record error-flag error-message
		   move ws-master-account to master-account
							     
		   open input master-file
		   read master-file key is master-account
		       invalid key
                   set not-valid to true
			   not invalid key
				   set valid to true
				   move master-account to ws-master-account
				   move master-name to ws-master-name
				   move master-balance to ws-master-balance
           end-read
           close master-file
           goback.

	   *> The entry point for when the user requests a withdrawl. The users amount entered is checked in the main program.
	   *> The transaction type is set an the users amount is subtracted from their balance.
       *> From here the transaction update and receipt paragraphs are called.
	   110-withdrawl.
		   entry "withdrawl" using ws-master-record enter-amount receipt-required error-flag error-message
		   set trans-withdraw to true
		   open i-o master-file
		   read master-file key is master-account
			   not invalid key
				   subtract enter-amount from master-balance
				   rewrite master-record
				   move master-balance to ws-master-balance
		   end-read
	       close master-file
		   perform 200-update-transactions
           perform 210-receipt
           goback.
       
	   *> The entry point for when the user requests a deposit. The users amount entered is checked in the main program.
	   *> The transaction type is set and the users amount is added from their balance.
	   *> From here the transaction update and receipt paragraphs are called.
	   110-deposit.
		   entry "deposit" using ws-master-record enter-amount receipt-required error-flag error-message
		   set trans-deposit to true
		   open i-o master-file
		   read master-file key is master-account
			   not invalid key
				   add enter-amount to master-balance
				   rewrite master-record
				   move master-balance to ws-master-balance
		   end-read
	       close master-file
		   perform 200-update-transactions
           perform 210-receipt
           goback.

	   *> The entry point for when the users requests a transaction enquiry.
	   *> Transactions from trans-file are sorted accordingly.
	   *> Then the output procedure called for further sorting into a table.
	   120-transaction-enquiry.
		   entry "enquiry" using ws-master-record trans-count transactions error-flag error-message
		   sort sort-file on ascending key sort-account
						     descending key sort-date
						     descending key sort-time
                             using trans-file
                             output procedure is 240-read-transactions
           goback.
       
	   *> After a withdrawl or deposit the transaction file is updated with the details.
	   *> Current date and time of the transaction are written to the record.
	   200-update-transactions.
		   move master-account to trans-account
		   accept trans-date from date yyyymmdd
		   accept trans-time from time
		   move enter-amount to trans-amount
		   open extend trans-file
	           write trans-record
		   close trans-file.

	   *> If the user entered that they wanted a receipt then this paragraph is run.
	   *> The name of the file is created using STRING so that the number can be incremented.
	   210-receipt.
		   if receipt-required = "Y" or "y"
			   add 1 to receipt-counter
			   string  "receipt" delimited by size
				       receipt-counter delimited by size
					   ".dat" delimited by size
					   into receipt-name
			   end-string
			   perform 220-receipt-data
			   open output receipt-file
				   perform 230-receipt-print
			   close receipt-file
           end-if.

	   *> This is where the date for the receipt is moved from the transaction to the receipt fields.
	   220-receipt-data.
		   move master-account to print-account
		   move trans-day to print-day
		   move trans-month to print-month
		   move trans-year to print-year
		   move trans-hours to print-hours
		   move trans-minutes to print-minutes
		   move trans-seconds to print-seconds
		   move trans-type to print-type
		   move trans-amount to print-amount
		   move master-balance to print-balance.

	   *> This is the section that writes the report(receipt) using a preset layout in WS.
	   230-receipt-print.
		   write receipt-record from print-heading
           write receipt-record from print-line-1
			   after advancing 2 lines
		   write receipt-record from print-line-2
			   after advancing 2 lines
		   write receipt-record from print-line-3
			   after advancing 2 lines
		   write receipt-record from print-line-4
			   after advancing 2 lines
		   write receipt-record from print-line-5
			   after advancing 2 lines
		   write receipt-record from print-line-6
			   after advancing 2 lines.
       
	   *> This section reads the sorted file. It will return a maximum of 3 records.
	   *> If there are less than 3 transactions and the end is reached then trans-count keeps this info.
	   *> trans-count is passed back to the main program to help with displaying the right amount of records.
	   240-read-transactions.
		   perform until exit
			   return sort-file
				   at end
					   exit perform
				   not at end
		               if sort-account = ws-master-account and trans-count < 3
			               add 1 to trans-count
				           move sort-date to table-date(trans-count) 
				           move sort-time to table-time(trans-count)
				           move sort-type to table-type(trans-count)
				           move sort-amount to table-amount(trans-count)
                           if trans-count = 3
						        exit perform
                           end-if
					    end-if
			   end-return
		   end-perform.