local Buffer = {}



function Buffer:new(data)
    local Buffer = {}


    Buffer.data = data
    Buffer.readOffset = 1


    return setmetatable(Buffer, {
        __index = self
    })
end



function Buffer:ignoreBytes(count)
    self.readOffset = self.readOffset + count
end



function Buffer:readUInt8()
    local output = self.data:byte(self.readOffset)

    self.readOffset = self.readOffset + 1

    return output
end



function Buffer:readUInt16()
    local byte1, byte2 = self.data:byte(self.readOffset, self.readOffset + 1)
    -- bit.bor(bit.lshift(byte2, 8), byte1)
    local output = byte2 * 0xFF + byte1

    self.readOffset = self.readOffset + 2

    return output
end



function Buffer:readUInt32()
    local byte1, byte2, byte3, byte4 = self.data:byte(self.readOffset, self.readOffset + 3)
    -- bit.bor(bit.lshift(byte4, 24), bit.lshift(byte3, 16), bit.lshift(byte2, 8), byte1)
    local output = byte4 * 256^3 + byte3 * 256^2 + byte2 * 256 + byte1

    self.readOffset = self.readOffset + 4

    return output
end



function Buffer:readBuffer(length)
    local output = self.data:sub(self.readOffset, self.readOffset + length - 1)

    self.readOffset = self.readOffset + length

    return output
end




return Buffer