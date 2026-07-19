-- ========================================================================
-- [[ LOUIS HUB - TIME BOMB DUELS FUNCTIONAL PREMIUM EDITION (OPTIMIZED) ]]
-- ========================================================================

-- UPVALUE CACHING FOR MAXIMUM PERFORMANCE UNDER OBFUSCATION
local Vector3_new = Vector3.new
local CFrame_new = CFrame.new
local CFrame_Angles = CFrame.Angles
local CFrame_lookAt = CFrame.lookAt or function(p, t) return CFrame.new(p, t) end
local math_rad = math.rad
local math_random = math.random
local math_clamp = math.clamp
local math_huge = math.huge
local tick = tick
local ipairs = ipairs
local pairs = pairs
local tonumber = tonumber
local pcall = pcall
local task_wait = task.wait
local task_spawn = task.spawn
local task_defer = task.defer

-- Macro definition for local compatibility before obfuscation
local LPH_NO_VIRTUALIZE = LPH_NO_VIRTUALIZE or function(f) return f end

-- Safe fallback to prevent runtime crashes on slider updates
local function updateSliderLabelSafe(val) end

-- 1. LOAD UI LIBRARY FROM YOUR SOURCE
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/justone07696-blip/JAZB-7-sourcecodeLLH-.-lua/refs/heads/main/UI%20Library/V1.lua"))()

-- 2. SETUP MAIN ROBLOX SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ========================================================
-- [[ GITHUB RAW COORDINATES CONFIGURATION ]]
-- ========================================================
-- Base URL configured to point directly to your gamerlatahzan-design GitHub repository
local BaseUrl = "https://raw.githubusercontent.com/gamerlatahzan-design/CFRAMELUAHUB/refs/heads/main/"

-- Safe mapped database for path IDs, displays, and encoding to prevent space crashes in UI Library
local FlingPaths = {
    {id = "FlingLeft",     display = "Fling Left",      file = "LouisPath_fling%20left.lua"},
    {id = "FlingLeft2",    display = "Fling Left 2",    file = "LouisPath_fling%20left%202.lua"},
    {id = "FlingLeft3",    display = "Fling Left 3",    file = "LouisPath_fling%20left%203.lua"},
    {id = "FlingLeft4",    display = "Fling Left 4",    file = "LouisPath_fling%20left%204.lua"},
    {id = "FlingLeftBack", display = "Fling Left Back", file = "LouisPath_fling%20left%20back%20.lua"},
    {id = "FlingRight",    display = "Fling Right",     file = "LouisPath_fling%20right.lua"},
    {id = "FlingRight1",   display = "Fling Right 1",   file = "LouisPath_fling%20right%201.lua"},
    {id = "FlingRight2",   display = "Fling Right 2",   file = "LouisPath_fling%20right%202.lua"},
    {id = "FlingRight3",   display = "Fling Right 3",   file = "LouisPath_fling%20right%203.lua"},
    {id = "FlingRightBack1", display = "Fling Right Back 1", file = "LouisPath_fling%20right%20back%201.lua"},
    {id = "FlingRightBack2", display = "Fling Right Back 2", file = "LouisPath_fling%20right%20back%202.lua"},
    {id = "FlingRightBack3", display = "Fling Right Back 3", file = "LouisPath_fling%20right%20back%203.lua"}
}

local PathButtons = {} -- Stores dynamically generated external floating button instances
local ExternalButtonStates = {} -- Tracks manual visibility selection states of each path button
_G.CustomPathsEnabled = false
_G.FlingSpeedMultiplier = 5.0 -- Default speed configured to 5.0x

-- DYNAMIC CFRAME PATH PLAYER
local function playPath(pathId, pathData)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, point in ipairs(pathData) do
        -- Instant termination check if custom paths are toggled Off or if individual button is disabled [1]
        if not _G.CustomPathsEnabled or not ExternalButtonStates[pathId] then 
            break 
        end
        
        if not hrp or not hrp.Parent then break end
        if point.cf then
            pcall(function()
                hrp.CFrame = CFrame.new(table.unpack(point.cf))
            end)
        end
        
        -- Applies playback speed multiplier directly to the recorded delta time
        local speedMult = _G.FlingSpeedMultiplier or 5.0
        task_wait((point.dt or 0.016) / speedMult) 
    end
end

-- REAL-TIME DOWNLOADER & SCRIPT REPLICATION RUNNER
local function triggerPath(pathInfo)
    local url = BaseUrl .. pathInfo.file

    -- Trigger execution notification using new Library name [1]
    Library:CreateNotification("Fling Active", "Executing: " .. pathInfo.display:upper(), 1.5)

    -- Process download coordinates from GitHub raw and execute path once [1]
    task_spawn(function()
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)

        if success and result then
            local successLoad, pathTable = pcall(function()
                return loadstring(result)()
            end)

            if successLoad and type(pathTable) == "table" then
                playPath(pathInfo.id, pathTable)
            else
                Library:CreateNotification("Error", "Failed to process coordinate structure for: " .. pathInfo.display, 2.5)
            end
        else
            Library:CreateNotification("Error", "Failed to download " .. pathInfo.display .. " from GitHub.", 2.5)
        end
    end)
end

-- ========================================================
-- [[ DYNAMIC CUSTOM PATHS GENERATOR ]]
-- ========================================================
local function setupPathButtons()
    -- Dynamically toggle button visibility based on master toggle and individual selections [1]
    for _, pathInfo in ipairs(FlingPaths) do
        local extBtn = PathButtons[pathInfo.id]
        if extBtn then
            if _G.CustomPathsEnabled then
                local isVisible = ExternalButtonStates[pathInfo.id] or false
                SafeSetVisible(extBtn, isVisible)
            else
                SafeSetVisible(extBtn, false)
            end
        end
    end
end

-- ========================================================
-- [[ GLOBAL GAMEPLAY STATES ]]
-- ========================================================
_G.FollowEnabled = false
_G.FollowActive = false 
_G.PredictEnabled = false 
_G.HJEnabled = false 
_G.FlickEnabled = false 
_G.FlickActive = false
_G.FlickStrength = 45
_G.FlickTargetMode = "Camera Only" 
_G.CharFlickStrength = 45 
_G.WallHopDist = 2.5 
_G.WallhopEnabled = false
_G.WallhopActive = false
_G.WallhopMode = "Manual"
_G.WallhopType = "Normal"
_G.WallhopDetectionMode = "Raycast Only" 
_G.WallhopFlickMode = "Default" 
_G.WallhopStudEnabled = true
_G.PotatoEnabled = false

_G.FOVEnabled = false
_G.FOVValue = 70
_G.FreezeEnabled = false

-- Target hijacking configuration
_G.HijackEnabled = true
_G.HijackDistance = 7

-- Player ESP configuration
_G.ESPEnabled = false

-- INFINITE JUMP STATE
_G.InfJumpEnabled = false
_G.MaxJumpCount = 5
_G.CurrentJumpCount = 0

-- AUTO HOLD BOMB STATE
_G.AutoHoldEnabled = false
_G.AutoHoldActive = false

-- SCREEN RESOLUTION (STRETCH RES) STATE
_G.ResolutionEnabled = false
_G.ResolutionValue = 1.0

-- GLOBAL SIZE VALUES
_G.UIScaleValue = 100
_G.ExtScaleValue = 100

-- NEW AUTO WALK FEATURE
_G.AutoWalkEnabled = false
_G.AutoWalkActive = false
_G.AutoWalkRetreatSpeed = 22

-- NEW AUTO & MANUAL PASS BOMB FEATURE
_G.AutoPassEnabled = false
_G.PassTargetMode = "Without Bomb" 
_G.PassMaxDistance = 100 
_G.PassExternalVisible = false 

-- ========================================================
-- [[ INTEGRATED NEW FEATURES STATE GLOBALS ]]
-- ========================================================
_G.RangeChaseEnabled = false
_G.RangeChaseValue = 30
_G.TripEnabled = false

-- FOLLOW & RETREAT MODE SELECTION
_G.FollowTypeMode = "Follow + Retreat" 

-- LOCAL LIMBS HITBOX EXPANDER STATE (OPPONENTS TARGET)
_G.LocalHitboxEnabled = true 
_G.HitboxVisualEnabled = true 
_G.LocalHitboxSize = 2.0
_G.HitboxTeleportDelay = 0.04 
_G.HitboxShape = "Cylinder"

-- CORE WALK VALUES
_G.TPWalkEnabled = false
_G.TPWalkSpeed = 16

-- CAMLOCK STATE
_G.CamlockEnabled = false
_G.CamlockActive = false

-- DESYNC IMMUNITY & GHOST VISUAL STATE
_G.DesyncImmunityEnabled = false
_G.DesyncImmunityActive = false
_G.DesyncVisualEnabled = false

local CFrameHistory = {}
local GhostModel = nil
local LocalHitboxPart = nil
local isHeadlessActive = false
local isKorbloxActive = false
local RangeVisualPart = nil

-- State Internal TBD
local faceSpeed = 0.18
local lockedTarget = nil 
local lastHadBomb = false
local retreatTimer = 0
local autoWalkRetreatTimer = 0
local targetMemory = 0 
local bombTimer = 0 
local isLocked = false
local canWallJump = true
local jumpDebounce = false
local isTweening = false
local lastWallHopTime = 0
local lastShouldFollow = false

-- Performance Throttling & Caching Variables
local lastRaycastCheck = 0
local lastTargetSearch = 0
local raycastInterval = 0.1
local searchInterval = 0.25
local isVisibleCached = false
local lastAutoWalkRaycast = 0
local currentMoveDir = Vector3_new(0, 0, 0)

-- Camera Rotation Cache
local isSticking = false
local previewContainers = {} 

-- ========================================================
-- [[ CUSTOM GLOBAL KEYBIND CONFIGURATION SYSTEM ]]
-- ========================================================
local Keybinds = {
    FollowToggle = Enum.KeyCode.None,
    AutoWalkToggle = Enum.KeyCode.None,
    AutoPassToggle = Enum.KeyCode.None,
    RangeChaseToggle = Enum.KeyCode.None,
    FlickToggle = Enum.KeyCode.None,
    AutoHoldToggle = Enum.KeyCode.None,
    TripToggle = Enum.KeyCode.None,
    FreezeToggle = Enum.KeyCode.None,
    InfJumpToggle = Enum.KeyCode.None,
    WallhopToggle = Enum.KeyCode.None,
    HitboxToggle = Enum.KeyCode.None,
    CrosshairToggle = Enum.KeyCode.None,
    CamlockToggle = Enum.KeyCode.None,
    TPWalkToggle = Enum.KeyCode.None,
    DesyncImmunityToggle = Enum.KeyCode.None
}

-- Initialize path Keybind entries
for _, pathInfo in ipairs(FlingPaths) do
    Keybinds[pathInfo.id] = Enum.KeyCode.None
end

-- ========================================================
-- [[ DYNAMIC CUSTOM CROSSHAIR STATE & PRESETS ]]
-- ========================================================
_G.CrosshairSettings = {
    Enabled = false,
    Style = "Cross",
    Size = 10,
    Gap = 5,
    Thickness = 1.5,
    Color = Color3.fromRGB(0, 255, 150),
    Rainbow = false,
    ImageId = "6877713475",
    Rotation = 0,
    AutoSpin = false,
    SpinSpeed = 50,
    OnlyShiftLock = false,
    HideDefaultCursor = true
}
_G.CrosshairLoaded = false

