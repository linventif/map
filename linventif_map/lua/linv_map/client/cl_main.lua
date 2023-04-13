local function PosToMap(pos_x, pos_y, width, height)
    width = LinvLib:RespW(width)
    height = LinvLib:RespH(height)

    pos_x = pos_x + (32768 / 2)
    pos_x = pos_x / 32768
    pos_x = pos_x * width
    pos_x = math.Round(pos_x, 4)

    pos_y = pos_y * -1
    pos_y = pos_y + (32768 / 2)
    pos_y = pos_y / 32768
    pos_y = pos_y * height
    pos_y = math.Round(pos_y, 4)

    return pos_x, pos_y
end

local minimapSize = 300
local zoomFactor = 0.2
local resolution = 4096 * 3.85 // /2
local margin = 40
local mapBounds = {
    min = Vector(-resolution, -resolution, 0),
    max = Vector(resolution, resolution, 0)
}

local function WorldToMap(pos, size)
    local mapX = math.Remap(pos.x, mapBounds.min.x, mapBounds.max.x, 0, size)
    local mapY = math.Remap(pos.y, mapBounds.min.y, mapBounds.max.y, size, 0)
    return Vector(mapX, mapY)
end

function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

local function GetZoneMaterial()
    if !LinvMap.MapInfo.info.multizone || !LinvMap.MapInfo.zones then return LinvMap.MapMaterials[LinvMap.MapInfo.info.map] end
    for k, v in pairs(LinvMap.MapInfo.zones) do
        local pos = LocalPlayer():GetPos()if (pos.x > v.pos_start.x && pos.x < v.pos_end.x) && (pos.y > v.pos_start.y && pos.y < v.pos_end.y) && (pos.z > v.pos_start.z && pos.z < v.pos_end.z) then
            return LinvMap.MapMaterials[v.image_id]
        end
    end
    return LinvMap.MapMaterials[LinvMap.MapInfo.info.map]
end

local function DrawMinimap()
    if !LinvMap.MapInfo.info then return end

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local pos = ply:GetPos()
    local ang = ply:EyeAngles().y
    local mapPos = WorldToMap(pos, minimapSize / zoomFactor)

    local centerX, centerY = margin + minimapSize / 2, margin + minimapSize / 2

    surface.SetDrawColor(LinvLib:GetColorTheme("background"))
    if LinvMap.Config.UseCircleMap then
        draw.NoTexture()
	    draw.Circle(centerX, centerY, minimapSize / 2 + 8, 100)
    end

    -- Set up stencil
    render.SetStencilEnable(true)
    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)
    render.SetStencilReferenceValue(1)
    render.SetStencilFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
    render.SetBlend(0)

    surface.SetDrawColor(39, 39, 39, 255)
    if LinvMap.Config.UseCircleMap then
        draw.NoTexture()
	    draw.Circle(centerX, centerY, minimapSize / 2, 100)
	else
        surface.DrawRect(centerX - minimapSize / 2, centerY - minimapSize / 2, minimapSize, minimapSize)
    end

    render.SetBlend(1)

    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

    -- Draw the map
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(GetZoneMaterial())

    local map_pos = {
        x = math.Round(mapPos.x - minimapSize / (2 * zoomFactor)),
        y = math.Round(mapPos.y - minimapSize / (2 * zoomFactor))
    }
    surface.DrawTexturedRectRotated(centerX - map_pos.x, centerY - map_pos.y, minimapSize / zoomFactor, minimapSize / zoomFactor, 0)

    -- Drawn Cursor
    if LinvMap.Config.UseCalibrationCursor then
        surface.SetDrawColor(255, 0, 0)
        surface.DrawRect(centerX - 2, centerY - 2, 4, 4)
    else
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(LinvMap.Materials["cursor"])
        local cursor_res = LinvMap.Config.CursorResolution * LinvMap.Config.CursorSize
        ang = ang - 90
        if ply:InVehicle() then
            ang = ply:GetVehicle():GetAngles().y
        end
        surface.DrawTexturedRectRotated(centerX , centerY , cursor_res, cursor_res, ang)
    end

    -- Disable stencil
    render.SetStencilEnable(false)
end
hook.Add("HUDPaint", "DrawMinimap", DrawMinimap)

// Parameter Menu

