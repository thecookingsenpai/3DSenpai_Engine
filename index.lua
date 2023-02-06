Screen.disable3D() --Disabling 3D for the top screen

-- SECTION Program object
local Program = {
    title = "3DSenpai",
    dir = "0_LPP_Test"
}
-- !SECTION Program object

-- SECTION Misc objects
local emptyElement = {
    Element = nil, -- name of the element
    Type = 0, -- 0 = empty, 1 = element, 2 = creature, 3 = object
    Collision = false, -- true / false
    Size = { 0, 0 }, -- Size of the element
    StartingPosition = { 0, 0 }, -- Starting position of the element
    Image = nil, -- Image of the element (object)
    Screen = TOP_SCREEN, -- Screen of the element
    Properties = {} -- Properties of the element (e.g. health, damage, etc.)
}

local elementsTable = {} -- {name = {x,y}}
-- !SECTION Misc objects

-- SECTION Elements object
local Scene = {
    environment = {
        size = { x = 400, y = 240 },
        matrix = {}
    },
    character = {
        image = "assets/character.png",
        imageLoaded = nil,
        position = { x = 176, y = 96 }
    },
    currentScene = nil, -- Current scene method
    imagesToDraw = {} -- A table containing the images to draw each frame
}
-- !SECTION Elements object

-- SECTION Scenes
-- Scenes are functions that are called to draw the scene on the screen at the
-- beginning of the program or when the user changes the scene (e.g. next level)
local firstLevel = function ()
    local isBackground = true
    local isCharacter = true
    local imagesToDraw = {}
    return {isBackground, isCharacter}, imagesToDraw
end
-- !SECTION Scenes

local setScene = function (scene) -- Sets the current scene method
    -- Reset the environment matrix
    for i = 1, Scene.environment.size.x do
        Scene.environment.matrix[i] = {}
        -- Each pixel of the environment contains the informations about the element on it (if any)
        for j = 1, Scene.environment.size.y do
            Scene.environment.matrix[i][j] = {emptyElement}
        end
    end
    local settings = scene() -- Call the scene method that returns settings and images to draw
    Scene.currentScene = settings[0]
    Scene.imagesToDraw = settings[1]
    return true
end

local initialLoad = function ()
    System.currentDirectory("/3ds/" .. Program.dir .. "/")
    Scene.character.imageLoaded = Screen.loadImage(System.currentDirectory()
                                                   .. Scene.character.image)
    -- Setting the first scene
    setScene(firstLevel)
end

-- SECTION Controls check
local keyEvents = function ()
    local pad = Controls.read() -- Read Controls
    if (Controls.check(pad, KEY_START)) then -- check if start is pressed
        System.exit() -- Exit back to HBL
    -- Movements with bounds
    elseif (Controls.check(pad, KEY_DUP)) then
        Scene.character.position.y = Scene.character.position.y - 1
        if (Scene.character.position.y > 195) then
            Scene.character.position.y = 195
        end
    elseif (Controls.check(pad, KEY_DDOWN)) then
        Scene.character.position.y = Scene.character.position.y + 1
        if (Scene.character.position.y < 5) then
            Scene.character.position.y = 5
        end
    elseif (Controls.check(pad, KEY_DRIGHT)) then
        Scene.character.position.x = Scene.character.position.x + 1
        if (Scene.character.position.x > 355) then
            Scene.character.position.x = 355
        end
    elseif (Controls.check(pad, KEY_DLEFT)) then
        Scene.character.position.x = Scene.character.position.x - 1
        if (Scene.character.position.x < 5) then
            Scene.character.position.x = 5
        end
    end
end
-- !SECTION Controls check

local mainGUI = function ()
   -- Load the current scene
   local isBackground = Scene.currentScene[1]
   local isCharacter = Scene.currentScene[2]
   -- Draw the background
   if (isBackground) then
       Screen.fillRect(5, 395, 5, 235, Color.new(255, 0, 0), TOP_SCREEN)
   end
   -- Draw the character
   if (isCharacter) then
       Screen.drawImage(Scene.character.position.x, Scene.character.position.y,
                        Scene.character.imageLoaded, TOP_SCREEN)
   end
   -- Draw the images listed in the imagesToDraw table
   for i, image in pairs(Scene.imagesToDraw) do
       -- REVIEW Should the element be placed in the scene here with 'i'?
       Screen.drawImage(image.StartingPosition[0], image.StartingPosition[1],
                        image.Image, image.Screen)
   end
end

-- SECTION Methods
local isElement = function (x, y)
    if (Scene.environment.matrix[x][y].Element == nil) then
        return false
    else
        return true
    end
end

local elementPosition = function (elementName)
    if (elementsTable[elementName] == nil) then
        return nil
    end
    return elementsTable[elementName]
end

local placeElement = function (x, y, element, imagePath)
    local screen = element.screen or TOP_SCREEN
    -- Ensure the element is not already placed
    if (elementPosition(element.name) ~= nil) then
        return false, "alreadyplaced" -- Element already placed
    end
    -- Ensure the tiles are empty
    for i = x + 1, x + element.width do
        for j = y + 1, y + element.height do
            if isElement(x, y) then
                return false, "notempty" -- Tile is not empty
            end
        end
    end
    -- Loading the image
    local imageObject = Screen.loadImage(System.currentDirectory() .. imagePath)
    -- Setting the starting cell
    Scene.environment.matrix[x][y].Element = element.name
    Scene.environment.matrix[x][y].Type = element.type
    Scene.environment.matrix[x][y].Collision = element.collision
    Scene.environment.matrix[x][y].StartingPosition = {x, y}
    Scene.environment.matrix[x][y].Size = {element.width, element.height}
    Scene.environment.matrix[x][y].Image = imageObject
    Scene.environment.matrix[x][y].Screen = screen
    Scene.environment.matrix[x][y].Properties = element.properties
    -- Filling the matrix with the element
    for i = x + 1, x + element.width do
        for j = y + 1, y + element.height do
            Scene.environment.matrix[i][j] = Scene.environment.matrix[x][y]
        end
    end
    -- Adding the element to the elements table
    elementsTable[element.name] = {x, y}
    return true, "placed"
end

local removeElement = function (elementName)
    -- Getting the element coordinates
    local coordinates = elementPosition(elementName)
    -- Check if the element is in the elements table
    if (coordinates == nil) then
        return
    end
    local x = coordinates[1]
    local y = coordinates[2]
    -- Setting the starting cell
    Scene.environment.matrix[x][y] = {emptyElement}
    -- Filling the matrix with the element
    for i = x + 1, x + element.width do
        for j = y + 1, y + element.height do
            Scene.environment.matrix[i][j] = Scene.environment.matrix[x][y]
        end
    end
end


local checkTileCollision = function (x, y)
    if (Scene.environment.matrix[x][y].Collision) then
        return true
    else
        return false
    end
end
-- !SECTION Methods

local mainLoop = function ()
    Screen.waitVblankStart() -- Screen related stuff
    Screen.refresh() -- Other Screen related stuff
    Screen.clear(TOP_SCREEN) -- Clear top screen
    Screen.clear(BOTTOM_SCREEN) -- Clear bottom screen
    -- Keypress handling
    keyEvents() -- Check for key events
    -- Elements on screen
    mainGUI()
    Screen.flip() -- More screen related stuff
end

-- START MAIN LOGIC
initialLoad()

-- Continuously loop
while (true) do
    mainLoop() -- Draw to screen
end


