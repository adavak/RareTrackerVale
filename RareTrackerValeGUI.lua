-- Redefine often used functions locally.
local CreateFrame = CreateFrame
local IsLeftControlKeyDown = IsLeftControlKeyDown
local IsRightControlKeyDown = IsRightControlKeyDown
local UnitInRaid = UnitInRaid
local IsLeftAltKeyDown = IsLeftAltKeyDown
local IsRightAltKeyDown = IsRightAltKeyDown
local SendChatMessage = SendChatMessage
local GetServerTime = GetServerTime
local IsQuestFlaggedCompleted = IsQuestFlaggedCompleted

-- Redefine global variables locally.
local UIParent = UIParent

-- Width and height variables used to customize the window.
local entity_name_width = 208
local entity_status_width = 50
local frame_padding = 4
local favorite_rares_width = 10
local shard_id_frame_height = 16

-- Values for the opacity of the background and foreground.
local background_opacity = 0.4
local front_opacity = 0.6

-- ####################################################################
-- ##                      Localization Support                      ##
-- ####################################################################

-- Get an object we can use for the localization of the addon.
local L = LibStub("AceLocale-3.0"):GetLocale("RareTrackerVale", true)

-- ####################################################################
-- ##                              GUI                               ##
-- ####################################################################

RTV.last_reload_time = 0

function RTV:InitializeShardNumberFrame()
	local f = CreateFrame("Frame", "RTV.shard_id_frame", self)
	f:SetSize(
      entity_name_width + entity_status_width + 3 * frame_padding + 2 * favorite_rares_width,
      shard_id_frame_height
  )
  
	local texture = f:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0, 0, 0, front_opacity)
	texture:SetAllPoints(f)
	f.texture = texture
	
	f.status_text = f:CreateFontString(nil, nil, "GameFontNormal")
	f.status_text:SetPoint("TOPLEFT", 10 + 2 * favorite_rares_width + 2 * frame_padding, -3)
	f.status_text:SetText(L["Shard ID: Unknown"])
	f:SetPoint("TOPLEFT", self, frame_padding, -frame_padding)
	
	return f
end

