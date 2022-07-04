(: create o/ps
 : xar package and xqdoc
 :)
declare namespace pkg="http://expath.org/ns/pkg";
import module namespace build = "quodatum.utils.build" at "buildx.xqm";
declare variable $base:=resolve-uri("../");
declare variable $res:=resolve-uri("../target/xar/");
declare variable $dest:=resolve-uri("../dist/");

(:~ 
 : the package definition as a pkg:package 
 :)
declare variable $package as element(pkg:package) :=doc(resolve-uri("expath-pkg.xml",$res))/pkg:package;

declare variable $content:=resolve-uri("content/",$res);
declare variable $dest-doc:=resolve-uri("doc/",$dest);


let $files:=build:files($res) 
let $name:= build:xar-name($package)

return (
         (: save xqdoc :) 
          build:files($content)!build:write-xqdoc(.,$content,$dest-doc),
          
         (: write xar file :)
          file:write-binary(
                 resolve-uri($name,$dest),
                 archive:create($files,$files!file:read-binary(fn:resolve-uri(.,$res)))
          ),
          
          (: update package.xml located at $cxan :)
           build:publish($package,resolve-uri("package.xml",$base))
 )
