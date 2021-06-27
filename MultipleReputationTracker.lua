if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

AZP.VersionControl["Multiple Reputation Tracker"] = 16
if AZP.MultipleReputationTracker == nil then AZP.MultipleReputationTracker = {} end
if AZP.MultipleReputationTracker.Events == nil then AZP.MultipleReputationTracker.Events = {} end

local EventFrame, UpdateFrame

local addonLoaded = false
local MultipleReputationTrackerSelfFrame = nil
local AZPMRTSelfOptionPanel = nil
local MainFrame = nil
local ProgressBarsFrame
local optionHeader = "|cFF00FFFFMultiple Reputation Tracker|r"

function AZP.MultipleReputationTracker:OnLoadBoth(frame)
    MainFrame = frame

    ReputationListScrollFrame:HookScript("OnVerticalScroll", function(...)
        AZP.MultipleReputationTracker:updateFactionCheckboxes()
    end)
    ReputationFrame:HookScript("OnShow", function(...)
        AZP.MultipleReputationTracker:updateFactionCheckboxes()
    end)
end

function AZP.MultipleReputationTracker:OnLoadCore()
    AZP.MultipleReputationTracker:OnLoadBoth(AZP.Core.AddOns.MRT.MainFrame)

    AZP.Core:RegisterEvents("VARIABLES_LOADED", function() AZP.MultipleReputationTracker.Events:VariablesLoaded() end)
    AZP.Core:RegisterEvents("UPDATE_FACTION", function() AZP.MultipleReputationTracker:updateFactionCheckboxes() end)

    AZP.OptionsPanels:RemovePanel("Multiple Reputation Tracker")
    AZP.OptionsPanels:Generic("Multiple Reputation Tracker", optionHeader, function(frame)
        AZP.MultipleReputationTracker:FillOptionsPanel(frame)
    end)
end

function AZP.MultipleReputationTracker:OnLoadSelf()
    EventFrame = CreateFrame("Frame")
    EventFrame:SetScript("OnEvent", function(...) AZP.MultipleReputationTracker:OnEvent(...) end)
    EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    EventFrame:RegisterEvent("CHAT_MSG_ADDON")
    EventFrame:RegisterEvent("VARIABLES_LOADED")
    EventFrame:RegisterEvent("UPDATE_FACTION")

    AZPMRTSelfOptionPanel = CreateFrame("FRAME", nil)
    AZPMRTSelfOptionPanel.name = optionHeader
    InterfaceOptions_AddCategory(AZPMRTSelfOptionPanel)
    AZPMRTSelfOptionPanel.header = AZPMRTSelfOptionPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    AZPMRTSelfOptionPanel.header:SetPoint("TOP", 0, -10)
    AZPMRTSelfOptionPanel.header:SetText("|cFF00FFFFAzerPUG's Multiple Reputation Tracker Options!|r")

    AZPMRTSelfOptionPanel.footer = AZPMRTSelfOptionPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    AZPMRTSelfOptionPanel.footer:SetPoint("TOP", 0, -300)
    AZPMRTSelfOptionPanel.footer:SetText(
        "|cFF00FFFFAzerPUG Links:\n" ..
        "Website: www.azerpug.com\n" ..
        "Discord: www.azerpug.com/discord\n" ..
        "Twitch: www.twitch.tv/azerpug\n|r"
    )

    UpdateFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    UpdateFrame:SetPoint("CENTER", 0, 250)
    UpdateFrame:SetSize(400, 200)
    UpdateFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    UpdateFrame:SetBackdropColor(0.25, 0.25, 0.25, 0.80)
    UpdateFrame.header = UpdateFrame:CreateFontString("UpdateFrame", "ARTWORK", "GameFontNormalHuge")
    UpdateFrame.header:SetPoint("TOP", 0, -10)
    UpdateFrame.header:SetText("|cFFFF0000AzerPUG Multiple Reputation Tracker is out of date!|r")

    UpdateFrame.text = UpdateFrame:CreateFontString("UpdateFrame", "ARTWORK", "GameFontNormalLarge")
    UpdateFrame.text:SetPoint("TOP", 0, -40)
    UpdateFrame.text:SetText("Error!")

    UpdateFrame:Hide()

    local UpdateFrameCloseButton = CreateFrame("Button", nil, UpdateFrame, "UIPanelCloseButton")
    UpdateFrameCloseButton:SetWidth(25)
    UpdateFrameCloseButton:SetHeight(25)
    UpdateFrameCloseButton:SetPoint("TOPRIGHT", UpdateFrame, "TOPRIGHT", 2, 2)
    UpdateFrameCloseButton:SetScript("OnClick", function() UpdateFrame:Hide() end )

    AZP.MultipleReputationTracker:CreateSelfMainFrame()
    AZP.MultipleReputationTracker:OnLoadBoth(MultipleReputationTrackerSelfFrame)