function RTV:CreateRareTableEntry(npc_id, parent_frame)
	local f = CreateFrame("Frame", "RTV.entities_frame.entities["..npc_id.."]", parent_frame);
	f:SetSize(entity_name_width + entity_status_width + 3 * frame_padding + 2 * favorite_rares_width, 12)
	
	-- Add the favorite button.
	f.favorite = CreateFrame("CheckButton", "RTV.entities_frame.entities["..npc_id.."].favorite", f)
	f.favorite:SetSize(10, 10)
	local texture = f.favorite:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0, 0, 0, front_opacity)
	texture:SetAllPoints(f.favorite)
	f.favorite.texture = texture
	f.favorite:SetPoint("TOPLEFT", 1, 0)
	
	-- Add an action listener.
	f.favorite:SetScript("OnClick",
		function()
			if RTVDB.favorite_rares[npc_id] then
				RTVDB.favorite_rares[npc_id] = nil
				f.favorite.texture:SetColorTexture(0, 0, 0, front_opacity)
			else
				RTVDB.favorite_rares[npc_id] = true
				f.favorite.texture:SetColorTexture(0, 1, 0, 1)
			end
		end
	);
	
	-- Add the announce/waypoint button.
	f.announce = CreateFrame("Button", "RTV.entities_frame.entities["..npc_id.."].announce", f)
	f.announce:SetSize(10, 10)
	texture = f.announce:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0, 0, 0, front_opacity)
	texture:SetAllPoints(f.announce)
	f.announce.texture = texture
	f.announce:SetPoint("TOPLEFT", frame_padding + favorite_rares_width + 1, 0)
	f.announce:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	
	-- Add an action listener.
	f.announce:SetScript("OnClick",
		function(_, button)
			local name = self.rare_names[npc_id]
			local health = self.current_health[npc_id]
			local last_death = self.last_recorded_death[npc_id]
			local loc = self.current_coordinates[npc_id]
			
			if button == "LeftButton" then
				local target = "CHANNEL"
				
				if IsLeftControlKeyDown() or IsRightControlKeyDown() then
					if UnitInRaid("player") then
						target = "RAID"
					else
						target = "PARTY"
					end
				elseif IsLeftAltKeyDown() or IsRightAltKeyDown() then
					target = "SAY"
				end
                
                local channel_id = self.GetGeneralChatId()
			
				if self.current_health[npc_id] then
					-- SendChatMessage
					if loc then
						SendChatMessage(
							string.format(L["<RTV> %s (%s%%) seen at ~(%.2f, %.2f)"], name, health, loc.x, loc.y),
							target,
							nil,
							channel_id
						)
					else
						SendChatMessage(
							string.format(L["<RTV> %s (%s%%)"], name, health),
							target,
							nil,
							channel_id
						)
					end
				elseif self.last_recorded_death[npc_id] ~= nil then
					if GetServerTime() - last_death < 60 then
						SendChatMessage(
							string.format(L["<RTV> %s has died"], name, GetServerTime() - last_death),
							target,
							nil,
							channel_id
						)
					else
						SendChatMessage(
							string.format(
								L["<RTV> %s was last seen ~%s minutes ago"],
								name,
								math.floor((GetServerTime() - last_death) / 60)
							),
							target,
							nil,
							channel_id
						)
					end
				elseif self.is_alive[npc_id] then
					if loc then
						SendChatMessage(
							string.format(L["<RTV> %s seen alive, vignette at ~(%.2f, %.2f)"], name, loc.x, loc.y),
							target,
							nil,
							channel_id
						)
					else
						SendChatMessage(
							string.format(L["<RTV> %s seen alive (combat log)"], name),
							target,
							nil,
							channel_id
						)
					end
				end
			else
				-- does the user have tom tom? if so, add a waypoint if it exists.
				if TomTom ~= nil and loc and not self.waypoints[npc_id] then
					self.waypoints[npc_id] = TomTom:AddWaypointToCurrentZone(loc.x, loc.y, name)
				end
			end
		end
	);
	
	-- Add the entities name.
	f.name = f:CreateFontString(nil, nil, "GameFontNormal")
	f.name:SetJustifyH("LEFT")
	f.name:SetJustifyV("TOP")
	f.name:SetPoint("TOPLEFT", 2 * frame_padding + 2 * favorite_rares_width + 10, 0)
	f.name:SetText(self.rare_names[npc_id])
	
	-- Add the timer/health entry.
	f.status = f:CreateFontString(nil, nil, "GameFontNormal")
	f.status:SetPoint("TOPRIGHT", 0, 0)
	f.status:SetText("--")
	f.status:SetJustifyH("MIDDLE")
	f.status:SetJustifyV("TOP")
	f.status:SetSize(entity_status_width, 12)
	
	return f
end

function RTV:InitializeRareTableEntries(parent_frame)
	-- Create a holder for all the entries.
	parent_frame.entities = {}
	
	-- Create a frame entry for all of the NPC ids, even the ignored ones.
	-- The ordering and hiding of rares will be done later.
	for i=1, #self.rare_ids do
		local npc_id = self.rare_ids[i]
		parent_frame.entities[npc_id] = self:CreateRareTableEntry(npc_id, parent_frame)
	end
end

