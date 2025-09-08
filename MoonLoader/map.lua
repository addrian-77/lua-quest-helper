script_name("sqh")
script_author("linux1337")

-- Map location: MoonLoader/resource/img/map.png
-- Points location: MoonLoader/resource/cfg/map_points.ini
-- Usage: /map to toggle the map and /resetmap to wipe the points
-- lEGION MODS -> https://discord.gg/zareAn6WNE | Author discord -> linux1337

local imgui = require("imgui")
local encoding = require("encoding")
local inicfg = require("inicfg")
local vkeys = require('vkeys')
local sampev = require 'lib.samp.events'

encoding.default = "CP1251"
u8 = encoding.UTF8

tabl = {}
local style = imgui.GetStyle()
local colors = style.Colors
local clr = imgui.Col
local ImVec4 = imgui.ImVec4
style.WindowRounding = 0

local baseColor = ImVec4(0.039, 0.451, 0.365, 1)  -- #0a735d

local hoveredColor = ImVec4(0.059, 0.553, 0.420, 1) 

local activeColor = ImVec4(0.027, 0.345, 0.275, 1) 

local checkMarkColor = baseColor

local frameBgHoveredColor = ImVec4(0.059, 0.553, 0.420, 1) 
local frameBgActiveColor = ImVec4(0.027, 0.345, 0.275, 1)  

colors[clr.TitleBg]                = baseColor
colors[clr.TitleBgActive]          = activeColor
colors[clr.TitleBgCollapsed]       = ImVec4(0.039, 0.451, 0.365, 0.1)
colors[clr.Button]                 = baseColor
colors[clr.ButtonHovered]          = hoveredColor
colors[clr.ButtonActive]           = activeColor
colors[clr.CheckMark]              = checkMarkColor
colors[clr.FrameBgHovered]         = frameBgHoveredColor
colors[clr.FrameBgActive]          = frameBgActiveColor
colors[clr.Border]                 = baseColor

local mapImagePath = getWorkingDirectory() .. "\\resource\\img\\map.png"
local pointsFilePath = getWorkingDirectory() .. "\\resource\\cfg\\map_points.ini"
local settingsFilePath = getWorkingDirectory() .. "\\resource\\cfg\\map_size.ini"
local blipImagePath = getWorkingDirectory() .. "\\resource\\img\\blip.png"

local blipTexture = nil

local mapWidth, mapHeight
local oldMapWidth, oldMapHeight = mapWidth, mapHeight 

local radius
local mapSizes = {400, 500, 600, 700, 800, 1020}
local pointRadius = {3, 4, 4, 5, 6, 7}

local showMap = imgui.ImBool(false)
local showMapKey = imgui.ImBool(false)
local mapPoints = {}
local isMapLoaded = false

local enabledMap

local mapTexture = nil

function main()
    while not isSampAvailable() do wait(100) end
    wait(200)
    sampAddChatMessage("[SQH]: /map {ffffff} to see the map. Use {1dbe88}/resetmap {ffffff} to reset it.", 0x36c797)
    sampAddChatMessage("[SQH]: /mk {ffffff} to mark a position. Use {1dbe88}/rmlast {ffffff} to remove the last point.", 0x36c797)
    sampRegisterChatCommand("map", toggleMap)
    sampRegisterChatCommand("resetmap", resetMap)
    sampRegisterChatCommand("rmlast", removeLast)
    sampRegisterChatCommand("mk", markObject)
    sampRegisterChatCommand("mk1", markObjectGreen)
    sampRegisterChatCommand("mk2", markObjectYellow)
    sampRegisterChatCommand("mk3", markObjectOrange)
    sampRegisterChatCommand("mapsize", resizeMap)
    sampRegisterChatCommand("togmap", togMap)

    loadMapPoints()
    loadMapSettings()

    while true do
        wait(0)
        imgui.Process = showMap.v or showMapKey.v

        if isKeyDown(0x4D) and not sampIsChatInputActive() then  -- 'M' key
            showMapKey.v = true
            imgui.ShowCursor = false
        else
            showMapKey.v = false
            imgui.ShowCursor = true
        end
        
        if not isMapLoaded then
            mapTexture = imgui.CreateTextureFromFile(mapImagePath)
            if mapTexture == nil then
                sampAddChatMessage("[SQH]: Failed to load map.png", 0xFF0000)
            else
                isMapLoaded = true
            end
            blipTexture = imgui.CreateTextureFromFile(blipImagePath)
            if blipTexture == nil then
                sampAddChatMessage("[SQH]: Failed to load blip.png", 0xFF0000)
            end
        end
    end
end

function toggleMap()
    showMap.v = not showMap.v
end

function togMap()
    enabledMap = not enabledMap
    saveMapSettings()
    if enabledMap == false then
        sampAddChatMessage("[SQH]: Show on 'M' press {ff1900}Disabled", 0x36c797)
    else
        sampAddChatMessage("[SQH]: Show on 'M' press {1ed402}Enabled", 0x36c797)
    end
end