local function OpenBigMap(page)
    local frame = LinvLib:Frame(1110, 750)

    local panel_info = vgui.Create("DPanel", frame)
    panel_info:SetSize(LinvLib:RespW(1110), LinvLib:RespH(40))
    panel_info.Paint = function(self, w, h)
        draw.RoundedBoxEx(LinvLib.Config.Rounded, 0, 0, w, h, LinvLib.GetThemeColor("element"), true, true, false, false)
    end
    panel_info:Dock(TOP)

    local dlabel_title = vgui.Create("DLabel", panel_info)
    dlabel_title:SetText("Linventif Map")
    dlabel_title:SetFont(LinvLib.GetThemeFont("title"))
    dlabel_title:SetTextColor(LinvLib.GetThemeColor("text"))
    dlabel_title:SizeToContents()
    dlabel_title:Dock(LEFT)
    dlabel_title:DockMargin(LinvLib:RespW(5), 0, 0, 0)

    local but_close = LinvLib:CloseButton(panel_info, 30, 30, 810, 10, function()
        frame:Remove()
    end)
    but_close:Dock(RIGHT)
    but_close:DockMargin(LinvLib:RespW(5), LinvLib:RespH(5), LinvLib:RespW(5), LinvLib:RespH(5))

    local panel_content = vgui.Create("DPanel", frame)
    panel_content:SetSize(LinvLib:RespW(850), LinvLib:RespH(510))
    panel_content:Dock(FILL)
    panel_content:DockMargin(LinvLib:RespW(15), LinvLib:RespH(15), LinvLib:RespW(15), LinvLib:RespH(15))
    panel_content.Paint = function() end

    local scroll_category = vgui.Create("DScrollPanel", panel_content)
    scroll_category:Dock(LEFT)
    scroll_category:SetWide(LinvLib:RespW(220))
    -- scroll_category.Paint = function(self, w, h)
    --     draw.RoundedBox(0, 0, 0, w, h, LinvLib.GetThemeColor("element"))
    -- end

    LinvLib.HideVBar(scroll_category)

    local but_main = LinvLib:Button(scroll_category, "Carte", 160, 50, LinvLib:GetColorTheme("element"), true, function()
        frame:Close()
        OpenBigMap("main")
    end)
    but_main:Dock(TOP)
    but_main:DockMargin(0, 0, 0, LinvLib:RespH(15))

    local but_parameter = LinvLib:Button(scroll_category, "Paramètre", 160, 50, LinvLib:GetColorTheme("element"), true, function()
        frame:Close()
        OpenBigMap("parameter")
    end)
    but_parameter:Dock(TOP)
    but_parameter:DockMargin(0, 0, 0, LinvLib:RespH(15))

    local panel_main = vgui.Create("DPanel", panel_content)
    panel_main:SetSize(LinvLib:RespW(680), LinvLib:RespH(680))
    panel_main:Dock(FILL)
    panel_main:DockMargin(LinvLib:RespW(15), 0, 0, 0)

    if page == "parameter" then
        panel_main.Paint = function() end
        -- local scroll_parameter = vgui.Create("DScrollPanel", panel_main)
        -- scroll_parameter:Dock(FILL)
        -- scroll_parameter:SetWide(LinvLib:RespW(220))

        -- LinvLib.HideVBar(scroll_parameter)

        -- local panel_parameter = LinvLib:Panel(scroll_parameter, 680, 60, LinvLib:GetColorTheme("border"), LinvLib:GetColorTheme("element"))
        -- panel_parameter:Dock(TOP)
        -- panel_parameter:DockMargin(0, 0, 0, LinvLib:RespH(15))
        -- panel_parameter:DockPadding(LinvLib:RespW(15), LinvLib:RespH(15), LinvLib:RespW(15), LinvLib:RespH(15))

        -- local dlabel_parametre = vgui.Create("DLabel", panel_parameter)
        -- dlabel_parametre:SetText("Paramètre")
        -- dlabel_parametre:SizeToContents()
        -- dlabel_parametre:SetFont(LinvLib.GetThemeFont("title"))
        -- dlabel_parametre:SetTextColor(LinvLib.GetThemeColor("text"))
        -- dlabel_parametre:Dock(FILL)

        -- local but_act = LinvLib:Button(dlabel_parametre, "", 40, 40, LinvLib:GetColorTheme("element"), false, function()
        --     frame:Close()
        --     OpenBigMap("main")
        -- end)
        -- but_act:DockMargin(LinvLib:RespW(15), 0, 0, 0)
        -- but_act:Dock(RIGHT)

    else
        panel_main.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(39, 39, 39))
        end
        local image_map = vgui.Create("DImage", panel_main)
        image_map:SetSize(LinvLib:RespW(680), LinvLib:RespH(680))
        image_map:SetMaterial(GetZoneMaterial())
        image_map:Dock(FILL)

        local panel_zones = vgui.Create("DPanel", panel_content)
        panel_zones:SetSize(LinvLib:RespW(150), LinvLib:RespH(100))
        panel_zones:Dock(RIGHT)
        panel_zones:DockMargin(LinvLib:RespW(15), 0, 0, 0)
        panel_zones.Paint = function() end

        local title_zones = LinvLib:LabelPanel(panel_zones, "Zones", "LinvFontRobo25", 400, 60)
        title_zones:Dock(TOP)
        title_zones:DockMargin(0, 0, 0, LinvLib:RespH(15))

        local scroll_zones = vgui.Create("DScrollPanel", panel_zones)
        scroll_zones:Dock(FILL)
        scroll_zones.Paint = function() end

        LinvLib.HideVBar(scroll_zones)
        local zones = LinvMap.MapInfo.zones || {
            ["1"] = {
                ["image_id"] = LinvMap.MapInfo.info.map,
                ["name"] = "Principal"
            }
        }
        for k, v in pairs(zones) do
            local but_zone = LinvLib:Button(scroll_zones, v.name, 200, 50, LinvLib:GetColorTheme("element"), true, function()
                image_map:SetMaterial(LinvMap.MapMaterials[v.image_id])
            end)
            but_zone:Dock(TOP)
            but_zone:DockMargin(0, 0, 0, LinvLib:RespH(15))
        end

        local ply_pos = LocalPlayer():GetPos()
        local ang = math.Round(LocalPlayer():InVehicle() && LocalPlayer():GetVehicle():GetAngles().y || LocalPlayer():GetAngles().y - 90)

        if LinvMap.Config.UseCalibrationCursor then
            local cursor = vgui.Create("DPanel", image_map)
            cursor:SetSize(4, 4)
            cursor:SetPos(PosToMap(ply_pos.x, ply_pos.y, 680, 680))
            cursor.Paint = function(self, w, h)
                surface.SetDrawColor(255, 0, 0)
                surface.DrawRect(0, 0, w, h)
            end
        else
            local cursor_res = (LinvMap.Config.CursorResolution * LinvMap.Config.CursorSize)
            local cursor = vgui.Create("DPanel", image_map)
            cursor:SetSize(cursor_res, cursor_res)
            local pos = {}
            pos.x, pos.y = PosToMap(ply_pos.x, ply_pos.y, 680, 680)
            cursor:SetPos(pos.x - cursor_res / 2, pos.y - cursor_res / 2)
            cursor.Paint = function(self, w, h)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(LinvMap.Materials["cursor"])
                surface.DrawTexturedRectRotated(w / 2, h / 2, cursor_res, cursor_res, ang)
            end
        end

        -- local function GetMaterialFromTeam(team_name)
        --     local is_cop, is_staff = LinvMap.Config.CopTeam[team.GetName(LocalPlayer():Team())], LocalPlayer():IsLinvLibAdmin() && LinvMap.Config.StaffCanSeeAll
        --     if (is_staff || is_cop) && LinvMap.Config.CopTeam[team_name] then
        --         return LinvMap.Materials["player_cop"]
        --     elseif is_staff && LinvMap.Config.CriminalTeam[team_name] then
        --         return LinvMap.Materials["player_enemys"]
        --     elseif is_staff && LinvMap.Config.StaffTeam[team_name] then
        --         return LinvMap.Materials["player_staff"]
        --     end
        --     return is_staff && LinvMap.Materials["player_neutral"] || false
        -- end

        -- for _, ply in pairs(player.GetAll()) do
        --     if ply == LocalPlayer() then continue end

        --     local ply_pos = ply:GetPos()
        --     local ang = math.Round(ply:InVehicle() && ply:GetVehicle():GetAngles().y || ply:GetAngles().y - 90)

        --     if LinvMap.Config.UseCalibrationCursor then
        --         local cursor = vgui.Create("DPanel", image_map)
        --         cursor:SetSize(4, 4)
        --         cursor:SetPos(PosToMap(ply_pos.x, ply_pos.y, 680, 680))
        --         cursor.Paint = function(self, w, h)
        --             surface.SetDrawColor(255, 0, 0)
        --             surface.DrawRect(0, 0, w, h)
        --         end
        --     else
        --         local cursor_res = (LinvMap.Config.CursorResolution * LinvMap.Config.CursorSize) / 3
        --         local cursor = vgui.Create("DPanel", image_map)
        --         cursor:SetSize(cursor_res, cursor_res)
        --         local pos = {}
        --         pos.x, pos.y = PosToMap(ply_pos.x, ply_pos.y, 680, 680)
        --         cursor:SetPos(pos.x - cursor_res / 2, pos.y - cursor_res / 2)
        --         local mat = GetMaterialFromTeam(team.GetName(ply:Team()))
        --         if !mat then continue end
        --         cursor.Paint = function(self, w, h)
        --             surface.SetDrawColor(255, 255, 255, 255)
        --             surface.SetMaterial(mat)
        --             surface.DrawTexturedRectRotated(w / 2, h / 2, cursor_res, cursor_res, ang)
        --         end
        --     end
        -- end
    end
end

hook.Add("OnPlayerChat", "LinvMap:ChatCommand", function(ply, text)
    if ply != LocalPlayer() then return end
    if LinvMap.Config.Command[text] then
        OpenBigMap()
    end
end)
