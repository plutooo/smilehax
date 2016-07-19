#!/usr/bin/python3

import sys
import struct
import hashlib
import hmac

HMAC_KEY = \
'''nqmby+e9S?{%U*-V]51n%^xZMk8>b{?x]&?(NmmV[,g85:%6Sqd"'U")/8u77UL2'''

buf = open(sys.argv[1], 'rb').read()
out = open(sys.argv[2], 'wb')

data_len = len(buf)

hdr = struct.pack('IIII', data_len, 0x10000, data_len, 0) + \
      struct.pack('IIII', 0, 0, 0, 0) + \
      struct.pack('IH42s', 0, 0, b'Launch homebrew!')

buf = hdr + buf

h = hmac.new(bytearray(HMAC_KEY, 'utf-8'), digestmod=hashlib.sha1)
h.update(buf)

#import binascii
#print(binascii.hexlify(buf))
#print(binascii.hexlify(h.digest()))

out.write(buf)
out.write(h.digest())
