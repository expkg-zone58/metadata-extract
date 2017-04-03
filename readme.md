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
BaseX 8.2.1+ required.

# Usage
````
import module namespace metadata = 'expkg-zone58:image.metadata';
metadata:read("C:\Users\andy\Desktop\russian.jpg")
````
Additionally functions are provided to process some common tags, such as GPS information.

# Installation
The library is packaged in the [EXpath](http://expath.org/spec/pkg) xar format with 
the DrewNoakes jars included (version 2.10) 
It is targeted at BaseX. It was tested against BaseX version 8.6.2. 
It can be installed into the BaseX repository by executing:
````
"https://github.com/expkg-zone58/metadata-extract/releases/download/v1.0.9/metadata-extractor-1.0.10.xar"
=>repo:install()

````

# Tests
The `test.xqm` script uses the BaseX [Unit module](http://docs.basex.org/wiki/Unit_Module)
