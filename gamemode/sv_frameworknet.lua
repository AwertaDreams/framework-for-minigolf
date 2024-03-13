local gArray = {}

util.AddNetworkString("Framework_BypassTimeLimit")
util.AddNetworkString("Framework_BypassPractice")
util.AddNetworkString("Framework_GetHoles")
util.AddNetworkString("Framework_GetHolesReturn")
util.AddNetworkString("Framework_ChangeHole")
util.AddNetworkString("Framework_GetInfo")
util.AddNetworkString("Framework_GetInfoReturn")
util.AddNetworkString("Framework_FinishHole")

net.Receive("Framework_GetHoles", function(len, ply) 
    print("received")
    for k in pairs (gArray) do
        gArray[k] = nil
    end

    for _, x in pairs(GAMEMODE.Holes) do        
        table.insert(gArray, x)
    end
    
    local jsonTable = util.TableToJSON(GAMEMODE.Holes)

    net.Start("Framework_GetHolesReturn")
    net.WriteTable(gArray)
    net.Send(ply)    

    print("sent!")
end)

net.Receive("Framework_FinishHole", function(len,ply)
    ply:SetSwing(1)
    GAMEMODE:SetScore(ply, GAMEMODE:GetHole(), 1)
    ply:Pocket()
   
end)

net.Receive("Framework_BypassPractice", function(len, ply) 
    GAMEMODE:StartRound()
end)

net.Receive("Framework_GetInfo", function(len,ply)
    net.Start("Framework_GetInfoReturn")
    net.WriteInt(GAMEMODE:GetHole(), 32)
    net.WriteInt(GAMEMODE:GetPar(), 32)
    net.WriteString(GAMEMODE:GetHoleName())
    net.Send(ply)
end)

--[[
STATE_NOPLAY = 0
STATE_WAITING = 1
STATE_SETTINGS = 2
STATE_PREVIEW = 3
STATE_PLAYING = 4
STATE_INTERMISSION = 5
STATE_ENDING = 6


]]

net.Receive("Framework_ChangeHole", function(len,ply)
    local receivedInt = net.ReadInt(6)
    print(receivedInt)

    if receivedInt == -1 then
        SetGlobalBool("HasPractice", true)
        GAMEMODE:SetState(STATE_WAITING)
	    GAMEMODE:SetTime(WaitTime)
        ply:Pocket()
        ply:SetupBall(PracticeSpawn())
	    
        
    else
        GAMEMODE:UpdateNetHole(receivedInt)
        print(GAMEMODE:GetHole())
        GAMEMODE:StartRound()
    end

   

end)



net.Receive("Framework_BypassTimeLimit", function()
    local receivedBool = net.ReadBool()
    if receivedBool then
        GAMEMODE:SetTime(9999999)
    else
        if GAMEMODE:IsPracticing() then
            GAMEMODE:SetTime(20)
        else
            GAMEMODE:SetTime(600)
        end
        
    end
end)
