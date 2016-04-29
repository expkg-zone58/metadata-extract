(:~
 : unit tests for metadata module
 :)
module namespace test = 'http://basex.org/modules/xqunit-tests'; 

import module namespace mp3agic = "expkg-zone58.audio.mp3" at "../main/content/mp3magic.xqm";

declare variable $test:mp3:=resolve-uri("v24tagswithalbumimage.mp3"); 
 
(:~ we get tags :)
declare
  %unit:test
  function test:success-function() {
  let $meta:=metadata:read($test:pic1)
  return unit:assert($meta/tag)
};
  