local PresetNames = {
    "Preset 1 (ID: 6877713475)", "Preset 2 (ID: 11767039030)", "Preset 3 (ID: 11763581182)",
    "Preset 4 (ID: 11816181606)", "Preset 5 (ID: 11816262829)", "Preset 6 (ID: 11894211724)",
    "Preset 7 (ID: 11903012166)", "Preset 8 (ID: 12308297405)", "Preset 9 (ID: 13515759440)",
    "Preset 10 (ID: 13561401101)", "Preset 11 (ID: 13413721933)", "Preset 12 (ID: 12952422567)",
    "Preset 13 (ID: 12789524132)", "Preset 14 (ID: 12681078223)", "Preset 15 (ID: 12403457353)",
    "Preset 16 (ID: 17665878559)", "Preset 17 (ID: 11863480747)", "Preset 18 (ID: 11958213641)",
    "Preset 19 (ID: 17117394116)", "Preset 20 (ID: 10879103438)", "Preset 21 (ID: 12099552082)",
    "Preset 22 (ID: 12645685438)", "Preset 23 (ID: 13187494895)", "Preset 24 (ID: 14165283181)",
    "Preset 25 (ID: 14196151488)", "Preset 26 (ID: 14175340156)", "Preset 27 (ID: 15064835974)",
    "Preset 28 (ID: 11717828334)", "Preset 29 (ID: 11770890261)", "Preset 30 (ID: 12436450999)",
    "Preset 31 (ID: 14828905230)", "Preset 32 (ID: 5112357171)", "Preset 33 (ID: 8351520948)",
    "Preset 34 (ID: 12294092863)", "Preset 35 (ID: 11746881057)", "Preset 36 (ID: 11756692092)",
    "Preset 37 (ID: 11763243469)", "Preset 38 (ID: 12077205402)", "Preset 39 (ID: 12146988029)",
    "Preset 40 (ID: 2366671460)", "Preset 41 (ID: 11915618919)", "Preset 42 (ID: 10164277641)",
    "Preset 43 (ID: 4818758746)", "Preset 44 (ID: 11720549778)", "Preset 45 (ID: 15963047794)",
    "Preset 46 (ID: 13413667445)", "Preset 47 (ID: 12323570810)", "Preset 48 (6877713475)",
    "Preset 49 (9126971642)", "Preset 50 (6848903054)"
}

local CrosshairColorPresets = {
    ["Green (Neon)"] = Color3.fromRGB(0, 255, 150),
    ["Red"] = Color3.fromRGB(255, 75, 75),
    ["Blue"] = Color3.fromRGB(0, 150, 255),
    ["White"] = Color3.fromRGB(255, 255, 255),
    ["Yellow"] = Color3.fromRGB(255, 220, 0),
    ["Cyan"] = Color3.fromRGB(0, 255, 255),
    ["Pink"] = Color3.fromRGB(255, 100, 200)
}

-- [[ FORWARD DECLARATIONS ]]
local triggerManualPass
local applyFreeze
local stopFreeze
local startFreeze
local isFreezing = false
local updatePlayersHitboxes
local cleanHitboxes
local updateWallhopButtonsSync
local ToggleFeature = nil

-- ========================================================================
-- [[ SAFE VISIBILITY & TEXT HELPERS FOR STANDARD FRAMES ]]
-- ========================================================================
local function SafeSetVisible(btn, visible)
    if typeof(btn) == "Instance" then
        pcall(function() btn.Visible = visible end)
    elseif type(btn) == "table" and btn.SetVisible then
        pcall(function() btn:SetVisible(visible) end)
    end
end

local function SafeSetText(btn, text)
    if typeof(btn) == "Instance" then
        pcall(function()
            local txtBtn = btn:FindFirstChildOfClass("TextButton")
            if txtBtn then
                txtBtn.Text = text
            end
        end)
    elseif type(btn) == "table" and btn.SetText then
        pcall(function() btn:SetText(text) end)
    end
end

