/*
 * BaseX Metadata-extract interface
 * @author andy bunce
 * @copyright Quodatum Ltd
 * @date 2017
 * @licence Apache 2
 */
package org.expkgzone58.image;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;

import org.basex.query.QueryException;
import org.basex.query.QueryModule;
import org.basex.query.value.Value;
import org.basex.query.value.ValueBuilder;
import org.basex.query.value.item.B64Lazy;
import org.basex.query.value.node.FElem;

import com.adobe.xmp.XMPException;
import com.adobe.xmp.XMPIterator;
import com.adobe.xmp.XMPMeta;
import com.adobe.xmp.properties.XMPPropertyInfo;
import com.drew.imaging.ImageMetadataReader;
import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.xmp.XmpDirectory;

public class Metadata extends QueryModule {

    /**
     * @returns sequence of tag elements with @path for each xmp item
     * @throws QueryException
     * @throws ImageProcessingException
     * 
     */
    public Value xmp(final B64Lazy inputStream)
            throws XMPException, IOException, QueryException, ImageProcessingException {
        // Extract metadata from the image
        ByteArrayInputStream imageStream = new ByteArrayInputStream(inputStream.binary(null));
        com.drew.metadata.Metadata metadata = ImageMetadataReader.readMetadata(imageStream);
        ValueBuilder vb = new ValueBuilder();
        // Iterate through any XMP directories we may have received
        for (XmpDirectory xmpDirectory : metadata.getDirectoriesOfType(XmpDirectory.class)) {

            // Usually with metadata-extractor, you iterate a directory's tags.
            // However XMP has
            // a complex structure with many potentially unknown properties.
            // This doesn't map
            // well to metadata-extractor's directory-and-tag model.
            //
            // If you need to use XMP data, access the XMPMeta object directly.
            XMPMeta xmpMeta = xmpDirectory.getXMPMeta();
            String name=xmpDirectory.getName();
            XMPIterator itr = xmpMeta.iterator();
            // Iterate XMP properties
            while (itr.hasNext()) {

                XMPPropertyInfo property = (XMPPropertyInfo) itr.next();

                String path = property.getPath();
                String val = property.getValue();
                if (path != null && val != null) {
                    FElem elem = new FElem("tag").add("dir", "xmp-" + name).add("name", path).add(val);
                    vb.add(elem);
                }
            }
        }
        return vb.value();
    }

    /*
     * arraylist from iterable
     * http://stackoverflow.com/questions/6416706/easy-way
     * -to-change-iterable-into-collection/6416921#6416921
     */
    @Requires(Permission.NONE)
    public static <E> Collection<E> makeCollection(Iterable<E> iter) {
        Collection<E> list = new ArrayList<E>();
        for (E item : iter) {
            list.add(item);
        }
        return list;
    }
}
