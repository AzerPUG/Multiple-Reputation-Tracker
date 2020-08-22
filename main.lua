local GlobalAddonName, AGU = ...

local OptionsPanel

local initialConfig = AGU.initialConfig

local addonVersion = "v0.1"
local dash = " - "
local name = "GameUtility" .. dash .. "RepBaws"
local nameFull = ("AzerPUG " .. name)
local promo = (nameFull .. dash ..  addonVersion)

local addonMain = LibStub("AceAddon-3.0"):NewAddon("GameUtility-RepBars", "AceConsole-3.0")

-- function addonMain:MiniMapIconToggle()
-- 	self.db.profile.minimap.hide = not self.db.profile.minimap.hide
-- 	if self.db.profile.minimap.hide then
-- 		icon:Hide("GameUtility")
-- 	else
-- 		icon:Show("GameUtility")
-- 	end
-- end

function addonMain:CreateFactionBar(min, max, current)
    local factionBarFrame = CreateFrame("Frame", nil, GameUtilityAddonFrame) --With the name / header / title
    local factionBar = CreateFrame("StatusBar", nil, factionBarFrame)
    factionBarFrame:SetSize(100, 40)
    factionBarFrame:SetPoint("TOPLEFT", 50, -50)
    factionBar:SetSize(100, 20)
    factionBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    factionBar:SetMinMaxValues(min, max)
    factionBar:SetValue(current)
    factionBar:SetPoint("LEFT")
    factionBar:SetStatusBarColor(0, 1, 0)
    factionBar.bg = factionBar:CreateTexture(nil, "BACKGROUND")
    factionBar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    factionBar.bg:SetAllPoints(true)
    factionBar.bg:SetVertexColor(1, 0, 0)
    print("Het lieve schatje!!! <3 ik hou van you!")
    -- local factionProgressBar = CreateFrame("Frame", nil, factionBar)
    -- factionProgressBar:SetSize(20, 100)

    -- local factionProgressFiller = CreateFrame('Frame', nil, factionProgressBar)

    -- local a = current - min
    -- local b = max - min
    -- factionProgressFiller:SetPoint("LEFT", factionProgressBar, "LEFT", 0 ,0)
    -- factionProgressFiller:SetSize(20, a / b * 100)
    
    return factionBar
end