-- ========================================================
-- [[ RE-EXECUTION CLEANUP SYSTEM ]]
-- ========================================================
if _G.LouisConnections then
    for _, conn in pairs(_G.LouisConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
end
_G.LouisConnections = {}

local function SafeConnect(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(_G.LouisConnections, conn)
    return conn
end

pcall(function()
    local successHui, hui = pcall(function() return gethui and gethui() end)
    local parent = (successHui and hui) or game:GetService("CoreGui")
    local oldHUD = parent:FindFirstChild("Nexus_Compkiller_UI")
    if oldHUD then oldHUD:Destroy() end
end)

pcall(function()
    local oldVisual = workspace:FindFirstChild("LouisHub_RangeVisual")
    if oldVisual then oldVisual:Destroy() end
    local oldLocalVisual = workspace:FindFirstChild("LocalHitboxVisual")
    if oldLocalVisual then oldLocalVisual:Destroy() end
    local oldGhost = workspace:FindFirstChild("DesyncGhost")
    if oldGhost then oldGhost:Destroy() end
end)

-- Remove old ESP highlights
for _, p in ipairs(Players:GetPlayers()) do
    if p.Character then
        local esp = p.Character:FindFirstChild("LouisESP")
        if esp then pcall(function() esp:Destroy() end) end
    end
end

-- ========================================================
-- [[ TBD GRAPHICS & CORE HELPER FUNCTIONS ]]
-- ========================================================
local function ApplyPotato()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 250
        Lighting.Brightness = 2
        local s = settings()
        s.Rendering.QualityLevel = 1
        s.Physics.AllowSleep = true
    end)
    task_defer(function()
        local function Clean(v)
            if not v:IsA("BasePart") and not v:IsA("MeshPart") then 
                if v:IsA("Decal") or v:IsA("Texture") or v:IsA("Light") then v:Destroy()
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
                return 
            end
            v.Material = Enum.Material.SmoothPlastic
            v.CastShadow = false
            v.Reflectance = 0
            if v:IsA("MeshPart") then v.TextureID = "" end
        end
        local descendants = workspace:GetDescendants()
        for i, v in ipairs(descendants) do 
            pcall(Clean, v) 
            if i % 200 == 0 then 
                task_wait()
            end
        end
    end)
end

-- ADVANCED BOMB CHECKER (STRICT BOMB TOOL & MODEL DETECTION - NO ACC_COSMETIC CLASH)
local function hasBomb(p) 
    if not p or not p.Character then return false end
    local char = p.Character
    
    local bomb = char:FindFirstChild("Bomb")
    if bomb and (bomb:IsA("Tool") or bomb:IsA("Model")) then
        return true
    end
    
    local backpack = p:FindFirstChildOfClass("Backpack")
    if backpack and backpack:FindFirstChild("Bomb") then
        return true
    end
    
    return false
end

-- HIGH-PERFORMANCE TIMER SCANNER
local cachedBombLabel = nil
local lastBombLabelCheck = 0
local function getBombTime()
    local now = tick()
    if cachedBombLabel and cachedBombLabel.Parent and cachedBombLabel.Visible then
        local cleanTxt = cachedBombLabel.Text:match("[%d%.]+")
        if cleanTxt then
            local num = tonumber(cleanTxt)
            if num and num > 0 and num <= 30 then
                return num
            end
        end
    else
        cachedBombLabel = nil
    end
    
    if now - lastBombLabelCheck >= 0.5 then
        lastBombLabelCheck = now
        
        -- Priority Direct Check: Check character for BillboardGuis on the bomb
        local char = LocalPlayer.Character
        if char then
            local bomb = char:FindFirstChild("Bomb")
            if bomb then
                local billboard = bomb:FindFirstChildOfClass("BillboardGui")
                local label = billboard and billboard:FindFirstChildOfClass("TextLabel")
                if label then
                    cachedBombLabel = label
                    local num = tonumber(label.Text:match("[%d%.]+"))
                    if num then return num end
                end
            end
        end
    end
    return nil
end

local function isAlive(p) 
    return p and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 and p.Character:FindFirstChild("HumanoidRootPart") 
end

local function isTeammate(p)
    if not p or not p.Character then return false end
    if p.Team ~= nil and p.Team == LocalPlayer.Team then return true end
    local success, isTeam = pcall(function()
        for _, v in pairs(p.Character:GetDescendants()) do 
            if v:IsA("Highlight") and (v.FillColor.G > 0.5 or v.OutlineColor.G > 0.5) then return true end 
        end
        return false
    end)
    if success then return isTeam else return false end
end

-- TARGET VALIDATION FILTER WITH BOMB RULES
local function isValidTarget(p, amIHolder)
    if not p or p == LocalPlayer or not isAlive(p) or isTeammate(p) then 
        return false 
    end
    -- If we carry the bomb, do not lock onto targets that also carry the bomb
    if amIHolder and hasBomb(p) then 
        return false 
    end
    return true
end

-- SAFE CHARACTER TO TOUCH BOUNDARY MODIFIER
local function setCharacterCanTouch(state)
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanTouch = state
            end
        end
    end
end

local function canSeePlayerSticky(p)
    if not p.Character or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
    local char = p.Character; local origin = LocalPlayer.Character.HumanoidRootPart.Position
    local params = RaycastParams.new(); params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local partsToCheck = {"Head", "HumanoidRootPart"}
    for _, partName in ipairs(partsToCheck) do
        local part = char:FindFirstChild(partName)
        if part then
            local direction = part.Position - origin
            local success, r = pcall(function() return Workspace:Raycast(origin, direction, params) end)
            if success and (not r or r.Instance:IsDescendantOf(char)) then return true end
        end
    end
    return false
end

-- WALLHOP DETAILED DETECTION (BOUNDING BOX)
local function checkBoundingBoxDetection(root, char)
    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = {char}
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude
    overlapParams.MaxParts = 5
    
    local size = Vector3_new(4.5, 5.5, 4.5)
    local success, parts = pcall(function()
        return Workspace:GetPartBoundsInBox(root.CFrame, size, overlapParams)
    end)
    if success and parts then
        for _, part in ipairs(parts) do
            if part.CanCollide then
                return true
            end
        end
    end
    return false
end

local function CreateRangeVisual()
    if RangeVisualPart then pcall(function() RangeVisualPart:Destroy() end) end
    RangeVisualPart = Instance.new("Part")
    RangeVisualPart.Name = "LouisHub_RangeVisual"
    RangeVisualPart.Anchored = true
    RangeVisualPart.CanCollide = false
    RangeVisualPart.CastShadow = false
    RangeVisualPart.Material = Enum.Material.ForceField
    RangeVisualPart.Color = Color3.fromRGB(0, 255, 255)
    RangeVisualPart.Shape = Enum.PartType.Cylinder
    RangeVisualPart.Orientation = Vector3_new(0, 0, 90)
    RangeVisualPart.Transparency = 0.6
    RangeVisualPart.Parent = workspace
end

local function ApplyTrip(state)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanTouch = not state 
        end
    end
    
    if state then
        hum.PlatformStand = true 
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        pcall(function()
            hrp.CFrame = hrp.CFrame * CFrame_Angles(math_rad(45), 0, 0)
        end)
    else
        hum.PlatformStand = false
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

task_spawn(function()
    while true do
        task_wait(0.08)
        if _G.TripEnabled and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                pcall(function()
                    hum.PlatformStand = true
                    hum:ChangeState(Enum.HumanoidStateType.Physics)
                end)
            end
        end
    end
end)

local function ApplyHeadless()
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 1
        local face = head:FindFirstChildOfClass("Decal")
        if face then face.Transparency = 1 end
        
        for _, access in ipairs(char:GetChildren()) do
            if access:IsA("Accessory") then
                local handle = access:FindFirstChild("Handle")
                if handle then
                    if handle:FindFirstChildOfClass("SpecialMesh") then
                        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                        if mesh.MeshType == Enum.MeshType.Head or handle.Name:lower():find("head") or access.Name:lower():find("headless") then
                            handle.Transparency = 1
                        end
                    end
                end
            end
        end
    end
end

local function ApplyKorblox()
    local char = LocalPlayer.Character
    if not char then return end
    
    local rUpper = char:FindFirstChild("RightUpperLeg")
    local rLower = char:FindFirstChild("RightLowerLeg")
    local rFoot = char:FindFirstChild("RightFoot")
    
    if rUpper and rLower and rFoot then
        rUpper.Transparency = 1
        rLower.Transparency = 1
        rFoot.Transparency = 1
        
        if char:FindFirstChild("LocalKorbloxLeg") then
            char.LocalKorbloxLeg:Destroy()
        end
        
        local visualModel = Instance.new("Model", char)
        visualModel.Name = "LocalKorbloxLeg"
        
        local stick = Instance.new("Part", visualModel)
        stick.Name = "StickLeg"
        stick.Size = Vector3_new(0.3, 2.4, 0.3)
        stick.Color = Color3.fromRGB(25, 25, 25)
        stick.Material = Enum.Material.Metal
        stick.CanCollide = false
        stick.Massless = true
        
        local weld = Instance.new("WeldConstraint", stick)
        weld.Part0 = stick
        weld.Part1 = rUpper
        stick.CFrame = rUpper.CFrame * CFrame_new(0, -0.6, 0)
        
        local ring = Instance.new("Part", visualModel)
        ring.Name = "GlowRing"
        ring.Size = Vector3_new(0.5, 0.1, 0.5)
        ring.Color = Color3.fromRGB(0, 150, 255)
        ring.Material = Enum.Material.Neon
        ring.CanCollide = false
        ring.Massless = true
        
        local weld2 = Instance.new("WeldConstraint", ring)
        weld2.Part0 = ring
        weld2.Part1 = rLower
        ring.CFrame = rLower.CFrame * CFrame_new(0, -0.5, 0)
    else
        local rLeg = char:FindFirstChild("Right Leg")
        if rLeg then
            rLeg.Transparency = 1
            if char:FindFirstChild("LocalKorbloxLeg") then
                char.LocalKorbloxLeg:Destroy()
            end
            
            local visualModel = Instance.new("Model", char)
            visualModel.Name = "LocalKorbloxLeg"
            
            local stick = Instance.new("Part", visualModel)
            stick.Size = Vector3_new(0.4, 2, 0.4)
            stick.Color = Color3.fromRGB(25, 25, 25)
            stick.Material = Enum.Material.Metal
            stick.CanCollide = false
            stick.Massless = true
            
            local weld = Instance.new("WeldConstraint", stick)
            weld.Part0 = stick
            weld.Part1 = rLeg
            stick.CFrame = rLeg.CFrame
        end
    end
end

-- ========================================================================
-- [[ OPTIMIZED HITBOX & OWN CHARACTER RANGE AREA VISUALIZER ENGINE ]]
-- ========================================================================
cleanHitboxes = function()
    if LocalHitboxPart then
        pcall(function() LocalHitboxPart:Destroy() end)
        LocalHitboxPart = nil
    end
end

local lastHitboxUpdate = 0
updatePlayersHitboxes = function()
    local ourChar = LocalPlayer.Character
    local ourHRP = ourChar and ourChar:FindFirstChild("HumanoidRootPart")
    local amIHolder = hasBomb(LocalPlayer)
    
    if not _G.LocalHitboxEnabled or not ourHRP then
        cleanHitboxes()
    else
        -- 1. INSTANT FRAME-BY-FRAME HITBOX TELEPORT PASS ENGINE
        if amIHolder and not isTweening then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and isAlive(player) and not isTeammate(player) and not hasBomb(player) then
                    local opponentHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    if opponentHRP then
                        local distance = (ourHRP.Position - opponentHRP.Position).Magnitude
                        if distance <= _G.LocalHitboxSize then
                            isTweening = true
                            local startCFrame = ourHRP.CFrame
                            
                            task_spawn(function()
                                local success, err = pcall(function()
                                    ourHRP.CFrame = opponentHRP.CFrame * CFrame_new(0, 0, 0.8)
                                    task_wait(_G.HitboxTeleportDelay)
                                    ourHRP.CFrame = startCFrame
                                    task_wait(0.12)
                                end)
                                isTweening = false
                            end)
                            break
                        end
                    end
                end
            end
        end

        -- 2. HIGHLY VISIBLE NEON GLOWING LOCAL RANGE BOUNDS
        local now = tick()
        if (now - lastHitboxUpdate >= 0.08) then
            lastHitboxUpdate = now
            if _G.HitboxVisualEnabled then
                local shape = _G.HitboxShape or "Cylinder"
                local neededClassName = (shape == "Wedge") and "WedgePart" or "Part"
                
                if not LocalHitboxPart or LocalHitboxPart.ClassName ~= neededClassName or LocalHitboxPart.Parent == nil then
                    if LocalHitboxPart then pcall(function() LocalHitboxPart:Destroy() end) end
                    
                    LocalHitboxPart = Instance.new(neededClassName)
                    LocalHitboxPart.Name = "LocalHitboxVisual"
                    LocalHitboxPart.Anchored = true
                    LocalHitboxPart.CanCollide = false
                    LocalHitboxPart.CastShadow = false
                    LocalHitboxPart.Material = Enum.Material.Neon 
                    LocalHitboxPart.Color = Color3.fromRGB(255, 0, 100) 
                    LocalHitboxPart.Transparency = 0.3 
                    LocalHitboxPart.Parent = workspace
                end
                
                if shape == "Cylinder" then
                    LocalHitboxPart.Shape = Enum.PartType.Cylinder
                    LocalHitboxPart.Size = Vector3_new(0.2, _G.LocalHitboxSize * 2, _G.LocalHitboxSize * 2)
                    LocalHitboxPart.CFrame = CFrame_new(ourHRP.Position - Vector3_new(0, 2.8, 0)) * CFrame_Angles(0, 0, math_rad(90))
                elseif shape == "Sphere" then
                    LocalHitboxPart.Shape = Enum.PartType.Ball
                    LocalHitboxPart.Size = Vector3_new(_G.LocalHitboxSize * 2, _G.LocalHitboxSize * 2, _G.LocalHitboxSize * 2)
                    LocalHitboxPart.CFrame = CFrame_new(ourHRP.Position)
                elseif shape == "Block" then
                    LocalHitboxPart.Shape = Enum.PartType.Block
                    LocalHitboxPart.Size = Vector3_new(_G.LocalHitboxSize * 2, _G.LocalHitboxSize * 2, _G.LocalHitboxSize * 2)
                    LocalHitboxPart.CFrame = CFrame_new(ourHRP.Position)
                elseif shape == "Wedge" then
                    LocalHitboxPart.Size = Vector3_new(0.2, _G.LocalHitboxSize * 2, _G.LocalHitboxSize * 2)
                    LocalHitboxPart.CFrame = CFrame_new(ourHRP.Position - Vector3_new(0, 1.5, 0))
                end
                
                LocalHitboxPart.Visible = true
            else
                cleanHitboxes()
            end
        end
    end
end

local HitboxRenderConnection = RunService.PreSimulation:Connect(function()
    if _G.LocalHitboxEnabled then
        pcall(updatePlayersHitboxes)
    end
end)
table.insert(_G.LouisConnections, HitboxRenderConnection)

-- ========================================================
-- [[ LIGHTWEIGHT PLAYERS ESP ENGINE ]]
-- ========================================================
local highlights = {}
local function updateESP()
    if not _G.ESPEnabled then
        for player, highlight in pairs(highlights) do
            pcall(function() highlight:Destroy() end)
        end
        table.clear(highlights)
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) then
            local char = player.Character
            if char then
                local highlight = highlights[player] or char:FindFirstChild("LouisESP")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "LouisESP"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = char
                    highlights[player] = highlight
                end
                if hasBomb(player) then
                    highlight.FillColor = Color3.fromRGB(255, 0, 0) 
                elseif isTeammate(player) then
                    highlight.FillColor = Color3.fromRGB(0, 255, 0) 
                else
                    highlight.FillColor = Color3.fromRGB(0, 150, 255) 
                end
            end
        end
    end
    
    for player, highlight in pairs(highlights) do
        if not player.Parent or not isAlive(player) then
            pcall(function() highlight:Destroy() end)
            highlights[player] = nil
        end
    end
end

-- Throttled Heartbeat ESP trigger to maintain peak performance
local lastESPUpdate = 0
local ESPConnection = RunService.Heartbeat:Connect(function()
    local now = os.clock()
    if now - lastESPUpdate >= 0.15 then
        lastESPUpdate = now
        pcall(updateESP)
    end
end)
table.insert(_G.LouisConnections, ESPConnection)

-- ========================================================
-- [[ GHOST & PHYSICS DESYNC HELPERS ]]
-- ========================================================
local function getPing()
    local success, result = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if success then return result else return 100 end
end

local function updateDesyncGhost(cframe)
    if not _G.DesyncVisualEnabled then
        if GhostModel then GhostModel:Destroy(); GhostModel = nil end
        return
    end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    if not GhostModel or GhostModel.Parent ~= workspace then
        if GhostModel then GhostModel:Destroy() end
        
        local successClone = pcall(function()
            char.Archivable = true
            GhostModel = char:Clone()
            char.Archivable = false
        end)
        
        if successClone and GhostModel then
            GhostModel.Name = "DesyncGhost"
            for _, v in ipairs(GhostModel:GetDescendants()) do
                if v:IsA("LocalScript") or v:IsA("Script") or v:IsA("Animator") or v:IsA("Humanoid") then
                    v:Destroy()
                elseif v:IsA("BasePart") then
                    v.Anchored = true
                    v.CanCollide = false
                    v.CanTouch = false
                    v.CanQuery = false
                    v.Material = Enum.Material.Neon 
                    v.Color = Color3.fromRGB(0, 255, 255) 
                    v.Transparency = 0.3 
                elseif v:IsA("Decal") then
                    v:Destroy()
                end
            end
        else
            GhostModel = Instance.new("Part")
            GhostModel.Name = "DesyncGhost"
            GhostModel.Size = Vector3_new(2, 5, 2)
            GhostModel.Anchored = true
            GhostModel.CanCollide = false
            GhostModel.CanTouch = false
            GhostModel.CanQuery = false
            GhostModel.Color = Color3.fromRGB(0, 255, 255)
            GhostModel.Material = Enum.Material.Neon
            GhostModel.Transparency = 0.6
        end
        GhostModel.Parent = workspace
    end
    
    if GhostModel:IsA("Part") then
        GhostModel.CFrame = cframe
    else
        local ghostRoot = GhostModel:FindFirstChild("HumanoidRootPart")
        if ghostRoot then
            ghostRoot.CFrame = cframe
            for _, limb in ipairs(GhostModel:GetChildren()) do
                if limb:IsA("BasePart") and limb.Name ~= "HumanoidRootPart" then
                    local realLimb = char:FindFirstChild(limb.Name)
                    if realLimb then
                        limb.CFrame = cframe * (char.HumanoidRootPart.CFrame:ToObjectSpace(realLimb.CFrame))
                    end
                end
            end
        end
    end
