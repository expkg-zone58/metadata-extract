# expkg-zone58.image.metadata
An XQuery library to extract image metadata as XML using the 
[Drew Noakes library](http://drewnoakes.com/code/exif/)  
The output xml format matches the o/p of the [Xmlcalabash](http://xmlcalabash.com/) metadata extension. 
````
<metadata>
 <tag name=".." dir=".." type="..">value</tag>
 <tag ..
</metadata>
````
BaseX 7.7 or greater is required.

# Usage
````
import module namespace metadata = 'expkg-zone58.image.metadata';
metadata:read("C:\Users\andy\Desktop\russian.jpg")
````
Additionally functions are provided to process some common tags, such as GPS information.

# Installation
The library is packaged in the [EXpath](http://expath.org/spec/pkg) xar format with 
the DrewNoakes jars included. 
It is targeted at BaseX. It requires at least BaseX 8.2 (because the expkg2012 format is used). 
It can be installed into the BaseX repository by executing:
````
let $zar:='https://github.com/expkg-zone58/metadata-extract/releases/download/v1.0.6/metadata-extractor-1.0.6.xar'
return repo:install($zar)
````
# Tests
The `test.xq` script uses the BaseX [Unit module](http://docs.basex.org/wiki/Unit_Module)
