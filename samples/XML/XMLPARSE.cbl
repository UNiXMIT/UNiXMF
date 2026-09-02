      $SET SOURCEFORMAT(VARIABLE)
      $SET XMLPARSE(COMPAT) 
       ID DIVISION.
       PROGRAM-ID. XMLPARSE.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 XML-DOCUMENT.
         02 VALUE '<?xml version="1.0"?>'.
         02 VALUE x'0D0A'.
         02 VALUE '<PVDM_LoadDocInfoEx>'.

         02 VALUE '<DOC DOCID="112930">'.
         02 VALUE '<FILELISTS>'.
         02 VALUE '&lt;DOCFILES&gt;'.
      
         02 VALUE '&lt;FILE&gt;'.
         02 VALUE '&lt;FILENUM&gt;'.
         02 VALUE '1&lt;/FILENUM&gt;'.
         02 VALUE '&lt;PATH&gt;'.
         02 VALUE '51860013\IMG1\00008\00008905.TIF&lt;/PATH&gt;'.
         02 VALUE '&lt;SHA256_HASH&gt;'.
         02 VALUE '3054D824C04EDCD6FFE420560DD1C1650339754F46BA22311ECC562EC7FDF1DA&lt;/SHA256_HASH&gt;'.
         02 VALUE '&lt;SIZE_BYTES&gt;'.
         02 VALUE '13299&lt;/SIZE_BYTES&gt;'.
         02 VALUE '&lt;/FILE&gt;'.

         02 VALUE '&lt;FILE&gt;'.
         02 VALUE '&lt;FILENUM&gt;'.
         02 VALUE '2&lt;/FILENUM&gt;'.
         02 VALUE '&lt;PATH&gt;'.
         02 VALUE '51860013\IMG1\00008\00008906.TIF&lt;/PATH&gt;'.
         02 VALUE '&lt;SHA256_HASH&gt;'.
         02 VALUE '5FBDCB6070E7077352DCD261378C4EEE6ABB16EE00FC304D54371B7B6CE04E3B&lt;/SHA256_HASH&gt;'.
         02 VALUE '&lt;SIZE_BYTES&gt;'.
         02 VALUE '34166&lt;/SIZE_BYTES&gt;'.
         02 VALUE '&lt;/FILE&gt;'.
       
         02 VALUE '&lt;FILE&gt;'.
         02 VALUE '&lt;FILENUM&gt;'.
         02 VALUE '3&lt;/FILENUM&gt;'.
         02 VALUE '&lt;PATH&gt;'.
         02 VALUE '51860013\IMG1\00008\00008907.TIF&lt;/PATH&gt;'.
         02 VALUE '&lt;SHA256_HASH&gt;'.
         02 VALUE 'E03672CCBB474062ACEC5779D6016F261AAC8B4AAE1E353F191A8D183E7A0CA3&lt;/SHA256_HASH&gt;'.
         02 VALUE '&lt;SIZE_BYTES&gt;'.
         02 VALUE '135364&lt;/SIZE_BYTES&gt;'.
         02 VALUE '&lt;/FILE&gt;'.
       
         02 VALUE '&lt;FILE&gt;'.
         02 VALUE '&lt;FILENUM&gt;'.
         02 VALUE '4&lt;/FILENUM&gt;'.
         02 VALUE '&lt;PATH&gt;'.
         02 VALUE '51860013\IMG1\00008\00008908.TIF&lt;/PATH&gt;'.
         02 VALUE '&lt;SHA256_HASH&gt;'.
         02 VALUE '806325AA2771BE055469BF7FA16D45069E9DD0CAC519C72A8DBDF72D51DD5880&lt;/SHA256_HASH&gt;'.
         02 VALUE '&lt;SIZE_BYTES&gt;'.
         02 VALUE '55576&lt;/SIZE_BYTES&gt;'.
         02 VALUE '&lt;/FILE&gt;'.
       
         02 VALUE '&lt;FILE&gt;'.
         02 VALUE '&lt;FILENUM&gt;'.
         02 VALUE '5&lt;/FILENUM&gt;'.
         02 VALUE '&lt;PATH&gt;'.
         02 VALUE '51860013\IMG1\00008\00008909.TIF&lt;/PATH&gt;'.
         02 VALUE '&lt;SHA256_HASH&gt;'.
         02 VALUE 'A1421F4769F8953C3ABA7D084462D2BDC2B6BE4D161517B548AFAB0219A54E21&lt;/SHA256_HASH&gt;'.
         02 VALUE '&lt;SIZE_BYTES&gt;'.
         02 VALUE '35602&lt;/SIZE_BYTES&gt;'.
         02 VALUE '&lt;/FILE&gt;'.
       
         02 VALUE '&lt;FILE&gt;'.
         02 VALUE '&lt;FILENUM&gt;'.
         02 VALUE '6&lt;/FILENUM&gt;'.
         02 VALUE '&lt;PATH&gt;'.
         02 VALUE '51860013\IMG1\00008\00008910.TIF&lt;/PATH&gt;'.
         02 VALUE '&lt;SHA256_HASH&gt;'.
         02 VALUE 'C95748249503E7FC2101D44E13E965E17D4873FFD726C02E3A6CF12AEC7257C2&lt;/SHA256_HASH&gt;'.
         02 VALUE '&lt;SIZE_BYTES&gt;'.
         02 VALUE '36928&lt;/SIZE_BYTES&gt;'.
         02 VALUE '&lt;/FILE&gt;'.
       
         02 VALUE '&lt;FILE&gt;'.
         02 VALUE '&lt;FILENUM&gt;'.
         02 VALUE '7&lt;/FILENUM&gt;'.
         02 VALUE '&lt;PATH&gt;'.
         02 VALUE '51860013\IMG1\00008\00008911.TIF&lt;/PATH&gt;'.
         02 VALUE '&lt;SHA256_HASH&gt;'.
         02 VALUE '63862B5B0D669F97D19818863E0FC8703A078A524752B86353789F6D13627A37&lt;/SHA256_HASH&gt;'.
         02 VALUE '&lt;SIZE_BYTES&gt;'.
         02 VALUE '36656&lt;/SIZE_BYTES&gt;'.
         02 VALUE '&lt;/FILE&gt;'.
       
         02 VALUE '&lt;FILE&gt;'.
         02 VALUE '&lt;FILENUM&gt;'.
         02 VALUE '8&lt;/FILENUM&gt;'.
         02 VALUE '&lt;PATH&gt;'.
         02 VALUE '51860013\IMG1\00008\00008912.TIF&lt;/PATH&gt;'.
         02 VALUE '&lt;SHA256_HASH&gt;'.
         02 VALUE 'FE5F7F614A2C02A64A1559984BAD589FF0CBE370DE0DB1CA9B9E83491CD13E89&lt;/SHA256_HASH&gt;'.
         02 VALUE '&lt;SIZE_BYTES&gt;'.
         02 VALUE '47427&lt;/SIZE_BYTES&gt;'.
         02 VALUE '&lt;/FILE&gt;'.
       
         02 VALUE '&lt;FILE&gt;'.
         02 VALUE '&lt;FILENUM&gt;'.
         02 VALUE '9&lt;/FILENUM&gt;'.
         02 VALUE '&lt;PATH&gt;'.
         02 VALUE '51860013\IMG1\00008\00008913.TIF&lt;/PATH&gt;'.
         02 VALUE '&lt;SHA256_HASH&gt;'.
         02 VALUE '2BA57A97E19EA39462FFB1D84BAF4C9C46B690F1B9BBE2D9B7528144B0D131A6&lt;/SHA256_HASH&gt;'.
         02 VALUE '&lt;SIZE_BYTES&gt;'.
         02 VALUE '44866&lt;/SIZE_BYTES&gt;'.
         02 VALUE '&lt;/FILE&gt;'.
       
         02 VALUE '&lt;FILE&gt;'.
         02 VALUE '&lt;FILENUM&gt;'.
         02 VALUE '10&lt;/FILENUM&gt;'.
         02 VALUE '&lt;PATH&gt;'.
         02 VALUE '51860013\IMG1\00008\00008914.TIF&lt;/PATH&gt;'.
         02 VALUE '&lt;SHA256_HASH&gt;'.
         02 VALUE 'B1AE0318A76A5328252E5CD15B35C9F072CBD4DD13A9E634C8FB2EE69E3B9377&lt;/SHA256_HASH&gt;'.
         02 VALUE '&lt;SIZE_BYTES&gt;'.
         02 VALUE '59601&lt;/SIZE_BYTES&gt;'.
         02 VALUE '&lt;/FILE&gt;'.
       
         02 VALUE '&lt;FILE&gt;'.
         02 VALUE '&lt;FILENUM&gt;'.
         02 VALUE '11&lt;/FILENUM&gt;'.
         02 VALUE '&lt;PATH&gt;'.
         02 VALUE '51860013\IMG1\00008\00008915.TIF&lt;/PATH&gt;'.
         02 VALUE '&lt;SHA256_HASH&gt;'.
         02 VALUE '447FF8EF203611E4CE3C2212C139561B807E84AF49926E1B9586A693A004524B&lt;/SHA256_HASH&gt;'.
         02 VALUE '&lt;SIZE_BYTES&gt;'.
         02 VALUE '78477&lt;/SIZE_BYTES&gt;'.
         02 VALUE '&lt;/FILE&gt;'.
       
         02 VALUE '&lt;FILE&gt;'.
         02 VALUE '&lt;FILENUM&gt;'.
         02 VALUE '12&lt;/FILENUM&gt;'.
         02 VALUE '&lt;PATH&gt;'.
         02 VALUE '51860013\IMG1\00008\00008916.TIF&lt;/PATH&gt;'.
         02 VALUE '&lt;SHA256_HASH&gt;'.
         02 VALUE '7A0B2AD84C5E0AB4B8849D5571292774007CA9D9267EC69E2B2BABBCBBB80D56&lt;/SHA256_HASH&gt;'.
         02 VALUE '&lt;SIZE_BYTES&gt;'.
         02 VALUE '56198&lt;/SIZE_BYTES&gt;'.
         02 VALUE '&lt;/FILE&gt;'.
       
         02 VALUE '&lt;FILE&gt;'.
         02 VALUE '&lt;FILENUM&gt;'.
         02 VALUE '13&lt;/FILENUM&gt;'.
         02 VALUE '&lt;PATH&gt;'.
         02 VALUE '51860013\IMG1\00008\00008917.TIF&lt;/PATH&gt;'.
         02 VALUE '&lt;SHA256_HASH&gt;'.
         02 VALUE 'E51A738711780591F8FF32A9CF2A5B5614488807ADADAEFBAF6083E7008F5362&lt;/SHA256_HASH&gt;'.
         02 VALUE '&lt;SIZE_BYTES&gt;'.
         02 VALUE '56550&lt;/SIZE_BYTES&gt;'.
         02 VALUE '&lt;/FILE&gt;'.
       
         02 VALUE '&lt;FILE&gt;'.
         02 VALUE '&lt;FILENUM&gt;'.
         02 VALUE '14&lt;/FILENUM&gt;'.
         02 VALUE '&lt;PATH&gt;'.
         02 VALUE '51860013\IMG1\00008\00008918.TIF&lt;/PATH&gt;'.
         02 VALUE '&lt;SHA256_HASH&gt;'.
         02 VALUE 'E19C367A1089332F3B9CA383CBECBC83C2DB5CEC6EE9BBE63C74ACB85C7D8385&lt;/SHA256_HASH&gt;'.
         02 VALUE '&lt;SIZE_BYTES&gt;'.
         02 VALUE '53353&lt;/SIZE_BYTES&gt;'.
         02 VALUE '&lt;/FILE&gt;'.
       
         02 VALUE '&lt;FILE&gt;'.
         02 VALUE '&lt;FILENUM&gt;'.
         02 VALUE '15&lt;/FILENUM&gt;'.
         02 VALUE '&lt;PATH&gt;'.
         02 VALUE '51860013\IMG1\00008\00008919.TIF&lt;/PATH&gt;'.
         02 VALUE '&lt;SHA256_HASH&gt;'.
         02 VALUE '95193C1D4314706E62861DE322095521E77A0151DE6058816E49330D51566A76&lt;/SHA256_HASH&gt;'.
         02 VALUE '&lt;SIZE_BYTES&gt;'.
         02 VALUE '12581&lt;/SIZE_BYTES&gt;'.
         02 VALUE '&lt;/FILE&gt;'.

         02 VALUE '&lt;/DOCFILES&gt;'.
         02 VALUE '</FILELISTS>'.

         02 VALUE '</DOC>'.
         02 VALUE '</PVDM_LoadDocInfoEx>'.
         02 VALUE x'0D0A'.
         02 VALUE x'00'.

       01 XML-DOCUMENT-LENGTH          PIC 9(9).
       01 CURRENT-ELEMENT              PIC X(30).

       PROCEDURE DIVISION.

           XML PARSE XML-DOCUMENT PROCESSING PROCEDURE 100-XML-HANDLER
           ON EXCEPTION
             DISPLAY 'XML document error ' XML-CODE
           NOT ON EXCEPTION
             DISPLAY 'XML document successfully parsed'
           END-XML

           goback.

       100-XML-HANDLER.

           EVALUATE XML-EVENT
      *    Order XML events. Most frequent first.
             WHEN 'START-OF-ELEMENT'
               DISPLAY 'Start element tag: <' XML-TEXT '>'
               MOVE XML-TEXT TO CURRENT-ELEMENT
             WHEN 'CONTENT-CHARACTERS'
               DISPLAY 'Content characters: <' XML-TEXT '>'
             WHEN 'END-OF-ELEMENT'
               DISPLAY 'End element tag: <' XML-TEXT '>'
               MOVE spaces TO CURRENT-ELEMENT
             WHEN 'START-OF-DOCUMENT'
               compute XML-DOCUMENT-LENGTH = function length(XML-TEXT)
               DISPLAY 'Start of document: length= ' XML-DOCUMENT-LENGTH ' characters.'
             WHEN 'END-OF-DOCUMENT'
               DISPLAY 'End of document.'
             WHEN 'VERSION-INFORMATION'
               DISPLAY 'Version: <' XML-TEXT '>'
             WHEN 'ENCODING-DECLARATION'
               DISPLAY 'Encoding: <' XML-TEXT '>'
             WHEN 'STANDALONE-DECLARATION'
               DISPLAY 'Standalone: <' XML-TEXT '>'
             WHEN 'ATTRIBUTE-NAME'
               DISPLAY 'Attribute name: <' XML-TEXT '>'
             WHEN 'ATTRIBUTE-CHARACTERS'
               DISPLAY 'Attribute value characters: <' XML-TEXT '>'
             WHEN 'ATTRIBUTE-CHARACTER'
               DISPLAY 'Attribute value character: <' XML-TEXT '>'
             WHEN 'START-OF-CDATA-SECTION'
               DISPLAY 'Start of CData: <' XML-TEXT '>'
             WHEN 'END-OF-CDATA-SECTION'
               DISPLAY 'End of CData: <' XML-TEXT '>'
             WHEN 'CONTENT-CHARACTER'
               DISPLAY 'Content character: <' XML-TEXT '>'
             WHEN 'PROCESSING-INSTRUCTION-TARGET'
               DISPLAY 'PI target: <' XML-TEXT '>'
             WHEN 'PROCESSING-INSTRUCTION-DATA'
               DISPLAY 'PI data: <' XML-TEXT '>'
             WHEN 'COMMENT'
               DISPLAY 'Comment: <' XML-TEXT '>'
             WHEN 'EXCEPTION'
               COMPUTE XML-DOCUMENT-LENGTH = FUNCTION LENGTH(XML-TEXT)
               DISPLAY 'Exception ' XML-CODE ' at offset' XML-DOCUMENT-LENGTH '.'
             WHEN OTHER
               DISPLAY 'Unexpected XML event: ' XML-EVENT '.'
           END-EVALUATE.
