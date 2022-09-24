KillDB = KillDB or { Enabled = true }

data_table_sound_files = {
    ["Ha, Gottem"] = "Interface\\AddOns\\Memeboard\\Sound\\Ha_Got_Em.mp3",
}

data_table_ingame_sound = {

}

data_table_events = {
    ["COMBAT_LOG_EVENT_UNFILTERED"] = {
        ["Killing Blow"] = "PARTY_KILL"
    }
}

-- event = sound
data_table_settings = {
    ["events"] = {},
    ["sounds"] = {}
}

data_table_apply = {

}

killing_blow = function (sound)
    
end

on_click_dd = function (self)
    local parent = self:GetParent()
    parent.text = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    parent.text:SetText(self:GetText())
    parent.text:SetPoint("LEFT")
    for key, val in pairs(data_table_sound_files) do
        if key == self:GetText() then
            data_table_settings["sounds"][key] = val
            return
        end
    end

    for key, val in pairs(data_table_events) do
       for key, val in pairs(data_table_events[key]) do
            if key == self:GetText() then
                data_table_settings["events"][key] = val
                return
            end
       end 
    end
end

local Load = function(self)
	self:UnregisterEvent("VARIABLES_LOADED")
    --center frame and show it initally
    self:SetPoint("CENTER",0,0)
    self:Show()
    --self:Hide()
    child_to_show = get_child(self, "AddNewSoundFrame")
    child_to_hide = get_child(self, "ReplaceSoundFrame")
    child_to_show:Show()
	child_to_hide:Hide()
    SLASH_meme1 = "/meme"
    SLASH_meme2 = "/Meme"
    SLASH_meme3 = "/MEME"
    SLASH_meme4 = "/kekw"
	SlashCmdList["meme"] = function()
		self:Show()
	end
end

local EventHandler = function(self, event, ...)
    if(event=="VARIABLES_LOADED") then
        Load(self)
    elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
        --message(data_table_settings["events"]["Killing Blow"])
        local _,combat_event, _, source_GUID, _, _, dFlag = CombatLogGetCurrentEventInfo()
        local index = 0
        for key, val in pairs(data_table_settings["events"]) do
            if data_table_settings["events"][key] == "PARTY_KILL" then
                --DEFAULT_CHAT_FRAME:AddMessage("|cff00aa00Gottem|r: TEST = "..tostring(a)..tostring(b)..tostring(c)..tostring(d)..tostring(e)..tostring(f)..tostring(g)..tostring(h)..tostring(i))
                if(combat_event == data_table_settings["events"][key] and source_GUID == UnitGUID("player")) then
                    local sound_index = 0
                    for key, val in pairs(data_table_settings["sounds"]) do
                        if sound_index == index then
                            PlaySoundFile(data_table_settings["sounds"][key])
                        end
                        sound_index = sound_index + 1
                    end
                end
                index = index + 1
            end
        end
    end
end

local CreateBorder = function(self)
    if not self.borders then
        self.borders = {}
        for border_line =1,4 do
            self.borders[border_line] = self:CreateLine(nil, "BACKGROUND", nil, 0)
            local border = self.borders[border_line]
            local thickness = 5 
            border:SetThickness(thickness)
            border:SetColorTexture(0, 0, 0, 1)
            if border_line==1 then
                border:SetStartPoint("TOPLEFT", -thickness/2, 0)
                border:SetEndPoint("TOPRIGHT", thickness/2, 0)
            elseif border_line==2 then
                border:SetStartPoint("TOPRIGHT")
                border:SetEndPoint("BOTTOMRIGHT")
            elseif border_line==3 then
                border:SetStartPoint("BOTTOMRIGHT", thickness/2, 0)
                border:SetEndPoint("BOTTOMLEFT", -thickness/2, 0)
            else
                border:SetStartPoint("BOTTOMLEFT")
                border:SetEndPoint("TOPLEFT")
            end
        end
    end
end

local click_exit = function (self)
    self:GetParent():GetParent():Hide()
end

local click_add_sound = function (self)
    local parent = self:GetParent():GetParent()
    child_to_hide = get_child(parent, "ReplaceSoundFrame")
    child_to_show = get_child(parent, "AddNewSoundFrame")
    child_to_hide:Hide()
    child_to_show:Show()
end

local click_replace_sound = function (self)
    local parent = self:GetParent():GetParent()
    child = get_child(parent, "AddNewSoundFrame")
    child_to_hide = get_child(parent, "AddNewSoundFrame")
    child_to_show = get_child(parent, "ReplaceSoundFrame")
    child_to_hide:Hide()
    child_to_show:Show()
end

get_child = function (frame, name)
    for _, child in ipairs({frame:GetChildren()}) do
        if child:GetName() == name then
            return child
        end
    end
