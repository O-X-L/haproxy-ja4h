-- Source: https://github.com/O-X-L/haproxy-ja4h
-- Copyright (C) 2024 Rath Pascal
-- License: MIT

-- JA4H
-- see: https://github.com/FoxIO-LLC/ja4
-- config:
--   register: lua-load /etc/haproxy/lua/ja4h.lua (in global)
--   run: http-request lua.fingerprint_ja4h
--   log: http-request capture var(txn.fingerprint_ja4h) len 51
--   acl: var(txn.fingerprint_ja4h) -m str ge11cn21enus_9022c49255fb_ac95b44401d9_8df6a44f726c

local sha = require('sha2')

function split_string(str, delimiter)
    local result = {}
    local from  = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(str, from , delim_from-1))
        from  = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end
    table.insert(result, string.sub(str, from))
    return result
end

function truncated_sha256(value)
    return string.sub(sha.sha256(value), 1, 12)
end

function fingerprint_ja4h(txn)
    local test = txn.f:req_method()

    txn:set_var('txn.fingerprint_ja4h_raw', test)
    txn:set_var('txn.fingerprint_ja4h', test)
end

core.register_action('fingerprint_ja4h', {'tcp-req', 'http-req'}, fingerprint_ja4h)