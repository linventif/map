// -- // -- // -- // -- // -- // -- // -- //
// You can add your own materials here, this use imgur
// So you need to upload your image to imgur as png and get the ID
// -- // -- // -- // -- // -- // -- // -- //

local imgurID = {
    ["no_map"] = "bANAhi8",
    ["gm_mini_map"] = "ggtZgtZ",
    ["rp_rockford_v2b"] = "02IMkDg",
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