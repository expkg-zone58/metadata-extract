(:~
 : unit tests for metadata module
 :)
module namespace test = 'http://basex.org/modules/xqunit-tests'; 

import module namespace metadata = "expkg-zone58:image.metadata";


 
(:~ we get tags :)
declare
  %unit:test
  function test:read() {
  let $meta:=test:meta("simple.jpg")
  return unit:assert($meta/tag)
};

(:~ we get core info :)
declare
  %unit:test
  function test:core() {
  let $meta:=test:meta("simple.jpg")
  return unit:assert(metadata:core($meta))
};

(:~ we get no keyword info :)
declare
  %unit:test
  function test:keywords() {
   let $meta:=test:meta("simple.jpg")
  return unit:assert(metadata:keywords($meta)=>fn:empty())
}; 
 
(:~ we get xmp info :)
declare
  %unit:test
  function test:xmp() {
   let $xmp:=test:image("IMG_3881.jpg")=>fetch:binary()=>metadata:xmp()
  return unit:assert($xmp=>fn:exists())
}; 
(:~ image path :)
declare
  function test:image($file as xs:string) {
 resolve-uri("../resources/" || $file) 
};  
(:~ image path :)
declare
  function test:meta($file as xs:string) {
 metadata:read(test:image($file) )
}; 