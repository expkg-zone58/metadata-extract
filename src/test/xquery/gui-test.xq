(:~
 : unit tests for metadata module
 :)

import module namespace metadata = "expkg-zone58:image.metadata"; 


declare variable $test:=resolve-uri("../resources/simple.jpg"); 

 metadata:tags($test)
 
