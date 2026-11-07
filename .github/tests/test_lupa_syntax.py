#!/usr/bin/env python3
"""Bramka skladni w silniku Lua uzywanym przez Generic MUD."""
import re,sys
from pathlib import Path
from lupa import LuaRuntime
code=Path(sys.argv[1] if len(sys.argv)>1 else 'soundpack.lua').read_text(encoding='utf-8-sig')
def check(cls,version):
    lua=cls(unpack_returned_tuples=True)
    lua.eval('function(code) local fn,err=load(code,"@soundpack.lua"); assert(fn,err); return true end')(code)
    print('PASS: '+version+' '+str(lua.eval('_VERSION')))
check(LuaRuntime,'Lupa default')
try:
    from lupa.lua55 import LuaRuntime as Lua55
except ImportError:
    print('Lua 5.5 backend unavailable; Lupa default passed')
else:
    check(Lua55,'Lupa Lua 5.5')
assert not re.search(r'for\s+part\s+in[^\n]*do\s*\n\s*part\s*=',code)
print('PASS: brak przypisania do zmiennej petli part')