end

local DesyncPreConnection = RunService.PreSimulation:Connect(function()
    local char = LocalPlayer.Character
    if char then
        if _G.DesyncImmunityEnabled and _G.DesyncImmunityActive then
            setCharacterCanTouch(false)
        else
            setCharacterCanTouch(true)
        end
    end
end)
table.insert(_G.LouisConnections, DesyncPreConnection)

-- ========================================================
-- [[ MOVEMENT & PASS WORKAROUND DEFINITIONS ]]
-- ========================================================
local function teleportTween(targetPart)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and targetPart then
        isTweening = true
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetPart.CFrame})
        tween:Play()
        tween.Completed:Connect(function()
            isTweening = false
        end)
    end
end

triggerManualPass = function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local rootPos = root.Position
    local bestTarget = nil
    local minDist = math_huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isAlive(p) and not isTeammate(p) and not hasBomb(p) then
            local d = (rootPos - p.Character.HumanoidRootPart.Position).Magnitude
            if d < minDist then
                minDist = d
                bestTarget = p
            end
        end
    end
    if bestTarget then
        teleportTween(bestTarget.Character.HumanoidRootPart)
    else
        Library:CreateNotification("Manual Pass", "No valid player found to pass the bomb!", 2)
    end
end

-- ========================================================
-- [[ INITIATE SHAPE ADAPTABLE EXTERNAL FLOATING KEYPADS ]]
-- ========================================================
local baseShape = "Round"

_G.ExtFollowBtn = Library:CreateExternalButton("AUTO FOLLOW", "Toggle", baseShape, "Follow_Ext", function(state)
    _G.FollowActive = state
end)
_G.ExtFollowBtn.Position = UDim2.new(0.5, -235, 0.8, 0)

_G.ExtFreezeBtn = Library:CreateExternalButton("FREEZE", "Toggle", baseShape, "Freeze_Ext", function(state)
    if state then startFreeze() else stopFreeze() end
end)
_G.ExtFreezeBtn.Position = UDim2.new(0.5, -155, 0.8, 0)

_G.ExtFlickBtn = Library:CreateExternalButton("FLICK", "Toggle", baseShape, "Flick_Ext", function(state)
    _G.FlickActive = state
end)
_G.ExtFlickBtn.Position = UDim2.new(0.5, -75, 0.8, 0)

_G.ExtHoldBtn = Library:CreateExternalButton("HOLD BOMB", "Toggle", baseShape, "Hold_Ext", function(state)
    _G.AutoHoldActive = state
end)
_G.ExtHoldBtn.Position = UDim2.new(0.5, 5, 0.8, 0)

_G.ExtPassBtn = Library:CreateExternalButton("PASS BOMB", "Click", baseShape, "Pass_Ext", function()
    triggerManualPass()
end)
_G.ExtPassBtn.Position = UDim2.new(0.5, 85, 0.8, 0)

_G.ExtAutoWalkBtn = Library:CreateExternalButton("AUTO WALK", "Toggle", baseShape, "AutoWalk_Ext", function(state)
    _G.AutoWalkActive = state
end)
_G.ExtAutoWalkBtn.Position = UDim2.new(0.5, 165, 0.8, 0)

_G.ExtRangeChaseBtn = Library:CreateExternalButton("RANGE CHASE", "Toggle", baseShape, "RangeChase_Ext", function(state)
    _G.RangeChaseEnabled = state
end)
_G.ExtRangeChaseBtn.Position = UDim2.new(0.5, -235, 0.72, 0)

_G.ExtTripBtn = Library:CreateExternalButton("TRIP FALL", "Toggle", baseShape, "Trip_Ext", function(state)
    _G.TripEnabled = state
    ApplyTrip(state)
end)
_G.ExtTripBtn.Position = UDim2.new(0.5, -155, 0.72, 0)

_G.ExtCamlockBtn = Library:CreateExternalButton("CAMLOCK", "Toggle", baseShape, "Camlock_Ext", function(state)
    _G.CamlockActive = state
end)
_G.ExtCamlockBtn.Position = UDim2.new(0.5, 5, 0.72, 0)

_G.ExtDesyncImmunityBtn = Library:CreateExternalButton("DESYNC SHIELD", "Toggle", baseShape, "DesyncShield_Ext", function(state)
    _G.DesyncImmunityActive = state
    setCharacterCanTouch(not state)
end)
_G.ExtDesyncImmunityBtn.Position = UDim2.new(0.5, 85, 0.72, 0)

-- CONSOLIDATED WALLHOP TYPE EXTERNAL BUTTONS
_G.ExtWHNormalBtn = Library:CreateExternalButton("wh_normal", "Toggle", baseShape, "WHNormal_Ext", function() ToggleFeature("Wallhop") end)
_G.ExtWHNormalBtn.Position = UDim2.new(0.5, -75, 0.72, 0)

_G.ExtWHInstantBtn = Library:CreateExternalButton("wh_instant", "Toggle", baseShape, "WHInstant_Ext", function() ToggleFeature("Wallhop") end)
_G.ExtWHInstantBtn.Position = UDim2.new(0.5, -75, 0.72, 0)

_G.ExtWHUltraBtn = Library:CreateExternalButton("wh_ultra", "Toggle", baseShape, "WHUltra_Ext", function() ToggleFeature("Wallhop") end)
_G.ExtWHUltraBtn.Position = UDim2.new(0.5, -75, 0.72, 0)

-- Setup custom paths external buttons
local startX = -235
local startY = 0.64
local count = 0
for _, pathInfo in ipairs(FlingPaths) do
    local currentInfo = pathInfo
    local xOffset = startX + ((count % 6) * 80)
    local yOffset = startY - (math.floor(count / 6) * 0.08)
    
    local btn = Library:CreateExternalButton(currentInfo.display:upper(), "Click", baseShape, currentInfo.id .. "_Ext", function()
        triggerPath(currentInfo)
    end)
    btn.Position = UDim2.new(0.5, xOffset, yOffset, 0)
    SafeSetVisible(btn, false)
    PathButtons[currentInfo.id] = btn
    count = count + 1
end

applyFreeze = function(state)
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.Anchored = state end
    end
end

stopFreeze = function()
    if not isFreezing then return end
    isFreezing = false
    applyFreeze(false)
    SafeSetText(_G.ExtFreezeBtn, "FREEZE")
end

startFreeze = function()
    if isFreezing then return end
    isFreezing = true
    applyFreeze(true)
    SafeSetText(_G.ExtFreezeBtn, "FROZEN")
end

-- ========================================================
-- [[ CUSTOM CROSSHAIR MOUSE BYPASS ]]
-- ========================================================
local TRANSPARENT_ICON = "rbxassetid://0"
SafeConnect(RunService.PostSimulation, function()
    if _G.CrosshairSettings.Enabled and _G.CrosshairSettings.HideDefaultCursor then
        if Mouse.Icon ~= TRANSPARENT_ICON then
            pcall(function() Mouse.Icon = TRANSPARENT_ICON end)
        end
    else
        if Mouse.Icon == TRANSPARENT_ICON then
            pcall(function() Mouse.Icon = "" end)
        end
    end
end)

-- ========================================================
-- [[ MOVEMENT & TBD AUTOMATIONS PHYSICS ENGINE ]]
-- ========================================================
local function performWallhop(visualStyle)
    if not canWallJump or (tick() - lastWallHopTime < 0.18) then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    params.FilterType = Enum.RaycastFilterType.Exclude

    local isNearWall = false
    local dMode = _G.WallhopDetectionMode or "Raycast Only"
    local studEnabled = _G.WallhopStudEnabled

    if studEnabled and (dMode == "Raycast Only" or dMode == "Hybrid") then
        local dir = Vector3_new(0, 0, 0)
        for i = 0, 7 do
            local angle = math_rad(i * 45)
            dir = (root.CFrame * CFrame_Angles(0, angle, 0)).LookVector
            local r = Workspace:Raycast(root.Position, dir * _G.WallHopDist, params)
            if r and r.Instance.CanCollide then
                isNearWall = true
                break
            end
        end
    end

    if not isNearWall and (not studEnabled or dMode == "Bounding Box" or dMode == "Hybrid") then
        isNearWall = checkBoundingBoxDetection(root, char)
    end

    if isNearWall and hum.FloorMaterial == Enum.Material.Air then
        lastWallHopTime = tick()
        canWallJump = false

        local jumpPowerBoost = hum.JumpPower > 0 and hum.JumpPower or 50
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        root.AssemblyLinearVelocity = Vector3_new(root.AssemblyLinearVelocity.X, jumpPowerBoost * 0.95, root.AssemblyLinearVelocity.Z)

        local fMode = _G.WallhopFlickMode or "Default"
        if fMode == "Front-to-Back Flick" then
            local cameraDir = Camera.CFrame.LookVector
            local flatCamDir = Vector3_new(cameraDir.X, 0, cameraDir.Z).Unit
            root.CFrame = CFrame_new(root.Position, root.Position + flatCamDir)
            task_wait(0.01)
            root.CFrame = root.CFrame * CFrame_Angles(0, math_rad(180), 0)
        elseif fMode == "Back-to-Front Flick" then
            local cameraDir = Camera.CFrame.LookVector
            local flatCamDir = Vector3_new(cameraDir.X, 0, cameraDir.Z).Unit
            root.CFrame = CFrame_new(root.Position, root.Position + flatCamDir) * CFrame_Angles(0, math_rad(180), 0)
            task_wait(0.01)
            root.CFrame = CFrame_new(root.Position, root.Position + flatCamDir)
        end

        if visualStyle == "Instant" then
            task_spawn(function()
                pcall(function()
                    local angle = math_rad(15)
                    Camera.CFrame = Camera.CFrame * CFrame_Angles(0, -angle, 0)
                    task_wait(0.01)
                    Camera.CFrame = Camera.CFrame * CFrame_Angles(0, angle * 2, 0)
                    task_wait(0.01)
                    Camera.CFrame = Camera.CFrame * CFrame_Angles(0, -angle, 0)
                end)
            end)
        elseif visualStyle == "Normal" then
            task_spawn(function()
                root.CFrame = root.CFrame * CFrame_Angles(0, math_rad(-30), 0)
                task_wait(0.06)
                root.CFrame = root.CFrame * CFrame_Angles(0, math_rad(30), 0)
            end)
        end

        task_wait(0.18)
        canWallJump = true
    end
end

