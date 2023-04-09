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

local function DrawMinimap()
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
    surface.SetMaterial(LinvMap.Materials[game.GetMap()] || LinvMap.Materials["no_map"])

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