function RTV:ReorganizeRareTableFrame(f)
    -- Filter out the rares that are not part of the current assault.
    local assault_rares = RTV.rare_ids_set
    if self.assault_id ~= 0 then
        assault_rares = RTV.assault_rare_ids[self.assault_id]
    end
    
	-- How many ignored rares do we have?
	local n = 0
    for _, npc_id in pairs(RTV.rare_ids) do
        if RTVDB.ignore_rare[npc_id] or assault_rares[npc_id] == nil then
            n = n + 1
        end
    end
	
	-- Resize all the frames.
	self:SetSize(
		entity_name_width + entity_status_width + 2 * favorite_rares_width + 5 * frame_padding,
		shard_id_frame_height + 3 * frame_padding + (#self.rare_ids - n) * 12 + 8
	)
	f:SetSize(
		entity_name_width + entity_status_width + 2 * favorite_rares_width + 3 * frame_padding,
		(#self.rare_ids - n) * 12 + 8
	)
	f.entity_name_backdrop:SetSize(entity_name_width, f:GetHeight())
	f.entity_status_backdrop:SetSize(entity_status_width, f:GetHeight())
	
	-- Give all of the table entries their new positions.
	local i = 1
	RTVDB.rare_ordering:ForEach(
		function(npc_id, _)
			if RTVDB.ignore_rare[npc_id] or assault_rares[npc_id] == nil then
				f.entities[npc_id]:Hide()
			else
				f.entities[npc_id]:SetPoint("TOPLEFT", f, 0, -(i - 1) * 12 - 5)
				f.entities[npc_id]:Show()
				i = i + 1
			end
		end
	)
end

function RTV:InitializeRareTableFrame(f)
	-- First, add the frames for the backdrop and make sure that the hierarchy is created.
	f:SetPoint("TOPLEFT", frame_padding, -(2 * frame_padding + shard_id_frame_height))
	
	f.entity_name_backdrop = CreateFrame("Frame", "RTV.entities_frame.entity_name_backdrop", f)
	local texture = f.entity_name_backdrop:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0, 0, 0, front_opacity)
	texture:SetAllPoints(f.entity_name_backdrop)
	f.entity_name_backdrop.texture = texture
	f.entity_name_backdrop:SetPoint("TOPLEFT", f, 2 * frame_padding + 2 * favorite_rares_width, 0)
	
	f.entity_status_backdrop = CreateFrame("Frame", "RTV.entities_frame.entity_status_backdrop", f)
	texture = f.entity_status_backdrop:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0, 0, 0, front_opacity)
	texture:SetAllPoints(f.entity_status_backdrop)
	f.entity_status_backdrop.texture = texture
	f.entity_status_backdrop:SetPoint("TOPRIGHT", f, 0, 0)
	
	-- Next, add all the rare entries to the table.
	self:InitializeRareTableEntries(f)
	
	-- Arrange the table such that it fits the user's wishes. Resize the frames appropriately.
	self:ReorganizeRareTableFrame(f)
end

function RTV:UpdateStatus(npc_id)
	local target = self.entities_frame.entities[npc_id]

	if self.current_health[npc_id] then
		target.status:SetText(self.current_health[npc_id].."%")
    target.status:SetFontObject("GameFontGreen")
		target.announce.texture:SetColorTexture(0, 1, 0, 1)
	elseif self.is_alive[npc_id] then
		target.status:SetText("N/A")
    target.status:SetFontObject("GameFontGreen")
		target.announce.texture:SetColorTexture(0, 1, 0, 1)
	elseif self.last_recorded_death[npc_id] ~= nil then
		local last_death = self.last_recorded_death[npc_id]
		target.status:SetText(math.floor((GetServerTime() - last_death) / 60).."m")
    target.status:SetFontObject("GameFontNormal")
		target.announce.texture:SetColorTexture(0, 0, 1, front_opacity)
	else
		target.status:SetText("--")
    target.status:SetFontObject("GameFontNormal")
		target.announce.texture:SetColorTexture(0, 0, 0, front_opacity)
	end
end

function RTV:UpdateShardNumber(shard_number)
	if shard_number then
		self.shard_id_frame.status_text:SetText(L["Shard ID: "]..(shard_number + 42))
	else
		self.shard_id_frame.status_text:SetText(L["Shard ID: Unknown"])
	end
end

function RTV:CorrectFavoriteMarks()
	for i=1, #self.rare_ids do
		local npc_id = self.rare_ids[i]
		
		if RTVDB.favorite_rares[npc_id] then
			self.entities_frame.entities[npc_id].favorite.texture:SetColorTexture(0, 1, 0, 1)
		else
			self.entities_frame.entities[npc_id].favorite.texture:SetColorTexture(0, 0, 0, front_opacity)
		end
	end
end

function RTV:UpdateDailyKillMark(npc_id)
	if not self.completion_quest_ids[npc_id] then
		return
	end
	
	-- Multiple NPCs might share the same quest id.
	local completion_quest_id = self.completion_quest_ids[npc_id]
	local npc_ids = self.completion_quest_inverse[completion_quest_id]
	
	for _, target_npc_id in pairs(npc_ids) do
		if self.completion_quest_ids[target_npc_id] and IsQuestFlaggedCompleted(self.completion_quest_ids[target_npc_id]) then
			self.entities_frame.entities[target_npc_id].name:SetText(self.rare_display_names[target_npc_id])
			self.entities_frame.entities[target_npc_id].name:SetFontObject("GameFontRed")
		else
			self.entities_frame.entities[target_npc_id].name:SetText(self.rare_display_names[target_npc_id])
			self.entities_frame.entities[target_npc_id].name:SetFontObject("GameFontNormal")
		end
	end