function addonMain:OnLoad(self)
    local GameUtilityAddonFrame = CreateFrame("FRAME", "GameUtilityAddonFrame", UIParent)
    GameUtilityAddonFrame:SetPoint("CENTER", 0, 0)
    GameUtilityAddonFrame.texture = GameUtilityAddonFrame:CreateTexture()
    GameUtilityAddonFrame.texture:SetAllPoints(true)
    GameUtilityAddonFrame:EnableMouse(true)
    GameUtilityAddonFrame:SetMovable(true)
    --GameUtilityAddonFrame:SetScript("OnUpdate", function(...) addonMain:OnUpdate(...) end)
    GameUtilityAddonFrame:SetScript("OnEvent", function(...) addonMain:OnEvent(...) end)
    GameUtilityAddonFrame:RegisterForDrag("LeftButton")
    GameUtilityAddonFrame:SetScript("OnDragStart", GameUtilityAddonFrame.StartMoving)
    GameUtilityAddonFrame:SetScript("OnDragStop", GameUtilityAddonFrame.StopMovingOrSizing)
    GameUtilityAddonFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    GameUtilityAddonFrame:RegisterEvent("UPDATE_FACTION")
    GameUtilityAddonFrame:RegisterEvent("LFG_BONUS_FACTION_ID_UPDATED")
    --GameUtilityAddonFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    --GameUtilityAddonFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    --GameUtilityAddonFrame.TimeSinceLastUpdate = 0
    --GameUtilityAddonFrame.MinuteCounter = 0
    GameUtilityAddonFrame:SetSize(800, 400)
    GameUtilityAddonFrame.texture:SetColorTexture(0.5, 0.5, 0.5, 0.5)

    addonMain:CreateFactionBar(0, 1000, 666)

    local AddonTitle = GameUtilityAddonFrame:CreateFontString("AddonTitle", "ARTWORK", "GameFontNormal")
    AddonTitle:SetText(nameFull)
    AddonTitle:SetHeight("10")
    AddonTitle:SetPoint("TOP", "GameUtilityAddonFrame", -100, -3)
    local repBarFrames = {}
    for i=1, 10 do
        local FrameName
        if FrameName ~= nil then

        end
    end


    TempTestButton1 = CreateFrame("Button", "TempTestButton1", GameUtilityAddonFrame, "UIPanelButtonTemplate")
    TempTestButton1.contentText = TempTestButton1:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    TempTestButton1.contentText:SetText("TEST!")
    TempTestButton1:SetWidth("100")
    TempTestButton1:SetHeight("25")
    TempTestButton1.contentText:SetWidth("100")
    TempTestButton1.contentText:SetHeight("15")
    TempTestButton1:SetPoint("TOP", 100, -25)
    TempTestButton1.contentText:SetPoint("CENTER", 0, -1)
    TempTestButton1:SetScript("OnClick", function() addonMain:testButtonClicked() end )

    OptionsPanel = CreateFrame("FRAME", "AZP-GU-OptionsPanel")
    OptionsPanel.name = "AzerPUG GameUtility"
    InterfaceOptions_AddCategory(OptionsPanel)

    local OptionsHeader = OptionsPanel:CreateFontString("OptionsHeader", "ARTWORK", "GameFontNormalHuge")
    OptionsHeader:SetText(promo .. dash .. "Options")
    OptionsHeader:SetWidth(OptionsPanel:GetWidth())
    OptionsHeader:SetHeight(OptionsPanel:GetHeight())
    OptionsHeader:SetPoint("TOP", 0, -10)
    
    local defaultScrollBehaviour = ReputationListScrollFrame:GetScript("OnVerticalScroll")
    ReputationListScrollFrame:SetScript("OnVerticalScroll", function(...)
        defaultScrollBehaviour(...)
        addonMain:updateFactionCheckboxes()
    end)
    local defaultFrameShowBehaviour = ReputationFrame:GetScript("OnShow")
    ReputationFrame:SetScript("OnShow", function(...)
        defaultFrameShowBehaviour(...)
        addonMain:updateFactionCheckboxes() 
    end)
end

function addonMain:initializeConfig()
    
end

function addonMain:OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        GameUtilityAddonFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        addonMain:initializeConfig()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
    elseif event == "UPDATE_FACTION" or event == "LFG_BONUS_FACTION_ID_UPDATED" then
        addonMain:updateFactionCheckboxes()
    end
end

function addonMain:updateFactionCheckboxes()
    for i=1,15 do
        local factionBarFrame = _G["ReputationBar" .. i]
        if factionBarFrame["index"] == nil then
            return
        elseif factionBarFrame.itemCheckBox == nil then
            factionBarFrame.itemCheckBox = CreateFrame("CheckButton", nil, factionBarFrame, "ChatConfigCheckButtonTemplate")
            factionBarFrame.itemCheckBox:SetSize(20, 20)
            factionBarFrame.itemCheckBox:SetPoint("LEFT", -15, 0)
            factionBarFrame.itemCheckBox:SetChecked(true)
            factionBarFrame.itemCheckBox:SetScript("OnClick", function(sender) print("hey!" .. sender:GetParent().index) end)
        end

        local faction, min, max, value, isHeader, factioId = addonMain:getUsefulFactionInfo(factionBarFrame["index"])
        if isHeader then
            factionBarFrame.itemCheckBox:Hide()
        else
            factionBarFrame.itemCheckBox:Show()
        end
    end
    -- Look for event to update faction screen, save state in SavedVariable, iterate faction screen using GetFactionInfo, render rep bars using GetFactionInfoByID.
    
end

function addonMain:getUsefulFactionInfo(index)
    local faction, _, _, min, max, value, _, _, isHeader, _, _, _, _, factionId = GetFactionInfo(index)
    return faction, min, max, value, isHeader, factionId
end

function addonMain:testButtonClicked()
    -- Get Specific reputation, current / max. Show numbers / percentage. Show name of current level (honored / revered / exalted / paragon).
end

addonMain:OnLoad()