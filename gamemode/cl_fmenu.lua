local checkboxArray = {}
local init = false
local populated = false
local framework = include("cl_frameworknet.lua")

local function UpdateCheckboxArray(checkboxName, isChecked)
    checkboxArray[checkboxName] = isChecked
    
    if checkboxName == "Bypass time limit" and isChecked then
        framework.BypassTimeLimit(isChecked)
    else
        framework.BypassTimeLimit(isChecked)
    end
end

local function CreateCheckBoxLabel(labelText,parent)
    if parent then
        checkboxLabel = vgui.Create("DCheckBoxLabel", parent)
    else
        checkboxLabel = vgui.Create("DCheckBoxLabel")
    end

    
    checkboxLabel:SetText(labelText)
    checkboxLabel:SizeToContents()
    checkboxLabel:SetTextColor(Color(0,0,0))
    checkboxLabel.OnChange = function(self, isChecked)
        UpdateCheckboxArray(labelText, isChecked)
    end

    return checkboxLabel
end

local FrameworkPanel = vgui.Create("DFrame")
local InitPanel = vgui.Create("DFrame")
local InitText = vgui.Create("DLabel", InitPanel)
local sheet = vgui.Create( "DPropertySheet", FrameworkPanel )
local panel1 = vgui.Create( "DPanel", sheet )
local panel2 = vgui.Create( "DPanel", sheet )
local authorlabel = vgui.Create("DLabel", panel2)

local categorylist = vgui.Create("DCategoryList", panel1)
categorylist:Dock(FILL)

local menu2 = categorylist:Add("Options")
menu2:SetTall(200)

local menu1 = categorylist:Add("Teleportation")
menu1:SetTall(200)

local DComboBox = vgui.Create( "DComboBox" )
DComboBox:SetValue( "Teleport to..." )
menu1:SetContents(DComboBox)

FrameworkPanel:SetPos(100, 100)
FrameworkPanel:SetSize(300, 600)
FrameworkPanel:SetTitle("Framework")
FrameworkPanel:MakePopup()
FrameworkPanel:SetDeleteOnClose(false) 
FrameworkPanel:SetVisible(false)

InitPanel:SetSize(300,300)
InitPanel:Center()
InitPanel:SetTitle("Initialization")
InitPanel:MakePopup()
InitPanel:SetDeleteOnClose(true)
InitPanel:SetVisible(false)

InitText:SetText("Initialization done. \n You may close this panel now.")
InitText:SetSize(300,300)
InitText:SetPos(0,0)

authorlabel:SetTextColor(Color(0,0,0))
authorlabel:SetSize(300,400)
authorlabel:SetPos(5,-165)
authorlabel:SetText("Framework for minigolf by awertadreams\nGMod Tower & and minigolf is a product\nmade by PixelTail Games, LLC. \nFramework is not affiliated with PixelTail Games, LLC.")
sheet:AddSheet( "Options", panel1, "icon16/cog.png" )
sheet:AddSheet( "Authors", panel2, "icon16/group.png" )
sheet:Dock( FILL )


local layout = vgui.Create("DListLayout")

local checkboxLabel1 = CreateCheckBoxLabel("Bypass time limit", layout)
local FinishHole = vgui.Create("DButton", layout)
FinishHole:SetText("Finish Hole")

function FinishHole:DoClick()
    framework.FinishHole()
end




menu2:SetContents(layout)

DComboBox.OnSelect = function( self, index, value )
	print( "Teleporting to " .. value)
    if value == "Practice hole" then
        framework.teleport(-1)
    else
        framework.teleport(index - 1)
    end
end

function populateCombo()
    for i, v in pairs(framework.garray) do
        DComboBox:AddChoice("Hole " .. i)
    end
    DComboBox:AddChoice("Practice hole")
end




concommand.Add( "framework_menu", function()
    --[[
        do not remove initpanel. its the hack to fix the fact that you cant 
        dynamically populate dcomboboxes, resulting in the player having to open the frameworkpanel twice.
            
    ]]

    framework.init()
    if init == false then
        InitPanel:SetVisible(true)
        init = true
    else
        FrameworkPanel:SetVisible(true)
        if populated == false then
            populateCombo()
            populated = true
        end    
    end


end)


