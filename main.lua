local GlobalAddonName, AGU = ...

local OptionsPanel

local initialConfig = AGU.initialConfig

local addonVersion = "v0.1"
local dash = " - "
local name = "GameUtility" .. dash .. "RepBaws"
local nameFull = ("AzerPUG " .. name)
local promo = (nameFull .. dash ..  addonVersion)

local addonLoaded = false

local addonMain = LibStub("AceAddon-3.0"):NewAddon("GameUtility-RepBars", "AceConsole-3.0")

-- function addonMain:MiniMapIconToggle()
-- 	self.db.profile.minimap.hide = not self.db.profile.minimap.hide
-- 	if self.db.profile.minimap.hide then
-- 		icon:Hide("GameUtility")
-- 	else
-- 		icon:Show("GameUtility")
-- 	end
-- end

function addonMain:CreateFactionBar(standingID, min, max, current, name, factionID)

    --  TODO: Add Paragon Reputation Stuff: https://wow.gamepedia.com/API_C_Reputation.GetFactionParagonInfo
    --  If Paragonrep: Change StandinID to 9, Change min/max to other numbers.

    if standingID == 8 then
        local currentValue, threshold, rewardQuestID, hasRewardPending, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(factionID)
        if currentValue ~= nil and threshold ~= nil then
            current = (currentValue % 10000)
            max = 10000
            min = 0
            standingID = 9
        end
    end

    local factionBarFrame = CreateFrame("Frame", nil, GameUtilityProgressFrame) --With the name / header / title
    local factionBar = CreateFrame("StatusBar", nil, factionBarFrame)
    factionBarFrame:SetSize(300, 25)
    factionBarFrame:SetPoint("TOPLEFT", 50, -50)
    factionBarFrame.contentText = factionBarFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    factionBarFrame.contentText:SetText(name)
    factionBarFrame.contentText:SetPoint("LEFT")
    factionBarFrame.contentText:SetSize(150, 20)
    factionBarFrame.contentText:SetJustifyH("LEFT")
    factionBar:SetSize(150, 20)
    factionBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    if min == max then min = 0 end
    factionBar:SetMinMaxValues(min, max)
    factionBar:SetValue(current)
    factionBar:SetPoint("RIGHT")
    factionBar.bg = factionBar:CreateTexture(nil, "BACKGROUND")
    factionBar.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    factionBar.bg:SetAllPoints(true)
    factionBar.bg:SetVertexColor(0, 0, 0)
    factionBar.contentText = factionBar:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    factionBar.contentText:SetPoint("CENTER")
    factionBar.contentText:SetSize(150, 20)

    if standingID == 1 then                             -- Hated
        factionBar:SetStatusBarColor(1, 0, 0)
        factionBar.contentText:SetText("Hated")
    elseif standingID == 2 then                         -- Hostile
        factionBar:SetStatusBarColor(1, 0.25, 0)
        factionBar.contentText:SetText("Hostile")
    elseif standingID == 3 then                         -- Unfriendly
        factionBar:SetStatusBarColor(1, 0.5, 0)
        factionBar.contentText:SetText("Unfriendly")
    elseif standingID == 4 then                         -- Neutral
        factionBar:SetStatusBarColor(1, 0.75, 0)
        factionBar.contentText:SetText("Neutral")
    elseif standingID == 5 then                         -- Friendly
        factionBar:SetStatusBarColor(0, 0.4, 0)
        factionBar.contentText:SetText("Friendly")
    elseif standingID == 6 then                         -- Honored
        factionBar:SetStatusBarColor(0, 0.6, 0)
        factionBar.contentText:SetText("Honored")
    elseif standingID == 7 then                         -- Revered
        factionBar:SetStatusBarColor(0, 0.8, 0)
        factionBar.contentText:SetText("Revered")
    elseif standingID == 8 then                         -- Exalted
        factionBar:SetStatusBarColor(0, 1, 0)
        factionBar.contentText:SetText("Exalted")
    elseif standingID == 9 then                         -- Paragon
        factionBar:SetStatusBarColor(0, 1, 1)
        factionBar.contentText:SetText("Paragon")
    end
    
    return factionBarFrame
end

