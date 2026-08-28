#!/usr/bin/env lua
-- Standalone unit tests for ../ja4h.lua.
--
-- Mocks the HAProxy Lua runtime (`core`, the `txn` fetch/converter objects) so the
-- script can be exercised without HAProxy. The sha256 converter is mocked to identity,
-- so no sha2.lua dependency is required and the JA4H "pretty" segments are asserted
-- directly (parts a/b/c/d), which is where the behaviour under test lives.
--
-- Run:  lua test/unit_ja4h.lua   (exit code 0 = pass, 1 = fail)

local here = (arg[0] or ''):match('(.*/)') or './'
local SCRIPT = here .. '../ja4h.lua'

-- The script calls core.register_action() at load time.
core = { register_action = function() end }
assert(loadfile(SCRIPT))()  -- defines globals: fingerprint_ja4h, starts_with

local failures = 0
local function check(name, cond, detail)
  if cond then
    print('  ok   - ' .. name)
  else
    failures = failures + 1
    print('  FAIL - ' .. name .. (detail ~= nil and ('  [got: ' .. tostring(detail) .. ']') or ''))
  end
end

-- Build a mock txn from a header-name list, a header value map, and optional cookies.
-- cooks.__names is the comma-separated cookie-name list; cooks[name] is each value.
local function make_txn(names, hdrs, cooks)
  hdrs = hdrs or {}
  local vars = {}
  local f = {
    method        = function() return 'GET' end,
    req_ver       = function() return '1.1' end,
    req_hdr_names = function() return names end,
    req_hdr       = function(_, n) return hdrs[n] end,
    req_fhdr      = function(_, n) return hdrs[n] end,
    req_cook_names = function() return cooks and cooks.__names or nil end,
    req_cook       = function(_, k) return cooks and cooks[k] or nil end,
  }
  local c = { digest = function(_, v) return v end, hex = function(_, v) return v end }
  return { f = f, c = c, set_var = function(_, k, v) vars[k] = v end }, vars
end

-- Split on '_' preserving empty fields (p8/p9 are empty when there are no cookies).
local function fields(raw)
  local t, from = {}, 1
  while true do
    local s, e = raw:find('_', from, true)
    if not s then t[#t + 1] = raw:sub(from); break end
    t[#t + 1] = raw:sub(from, s - 1)
    from = e + 1
  end
  return t
end

local function run(names, hdrs, cooks)
  local txn, vars = make_txn(names, hdrs, cooks)
  fingerprint_ja4h(txn)
  return fields(vars['txn.fingerprint_ja4h_raw']), vars['txn.fingerprint_ja4h']
end

print('starts_with (prefix comparison):')
check('multi-char prefix matches',      starts_with('cookie2', 'cookie') == true)
check('non-matching prefix is false',   starts_with('referer', 'cookie') == false)
check('single-char prefix still works', starts_with('c', 'c') == true)
check('non-string returns false',       starts_with(nil, 'cookie') == false)

print('part a - header count (no cookie/referer):')
local p = run('host,user-agent,accept', {})
check('count is fixed-width 2-digit', p[5] == '03', p[5])
check('cookie flag is n',             p[3] == 'n', p[3])
check('referer flag is n',            p[4] == 'n', p[4])

print('cookie + referer present:')
p = run('host,user-agent,accept,cookie,referer',
        { cookie = 'sess=1', referer = 'http://example.test/' },
        { __names = 'sess', sess = '1' })
check('part a count excludes cookie & referer', p[5] == '03', p[5])
check('part b names exclude cookie & referer',  p[7] == 'host,user-agent,accept', p[7])
check('cookie flag is c',                        p[3] == 'c', p[3])
check('referer flag is r',                       p[4] == 'r', p[4])
check('part c has cookie names',                 p[8] == 'sess', p[8])
check('part d has cookie name=value',            p[9] == 'sess=1', p[9])

print('part b - header names keep request order:')
p = run('user-agent,host,accept', {})
check('names are not sorted alphabetically', p[7] == 'user-agent,host,accept', p[7])

print('case-insensitive filtering:')
p = run('Host,User-Agent,Cookie,Referer',
        { Cookie = 'x=1', Referer = 'http://y/' }, { __names = 'x', x = '1' })
check('mixed-case cookie/referer excluded from count', p[5] == '02', p[5])
check('names lower-cased and filtered',                p[7] == 'host,user-agent', p[7])

print('part a - accept-language padding:')
p = run('host,accept-language', { ['accept-language'] = 'en' })
check('short language is right-padded', p[6] == 'en00', p[6])
p = run('host,accept-language', { ['accept-language'] = 'en-US' })
check('four-char language is unpadded', p[6] == 'enus', p[6])
p = run('host', {})
check('missing language is 0000', p[6] == '0000', p[6])

print('part a - count clamped to 99:')
local many = {}
for i = 1, 150 do many[#many + 1] = 'x-h' .. i end
p = run(table.concat(many, ','), {})
check('count clamps at 99', p[5] == '99', p[5])

print('')
if failures == 0 then
  print('PASS: all ja4h unit tests passed')
  os.exit(0)
else
  print('FAIL: ' .. failures .. ' check(s) failed')
  os.exit(1)
end
