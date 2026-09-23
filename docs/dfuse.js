/*!
 * WebDFU — https://github.com/devanlai/webdfu, modified: MALAHIT FORCE erase, single base address with sequential block numbers, expected manifestation errors silenced
 * Copyright (c) 2016, Devan Lai
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
 * RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
 * USE OR PERFORMANCE OF THIS SOFTWARE.
 */
/* dfu.js must be included before dfuse.js */

var dfuse = {};

(function() {
    'use strict';

    dfuse.GET_COMMANDS = 0x00;
    dfuse.SET_ADDRESS = 0x21;
    dfuse.ERASE_SECTOR = 0x41;

    dfuse.Device = function(device, settings) {
        dfu.Device.call(this, device, settings);
        this.memoryInfo = null;
        this.startAddress = NaN;
        if (settings.name) {
            this.memoryInfo = dfuse.parseMemoryDescriptor(settings.name);
        }
    }

    dfuse.Device.prototype = Object.create(dfu.Device.prototype);
    dfuse.Device.prototype.constructor = dfuse.Device;

    // The receiver leaves the USB bus while it manifests the new firmware, so the
    // final status poll normally dies with a transfer or disconnect error. That is
    // the expected end of a successful write and must not be reported as a failure.
    dfuse.isExpectedManifestationError = function(error) {
        // String() keeps a DOMException's name ("NetworkError: Unable to reset the device.");
        // reading .message alone would drop it and let a benign reset failure through.
        const text = String(error);
        return /^stall$|ControlTransfer(In|Out) failed|NetworkError|NotFoundError|A transfer error has occurred|device was disconnected|Device unavailable|\bstall(ed)?\b|\bbabble\b/i.test(text);
    };

    dfuse.parseMemoryDescriptor = function(desc) {
        const nameEndIndex = desc.indexOf("/");
        if (!desc.startsWith("@") || nameEndIndex == -1) {
            throw `Not a DfuSe memory descriptor: "${desc}"`;
        }

        const name = desc.substring(1, nameEndIndex).trim();
        const segmentString = desc.substring(nameEndIndex);

        let segments = [];

        const sectorMultipliers = {
            ' ': 1,
            'B': 1,
            'K': 1024,
            'M': 1048576
        };

        let contiguousSegmentRegex = /\/\s*(0x[0-9a-fA-F]{1,8})\s*\/(\s*[0-9]+\s*\*\s*[0-9]+\s?[ BKM]\s*[abcdefg]\s*,?\s*)+/g;
        let contiguousSegmentMatch;
        while (contiguousSegmentMatch = contiguousSegmentRegex.exec(segmentString)) {
            let segmentRegex = /([0-9]+)\s*\*\s*([0-9]+)\s?([ BKM])\s*([abcdefg])\s*,?\s*/g;
            let startAddress = parseInt(contiguousSegmentMatch[1], 16);
            let segmentMatch;
            while (segmentMatch = segmentRegex.exec(contiguousSegmentMatch[0])) {
                let segment = {}
                let sectorCount = parseInt(segmentMatch[1], 10);
                let sectorSize = parseInt(segmentMatch[2]) * sectorMultipliers[segmentMatch[3]];
                let properties = segmentMatch[4].charCodeAt(0) - 'a'.charCodeAt(0) + 1;
                segment.start = startAddress;
                segment.sectorSize = sectorSize;
                segment.end = startAddress + sectorSize * sectorCount;
                segment.readable = (properties & 0x1) != 0;
                segment.erasable = (properties & 0x2) != 0;
                segment.writable = (properties & 0x4) != 0;
                segments.push(segment);

                startAddress += sectorSize * sectorCount;
            }
        }

        return {"name": name, "segments": segments};
    };

    dfuse.Device.prototype.dfuseCommand = async function(command, param, len) {
        if (typeof param === 'undefined' && typeof len === 'undefined') {
            param = 0x00;
            len = 1;
        }

        const commandNames = {
            0x00: "GET_COMMANDS",
            0x21: "SET_ADDRESS",
            0x41: "ERASE_SECTOR"
        };

        let payload = new ArrayBuffer(len + 1);
        let view = new DataView(payload);
        view.setUint8(0, command);
        if (len == 1) {
            view.setUint8(1, param);
        } else if (len == 4) {
            view.setUint32(1, param, true);
        } else {
            throw "Don't know how to handle data of len " + len;
        }

        try {
            await this.download(payload, 0);
        } catch (error) {
            throw "Error during special DfuSe command " + commandNames[command] + ":" + error;
        }

        let status = await this.poll_until(state => (state != dfu.dfuDNBUSY));
        if (status.status != dfu.STATUS_OK) {
            throw "Special DfuSe command " + commandName + " failed";
        }
    };

    dfuse.Device.prototype.getSegment = function(addr) {
        if (!this.memoryInfo || ! this.memoryInfo.segments) {
            throw "No memory map information available";
        }

        for (let segment of this.memoryInfo.segments) {
            if (segment.start <= addr && addr < segment.end) {
                return segment;
            }
        }

        return null;
    };

    dfuse.Device.prototype.getSectorStart = function(addr, segment) {
        if (typeof segment === 'undefined') {
            segment = this.getSegment(addr);
        }

        if (!segment) {
            throw `Address ${addr.toString(16)} outside of memory map`;
        }

        const sectorIndex = Math.floor((addr - segment.start)/segment.sectorSize);
        return segment.start + sectorIndex * segment.sectorSize;
    };

    dfuse.Device.prototype.getSectorEnd = function(addr, segment) {
        if (typeof segment === 'undefined') {
            segment = this.getSegment(addr);
        }

        if (!segment) {
            throw `Address ${addr.toString(16)} outside of memory map`;
        }

        const sectorIndex = Math.floor((addr - segment.start)/segment.sectorSize);
        return segment.start + (sectorIndex + 1) * segment.sectorSize;
    };

    dfuse.Device.prototype.getFirstWritableSegment = function() {
        if (!this.memoryInfo || ! this.memoryInfo.segments) {
            throw "No memory map information available";
        }

        for (let segment of this.memoryInfo.segments) {
            if (segment.writable) {
                return segment;
            }
        }

        return null;
    };

    dfuse.Device.prototype.getMaxReadSize = function(startAddr) {
        if (!this.memoryInfo || ! this.memoryInfo.segments) {
            throw "No memory map information available";
        }

        let numBytes = 0;
        for (let segment of this.memoryInfo.segments) {
            if (segment.start <= startAddr && startAddr < segment.end) {
                // Found the first segment the read starts in
                if (segment.readable) {
                    numBytes += segment.end - startAddr;
                } else {
                    return 0;
                }
            } else if (segment.start == startAddr + numBytes) {
                // Include a contiguous segment
                if (segment.readable) {
                    numBytes += (segment.end - segment.start);
                } else {
                    break;
                }
            }
        }

        return numBytes;
    };

    dfuse.Device.prototype.erase = async function(startAddr, length, force = false) {
        let segment = this.getSegment(startAddr);
        let addr = this.getSectorStart(startAddr, segment);
        const endAddr = this.getSectorEnd(startAddr + length - 1);

        let bytesErased = 0;
        const bytesToErase = endAddr - addr;
        if (bytesToErase > 0) {
            this.logProgress(bytesErased, bytesToErase);
        }

        while (addr < endAddr) {
            if (segment.end <= addr) {
                segment = this.getSegment(addr);
            }
            if (!segment.erasable && !force) {
                // Skip over the non-erasable section
                bytesErased = Math.min(bytesErased + segment.end - addr, bytesToErase);
                addr = segment.end;
                this.logProgress(bytesErased, bytesToErase);
                continue;
            }
            const sectorIndex = Math.floor((addr - segment.start)/segment.sectorSize);
            const sectorAddr = segment.start + sectorIndex * segment.sectorSize;
            this.logDebug(`Erasing ${segment.sectorSize}B at 0x${sectorAddr.toString(16)}`);
            await this.dfuseCommand(dfuse.ERASE_SECTOR, sectorAddr, 4);
            addr = sectorAddr + segment.sectorSize;
            bytesErased += segment.sectorSize;
            this.logProgress(bytesErased, bytesToErase);
        }
    };

    dfuse.Device.prototype.do_download = async function(xfer_size, data, manifestationTolerant, options = {}) {
        if (!this.memoryInfo || ! this.memoryInfo.segments) {
            throw "No memory map available";
        }

        this.logInfo("Erasing DFU device memory");
        
        let bytes_sent = 0;
        let expected_size = data.byteLength;

        let startAddress = this.startAddress;
        if (isNaN(startAddress)) {
            startAddress = this.memoryInfo.segments[0].start;
            this.logWarning("Using inferred start address 0x" + startAddress.toString(16));
        } else if (this.getSegment(startAddress) === null) {
            this.logError(`Start address 0x${startAddress.toString(16)} outside of memory map bounds`);
        }
        await this.erase(startAddress, expected_size, options.force === true);

        this.logInfo("Copying data from browser to DFU device");

        let address = startAddress;
        let blockNum = 2;
        // STM32 DfuSe derives each address from the base pointer and wBlockNum,
        // so contiguous data needs one SET_ADDRESS instead of one per block.
        await this.dfuseCommand(dfuse.SET_ADDRESS, address, 4);
        this.logDebug(`Set base address to 0x${address.toString(16)}`);
        while (bytes_sent < expected_size) {
            const bytes_left = expected_size - bytes_sent;
            const chunk_size = Math.min(bytes_left, xfer_size);

            // wBlockNum is 16-bit. For very large images, start a new address window.
            if (blockNum > 0xffff) {
                await this.dfuseCommand(dfuse.SET_ADDRESS, address, 4);
                this.logDebug(`Set base address to 0x${address.toString(16)}`);
                blockNum = 2;
            }

            let bytes_written = 0;
            let dfu_status;
            try {
                bytes_written = await this.download(data.slice(bytes_sent, bytes_sent+chunk_size), blockNum);
                this.logDebug("Sent " + bytes_written + " bytes");
                dfu_status = await this.poll_until_idle(dfu.dfuDNLOAD_IDLE);
            } catch (error) {
                throw "Error during DfuSe download: " + error;
            }

            if (dfu_status.status != dfu.STATUS_OK) {
                throw `DFU DOWNLOAD failed state=${dfu_status.state}, status=${dfu_status.status}`;
            }
            if (bytes_written != chunk_size) {
                throw `DFU DOWNLOAD wrote ${bytes_written} of ${chunk_size} bytes`;
            }

            this.logDebug("Wrote " + bytes_written + " bytes");
            bytes_sent += bytes_written;
            address += bytes_written;
            blockNum += 1;

            this.logProgress(bytes_sent, expected_size);
        }
        this.logInfo(`Wrote ${bytes_sent} bytes`);

        this.logInfo("Manifesting new firmware");
        try {
            await this.dfuseCommand(dfuse.SET_ADDRESS, startAddress, 4);
            await this.download(new ArrayBuffer(), 0);
        } catch (error) {
            throw "Error during DfuSe manifestation: " + error;
        }

        try {
            await this.poll_until(state => (state == dfu.dfuMANIFEST));
        } catch (error) {
            if (!dfuse.isExpectedManifestationError(error)) {
                this.logWarning(error);
            }
        }

        // dfu-util ends ":leave" with a bus reset. Without it the STM32 can stay in
        // MANIFEST_WAIT_RESET, so the receiver would keep sitting in the bootloader
        // instead of starting the firmware that was just written.
        try {
            await this.device_.reset();
        } catch (error) {
            if (!dfuse.isExpectedManifestationError(error)) {
                this.logWarning("Reset after manifestation failed: " + error);
            }
        }
    }

    dfuse.Device.prototype.do_upload = async function(xfer_size, max_size) {
        let startAddress = this.startAddress;
        if (isNaN(startAddress)) {
            startAddress = this.memoryInfo.segments[0].start;
            this.logWarning("Using inferred start address 0x" + startAddress.toString(16));
        } else if (this.getSegment(startAddress) === null) {
            this.logWarning(`Start address 0x${startAddress.toString(16)} outside of memory map bounds`);
        }

        this.logInfo(`Reading up to 0x${max_size.toString(16)} bytes starting at 0x${startAddress.toString(16)}`);
        let state = await this.getState();
        if (state != dfu.dfuIDLE) {
            await this.abortToIdle();
        }
        await this.dfuseCommand(dfuse.SET_ADDRESS, startAddress, 4);
        await this.abortToIdle();

        // DfuSe encodes the read address based on the transfer size,
        // the block number - 2, and the SET_ADDRESS pointer.
        return await dfu.Device.prototype.do_upload.call(this, xfer_size, max_size, 2);
    }
})();
