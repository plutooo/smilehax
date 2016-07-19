# Usage: ./smilehax_genropaddrs.sh <codebin path>

codebin=$1

PATTERNFINDER_BLACKLISTPARAM=--blacklist=0x00101000-0x0010D000

# Locate HTTPC_INITSTRUCT.

printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 --patterntype=sha256 --patterndata=3886b0137d4377756b36dc2a6849bc92632d264cd3225d2129cca8f24f02bdac --patternsha256size=0x4c "--plainout=#define HTTPC_INITSTRUCT "`

if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: HTTPC_INITSTRUCT not found."
	exit 1
fi

# TODO: Update this to locate it properly?
# Locate HTTPC_BEGINREQUEST.

#printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 --patterntype=sha256 --patterndata=d1d9d26b26ec3696c4e44bf70134dbf12e158392f5fc38b13aa8053ac94cde4c --patternsha256size=0x18 "--plainout=#define HTTPC_BEGINREQUEST "`

#if [[ $? -eq 0 ]]; then
#	echo "$printstr"
#else
#	echo "//ERROR: HTTPC_BEGINREQUEST not found."
#	exit 1
#fi

# Locate HTTPC_RECVDATA.

printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 --patterntype=sha256 --patterndata=be1a6eb149cc9e1a3aec716a405f0f6feac02ec25046cd8cb17ed2c71e07a889 --patternsha256size=0x30 "--plainout=#define HTTPC_RECVDATA "`

if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: HTTPC_RECVDATA not found."
	exit 1
fi


# Locate GADGET_POP_R0PC.

printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 $PATTERNFINDER_BLACKLISTPARAM --patterntype=sha256 --patterndata=e0160ca8a7f0ec85bd4b01d8756fb82e38344124545f0a7d58ae2ac288da17cc --patternsha256size=0x4 "--plainout=#define GADGET_POP_R0PC "`
if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: GADGET_POP_R0PC not found."
	exit 1
fi

# Locate GADGET_POP_R1PC.

printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 $PATTERNFINDER_BLACKLISTPARAM --patterntype=sha256 --patterndata=1db27e1b47976b065367f34eee05cdc06421c0053cadb2dfdd81ec315a47daff --patternsha256size=0x4 "--plainout=#define GADGET_POP_R1PC "`
if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: GADGET_POP_R1PC not found."
	exit 1
fi

# Locate GADGET_POP_R0R1R2R3R4R5R6__POP_R3__ADD_SP_0x10__BX_R3.

printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 $PATTERNFINDER_BLACKLISTPARAM --patterntype=sha256 --patterndata=239069af3d9542d671edee9e0b0e8cbd4f5ba03923307480e25c8a638acfca7f --patternsha256size=0x8 "--plainout=#define GADGET_POP_R0R1R2R3R4R5R6__POP_R3__ADD_SP_0x10__BX_R3 " --addval=0x1 --stride=0x2`
if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: GADGET_POP_R0R1R2R3R4R5R6__POP_R3__ADD_SP_0x10__BX_R3 not found."
	exit 1
fi

# Locate GADGET_POP_R4R5LR__BX_LR.

printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 --patterntype=sha256 --patterndata=8ede950d3dc59e8709e737b018a1316afb1e4293fc0046a95bcb140570d21683 --patterndatamask=ffffffff000000ff00000000ffffffff --patternsha256size=0x10 "--plainout=#define GADGET_POP_R4R5LR__BX_LR "`

if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: GADGET_POP_R4R5LR__BX_LR not found."
	exit 1
fi

echo ""

# Locate SVC_SLEEP_THREAD.

printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 --patterntype=sha256 --patterndata=a424f8b938aa4919842c18cf173c854c6412bacc5bf48ff0abbb7164e69ec507 --patternsha256size=0x8 "--plainout=#define SVC_SLEEP_THREAD "`

if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: SVC_SLEEP_THREAD not found."
	exit 1
fi

# Locate GSP_FLUSH_DATA_CACHE.

printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 --patterntype=sha256 --patterndata=13e4f43b6452910ff7a0dc1804e38c4e5dba166750871a37c7beefd22995a484 --patternsha256size=0x18 "--plainout=#define GSP_FLUSH_DATA_CACHE " --addval=0x4`

if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: GSP_FLUSH_DATA_CACHE not found."
	exit 1
fi

# Locate MEMCPY.

printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 --patterntype=sha256 --patterndata=af9b979211128ac5b9ec87508960da11a378820b0df7899576628e36dc662449 --patternsha256size=0x5c "--plainout=#define MEMCPY "`

if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: MEMCPY not found."
	exit 1
fi

# Locate SNPRINTF.
# NOTE: This fails with certain codebin(s).

printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 --patterntype=sha256 --patterndata=2c961c6a66c85246fa4401757534abd94facb0ce8d0b9d04c32905f733ece072 --patterndatamask=ffffffffffffffffffffffffffffffffffffffff000000ffffffffffffffffffffffffffffffffffffffffffffffffff000000ffffffffffffffffff --patternsha256size=0x3c "--plainout=#define SNPRINTF " --addval=0x20`

if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: SNPRINTF not found."
	#exit 1
fi

# Locate GSP_ENQUEUE_CMD_GADGET.

printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 $PATTERNFINDER_BLACKLISTPARAM --patterntype=sha256 --patterndata=5b8c4b55aa2a6197ba8b04048debf2664df7974eb3aae8c148d7a669d80151bf --patterndatamask=ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000ffffffffffffffffff000000ffffffffffffffffff --patternsha256size=0x7c "--plainout=#define GSP_ENQUEUE_CMD_GADGET " --addval=0x64`

if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//WARNING: GSP_ENQUEUE_CMD_GADGET not found."
fi

# Locate GXLOW_CMD4.

printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 $ROPKIT_PATTERNFINDER_BLACKLISTPARAM --patterntype=sha256 --patterndata=406e130dfe0a99ba64c16ac6ec4a53355cb36f090647b73c5382ea180c88e72c --patternsha256size=0x30 "--plainout=#define GXLOW_CMD4 "`
if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 $ROPKIT_PATTERNFINDER_BLACKLISTPARAM --patterntype=sha256 --patterndata=92aaae0b22699ada29758d0f9c7043897b634196c87c0e6a3c9f562e221d751d --patternsha256size=0x3c "--plainout=#define GXLOW_CMD4 "`

	if [[ $? -eq 0 ]]; then
		echo "$printstr"
	else
		echo "//ERROR: GXLOW_CMD4 not found."
		exit 1
	fi
fi

# Locate GADGET_R3.

printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 $PATTERNFINDER_BLACKLISTPARAM --patterntype=sha256 --patterndata=34c90c0722eaee19ec9a8c7dcb85f708066837c7e65d9e127f6052dc730f3465 --patternsha256size=0x4 "--plainout=#define GADGET_R3 "`
if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: GADGET_R3 not found."
	exit 1
fi

# Locate GADGET_R1R2R3R4R5.

printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 --patterntype=sha256 --patterndata=698558cfe309dc534cb562046e041022fd930427110dc4cd7dbe7986c6c155c3 --patternsha256size=0x2 "--plainout=#define GADGET_R1R2R3R4R5 " --addval=0x1 --stride=0x2`
if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: GADGET_R1R2R3R4R5 not found."
	exit 1
fi

# Locate GADGET_NOP.

printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 --patterntype=sha256 --patterndata=842555e8c82550c2c431530590fe143174ca0d28d1e35a941b87cdee5e5fd465 --patternsha256size=0x4 "--plainout=#define GADGET_NOP "`

if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: GADGET_NOP not found."
	exit 1
fi

# Locate GSPGPU_SERVHANDLEADR.

printstr=`ropgadget_patternfinder $1 --baseaddr=0x100000 --patterntype=sha256 --patterndata=56d7a4a092f431aca4c7091f82482481324df2fd1e27fd86a6d7cd4904ca9af2 --patterndatamask=ffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000ffffffffff --patternsha256size=0x24 --dataload=0x28 "--plainout=#define GSPGPU_SERVHANDLEADR "`

if [[ $? -eq 0 ]]; then
	echo "$printstr"
else
	echo "//ERROR: GSPGPU_SERVHANDLEADR not found."
	exit 1
fi