updateWallhopButtonsSync = function()
    local isEnabled = _G.WallhopEnabled
    local isActive = _G.WallhopActive
    local wType = _G.WallhopType
    
    SafeSetVisible(_G.ExtWHNormalBtn, false)
    SafeSetVisible(_G.ExtWHInstantBtn, false)
    SafeSetVisible(_G.ExtWHUltraBtn, false)
    
    if isEnabled then
        if wType == "Normal" then
            SafeSetVisible(_G.ExtWHNormalBtn, true)
            SafeSetText(_G.ExtWHNormalBtn, isActive and "WH_NORMAL [ON]" or "wh_normal")
        elseif wType == "Instant" then
            SafeSetVisible(_G.ExtWHInstantBtn, true)
            SafeSetText(_G.ExtWHInstantBtn, isActive and "WH_INSTANT [ON]" or "wh_instant")
        elseif wType == "Ultra" then
            SafeSetVisible(_G.ExtWHUltraBtn, true)
            SafeSetText(_G.ExtWHUltraBtn, isActive and "WH_ULTRA [ON]" or "wh_ultra")
        end
    end
end

-- PRIMARY GAMEPLAY CORE LOOP
SafeConnect(RunService.Heartbeat, LPH_NO_VIRTUALIZE(function(dt)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local hum = LocalPlayer.Character.Humanoid
    
    local amIHolder = hasBomb(LocalPlayer)
    
    if hum and hum.FloorMaterial ~= Enum.Material.Air then
        _G.CurrentJumpCount = 0
    end

    if _G.FOVEnabled and Camera.FieldOfView ~= _G.FOVValue then
        Camera.FieldOfView = _G.FOVValue
    end

    if _G.TPWalkEnabled and hum and hum.MoveDirection.Magnitude > 0 then
        local tpSpeed = _G.TPWalkSpeed or 16
        local cf = root.CFrame
        local offset = hum.MoveDirection * (tpSpeed * dt)
        local _, _, _, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
        root.CFrame = CFrame_new(cf.X + offset.X, cf.Y + offset.Y, cf.Z + offset.Z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
    end

    if _G.DesyncVisualEnabled then
        table.insert(CFrameHistory, {Time = tick(), CFrame = root.CFrame})
        while #CFrameHistory > 0 and tick() - CFrameHistory[1].Time > 2 do
            table.remove(CFrameHistory, 1)
        end
        local currentPing = getPing()
        local latencyDelay = math_clamp(currentPing / 1000, 0.03, 1.5)
        local ghostCFrame = root.CFrame
        for i = #CFrameHistory, 1, -1 do
            if tick() - CFrameHistory[i].Time >= latencyDelay then
                ghostCFrame = CFrameHistory[i].CFrame
                break
            end
        end
        updateDesyncGhost(ghostCFrame)
    else
        if GhostModel then GhostModel:Destroy(); GhostModel = nil end
    end

    if _G.RangeChaseEnabled then
        if not RangeVisualPart or RangeVisualPart.Parent == nil then CreateRangeVisual() end
        if RangeVisualPart then
            RangeVisualPart.Size = Vector3_new(0.2, _G.RangeChaseValue * 2, _G.RangeChaseValue * 2)
            RangeVisualPart.CFrame = CFrame_new(root.Position - Vector3_new(0, 2.8, 0)) * CFrame_Angles(0, 0, math_rad(90))
        end
    else
        if RangeVisualPart then pcall(function() RangeVisualPart:Destroy() end); RangeVisualPart = nil end
    end

    if hum.FloorMaterial == Enum.Material.Air and root.Velocity.Magnitude > 100 then 
        root.Velocity = root.Velocity.Unit * 100 
    end
    if amIHolder then bombTimer = bombTimer + dt else bombTimer = 0 end

    if tick() - lastRaycastCheck >= raycastInterval then
        if lockedTarget then isVisibleCached = canSeePlayerSticky(lockedTarget) end
        lastRaycastCheck = tick()
    end

    if not lastHadBomb and amIHolder then
        retreatTimer = 0
        local minDist = math_huge; local bestTarget = nil
        for _, p in ipairs(Players:GetPlayers()) do
            if isValidTarget(p, true) then
                local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < minDist then minDist = d; bestTarget = p end
            end
        end
        if bestTarget then lockedTarget = bestTarget; targetMemory = 2 end 
    end

    if lockedTarget and not isValidTarget(lockedTarget, amIHolder) then lockedTarget = nil end
    if isVisibleCached then targetMemory = 1.2 elseif targetMemory > 0 then targetMemory = targetMemory - dt end

    if tick() - lastTargetSearch >= searchInterval then
        local pList = Players:GetPlayers()
        local minDist = math_huge; local best = nil; local closestDist = math_huge; local closestPlayer = nil
        
        if _G.RangeChaseEnabled then
            for _, p in pairs(pList) do
                if isValidTarget(p, amIHolder) then
                    local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d <= _G.RangeChaseValue and d < minDist then minDist = d; best = p end
                end
            end
            lockedTarget = best
        else
            for _, p in pairs(pList) do
                if isValidTarget(p, amIHolder) then
                    local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < closestDist then closestDist = d; closestPlayer = p end
                    if d < minDist and canSeePlayerSticky(p) then minDist = d; best = p end
                end
            end
            if lockedTarget and isValidTarget(lockedTarget, amIHolder) and (targetMemory > 0 or isVisibleCached) then
                if isVisibleCached then targetMemory = 1.2 end
                if _G.HijackEnabled and closestPlayer and closestPlayer ~= lockedTarget and closestDist <= _G.HijackDistance then
                    lockedTarget = closestPlayer; targetMemory = 1.2
                end
            else
                if _G.HijackEnabled and closestPlayer and closestDist <= _G.HijackDistance then
                    lockedTarget = closestPlayer; targetMemory = 1.2
                elseif best then
                    lockedTarget = best; targetMemory = 1.2
                else
                    lockedTarget = nil
                end
            end
        end
        lastTargetSearch = tick()
    end

    if lastHadBomb and not amIHolder then 
        hum.WalkSpeed = 16
        retreatTimer = _G.HJEnabled and 3.8 or 2.5
        if _G.AutoWalkActive then autoWalkRetreatTimer = 2.5 end
    end

    if _G.AutoPassEnabled and amIHolder and not isTweening then
        local rootPos = root.Position
        local bestTarget = nil; local minDist = math_huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isAlive(p) and not isTeammate(p) and not hasBomb(p) then
                local d = (rootPos - p.Character.HumanoidRootPart.Position).Magnitude
                if d <= _G.PassMaxDistance and d < minDist then minDist = d; bestTarget = p end
            end
        end
        if bestTarget then teleportTween(bestTarget.Character.HumanoidRootPart) end
    end

    if _G.RangeChaseEnabled then
        if lockedTarget and isAlive(lockedTarget) then hum:MoveTo(lockedTarget.Character.HumanoidRootPart.Position) end
    elseif _G.AutoWalkActive then
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
        params.FilterType = Enum.RaycastFilterType.Exclude

        if amIHolder then
            if lockedTarget and isAlive(lockedTarget) then
                local tRoot = lockedTarget.Character.HumanoidRootPart
                local dist = (root.Position - tRoot.Position).Magnitude
                hum.WalkSpeed = (dist <= 12) and 25 or 16
                
                local targetPos = tRoot.Position
                local speed = 25
                local now = tick()
                if now - lastAutoWalkRaycast >= 0.12 or currentMoveDir == nil then
                    lastAutoWalkRaycast = now
                    local moveDir = (targetPos - root.Position).Unit
                    local rayOrigin = root.Position + Vector3_new(0, -1.2, 0)
                    local raycastResult = Workspace:Raycast(rayOrigin, moveDir * 6, params)
                    if raycastResult and raycastResult.Instance.CanCollide then
                        local angles = {30, -30, 60, -60, 90, -90, 120, -120}
                        for _, angle in ipairs(angles) do
                            local worldAltDir = (CFrame_lookAt(root.Position, targetPos) * CFrame_Angles(0, math_rad(angle), 0)).LookVector
                            local altRay = Workspace:Raycast(rayOrigin, worldAltDir * 6, params)
                            if not altRay or not altRay.Instance.CanCollide then moveDir = worldAltDir; break end
                        end
                    end
                    currentMoveDir = moveDir
                end
                
                local nextPos = root.Position + (currentMoveDir * speed * dt)
                local targetY = root.Position.Y
                if hum.FloorMaterial ~= Enum.Material.Air then
                    local groundRay = Workspace:Raycast(nextPos + Vector3_new(0, 5, 0), Vector3_new(0, -12, 0), params)
                    if groundRay then targetY = groundRay.Position.Y + 3.0 end
                else
                    targetY = root.Position.Y + (root.AssemblyLinearVelocity.Y * dt)
                end
                root.CFrame = CFrame_new(Vector3_new(nextPos.X, targetY, nextPos.Z), Vector3_new(targetPos.X, targetY, targetPos.Z))
                hum:Move(Vector3_new(0, 0, 0))
            else
                hum.WalkSpeed = 16
            end
        else
            if _G.FollowTypeMode == "Follow Only" then
                if lockedTarget and isAlive(lockedTarget) then hum:MoveTo(lockedTarget.Character.HumanoidRootPart.Position) else hum:Move(Vector3_new(0,0,0)) end
            else 
                local bombHolder = nil
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and isAlive(p) and hasBomb(p) then bombHolder = p; break end
                end
                if bombHolder then
                    local targetPos = bombHolder.Character.HumanoidRootPart.Position
                    local speed = _G.AutoWalkRetreatSpeed or 22
                    local now = tick()
                    if now - lastAutoWalkRaycast >= 0.12 or currentMoveDir == nil then
                        lastAutoWalkRaycast = now
                        local moveDir = (root.Position - targetPos).Unit
                        local rayOrigin = root.Position + Vector3_new(0, -1.2, 0)
                        local raycastResult = Workspace:Raycast(rayOrigin, moveDir * 6, params)
                        if raycastResult and raycastResult.Instance.CanCollide then
                            local angles = {30, -30, 60, -60, 90, -90, 120, -120}
                            for _, angle in ipairs(angles) do
                                local worldAltDir = (CFrame_lookAt(root.Position, root.Position + moveDir) * CFrame_Angles(0, math_rad(angle), 0)).LookVector
                                local altRay = Workspace:Raycast(rayOrigin, worldAltDir * 6, params)
                                if not altRay or not altRay.Instance.CanCollide then moveDir = worldAltDir; break end
                            end
                        end
                        currentMoveDir = moveDir
                    end
                    local nextPos = root.Position + (currentMoveDir * speed * dt)
                    local targetY = root.Position.Y
                    if hum.FloorMaterial ~= Enum.Material.Air then
                        local groundRay = Workspace:Raycast(nextPos + Vector3_new(0, 5, 0), Vector3_new(0, -12, 0), params)
                        if groundRay then targetY = groundRay.Position.Y + 3.0 end
                    else
                        targetY = root.Position.Y + (root.AssemblyLinearVelocity.Y * dt)
                    end
                    root.CFrame = CFrame_new(Vector3_new(nextPos.X, targetY, nextPos.Z), Vector3_new(targetPos.X, targetY, targetPos.Z))
                    hum:Move(Vector3_new(0, 0, 0))
                else
                    if lockedTarget and isAlive(lockedTarget) then
                        local tRoot = lockedTarget.Character.HumanoidRootPart
                        hum:MoveTo(root.Position + (root.Position - tRoot.Position).Unit * 22)
                    end
                end
            end
        end
    else
        if lockedTarget and isAlive(lockedTarget) then
            local tRoot = lockedTarget.Character.HumanoidRootPart
            local dist = (root.Position - tRoot.Position).Magnitude
            hum.WalkSpeed = (amIHolder and dist <= 12) and 25 or 16
            
            local shouldFollow = (_G.FollowEnabled and _G.FollowActive) or _G.AutoHoldActive
            local targetPos = _G.PredictEnabled and (tRoot.Position + (tRoot.Velocity * 0.13)) or tRoot.Position
            
            if shouldFollow then
                if _G.FollowTypeMode == "Follow Only" then
                    hum:MoveTo(targetPos)
                else 
                    if retreatTimer <= 0 then 
                        hum:MoveTo(targetPos) 
                    else
                        retreatTimer = retreatTimer - dt
                        hum:MoveTo(root.Position + (root.Position - tRoot.Position).Unit * 22)
                    end
                end
            elseif lastShouldFollow then
                hum:Move(Vector3_new(0, 0, 0))
            end
            lastShouldFollow = shouldFollow
        else 
            hum.WalkSpeed = 16 
            if lastShouldFollow then hum:Move(Vector3_new(0, 0, 0)) lastShouldFollow = false end
        end
    end

    if _G.FlickActive and amIHolder and isAlive(lockedTarget) and (root.Position - lockedTarget.Character.HumanoidRootPart.Position).Magnitude <= 4 then
        local flickMode = _G.FlickTargetMode or "Camera Only"
        if flickMode == "Camera Only" or flickMode == "Both" then
            local str = _G.FlickStrength or 45
            Camera.CFrame = Camera.CFrame * CFrame_Angles(math_rad(math_random(-str/2, str/2)), math_rad(math_random(-str, str)), 0)
        end
        if flickMode == "Character Only" or flickMode == "Both" then
            local charStr = _G.CharFlickStrength or 45
            root.CFrame = root.CFrame * CFrame_Angles(0, math_rad(math_random(-charStr, charStr)), 0)
        end
    end

    local needsFacing = false
    local lookDir = nil

    if isAlive(lockedTarget) then
        local targetPos = lockedTarget.Character.HumanoidRootPart.Position
        local flatTargetPos = Vector3_new(targetPos.X, root.Position.Y, targetPos.Z)
        if _G.CamlockEnabled and _G.CamlockActive then
            needsFacing = true
            lookDir = amIHolder and flatTargetPos or (root.Position + (root.Position - flatTargetPos).Unit)
        elseif _G.AutoHoldActive and amIHolder then
            needsFacing = true
            local remaining = getBombTime()
            lookDir = (remaining and remaining <= 1.05) and flatTargetPos or (root.Position + (root.Position - flatTargetPos).Unit)
        end
    end

    if needsFacing and lookDir then
        hum.AutoRotate = false
        root.CFrame = root.CFrame:Lerp(CFrame_new(root.Position, lookDir), 0.3)
    else
        hum.AutoRotate = true
    end

    if canWallJump and (tick() - lastWallHopTime >= 0.18) then
        if _G.WallhopEnabled and _G.WallhopActive and _G.WallhopMode == "Automatic" then
            local visualStyle = _G.WallhopType
            if visualStyle == "Ultra" then visualStyle = (UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter) and "Instant" or "Normal" end
            performWallhop(visualStyle)
        end
    end

    lastHadBomb = amIHolder
end))

SafeConnect(RunService.RenderStepped, function()
    if _G.ResolutionEnabled and _G.ResolutionValue ~= 1.00 then
        Camera.CFrame = Camera.CFrame * CFrame_new(0, 0, 0, 1, 0, 0, 0, _G.ResolutionValue, 0, 0, 0, 1)
    end
end)

local JumpRequestConnection = UserInputService.JumpRequest:Connect(function()
    isSticking = false 
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    if _G.WallhopEnabled and _G.WallhopActive and _G.WallhopMode == "Manual" then
        local visualStyle = _G.WallhopType
        if visualStyle == "Ultra" then visualStyle = (UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter) and "Instant" or "Normal" end
        performWallhop(visualStyle)
    end

    if _G.InfJumpEnabled and not jumpDebounce then
        jumpDebounce = true
        if hum.FloorMaterial == Enum.Material.Air then
            if _G.CurrentJumpCount < _G.MaxJumpCount - 1 then
                _G.CurrentJumpCount = _G.CurrentJumpCount + 1
                root.AssemblyLinearVelocity = Vector3_new(root.AssemblyLinearVelocity.X, hum.JumpPower > 0 and hum.JumpPower or 50, root.AssemblyLinearVelocity.Z)
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        else
            _G.CurrentJumpCount = 0
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        task_spawn(function() task_wait(0.2) jumpDebounce = false end)
    end
end)
table.insert(_G.LouisConnections, JumpRequestConnection)

-- ========================================================
-- [[ MAIN MENU STRUCTURE (SECTIONS IMPLEMENTATION) ]]
-- ========================================================
local Window = Library:CreateWindow("LOUIS TBD PREMIUM", "discord.gg/P2FEVBz2PG")

-- --- TAB 1: WELCOME (LUCIDE ICON: "home") ---
local TabMain = Window:CreateTab("Welcome", "home")
local SectionWelcome = TabMain:CreateSection("Welcome Information")
SectionWelcome:CreateParagraph("Welcome!", "Hello " .. LocalPlayer.Name .. "!\nThank you for executing Louis TBD Premium Edition.")
SectionWelcome:CreateParagraph("UI Instructions", "Keybind to open/hide menu: Insert\nYou can toggle external buttons from settings.")
SectionWelcome:CreateParagraph("Official Community", "Join our Discord server to get the latest update information!")

SectionWelcome:CreateButton("Copy Discord Server Link", function()
    if setclipboard then
        setclipboard("https://discord.gg/P2FEVBz2PG")
        Library:CreateNotification("Discord Link", "Discord link copied successfully to your clipboard!", 2)
    else
        Library:CreateNotification("Error", "Your exploit does not support clipboard copying.", 2.5)
    end
end)

SectionWelcome:CreateButton("Activate Potato Graphics Optimization", function()
    ApplyPotato()
    Library:CreateNotification("Potato Mode", "Graphics optimized successfully!", 3)
end)

-- --- TAB 2: COMBAT (LUCIDE ICON: "swords") ---
local TabCombat = Window:CreateTab("Combat", "swords")

local SecAutoChase = TabCombat:CreateSection("Auto Chase & Walk Controls")
SecAutoChase:CreateToggle("Enable Follow System", false, "FollowEnabled", {}, function(state)
    _G.FollowEnabled = state
    _G.FollowActive = state 
    SafeSetVisible(_G.ExtFollowBtn, state)
end)

SecAutoChase:CreateToggle("Predict Coordinates", false, "PredictEnabled", {}, function(state)
    _G.PredictEnabled = state
end)

SecAutoChase:CreateToggle("Enable Auto Walk System", false, "AutoWalkEnabled", {}, function(state)
    _G.AutoWalkEnabled = state
    _G.AutoWalkActive = state 
    SafeSetVisible(_G.ExtAutoWalkBtn, state)
end)

SecAutoChase:CreateSlider("Auto Walk Retreat Speed", 10, 50, 22, "AutoWalkRetreatSpeed", function(val)
    _G.AutoWalkRetreatSpeed = val
end)

SecAutoChase:CreateDropdown("Follow & Walk Mode", {"Follow + Retreat", "Follow Only"}, "Follow + Retreat", "FollowTypeMode", function(val)
    _G.FollowTypeMode = val
end)

local SecHijack = TabCombat:CreateSection("Target Hijack Controls")
SecHijack:CreateToggle("Enable Target Hijacking", true, "HijackEnabled", {}, function(state)
    _G.HijackEnabled = state
end)

SecHijack:CreateSlider("Hijack Override Distance (Studs)", 1, 100, 7, "HijackDistance", function(val)
    _G.HijackDistance = val
end)

local SecPass = TabCombat:CreateSection("Automatic Bomb Passing")
SecPass:CreateToggle("Enable Auto Pass Bomb", false, "AutoPassEnabled", {}, function(state)
    _G.AutoPassEnabled = state
end)

SecPass:CreateDropdown("Pass Target Mode", {"Without Bomb", "With Bomb"}, "Without Bomb", "PassTargetMode", function(val)
    _G.PassTargetMode = val
end)

SecPass:CreateSlider("Pass Max Distance (Studs)", 1, 200, 100, "PassMaxDistance", function(val)
    _G.PassMaxDistance = val
end)

SecPass:CreateToggle("Show Manual Pass Button [PASS]", false, "PassExternalVisible", {}, function(state)
    SafeSetVisible(_G.ExtPassBtn, state)
end)

SecPass:CreateButton("Manual Trigger Pass Bomb Now", function()
    triggerManualPass()
end)

local SecRange = TabCombat:CreateSection("Range Area Chase System")
SecRange:CreateToggle("Enable Range Area Chase", false, "RangeChaseEnabled", {}, function(state)
    _G.RangeChaseEnabled = state
    SafeSetVisible(_G.ExtRangeChaseBtn, state)
end)

SecRange:CreateSlider("Chase Range (Studs)", 10, 150, 30, "RangeChaseValue", function(val)
    _G.RangeChaseValue = val
end)

local SecFlick = TabCombat:CreateSection("Flick & Hold Controls")
SecFlick:CreateToggle("Enable Flick System", false, "FlickEnabled", {}, function(state)
    _G.FlickEnabled = state
    _G.FlickActive = state 
    SafeSetVisible(_G.ExtFlickBtn, state)
end)

SecFlick:CreateDropdown("Flick Target Mode", {"Camera Only", "Character Only", "Both"}, "Camera Only", "FlickTargetMode", function(val)
    _G.FlickTargetMode = val
end)

SecFlick:CreateSlider("Character Flick Strength", 5, 180, 45, "CharFlickStrength", function(val)
    _G.CharFlickStrength = val
end)

SecFlick:CreateSlider("Camera Flick Strength", 5, 90, 45, "FlickStrength", function(val)
    _G.FlickStrength = val
end)

SecFlick:CreateToggle("Enable Auto Hold Bomb", false, "AutoHoldEnabled", {}, function(state)
    _G.AutoHoldEnabled = state
    _G.AutoHoldActive = state 
    SafeSetVisible(_G.ExtHoldBtn, state)
end)

local SecTPWalk = TabCombat:CreateSection("Teleport Walk & Desync")
SecTPWalk:CreateToggle("Enable TPWalk Speed", false, "TPWalkEnabled", {}, function(state)
    _G.TPWalkEnabled = state
end)

SecTPWalk:CreateSlider("TPWalk Speed Scale", 1, 100, 16, "TPWalkSpeed", function(val)
    _G.TPWalkSpeed = val
end)

SecTPWalk:CreateToggle("Aetherial Desync Shield", false, "DesyncImmunityEnabled", {}, function(state)
    _G.DesyncImmunityEnabled = state
    _G.DesyncImmunityActive = state
    SafeSetVisible(_G.ExtDesyncImmunityBtn, state)
    setCharacterCanTouch(not state)
end)

local SecHitbox = TabCombat:CreateSection("Range Hitbox Expander")
SecHitbox:CreateToggle("Enable Opponents Hitbox Expander", true, "LocalHitboxEnabled", {}, function(state)
    _G.LocalHitboxEnabled = state
    pcall(updatePlayersHitboxes)
end)

SecHitbox:CreateToggle("Show Hitbox Outlines (Visual)", true, "HitboxVisualEnabled", {}, function(state)
    _G.HitboxVisualEnabled = state
    pcall(updatePlayersHitboxes)
end)

SecHitbox:CreateDropdown("Hitbox Range Shape", {"Cylinder", "Sphere", "Block"}, "Cylinder", "HitboxShape", function(val)
    _G.HitboxShape = val
    pcall(updatePlayersHitboxes)
end)

SecHitbox:CreateSlider("Hitbox Range Size (Studs)", 1, 20, 2, "LocalHitboxSize", function(val)
    _G.LocalHitboxSize = val
    pcall(updatePlayersHitboxes)
end)

SecHitbox:CreateSlider("Teleport Hold Duration (ms)", 1, 100, 4, "HitboxTeleportDelay", function(val)
    _G.HitboxTeleportDelay = val / 100
end)

local SecTrip = TabCombat:CreateSection("Movement Utilities")
SecTrip:CreateToggle("Enable Trip Fall", false, "TripEnabled", {}, function(state)
    _G.TripEnabled = state
    ApplyTrip(state)
    SafeSetVisible(_G.ExtTripBtn, state)
end)

SecTrip:CreateToggle("Enable Freeze System", false, "FreezeEnabled", {}, function(state)
    _G.FreezeEnabled = state
    SafeSetVisible(_G.ExtFreezeBtn, state)
    if not state then pcall(stopFreeze) end
end)

SecTrip:CreateToggle("Infinite Jump Toggle", false, "InfJumpEnabled", {}, function(state)
    _G.InfJumpEnabled = state
end)

SecTrip:CreateSlider("Maximum Jump Air-Count", 2, 10, 5, "MaxJumpCount", function(val)
    _G.MaxJumpCount = val
end)

-- --- TAB 3: VISUALS (LUCIDE ICON: "eye") ---
local TabVisuals = Window:CreateTab("Visuals", "eye")

local SecESP = TabVisuals:CreateSection("Player ESP Highlights")
SecESP:CreateToggle("Enable Player ESP", false, "ESPEnabled", {}, function(state)
    _G.ESPEnabled = state
end)

SecESP:CreateToggle("Desync Ghost Visualizer", false, "DesyncVisualEnabled", {}, function(state)
    _G.DesyncVisualEnabled = state
    if not state and GhostModel then GhostModel:Destroy() GhostModel = nil end
end)

local SecCosmetics = TabVisuals:CreateSection("Record Protection & Cosmetics")
SecCosmetics:CreateButton("Randomize Avatar (Client)", function()
    ApplyRandomAvatar()
end)

SecCosmetics:CreateButton("Apply FE Korblox & Headless", function()
    isHeadlessActive = true
    isKorbloxActive = true
    ApplyHeadless()
    ApplyKorblox()
    Library:CreateNotification("Visuals applied", "FE Headless & Korblox successfully loaded locally!", 2)
end)

local SecCamera = TabVisuals:CreateSection("Camera & Resolution Scaling")
SecCamera:CreateToggle("FOV Override Toggle", false, "FOVEnabled", {}, function(state)
    _G.FOVEnabled = state
    if not state then Camera.FieldOfView = 70 end
end)

SecCamera:CreateSlider("Field Of View Value", 1, 200, 70, "FOVValue", function(val)
    _G.FOVValue = val
end)

SecCamera:CreateToggle("Stretch Resolution Toggle", false, "ResolutionEnabled", {}, function(state)
    _G.ResolutionEnabled = state
end)

SecCamera:CreateSlider("Stretch Resolution Scale", 1, 20, 10, "ResolutionValue", function(val)
    _G.ResolutionValue = val / 10
end)

-- --- TAB 4: CUSTOM CROSSHAIRS (LUCIDE ICON: "crosshair") ---
local TabCrosshair = Window:CreateTab("Custom Crosshairs", "crosshair")
local SecCrossControls = TabCrosshair:CreateSection("Crosshair Controls")

SecCrossControls:CreateToggle("Enable Custom Crosshair", false, "CustomCrosshairEnabled", {}, function(state)
    _G.CrosshairSettings.Enabled = state
    if state and not _G.CrosshairLoaded_2 then
        _G.CrosshairLoaded_2 = true
        task_spawn(function()
            local url = "https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/crosshair.lua"
            pcall(function() loadstring(game:HttpGet(url))() end)
        end)
    end
end)

SecCrossControls:CreateToggle("Show Only When Shift Lock is On", false, "CrosshairOnlyShiftLock", {}, function(state)
    _G.CrosshairSettings.OnlyShiftLock = state
end)

SecCrossControls:CreateToggle("Hide Roblox Default Cursor", true, "CrosshairHideDefaultCursor", {}, function(state)
    _G.CrosshairSettings.HideDefaultCursor = state
end)

SecCrossControls:CreateDropdown("Crosshair Style", {"Cross", "T-Shape", "Diamond", "Circle", "Dot", "Image"}, "Cross", "CrosshairStyle", function(selected)
    _G.CrosshairSettings.Style = selected
end)

SecCrossControls:CreateDropdown("Select Preset Image ID", PresetNames, PresetNames[1], "CrosshairPresetImage", function(selectedPreset)
    local cleanId = selectedPreset:match("(%d+)%)") 
    if cleanId then _G.CrosshairSettings.ImageId = cleanId end
end)

SecCrossControls:CreateTextBox("Custom Image ID", "Enter ID manually...", "CrosshairCustomImage", function(text)
    local cleanId = text:gsub("%D", "")
    if cleanId ~= "" then _G.CrosshairSettings.ImageId = cleanId end
end)

SecCrossControls:CreateDropdown("Crosshair Color Preset", {"Green (Neon)", "Red", "Blue", "White", "Yellow", "Cyan", "Pink"}, "Green (Neon)", "CrosshairColorPreset", function(selectedName)
    local targetColor = CrosshairColorPresets[selectedName]
    if targetColor then _G.CrosshairSettings.Color = targetColor end
end)

SecCrossControls:CreateToggle("Rainbow Crosshair Effect", false, "CrosshairRainbow", {}, function(state)
    _G.CrosshairSettings.Rainbow = state
end)

SecCrossControls:CreateSlider("Crosshair Size / Radius", 2, 35, 10, "CrosshairSize", function(val)
    _G.CrosshairSettings.Size = val
end)

SecCrossControls:CreateSlider("Crosshair Gap Size", 0, 25, 5, "CrosshairGap", function(val)
    _G.CrosshairSettings.Gap = val
end)

SecCrossControls:CreateSlider("Crosshair Thickness", 1, 6, 2, "CrosshairThickness", function(val)
    _G.CrosshairSettings.Thickness = val / 1.3
end)

local SecCrossRot = TabCrosshair:CreateSection("Crosshair Rotation")
SecCrossRot:CreateSlider("Manual Rotation Angle", 0, 360, 0, "CrosshairRotation", function(val)
    _G.CrosshairSettings.Rotation = val
end)

SecCrossRot:CreateToggle("Auto-Spin Crosshair", false, "CrosshairAutoSpin", {}, function(state)
    _G.CrosshairSettings.AutoSpin = state
end)

SecCrossRot:CreateSlider("Auto-Spin Speed", 10, 200, 50, "CrosshairSpinSpeed", function(val)
    _G.CrosshairSettings.SpinSpeed = val
end)

-- --- TAB 5: PREMIUM (LUCIDE ICON: "crown" - UNLOCKED FOR VIP) ---
local TabPremium = Window:CreateTab("Premium", "crown", true) -- Set isPremium parameter to true [3]

local SecFlingPaths = TabPremium:CreateSection("Custom Fling Coordinates")
SecFlingPaths:CreateToggle("Enable Custom Paths", false, "CustomPathsEnabled", {}, function(state)
    _G.CustomPathsEnabled = state
    setupPathButtons()
end)

SecFlingPaths:CreateSlider("Fling Speed Multiplier", 1, 100, 50, "FlingSpeedMultiplier", function(val)
    _G.FlingSpeedMultiplier = val / 10
end)

for _, pathInfo in ipairs(FlingPaths) do
    local currentInfo = pathInfo
    SecFlingPaths:CreateButton(currentInfo.display:upper(), function()
        local currentState = ExternalButtonStates[currentInfo.id] or false
        local newState = not currentState
        ExternalButtonStates[currentInfo.id] = newState
        local extBtn = PathButtons[currentInfo.id]
        if extBtn and _G.CustomPathsEnabled then
            SafeSetVisible(extBtn, newState)
        end
    end)
end

local SecWallhop = TabPremium:CreateSection("Camlock & Wallhop Consolidated Panel")
SecWallhop:CreateToggle("Camlock", false, "CamlockEnabled", {}, function(state)
    _G.CamlockEnabled = state
    _G.CamlockActive = state
    SafeSetVisible(_G.ExtCamlockBtn, state)
end)

SecWallhop:CreateToggle("Enable Wallhop System", false, "WallhopEnabled", {}, function(state)
    _G.WallhopEnabled = state
    _G.WallhopActive = state
    updateWallhopButtonsSync()
end)

SecWallhop:CreateToggle("Enable Stud (Raycast) Detection", true, "WallhopStudEnabled", {}, function(state)
    _G.WallhopStudEnabled = state
end)

SecWallhop:CreateDropdown("Wallhop Mode", {"Manual", "Automatic"}, "Manual", "WallhopMode", function(val)
    _G.WallhopMode = val
end)

SecWallhop:CreateDropdown("Wallhop Type", {"Normal", "Instant", "Ultra"}, "Normal", "WallhopType", function(val)
    _G.WallhopType = val
    updateWallhopButtonsSync()
end)

SecWallhop:CreateDropdown("Wallhop Detection Mode", {"Raycast Only", "Bounding Box", "Hybrid"}, "Raycast Only", "WallhopDetectionMode", function(val)
    _G.WallhopDetectionMode = val
end)

SecWallhop:CreateDropdown("Wallhop Action Style", {"Default", "Front-to-Back Flick", "Back-to-Front Flick"}, "Default", "WallhopFlickMode", function(val)
    _G.WallhopFlickMode = val
end)

SecWallhop:CreateSlider("Wallhop Distance Range (Studs)", 1, 15, 2.5, "WH_Distance", function(val)
    _G.WallHopDist = val
end)

local SecBotWalk = TabPremium:CreateSection("Bot Walk & Navigation")
SecBotWalk:CreateButton("Bot Walk System", function()
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/gamerlatahzan-design/SSLH-SourceCode-/main/SourceCodePathFinder.lua"))()
    end)
    if success then
        Library:CreateNotification("Bot Walk System", "Bot Walk System loaded successfully!", 3)
    else
        Library:CreateNotification("Bot Walk System Error", "Failed to load script: " .. tostring(err), 3)
    end
end)