end

function AZP.MultipleReputationTracker:CreateSelfMainFrame()
    MultipleReputationTrackerSelfFrame = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
    MultipleReputationTrackerSelfFrame:SetSize(325, 220)
    MultipleReputationTrackerSelfFrame:SetPoint("CENTER", 0, 0)
    MultipleReputationTrackerSelfFrame:SetScript("OnDragStart", MultipleReputationTrackerSelfFrame.StartMoving)
    MultipleReputationTrackerSelfFrame:SetScript("OnDragStop", function()
        MultipleReputationTrackerSelfFrame:StopMovingOrSizing()
        AZP.MultipleReputationTracker:SaveMainFrameLocation()
    end)
    MultipleReputationTrackerSelfFrame:RegisterForDrag("LeftButton")
    MultipleReputationTrackerSelfFrame:EnableMouse(true)
    MultipleReputationTrackerSelfFrame:SetMovable(true)
    MultipleReputationTrackerSelfFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    MultipleReputationTrackerSelfFrame:SetBackdropColor(0.5, 0.5, 0.5, 0.75)

    local IUAddonFrameCloseButton = CreateFrame("Button", nil, MultipleReputationTrackerSelfFrame, "UIPanelCloseButton")
    IUAddonFrameCloseButton:SetSize(20, 21)
    IUAddonFrameCloseButton:SetPoint("TOPRIGHT", MultipleReputationTrackerSelfFrame, "TOPRIGHT", 2, 2)
    IUAddonFrameCloseButton:SetScript("OnClick", function() AZP.MultipleReputationTracker:ShowHideFrame() end )
end

function AZP.MultipleReputationTracker:CreateFactionBar(standingID, min, max, current, name, factionID)
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

    local rValue, gValue, bValue, Text = AZP.MultipleReputationTracker:GetStandingAndColor(standingID)
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

function AZP.MultipleReputationTracker:GetStandingAndColor(standingID)
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

function AZP.MultipleReputationTracker:drawProgressBars()
    if ProgressBarsFrame ~= nil then
       ProgressBarsFrame:Hide()
       ProgressBarsFrame:SetParent(nil)
       ProgressBarsFrame = nil
    end

    ProgressBarsFrame = CreateFrame("Button", "ProgressBarsFrame", MainFrame)
    ProgressBarsFrame:SetSize(MainFrame:GetWidth() - 20, MainFrame:GetHeight())
    ProgressBarsFrame:SetPoint("TOPLEFT", 0, 0)
    ProgressBarsFrame:EnableMouse(false)

    local last = nil
    for factionID, _ in pairs(AZPGURepBarsData["checkFactionIDs"]) do
        local faction, _, standingID, min, max, value, _, _, isHeader, _, _, _, _, _ = GetFactionInfoByID(factionID)
        local cur = AZP.MultipleReputationTracker:CreateFactionBar(standingID, min, max, value, faction, factionID)
        if last ~= nil then
            cur:SetPoint("TOPLEFT", last, "BOTTOMLEFT")
        end
        last = cur
    end
