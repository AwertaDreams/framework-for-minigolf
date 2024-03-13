--[[
    framework net to read from serverside frameworknet
    if this shit doesnt work i might rework it one day
]]

local framework = {}
framework.garray = {} -- golf array, haha.. garry..
local initblock = true


function framework.init()
    if initblock == true then
        print("loading..")
        net.Start("Framework_GetHoles")
        net.SendToServer(LocalPlayer())
    else
        return true
    end
end

function framework.BypassTimeLimit(boolean)
    net.Start("Framework_BypassTimeLimit")
    net.WriteBool(boolean)
    net.SendToServer()
end

function framework.teleport(int)
    if int > 18 then
        error("Number not allowed to be higher than 18.")
    end

    if int == -1 then
        net.Start("Framework_ChangeHole")
        net.WriteInt(int, 6)
        net.SendToServer()
    end

    net.Start("Framework_ChangeHole")
    net.WriteInt(int, 6) -- supporting up to 31, aka -32 to 31
    net.SendToServer()
end

net.Receive("Framework_GetHolesReturn", function() 
    print("received")
    local receivedTable = net.ReadTable()
    if receivedTable then
        for i, v in pairs(receivedTable) do
            print(v)
            table.insert(framework.garray, v)
        end

        print("loaded")
        initblock = false
       
    else
        print("Error: Unable to read table from network message")
    end
end)

function framework.FinishHole()
    net.Start("Framework_FinishHole")
    net.SendToServer()
end

return framework

