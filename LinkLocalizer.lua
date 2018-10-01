-------------------------
-- Link Localizer      --
-- a BR addon          --
--                     --
-------------------------

local chatChannels = {
	CHAT_MSG_GUILD = true,
	CHAT_MSG_RAID = true,
	CHAT_MSG_PARTY = true,
	CHAT_MSG_WHISPER = true,
	CHAT_MSG_SAY = true,
	CHAT_MSG_YELL = true,
	CHAT_MSG_CHANNEL = true,
	CHAT_MSG_BATTLEGROUND = true,
}

local LinkLocalizer = CreateFrame("GameTooltip", "LLTooltip", UIParent, "GameTooltipTemplate")
LinkLocalizer:RegisterEvent("ADDON_LOADED")

------------------------------------------------------------------------------------------------------------
---------------------OBTAIN TITLE FROM TOOLTIP - COPIED FROM THE WEB WITH A SMALL CHANGE -------------------
------------------------------------------------------------------------------------------------------------
--MyScanningTooltip = CreateFrame( "GameTooltip", "MyScanningTooltip", nil, "GameTooltipTemplate" )
local NameFromTooltip = setmetatable({}, { __index = function(t, link)
         LinkLocalizer:SetOwner(UIParent, "ANCHOR_NONE")
         LinkLocalizer:SetHyperlink(link)
         local title = LLTooltipTextLeft1:GetText()
         LinkLocalizer:Hide()
         if title and title ~= RETRIEVING_DATA and title ~= RETRIEVING_ITEM_INFO then
            t[link] = title
            return title
         end
end })

------------------------------------------------------------------------------------------------------------

local hyperLinkPattern = "|c.-|r"
local linkPattern = "|H.-|h"
local allInOnePattern = "|H(%a*):(%d*):(%d*):?.-|h%[(.-)%s?%(?%d?%d?%)?%]|h"

local string_gmatch = string.gmatch
local string_match = string.match
local string_gsub = string.gsub

local TS_GetRecipeLink = C_TradeSkillUI.GetRecipeLink
local AddFilter = ChatFrame_AddMessageEventFilter
local GetPetName = C_PetJournal.GetPetInfoBySpeciesID
local EJ_GetSectionInfo = C_EncounterJournal.GetSectionInfo

local select = select 

local string = string
local GetItemInfo = GetItemInfo
local GetSpellInfo = GetSpellInfo
local GetAchievementInfo = GetAchievementInfo
local EJ_GetInstanceInfo = EJ_GetInstanceInfo
local EJ_GetEncounterInfo = EJ_GetEncounterInfo

------------------------------------------------------------------------------------------------------------

local function Filter(self, event, msg, author, ... )

	local newMessage = msg

	for s in string_gmatch(msg, hyperLinkPattern) do

		--print(s)

		local tipe, id, val1, inside = string_match(s, allInOnePattern)
		local iLink = string_match(s, linkPattern)
		local tmp = nil

		GetItemInfo(iLink)

		if tipe == "item" then
			tmp = NameFromTooltip[iLink]

		elseif tipe == "quest" then
			tmp = NameFromTooltip["quest:"..id]

		elseif tipe == "spell" then
			tmp = GetSpellInfo(id)

		elseif tipe == "keystone" then
			tmp = NameFromTooltip["keystone:158923:"..val1]

		elseif tipe == "enchant" then
			local enchantLink = TS_GetRecipeLink(id)
			tmp = string.match(enchantLink, "%[(.-)%]")

		elseif tipe == "battlepet" then
			tmp = GetPetName(id)

		elseif tipe == "achievement" then
			tmp = select(2,GetAchievementInfo(id))

		elseif tipe == "journal" then
			if id == "0" then
				tmp = EJ_GetInstanceInfo(val1)
			elseif id == "1" then
				tmp = EJ_GetEncounterInfo(val1)
			elseif id == "2" then
				local tempTable = EJ_GetSectionInfo(val1)
				tmp = tempTable.title
			end
		end

		-- if not translated keep the message original
		if tmp then
			newMessage = string_gsub(newMessage, inside, tmp)
		end	
	end

	return false, newMessage, author, ...

end

LinkLocalizer:SetScript("OnEvent", function(self,event,...)
	if event == "ADDON_LOADED" then
		if (... == "LinkLocalizer") then
			for k,v in pairs(chatChannels) do
				AddFilter(k, Filter)	
			end
		end
	end
end)

SLASH_LINKLOCALIZERC1, SLASH_LINKLOCALIZERC2 = '/ll', '/linklocalizer'
function SlashCmdList.LINKLOCALIZERC()
	print("LinkLocalizer will try to \nupdate all the links in your locale, \ritems can misbehave, blame blizzard and it's caching system")
end
