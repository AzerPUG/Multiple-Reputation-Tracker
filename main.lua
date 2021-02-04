local GlobalAddonName, AGU = ...

local RepBarsConfig = AGU.RepBarsConfig

local AZPGURepBarsVersion = 12
local dash = " - "
local name = "GameUtility" .. dash .. "RepBars"
local nameFull = ("AzerPUG " .. name)
local promo = (nameFull .. dash ..  AZPGURepBarsVersion)

local addonLoaded = false
local addonMain = LibStub("AceAddon-3.0"):NewAddon("GameUtility-RepBars", "AceConsole-3.0")

local ModuleStats = AZP.GU.ModuleStats
local ProgressBarsFrame

function AZP.GU.VersionControl:RepBars()
    return AZPGURepBarsVersion
end

function AZP.GU.OnLoad:RepBars(self)
    addonMain:initializeConfig()
    addonMain:drawProgressBars()

    ModuleStats["Frames"]["RepBars"]:SetSize(400, 300)
    addonMain:ChangeOptionsText()

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

    local factionBarFrame = CreateFrame("Frame", nil, ProgressBarsFrame)
    local factionBar = CreateFrame("StatusBar", nil, factionBarFrame)
    factionBarFrame:SetSize(300, 25)
    factionBarFrame:SetPoint("TOPLEFT", 10, -10)
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
    factionBar.contentText:SetPoint("TOPLEFT")
    factionBar.contentText:SetSize(150, 20)

    local rValue, gValue, bValue, Text = addonMain:GetStandingAndColor(standingID)
    factionBar:SetStatusBarColor(rValue, gValue, bValue)
    factionBar.contentText:SetText(Text)

    factionBar:SetScript("OnEnter", function()
        factionBar.contentText:SetText(current .. "/" .. max .. " (" .. math.floor(current/max*100) .. "%)")
    end)
    factionBar:SetScript("OnLeave", function()
        factionBar.contentText:SetText(Text)
    end)
    return factionBarFrame
end

function addonMain:GetStandingAndColor(standingID)
    if standingID == 1 then                             -- Hated
        return 1, 0, 0, "Hated"
    elseif standingID == 2 then                         -- Hostile
        return 1, 0.25, 0, "Hostile"
    elseif standingID == 3 then                         -- Unfriendly
        return 1, 0.5, 0, "Unfriendly"
    elseif standingID == 4 then                         -- Neutral
        return 1, 0.75, 0, "Neutral"
    elseif standingID == 5 then                         -- Friendly
        return 0, 0.4, 0, "Friendly"
    elseif standingID == 6 then                         -- Honored
        return 0, 0.6, 0, "Honored"
    elseif standingID == 7 then                         -- Revered
        return 0, 0.8, 0, "Revered"
    elseif standingID == 8 then                         -- Exalted
        return 0, 1, 0, "Exalted"
    elseif standingID == 9 then                         -- Paragon
        return 0, 1, 1, "Paragon"
    end
end

function addonMain:drawProgressBars()
    if ProgressBarsFrame ~= nil then
       ProgressBarsFrame:Hide()
       ProgressBarsFrame:SetParent(nil)
       ProgressBarsFrame = nil
    end

    ProgressBarsFrame = CreateFrame("Button", "ProgressBarsFrame", ModuleStats["Frames"]["RepBars"])
    ProgressBarsFrame:SetSize(ModuleStats["Frames"]["RepBars"]:GetWidth(), ModuleStats["Frames"]["RepBars"]:GetHeight())
    ProgressBarsFrame:SetPoint("TOPLEFT", 0, 0)

    local last = nil
    for factionID, _ in pairs(AZPGURepBarsData["checkFactionIDs"]) do
        local faction, _, standingID, min, max, value, _, _, isHeader, _, _, _, _, _ = GetFactionInfoByID(factionID)
        local cur = addonMain:CreateFactionBar(standingID, min, max, value, faction, factionID)
        if last ~= nil then
            cur:SetPoint("TOPLEFT", last, "BOTTOMLEFT")
        end
        last = cur
    end
