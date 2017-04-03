(:~
 : unit tests for metadata module
 :)
module namespace test = 'http://basex.org/modules/xqunit-tests'; 

import module namespace metadata = "expkg-zone58:image.metadata" at "../main/content/metadata-extractor.xqm";
declare variable $test:pic1:=resolve-uri("simple.jpg"); 

 
(:~ we get tags :)
declare
  %unit:test
  function test:read() {
  let $meta:=metadata:read($test:pic1)
  return unit:assert($meta/tag)
};
  
