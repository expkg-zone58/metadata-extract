xquery version "3.0" encoding "UTF-8";
(:~ Return metadata from image file as xml using the 
 :<a href="https://github.com/drewnoakes/metadata-extractor">http://drewnoakes.com/code/exif/</a> library.
 :<pre>
 : usage: 
 : <code>imgmeta:read('C:/temp/apic.jpg')</code>
 :</pre>
 : The xml format based on xmlcalabash1

 : includes utility functions for post processing some tags such as GPS information.
 : @author andy bunce
  : @see https://github.com/ndw/xmlcalabash1/blob/master/src/com/xmlcalabash/extensions/MetadataExtractor.java
  :@version 1.1.0
 :)
module namespace imgmeta = 'expkg-zone58:image.metadata';

declare namespace File="java:java.io.File";
declare namespace URL="java:java.net.URL";
declare namespace URLConnection="java.net.URLConnection";
declare namespace Tag="java:com.drew.metadata.Tag";
declare namespace ImageMetadataReader="java:com.drew.imaging.ImageMetadataReader";
declare namespace Metadata="java:com.drew.metadata.Metadata";
declare namespace Directory="java:com.drew.metadata.Directory";
declare namespace ArrayList="java:java.util.ArrayList";
declare namespace apb="java:org.apb.modules.TestModule";

(:~ Read image metadata from file, errors are supressed 
 : @param path source file
 : @result metadata wrapping set of tag elements with @name @dir @type attributes 
 :        and text containing value. empty if error
 :)
declare function imgmeta:read($path as xs:string) as element(metadata)
{
   try {
    <metadata>{imgmeta:tags($path)}</metadata>
   } catch * {
    <metadata error="{$err:code}">{$err:description}</metadata>
   }
};

(:~
 : Read image metadata from file
 : @return sequence of <code>tag</code> elements
 :)
declare function imgmeta:tags($path as xs:string) as element(tag)*
{
     let $src := imgmeta:src($path)
     let $meta:=ImageMetadataReader:readMetadata($src)
     let $dirs:=Metadata:getDirectories($meta)
     return imgmeta:java-for-each($dirs,imgmeta:dir#1)
};

(:~ Tags in directory :)
declare %private function imgmeta:dir($dir) as element(tag)*
{
 let $tags:= Directory:getTags($dir)
 return imgmeta:java-for-each($tags,imgmeta:tag#1) 
};

(:~ Extract a single tag :)
declare %private function imgmeta:tag($tag) as element(tag)
{
  try {
      let $name:=Tag:getTagName($tag)
      let $dir:=Tag:getDirectoryName($tag)
      let $type:=Tag:getTagTypeHex($tag)
      let $value:=(# db:checkstrings false #){
                Tag:getDescription($tag)
                }  (: remove illegals :)
      let $value:=imgmeta:isodate($value) 
      return <tag name="{$name}" dir="{$dir}" type="{$type}">{$value}</tag>
  } catch * { 
     <tag error="{$err:description}"/> 
  }
};

(:~ file or stream for http
: http NOT WORKING
:)
declare %private function imgmeta:src($path){
  if(fn:starts-with($path,"http:/")) then 
      let $url:=URL:new($path)
      let $url:=fn:trace($url,"metadata src: ")
      return URL:openStream($url)
    
  else 
      let $path:=file:path-to-native($path)
      return File:new($path)
};



(:~ apply function fn to each item in java list thing :)
declare  %private function imgmeta:java-for-each($items,$fn)
{
   let $a:=apb:makeCollection($items)
   for $i in 0 to ArrayList:size($a) -1
   let $s:= ArrayList:get($a,xs:int($i))
   return $fn($s)
};

(:~ 
 :Convert date like "2010:06:30 14:26:25" to iso format 
 :)
declare function imgmeta:isodate($value as xs:string) as xs:string
{
    if (fn:matches($value,"^\d\d\d\d:\d\d:\d\d \d\d:\d\d:\d\d$"))
    then fn:substring($value,1, 4) || "-" || fn:substring($value,6, 2) || "-" || fn:substring($value,9, 2) || "T" || fn:substring($value,12,8)
    else $value
};

(:~ 
 : Convert degrees minutes seconds to decimal degrees
 : @param dms string like 45.0� 1.0' 46.32869861594543"
 :)
declare function imgmeta:geodecimal($dms as xs:string) as xs:double
{
  let $p:= fn:tokenize($dms," ")!fn:number(fn:substring(.,1,fn:string-length(.)-1))
  return fn:sum(fn:for-each-pair($p,(1,60,3600),function($a,$b){$a div $b}))
};


(:~ 
 :Process gps elements 
 : @return geo tag with lat and long children
 :)
declare function imgmeta:geo($metadata as element(metadata)) as element(geo)?
{
 let $g:=function($name as xs:string){$metadata/tag[@name=$name and @dir="GPS"]}
 let $lat:=$g("GPS Latitude")
 return if($lat)
        then 
            let $lat:=imgmeta:geodecimal($lat)
            let $latr:=$g("GPS Latitude Ref")
            let $lat:=if($latr="N") then $lat else -$lat
            
            let $lng:=$g("GPS Longitude")
            let $lng:=imgmeta:geodecimal($lng)
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
 :Extract keywords and split into seperate elements
 : @return keyword elements wrapped in keywords
 :)
declare function imgmeta:keywords($metadata as element(metadata)) as element(keywords)?
{
  let $keywords:=$metadata/tag[@name="Keywords" and @dir="IPTC"]
  return if($keywords)
         then <keywords>{
              for $k in fn:tokenize($keywords,";")
              return <keyword>{$k}</keyword>
              }</keywords>
          else ()
};


(:~ Extract core stuff
 : width,height,datetaken,model,caption
 :)
declare function imgmeta:core($metadata as element(metadata)) as element()*
{
    let $d1:=$metadata/tag[@name="Date/Time" and @dir="Exif IFD0"]
    let $d2:=$metadata/tag[@name="Date/Time Original"  and @dir="Exif SubIFD"]
    let $d3:=$metadata/tag[@name="Date/Time Digitized" and @dir="Exif SubIFD" ]
    
    let $c:=$metadata/tag[@name="Caption/Abstract" and @dir="IPTC"]
    let $m:=$metadata/tag[@name="Make" and @dir="Exif IFD0"]
    let $m:=($m, $metadata/tag[@name="Model" and @dir="Exif IFD0"])  
    (: image size 
    : use get("Image Width","JPEG") rather than
    : get("Exif Image Width","Exif SubIFD") because never found alone
    :)
    let $w:=$metadata/tag[@name="Image Width" and @dir="JPEG"]/fn:substring-before(.," ")
    let $h:=$metadata/tag[@name="Image Height" and @dir="JPEG"]/fn:substring-before(.," ")

    return (if($d1 castable as xs:dateTime) then <dateedit>{$d1/fn:string()}</dateedit> else (),
            if($d2 castable as xs:dateTime) then <datetaken>{$d2/fn:string()}</datetaken> else (),
            if($d3 castable as xs:dateTime) then <datedigitized>{$d3/fn:string()}</datedigitized> else (),
            if($c) then <caption>{$c/fn:string()}</caption> else (),
            if($m) then <model>{string-join($m," ")}</model> else (),
            if($w and $h)  then (<width>{$w}</width>,<height>{$h}</height>) else ()   
            )
}; 