end

function RTV:UpdateAllDailyKillMarks()
	for i=1, #RTV.rare_ids do
		local npc_id = RTV.rare_ids[i]
		self:UpdateDailyKillMark(npc_id)
	end
end

function RTV.InitializeFavoriteIconFrame(f)
	f.favorite_icon = CreateFrame("Frame", "RTV.favorite_icon", f)
	f.favorite_icon:SetSize(10, 10)
	f.favorite_icon:SetPoint("TOPLEFT", f, frame_padding + 1, -(frame_padding + 3))

	f.favorite_icon.texture = f.favorite_icon:CreateTexture(nil, "OVERLAY")
	f.favorite_icon.texture:SetTexture("Interface\\AddOns\\RareTrackerVale\\Icons\\Favorite.tga")
	f.favorite_icon.texture:SetSize(10, 10)
	f.favorite_icon.texture:SetPoint("CENTER", f.favorite_icon)
	
	f.favorite_icon.tooltip = CreateFrame("Frame", nil, UIParent)
	f.favorite_icon.tooltip:SetSize(300, 18)
	
	local texture = f.favorite_icon.tooltip:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0, 0, 0, front_opacity)
	texture:SetAllPoints(f.favorite_icon.tooltip)
	f.favorite_icon.tooltip.texture = texture
	f.favorite_icon.tooltip:SetPoint("TOPLEFT", f, 0, 19)
	f.favorite_icon.tooltip:Hide()
	
	f.favorite_icon.tooltip.text = f.favorite_icon.tooltip:CreateFontString(nil, nil, "GameFontNormal")
	f.favorite_icon.tooltip.text:SetJustifyH("LEFT")
	f.favorite_icon.tooltip.text:SetJustifyV("TOP")
	f.favorite_icon.tooltip.text:SetPoint("TOPLEFT", f.favorite_icon.tooltip, 5, -3)
	f.favorite_icon.tooltip.text:SetText(L["Click on the squares to add rares to your favorites."])
	
	f.favorite_icon:SetScript("OnEnter",
		function(self)
			self.tooltip:Show()
		end
	);
	
	f.favorite_icon:SetScript("OnLeave",
		function(self)
			self.tooltip:Hide()
		end
	);
end