function addonMain:OnLoad(self)
    addonMain:initializeConfig()
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

    addonMain:drawProgressBars()


    TempTestButton1 = CreateFrame("Button", "TempTestButton1", GameUtilityAddonFrame, "UIPanelButtonTemplate")
    TempTestButton1.contentText = TempTestButton1:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    TempTestButton1.contentText:SetText("TEST!")
    TempTestButton1:SetWidth("100")
    TempTestButton1:SetHeight("25")
    TempTestButton1.contentText:SetWidth("100")
    TempTestButton1.contentText:SetHeight("15")
    TempTestButton1:SetPoint("TOP", 100, -25)
    TempTestButton1.contentText:SetPoint("CENTER", 0, -1)
    TempTestButton1:SetScript("OnClick", function() ReloadUI() end )

    

    local OptionsHeader = AZPGUOptionsSubPanelRepBars:CreateFontString("OptionsHeader", "ARTWORK", "GameFontNormalHuge")
    OptionsHeader:SetText(promo .. dash .. "Options")
    OptionsHeader:SetWidth(AZPGUOptionsSubPanelRepBars:GetWidth())
    OptionsHeader:SetHeight(AZPGUOptionsSubPanelRepBars:GetHeight())
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

function addonMain:drawProgressBars()
    if GameUtilityProgressFrame ~= nil then
        GameUtilityProgressFrame:Hide()
        GameUtilityProgressFrame:SetParent(nil)
        GameUtilityProgressFrame = nil
    end
    local ProgressFrame = CreateFrame("Frame", "GameUtilityProgressFrame", GameUtilityAddonFrame)
    ProgressFrame:SetPoint("TOPLEFT")
    ProgressFrame:SetSize(400, 600)

    local last = nil
    for factionID,_ in pairs(AGUCheckedData["checkFactionIDs"]) do
        local faction, _, standingID, min, max, value, _, _, isHeader, _, _, _, _, _ = GetFactionInfoByID(factionID)
        local cur = addonMain:CreateFactionBar(standingID, min, max, value, faction, factionID)
        if last ~= nil then
            cur:SetPoint("TOPLEFT", last, "BOTTOMLEFT")
        end
        last = cur
    end
end

function addonMain:initializeConfig()
    if AGUCheckedData == nil then
        AGUCheckedData = initialConfig
    end
    addonMain:updateFactionCheckboxes()
end

function addonMain:OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        GameUtilityAddonFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
    elseif event == "UPDATE_FACTION" or event == "LFG_BONUS_FACTION_ID_UPDATED" then
        addonMain:updateFactionCheckboxes()
    elseif event == "ADDON_LOADED" then
        if addonLoaded == false then
            AZPAddonHelper:DelayedExecution(5, function() addonMain:initializeConfig() end)
            addonLoaded = true
        end
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
            factionBarFrame.itemCheckBox:SetPoint("RIGHT", 25, 0)
            factionBarFrame.itemCheckBox:SetScript("OnClick", function(sender)
                local faction, standingID, min, max, value, isHeader, factionID = addonMain:getUsefulFactionInfo(sender:GetParent().index)
                if sender:GetChecked() == true then
                    AGUCheckedData["checkFactionIDs"][factionID] = true
                else
                    AGUCheckedData["checkFactionIDs"][factionID] = nil
                end
                addonMain:drawProgressBars()
            end)
        end

        local faction, standingID, min, max, value, isHeader, factionID = addonMain:getUsefulFactionInfo(factionBarFrame["index"])
        if isHeader then
            factionBarFrame.itemCheckBox:Hide()
        else
            factionBarFrame.itemCheckBox:Show()
            factionBarFrame.itemCheckBox:SetChecked(AGUCheckedData["checkFactionIDs"][factionID])
        end
    end
    -- Look for event to update faction screen, save state in SavedVariable, iterate faction screen using GetFactionInfo, render rep bars using GetFactionInfoByID.
    
end

function addonMain:getUsefulFactionInfo(index)
    local faction, _, standingID, min, max, value, _, _, isHeader, _, _, _, _, factionId = GetFactionInfo(index)
    return faction, standingID, min, max, value, isHeader, factionId
end

function addonMain:testButtonClicked()
    -- Get Specific reputation, current / max. Show numbers / percentage. Show name of current level (honored / revered / exalted / paragon).
end

addonMain:OnLoad()