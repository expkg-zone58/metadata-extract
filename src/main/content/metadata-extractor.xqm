xquery version "3.0" encoding "UTF-8";
(:~ return image metadata as xml using http://drewnoakes.com/code/exif/
 : usage: metadata:read('C:/temp/apic.jpg')
 : xml format based on xmlcalabash1
 : https://github.com/ndw/xmlcalabash1/blob/master/src/com/xmlcalabash/extensions/MetadataExtractor.java
 : includes utility functions for post processing some tags such as GPS information.
 : @author andy bunce
 :)
module namespace metadata = 'apb.image.metadata';
declare default function namespace 'apb.image.metadata'; 

declare namespace File="java:java.io.File";
declare namespace URL="java:java.net.URL";
declare namespace URLConnection="java.net.URLConnection";
declare namespace Tag="java:com.drew.metadata.Tag";
declare namespace ImageMetadataReader="java:com.drew.imaging.ImageMetadataReader";
declare namespace Metadata="java:com.drew.metadata.Metadata";
declare namespace Directory="java:com.drew.metadata.Directory";
declare namespace ArrayList="java:java.util.ArrayList";


(:~ extract metadata 
 : @param path source file
 : @result metadata wrapping set of tag elements with @name @dir @type attributes 
 :        and text containing value. empty if error
 :)
declare function read($path as xs:string) as element(metadata)
{
   try {
    <metadata>{tags($path)}</metadata>
   } catch * {
    <metadata error="{$err:description}"/> 
   }
};

declare function tags($path as xs:string) as element(tag)*
{
     let $src := src($path)
     let $meta:=ImageMetadataReader:readMetadata($src)
     let $dirs:=Metadata:getDirectories($meta)
     return java-for-each($dirs,dir#1)
};

(:~ tags in directory :)
declare %private function dir($dir) as element(tag)*
{
 let $tags:= Directory:getTags($dir)
 return java-for-each($tags,tag#1) 
};

(:~ extract a single tag :)
declare %private function tag($tag) as element(tag)
{
  try {
      let $name:=Tag:getTagName($tag)
      let $dir:=Tag:getDirectoryName($tag)
      let $type:=Tag:getTagTypeHex($tag)
      let $value:=(# db:checkstrings false #){
                clean-string(Tag:getDescription($tag))
                }  (: remove illegals :)
      let $value:=isodate($value) 
      return <tag name="{$name}" dir="{$dir}" type="{$type}">{$value}</tag>
  } catch * { 
     <tag error="{$err:description}"/> 
  }
};

(:~ file or stream for http
: http NOT WORKING
:)
declare %private function src($path){
  if(fn:starts-with($path,"http:/")) then 
      let $url:=URL:new($path)
      let $url:=fn:trace($url,"metadata src: ")
      return URL:openStream($url)
    
  else 
      let $path:=file:path-to-native($path)
      return File:new($path)
};

(:~ remove bad chars from java string
 : need more eg [^\x09\x0A\x0D\x20-\uD7FF\uE000-\uFFFD\u10000-u10FFFF]
 : @see http://stackoverflow.com/a/14323524
 :)
declare %private function clean-string($s){
    let $t:= fn:string-to-codepoints($s)
    let $t:=fn:filter($t,function($c as xs:integer){$c > 8})
    return fn:codepoints-to-string($t)
};

(:~ apply function fn to each item in java list thing :)
declare  %private function java-for-each($items,$fn)
{
   for $i in 0 to ArrayList:size($items) -1
   let $s:= ArrayList:get($items,xs:int($i))
   return $fn($s)
};

(:~ 
 :convert date like "2010:06:30 14:26:25" to iso format 
 :)
declare function isodate($value as xs:string) as xs:string
{
    if (fn:matches($value,"^\d\d\d\d:\d\d:\d\d \d\d:\d\d:\d\d$"))
    then fn:substring($value,1, 4) || "-" || fn:substring($value,6, 2) || "-" || fn:substring($value,9, 2) || "T" || fn:substring($value,12,8)
    else $value
};

(:~ 
 : convert degrees minutes seconds to decimal degrees
 : @param dms string like 45.0� 1.0' 46.32869861594543"
 :)
declare function geodecimal($dms as xs:string) as xs:double
{
  let $p:= fn:tokenize($dms," ")!fn:number(fn:substring(.,1,fn:string-length(.)-1))
  return fn:sum(fn:for-each-pair($p,(1,60,3600),function($a,$b){$a div $b}))
};


(:~ 
 :process gps elements 
 : @return geo tag with lat and long children
 :)
declare function geo($metadata as element(metadata)) as element(geo)?
{
 let $g:=function($name as xs:string){$metadata/tag[@name=$name and @dir="GPS"]}
 let $lat:=$g("GPS Latitude")
 return if($lat)
        then 
            let $lat:=geodecimal($lat)
            let $latr:=$g("GPS Latitude Ref")
            let $lat:=if($latr="N") then $lat else -$lat
            
            let $lng:=$g("GPS Longitude")
            let $lng:=geodecimal($lng)
            let $lngr:=$g("GPS Longitude Ref")
            let $lng:=if($lngr="E") then $lng else -$lng
            return <geo>
                       <latitude>{$lat}</latitude>
                       <longitude>{$lng}</longitude>
                    </geo>
        else
            ()       
};

(:~ 
 :extract keywords and split into seperate elements
 :)
declare function keywords($metadata as element(metadata)) as element(keywords)?
{
  let $keywords:=$metadata/tag[@name="Keywords" and @dir="Iptc"]
  return if($keywords)
         then <keywords>{
              for $k in fn:tokenize($keywords,";")
              return <keyword>{$k}</keyword>
              }</keywords>
          else ()
};


(:~ extract core stuff
 : width,height,datetaken,model,caption
 :)
declare function core($metadata as element(metadata)) as element()*
{
    let $d1:=$metadata/tag[@name="Date/Time" and @dir="Exif IFD0"]
    let $d2:=$metadata/tag[@name="Date/Time Original"  and @dir="Exif SubIFD"]
    let $d3:=$metadata/tag[@name="Date/Time Digitized" and @dir="Exif SubIFD" ]
    
    let $c:=$metadata/tag[@name="Caption/Abstract" and @dir="Iptc"]
    let $m:=$metadata/tag[@name="Model" and @dir="Exif IFD0"] 
    (: image size 
    : use get("Image Width","Jpeg") rather than
    : get("Exif Image Width","Exif SubIFD") because never found alone
    :)
    let $w:=$metadata/tag[@name="Image Width" and @dir="Jpeg"]/fn:substring-before(.," ")
    let $h:=$metadata/tag[@name="Image Height" and @dir="Jpeg"]/fn:substring-before(.," ")

    return (if($d1 castable as xs:dateTime) then <dateedit>{$d1/fn:string()}</dateedit> else (),
            if($d2 castable as xs:dateTime) then <datetaken>{$d2/fn:string()}</datetaken> else (),
            if($d3 castable as xs:dateTime) then <datedigitized>{$d3/fn:string()}</datedigitized> else (),
            if($c) then <caption>{$c/fn:string()}</caption> else (),
            if($m) then <model>{$m/fn:string()}</model> else (),
            if($w and $h)  then (<width>{$w}</width>,<height>{$h}</height>) else ()
            )
}; 