function RTV.InitializeAnnounceIconFrame(f)
	f.broadcast_icon = CreateFrame("Frame", "RTV.broadcast_icon", f)
	f.broadcast_icon:SetSize(10, 10)
	f.broadcast_icon:SetPoint("TOPLEFT", f, 2 * frame_padding + favorite_rares_width + 1, -(frame_padding + 3))

	f.broadcast_icon.texture = f.broadcast_icon:CreateTexture(nil, "OVERLAY")
	f.broadcast_icon.texture:SetTexture("Interface\\AddOns\\RareTrackerVale\\Icons\\Broadcast.tga")
	f.broadcast_icon.texture:SetSize(10, 10)
	f.broadcast_icon.texture:SetPoint("CENTER", f.broadcast_icon)
	f.broadcast_icon.icon_state = false
	
	f.broadcast_icon.tooltip = CreateFrame("Frame", nil, UIParent)
	f.broadcast_icon.tooltip:SetSize(273, 68)
	
	local texture = f.broadcast_icon.tooltip:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0, 0, 0, front_opacity)
	texture:SetAllPoints(f.broadcast_icon.tooltip)
	f.broadcast_icon.tooltip.texture = texture
	f.broadcast_icon.tooltip:SetPoint("TOPLEFT", f, 0, 69)
	f.broadcast_icon.tooltip:Hide()
	
	f.broadcast_icon.tooltip.text1 = f.broadcast_icon.tooltip:CreateFontString(nil, nil, "GameFontNormal")
	f.broadcast_icon.tooltip.text1:SetJustifyH("LEFT")
	f.broadcast_icon.tooltip.text1:SetJustifyV("TOP")
	f.broadcast_icon.tooltip.text1:SetPoint("TOPLEFT", f.broadcast_icon.tooltip, 5, -3)
	f.broadcast_icon.tooltip.text1:SetText(L["Click on the squares to announce rare timers."])
	
	f.broadcast_icon.tooltip.text2 = f.broadcast_icon.tooltip:CreateFontString(nil, nil, "GameFontNormal")
	f.broadcast_icon.tooltip.text2:SetJustifyH("LEFT")
	f.broadcast_icon.tooltip.text2:SetJustifyV("TOP")
	f.broadcast_icon.tooltip.text2:SetPoint("TOPLEFT", f.broadcast_icon.tooltip, 5, -15)
	f.broadcast_icon.tooltip.text2:SetText(L["Left click: report to general chat"])
	
	f.broadcast_icon.tooltip.text3 = f.broadcast_icon.tooltip:CreateFontString(nil, nil, "GameFontNormal")
	f.broadcast_icon.tooltip.text3:SetJustifyH("LEFT")
	f.broadcast_icon.tooltip.text3:SetJustifyV("TOP")
	f.broadcast_icon.tooltip.text3:SetPoint("TOPLEFT", f.broadcast_icon.tooltip, 5, -27)
	f.broadcast_icon.tooltip.text3:SetText(L["Control-left click: report to party/raid chat"])
	
	f.broadcast_icon.tooltip.text4 = f.broadcast_icon.tooltip:CreateFontString(nil, nil, "GameFontNormal")
	f.broadcast_icon.tooltip.text4:SetJustifyH("LEFT")
	f.broadcast_icon.tooltip.text4:SetJustifyV("TOP")
	f.broadcast_icon.tooltip.text4:SetPoint("TOPLEFT", f.broadcast_icon.tooltip, 5, -39)
	f.broadcast_icon.tooltip.text4:SetText(L["Alt-left click: report to say"])
	  
	f.broadcast_icon.tooltip.text5 = f.broadcast_icon.tooltip:CreateFontString(nil, nil, "GameFontNormal")
	f.broadcast_icon.tooltip.text5:SetJustifyH("LEFT")
	f.broadcast_icon.tooltip.text5:SetJustifyV("TOP")
	f.broadcast_icon.tooltip.text5:SetPoint("TOPLEFT", f.broadcast_icon.tooltip, 5, -51)
	f.broadcast_icon.tooltip.text5:SetText(L["Right click: set waypoint if available"])
	
	f.broadcast_icon:SetScript("OnEnter",
		function(self)
			self.tooltip:Show()
		end
	);
	
	f.broadcast_icon:SetScript("OnLeave",
		function(self)
			self.tooltip:Hide()
		end
	);
end

