(:~
 : unit tests for metadata module
 :)

import module namespace metadata = "expkg-zone58:image.metadata" at "../main/content/metadata-extractor.xqm";


declare variable $pic1:=resolve-uri("simple.jpg"); 

 metadata:tags($pic1)
 
