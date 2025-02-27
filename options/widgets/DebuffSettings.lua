--[[
Options to configure each Individual Debuff
]]--
local _, ns = ...


local COLOR_GREY = "ff808080"
local ICON_SIZE = 34



local options = {}


options.header = {
    type = "description",
    order = 10,

    fontSize = "large",
    name = function(info)
        local info = C_Spell.GetSpellInfo(info.handler and info.handler.spell_id)
        if info then
            return string.format( "%s\n(%d)", info.name, info.spellID)
        else
            return ""
        end
    end,
    image = function(info)
        local info = C_Spell.GetSpellInfo(info.handler.spell_id)
        return info.iconID, ICON_SIZE, ICON_SIZE
    end,
    imageWidth = ICON_SIZE,
    imageHeight = ICON_SIZE,
}


options.enableSpell = {
    type = "toggle",
    order = 11,
    name = "Enabled",
    get = function(info)
        return info.handler.data.enabled
    end,
    set = function(info, value)
        info.handler.data.enabled = value
        ns.gui_refresh()
    end,
}


options.spell_id = {
    type = "input",
    name = "Spell ID:",
    order = 20,
    get = function(info)
        return tostring(info.handler.spell_id)
    end,
    set = function() end,
}


options.header2 = { type="header", order=30, name="" }


options.assignedStatus = {
    type = "select",
    order = 110,
    name = "Status",

    values = function()
        local n = ns.num_statuses or 4
        local r = {}
        for i=1, n do
            r[i] = i
        end
        return r
    end,

    get = function(info)
        return info.handler.data.status or 1
    end,

    set = function (info, v)
        info.handler.data.status = v
        ns.gui_refresh()
    end,

    disabled = function(info)
        return not info.handler.data.enabled
    end,
}


options.group = {
    type = "select",
    order = 150,
    width = "full",
    name = "Group:",

    values = function()

        local r = {}
        for k, v in pairs(ArrgDebuffsDB.groups) do
            r[k] = k
        end
        return r
    end,

    get = function(info)
        return info.handler.data.group or ""
    end,

    set = function(info , v)
        info.handler.data.group = v
        ns.gui_refresh()
    end,
}


options.header2 = { type= "header", order=199, name="" }

options.wa_enable = {
    type = "toggle",
    order = 201,
    name = "Enable WA Trigger",
    get = function(info)
        return info.handler.data.wa_enable
    end,
    set = function(info, value)
        info.handler.data.wa_enable = value
    end,
}

options.wa_tag = {
    type = "input",
    order = 202,
    name = "WA Tag",
    get = function(info)
        return info.handler.data.wa_tag
    end,
    set = function(info, value)
        info.handler.data.wa_tag = value
    end,
    disabled = function(info)
        return not info.handler.data.wa_enable
    end,

}



options.header3 = { type= "header", order=299, name="" }


options.chat_link = {
    type = "execute",
    order = 300,
    name = "Link to Chat",
    func = function(info)
        local link = C_Spell.GetSpellLink(info.handler.spell_id)
        if not link then return end

        local ChatBox = ChatEdit_ChooseBoxForSend()
        if not ChatBox:HasFocus() then
            ChatFrame_OpenChat(link)
        else
            ChatBox:Insert(link)
        end
    end,
}


options.remove_spell = {
    type = "execute",
    order = 310,
    name = "Remove",

    func = function(info)
        local spell_id = info.handler.spell_id
        print("Remove Spell:", spell_id)
        ns.db.debuffs[spell_id] = nil
        -- or: 
        -- table.remove(debuffs, index)

        -- refresh the debuffs list
        ns.gui_refresh()
    end
}



function ns.widgets.DebuffSettings(spell_id, data)


    local info = C_Spell.GetSpellInfo(spell_id)
    if not info then
        return nil
    end

	-- local _, _, icon = GetSpellInfo(spell_id)
	local iconCoords = { 0.05, 0.95, 0.05, 0.95 }

	-- local icon = READY_CHECK_READY_TEXTURE
	-- local mask = "  |T%s:0|t%s%s"
	-- local suffix = ""
	-- local title = string.format(mask, icon, spell_name, suffix)

	local title = info.name or "UNKNOWN"

	if info.iconID then
		title = "|T" .. info.iconID .. ":0|t" .. title
	end

	local enabled = data.enabled ~= false
	if enabled then
		title = "|T" .. READY_CHECK_READY_TEXTURE .. ":0|t" .. title
	else
		title = "|T" .. READY_CHECK_NOT_READY_TEXTURE .. ":0|t" .. title
		title = WrapTextInColorCode(title, COLOR_GREY)
	end

	-- append assigned Status
	if enabled and data.status and data.status > 1 then
		title = title .. " (" .. data.status .. ")"
	end

	-- Order
	local order = spell_id
	if not enabled then
		order = order + 100000000
	end
	order = order + ((data.status or 1) * 100000)


	return {
		type = "group",
		name = title,
		desc = string.format("     (%d)", spell_id ),
		order = order,
		args = options,
		handler = {
            spell_id = spell_id,
            data = data,
        },
	}
end