end


local create_frame_with_settings = function (frame_type, frame_name, frame_placement, parent, size, alpha, texture_info)
    local frame = CreateFrame(frame_type, frame_name, parent)
    local texture = frame:CreateTexture(nil,"BACKGROUND")

    if frame_name == "MainFrame" then
        frame:SetFrameStrata("BACKGROUND")
        frame:EnableMouse(true)
        frame:SetMovable(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    else
        frame:SetPoint(frame_placement ,parent, frame_placement)
    end

    frame:SetSize(size[1], size[2])

    if type(texture_info) == "string" then
        if texture_info ~= "" then
            texture:SetTexture(texture_info)
            texture:SetAlpha(alpha)
        else
            texture:SetColorTexture(0, 0, 0, alpha)
        end    
    else
        if texture_info ~= nil then
            texture:SetColorTexture(texture_info[1], texture_info[2], texture_info[3])
        end
    end
    
    texture:SetAllPoints(frame)
    frame.texture=texture



    return frame
end

local create_drop_down_menu = function (frame_type, frame_name, dd_anchor, parent_frame, frame_size, dd_title, dd_offset, data_type)
    local drop_down_frame = CreateFrame(frame_type, frame_name, parent_frame)
    local dd_arrow = CreateFrame("Button", "DropDownArrow", drop_down_frame)
    local title = drop_down_frame:CreateFontString(drop_down_frame, "OVERLAY", "GameFontNormal")
    local dd_texture = drop_down_frame:CreateTexture(nil, "BACKGROUND")
    local dd_arrow_texture = dd_arrow:CreateTexture(nil, "BACKGROUND")
    local data_table = {}
    
    -- set corresponding data table for drop down menu
    if data_type == "sound" then
        data_table = data_table_sound_files
    elseif data_type == "event" then
        data_table = data_table_events
    elseif data_type == "game_sound" then
        data_table = data_table_ingame_sound
    end
    

    drop_down_frame:SetSize(frame_size[1], frame_size[2])
    drop_down_frame:SetPoint(dd_anchor, dd_offset[1], dd_offset[2])
    dd_arrow:SetSize(20, frame_size[2])
    dd_arrow:SetPoint("RIGHT", drop_down_frame, "RIGHT")

    dd_texture:SetColorTexture(0,0,0,1)
    dd_texture:SetAllPoints(drop_down_frame)
    drop_down_frame.texture = dd_texture

    title:SetPoint("TOPLEFT", drop_down_frame, 0, 20)
    title:SetText(dd_title)
    
    dd_arrow_texture:SetTexture("Interface\\AddOns\\Memeboard\\TGA\\down_arrow.tga")
    dd_arrow_texture:SetAllPoints(dd_arrow)
    dd_arrow.texture = dd_arrow_texture


    drop_down_frame = init_dd(drop_down_frame, data_table)

    local diff = math.abs(600/2 - drop_down_frame:GetWidth())
    if dd_anchor == "TOPLEFT" then
        if diff > 0 then
            drop_down_frame:SetPoint(dd_anchor, diff - 30, dd_offset[2])
        else
            drop_down_frame:SetPoint(dd_anchor, 10, dd_offset[2])
        end
    else
        if diff > 0 then
            drop_down_frame:SetPoint(dd_anchor, -diff + 30, dd_offset[2])
        else
            drop_down_frame:SetPoint(dd_anchor, 10, dd_offset[2])
        end
    end
    

    dd_arrow:SetScript("OnClick",on_click_dd_arrow)
    return drop_down_frame
end

on_click_dd_arrow = function (self)
    for _, child in ipairs({self:GetParent():GetChildren()}) do
        if child:IsShown() then
            if child:GetName() ~= "DropDownArrow" then
                child:Hide() 
            end
        else
            child:Show()
        end
    end
end

init_dd = function (dd_frame, entries)
    local dd_frame_initialized = {}
    dd_frame_initialized["root"] = dd_frame
    
    local cnt = 1
    local max_len = 0
    
    if entries == data_table_events then
        for key, value in pairs(entries) do
            for key, value in pairs(entries[key]) do
                local temp_frame = CreateFrame("Button", value, dd_frame)
                local temp_value = temp_frame:CreateFontString(temp_frame, "OVERLAY", "GameFontNormal")
                local temp_texture = temp_frame:CreateTexture(nil, "BACKGROUND")
                
                temp_texture:SetColorTexture(0, 0 , 0, 1)
                temp_texture:SetAllPoints(temp_frame)
                temp_frame.texture = temp_texture
                
                temp_value:SetPoint("CENTER", temp_frame, 0, 0)
                temp_value:SetText(key)
                local temp_text_width  = temp_value:GetStringWidth()
                if temp_text_width > max_len then
                    max_len = temp_text_width
                end
                temp_frame:SetFontString(temp_value)
                temp_frame.text = temp_value
                
                temp_frame:SetSize(max_len + 20, dd_frame:GetHeight())
                temp_frame:SetPoint("CENTER", dd_frame, 0, -cnt*dd_frame:GetHeight())
        
                temp_frame:SetScript("OnClick", on_click_dd)
                temp_frame:Hide()
                
                cnt = cnt + 1
            end
        end
    else
        for key, value in pairs(entries) do
            local temp_frame = CreateFrame("Button", value, dd_frame)
            local temp_value = temp_frame:CreateFontString(temp_frame, "OVERLAY", "GameFontNormal")
            local temp_texture = temp_frame:CreateTexture(nil, "BACKGROUND")
            
            temp_texture:SetColorTexture(0, 0 , 0, 1)
            temp_texture:SetAllPoints(temp_frame)
            temp_frame.texture = temp_texture
            
            temp_value:SetPoint("CENTER", temp_frame, 0, 0)
            temp_value:SetText(key)
            local temp_text_width  = temp_value:GetStringWidth()
            if temp_text_width > max_len then
                max_len = temp_text_width
            end
            temp_frame:SetFontString(temp_value)
            temp_frame.text = temp_value
             
            temp_frame:SetSize(max_len + 20, dd_frame:GetHeight())
            temp_frame:SetPoint("CENTER", dd_frame, 0, -cnt*dd_frame:GetHeight())
            
            temp_frame:SetScript("OnClick", on_click_dd)
            temp_frame:Hide()
            
            cnt = cnt + 1
        end
    end
    
    dd_frame:SetWidth(max_len + 20)
    return dd_frame
end

local dd_on_click_arrow = function (entries)
    
end



--##################################### GENERAL FRAMES AND BUTTON ###########################################################

--settings for frame
local frame = create_frame_with_settings("Frame", "MainFrame", "", UIParent, {600,600}, 0.5, "Interface\\AddOns\\Memeboard\\TGA\\pepe_lols.tga")

--top bar settings
local top_frame=create_frame_with_settings("Frame", "TopFrame", "TOP", frame, {frame:GetWidth(), 25}, 1, {0.5, 0.5, 0.5})


--exit button settings
local button_frame_exit=create_frame_with_settings("Button", "ExitButton", "TOPLEFT", top_frame, {50, 25}, 1, {0, 0, 0})
button_frame_exit:SetText("Exit")
button_frame_exit:SetNormalFontObject("GameFontNormal")
button_frame_exit:SetScript("OnClick", click_exit)

--Add New Sound frame
local new_sound_frame=create_frame_with_settings("Frame", "AddNewSoundFrame", "CENTER", frame, {frame:GetWidth(), frame:GetHeight()}, 1, nil)


--Replace Sound frame
local replace_sound_frame=create_frame_with_settings("Frame", "ReplaceSoundFrame", "CENTER", frame, {frame:GetWidth(), frame:GetHeight()}, 1, nil)

--Button Add Sounds
local button_add_sound=create_frame_with_settings("Button", "ExitButton", "TOPRIGHT", top_frame, {100, 25}, 1, {0, 0, 0})
button_add_sound:SetText("Add new sounds")
button_add_sound:SetNormalFontObject("GameFontNormal")
button_add_sound:SetScript("OnClick", click_add_sound)

--Button Replace Sounds
local button_replace_sound=create_frame_with_settings("Button", "ExitButton", "TOPRIGHT", top_frame, {100, 25}, 1, {0, 0, 0})
button_replace_sound:SetPoint("TOPRIGHT",top_frame,"TOPRIGHT",-100,0)
button_replace_sound:SetText("Replace sound")
button_replace_sound:SetNormalFontObject("GameFontNormal")
button_replace_sound:SetScript("OnClick", click_replace_sound)



--##################################### DROP DOWN MENU STUFF ###########################################################
--Drop down menu Add Sounds
local dropdown_add_sound = create_drop_down_menu("Frame", "addSoundDropDown", "TOPLEFT", new_sound_frame, {100,25}, "Meme Sound:", {150, -75}, "sound")
local dropdown_add_event = create_drop_down_menu("Frame", "addSoundDropDownEvent", "TOPRIGHT", new_sound_frame, {100,25}, "Event to add to:", {-150, -75}, "event")


--################### CREATE SOME B ORDERS ###################
CreateBorder(frame)
CreateBorder(top_frame)

--################### EVENT REGISTERS ETC ####################
frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:SetScript("OnEvent", EventHandler)