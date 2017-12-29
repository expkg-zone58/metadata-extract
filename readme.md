# expkg-zone58:image.metadata
An XQuery library to extract image metadata as XML using the 
[Drew Noakes library](http://drewnoakes.com/code/exif/)  
The output XML format matches the o/p of the [Xmlcalabash](http://xmlcalabash.com/) metadata extension. 
```
import module namespace imgmeta = "expkg-zone58:image.metadata" ;

declare variable $pic1:=resolve-uri("simple.jpg"); 
imgmeta:read($pic1)
<metadata>
  <tag name="Compression Type" dir="JPEG" type="0xfffffffd">Baseline</tag>
  <tag name="Data Precision" dir="JPEG" type="0x0000">8 bits</tag>
  <tag name="Image Height" dir="JPEG" type="0x0001">600 pixels</tag>
  <tag name="Image Width" dir="JPEG" type="0x0003">800 pixels</tag>
  <tag name="Number of Components" dir="JPEG" type="0x0005">3</tag>
  <tag name="Component 1" dir="JPEG" type="0x0006">Y component: Quantization table 0, Sampling factors 2 horiz/2 vert</tag>
  <tag name="Component 2" dir="JPEG" type="0x0007">Cb component: Quantization table 1, Sampling factors 1 horiz/1 vert</tag>
  <tag name="Component 3" dir="JPEG" type="0x0008">Cr component: Quantization table 1, Sampling factors 1 horiz/1 vert</tag>
  <tag name="JPEG Comment" dir="JpegComment" type="0x0000">AppleMark
</tag>
  <tag name="Make" dir="Exif IFD0" type="0x010f">Canon</tag>
  <tag name="Model" dir="Exif IFD0" type="0x0110">Canon PowerShot S330</tag>
  <tag name="Orientation" dir="Exif IFD0" type="0x0112">Top, left side (Horizontal / normal)</tag>
  <tag name="X Resolution" dir="Exif IFD0" type="0x011a">180 dots per inch</tag>
  <tag name="Y Resolution" dir="Exif IFD0" type="0x011b">180 dots per inch</tag>
  <tag name="Resolution Unit" dir="Exif IFD0" type="0x0128">Inch</tag>
  <tag name="Software" dir="Exif IFD0" type="0x0131">QuickTime 6.0.2</tag>
  <tag name="Date/Time" dir="Exif IFD0" type="0x0132">2002-11-18T22:46:09</tag>
  <tag name="Host Computer" dir="Exif IFD0" type="0x013c">Mac OS X 10.2.2</tag>
..
````


# Usage
````
import module namespace metadata = 'expkg-zone58:image.metadata';
metadata:read("C:\Users\andy\Desktop\russian.jpg")
````
Additionally functions are provided to process some common tags, such as GPS information.

# Installation
The library is packaged in the [EXpath](http://expath.org/spec/pkg) xar format with 
the DrewNoakes jars included (version 2.11.0) 
It is targeted at BaseX. It was tested against BaseX version 8.9.0 beta. 
It can be installed into the BaseX repository by executing:
````
"https://github.com/expkg-zone58/metadata-extract/releases/download/v1.2.4/metadata-extractor-1.2.4.xar"
=>repo:install()

````
# Versions
Basex 8.9+ requires metadata-extractor-1.2.x.xar +

# Tests
The `test.xqm` script uses the BaseX [Unit module](http://docs.basex.org/wiki/Unit_Module)
