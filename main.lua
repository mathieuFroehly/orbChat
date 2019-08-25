local _, L = ...;

local CHAT_EVENTS = {
    "CHAT_MSG_SAY",
    "CHAT_MSG_YELL",
    "CHAT_MSG_CHANNEL",
    "CHAT_MSG_TEXT_EMOTE",
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_BN_WHISPER",
    "CHAT_MSG_BN_WHISPER_INFORM",
    "CHAT_MSG_BN_CONVERSATION",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_OFFICER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER"
}

--------------------------------------------------------------------------------
-- Chat improvements
--------------------------------------------------------------------------------

local function RegisterChatImprovements()
    -- Add more chat font sizes
    for i = 1, 17 do
        CHAT_FONT_HEIGHTS[i] = i + 7
    end

    -- URL Replace stuff
    local function FormatUrl(url)
        return "|Hurl:"..tostring(url).."|h|cff0099FF"..tostring("["..url.."]").."|r|h"
    end

    local function UrlFilter(self, event, msg, ...)
        local foundUrl = false

        local msg2 = msg:gsub("(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)", function(before, url, after)
            foundUrl = true
            return before..FormatUrl(url)..after
        end)
        if not foundUrl then
            msg2 = msg:gsub("(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)", function(before, url, after)
                foundUrl = true
                return before..FormatUrl(url)..after
            end)
        end
        if not foundUrl then
            msg2 = msg:gsub("(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)", function(before, url, after)
                foundUrl = true
                return before..FormatUrl(url)..after
            end)
        end
        if not foundUrl then
            msg2 = msg:gsub("(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", function(before, url, after)
                foundUrl = true
                return before..FormatUrl(url)..after
            end)
        end
        if not foundUrl then
            msg2 = msg:gsub("(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", function(before, url, after)
                foundUrl = true
                return before..FormatUrl(url)..after
            end)
        end
        if not foundUrl then
            msg2 = msg:gsub("(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)", function(before, url, after)
                foundUrl = true
                return before..FormatUrl(url)..after
            end)
        end

        if msg2 ~= msg then
            return false, msg2, ...
        end
    end

    for _, event in pairs(CHAT_EVENTS) do
        ChatFrame_AddMessageEventFilter(event, UrlFilter)
    end

    StaticPopupDialogs["AnUI_UrlCopy"] = {
        text = L.URL_TEXT,
        button1 = L.URL_BTN1,
        button2 = L.URL_BTN2,
        hasEditBox = true,
        whileDead = true,
        hideOnEscape = true,
        timeout = 10,
        enterClicksFirstButton = true
    }

    local OriginalChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow
    function ChatFrame_OnHyperlinkShow(frame, link, text, button)
        local type, value = link:match("(%a+):(.+)")
        if (type == "url") then
            --local eb = LAST_ACTIVE_CHAT_EDIT_BOX or _G[frame:GetName().."EditBox"]
            --if eb then
            --    eb:SetText(value)
            --    eb:SetFocus()
            --    eb:HighlightText()
            --end
            local popup = StaticPopup_Show("AnUI_UrlCopy")
            popup.editBox:SetText(value)
            popup.editBox:SetFocus()
            popup.editBox:HighlightText()
        else
            OriginalChatFrame_OnHyperlinkShow(self, link, text, button)
        end
    end

    -- Make arrow keys work without alt in editboxes
    for i = 1, NUM_CHAT_WINDOWS do
        if i ~= 2 then
            local editBox = _G["ChatFrame"..i.."EditBox"]
            editBox:SetAltArrowKeyMode(false)
        end
    end

    -- TODO: chat history support
end

-----------------------------------------------------------------------------
-- Load the addon                                                          --
-----------------------------------------------------------------------------

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event)
    RegisterChatImprovements()
end)
