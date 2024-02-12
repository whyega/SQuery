local utils = {}



function utils:UInt16ToChars(number)
    -- string.char(bit.rshift(number, 8), bit.band(number, 0xFF))
    return string.char(math.floor(number / 256) % 256, number % 256)
end



function utils:convertHostToChars(host)
    local bytes = {host:match("(%d+).(%d+).(%d+).(%d+)")}
    if #bytes == 4 then
        return string.char(table.unpack(bytes))
    end
end



return utils