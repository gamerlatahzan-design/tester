-- ========================================================================
-- [[ LOUIS HUB - TIME BOMB DUELS FUNCTIONAL PREMIUM EDITION (OPTIMIZED) ]]
-- [[ COMPATIBLE WITH NEW UI LIBRARY STANDARD - VERSI PERBAIKAN PENUH ]]
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

-- 1. LOAD NEW UI LIBRARY FROM THE LATEST SOURCE
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/Ui%20Library.lua"))()

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
local BaseUrl = "https://raw.githubusercontent.com/gamerlatahzan-design/CFRAMELUAHUB/refs/heads/main/"

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

local PathButtons = {} 
local ExternalButtonStates = {} 
_G.CustomPathsEnabled = false
_G.FlingSpeedMultiplier = 5.0 

-- DYNAMIC CFRAME PATH PLAYER
local function playPath(pathId, pathData)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, point in ipairs(pathData) do
        if not _G.CustomPathsEnabled or not ExternalButtonStates[pathId] then 
            break 
        end
        
        if not hrp or not hrp.Parent then break end
        if point.cf then
            pcall(function()
                hrp.CFrame = CFrame.new(table.unpack(point.cf))
            end)
        end
        
        local speedMult = _G.FlingSpeedMultiplier or 5.0
        task_wait((point.dt or 0.016) / speedMult) 
    end
end

-- REAL-TIME DOWNLOADER & SCRIPT REPLICATION RUNNER
local function triggerPath(pathInfo)
    local url = BaseUrl .. pathInfo.file

    Library:CreateNotification("Fling Active", "Executing: " .. pathInfo.display:upper(), 1.5)

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
-- [[ DYNAMIC AUTO-SAVE & AUTO-LOAD CONFIGURATION SYSTEM ]]
-- ========================================================
local HttpService = game:GetService("HttpService")
local ConfigFile = "LouisHub_TBD_Premium_Config.json"
local Config = {}

local Defaults = {
    FollowEnabled = false,
    PredictEnabled = false,
    AutoWalkEnabled = false,
    AutoWalkRetreatSpeed = 22,
    FollowTypeMode = "Follow + Retreat",
    AutoPassEnabled = false,
    PassTargetMode = "Without Bomb",
    PassMaxDistance = 100,
    PassExternalVisible = false,
    RangeChaseEnabled = false,
    RangeChaseValue = 30,
    FlickEnabled = false,
    FlickStrength = 45,
    FlickTargetMode = "Camera Only", 
    CharFlickStrength = 45,          
    AutoHoldEnabled = false,
    LocalHitboxEnabled = true,
    HitboxVisualEnabled = true,
    LocalHitboxSize = 2.0,
    HitboxTeleportDelay = 4,
    HitboxShape = "Cylinder",
    TPWalkEnabled = false,
    TPWalkSpeed = 16,
    CamlockEnabled = false,
    CamlockActive = false,
    DesyncImmunityEnabled = false,
    DesyncImmunityActive = false,
    DesyncVisualEnabled = false,
    TripEnabled = false,
    FreezeEnabled = false,
    InfJumpEnabled = false,
    MaxJumpCount = 5,
    WH_Distance = 2.5,
    WallhopEnabled = false,
    WallhopActive = false,
    WallhopMode = "Manual",
    WallhopType = "Normal",
    WallhopDetectionMode = "Raycast Only", 
    WallhopFlickMode = "Default",          
    WallhopStudEnabled = true,             
    FOVEnabled = false,
    FOVValue = 70,
    ResolutionEnabled = false,
    ResolutionValue = 10,
    
    HijackEnabled = true,
    HijackDistance = 7,
    ESPEnabled = false,
    
    Keybind_UIToggle = "Insert", 
    Keybind_FollowToggle = "None",
    Keybind_AutoWalkToggle = "None",
    Keybind_AutoPassToggle = "None",
    Keybind_RangeChaseToggle = "None",
    Keybind_FlickToggle = "None",
    Keybind_AutoHoldToggle = "None",
    Keybind_TripToggle = "None",
    Keybind_FreezeToggle = "None",
    Keybind_InfJumpToggle = "None",
    Keybind_WallhopToggle = "None",
    Keybind_HitboxToggle = "None",
    Keybind_CrosshairToggle = "None",
    Keybind_CamlockToggle = "None",
    Keybind_TPWalkToggle = "None",
    Keybind_DesyncImmunityToggle = "None"
}

local function LoadConfig()
    if isfile and isfile(ConfigFile) then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFile))
        end)
        if success and type(decoded) == "table" then
            Config = decoded
        else
            Config = {}
        end
    else
        Config = {}
    end
    for k, v in pairs(Defaults) do
        if Config[k] == nil then
            Config[k] = v
        end
    end
    for _, pathInfo in ipairs(FlingPaths) do
        local key = "Keybind_" .. pathInfo.id
        if Config[key] == nil then
            Config[key] = "None"
        end
    end
end

local function SaveConfig()
    if writefile then
        pcall(function()
            writefile(ConfigFile, HttpService:JSONEncode(Config))
        end)
    end
end

LoadConfig()

_G.FollowEnabled = Config.FollowEnabled
_G.FollowActive = Config.FollowEnabled 
_G.PredictEnabled = Config.PredictEnabled 
_G.HJEnabled = false 
_G.FlickEnabled = Config.FlickEnabled 
_G.FlickActive = Config.FlickEnabled
_G.FlickStrength = Config.FlickStrength
_G.FlickTargetMode = Config.FlickTargetMode 
_G.CharFlickStrength = Config.CharFlickStrength 
_G.WallHopDist = Config.WH_Distance 
_G.WallhopEnabled = Config.WallhopEnabled
_G.WallhopActive = Config.WallhopActive
_G.WallhopMode = Config.WallhopMode
_G.WallhopType = Config.WallhopType
_G.WallhopDetectionMode = Config.WallhopDetectionMode 
_G.WallhopFlickMode = Config.WallhopFlickMode 
_G.WallhopStudEnabled = Config.WallhopStudEnabled
_G.PotatoEnabled = false

_G.FOVEnabled = Config.FOVEnabled
_G.FOVValue = Config.FOVValue
_G.FreezeEnabled = Config.FreezeEnabled
_G.HijackEnabled = Config.HijackEnabled
_G.HijackDistance = Config.HijackDistance
_G.ESPEnabled = Config.ESPEnabled
_G.InfJumpEnabled = Config.InfJumpEnabled
_G.MaxJumpCount = Config.MaxJumpCount
_G.CurrentJumpCount = 0
_G.AutoHoldEnabled = Config.AutoHoldEnabled
_G.AutoHoldActive = Config.AutoHoldEnabled
_G.ResolutionEnabled = Config.ResolutionEnabled
_G.ResolutionValue = Config.ResolutionValue / 10
_G.UIScaleValue = 100
_G.ExtScaleValue = 100
_G.AutoWalkEnabled = Config.AutoWalkEnabled
_G.AutoWalkActive = Config.AutoWalkEnabled
_G.AutoWalkRetreatSpeed = Config.AutoWalkRetreatSpeed
_G.AutoPassEnabled = Config.AutoPassEnabled
_G.PassTargetMode = Config.PassTargetMode 
_G.PassMaxDistance = Config.PassMaxDistance 
_G.PassExternalVisible = Config.PassExternalVisible 
_G.RangeChaseEnabled = Config.RangeChaseEnabled
_G.RangeChaseValue = Config.RangeChaseValue
_G.TripEnabled = Config.TripEnabled
_G.FollowTypeMode = Config.FollowTypeMode 
_G.LocalHitboxEnabled = Config.LocalHitboxEnabled 
_G.HitboxVisualEnabled = Config.HitboxVisualEnabled 
_G.LocalHitboxSize = Config.LocalHitboxSize
_G.HitboxTeleportDelay = Config.HitboxTeleportDelay / 1000 
_G.HitboxShape = Config.HitboxShape
_G.TPWalkEnabled = Config.TPWalkEnabled
_G.TPWalkSpeed = Config.TPWalkSpeed
_G.CamlockEnabled = Config.CamlockEnabled
_G.CamlockActive = Config.CamlockActive
_G.DesyncImmunityEnabled = Config.DesyncImmunityEnabled
_G.DesyncImmunityActive = Config.DesyncImmunityActive
_G.DesyncVisualEnabled = Config.DesyncVisualEnabled

local CFrameHistory = {}
local GhostModel = nil
local LocalHitboxPart = nil
local isHeadlessActive = false
local isKorbloxActive = false
local RangeVisualPart = nil

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

local lastRaycastCheck = 0
local lastTargetSearch = 0
local raycastInterval = 0.1
local searchInterval = 0.25
local isVisibleCached = false
local lastAutoWalkRaycast = 0
local currentMoveDir = Vector3_new(0, 0, 0)

local isSticking = false
local previewContainers = {} 

-- ========================================================
-- [[ GLOBAL CONNECTION TRACKER & CLEANUP SYSTEM ]]
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

if _G.LouisDrawings then
    for _, drawing in pairs(_G.LouisDrawings) do
        pcall(function() drawing:Remove() end)
    end
