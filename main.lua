local GlobalAddonName, AGU = ...

local initialConfig = AGU.initialConfig

local AZPGURepBarsVersion = 0.2
local dash = " - "
local name = "GameUtility" .. dash .. "RepBars"
local nameFull = ("AzerPUG " .. name)
local promo = (nameFull .. dash ..  AZPGURepBarsVersion)

local addonLoaded = false
local addonMain = LibStub("AceAddon-3.0"):NewAddon("GameUtility-RepBars", "AceConsole-3.0")

function AZP.GU.VersionControl:RepBars()
    return AZPGURepBarsVersion
end

function AZP.GU.OnLoad:RepBars(self)
    addonMain:initializeConfig()
    addonMain:drawProgressBars()

    local OptionsHeader = RepBarsSubPanel:CreateFontString("OptionsHeader", "ARTWORK", "GameFontNormalHuge")
    OptionsHeader:SetText(promo)
    OptionsHeader:SetWidth(RepBarsSubPanel:GetWidth())
    OptionsHeader:SetHeight(RepBarsSubPanel:GetHeight())
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

function addonMain:CreateFactionBar(standingID, min, max, current, name, factionID)
    if standingID == 8 then
        local currentValue, threshold = C_Reputation.GetFactionParagonInfo(factionID)
        if currentValue ~= nil and threshold ~= nil then
            current = (currentValue % 10000)
            max = 10000
            min = 0
            standingID = 9
        end
    end

    local factionBarFrame = CreateFrame("Frame", nil, GameUtilityProgressFrame)
    local factionBar = CreateFrame("StatusBar", nil, factionBarFrame)
    factionBarFrame:SetSize(300, 25)
    factionBarFrame:SetPoint("TOPLEFT", 10, -20)
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
    AZPAddonHelper:DelayedExecution(5, function() addonMain:drawProgressBars() end)
end

function AZP.GU.OnEvent:RepBars(self, event, ...)
    if event == "UPDATE_FACTION" or event == "LFG_BONUS_FACTION_ID_UPDATED" then
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
    -- Wire is this part done?
end

function addonMain:getUsefulFactionInfo(index)
    local faction, _, standingID, min, max, value, _, _, isHeader, _, _, _, _, factionId = GetFactionInfo(index)
    return faction, standingID, min, max, value, isHeader, factionId
end