function RTV:InitializeReloadButton(f)
	f.reload_button = CreateFrame("Button", "RTV.reload_button", f)
	f.reload_button:SetSize(10, 10)
	f.reload_button:SetPoint("TOPRIGHT", f, -3 * frame_padding - favorite_rares_width, -(frame_padding + 3))

	f.reload_button.texture = f.reload_button:CreateTexture(nil, "OVERLAY")
	f.reload_button.texture:SetTexture("Interface\\AddOns\\RareTrackerVale\\Icons\\Reload.tga")
	f.reload_button.texture:SetSize(10, 10)
	f.reload_button.texture:SetPoint("CENTER", f.reload_button)
	
	-- Create a tooltip window.
	f.reload_button.tooltip = CreateFrame("Frame", nil, UIParent)
	f.reload_button.tooltip:SetSize(390, 34)
	
	local texture = f.reload_button.tooltip:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0, 0, 0, front_opacity)
	texture:SetAllPoints(f.reload_button.tooltip)
	f.reload_button.tooltip.texture = texture
	f.reload_button.tooltip:SetPoint("TOPLEFT", f, 0, 35)
	f.reload_button.tooltip:Hide()
	
	f.reload_button.tooltip.text1 = f.reload_button.tooltip:CreateFontString(nil, nil, "GameFontNormal")
	f.reload_button.tooltip.text1:SetJustifyH("LEFT")
	f.reload_button.tooltip.text1:SetJustifyV("TOP")
	f.reload_button.tooltip.text1:SetPoint("TOPLEFT", f.reload_button.tooltip, 5, -3)
	f.reload_button.tooltip.text1:SetText(L["Reset your data and replace it with the data of others."])
	
	f.reload_button.tooltip.text2 = f.reload_button.tooltip:CreateFontString(nil, nil, "GameFontNormal")
	f.reload_button.tooltip.text2:SetJustifyH("LEFT")
	f.reload_button.tooltip.text2:SetJustifyV("TOP")
	f.reload_button.tooltip.text2:SetPoint("TOPLEFT", f.reload_button.tooltip, 5, -15)
	f.reload_button.tooltip.text2:SetText(L["Note: you do not need to press this button to receive new timers."])
	
	-- Hide and show the tooltip on mouseover.
	f.reload_button:SetScript("OnEnter",
		function(self2)
			self2.tooltip:Show()
		end
	);
	
	f.reload_button:SetScript("OnLeave",
		function(self2)
			self2.tooltip:Hide()
		end
	);
	
	f.reload_button:SetScript("OnClick",
		function()
			if self.current_shard_id ~= nil and GetServerTime() - self.last_reload_time > 600 then
				print(L["<RTV> Resetting current rare timers and requesting up-to-date data."])
				self.is_alive = {}
				self.current_health = {}
				self.last_recorded_death = {}
				self.recorded_entity_death_ids = {}
				self.current_coordinates = {}
				self.reported_spawn_uids = {}
				self.reported_vignettes = {}
				self.last_reload_time = GetServerTime()
				
				-- Reset the cache.
				RTVDB.previous_records[self.current_shard_id] = nil
				
				-- Re-register your arrival in the shard.
				RTV:RegisterArrival(self.current_shard_id)
			elseif self.current_shard_id == nil then
				print(L["<RTV> Please target a non-player entity prior to resetting, "..
						"such that the addon can determine the current shard id."])
			else
				print(L["<RTV> The reset button is on cooldown. Please note that a reset is not needed "..
					"to receive new timers. If it is your intention to reset the data, "..
					"please do a /reload and click the reset button again."])
			end
		end
	);
end

function RTV:InitializeCloseButton(f)
	f.close_button = CreateFrame("Button", "RTV.close_button", f)
	f.close_button:SetSize(10, 10)
	f.close_button:SetPoint("TOPRIGHT", f, -2 * frame_padding, -(frame_padding + 3))

	f.close_button.texture = f.close_button:CreateTexture(nil, "OVERLAY")
	f.close_button.texture:SetTexture("Interface\\AddOns\\RareTrackerVale\\Icons\\Cross.tga")
	f.close_button.texture:SetSize(10, 10)
	f.close_button.texture:SetPoint("CENTER", f.close_button)
	
	f.close_button:SetScript("OnClick",
		function()
            self:Hide()
            RTVDB.show_window = false
		end
	);
end

function RTV:InitializeInterface()
	self:SetSize(
		entity_name_width + entity_status_width + 2 * favorite_rares_width + 5 * frame_padding,
		shard_id_frame_height + 3 * frame_padding + #self.rare_ids * 12 + 8
	)
	
	local texture = self:CreateTexture(nil, "BACKGROUND")
	texture:SetColorTexture(0, 0, 0, background_opacity)
	texture:SetAllPoints(self)
	self.texture = texture
	self:SetPoint("CENTER")
	
	-- Create a sub-frame for the entity names.
	self.shard_id_frame = self:InitializeShardNumberFrame()
	self.entities_frame = CreateFrame("Frame", "RTV.entities_frame", self)
	self:InitializeRareTableFrame(self.entities_frame)

	self:SetMovable(true)
	self:EnableMouse(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", self.StartMoving)
	self:SetScript("OnDragStop", self.StopMovingOrSizing)
	
	-- Add icons for the favorite and broadcast columns.
	self.InitializeFavoriteIconFrame(self)
	self.InitializeAnnounceIconFrame(self)
	
	-- Create a reset button.
	self:InitializeReloadButton(self)
    self:InitializeCloseButton(self)
	self:SetClampedToScreen(true)
	
	self:Hide()
end
