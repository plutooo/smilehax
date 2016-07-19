/* smilehax - smilebasic exploit */
/* plutoo 2016 */

#define GARBAGE 0xDEADC0DE
#define TODO    0x70D070D0

#if defined(JAP300)
#define REGION_CONST(name, jap300, usa321, usa331) .set name, jap300
#elif defined(USA321)
#define REGION_CONST(name, jap300, usa321, usa331) .set name, usa321
#elif defined(USA331)
#define REGION_CONST(name, jap300, usa321, usa331) .set name, usa331
#else
#error "wat"
#endif

#define GLOBAL_CONST(name, val) .set name, val

/* Linear memory is mapped at 0x30000000 not 0x14000000. */
#define PA_TO_GPU_ADDR(pa) ((pa) + 0x10000000)
#define GPU_TO_PA_ADDR(pa) ((pa) - 0x10000000)

REGION_CONST(NEW_VA_TO_PA, 0x27B00000, TODO, 0x27B00000);
REGION_CONST(OLD_VA_TO_PA, 0x23F00000, TODO, 0x23F00000);

#if defined(NEW3DS)
#define CODE_VA_TO_PA(va) ((va - 0x00100000) + NEW_VA_TO_PA)
#else
#define CODE_VA_TO_PA(va) ((va - 0x00100000) + OLD_VA_TO_PA)
#endif