function markObject()
    local cx, cy, cz = getCharCoordinates(PLAYER_PED)

    if cx and cy then
        local xn = (cx + 3000) / 6000
        local yn = (3000 - cy) / 6000
        local xp = xn * (mapWidth - 1)
        local yp = yn * (mapHeight - 1)

        sampAddChatMessage("[SQH]: Marked object at location: X: " .. string.format("%.2f", xp) .. " | Y: " .. string.format("%.2f", yp), 0x36c797)
        local pos = {x = xp, y = yp, r = 1, g = 0, b = 0, a =1, facing = 0}
        table.insert(mapPoints, pos)
        saveMapPoints()
    else
        sampAddChatMessage("Error: Invalid coordinates received.", -1)
    end
end

function markObjectGreen(arg)
    if #arg == 0 then
        sampAddChatMessage("Syntax: /mk1 <-1 | 0 | 1>", -1)
    else
        local arg_int = tonumber(arg)
        if arg_int == -1 or arg_int == 0 or arg_int == 1 then
            local cx, cy, cz = getCharCoordinates(PLAYER_PED)
            if cx and cy then
                local xn = (cx + 3000) / 6000
                local yn = (3000 - cy) / 6000
                local xp = xn * (mapWidth - 1)
                local yp = yn * (mapHeight - 1)

                sampAddChatMessage("[SQH]: Marked object at location: X: " .. string.format("%.2f", xp) .. " | Y: " .. string.format("%.2f", yp), 0x36c797)
                local pos = {x = xp, y = yp, r = 0.2823, g = 0.7921, b = 0.0274, a = 1, facing = arg_int}
                table.insert(mapPoints, pos)
                saveMapPoints()
            else
                sampAddChatMessage("Error: Invalid coordinates received.", -1)
            end
        else
            sampAddChatMessage("Invalid value!", -1)
        end
    end
end

function markObjectYellow()
    local cx, cy, cz = getCharCoordinates(PLAYER_PED)

    if cx and cy then
        local xn = (cx + 3000) / 6000
        local yn = (3000 - cy) / 6000
        local xp = xn * (mapWidth - 1)
        local yp = yn * (mapHeight - 1)

        sampAddChatMessage("[SQH]: Marked object at location: X: " .. string.format("%.2f", xp) .. " | Y: " .. string.format("%.2f", yp), 0x36c797)
        local pos = {x = xp, y = yp, r = 1, g = 0.945, b = 0.3137, a = 1, facing = 0}
        table.insert(mapPoints, pos)
        saveMapPoints()
    else
        sampAddChatMessage("Error: Invalid coordinates received.", -1)
    end
end

function markObjectOrange()
    local cx, cy, cz = getCharCoordinates(PLAYER_PED)

    if cx and cy then
        local xn = (cx + 3000) / 6000
        local yn = (3000 - cy) / 6000
        local xp = xn * (mapWidth - 1)
        local yp = yn * (mapHeight - 1)

        sampAddChatMessage("[SQH]: Marked object at location: X: " .. string.format("%.2f", xp) .. " | Y: " .. string.format("%.2f", yp), 0x36c797)
        local pos = {x = xp, y = yp, r = 1, g = 0.6156, b = 0, a = 1, facing = 0}
        table.insert(mapPoints, pos)
        saveMapPoints()
    else
        sampAddChatMessage("Error: Invalid coordinates received.", -1)
    end
end


function resizeMap(arg)
    if #arg == 0 then
        sampAddChatMessage("Syntax: /mapsize <0-5>", -1)
    else
        local index = tonumber(arg)
        if index >= 0 and index <= 5 then
            index = index + 1
            oldMapWidth = mapWidth
            oldMapHeight =  mapHeight
            mapWidth = mapSizes[index]
            mapHeight = mapSizes[index]
            radius = pointRadius[index]
            local scale = mapWidth / oldMapWidth

            for _, point in ipairs(mapPoints) do
                point.x = point.x * scale
                point.y = point.y * scale
            end

            saveMapPoints()
            saveMapSettings()
            sampAddChatMessage("[SQH]: Resized map to: " ..mapWidth.. "x" ..mapHeight.. "px", 0x36c797)
        else
            sampAddChatMessage("Syntax: /mapsize <0-5>", -1)
        end
    end
end

function resetMap()
    mapPoints = {}

    os.remove(pointsFilePath)  

    local file = io.open(pointsFilePath, "w")  
    if file then
        file:close() 
    end

    sampAddChatMessage("[SQH]: All map points have been removed.", 0x36c797)
end



