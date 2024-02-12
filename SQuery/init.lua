local socket = require("socket")

local utils = require("SQuery.utils")
local Buffer = require("SQuery.buffer")



local SQuery = {}



---Create new instance
---@param host string
---@param port integer
---@param timeout integer | nil
---@return table
function SQuery:new(host, port, timeout)
    local SQuery = {}


    SQuery.host = socket.dns.toip(host) or host
    SQuery.port = port
    SQuery.header = "SAMP" .. assert(utils:convertHostToChars(SQuery.host), "Enter the correct address") .. utils:UInt16ToChars(SQuery.port)
    SQuery.timeout = timeout and timeout or 5


    return setmetatable(SQuery, {
        __index = self
    })
end



---Get basic information about the server
---@return integer | boolean isPassword
---@return integer | nil numberOfPlayers
---@return integer | nil maxPlayers
---@return string | nil hostname
---@return string | nil gamemode
---@return string | nil language
function SQuery:getServerInfo()
    local response = self:request("i")
    if not response then return false end

    local data = Buffer:new(response)
    data:ignoreBytes(11)
    local isPassword = data:readUInt8()
    local numberOfPlayers = data:readUInt16()
    local maxPlayers = data:readUInt16()
    local hostlen = data:readUInt32()
    local hostname = data:readBuffer(hostlen)
    local gamemode = data:readBuffer(data:readUInt32())
    local language = data:readBuffer(data:readUInt32())

    return isPassword, numberOfPlayers, maxPlayers, hostname, gamemode, language
end



---Get rules about the server
---@return table | boolean
function SQuery:getServerRules()
    local response = self:request("r")
    if not response then return false end

    local data = Buffer:new(response)
    data:ignoreBytes(11)

    local count = data:readUInt16()
    local rules = {}
    for _ = 1, count do
        local name = data:readBuffer(data:readUInt8())
        local value = data:readBuffer(data:readUInt8())
        table.insert(rules, {name = name, value = value})
    end

    return rules
end



---Get a list of clients
---@return table | boolean
function SQuery:getServerPlayers()
    local response = self:request("c")
    if not response then return false end

    local data = Buffer:new(response)
    data:ignoreBytes(11)

    local count = data:readUInt16()
    local players = {}
    for _ = 1, count do
        local name = data:readBuffer(data:readUInt8())
        local score = data:readUInt32()
        table.insert(players, {name = name, score = score})
    end

    return players
end



---Get more information about the players
---@return table | boolean
function SQuery:getServerPlayersDetailed()
    local response = self:request("d")
    if not response then return false end

    local data = Buffer:new(response)
    data:ignoreBytes(11)

    local count = data:readUInt16()
    local players = {}
    for _ = 1, count do
        local id = data:readUInt8()
        local name = data:readBuffer(data:readUInt8())
        local score = data:readUInt32()
        local ping = data:readUInt32()
        table.insert(players, {id = id, name = name, score = score, ping = ping})
    end

    return players
end



---Determines the ping between the client and the server
---@return integer | boolean ping
function SQuery:getServerPing()
    local time = socket.gettime()
    -- "1234" - magic chars
    local response = self:request("p1234")
    if not response then return false end

    return (socket.gettime() - time) * 1000
end



---Send a request to the server
---@param content string
---@return string response
function SQuery:request(content)
    local s = socket.udp()
    s:settimeout(self.timeout)

    local data = self.header .. content
    s:sendto(data, self.host, self.port)
    local response = s:receive()
    s:close()

    return response
end



return SQuery