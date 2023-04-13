// -- // -- // -- // -- // -- // -- // -- //
// You can add your own materials here, this use imgur
// So you need to upload your image to imgur as png and get the ID
// -- // -- // -- // -- // -- // -- // -- //

local imgurID = {
    ["no_map"] = "6PvywOW",
    ["cursor"] = "dnna6rx",
    ["player_friends"] = "F1dqqCe",
    ["player_enemys"] = "YiBLkyT",
    ["player_neutral"] = "PP2JnVR",
    ["player_cop"] = "f4FqNeJ",
    ["player_staff"] = "MFgf9Fa",
}

// -- // -- // -- // -- // -- // -- // -- //
// Do not edit below this line
// -- // -- // -- // -- // -- // -- // -- //

LinvLib.CreateImgurMaterials(imgurID, LinvMap.Materials, "linventif/linvmap/material", "Linventif Map")

hook.Add("InitPostEntity", "LinvMap:GetMapMaterials", function()
    local files = file.Find("linventif/linvmap/map/*", "DATA")
    for k, v in pairs(files) do
        file.Delete("linventif/linvmap/map/" .. v)
    end

    http.Fetch("https://api.linv.dev/addons/map/" .. game.GetMap() .. ".json", function(body, length, headers, code)
        if code != 200 then return end
        LinvMap.MapInfo = util.JSONToTable(body)
        LinvLib.CreateImgurMaterials(LinvMap.MapInfo.info.images, LinvMap.MapMaterials, "linventif/linvmap/map", "Linventif Map")
    end)
end)