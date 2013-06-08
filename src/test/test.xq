(:~
 : unit tests for metadata module
 :)
import module namespace metadata = 'apb.image.metadata';

declare variable $pic1:=resolve-uri("simple.jpg"); 

(:~ Initializing function, which is called once before all tests. :)
declare
  %unit:before-module
  function local:before-all-tests() { ()
};
 
(:~ Initializing function, which is called once after all tests. :)
declare
  %unit:after-module
  function local:after-all-tests() { ()
};
 
(:~ Initializing function, which is called before each test. :)
declare
  %unit:before
  function local:before() { ()
};
 
(:~ Initializing function, which is called after each test. :)
declare
  %unit:after
  function local:after() { ()
};
 
(:~ we get tags :)
declare
  %unit:test
  function local:success-function() {
  let $meta:=metadata:read($pic1)
  return unit:assert($meta/tag)
};
  
(: run all tests  :)
unit:test() 