-- --- TAB 6: KEYBIND SETTINGS (LUCIDE ICON: "keyboard") ---
local TabKeybinds = Window:CreateTab("Keybind Settings", "keyboard")
local SecKeybinds = TabKeybinds:CreateSection("Custom Keybind System")

SecKeybinds:CreateKeybind("Follow Toggle Key", Enum.KeyCode.None, "FollowToggleKey", function(key) Keybinds.FollowToggle = key end)
SecKeybinds:CreateKeybind("Auto Walk Toggle Key", Enum.KeyCode.None, "AutoWalkToggleKey", function(key) Keybinds.AutoWalkToggle = key end)
SecKeybinds:CreateKeybind("Auto Pass Toggle Key", Enum.KeyCode.None, "AutoPassToggleKey", function(key) Keybinds.AutoPassToggle = key end)
SecKeybinds:CreateKeybind("Range Chase Toggle Key", Enum.KeyCode.None, "RangeChaseToggleKey", function(key) Keybinds.RangeChaseToggle = key end)
SecKeybinds:CreateKeybind("Flick Toggle Key", Enum.KeyCode.None, "FlickToggleKey", function(key) Keybinds.FlickToggle = key end)
SecKeybinds:CreateKeybind("Auto Hold Toggle Key", Enum.KeyCode.None, "AutoHoldToggleKey", function(key) Keybinds.AutoHoldToggle = key end)
SecKeybinds:CreateKeybind("Trip Fall Toggle Key", Enum.KeyCode.None, "TripToggleKey", function(key) Keybinds.TripToggle = key end)
SecKeybinds:CreateKeybind("Freeze Toggle Key", Enum.KeyCode.None, "FreezeToggleKey", function(key) Keybinds.FreezeToggle = key end)
SecKeybinds:CreateKeybind("Infinite Jump Toggle Key", Enum.KeyCode.None, "InfJumpToggleKey", function(key) Keybinds.InfJumpToggle = key end)
SecKeybinds:CreateKeybind("Wallhop Toggle Key", Enum.KeyCode.None, "WallhopToggleKey", function(key) Keybinds.WallhopToggle = key end)
SecKeybinds:CreateKeybind("Hitbox Expander Toggle Key", Enum.KeyCode.None, "HitboxToggleKey", function(key) Keybinds.HitboxToggle = key end)
SecKeybinds:CreateKeybind("Crosshair Toggle Key", Enum.KeyCode.None, "CrosshairToggleKey", function(key) Keybinds.CrosshairToggle = key end)
SecKeybinds:CreateKeybind("Camlock Toggle Key", Enum.KeyCode.None, "CamlockToggleKey", function(key) Keybinds.CamlockToggle = key end)
SecKeybinds:CreateKeybind("walkspeed Toggle Key", Enum.KeyCode.None, "TPWalkToggleKey", function(key) Keybinds.TPWalkToggle = key end)
SecKeybinds:CreateKeybind("Desync Shield Toggle Key", Enum.KeyCode.None, "DesyncImmunityToggleKey", function(key) Keybinds.DesyncImmunityToggle = key end)