end
_G.LouisDrawings = {}

pcall(function()
    local successHui, hui = pcall(function() return gethui and gethui() end)
    local parent = (successHui and hui) or game:GetService("CoreGui")
    
    local oldCross = parent:FindFirstChild("LouisHub_FREE_Crosshair")
    if oldCross then oldCross:Destroy() end
    local oldCrossPrem = parent:FindFirstChild("LouisHub_Premium_Crosshair")
    if oldCrossPrem then oldCrossPrem:Destroy() end
end)

pcall(function()
    local oldVisual = workspace:FindFirstChild("LouisHub_RangeVisual")
    if oldVisual then oldVisual:Destroy() end
end)

pcall(function()
    local successHui, hui = pcall(function() return gethui and gethui() end)
    local parent = (successHui and hui) or game:GetService("CoreGui")
    
    local oldHUD = parent:FindFirstChild("LouisHub_FPS_Ping_HUD")
    if oldHUD then oldHUD:Destroy() end
end)

pcall(function()
    local oldLocalVisual = workspace:FindFirstChild("LocalHitboxVisual")
    if oldLocalVisual then oldLocalVisual:Destroy() end
end)

pcall(function()
    local oldGhost = workspace:FindFirstChild("DesyncGhost")
    if oldGhost then oldGhost:Destroy() end
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p.Character then
        local esp = p.Character:FindFirstChild("LouisESP")
        if esp then pcall(function() esp:Destroy() end) end
    end
end

-- ========================================================
-- [[ GAMEPLAY HELPERS & DETECTIONS ]]
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
        
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if playerGui then
            for _, gui in ipairs(playerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled then
                    for _, obj in ipairs(gui:GetChildren()) do
                        if obj:IsA("TextLabel") and obj.Visible then
                            local num = tonumber(obj.Text:match("[%d%.]+"))
                            if num and num > 0 and num <= 30 then
                                cachedBombLabel = obj
                                return num
                            end
                        end
                    end
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

local function isValidTarget(p, amIHolder)
    if not p or p == LocalPlayer or not isAlive(p) or isTeammate(p) then 
        return false 
    end
    if amIHolder and hasBomb(p) then 
        return false 
    end
    return true
end

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

local function ApplyRandomAvatar()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    local presetIds = {1, 150, 261, 187514, 10000, 1610487}
    local selectedId = presetIds[math.random(1, #presetIds)]
    task_spawn(function()
        local success, desc = pcall(function()
            return Players:GetHumanoidDescriptionFromUserId(selectedId)
        end)
        
        if success and desc then
            local applySuccess, err = pcall(function()
                hum:ApplyDescription(desc)
            end)
            if applySuccess then
                Library:CreateNotification("Avatar Changer", "Random client-side avatar loaded successfully!", 2)
                return
            end
        end
        
        pcall(function()
            local shirts = {"rbxassetid://121925345", "rbxassetid://607785314", "rbxassetid://144076387"}
            local pants = {"rbxassetid://122304648", "rbxassetid://607785731", "rbxassetid://144076760"}
            
            local shirt = char:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", char)
            shirt.ShirtTemplate = shirts[math.random(1, #shirts)]
            
            local pant = char:FindFirstChildOfClass("Pants") or Instance.new("Pants", char)
            pant.PantsTemplate = pants[math.random(1, #pants)]
            
            local head = char:FindFirstChild("Head")
            local face = head and head:FindFirstChildOfClass("Decal")
            if face then
                face.Texture = "rbxassetid://143890332"
            end
        end)
        Library:CreateNotification("Avatar Changer", "Random client-side avatar applied successfully (Fallback Mode).", 2)
    end)
end

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

local lastESPUpdate = 0
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
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = char
                    highlights[player] = highlight
                end
                if hasBomb(player) then
                    highlight.FillColor = Color3.fromRGB(255, 0, 0) 
                elseif isTeammate(player) then
                    highlight.FillColor = Color3.fromRGB(0, 255, 0) -- PERBAIKAN BUG: Mengganti variabel green yang nil menjadi nilai hijau solid (0)
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

local ESPConnection = RunService.Heartbeat:Connect(function()
    pcall(updateESP)
end)
table.insert(_G.LouisConnections, ESPConnection)

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
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanTouch then
                    part.CanTouch = false
                end
            end
        else
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and not part.CanTouch then
                    part.CanTouch = true
                end
            end
        end
    end
end)
table.insert(_G.LouisConnections, DesyncPreConnection)

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

applyFreeze = function(state)
    local char = LocalPlayer.Character
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = state
        end
    end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = state
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

local function performWallhop(visualStyle)
    if not canWallJump or (tick() - lastWallHopTime < 0.18) then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
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
        root.AssemblyLinearVelocity = Vector3_new(root.AssemblyLinearVelocity.X, jumpPowerBoost * 0.95, root.AssemblyLinearVelocity.Z)
        hum:ChangeState(Enum.HumanoidStateType.Jumping)

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
            if isActive then
                SafeSetText(_G.ExtWHNormalBtn, "WH_NORMAL [ON]")
            else
                SafeSetText(_G.ExtWHNormalBtn, "wh_normal")
            end
        elseif wType == "Instant" then
            SafeSetVisible(_G.ExtWHInstantBtn, true)
            if isActive then
                SafeSetText(_G.ExtWHInstantBtn, "WH_INSTANT [ON]")
            else
                SafeSetText(_G.ExtWHInstantBtn, "wh_instant")
            end
        elseif wType == "Ultra" then
            SafeSetVisible(_G.ExtWHUltraBtn, true)
            if isActive then
                SafeSetText(_G.ExtWHUltraBtn, "WH_ULTRA [ON]")
            else
                SafeSetText(_G.ExtWHUltraBtn, "wh_ultra")
            end
        end
    end
end

-- PERBAIKAN BUG: Menulis kembali fungsi penata tombol fling kustom yang sebelumnya hilang [1]
local function setupPathButtons()
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

-- ========================================================================
-- [[ 1. MAIN MENU INITIALIZATION (MUST RUN BEFORE EXTERNAL BUTTONS) ]]
-- ========================================================================
-- PERBAIKAN BUG: Jendela UI utama diinisialisasi terlebih dahulu agar elemen turunan dapat muncul secara otomatis

local Window = Library:CreateWindow("LOUIS TBD PREMIUM EDITION", "discord.gg/P2FEVBz2PG", {
    Mode = "PC",
    Scale = 1.0,
    Font = Enum.Font.GothamMedium,
    BoldFont = Enum.Font.GothamBold
})

Window:CreateCategory("Main Hub")
local TabMain = Window:CreateTab("Welcome", "home", false)
local TabCombat = Window:CreateTab("Combat", "swords", false)
local TabVisuals = Window:CreateTab("Visuals", "eye", false)
local TabCrosshair = Window:CreateTab("Custom Crosshairs", "crosshair", false)

Window:CreateCategory("Premium Features")
local TabPremium = Window:CreateTab("Premium", "crown", true) 

Window:CreateCategory("Configurations")
local TabKeybinds = Window:CreateTab("Keybind Settings", "keyboard", false)
local TabControls = Window:CreateTab("Controls & Scales", "sliders", false)

-- ========================================================
-- [[ 2. SECTIONS & INPUT CONTROL ELEMENTS ]]
-- ========================================================

-- --- TAB 1: WELCOME ---
local SecWelcome = TabMain:CreateSection("Welcome Details")
SecWelcome:CreateParagraph("Welcome!", "Hello " .. LocalPlayer.Name .. "!\nThank you for executing Louis TBD Premium Edition.")
SecWelcome:CreateParagraph("UI Instructions", "Keybind to open/hide menu: Insert Key\nYou can toggle external buttons from settings.")
SecWelcome:CreateParagraph("Official Community", "Join our Discord server to get the latest update information!")

SecWelcome:CreateButton("Copy Discord Server Link", function()
    if setclipboard then
        setclipboard("https://discord.gg/P2FEVBz2PG")
        Library:CreateNotification("Discord Link", "Discord link copied successfully to your clipboard!", 2)
    else
        Library:CreateNotification("Error", "Your exploit does not support clipboard copying.", 2.5)
    end
end)

SecWelcome:CreateButton("Activate Potato Graphics Optimization", function()
    ApplyPotato()
    Library:CreateNotification("Potato Mode", "Graphics optimized successfully!", 3)
end)

-- --- TAB 2: COMBAT ---
local SecCombatChasing = TabCombat:CreateSection("Auto Chase & Walk Controls")

local FollowToggle = SecCombatChasing:CreateToggle("Enable Follow System", Config.FollowEnabled, "FollowEnabled", {}, function(state)
    _G.FollowEnabled = state
    _G.FollowActive = state 
    Config.FollowEnabled = state
    SaveConfig()
    SafeSetVisible(_G.ExtFollowBtn, state)
    if state then
        SafeSetText(_G.ExtFollowBtn, "FOLLOWING")
    else
        SafeSetText(_G.ExtFollowBtn, "AUTO FOLLOW")
    end
end)

SecCombatChasing:CreateToggle("Predict Coordinates", Config.PredictEnabled, "PredictEnabled", {}, function(state)
    _G.PredictEnabled = state
    Config.PredictEnabled = state
    SaveConfig()
end)

SecCombatChasing:CreateToggle("Enable Auto Walk System", Config.AutoWalkEnabled, "AutoWalkEnabled", {}, function(state)
    _G.AutoWalkEnabled = state
    _G.AutoWalkActive = state 
    Config.AutoWalkEnabled = state
    SaveConfig()
    SafeSetVisible(_G.ExtAutoWalkBtn, state)
    if state then
        SafeSetText(_G.ExtAutoWalkBtn, "WALKING")
    else
        SafeSetText(_G.ExtAutoWalkBtn, "AUTO WALK")
    end
end)

SecCombatChasing:CreateSlider("Auto Walk Retreat Speed", 10, 50, Config.AutoWalkRetreatSpeed, "AutoWalkRetreatSpeed", function(val)
    _G.AutoWalkRetreatSpeed = val
    Config.AutoWalkRetreatSpeed = val
    SaveConfig()
end)

SecCombatChasing:CreateDropdown("Follow & Walk Mode", {"Follow + Retreat", "Follow Only"}, Config.FollowTypeMode, "FollowTypeMode", function(val)
    _G.FollowTypeMode = val
    Config.FollowTypeMode = val
    SaveConfig()
end)

local SecCombatHijack = TabCombat:CreateSection("Target Hijack Controls")
SecCombatHijack:CreateToggle("Enable Target Hijacking", Config.HijackEnabled, "HijackEnabled", {}, function(state)
    _G.HijackEnabled = state
    Config.HijackEnabled = state
    SaveConfig()
end)

SecCombatHijack:CreateSlider("Hijack Override Distance (Studs)", 1, 100, Config.HijackDistance, "HijackDistance", function(val)
    _G.HijackDistance = val
    Config.HijackDistance = val
    SaveConfig()
end)

local SecCombatPass = TabCombat:CreateSection("Automatic Bomb Passing")
SecCombatPass:CreateToggle("Enable Auto Pass Bomb", Config.AutoPassEnabled, "AutoPassEnabled", {}, function(state)
    _G.AutoPassEnabled = state
    Config.AutoPassEnabled = state
    SaveConfig()
end)

SecCombatPass:CreateDropdown("Pass Target Mode", {"Without Bomb", "With Bomb"}, Config.PassTargetMode, "PassTargetMode", function(val)
    _G.PassTargetMode = val
    Config.PassTargetMode = val
    SaveConfig()
end)

SecCombatPass:CreateSlider("Pass Max Distance (Studs)", 1, 200, Config.PassMaxDistance, "PassMaxDistance", function(val)
    _G.PassMaxDistance = val
    Config.PassMaxDistance = val
    SaveConfig()
end)

SecCombatPass:CreateToggle("Show Manual Pass Button [PASS]", Config.PassExternalVisible, "PassExternalVisible", {}, function(state)
    _G.PassExternalVisible = state
    Config.PassExternalVisible = state
    SaveConfig()
    SafeSetVisible(_G.ExtPassBtn, state)
end)

SecCombatPass:CreateButton("Manual Trigger Pass Bomb Now", function()
    triggerManualPass()
end)

local SecCombatRangeChase = TabCombat:CreateSection("Range Area Chase System")
SecCombatRangeChase:CreateToggle("Enable Range Area Chase", Config.RangeChaseEnabled, "RangeChaseEnabled", {}, function(state)
    _G.RangeChaseEnabled = state
    Config.RangeChaseEnabled = state
    SaveConfig()
    SafeSetVisible(_G.ExtRangeChaseBtn, state)
    if state then
        SafeSetText(_G.ExtRangeChaseBtn, "CHASING")
    else
        SafeSetText(_G.ExtRangeChaseBtn, "RANGE CHASE")
    end
end)

SecCombatRangeChase:CreateSlider("Chase Range (Studs)", 10, 150, Config.RangeChaseValue, "RangeChaseValue", function(val)
    _G.RangeChaseValue = val
    Config.RangeChaseValue = val
    SaveConfig()
end)

local SecCombatFlick = TabCombat:CreateSection("Flick & Hold Controls")
SecCombatFlick:CreateToggle("Enable Flick System", Config.FlickEnabled, "FlickEnabled", {}, function(state)
    _G.FlickEnabled = state
    _G.FlickActive = state 
    Config.FlickEnabled = state
    SaveConfig()
    SafeSetVisible(_G.ExtFlickBtn, state)
    if state then
        SafeSetText(_G.ExtFlickBtn, "FLICKING")
    else
        SafeSetText(_G.ExtFlickBtn, "FLICK")
    end
end)

SecCombatFlick:CreateDropdown("Flick Target Mode", {"Camera Only", "Character Only", "Both"}, Config.FlickTargetMode, "FlickTargetMode", function(val)
    _G.FlickTargetMode = val
    Config.FlickTargetMode = val
    SaveConfig()
end)

SecCombatFlick:CreateSlider("Character Flick Strength (Degrees)", 5, 180, Config.CharFlickStrength, "CharFlickStrength", function(val)
    _G.CharFlickStrength = val
    Config.CharFlickStrength = val
    SaveConfig()
end)

SecCombatFlick:CreateSlider("Camera Flick Strength (Degrees)", 5, 90, Config.FlickStrength, "FlickStrength", function(val)
    _G.FlickStrength = val
    Config.FlickStrength = val
    SaveConfig()
end)

SecCombatFlick:CreateToggle("Enable Auto Hold Bomb", Config.AutoHoldEnabled, "AutoHoldEnabled", {}, function(state)
    _G.AutoHoldEnabled = state
    _G.AutoHoldActive = state 
    Config.AutoHoldEnabled = state
    SaveConfig()
    SafeSetVisible(_G.ExtHoldBtn, state)
    if state then
        SafeSetText(_G.ExtHoldBtn, "HOLDING")
    else
        SafeSetText(_G.ExtHoldBtn, "HOLD BOMB")
    end
end)

local SecCombatTPW = TabCombat:CreateSection("Teleport Walk (TPWalk)")
SecCombatTPW:CreateToggle("Enable TPWalk Speed", Config.TPWalkEnabled, "TPWalkEnabled", {}, function(state)
    _G.TPWalkEnabled = state
    Config.TPWalkEnabled = state
    SaveConfig()
end)

SecCombatTPW:CreateSlider("TPWalk Speed Scale", 1, 100, Config.TPWalkSpeed, "TPWalkSpeed", function(val)
    _G.TPWalkSpeed = val
    Config.TPWalkSpeed = val
    SaveConfig()
end)

local SecCombatDesync = TabCombat:CreateSection("Replication Desync Utilities")
SecCombatDesync:CreateToggle("Aetherial Desync Shield", Config.DesyncImmunityEnabled, "DesyncImmunityEnabled", {}, function(state)
    _G.DesyncImmunityEnabled = state
    _G.DesyncImmunityActive = state
    Config.DesyncImmunityEnabled = state
    Config.DesyncImmunityActive = state
    SaveConfig()
    SafeSetVisible(_G.ExtDesyncImmunityBtn, state)
    setCharacterCanTouch(not state)
    if state then
        SafeSetText(_G.ExtDesyncImmunityBtn, "SHIELD [ON]")
    else
        SafeSetText(_G.ExtDesyncImmunityBtn, "DESYNC SHIELD")
    end
end)

local SecCombatHitbox = TabCombat:CreateSection("Range Hitbox Expander (Local Area Bounds)")
SecCombatHitbox:CreateToggle("Enable Opponents Hitbox Expander", Config.LocalHitboxEnabled, "LocalHitboxEnabled", {}, function(state)
    _G.LocalHitboxEnabled = state
    Config.LocalHitboxEnabled = state
    SaveConfig()
    pcall(updatePlayersHitboxes)
end)

SecCombatHitbox:CreateToggle("Show Hitbox Outlines (Visual)", Config.HitboxVisualEnabled, "HitboxVisualEnabled", {}, function(state)
    _G.HitboxVisualEnabled = state
    Config.HitboxVisualEnabled = state
    SaveConfig()
    pcall(updatePlayersHitboxes)
end)

SecCombatHitbox:CreateDropdown("Hitbox Range Shape", {"Cylinder", "Sphere", "Block", "Wedge"}, Config.HitboxShape, "HitboxShape", function(val)
    _G.HitboxShape = val
    Config.HitboxShape = val
    SaveConfig()
    pcall(updatePlayersHitboxes)
end)

SecCombatHitbox:CreateSlider("Hitbox Range Size (Studs)", 1, 20, Config.LocalHitboxSize, "LocalHitboxSize", function(val)
    _G.LocalHitboxSize = val
    Config.LocalHitboxSize = val
    SaveConfig()
    pcall(updatePlayersHitboxes)
end)

SecCombatHitbox:CreateSlider("Teleport Hold Duration (ms)", 1, 100, Config.HitboxTeleportDelay, "HitboxTeleportDelay", function(val)
    _G.HitboxTeleportDelay = val / 1000
    Config.HitboxTeleportDelay = val
    SaveConfig()
    task_defer(function()
        updateSliderLabelSafe(val)
    end)
end)

local SecCombatTrip = TabCombat:CreateSection("Trip Fall Physics")
SecCombatTrip:CreateToggle("Enable Trip Fall", Config.TripEnabled, "TripEnabled", {}, function(state)
    _G.TripEnabled = state
    Config.TripEnabled = state
    SaveConfig()
    ApplyTrip(_G.TripEnabled)
    SafeSetVisible(_G.ExtTripBtn, state)
    if state then
        SafeSetText(_G.ExtTripBtn, "TRIPPED")
    else
        SafeSetText(_G.ExtTripBtn, "TRIP FALL")
    end
end)

local SecCombatFreeze = TabCombat:CreateSection("Freeze System")
SecCombatFreeze:CreateToggle("Enable Freeze System", Config.FreezeEnabled, "FreezeEnabled", {}, function(state)
    _G.FreezeEnabled = state
    Config.FreezeEnabled = state
    SaveConfig()
    SafeSetVisible(_G.ExtFreezeBtn, state)
    if not state then
        pcall(function()
            if isFreezing then
                stopFreeze()
            end
        end)
    end
end)

local SecCombatJump = TabCombat:CreateSection("Infinite Jump")
SecCombatJump:CreateToggle("Infinite Jump Toggle", Config.InfJumpEnabled, "InfJumpEnabled", {}, function(state)
    _G.InfJumpEnabled = state
    Config.InfJumpEnabled = state
    SaveConfig()
end)

SecCombatJump:CreateSlider("Maximum Jump Air-Count", 2, 10, Config.MaxJumpCount, "MaxJumpCount", function(val)
    _G.MaxJumpCount = val
    Config.MaxJumpCount = val
    SaveConfig()
end)

-- --- TAB 3: VISUALS ---
local SecVisualsESP = TabVisuals:CreateSection("Player ESP Highlights")
SecVisualsESP:CreateToggle("Enable Player ESP", Config.ESPEnabled, "ESPEnabled", {}, function(state)
    _G.ESPEnabled = state
    Config.ESPEnabled = state
    SaveConfig()
end)

local SecVisualsNet = TabVisuals:CreateSection("Network Latency Visualizer")
SecVisualsNet:CreateToggle("Desync Ghost Visualizer", Config.DesyncVisualEnabled, "DesyncVisualEnabled", {}, function(state)
    _G.DesyncVisualEnabled = state
    Config.DesyncVisualEnabled = state
    SaveConfig()
    if not state then
        if GhostModel then GhostModel:Destroy(); GhostModel = nil end
    end
end)

local SecVisualsCos = TabVisuals:CreateSection("Record Protection & Cosmetics (Local)")
SecVisualsCos:CreateButton("Randomize Avatar (Client)", function()
    ApplyRandomAvatar()
end)

SecVisualsCos:CreateButton("Apply FE Korblox & Headless", function()
    isHeadlessActive = true
    isKorbloxActive = true
    ApplyHeadless()
    ApplyKorblox()
    Library:CreateNotification("Visuals applied", "FE Headless & Korblox successfully loaded locally!", 2)
end)

local SecVisualsScale = TabVisuals:CreateSection("Camera & Resolution Scaling")
SecVisualsScale:CreateToggle("FOV Override Toggle", Config.FOVEnabled, "FOVEnabled", {}, function(state)
    _G.FOVEnabled = state
    Config.FOVEnabled = state
    SaveConfig()
    if not state then
        Camera.FieldOfView = 70
    end
end)

SecVisualsScale:CreateSlider("Field Of View Value", 1, 200, Config.FOVValue, "FOVValue", function(val)
    _G.FOVValue = val
    Config.FOVValue = val
    SaveConfig()
end)

SecVisualsScale:CreateToggle("Stretch Resolution Toggle", Config.ResolutionEnabled, "ResolutionEnabled", {}, function(state)
    _G.ResolutionEnabled = state
    Config.ResolutionEnabled = state
    SaveConfig()
end)

SecVisualsScale:CreateSlider("Stretch Resolution Scale", 1, 20, Config.ResolutionValue, "ResolutionValue", function(val)
    _G.ResolutionValue = val / 10
    Config.ResolutionValue = val
    SaveConfig()
end)

-- --- TAB 4: CUSTOM CROSSHAIRS ---
local SecCrosshairMain = TabCrosshair:CreateSection("Crosshair Main")

SecCrosshairMain:CreateToggle("Enable Custom Crosshair", false, "CustomCrosshairEnabled", {}, function(state)
    _G.CrosshairSettings.Enabled = state
    if state and not _G.CrosshairLoaded_2 then
        _G.CrosshairLoaded_2 = true
        task_spawn(function()
            local url = "https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/crosshair.lua"
            local success, err = pcall(function()
                loadstring(game:HttpGet(url))()
            end)
            if not success then
                _G.CrosshairLoaded_2 = false
                Library:CreateNotification("Crosshair Error", "Failed to download crosshair module.", 3)
            end
        end)
    end
end)

SecCrosshairMain:CreateToggle("Show Only When Shift Lock is On", false, "CrosshairOnlyShiftLock", {}, function(state)
    _G.CrosshairSettings.OnlyShiftLock = state
end)

SecCrosshairMain:CreateToggle("Hide Roblox Default Cursor", true, "CrosshairHideDefaultCursor", {}, function(state)
    _G.CrosshairSettings.HideDefaultCursor = state
end)

SecCrosshairMain:CreateDropdown("Crosshair Style", {"Cross", "T-Shape", "Diamond", "Circle", "Dot", "Image"}, "Cross", "CrosshairStyle", function(selected)
    _G.CrosshairSettings.Style = selected
end)

SecCrosshairMain:CreateDropdown("Select Preset Image ID", PresetNames, PresetNames[1], "CrosshairPresetImage", function(selectedPreset)
    local cleanId = selectedPreset:match("(%d+)%)") 
    if cleanId then
        _G.CrosshairSettings.ImageId = cleanId
    end
end)

SecCrosshairMain:CreateTextBox("Custom Image ID", "Enter Image Asset ID manually...", "CrosshairCustomImage", function(text)
    local cleanId = text:gsub("%D", "")
    if cleanId ~= "" then
        _G.CrosshairSettings.ImageId = cleanId
        Library:CreateNotification("Crosshair ID", "ID updated manually to: " .. cleanId, 1.5)
    end
end)

SecCrosshairMain:CreateDropdown("Crosshair Color Preset", {"Green (Neon)", "Red", "Blue", "White", "Yellow", "Cyan", "Pink"}, "Green (Neon)", "CrosshairColorPreset", function(selectedName)
    local targetColor = CrosshairColorPresets[selectedName]
    if targetColor then
        _G.CrosshairSettings.Color = targetColor
    end
end)

SecCrosshairMain:CreateToggle("Rainbow Crosshair Effect", false, "CrosshairRainbow", {}, function(state)
    _G.CrosshairSettings.Rainbow = state
end)

SecCrosshairMain:CreateSlider("Crosshair Size / Radius", 2, 35, 10, "CrosshairSize", function(val)
    _G.CrosshairSettings.Size = val
end)

SecCrosshairMain:CreateSlider("Crosshair Gap Size", 0, 25, 5, "CrosshairGap", function(val)
    _G.CrosshairSettings.Gap = val
end)

SecCrosshairMain:CreateSlider("Crosshair Thickness", 1, 6, 2, "CrosshairThickness", function(val)
    _G.CrosshairSettings.Thickness = val / 1.3
end)

local SecCrosshairRot = TabCrosshair:CreateSection("Crosshair Rotation Controls")
SecCrosshairRot:CreateParagraph("Information", "Adjust manual rotation angle or enable Auto-Spin mode.")

SecCrosshairRot:CreateSlider("Manual Rotation Angle", 0, 360, 0, "CrosshairRotation", function(val)
    _G.CrosshairSettings.Rotation = val
end)

SecCrosshairRot:CreateToggle("Auto-Spin Crosshair", false, "CrosshairAutoSpin", {}, function(state)
    _G.CrosshairSettings.AutoSpin = state
end)

SecCrosshairRot:CreateSlider("Auto-Spin Speed", 10, 200, 50, "CrosshairSpinSpeed", function(val)
    _G.CrosshairSettings.SpinSpeed = val
end)

-- --- TAB 5: PREMIUM (LOCKED) ---
local SecPremPaths = TabPremium:CreateSection("Custom Fling Coordinates")
SecPremPaths:CreateParagraph("Information", "Configure custom coordinate flings. Clicking a button below toggles its external button.")

SecPremPaths:CreateToggle("Enable Custom Paths", false, "CustomPathsEnabled", {}, function(state)
    _G.CustomPathsEnabled = state
    setupPathButtons()
    Library:CreateNotification("Custom Paths", "Custom paths feature: " .. (state and "ENABLED" or "DISABLED"), 2)
end)

SecPremPaths:CreateSlider("Fling Speed Multiplier", 1, 100, 50, "FlingSpeedMultiplier", function(val)
    _G.FlingSpeedMultiplier = val / 10
end)

local SecPremPanel = TabPremium:CreateSection("Fling Activation Panel")
SecPremPanel:CreateParagraph("Information", "Show/hide fling buttons on your screen.")

for _, pathInfo in ipairs(FlingPaths) do
    local currentInfo = pathInfo
    SecPremPanel:CreateButton(currentInfo.display:upper(), function()
        local currentState = ExternalButtonStates[currentInfo.id] or false
        local newState = not currentState
        ExternalButtonStates[currentInfo.id] = newState
        
        local extBtn = PathButtons[currentInfo.id]
        if extBtn then
            if _G.CustomPathsEnabled then
                SafeSetVisible(extBtn, newState)
            end
        end
        
        if newState then
            if _G.CustomPathsEnabled then
                Library:CreateNotification("Custom Paths", currentInfo.display .. " button is now VISIBLE.", 1.5)
            else
                Library:CreateNotification("Custom Paths", currentInfo.display .. " button enabled, but turn on 'Enable Custom Paths' first.", 2.5)
            end
        else
            Library:CreateNotification("Custom Paths", currentInfo.display .. " button is now HIDDEN.", 1.5)
        end
    end)
end

local SecPremCam = TabPremium:CreateSection("Camlock Targeting Alignment")
SecPremCam:CreateToggle("Camlock", Config.CamlockEnabled, "CamlockEnabled", {}, function(state)
    _G.CamlockEnabled = state
    _G.CamlockActive = state
    Config.CamlockEnabled = state
    Config.CamlockActive = state
    SaveConfig()
    SafeSetVisible(_G.ExtCamlockBtn, state)
    if state then
        SafeSetText(_G.ExtCamlockBtn, "CAMLOCK [ON]")
    else
        SafeSetText(_G.ExtCamlockBtn, "CAMLOCK")
    end
end)

local SecPremWH = TabPremium:CreateSection("Wallhop Consolidated Panel")

local WallhopMainToggle = SecPremWH:CreateToggle("Enable Wallhop System", Config.WallhopEnabled, "WallhopEnabled", {}, function(state)
    _G.WallhopEnabled = state
    _G.WallhopActive = state
    Config.WallhopEnabled = state
    Config.WallhopActive = state
    SaveConfig()
    updateWallhopButtonsSync()
    Library:CreateNotification("Wallhop System", "Wallhop Master Toggle: " .. (state and "ENABLED" or "DISABLED"), 2.0)
end)

SecPremWH:CreateToggle("Enable Stud (Raycast) Detection", Config.WallhopStudEnabled, "WallhopStudEnabled", {}, function(state)
    _G.WallhopStudEnabled = state
    Config.WallhopStudEnabled = state
    SaveConfig()
    Library:CreateNotification("Wallhop Detection", "Stud Detection: " .. (state and "ENABLED" or "DISABLED"), 2.0)
end)

local WallhopModeDropdown = SecPremWH:CreateDropdown("Wallhop Mode", {"Manual", "Automatic"}, Config.WallhopMode, "WallhopMode", function(val)
    _G.WallhopMode = val
    Config.WallhopMode = val
    SaveConfig()
    Library:CreateNotification("Wallhop System", "Wallhop Mode: " .. val, 2.0)
end)

local WallhopTypeDropdown = SecPremWH:CreateDropdown("Wallhop Type", {"Normal", "Instant", "Ultra"}, Config.WallhopType, "WallhopType", function(val)
    _G.WallhopType = val
    Config.WallhopType = val
    SaveConfig()
    updateWallhopButtonsSync()
    Library:CreateNotification("Wallhop System", "Wallhop Type: " .. val, 2.0)
end)

SecPremWH:CreateDropdown("Wallhop Detection Mode", {"Raycast Only", "Bounding Box", "Hybrid"}, Config.WallhopDetectionMode, "WallhopDetectionMode", function(val)
    _G.WallhopDetectionMode = val
    Config.WallhopDetectionMode = val
    SaveConfig()
    Library:CreateNotification("Wallhop Detection", "Mode: " .. val, 2.0)
end)

SecPremWH:CreateDropdown("Wallhop Action Style", {"Default", "Front-to-Back Flick", "Back-to-Front Flick"}, Config.WallhopFlickMode, "WallhopFlickMode", function(val)
    _G.WallhopFlickMode = val
    Config.WallhopFlickMode = val
    SaveConfig()
    Library:CreateNotification("Wallhop Action", "Style: " .. val, 2.0)
end)

SecPremWH:CreateSlider("Wallhop Distance Range (Studs)", 1, 15, Config.WH_Distance, "WH_Distance", function(val)
    _G.WallHopDist = val
    Config.WH_Distance = val
    SaveConfig()
end)

SecPremWH:CreateParagraph("Wallhop Guidelines", "Normal: character-based rotation.\nInstant: CFrame-based camera tilt/flick.\nUltra: combines both based on Shift-Lock.")

SecPremWH:CreateButton("Bot Walk System", function()
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/gamerlatahzan-design/SSLH-SourceCode-/main/SourceCodePathFinder.lua"))()
    end)
    if success then
        Library:CreateNotification("Bot Walk System", "Bot Walk System loaded successfully!", 3)
    else
        Library:CreateNotification("Bot Walk System Error", "Failed to load script: " .. tostring(err), 3)
    end
end)

-- --- TAB 6: KEYBIND SETTINGS ---
local SecKeybinds = TabKeybinds:CreateSection("Custom Keybind System")
SecKeybinds:CreateParagraph("Information", "Click Keybind box and press physical key to bind. Set to None to clear.")

local function RegisterKeybindUI(section, label, configKey, defaultVal)
    local savedVal = Config["Keybind_" .. configKey] or defaultVal
    local parsedCode = (savedVal == "None" and Enum.KeyCode.None) or (typeof(savedVal) == "string" and GetKeyCode(savedVal)) or savedVal
    
    section:CreateKeybind(label, parsedCode, configKey .. "Keybind", function(keyCode)
        Keybinds[configKey] = keyCode
        Config["Keybind_" .. configKey] = keyCode.Name
        SaveConfig()
        Library:CreateNotification("Keybind", label .. " set to: " .. keyCode.Name, 2)
    end)
end

local keybindsList = {
    {"Follow Toggle Key", "FollowToggle", "None"},
    {"Auto Walk Toggle Key", "AutoWalkToggle", "None"},
    {"Auto Pass Toggle Key", "AutoPassToggle", "None"},
    {"Range Chase Toggle Key", "RangeChaseToggle", "None"},
    {"Flick Toggle Key", "FlickToggle", "None"},
    {"Auto Hold Toggle Key", "AutoHoldToggle", "None"},
    {"Trip Fall Toggle Key", "TripToggle", "None"},
    {"Freeze Toggle Key", "FreezeToggle", "None"},
    {"Infinite Jump Toggle Key", "InfJumpToggle", "None"},
    {"Wallhop Toggle Key", "WallhopToggle", "None"},
    {"Hitbox Expander Toggle Key", "HitboxToggle", "None"},
    {"Crosshair Toggle Key", "CrosshairToggle", "None"},
    {"Camlock Toggle Key", "CamlockToggle", "None"},
    {"walkspeed Toggle Key", "TPWalkToggle", "None"},
    {"Desync Shield Toggle Key", "DesyncImmunityToggle", "None"}
}

for _, k in ipairs(keybindsList) do
    RegisterKeybindUI(SecKeybinds, k[1], k[2], k[3])
end

local SecKeybindsFling = TabKeybinds:CreateSection("Custom Fling Keybinds")
SecKeybindsFling:CreateParagraph("Information", "Assign hotkeys to execute your custom coordinate paths directly [1].")

for _, pathInfo in ipairs(FlingPaths) do
    RegisterKeybindUI(SecKeybindsFling, pathInfo.display .. " Keybind", pathInfo.id, "None")
end

-- --- TAB 7: BUTTON CONTROLS ---
local SecControlsScale = TabControls:CreateSection("External Button Scales (%)")
SecControlsScale:CreateParagraph("Information", "Adjust the scale of each floating button dynamically.")

SecControlsScale:CreateSlider("External Buttons Size", 10, 200, 100, "ExtScaleValue", function(val)
    _G.ExtScaleValue = val
    UpdateAllButtonsSize(val / 100)
end)

local SecControlsWindow = TabControls:CreateSection("Window Settings")
SecControlsWindow:CreateToggle("Lock Main UI Dragging", Config.BuiltIn_LockDrag or false, "BuiltIn_LockDrag", {}, function(state)
    Library.Settings.DragLocked = state
    UpdateAllButtonsDragLock(state)
end)

-- ========================================================================
-- [[ 3. ADAPTER & INSTANSIASI TOMBOL MELAYANG EKSTERNAL ]]
-- ========================================================================
-- Berjalan mulus setelah kontainer "Nexus_Compkiller_UI" dan "Library.Settings" aktif

local function CreateExternalButtonAdapter(flag, text, callback, buttonType)
    -- Safe indexing preventer agar tidak crash jika Settings kosong
    local shape = (Library.Settings and Library.Settings.ExternalShape) or "Round"
    local typeVal = buttonType or "Click"
    
    local extFrame = Library:CreateExternalButton(text, typeVal, shape, flag, callback)
    
    local controller = {}
    controller.Instance = extFrame
    
    function controller:SetVisible(state)
        if extFrame then extFrame.Visible = state end
    end
    
    function controller:SetText(val)
        if extFrame then
            local btn = extFrame:FindFirstChildOfClass("TextButton")
            if btn then btn.Text = tostring(val) end
        end
    end
    
    function controller:SetDragLock(locked) end
    function controller:SetSize(scaleValue)
        if extFrame then extFrame.Size = UDim2.new(0, 0, 0, 30) end
    end
    
    return controller
end

_G.ExtFollowBtn = CreateExternalButtonAdapter("ExtFollow", "AUTO FOLLOW", function()
    if not _G.FollowEnabled then return end
    _G.FollowActive = not _G.FollowActive
    if _G.FollowActive then
        SafeSetText(_G.ExtFollowBtn, "FOLLOWING")
    else
        SafeSetText(_G.ExtFollowBtn, "AUTO FOLLOW")
    end
end, "Toggle")
RegisterExternalButton(_G.ExtFollowBtn)

_G.ExtFreezeBtn = CreateExternalButtonAdapter("ExtFreeze", "FREEZE", function()
    if isFreezing then stopFreeze() else startFreeze() end
end, "Toggle")
RegisterExternalButton(_G.ExtFreezeBtn)

_G.ExtFlickBtn = CreateExternalButtonAdapter("ExtFlick", "FLICK", function()
    _G.FlickActive = not _G.FlickActive
    if _G.FlickActive then
        SafeSetText(_G.ExtFlickBtn, "FLICKING")
    else
        SafeSetText(_G.ExtFlickBtn, "FLICK")
    end
end, "Toggle")
RegisterExternalButton(_G.ExtFlickBtn)

_G.ExtHoldBtn = CreateExternalButtonAdapter("ExtHold", "HOLD BOMB", function()
    _G.AutoHoldActive = not _G.AutoHoldActive
    if _G.AutoHoldActive then
        SafeSetText(_G.ExtHoldBtn, "HOLDING")
    else
        SafeSetText(_G.ExtHoldBtn, "HOLD BOMB")
    end
end, "Toggle")
RegisterExternalButton(_G.ExtHoldBtn)

_G.ExtPassBtn = CreateExternalButtonAdapter("ExtPass", "PASS BOMB", function()
    triggerManualPass()
end, "Click")
RegisterExternalButton(_G.ExtPassBtn)

_G.ExtAutoWalkBtn = CreateExternalButtonAdapter("ExtAutoWalk", "AUTO WALK", function()
    _G.AutoWalkActive = not _G.AutoWalkActive
    if _G.AutoWalkActive then
        SafeSetText(_G.ExtAutoWalkBtn, "WALKING")
    else
        SafeSetText(_G.ExtAutoWalkBtn, "AUTO WALK")
    end
end, "Toggle")
RegisterExternalButton(_G.ExtAutoWalkBtn)

_G.ExtRangeChaseBtn = CreateExternalButtonAdapter("ExtRangeChase", "RANGE CHASE", function()
    _G.RangeChaseEnabled = not _G.RangeChaseEnabled
    if _G.RangeChaseEnabled then
        SafeSetText(_G.ExtRangeChaseBtn, "CHASING")
    else
        SafeSetText(_G.ExtRangeChaseBtn, "RANGE CHASE")
    end
end, "Toggle")
RegisterExternalButton(_G.ExtRangeChaseBtn)

_G.ExtTripBtn = CreateExternalButtonAdapter("ExtTripFall", "TRIP FALL", function()
    _G.TripEnabled = not _G.TripEnabled
    ApplyTrip(_G.TripEnabled)
    if _G.TripEnabled then
        SafeSetText(_G.ExtTripBtn, "TRIPPED")
    else
        SafeSetText(_G.ExtTripBtn, "TRIP FALL")
    end
end, "Toggle")
RegisterExternalButton(_G.ExtTripBtn)

_G.ExtCamlockBtn = CreateExternalButtonAdapter("ExtCamlock", "CAMLOCK", function()
    if not _G.CamlockEnabled then return end
    _G.CamlockActive = not _G.CamlockActive
    if _G.CamlockActive then
        SafeSetText(_G.ExtCamlockBtn, "CAMLOCK [ON]")
    else
        SafeSetText(_G.ExtCamlockBtn, "CAMLOCK")
    end
end, "Toggle")
RegisterExternalButton(_G.ExtCamlockBtn)

_G.ExtDesyncImmunityBtn = CreateExternalButtonAdapter("ExtDesyncShield", "DESYNC SHIELD", function()
    if not _G.DesyncImmunityEnabled then return end
    _G.DesyncImmunityActive = not _G.DesyncImmunityActive
    setCharacterCanTouch(not _G.DesyncImmunityActive)
    if _G.DesyncImmunityActive then
        SafeSetText(_G.ExtDesyncImmunityBtn, "SHIELD [ON]")
    else
        SafeSetText(_G.ExtDesyncImmunityBtn, "DESYNC SHIELD")
    end
end, "Toggle")
RegisterExternalButton(_G.ExtDesyncImmunityBtn)

_G.ExtWHNormalBtn = CreateExternalButtonAdapter("ExtWHNormal", "wh_normal", function()
    ToggleFeature("Wallhop")
end, "Toggle")
RegisterExternalButton(_G.ExtWHNormalBtn)

_G.ExtWHInstantBtn = CreateExternalButtonAdapter("ExtWHInstant", "wh_instant", function()
    ToggleFeature("Wallhop")
end, "Toggle")
RegisterExternalButton(_G.ExtWHInstantBtn)

_G.ExtWHUltraBtn = CreateExternalButtonAdapter("ExtWHUltra", "wh_ultra", function()
    ToggleFeature("Wallhop")
end, "Toggle")
RegisterExternalButton(_G.ExtWHUltraBtn)

-- ========================================================
-- [[ DYNAMIC CUSTOM FLING PATH BUTTON GENERATION ]]
-- ========================================================
for _, pathInfo in ipairs(FlingPaths) do
    local currentInfo = pathInfo
    local btn = CreateExternalButtonAdapter("ExtPath_" .. currentInfo.id, currentInfo.display:upper(), function()
        triggerPath(currentInfo)
    end, "Click")
    
    RegisterExternalButton(btn)
    PathButtons[currentInfo.id] = btn
    SafeSetVisible(btn, false) -- PERBAIKAN BUG: Mengatur status awal semua tombol fling kustom agar tersembunyi demi estetika layar
end

-- ========================================================
-- [[ MOVEMENT, PHYSICS, & CORE INPUT AUTOMATIONS ]]
-- ========================================================
SafeConnect(RunService.Heartbeat, LPH_NO_VIRTUALIZE(function(dt)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local hum = LocalPlayer.Character.Humanoid
    
    local amIHolder = hasBomb(LocalPlayer)
    local fovEnabled = _G.FOVEnabled
    local fovValue = _G.FOVValue
    local rangeChaseEnabled = _G.RangeChaseEnabled
    local rangeChaseValue = _G.RangeChaseValue
    local autoWalkActive = _G.AutoWalkActive
    local followTypeMode = _G.FollowTypeMode
    local autoPassEnabled = _G.AutoPassEnabled
    local passTargetMode = _G.PassTargetMode
    local passMaxDistance = _G.PassMaxDistance
    local followEnabled = _G.FollowEnabled
    local followActive = _G.FollowActive 
    local predictEnabled = _G.PredictEnabled
    local autoHoldActive = _G.AutoHoldActive
    local flickActive = _G.FlickActive
    local wallhopEnabled = _G.WallhopEnabled
    local wallhopActive = _G.WallhopActive
    local wallhopMode = _G.WallhopMode
    local wallhopType = _G.WallhopType
    local flickStrength = _G.FlickStrength
    local autoWalkRetreatSpeed = _G.AutoWalkRetreatSpeed
    local hijackEnabled = _G.HijackEnabled
    local hijackDistance = _G.HijackDistance
    
    if hum and hum.FloorMaterial ~= Enum.Material.Air then
        _G.CurrentJumpCount = 0
    end

    if fovEnabled and Camera.FieldOfView ~= fovValue then
        Camera.FieldOfView = fovValue
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

    if _G.DesyncImmunityEnabled and _G.DesyncImmunityActive then
        setCharacterCanTouch(false)
    end

    if rangeChaseEnabled then
        if not RangeVisualPart or RangeVisualPart.Parent == nil then
            CreateRangeVisual()
        end
        if RangeVisualPart then
            RangeVisualPart.Size = Vector3_new(0.2, rangeChaseValue * 2, rangeChaseValue * 2)
            local groundPosition = root.Position - Vector3_new(0, 2.8, 0)
            RangeVisualPart.CFrame = CFrame_new(groundPosition) * CFrame_Angles(0, 0, math_rad(90))
        end
    else
        if RangeVisualPart then
            pcall(function() RangeVisualPart:Destroy() end)
            RangeVisualPart = nil
        end
    end

    if hum.FloorMaterial == Enum.Material.Air and root.Velocity.Magnitude > 100 then 
        root.Velocity = root.Velocity.Unit * 100 
    end
    if amIHolder then bombTimer = bombTimer + dt else bombTimer = 0 end

    isSticking = false

    if tick() - lastRaycastCheck >= raycastInterval then
        if lockedTarget then isVisibleCached = canSeePlayerSticky(lockedTarget) end
        lastRaycastCheck = tick()
    end

    if not lastHadBomb and amIHolder then
        retreatTimer = 0
        local minDist = math_huge
        local bestTarget = nil
        for _, p in ipairs(Players:GetPlayers()) do
            if isValidTarget(p, true) then
                local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < minDist then 
                    minDist = d
                    bestTarget = p 
                end
            end
        end
        if bestTarget then 
            lockedTarget = bestTarget
            targetMemory = 2 
        end 
    end

    if lockedTarget and not isValidTarget(lockedTarget, amIHolder) then 
        lockedTarget = nil 
    end
    
    if isVisibleCached then 
        targetMemory = 1.2 
    elseif targetMemory > 0 then 
        targetMemory = targetMemory - dt 
    end

    if tick() - lastTargetSearch >= searchInterval then
        local pList = Players:GetPlayers()
        local minDist = math_huge; local best = nil; local closestDist = math_huge; local closestPlayer = nil
        
        if rangeChaseEnabled then
            for _, p in pairs(pList) do
                if isValidTarget(p, amIHolder) then
                    local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d <= rangeChaseValue and d < minDist then
                        minDist = d
                        best = p
                    end
                end
            end
            lockedTarget = best
        else
            for _, p in pairs(pList) do
                if isValidTarget(p, amIHolder) then
                    local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < closestDist then 
                        closestDist = d
                        closestPlayer = p 
                    end
                    
                    if d < minDist then
                        if canSeePlayerSticky(p) then 
                            minDist = d
                            best = p 
                        end
                    end
                end
            end
            
            if lockedTarget and isValidTarget(lockedTarget, amIHolder) and (targetMemory > 0 or isVisibleCached) then
                if isVisibleCached then
                    targetMemory = 1.2
                end
                
                if hijackEnabled and closestPlayer and closestPlayer ~= lockedTarget then
                    if closestDist <= hijackDistance then
                        lockedTarget = closestPlayer
                        targetMemory = 1.2
                    end
                end
            else
                if hijackEnabled and closestPlayer and closestDist <= hijackDistance then
                    lockedTarget = closestPlayer
                    targetMemory = 1.2
                elseif best then
                    lockedTarget = best
                    targetMemory = 1.2
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
        if _G.HJEnabled then task_spawn(function() hum:ChangeState(3); task_wait(0.4); hum:ChangeState(3) end) end
        if autoWalkActive then
            autoWalkRetreatTimer = 2.5
        end
    end

    if autoPassEnabled and amIHolder and not isTweening then
        local rootPos = root.Position
        local bestTarget = nil
        local minDist = math_huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isAlive(p) and not isTeammate(p) and not hasBomb(p) then
                local d = (rootPos - p.Character.HumanoidRootPart.Position).Magnitude
                if d <= passMaxDistance and d < minDist then
                    minDist = d
                    bestTarget = p
                end
            end
        end
        if bestTarget then
            teleportTween(bestTarget.Character.HumanoidRootPart)
        end
    end

    if rangeChaseEnabled then
        if lockedTarget and isAlive(lockedTarget) then
            local tRoot = lockedTarget.Character.HumanoidRootPart
            local targetPos = tRoot.Position
            hum:MoveTo(targetPos)
        end
    elseif autoWalkActive then
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
        params.FilterType = Enum.RaycastFilterType.Exclude

        if amIHolder then
            if lockedTarget and isAlive(lockedTarget) then
                local tRoot = lockedTarget.Character.HumanoidRootPart; local dist = (root.Position - tRoot.Position).Magnitude
                if dist <= 12 then hum.WalkSpeed = 25 else hum.WalkSpeed = 16 end
                
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
                            if not altRay or not altRay.Instance.CanCollide then
                                moveDir = worldAltDir
                                break
                            end
                        end
                    end
                    currentMoveDir = moveDir
                end
                
                local nextPos = root.Position + (currentMoveDir * speed * dt)
                local targetY = root.Position.Y
                
                if hum.FloorMaterial ~= Enum.Material.Air then
                    local groundRay = Workspace:Raycast(nextPos + Vector3_new(0, 5, 0), Vector3_new(0, -12, 0), params)
                    if groundRay then
                        targetY = groundRay.Position.Y + 3.0
                    end
                else
                    targetY = root.Position.Y + (root.AssemblyLinearVelocity.Y * dt)
                end
                
                root.CFrame = CFrame_new(Vector3_new(nextPos.X, targetY, nextPos.Z), Vector3_new(targetPos.X, targetY, targetPos.Z))
                hum:Move(Vector3_new(0, 0, 0))
            else
                hum.WalkSpeed = 16
            end
        else
            if followTypeMode == "Follow Only" then
                if lockedTarget and isAlive(lockedTarget) then
                    local tRoot = lockedTarget.Character.HumanoidRootPart
                    hum:MoveTo(tRoot.Position)
                else
                    hum:Move(Vector3_new(0, 0, 0))
                end
            else 
                local bombHolder = nil
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and isAlive(p) and hasBomb(p) then
                        bombHolder = p
                        break
                    end
                end
                
                if bombHolder then
                    local targetPos = bombHolder.Character.HumanoidRootPart.Position
                    local speed = autoWalkRetreatSpeed or 22
                    
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
                                if not altRay or not altRay.Instance.CanCollide then
                                    moveDir = worldAltDir
                                    break
                                end
                            end
                        end
                        currentMoveDir = moveDir
                    end
                    
                    local nextPos = root.Position + (currentMoveDir * speed * dt)
                    local targetY = root.Position.Y
                    
                    if hum.FloorMaterial ~= Enum.Material.Air then
                        local groundRay = Workspace:Raycast(nextPos + Vector3_new(0, 5, 0), Vector3_new(0, -12, 0), params)
                        if groundRay then
                            targetY = groundRay.Position.Y + 3.0
                        end
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
            local tRoot = lockedTarget.Character.HumanoidRootPart; local dist = (root.Position - tRoot.Position).Magnitude
            if amIHolder and dist <= 12 then hum.WalkSpeed = 25 else hum.WalkSpeed = 16 end
            
            local shouldFollow = (followEnabled and followActive) or autoHoldActive
            local targetPos = predictEnabled and (tRoot.Position + (tRoot.Velocity * 0.13)) or tRoot.Position
            
            if shouldFollow then
                if followTypeMode == "Follow Only" then
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
            if lastShouldFollow then
                hum:Move(Vector3_new(0, 0, 0))
                lastShouldFollow = false
            end
        end
    end

    if flickActive and amIHolder and isAlive(lockedTarget) and (root.Position - lockedTarget.Character.HumanoidRootPart.Position).Magnitude <= 4 then
        local flickMode = _G.FlickTargetMode or "Camera Only"
        
        if flickMode == "Camera Only" or flickMode == "Both" then
            local str = flickStrength or 45
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
            if amIHolder then
                lookDir = flatTargetPos
            else
                lookDir = root.Position + (root.Position - flatTargetPos).Unit
            end
        elseif autoHoldActive and amIHolder then
            needsFacing = true
            local remaining = getBombTime()
            if remaining and remaining <= 1.05 then
                lookDir = flatTargetPos
            else
                lookDir = root.Position + (root.Position - flatTargetPos).Unit
            end
        end
    end

    if needsFacing and lookDir then
        hum.AutoRotate = false
        root.CFrame = root.CFrame:Lerp(CFrame_new(root.Position, lookDir), 0.3)
    else
        hum.AutoRotate = true
    end

    if canWallJump and (tick() - lastWallHopTime >= 0.18) then
        if wallhopEnabled and wallhopActive and wallhopMode == "Automatic" then
            local visualStyle = wallhopType
            if visualStyle == "Ultra" then
                if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
                    visualStyle = "Instant"
                else
                    visualStyle = "Normal"
                end
            end
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
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local r_top = char:FindFirstChild("HumanoidRootPart")
    if not hum or not r_top then return end

    if _G.WallhopEnabled and _G.WallhopActive and _G.WallhopMode == "Manual" then
        local visualStyle = _G.WallhopType
        if visualStyle == "Ultra" then
            if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
                visualStyle = "Instant"
            else
                visualStyle = "Normal"
            end
        end
        performWallhop(visualStyle)
    end

    if _G.InfJumpEnabled and not jumpDebounce then
        jumpDebounce = true
        if hum.FloorMaterial == Enum.Material.Air then
            if _G.CurrentJumpCount < _G.MaxJumpCount - 1 then
                _G.CurrentJumpCount = _G.CurrentJumpCount + 1
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        else
            _G.CurrentJumpCount = 0
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        task_spawn(function()
            task_wait(0.2)
            jumpDebounce = false
        end)
    end
end)
table.insert(_G.LouisConnections, JumpRequestConnection)

ToggleFeature = function(name)
    if name == "Follow" then
        _G.FollowEnabled = not _G.FollowEnabled
        _G.FollowActive = _G.FollowEnabled 
        Config.FollowEnabled = _G.FollowEnabled
        SaveConfig()
        if FollowToggle and FollowToggle.Set then
            FollowToggle:Set(_G.FollowEnabled)
        end
        SafeSetVisible(_G.ExtFollowBtn, _G.FollowEnabled)
        if _G.FollowEnabled then
            SafeSetText(_G.ExtFollowBtn, "FOLLOWING")
        else
            SafeSetText(_G.ExtFollowBtn, "AUTO FOLLOW")
        end
        Library:CreateNotification("Follow System", "Status: " .. (_G.FollowEnabled and "ON" or "OFF"), 1.5)
    elseif name == "AutoWalk" then
        _G.AutoWalkEnabled = not _G.AutoWalkEnabled
        _G.AutoWalkActive = _G.AutoWalkEnabled 
        Config.AutoWalkEnabled = _G.AutoWalkEnabled
        SaveConfig()
        SafeSetVisible(_G.ExtAutoWalkBtn, _G.AutoWalkEnabled)
        if _G.AutoWalkEnabled then
            SafeSetText(_G.ExtAutoWalkBtn, "WALKING")
        else
            SafeSetText(_G.ExtAutoWalkBtn, "AUTO WALK")
        end
        Library:CreateNotification("Auto Walk", "Status: " .. (_G.AutoWalkEnabled and "ON" or "OFF"), 1.5)
    elseif name == "AutoPass" then
        _G.AutoPassEnabled = not _G.AutoPassEnabled
        Config.AutoPassEnabled = _G.AutoPassEnabled
        SaveConfig()
        Library:CreateNotification("Auto Pass", "Status: " .. (_G.AutoPassEnabled and "ON" or "OFF"), 1.5)
    elseif name == "RangeChase" then
        _G.RangeChaseEnabled = not _G.RangeChaseEnabled
        Config.RangeChaseEnabled = _G.RangeChaseEnabled
        SaveConfig()
        SafeSetVisible(_G.ExtRangeChaseBtn, _G.RangeChaseEnabled)
        if _G.RangeChaseEnabled then
            SafeSetText(_G.ExtRangeChaseBtn, "CHASING")
        else
            SafeSetText(_G.ExtRangeChaseBtn, "RANGE CHASE")
        end
        Library:CreateNotification("Range Chase", "Status: " .. (_G.RangeChaseEnabled and "ON" or "OFF"), 1.5)
    elseif name == "Flick" then
        _G.FlickEnabled = not _G.FlickEnabled
        _G.FlickActive = _G.FlickEnabled 
        Config.FlickEnabled = _G.FlickEnabled
        SaveConfig()
        SafeSetVisible(_G.ExtFlickBtn, _G.FlickEnabled)
        if _G.FlickEnabled then
            SafeSetText(_G.ExtFlickBtn, "FLICKING")
        else
            SafeSetText(_G.ExtFlickBtn, "FLICK")
        end
        Library:CreateNotification("Flick", "Status: " .. (_G.FlickEnabled and "ON" or "OFF"), 1.5)
    elseif name == "AutoHold" then
        _G.AutoHoldEnabled = not _G.AutoHoldEnabled
        _G.AutoHoldActive = _G.AutoHoldEnabled 
        Config.AutoHoldEnabled = _G.AutoHoldEnabled
        SaveConfig()
        SafeSetVisible(_G.ExtHoldBtn, _G.AutoHoldEnabled)
        if _G.AutoHoldEnabled then
            SafeSetText(_G.ExtHoldBtn, "HOLDING")
        else
            SafeSetText(_G.ExtHoldBtn, "HOLD BOMB")
        end
        Library:CreateNotification("Auto Hold", "Status: " .. (_G.AutoHoldEnabled and "ON" or "OFF"), 1.5)
    elseif name == "Trip" then
        _G.TripEnabled = not _G.TripEnabled
        Config.TripEnabled = _G.TripEnabled
        SaveConfig()
        ApplyTrip(_G.TripEnabled)
        SafeSetVisible(_G.ExtTripBtn, _G.TripEnabled)
        if _G.TripEnabled then
            SafeSetText(_G.ExtTripBtn, "TRIPPED")
        else
            SafeSetText(_G.ExtTripBtn, "TRIP FALL")
        end
        Library:CreateNotification("Trip Fall", "Status: " .. (_G.TripEnabled and "ON" or "OFF"), 1.5)
    elseif name == "Freeze" then
        _G.FreezeEnabled = not _G.FreezeEnabled
        Config.FreezeEnabled = _G.FreezeEnabled
        SaveConfig()
        SafeSetVisible(_G.ExtFreezeBtn, _G.FreezeEnabled)
        if _G.FreezeEnabled then
            startFreeze()
        else
            stopFreeze()
        end
        Library:CreateNotification("Freeze System", "Status: " .. (_G.FreezeEnabled and "ON" or "OFF"), 1.5)
    elseif name == "InfJump" then
        _G.InfJumpEnabled = not _G.InfJumpEnabled
        Config.InfJumpEnabled = _G.InfJumpEnabled
        SaveConfig()
        Library:CreateNotification("Inf Jump", "Status: " .. (_G.InfJumpEnabled and "ON" or "OFF"), 1.5)
    elseif name == "Wallhop" then
        if _G.WallhopEnabled then
            _G.WallhopActive = not _G.WallhopActive
            Config.WallhopActive = _G.WallhopActive
            SaveConfig()
            updateWallhopButtonsSync()
            
            if _G.WallhopActive then
                Library:CreateNotification("Wallhop Mode", "Status: ACTIVE (" .. _G.WallhopType .. ")", 1.5)
            else
                Library:CreateNotification("Wallhop Mode", "Status: INACTIVE", 1.5)
            end
        else
            Library:CreateNotification("Wallhop Error", "Please enable the Wallhop System in the UI first!", 2.5)
        end
    elseif name == "Hitbox" then
        _G.LocalHitboxEnabled = not _G.LocalHitboxEnabled
        Config.LocalHitboxEnabled = _G.LocalHitboxEnabled
        SaveConfig()
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
            Config.CamlockActive = _G.CamlockActive
            SaveConfig()
            if _G.CamlockActive then
                SafeSetText(_G.ExtCamlockBtn, "CAMLOCK [ON]")
            else
                SafeSetText(_G.ExtCamlockBtn, "CAMLOCK")
            end
            Library:CreateNotification("Camlock Mode", "Status: " .. (_G.CamlockActive and "ON" or "OFF"), 1.5)
        else
            Library:CreateNotification("Camlock Error", "Please enable Camlock System in the UI first!", 2.5)
        end
    elseif name == "TPWalk" then
        _G.TPWalkEnabled = not _G.TPWalkEnabled
        Config.TPWalkEnabled = _G.TPWalkEnabled
        SaveConfig()
        Library:CreateNotification("TPWalk", "Status: " .. (_G.TPWalkEnabled and "ON" or "OFF"), 1.5)
    elseif name == "DesyncImmunity" then
        if _G.DesyncImmunityEnabled then
            _G.DesyncImmunityActive = not _G.DesyncImmunityActive
            Config.DesyncImmunityActive = _G.DesyncImmunityActive
            SaveConfig()
            setCharacterCanTouch(not _G.DesyncImmunityActive)
            if _G.DesyncImmunityActive then
                SafeSetText(_G.ExtDesyncImmunityBtn, "SHIELD [ON]")
            else
                SafeSetText(_G.ExtDesyncImmunityBtn, "DESYNC SHIELD")
            end
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

-- ========================================================================
-- [[ DYNAMIC VISIBILITY STARTUP SYNCHRONIZATION ]]
-- ========================================================================
SafeSetVisible(_G.ExtFollowBtn, _G.FollowEnabled)
SafeSetVisible(_G.ExtFreezeBtn, _G.FreezeEnabled)
SafeSetVisible(_G.ExtFlickBtn, _G.FlickEnabled)
SafeSetVisible(_G.ExtHoldBtn, _G.AutoHoldEnabled)
SafeSetVisible(_G.ExtPassBtn, _G.PassExternalVisible)
SafeSetVisible(_G.ExtAutoWalkBtn, _G.AutoWalkEnabled)
SafeSetVisible(_G.ExtRangeChaseBtn, _G.RangeChaseEnabled)
SafeSetVisible(_G.ExtTripBtn, _G.TripEnabled)
SafeSetVisible(_G.ExtCamlockBtn, _G.CamlockEnabled)
SafeSetVisible(_G.ExtDesyncImmunityBtn, _G.DesyncImmunityEnabled)

updateWallhopButtonsSync()
setupPathButtons() -- PERBAIKAN BUG: Menjalankan sinkronisasi awal status Custom Path pada saat startup

if _G.LocalHitboxEnabled then
    pcall(updatePlayersHitboxes)
end

Library:CreateNotification("LOUIS HUB PREMIUM EDITION INSTANTIATED", "UI Standard Terbaru executed successfully. Press Insert to minimize.", 5)