end

function addonMain:initializeConfig()
    if AZPGURepBarsData == nil then
        AZPGURepBarsData = RepBarsConfig
    end
    addonMain:updateFactionCheckboxes()
    AZPAddonHelper:DelayedExecution(5, function() addonMain:drawProgressBars() end)
end

function AZP.GU.OnEvent:RepBars(event, ...)
    --if event == "UPDATE_FACTION" or event == "LFG_BONUS_FACTION_ID_UPDATED" then
    if event == "UPDATE_FACTION" then
        addonMain:updateFactionCheckboxes()
    end
end

function addonMain:updateFactionCheckboxes()
    for i=1,15 do
        local factionBarFrame = _G["ReputationBar" .. i]
        if factionBarFrame["index"] == nil then
            return
        elseif factionBarFrame.itemCheckBox == nil then
            --factionBarFrame.itemCheckBox = CreateFrame("CheckButton", nil, factionBarFrame, "ChatConfigCheckButtonTemplate")
            factionBarFrame.itemCheckBox = CreateFrame("CheckButton", nil, factionBarFrame, "ChatConfigBaseCheckButtonTemplate")
            factionBarFrame.itemCheckBox:SetSize(20, 20)
            factionBarFrame.itemCheckBox:SetPoint("RIGHT", 25, 0)
            factionBarFrame.itemCheckBox:SetScript("OnClick", function(sender)
                local faction, standingID, min, max, value, isHeader, factionID = addonMain:getUsefulFactionInfo(sender:GetParent().index)
                if sender:GetChecked() == true then
                    AZPGURepBarsData["checkFactionIDs"][factionID] = true
                else
                    AZPGURepBarsData["checkFactionIDs"][factionID] = nil
                end
                addonMain:drawProgressBars()
            end)
        end

        local faction, standingID, min, max, value, isHeader, factionID = addonMain:getUsefulFactionInfo(factionBarFrame["index"])
        if isHeader then
            factionBarFrame.itemCheckBox:Hide()
        else
            factionBarFrame.itemCheckBox:Show()
            factionBarFrame.itemCheckBox:SetChecked(AZPGURepBarsData["checkFactionIDs"][factionID])
        end
    end
end

function addonMain:getUsefulFactionInfo(index)
    local faction, _, standingID, min, max, value, _, _, isHeader, _, _, _, _, factionId = GetFactionInfo(index)
    return faction, standingID, min, max, value, isHeader, factionId
end

function addonMain:ChangeOptionsText()
    RepBarsSubPanelPHTitle:Hide()
    RepBarsSubPanelPHText:Hide()
    RepBarsSubPanelPHTitle:SetParent(nil)
    RepBarsSubPanelPHText:SetParent(nil)

    local RepBarsSubPanelHeader = RepBarsSubPanel:CreateFontString("RepBarsSubPanelHeader", "ARTWORK", "GameFontNormalHuge")
    RepBarsSubPanelHeader:SetText(promo)
    RepBarsSubPanelHeader:SetWidth(RepBarsSubPanel:GetWidth())
    RepBarsSubPanelHeader:SetHeight(RepBarsSubPanel:GetHeight())
    RepBarsSubPanelHeader:SetPoint("TOP", 0, -10)

    local RepBarsSubPanelText = RepBarsSubPanel:CreateFontString("RepBarsSubPanelText", "ARTWORK", "GameFontNormalHuge")
    RepBarsSubPanelText:SetWidth(RepBarsSubPanel:GetWidth())
    RepBarsSubPanelText:SetHeight(RepBarsSubPanel:GetHeight())
    RepBarsSubPanelText:SetPoint("TOPLEFT", 0, -50)
    RepBarsSubPanelText:SetText(
        "AzerPUG-GameUtility-RepBars does not have options yet.\n" ..
        "For feature requests visit our Discord Server!"
    )
end