import module namespace metadata = 'apb.image.metadata';

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
 
(:~ Function demonstrating a successful test. :)
declare
  %unit:test
  function local:success-function() {
  unit:assert(1 + 2 = 3)
};
 
(:~ Function demonstrating a failure. :)
declare
  %unit:test
  function local:failure-function() {
  unit:assert(4 + 5 = 6)
};
 
(:~ Function demonstrating an expected error. :)
declare
  %unit:test("expected", "FORG0001")
  function local:expected-success() {
  ()
};
 
(:~ Function demonstrating an expected error. :)
declare
  %unit:test("expected", "FORG0001")
  function local:expected-error() {
  1 + <a/>
};
 
(:~ Function demonstrating an error. :)
declare
  %unit:test
  function local:error-function() {
  1 + <a/>
};
 
(:~ Skipping a test. :)
declare
  %unit:test %unit:ignore("Skipped!")
  function local:skipped-function() {
  ()
};
 
(: run all tests :)
unit:test()