-- Dynamic custom fling keybinds
local SecFlingBinds = TabKeybinds:CreateSection("Custom Fling Keybinds")
for _, pathInfo in ipairs(FlingPaths) do
    SecFlingBinds:CreateKeybind(pathInfo.display .. " Keybind", Enum.KeyCode.None, pathInfo.id .. "Keybind", function(key) Keybinds[pathInfo.id] = key end)
end

-- ========================================================
-- [[ KEYBOARD QUICK SHORTCUTS CONNECTION ]]
-- ========================================================
ToggleFeature = function(name)
    if name == "Follow" then
        _G.FollowEnabled = not _G.FollowEnabled
        _G.FollowActive = _G.FollowEnabled 
        SafeSetVisible(_G.ExtFollowBtn, _G.FollowEnabled)
        Library:CreateNotification("Follow System", "Status: " .. (_G.FollowEnabled and "ON" or "OFF"), 1.5)
    elseif name == "AutoWalk" then
        _G.AutoWalkEnabled = not _G.AutoWalkEnabled
        _G.AutoWalkActive = _G.AutoWalkEnabled 
        SafeSetVisible(_G.ExtAutoWalkBtn, _G.AutoWalkEnabled)
        Library:CreateNotification("Auto Walk", "Status: " .. (_G.AutoWalkEnabled and "ON" or "OFF"), 1.5)
    elseif name == "AutoPass" then
        _G.AutoPassEnabled = not _G.AutoPassEnabled
        Library:CreateNotification("Auto Pass", "Status: " .. (_G.AutoPassEnabled and "ON" or "OFF"), 1.5)
    elseif name == "RangeChase" then
        _G.RangeChaseEnabled = not _G.RangeChaseEnabled
        SafeSetVisible(_G.ExtRangeChaseBtn, _G.RangeChaseEnabled)
        Library:CreateNotification("Range Chase", "Status: " .. (_G.RangeChaseEnabled and "ON" or "OFF"), 1.5)
    elseif name == "Flick" then
        _G.FlickEnabled = not _G.FlickEnabled
        _G.FlickActive = _G.FlickEnabled 
        SafeSetVisible(_G.ExtFlickBtn, _G.FlickEnabled)
        Library:CreateNotification("Flick", "Status: " .. (_G.FlickEnabled and "ON" or "OFF"), 1.5)
    elseif name == "AutoHold" then
        _G.AutoHoldEnabled = not _G.AutoHoldEnabled
        _G.AutoHoldActive = _G.AutoHoldEnabled 
        SafeSetVisible(_G.ExtHoldBtn, _G.AutoHoldEnabled)
        Library:CreateNotification("Auto Hold", "Status: " .. (_G.AutoHoldEnabled and "ON" or "OFF"), 1.5)
    elseif name == "Trip" then
        _G.TripEnabled = not _G.TripEnabled
        ApplyTrip(_G.TripEnabled)
        SafeSetVisible(_G.ExtTripBtn, _G.TripEnabled)
        Library:CreateNotification("Trip Fall", "Status: " .. (_G.TripEnabled and "ON" or "OFF"), 1.5)
    elseif name == "Freeze" then
        _G.FreezeEnabled = not _G.FreezeEnabled
        SafeSetVisible(_G.ExtFreezeBtn, _G.FreezeEnabled)
        if _G.FreezeEnabled then startFreeze() else stopFreeze() end
        Library:CreateNotification("Freeze System", "Status: " .. (_G.FreezeEnabled and "ON" or "OFF"), 1.5)
    elseif name == "InfJump" then
        _G.InfJumpEnabled = not _G.InfJumpEnabled
        Library:CreateNotification("Inf Jump", "Status: " .. (_G.InfJumpEnabled and "ON" or "OFF"), 1.5)
    elseif name == "Wallhop" then
        if _G.WallhopEnabled then
            _G.WallhopActive = not _G.WallhopActive
            updateWallhopButtonsSync()
            Library:CreateNotification("Wallhop Mode", _G.WallhopActive and "Status: ACTIVE (" .. _G.WallhopType .. ")" or "Status: INACTIVE", 1.5)
        else
            Library:CreateNotification("Wallhop Error", "Please enable the Wallhop System in the UI first!", 2.5)
        end
    elseif name == "Hitbox" then
        _G.LocalHitboxEnabled = not _G.LocalHitboxEnabled
        pcall(updatePlayersHitboxes)
        Library:CreateNotification("Hitbox Expander", "Status: " .. (_G.LocalHitboxEnabled and "ON" or "OFF"), 1.5)
    elseif name == "Crosshair" then
        _G.CrosshairSettings.Enabled = not _G.CrosshairSettings.Enabled
        if _G.CrosshairSettings.Enabled and not _G.CrosshairLoaded_2 then
            _G.CrosshairLoaded_2 = true
            task_spawn(function()
                local url = "https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/crosshair.lua"
                pcall(function() loadstring(game:HttpGet(url))() end)
            end)
        end
        Library:CreateNotification("Crosshair", "Status: " .. (_G.CrosshairSettings.Enabled and "ON" or "OFF"), 1.5)
    elseif name == "Camlock" then
        if _G.CamlockEnabled then
            _G.CamlockActive = not _G.CamlockActive
            SafeSetText(_G.ExtCamlockBtn, _G.CamlockActive and "CAMLOCK [ON]" or "CAMLOCK")
            Library:CreateNotification("Camlock Mode", "Status: " .. (_G.CamlockActive and "ON" or "OFF"), 1.5)
        else
            Library:CreateNotification("Camlock Error", "Please enable Camlock System in the UI first!", 2.5)
        end
    elseif name == "TPWalk" then
        _G.TPWalkEnabled = not _G.TPWalkEnabled
        Library:CreateNotification("TPWalk", "Status: " .. (_G.TPWalkEnabled and "ON" or "OFF"), 1.5)
    elseif name == "DesyncImmunity" then
        if _G.DesyncImmunityEnabled then
            _G.DesyncImmunityActive = not _G.DesyncImmunityActive
            setCharacterCanTouch(not _G.DesyncImmunityActive)
            SafeSetText(_G.ExtDesyncImmunityBtn, _G.DesyncImmunityActive and "SHIELD [ON]" or "DESYNC SHIELD")
            Library:CreateNotification("Desync Shield", "Status: " .. (_G.DesyncImmunityActive and "ACTIVE" or "INACTIVE"), 1.5)
        else
            Library:CreateNotification("Desync Shield Error", "Please enable Desync Shield in the UI first!", 2.5)
        end
    end
