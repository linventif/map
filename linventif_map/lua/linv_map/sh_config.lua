// -- // -- // -- // -- // -- // -- // -- //
// This addon can't work without Linventif Library : https://linv.dev/docs/#library
// Some configuration are only editable in Linventif Monitor : https://linv.dev/docs/#monitor
// If you have any problem with this addon please contact me on discord : https://linv.dev/discord
// -- // -- // -- // -- // -- // -- // -- //

LinvMap.Config.UseCircleMap = true // If true, the map will be a circle, if false, the map will be a square

// Cursor
LinvMap.Config.UseCalibrationCursor = false
LinvMap.Config.CursorResolution = 180
LinvMap.Config.CursorSize = 0.2

// Advanced
LinvMap.Config.ShowOtherPlayers = true
LinvMap.Config.ShowEnemy = true
LinvMap.Config.ShowNeutral = true
LinvMap.Config.ShowFriendly = true

// Cop
LinvMap.Config.CopCanSeeCop = true
LinvMap.Config.CopTeam = {
    ["Civil Protection"] = true,
    ["Police"] = true,
}

// Staff
LinvMap.Config.StaffCanSeeAll = true // If true, staff can see all players
LinvMap.Config.StaffTeam = { // Staff team
    ["Staff"] = true,
    ["Staff on Duty"] = true,
}

// Command
LinvMap.Config.Command = {
    ["/map"] = true,
    ["!map"] = true,
}