       IDENTIFICATION DIVISION.
      *
       PROGRAM-ID.  PrintRoutines.

       ENVIRONMENT DIVISION.
       SPECIAL-NAMES.
           CONSOLE IS CRT.
      *
       INPUT-OUTPUT SECTION.
      *
       FILE-CONTROL.
      *
       SELECT myfile ASSIGN TO PRINTER
           organization is line sequential
           file status is dat-sta.
      *
       DATA DIVISION.
      *
       FILE SECTION.
      *
       FD myfile.
         01 print-record PIC X(80).
        
      /
      *
       WORKING-STORAGE SECTION.
      *
       01  PROGRAMM      PIC X(14)  VALUE "*par-09-01 *".
      *
       01 DAT-STA PIC XX.
       01 my-printer.
          03 my-printer-length PIC X(2) comp-5 value 40.
          03 my-printer-name PIC X(40)
              value "Microsoft Print to PDF".
       01 document-title.
          03 document-length PIC X(2) comp-5 value 18.
          03 document-text PIC X(18) value "MF Test-Print".
       01 status-code pic S9(9) comp-5.
       01 PR-HAN pic X(4) comp-5 value 0.
       01 FLAGS PIC X(4) COMP-5.
       01 WIN-HAN PIC X(4) COMP-5 value 0.
       01 my-font.
         03 FONT-LEN PIC X(2) COMP-5 VALUE 5.
         03 FONT-NA PIC X(16) VALUE "Arial".
       01 FONT-SIZE PIC X(4) COMP-5.
       01 FONT-STYLE PIC X(4) COMP-5.
          88 style-italic Value 1.
          88 style-underline value 2.
          88 style-strikeout value 4.
          88 style-bold value 8.
       01 set-options PIC X(4) COMP-5.
       01 new-x PIC X(4) COMP-5.
       01 new-y PIC X(4) COMP-5.
       01 PR-COM PIC X(4) COMP-5 VALUE 4.
       01 PROPER.
         03 pp-papersize PIC S9(4) COMP-5.
       01 DRAW-RE PIC X(4) COMP-5.
       01 BOX-STYLE PIC X(4) COMP-5.
       01 START-X PIC X(4) COMP-5.
       01 START-Y PIC X(4) COMP-5.
       01 END-X PIC X(4) COMP-5.
       01 END-Y PIC X(4) COMP-5.
       
      *
       PROCEDURE DIVISION.
       WORK SECTION.
       LIZENZ-ABFRAGE.
 
           MOVE 12 TO FONT-SIZE.
           move 8 to FONT-STYLE.
      *    set style-bold to true.
           CALL "PC_PRINTER_DEFAULT_FONT" USING my-font
                                                BY VALUE FONT-SIZE   
                                                BY VALUE FONT-STYLE
                                      RETURNING status-code.
           PERFORM Fehler.
      *    MOVE 3 to FLAGS.
           move 0 to FLAGS.
      *    move 8 to FLAGS.
           CALL "PC_PRINTER_OPEN" USING PR-HAN
                                        document-title
                                        BY VALUE FLAGS
                                        BY VALUE WIN-HAN
                              RETURNING status-code.
 
           PERFORM Fehler.
           PERFORM SetPen
           MOVE 0 TO DRAW-RE.
           MOVE 1 TO BOX-STYLE.
           MOVE 40 TO START-X.
           MOVE 150 TO END-X.
           MOVE 200 TO START-Y.
           MOVE 420 TO END-Y.
           CALL "PC_PRINTER_DRAW_RECTANGLE" USING By VALUE PR-HAN
                                                  BY VALUE DRAW-RE
                                                  BY VALUE BOX-STYLE
                                                  BY VALUE START-X
                                                  BY VALUE START-Y
                                                  BY VALUE END-X
                                                  BY VALUE END-Y
           returning status-code.
           MOVE 3 TO PR-COM.
           CALL "PC_PRINTER_CONTROL" USING PR-HAN
                                           BY VALUE PR-COM
                                 RETURNING status-code.
           PERFORM Fehler.
           CALL "PC_PRINTER_WRITE" USING PR-HAN
                                         print-record
                                         BY VALUE 80
                               RETURNING status-code.
           PERFORM Fehler.

           CALL "PC_PRINTER_CLOSE" USING PR-HAN
                               RETURNING status-code.
       goback.

       Fehler.
           if status-code not = 0
             then
               display "file Status = " status-code
               if pr-han not = 0
                   call "PC_PRINTER_CLOSE" Using PR-HAN
                                       returning status-code
              end-if
           goback
         end-if.

       SetPen.
             call "PC_PRINTER_SET_PEN" using by value pr-han
                                             by value 10  *> Width
                                             by value 0   *> Style = solid
                                             by value 255 *> Red
                                             by value 0   *> Green
                                             by value 127 *> Blue
         end program PrintRoutines.
           