end

function AZP.MultipleReputationTracker.Events:ChatMsgAddon(...)
    local prefix, payload, _, sender = ...
    if prefix == "AZPVERSIONS" then
        local version = AZP.MultipleReputationTracker:GetSpecificAddonVersion(payload, "MRT")
        if version ~= nil then
            AZP.MultipleReputationTracker:ReceiveVersion(version)
        end
    end
end

function AZP.MultipleReputationTracker:OnEvent(self, event, ...)
    --if event == "UPDATE_FACTION" or event == "LFG_BONUS_FACTION_ID_UPDATED" then
    if event == "UPDATE_FACTION" then
        AZP.MultipleReputationTracker:updateFactionCheckboxes()
    elseif event == "VARIABLES_LOADED" then
        AZP.MultipleReputationTracker.Events:VariablesLoaded()
        AZP.MultipleReputationTracker.Events:VariablesLoadedLocation()
    elseif event == "CHAT_MSG_ADDON" then
        AZP.MultipleReputationTracker.Events:ChatMsgAddon(...)
    elseif event == "GROUP_ROSTER_UPDATE" then
        AZP.MultipleReputationTracker:ShareVersion()
    end
end

function AZP.MultipleReputationTracker.Events:VariablesLoaded()
    if AZPGURepBarsData == nil then
        AZPGURepBarsData = AZP.MultipleReputationTracker.RepBarsConfig
    end
    AZP.MultipleReputationTracker:updateFactionCheckboxes()
    AZP.MultipleReputationTracker:drawProgressBars()
    AZP.MultipleReputationTracker:ShareVersion()
end

function AZP.MultipleReputationTracker.Events:VariablesLoadedLocation()
    if AZPMRTShown == false then
        MultipleReputationTrackerSelfFrame:Hide()
    end

    if AZPMRTLocation == nil then
        AZPMRTLocation = {"CENTER", nil, nil, 200, 0}
    end
    MultipleReputationTrackerSelfFrame:SetPoint(AZPMRTLocation[1], AZPMRTLocation[4], AZPMRTLocation[5])
end

function AZP.MultipleReputationTracker:updateFactionCheckboxes()
    for i=1,15 do
        local factionBarFrame = _G["ReputationBar" .. i]
        if factionBarFrame["index"] == nil then
            return
        elseif factionBarFrame.itemCheckBox == nil then
            factionBarFrame.itemCheckBox = CreateFrame("CheckButton", nil, factionBarFrame, "ChatConfigBaseCheckButtonTemplate")
            factionBarFrame.itemCheckBox:SetSize(20, 20)
            factionBarFrame.itemCheckBox:SetPoint("RIGHT", 25, 0)
            factionBarFrame.itemCheckBox:SetScript("OnClick", function(sender)
                local faction, standingID, min, max, value, isHeader, factionID = AZP.MultipleReputationTracker:getUsefulFactionInfo(sender:GetParent().index)
                if sender:GetChecked() == true then
                    AZPGURepBarsData["checkFactionIDs"][factionID] = true
                else
                    AZPGURepBarsData["checkFactionIDs"][factionID] = nil
                end
                AZP.MultipleReputationTracker:drawProgressBars()
            end)
        end

        local faction, standingID, min, max, current, isHeader, factionID = AZP.MultipleReputationTracker:getUsefulFactionInfo(factionBarFrame["index"])
        if isHeader then
            factionBarFrame.itemCheckBox:Hide()
        else
            factionBarFrame.itemCheckBox:Show()
            factionBarFrame.itemCheckBox:SetChecked(AZPGURepBarsData["checkFactionIDs"][factionID])
        end

        if standingID == 8 then
            local currentValue, threshold = C_Reputation.GetFactionParagonInfo(factionID)
            if currentValue ~= nil and threshold ~= nil then
                current = (currentValue % 10000)
                max = 10000
                min = 0
                standingID = 9
            end
        end

        local factionBarReputationBar = _G["ReputationBar" .. i .. "ReputationBar"]
        local rValue, gValue, bValue, Text = AZP.MultipleReputationTracker:GetStandingAndColor(standingID)
        factionBarReputationBar:SetStatusBarColor(rValue, gValue, bValue)
        factionBarReputationBar:SetMinMaxValues(min, max)
        factionBarReputationBar:SetValue(current)

        local factionBarReputationBarText= _G["ReputationBar" .. i .. "ReputationBarFactionStanding"]
        factionBarReputationBarText:SetText(Text)

    end
