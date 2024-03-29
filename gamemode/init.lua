AddCSLuaFile("camsystem/cl_init.lua")
AddCSLuaFile("camsystem/shared.lua")
AddCSLuaFile("Catmull/shared.lua")
AddCSLuaFile("cl_camera.lua")
AddCSLuaFile("cl_controls.lua")
AddCSLuaFile("cl_draw.lua")
AddCSLuaFile("cl_hud_customize.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_music.lua")
AddCSLuaFile("cl_fmenu.lua")
AddCSLuaFile("cl_frameworknet.lua")
AddCSLuaFile("cl_hud.lua")

AddCSLuaFile("gmt/camera/" .. game.GetMap() .. ".lua")

AddCSLuaFile("meta_camera.lua")
AddCSLuaFile("meta_player.lua")

AddCSLuaFile("sh_move.lua")
AddCSLuaFile("sh_scores.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_math.lua")

include("multiserver.lua")
include("meta_camera.lua")
include("meta_player.lua")
include("round.lua")
include("sh_move.lua")
include("sh_scores.lua")
include("shared.lua")
include("sv_control.lua")
include("sh_math.lua")
include("sv_frameworknet.lua")



CreateConVar("mp_flashlight", 0)

function GM:Intialize()
	RegisterNWGlobal()
	self:SetState(STATE_NOPLAY)
end

function FlagSetup()
	timer.Simple(2,function()
			for k, v in pairs(ents.FindByClass("golfhole")) do
				local flagbase = ents.Create("flagbase")
				flagbase:SetPos(v:GetPos())
				flagbase:Spawn()
				flagbase:SetParent(v)
			end

			timer.Simple(2, function()
					FlagSpawn()
			end)
		end)
end

function FlagSpawn()
	for k, v in pairs(ents.FindByClass("flagbase")) do
		local flag = ents.Create("flag")
		flag:SetOwner(v)
		flag:SetPos(flag:GetOwner():GetPos())
		flag:Spawn()
		flag:SetParent(v)
	end
end

function FlagDestroy()
	for k, v in pairs(ents.FindByClass("flagbase")) do
		v:Remove()
	end
end

function FlagUnspawn()
	for k, v in pairs(ents.FindByClass("flag")) do
		v:Remove()
	end
end

function SetAllMoveType(movetype)
	for k, v in pairs(player.GetAll()) do
		v:SetMoveType(movetype)
	end
end

function PrepAllBalls()
	for k, v in pairs(player.GetAll()) do
		v:SetupForHole()
	end
end

function RemoveAllBalls()
	for k, v in pairs(player.GetAll()) do
		v:RemoveBall()
	end
end

function FreezeAll()
	for k, v in pairs(player.GetAll()) do
		v:Freeze(true)
	end
end

function UnpocketAllBalls()
	for k, v in pairs(player.GetAll()) do
		v:GetGolfBall().IsPocketed = false
	end
end

function GetAllUnfinished()
	for k, v in pairs(player.GetAll()) do
		if v:Team() ~= TEAM_FINISHED then
			v:SetSwing(15)
			v:AutoFail("TIME LIMIT")
		end
	end
end

function SetAllTeams(team)
	for k, v in pairs(player.GetAll()) do
		v:SetTeam(team)
	end
end

function SetAllCams(state)
	for k, v in pairs(player.GetAll()) do
		v:SetCamera(state, 1.0)
	end
end

function SetupAllBalls()
	for k, v in pairs(player.GetAll()) do
		v:SetupBall(CurrentHole)
	end
end

--Penalty Functions
function PenaltyScores(HoleNumber)
	for _, hole in pairs(ents.FindByClass("golfstart")) do
		if hole.Hole == tostring(HoleNumber) then
			return hole.par
		end
	end
end

function GM:HUDMessage(ent, msg)
	print(msg)
	umsg.Start("HUDMessage", ent)
	umsg.String(msg)
	umsg.End()
end

function GM:AreAllPlayersFinished()
    if player.GetCount() >= 1 then
        if (team.NumPlayers(TEAM_FINISHED) == player.GetCount() and self:GetState() ~= STATE_PREVIEW and self.PreGame ~= true) then
            if self:GetHole() ~= 18 then
                if self:GetState() == STATE_INTERMISSION then
                    return true
                else
                    self:SetState(STATE_INTERMISSION)
                    self:SetTime(60)
                end
            
                else
                    return true 
                end
                
                else
                    return false 
            end
        end
end

function GM:PlaySound(SOUNDINDEX, ply, NUM)
	if IsValid(ply) then
		umsg.Start("PlaySoundEffect", ply)
		umsg.Char(SOUNDINDEX)
		umsg.Char(NUM)
		umsg.End()
	else
		umsg.Start("PlayMusic")
		umsg.Char(SOUNDINDEX)
		umsg.End()
	end
end

function GM:EntityTakeDamage(target, dmginfo)
	if (target:IsPlayer()) then
		dmginfo:ScaleDamage(0) -- Damage is now half of what you would normally take.
	end
end

concommand.Add(
	"minigolf_color",
	function(ply, cmd, args)
		local color = tostring(args[1])
		ply:SetNWString("BallColor", color)
	end
)


local function BlockSuicide(ply)
	return false
end

hook.Add("CanPlayerSuicide", "BlockSuicide", BlockSuicide)


timer.Create("GTowerPlayerThink",1.0,0,function()
		for k, v in pairs(player.GetAll()) do
			hook.Call("PlayerPostThink", GAMEMODE, v)
		end
	end
)

hook.Add("PlayerDisconnected","PlayerPopulationCheck",function(ply)
		timer.Simple(0.2, function()
			if (GAMEMODE:GetState() ~= STATE_NOPLAY and #player.GetAll() == 0) then
				GAMEMODE:EndServer()
			end
		end)
end)

hook.Add("PlayerInitialSpawn","InitialSpawnCheck",function(ply)
		if #player.GetAll() == 1 and not ply:IsBot() then
			GAMEMODE:BeginGame()
			ply:ChatPrint("Welcome to framework for minigolf.")
            ply:ChatPrint("Console commands:\nframework_menu - opens the settings menu\nmg_settime <amount> - sets the time untill round end.")
            ply:ChatPrint("Have fun, waiting for additional people for 80 seconds.")
		end

		if not ply:IsBot() then
			ply:SetNWString("BallColor", "1 1 1")
			ply:SetNWInt("Swing", 0)
		end
end)

hook.Add("PostGamemodeLoaded", "FlagSpawing", FlagSetup)

hook.Add("PlayerSpawn","PlayerSetup",function(ply)
		ply:SetNoDraw(true)

		if GAMEMODE:IsPracticing() and ply.InitialSpawn ~= true then
			ply.InitialSpawn = true
			GAMEMODE:GetHoles()
			timer.Simple(1,function()
					ply:SetupBall(PracticeSpawn())
					GAMEMODE:PlaySound(MUSIC_WAITING, ply)
			end)
		end

		if not GAMEMODE:IsPracticing() and ply.LateSpawned ~= true then
			ply:LateJoin()
			ply:SetupBall(CurrentHole)
			ply:SetCamera("Playing", 1.0)
		end

		ply:SetMoveType(MOVETYPE_NOCLIP)
end)

util.AddNetworkString("MinigolfPutt")