/**
 * JHOVE2 - Next-generation architecture for format-aware characterization
 * 
 * Copyright (c) 2009 by The Regents of the University of California, Ithaka
 * Harbors, Inc., and The Board of Trustees of the Leland Stanford Junior
 * University. All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * o Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 * 
 * o Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 
 * o Neither the name of the University of California/California Digital
 * Library, Ithaka Harbors/Portico, or Stanford University, nor the names of its
 * contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
package org.jhove2.module.format;

import org.jhove2.core.I8R;
import org.jhove2.core.JHOVE2Exception;
import org.jhove2.module.Module;

/**
 * Factory Interface for {@link org.jhove2.module.format.FormatModule}instances
 * 
 * @author smorrissey
 *
 */
public interface FormatModuleFactory {
	/**
	 * Construct FormatModule instance for FormatModule able to parse an instance of Format
	 * identified by the I8R parameters
	 * @param {@link org.jhove2.core.I8R} for Format for which corresponding FormatModule instance is to be created
	 * @return FormatModule if one is found, otherwise null
	 * @throws JHOVE2Exception
	 */
	public Module getFormatModule(I8R identifier)
		throws JHOVE2Exception;
	
    /**
     * Determine module to be invoked from format identifier
     * 
     * @param identifier
     *            JHOVE2 identifier for format
     * @return Module mapped to the JHOVE2 format identifier, or null if no
     *         module has been mapped to the JHOVE2 identifier
     * @throws JHOVE2Exception
     */
	public Module getModuleFromIdentifier(I8R identifier)
    throws JHOVE2Exception ;
}