end

local function HandleKeybindTrigger(keyCode)
    if keyCode == Enum.KeyCode.None or keyCode == Enum.KeyCode.Unknown then return end
    
    if keyCode == Keybinds.FollowToggle then ToggleFeature("Follow") end
    if keyCode == Keybinds.AutoWalkToggle then ToggleFeature("AutoWalk") end
    if keyCode == Keybinds.AutoPassToggle then ToggleFeature("AutoPass") end
    if keyCode == Keybinds.RangeChaseToggle then ToggleFeature("RangeChase") end
    if keyCode == Keybinds.FlickToggle then ToggleFeature("Flick") end
    if keyCode == Keybinds.AutoHoldToggle then ToggleFeature("AutoHold") end
    if keyCode == Keybinds.TripToggle then ToggleFeature("Trip") end
    if keyCode == Keybinds.FreezeToggle then ToggleFeature("Freeze") end
    if keyCode == Keybinds.InfJumpToggle then ToggleFeature("InfJump") end
    if keyCode == Keybinds.WallhopToggle then ToggleFeature("Wallhop") end
    if keyCode == Keybinds.HitboxToggle then ToggleFeature("Hitbox") end
    if keyCode == Keybinds.CrosshairToggle then ToggleFeature("Crosshair") end
    if keyCode == Keybinds.CamlockToggle then ToggleFeature("Camlock") end
    if keyCode == Keybinds.TPWalkToggle then ToggleFeature("TPWalk") end
    if keyCode == Keybinds.DesyncImmunityToggle then ToggleFeature("DesyncImmunity") end
    
    for _, pathInfo in ipairs(FlingPaths) do
        if keyCode == Keybinds[pathInfo.id] then
            triggerPath(pathInfo)
            break
        end
    end
end

SafeConnect(UserInputService.InputBegan, function(input, gameProcessed)
    if gameProcessed then return end
    HandleKeybindTrigger(input.KeyCode)
end)

SafeConnect(LocalPlayer.CharacterAdded, function(char)
    lastHadBomb = false
    retreatTimer = 0
    autoWalkRetreatTimer = 0
    targetMemory = 0
    bombTimer = 0
    isTweening = false
    _G.CurrentJumpCount = 0
    lastShouldFollow = false
    cachedBombLabel = nil
    table.clear(CFrameHistory)
end)

-- Synchronize initial Wallhop states
updateWallhopButtonsSync()