function removeLast()
    if #mapPoints > 0 then  -- Check if there are any points to remove
        table.remove(mapPoints, #mapPoints)  -- Remove the last element
        saveMapPoints()  -- Save the updated mapPoints
        sampAddChatMessage("[SQH]: Last point has been removed.", 0x36c797)
    else
        sampAddChatMessage("[SQH]: No points to remove.", 0x36c797)
    end
end

function saveMapSettings()
    local settingsData = {
        map = {
            width = mapWidth,
            height = mapHeight,
            radius = radius,
            enabledMap = enabledMap
        }
    }
    inicfg.save(settingsData, settingsFilePath)
    sampAddChatMessage("[SQH]: Map settings saved.", 0x36c797)
end

function loadMapSettings()
    local settingsData = inicfg.load({ map = { width = 500, height = 500, radius = 4 } }, settingsFilePath)
    if settingsData and settingsData.map then
        mapWidth = settingsData.map.width
        mapHeight = settingsData.map.height
        radius = settingsData.map.radius
        enabledMap = settingsData.map.enabledMap
        sampAddChatMessage("[SQH]: Map settings loaded.", 0x36c797)
    else
        sampAddChatMessage("[SQH]: Failed to load map settings, using defaults.", 0xFF0000)
    end
end

function saveMapPoints()
    local saveData = {}
    for _, point in ipairs(mapPoints) do
      table.insert(saveData, {x = point.x, y = point.y, r = point.r, g = point.g, b = point.b, a = point.a, facing = point.facing})
    end
  
    inicfg.save(saveData, pointsFilePath)
  end
  
function loadMapPoints()
    local loadedData = inicfg.load(nil, pointsFilePath)
  
    if loadedData then
      mapPoints = {}
  
      for _, point in ipairs(loadedData) do
        if type(point.x) == "number" and type(point.y) == "number" then
            table.insert(mapPoints, point)
            -- sampAddChatMessage("obtained " ..mapPoints[1].x.. " " ..mapPoints[1].r.. " " ..mapPoints[1].facing.. "", -1)
        end
      end
    else
      mapPoints = {}
      sampAddChatMessage("[SQH]: Failed to load map points.", 0x36c797)
    end
end
  


function imgui.OnDrawFrame()
    if isKeyJustPressed(0x1B) then  -- Escape key
        showMap.v = false  -- Close the map dialog
    end
    if showMap.v or (showMapKey.v and enabledMap) then
        imgui.SetNextWindowSize(imgui.ImVec2(mapWidth + 20, mapHeight + 40), imgui.Cond.Always)
        imgui.Begin(u8"Quest Helper by linux1337", showMap, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + (showMapKey.v and imgui.WindowFlags.NoInputs or 0))
        if mapTexture then

            local mapPosition = imgui.GetCursorScreenPos()
            imgui.Image(mapTexture, imgui.ImVec2(mapWidth, mapHeight))

            if imgui.IsItemClicked(0) then
                local mousePos = imgui.GetMousePos()
                local clickPos = {x = mousePos.x - mapPosition.x, y = mousePos.y - mapPosition.y, r = 1, g = 0, b = 0, a = 1, facing = 0}
                if clickPos.x >= 0 and clickPos.x <= mapWidth and clickPos.y >= 0 and clickPos.y <= mapHeight then
                    table.insert(mapPoints, clickPos)
                    saveMapPoints()
                end
            end

            local cx, cy, cz = getCharCoordinates(PLAYER_PED)
            if cx and cy and blipTexture then
                local xn = (cx + 3000) / 6000
                local yn = (3000 - cy) / 6000
                local xp = xn * (mapWidth - 1)
                local yp = yn * (mapHeight - 1)

                -- Get the player's facing angle
                local heading = getCharHeading(PLAYER_PED)  
                local headingRadians = math.rad(heading)

                -- Correct the heading by adding 180 degrees (π radians)
                local correctedHeadingRadians = headingRadians

                -- Calculate the rotated blip's corners for drawing
                local blipSize = radius * 2
                local halfSize = blipSize * 0.9
                local cosH = math.cos(correctedHeadingRadians)
                local sinH = -math.sin(correctedHeadingRadians)

                -- Define each corner's position with the corrected rotation applied
                local topLeft = imgui.ImVec2(mapPosition.x + xp - halfSize * cosH + halfSize * sinH, mapPosition.y + yp - halfSize * sinH - halfSize * cosH)
                local topRight = imgui.ImVec2(mapPosition.x + xp + halfSize * cosH + halfSize * sinH, mapPosition.y + yp + halfSize * sinH - halfSize * cosH)
                local bottomRight = imgui.ImVec2(mapPosition.x + xp + halfSize * cosH - halfSize * sinH, mapPosition.y + yp + halfSize * sinH + halfSize * cosH)
                local bottomLeft = imgui.ImVec2(mapPosition.x + xp - halfSize * cosH - halfSize * sinH, mapPosition.y + yp - halfSize * sinH + halfSize * cosH)

                -- Draw the blip texture with rotation
                imgui.GetWindowDrawList():AddImageQuad(
                    blipTexture,
                    topLeft,
                    topRight,
                    bottomRight,
                    bottomLeft
                )
            end


            for _, point in ipairs(mapPoints) do
                -- sampAddChatMessage("obtained " ..point.x.. " " ..point.y.. " " ..point.r.. " " ..point.g.. " " ..point.b.. " " ..point.a.. " "..point.facing, -1)
                imgui.GetWindowDrawList():AddCircleFilled(
                    imgui.ImVec2(mapPosition.x + point.x, mapPosition.y + point.y),
                    radius,  -- Radius
                    imgui.GetColorU32(imgui.ImVec4(point.r, point.g, point.b, point.a))  -- Use color from point
                )
            end
        else
            imgui.Text(u8"Failed to load map image.")
        end

        imgui.End()
    end
end