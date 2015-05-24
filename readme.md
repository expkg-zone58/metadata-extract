# expkg-zone58.image.metadata
An XQuery library to extract image metadata as XML using the 
[Drewnoakes library](http://drewnoakes.com/code/exif/)  
The output format is the same as [Xmlcalabash](http://xmlcalabash.com/) metadata extension. 
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
the drewnoakes jars included. It can be installed into the BaseX repository by 
executing the command:
````
repo:install('http://apb2006.github.io/metadata-extract/dist/metadata-extractor.zar')
````
# Tests
The `test.xq` script uses the BaseX [Unit module](http://docs.basex.org/wiki/Unit_Module)
