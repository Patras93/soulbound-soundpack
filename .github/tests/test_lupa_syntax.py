#!/usr/bin/env python3
"""Gate for the same embedded Lua backend Generic MUD uses (Lupa)."""
import sys
from pathlib import Path
from lupa import LuaRuntime

path = Path(sys.argv[1] if len(sys.argv) > 1 else 'soundpack.lua')
code = path.read_text(encoding='utf-8-sig')

def check(runtime_class, name):
    lua = runtime_class(unpack_returned_tuples=True)
    compiler = lua.eval('function(src) local fn, err = load(src, "@soundpack.lua"); assert(fn, err); return true end')
    compiler(code)
    print(f'PASS {name} Lua syntax: {lua.eval("_VERSION")}')

check(LuaRuntime, 'Lupa default')
# Parse also with 5.5 backend when packaged, because it prohibits
# assignments to the control variables of generic for-loops.
try:
    from lupa.lua55 import LuaRuntime as Lua55Runtime
except ImportError:
    print('Lua 5.5 backend unavailable; default Lupa syntax checked')
else:
    check(Lua55Runtime, 'Lupa 5.5')

# Explicit regression check even when the runner defaults to 5.4.
import re
if re.search(r"for\s+part\s+in[^\n]*do\s*\n\s*part\s*=", code):
    raise AssertionError('Regression: assigning to generic-for variable part')
print('PASS control variable regression check')