end

function AZP.MultipleReputationTracker:ShareVersion()
    local versionString = string.format("|MRT:%d|", AZP.VersionControl["Multiple Reputation Tracker"])
    if UnitInBattleground("player") ~= nil then
        -- BG stuff?
    else
        if IsInGroup() then
            if IsInRaid() then
                C_ChatInfo.SendAddonMessage("AZPVERSIONS", versionString ,"RAID", 1)
            else
                C_ChatInfo.SendAddonMessage("AZPVERSIONS", versionString ,"PARTY", 1)
            end
        end
        if IsInGuild() then
            C_ChatInfo.SendAddonMessage("AZPVERSIONS", versionString ,"GUILD", 1)
        end
    end
end

function AZP.MultipleReputationTracker:ReceiveVersion(version)
    if version > AZP.VersionControl["Multiple Reputation Tracker"] then
        if (not HaveShowedUpdateNotification) then
            HaveShowedUpdateNotification = true
            UpdateFrame:Show()
            UpdateFrame.text:SetText(
                "Please download the new version through the CurseForge app.\n" ..
                "Or use the CurseForge website to download it manually!\n\n" .. 
                "Newer Version: v" .. version .. "\n" .. 
                "Your version: v" .. AZP.VersionControl["Multiple Reputation Tracker"]
            )
        end
    end
end

function AZP.MultipleReputationTracker:GetSpecificAddonVersion(versionString, addonWanted)
    local pattern = "|([A-Z]+):([0-9]+)|"
    local index = 1
    while index < #versionString do
        local _, endPos = string.find(versionString, pattern, index)
        local addon, version = string.match(versionString, pattern, index)
        index = endPos + 1
        if addon == addonWanted then
            return tonumber(version)
        end
    end
end

function AZP.MultipleReputationTracker:ShowHideFrame()
    if MultipleReputationTrackerSelfFrame:IsShown() then
        MultipleReputationTrackerSelfFrame:Hide()
        AZPMRTShown = false
    elseif not MultipleReputationTrackerSelfFrame:IsShown() then
        MultipleReputationTrackerSelfFrame:Show()
        AZPMRTShown = true
    end
end

function AZP.MultipleReputationTracker:SaveMainFrameLocation()
    local temp = {}
    temp[1], temp[2], temp[3], temp[4], temp[5] = MultipleReputationTrackerSelfFrame:GetPoint()
    AZPMRTLocation = temp
end

function AZP.MultipleReputationTracker:getUsefulFactionInfo(index)
    local faction, _, standingID, min, max, value, _, _, isHeader, _, _, _, _, factionId = GetFactionInfo(index)
    return faction, standingID, min, max, value, isHeader, factionId
end

function AZP.MultipleReputationTracker:FillOptionsPanel(frameToFill)
    frameToFill:Hide()
end

if not IsAddOnLoaded("AzerPUGsCore") then
    AZP.MultipleReputationTracker:OnLoadSelf()
end

AZP.SlashCommands["MRT"] = function()
    if MultipleReputationTrackerSelfFrame ~= nil then AZP.MultipleReputationTracker:ShowHideFrame() end
end

AZP.SlashCommands["mrt"] = AZP.SlashCommands["MRT"]
AZP.SlashCommands["rep"] = AZP.SlashCommands["MRT"]
AZP.SlashCommands["multiple reputation tracker"] = AZP.SlashCommands["MRT"]