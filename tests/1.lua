local SQuery = require("SQuery")



local query = SQuery:new("185.189.15.89", 7228)


print("RESPONE SERVER INFO:", query:getServerInfo())

local rules = query:getServerRules()
if rules and #rules > 0 then
    print("RESPONE SERVER RULES:", rules[1].value)
end

local players = query:getServerPlayers()
if players and #players > 0 then
    print("RESPONE SERVER PLAYERS:", players[1].name)
end

local detailed = query:getServerPlayersDetailed()
if detailed and #detailed > 0 then
    print("RESPONE SERVER PLAYERS DETAILED:", detailed[1].name)
end

print("SERVER PING:", query:getServerPing())