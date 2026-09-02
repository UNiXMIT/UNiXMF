      $set ooctrl(+P)
       id division.
       program-id.  cblMainProg.
       environment division.
       class-control.
           csSubProgClass is class '$OLE$csSubProg.csSubProg'.
       working-storage section.
       01 wscsSubClassObj      object reference.
       01 CobGroupPass.
          05  PicX10Pass       pic x(10).
          05  Int32Pass        pic x(04) comp-5.
       01 wsRetCode            pic s9(9) comp-5.
       procedure division.
           move 'ABCDEFGHIJ' to PicX10Pass
           move 987 to Int32Pass
           display '[in cblMainProg]'
           display 'PicX10Pass  = ' PicX10Pass 
           display 'Int32Pass   = ' Int32Pass  RL
           display space

           invoke csSubProgClass 'New'
              returning wscsSubClassObj
           end-invoke

           invoke wscsSubClassObj 'csEntryPoint'
              using by reference PicX10Pass
                    by reference Int32Pass
              returning wsRetCode
           end-invoke

           display space
           display '[returned to cblMainProg]'
           display 'PicX10Pass  = ' PicX10Pass
           display 'Int32Pass   = ' Int32Pass
           display 'wsRetCode  = ' wsRetCode
           display space
           
           stop 'press ENTER to end program. . .'
           goback.
