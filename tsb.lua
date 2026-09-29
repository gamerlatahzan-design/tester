-- ========================================================
--  LOUIS HUB - THE STRONGEST BATTLEGROUNDS (TSB)
--  Framework: WindUI Engine | 100% Full English
--  Complete Master Suite: Combat, Mobility, Visuals & Misc
-- ========================================================

local cloneref = (cloneref or clonereference or function(instance)
    return instance
end)

-- ========================================================
-- SERVICES & CORE REFERENCES
-- ========================================================
local Players           = cloneref(game:GetService("Players"))
local RunService        = cloneref(game:GetService("RunService"))
local UserInputService  = cloneref(game:GetService("UserInputService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local TweenService      = cloneref(game:GetService("TweenService"))
local TeleportService   = cloneref(game:GetService("TeleportService"))
local Lighting          = cloneref(game:GetService("Lighting"))
local CollectionService = cloneref(game:GetService("CollectionService"))
local StarterGui        = cloneref(game:GetService("StarterGui"))
local VirtualInput      = cloneref(game:GetService("VirtualInputManager"))

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
    Camera = workspace.CurrentCamera
end)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
end)

-- ========================================================
-- DATABASE REGISTRY: ANIMATIONS & ROLES
-- ========================================================
local MoveAnimLookup = {
    [10468665991] = "Normal Punch",
    [10466974800] = "Consecutive Punches",
    [12983333733] = "Serious Punch",
    [11365563255] = "Table Flip",
    [13927612951] = "Omni Directional Punch",
    [13929182266] = "Omni Directional Punch",
    [12510170988] = "Uppercut",
    [10471336737] = "Shove",
    [12307656616] = "Hunter's Grasp",
    [12309835105] = "Hunter's Grasp",
    [12272894215] = "Flowing Water",
    [12273188754] = "Flowing Water",
    [12296882427] = "Lethal Whirlwind Stream",
    [12296113986] = "Lethal Whirlwind Stream",
    [12351854556] = "Prey's Peril",
    [12463072679] = "The Final Hunt",
    [12467789963] = "The Final Hunt",
    [12460977270] = "Water Stream Cutting Fist",
    [14057231976] = "Rock Splitting Fist",
    [13630786846] = "Crushed Rock",
    [13813099821] = "Crushed Rock",
    [13785666020] = "Crushed Rock",
    [16082123712] = "Atomic Slash",
    [16057411888] = "Atomic Slash",
    [15295895753] = "Pinpoint Cut",
    [15311685628] = "Split Second Counter",
    [15145462680] = "Atmos Cleave",
    [15290930205] = "Quick Slice",
    [15676072469] = "Solar Cleave",
    [16062410809] = "Sunrise",
    [15520132233] = "Sunset",
    [12534735382] = "Machine Gun Blows",
    [12618271998] = "Blitz Shot",
    [12684390285] = "Jet Dive",
    [12502664044] = "Ignition Burst",
    [13146710762] = "Incinerate",
    [13083332742] = "Flamewave Cannon",
    [15128849047] = "Death Blow",
    [15123665491] = "Death Blow Counter",
    [17275150809] = "Terrible Tornado",
    [17278415853] = "Terrible Tornado",
    [16139108718] = "Crushing Pull",
    [16597322398] = "Expulsive Push",
    [17464644182] = "Psychic Ricochet",
    [16515850153] = "Windstorm Fury",
    [14701242661] = "Brutal Beatdown",
    [14351441234] = "Foul Ball",
    [14004235777] = "Homerun",
    [14299135500] = "Grand Slam",
    [12832505612] = "Speedblitz Dropkick",
    [18179181663] = "Head First",
    [18182425133] = "Head First",
    [13501296372] = "Explosive Shuriken",
    [13881335713] = "Fourfold Flashstrike",
    [13376869471] = "Flash Strike",
    [13294790250] = "Whirlwind Kick"
}

local M1HitLookup = {
    [10469493270] = 1, [10469630950] = 2, [10469639222] = 3, [10469643643] = 4,
    [14004222985] = 1, [13997092940] = 2, [14001963401] = 3, [14136436157] = 4,
    [13370310513] = 1, [13390230973] = 2, [13378751717] = 3, [13378708199] = 4,
    [15259161390] = 1, [15240216931] = 2, [15240176873] = 3, [15162694192] = 4,
    [13532562418] = 1, [13532600125] = 2, [13532604085] = 3, [13294471966] = 4,
    [13491635433] = 1, [13296577783] = 2, [13295919399] = 3, [13295936866] = 4,
    [16515503507] = 1, [16515520431] = 2, [16515448089] = 3, [16552234590] = 4,
    [17325510002] = 1, [17325513870] = 2, [17325522388] = 3, [17325537719] = 4,
    [17889458563] = 1, [17889461810] = 2, [17889471098] = 3, [17889290569] = 4,
    [122482492364036] = 1, [125882667406347] = 2, [134822631853770] = 3, [76602138940033] = 4,
}

local DodgeAnimationIds = {
    [133094662049155] = true,
    [134711731729986] = true,
    [76963965406296]  = true,
    [92546791251633]  = true,
    [128188725134114] = true,
    [109088632860488] = true,
    [78339272602733]  = true,
    [127015697036075] = true,
}

local StaffDirectory = {
    [3350014406] = "Developer",
    [747447782]  = "Developer",
    [1001242712] = "Developer",
    [56721213]   = "Developer",
    [1446694201] = "Developer",
    [76707998]   = "Developer",
    [8874560414] = "Admin",
    [4041635170] = "Admin",
    [1241352401] = "Admin",
    [422755031]  = "Tester",
    [117723419]  = "Tester",
    [971193650]  = "Tester",
    [278097946]  = "Tester",
    [1526501409] = "Tester",
    [41022405]   = "Tester",
    [156112298]  = "Tester",
    [9684094059] = "Tester",
    [77342385]   = "Tester",
    [292707170]  = "Tester",
    [38307780]   = "Tester",
    [221681529]  = "Tester",
    [2544664287] = "Tester",
    [66105529]   = "Tester",
    [60862201]   = "Tester",
    [123755248]  = "Tester",
    [1974829690] = "Tester"
}

-- ========================================================
-- WINDUI ENGINE LOADER
-- ========================================================
local WindUI
do
    local ok, res = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
    end)
    if ok and res then
        WindUI = res
    else
        warn("[Louis Hub] Failed to load WindUI engine distribution!")
        return
    end
end

local function Notify(title, text, duration, icon)
    pcall(function()
        WindUI:Notify({
            Title    = title,
            Content  = text,
            Duration = duration or 3,
            Icon     = icon or "solar:bell-bold",
        })
    end)
end

-- ========================================================
-- SUITE STATE CONFIGURATION
-- ========================================================
-- Combat States
local autoBlockM1 = false
local blockDistance = 14
local predictiveEvasion = false
local evasionRange = 25
local cursorSkillMagnet = false
local magnetRange = 35
local targetLockAlert = false
local targetLockConn = nil
local clashWhiffDetector = false
local clashWhiffConn = nil
local hitboxTimer = false
local statusIndicator = false
local clashPhaseTracker = false
local clashTrackerConn = nil
local moveAnnouncer = false
local moveAnnouncerConns = {}
local wallHitCounter = false
local wallHitConn = nil
local actionReadinessHUD = false
local readinessBillboard = nil
local antiRagdoll = false
local m1ComboTracker = false
local m1ComboConns = {}
local dodgeDetector = false
local dodgeConns = {}
local m1SpacingVisualizer = false
local spacingAdornment = nil

-- Camlock Configuration
local camlockEnabled = false
local camlockTargetingMode = "Crosshair Focus" -- "Crosshair Focus" or "Proximity Threat"
local camlockRadius = 80
local camlockSmoothness = 0.25
local currentCamlockTarget = nil
local camlockConn = nil

-- Smart Combo Assist Configuration
local comboAssistEnabled = false
local comboExecutionMode = "Semi-Auto" -- "Semi-Auto" or "Full-Auto"
local comboCharacterPreset = "Saitama" -- "Saitama", "Garou", "Genos", "Sonic", "MetalBat"
local comboTriggerMethod = "Hold"     -- "Hold" or "DoubleTap"
local isComboRunning = false
local touchStartTime = 0
local lastTapTime = 0

-- Movement States
local smoothDash = false
local smoothDashConn = nil
local groundSnap = false
local groundSnapConn = nil
local tpwalkEnabled = false
local tpwalkSpeed = 2
local tpwalkConn = nil
local customSpeedEnabled = false
local customWalkSpeed = 16
local customJumpEnabled = false
local customJumpPower = 50
local uncappedSensitivity = 1
local shiftlockOffsetX = 1.75
local shiftlockOffsetY = 0
local noclip = false
local noclipConn = nil
local antiVoid = false

-- Visual States
local threatRadar = false
local threatRadarConn = nil
local screenStabilizer = false
local clearVision = false
local clearVisionConn = nil
local antiFlashbang = false
local antiFlashConn = nil
local disableImpactFrames = false
local impactFramesConn = nil
local distortionNeutralizer = false
local distortionConn = nil
local antiCinematicLock = false
local antiCinematicConn = nil
local antiFisheye = false
local antiFisheyeConn = nil
local lockedFOV = 70
local persistentHealth = false
local enemyAwakeningESP = false
local playerTelemetryRadar = false
local espEnabled = false
local espHighlights = {}

-- Performance & Misc States
local smartBoneOptimizer = false
local meshCulling = false
local smartVfxCulling = false
local smartCullConn = nil
local shockwaveNeutralizer = false
local shockwaveConn = nil
local staffSafetyRadar = false
local autoLeaveOnStaff = false
local staffRadarConn = nil
local forceResetEnabled = false
local forceResetThread = nil

-- ========================================================
-- MASTER WINDOW CREATION
-- ========================================================
local Window = WindUI:CreateWindow({
    Title         = "Louis Hub  |  The Strongest Battlegrounds",
    Folder        = "LouisHub_TSB",
    Icon          = "solar:shield-bold",
    NewElements   = true,
    HideSearchBar = false,
    OpenButton    = {
        Title           = "Open Louis Hub",
        CornerRadius    = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled         = false,
        Draggable       = true,
        Scale           = 0.5,
        Color           = ColorSequence.new(
            Color3.fromHex("#FF4B2B"),
            Color3.fromHex("#FF416C")
        ),
    },
    Topbar = {
        Height      = 44,
        ButtonsType = "Mac",
    },
})

Window:Tag({
    Title  = "Master Edition",
    Icon   = "solar:swords-bold",
    Color  = Color3.fromHex("#1f1f1f"),
    Border = true,
})

-- ========================================================
-- DRAGGABLE FLOATING ACTION BUTTON
-- ========================================================
local function createFloatingToggle()
    local parentGui = (gethui and gethui()) or game:GetService("CoreGui")
    if not parentGui or RunService:IsStudio() then
        parentGui = LocalPlayer:WaitForChild("PlayerGui")
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LouisHub_FloatingToggle"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 99999
    ScreenGui.Parent = parentGui

    local ToggleBtn = Instance.new("ImageButton")
    ToggleBtn.Name = "ToggleButton"
    ToggleBtn.Size = UDim2.fromOffset(50, 50)
    ToggleBtn.Position = UDim2.new(0, 20, 0.4, 0)
    ToggleBtn.BackgroundColor3 = Color3.fromHex("#18181b")
    ToggleBtn.Image = "rbxassetid://132438947521974"
    ToggleBtn.Active = true
    ToggleBtn.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = ToggleBtn

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromHex("#FF416C")
    Stroke.Thickness = 2
    Stroke.Parent = ToggleBtn

    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ToggleBtn.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    ToggleBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            ToggleBtn.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    ToggleBtn.Activated:Connect(function()
        pcall(function()
            Window:Toggle()
        end)
    end)
end

task.spawn(createFloatingToggle)

-- ========================================================
-- REUSABLE UTILITY HELPERS
-- ========================================================
local function triggerBlock()
    pcall(function()
        VirtualInput:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.28)
        VirtualInput:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end)
end

local function triggerSideDash()
    pcall(function()
        VirtualInput:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
        task.wait(0.05)
        VirtualInput:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    end)
end

local function sendM1()
    pcall(function()
        VirtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.04)
        VirtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

local function sendKey(keyCode, duration)
    pcall(function()
        VirtualInput:SendKeyEvent(true, keyCode, false, game)
        task.wait(duration or 0.05)
        VirtualInput:SendKeyEvent(false, keyCode, false, game)
    end)
end

local function getExtremityDistance(myHrp, enemyChar)
    local minDistance = (myHrp.Position - enemyChar.HumanoidRootPart.Position).Magnitude
    local reachParts = {
        enemyChar:FindFirstChild("RightHand") or enemyChar:FindFirstChild("Right Arm"),
        enemyChar:FindFirstChild("LeftHand") or enemyChar:FindFirstChild("Left Arm"),
        enemyChar:FindFirstChild("RightFoot") or enemyChar:FindFirstChild("Right Leg"),
        enemyChar:FindFirstChild("LeftFoot") or enemyChar:FindFirstChild("Left Leg"),
        enemyChar:FindFirstChild("Sword") or enemyChar:FindFirstChild("Blade")
    }

    for _, limb in ipairs(reachParts) do
        if limb and limb:IsA("BasePart") then
            local dist = (myHrp.Position - limb.Position).Magnitude
            if dist < minDistance then
                minDistance = dist
            end
        end
    end

    return minDistance
end

local function getClosestEnemyTorso(maxRadius)
    local target = nil
    local nearest = maxRadius or math.huge
    for _, enemy in ipairs(Players:GetPlayers()) do
        if enemy ~= LocalPlayer and enemy.Character then
            local eHrp = enemy.Character:FindFirstChild("HumanoidRootPart")
            local eHum = enemy.Character:FindFirstChild("Humanoid")
            if eHrp and eHum and eHum.Health > 0 and RootPart then
                local dist = (RootPart.Position - eHrp.Position).Magnitude
                if dist < nearest then
                    nearest = dist
                    target = eHrp
                end
            end
        end
    end
    return target
end

local function getCamlockTarget()
    if not RootPart or not Camera then return nil end

    if camlockTargetingMode == "Proximity Threat" then
        return getClosestEnemyTorso(camlockRadius)
    end

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local bestTarget = nil
    local shortestScreenDist = math.huge

    for _, enemy in ipairs(Players:GetPlayers()) do
        if enemy ~= LocalPlayer and enemy.Character then
            local eHrp = enemy.Character:FindFirstChild("HumanoidRootPart")
            local eHum = enemy.Character:FindFirstChild("Humanoid")
            if eHrp and eHum and eHum.Health > 0 then
                local worldDist = (RootPart.Position - eHrp.Position).Magnitude
                if worldDist <= camlockRadius then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(eHrp.Position)
                    if onScreen then
                        local screenDist = (center - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                        if screenDist < shortestScreenDist then
                            shortestScreenDist = screenDist
                            bestTarget = eHrp
                        end
                    end
                end
            end
        end
    end

    return bestTarget
end

local function isSkillReady(slotNumber)
    local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not pGui then return false end

    local screenGui = pGui:FindFirstChild("ScreenGui") or pGui:FindFirstChild("MainGui")
    if not screenGui then return true end

    local hotbar = screenGui:FindFirstChild("Hotbar") or screenGui:FindFirstChild("MagicHealth")
    if hotbar then
        local slot = hotbar:FindFirstChild(tostring(slotNumber)) or hotbar:FindFirstChild("Skill" .. slotNumber)
        if slot then
            local cdFrame = slot:FindFirstChild("Cooldown") or slot:FindFirstChild("Fill")
            if cdFrame and cdFrame:IsA("GuiObject") then
                if cdFrame.Visible and (cdFrame.Size.Y.Scale > 0.05 or cdFrame.Size.X.Scale > 0.05) then
                    return false
                end
            end
        end
    end
    return true
end

local function verifyHitConfirm()
    if not RootPart then return false end
    for _, enemy in ipairs(Players:GetPlayers()) do
        if enemy ~= LocalPlayer and enemy.Character then
            local eHrp = enemy.Character:FindFirstChild("HumanoidRootPart")
            local eHum = enemy.Character:FindFirstChild("Humanoid")
            if eHrp and eHum and eHum.Health > 0 then
                if (RootPart.Position - eHrp.Position).Magnitude <= 10 then
                    if enemy.Character:FindFirstChild("Combat") or enemy.Character:GetAttribute("Stunned") or (eHum.Health < eHum.MaxHealth) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- ========================================================
-- TAB 1: COMBAT
-- ========================================================
local CombatTab = Window:Tab({
    Title  = "Combat",
    Icon   = "solar:swords-bold",
    Desc   = "Precision combat assistance, evasion and timing tools",
    Border = true,
})

CombatTab:Section({ Title = "Defensive Assists" })

CombatTab:Toggle({
    Title    = "Auto Block V1 (M1)",
    Desc     = "Automatically blocks basic punches and rapid hit barrages before they land. Ignores heavy skills to keep you safe from guard breaks.",
    Value    = false,
    Callback = function(state)
        autoBlockM1 = state
        if autoBlockM1 then
            task.spawn(function()
                while autoBlockM1 do
                    if Character and RootPart and Humanoid and Humanoid.Health > 0 then
                        for _, enemy in ipairs(Players:GetPlayers()) do
                            if enemy ~= LocalPlayer and enemy.Character then
                                local eChar = enemy.Character
                                local eHrp = eChar:FindFirstChild("HumanoidRootPart")
                                local eHum = eChar:FindFirstChild("Humanoid")

                                if eHrp and eHum and eHum.Health > 0 then
                                    local dist = getExtremityDistance(RootPart, eChar)
                                    if dist <= blockDistance then
                                        local isAttacking = eChar:GetAttribute("Attacking") or (eChar:FindFirstChild("Combat") ~= nil)
                                        local isHeavy = eChar:GetAttribute("GuardBreak") or eChar:GetAttribute("HeavyAttack") or eChar:FindFirstChild("Heavy")
                                        
                                        if isAttacking and not isHeavy then
                                            triggerBlock()
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.04)
                end
            end)
        end
    end,
})

CombatTab:Slider({
    Title     = "Block Trigger Range",
    Desc      = "Distance threshold for punch detection",
    Step      = 1,
    Value     = { Min = 8, Max = 25, Default = 14 },
    IsTooltip = true,
    Callback  = function(val)
        blockDistance = val
    end,
})

CombatTab:Space()
CombatTab:Section({ Title = "Targeting & Smart Lock" })

CombatTab:Toggle({
    Title    = "Camlock (Shift-Lock Aware)",
    Desc     = "Smoothly aligns your view or body toward enemies. Automatically switches between camera lock and body facing depending on shift-lock status.",
    Value    = false,
    Callback = function(state)
        camlockEnabled = state
        if camlockEnabled then
            camlockConn = RunService.RenderStepped:Connect(function()
                if not camlockEnabled or not RootPart or not Humanoid or Humanoid.Health <= 0 then
                    currentCamlockTarget = nil
                    return
                end

                if currentCamlockTarget then
                    local parentChar = currentCamlockTarget.Parent
                    local parentHum = parentChar and parentChar:FindFirstChild("Humanoid")
                    if not parentHum or parentHum.Health <= 0 or (RootPart.Position - currentCamlockTarget.Position).Magnitude > camlockRadius then
                        currentCamlockTarget = nil
                    end
                end

                if not currentCamlockTarget then
                    currentCamlockTarget = getCamlockTarget()
                end

                if currentCamlockTarget and Camera then
                    local targetPos = currentCamlockTarget.Position
                    local isShiftLockActive = (UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter) or (LocalPlayer:GetAttribute("ShiftLocked") == true)

                    if isShiftLockActive then
                        local currentCF = Camera.CFrame
                        local targetCF = CFrame.lookAt(currentCF.Position, targetPos)
                        Camera.CFrame = currentCF:Lerp(targetCF, camlockSmoothness)
                    else
                        local lookPos = Vector3.new(targetPos.X, RootPart.Position.Y, targetPos.Z)
                        RootPart.CFrame = CFrame.lookAt(RootPart.Position, lookPos)
                    end
                end
            end)
            Notify("Camlock", "Smart Camlock activated!", 2, "solar:aim-bold")
        else
            if camlockConn then
                camlockConn:Disconnect()
                camlockConn = nil
            end
            currentCamlockTarget = nil
        end
    end,
})

CombatTab:Dropdown({
    Title    = "Targeting Priority",
    Desc     = "Determines how the system chooses your opponent in crowded combat scenarios.",
    Values   = { "Crosshair Focus", "Proximity Threat" },
    Value    = "Crosshair Focus",
    Callback = function(val)
        camlockTargetingMode = val
        currentCamlockTarget = nil
    end,
})

CombatTab:Slider({
    Title     = "Targeting Range",
    Desc      = "Maximum acquisition distance for target locking",
    Step      = 5,
    Value     = { Min = 30, Max = 150, Default = 80 },
    IsTooltip = true,
    Callback  = function(val)
        camlockRadius = val
    end,
})

CombatTab:Slider({
    Title     = "Tracking Smoothness",
    Desc      = "Interpolation speed of camera tracking adjustments",
    Step      = 0.05,
    Value     = { Min = 0.1, Max = 1, Default = 0.25 },
    IsTooltip = true,
    Callback  = function(val)
        camlockSmoothness = val
    end,
})

CombatTab:Space()
CombatTab:Section({ Title = "Threat & Evasion" })

CombatTab:Toggle({
    Title    = "Predictive Evasion",
    Desc     = "Calculates curved projectile trajectories and automatically dashes aside just before impact.",
    Value    = false,
    Callback = function(state)
        predictiveEvasion = state
        if predictiveEvasion then
            task.spawn(function()
                while predictiveEvasion do
                    if Character and RootPart and Humanoid and Humanoid.Health > 0 then
                        local thrown = workspace:FindFirstChild("Thrown")
                        if thrown then
                            for _, obj in ipairs(thrown:GetChildren()) do
                                if obj:IsA("BasePart") or obj:IsA("Model") then
                                    local pos = obj:IsA("BasePart") and obj.Position or obj:GetPivot().Position
                                    local dist = (RootPart.Position - pos).Magnitude
                                    if dist <= evasionRange and dist > 4 then
                                        triggerSideDash()
                                        task.wait(0.6)
                                        break
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.08)
                end
            end)
        end
    end,
})

CombatTab:Slider({
    Title     = "Evasion Trigger Range",
    Desc      = "Proximity threshold to incoming projectiles",
    Step      = 1,
    Value     = { Min = 10, Max = 40, Default = 25 },
    IsTooltip = true,
    Callback  = function(val)
        evasionRange = val
    end,
})

CombatTab:Toggle({
    Title    = "Clash & Whiff Detector",
    Desc     = "Instantly notifies you when an enemy's skill misses, clashes, or ends its active hitbox phase so you know exactly when to counterattack.",
    Value    = false,
    Callback = function(state)
        clashWhiffDetector = state
        local customVfx = ReplicatedStorage:FindFirstChild("CustomMoveVFX")
        local cast = customVfx and customVfx:FindFirstChild("Cast")
        local branchEvent = cast and cast:FindFirstChild("BranchActivateEvent")
        
        if clashWhiffDetector and branchEvent then
            clashWhiffConn = branchEvent.OnClientEvent:Connect(function(data)
                if not clashWhiffDetector then return end
                if type(data) == "table" then
                    local bName = tostring(data.branchName or ""):lower()
                    if bName:find("miss") or bName:find("whiff") then
                        Notify("Combat Alert", "Enemy missed attack branch! Safe to punish.", 2, "solar:shield-check-bold")
                    elseif bName:find("clash") then
                        Notify("Combat Alert", "Skill clash detected! Prepare instant follow-up.", 2, "solar:swords-bold")
                    end
                end
            end)
        else
            if clashWhiffConn then
                clashWhiffConn:Disconnect()
                clashWhiffConn = nil
            end
        end
    end,
})

CombatTab:Space()
CombatTab:Section({ Title = "Aim & Precision" })

CombatTab:Toggle({
    Title    = "Cursor Skill Magnet",
    Desc     = "Gently snaps your cursor-guided abilities and aimed skill shots toward the nearest target so your ranged moves never miss.",
    Value    = false,
    Callback = function(state)
        cursorSkillMagnet = state
        local moveReq = ReplicatedStorage:FindFirstChild("MoveEditorReq")
        if moveReq and moveReq:IsA("RemoteFunction") then
            if cursorSkillMagnet then
                moveReq.OnClientInvoke = function(action, arg)
                    if action == "getFreshMouseWorld" then
                        local enemyTarget = getClosestEnemyTorso(magnetRange)
                        if enemyTarget then
                            return {
                                Position = enemyTarget.Position,
                                CFrame   = enemyTarget.CFrame,
                                RequestSource = (type(arg) == "table" and arg.RequestSource) or nil
                            }
                        end
                        local mouse = LocalPlayer:GetMouse()
                        return {
                            Position = mouse.Hit.Position,
                            CFrame   = mouse.Hit,
                            RequestSource = (type(arg) == "table" and arg.RequestSource) or nil
                        }
                    end
                    return nil
                end
            end
        end
    end,
})

CombatTab:Slider({
    Title     = "Magnet Lock Range",
    Desc      = "Radius for snapping cursor skills",
    Step      = 1,
    Value     = { Min = 15, Max = 70, Default = 35 },
    IsTooltip = true,
    Callback  = function(val)
        magnetRange = val
    end,
})

CombatTab:Toggle({
    Title    = "M1 Spacing & Reach Visualizer",
    Desc     = "Projects your exact physical M1 attack reach boundary in front of you so you always hit from safe maximum range.",
    Value    = false,
    Callback = function(state)
        m1SpacingVisualizer = state
        if m1SpacingVisualizer then
            if not spacingAdornment then
                spacingAdornment = Instance.new("BoxHandleAdornment")
                spacingAdornment.Name = "M1SpacingBox"
                spacingAdornment.Size = Vector3.new(4.5, 4, 6.5)
                spacingAdornment.Color3 = Color3.fromHex("#FF3366")
                spacingAdornment.Transparency = 0.65
                spacingAdornment.ZIndex = 5
                spacingAdornment.AlwaysOnTop = true
                spacingAdornment.Parent = workspace
            end
            RunService.RenderStepped:Connect(function()
                if m1SpacingVisualizer and RootPart and spacingAdornment then
                    spacingAdornment.Adornee = RootPart
                    spacingAdornment.CFrame = CFrame.new(0, 0, -3.25)
                elseif spacingAdornment then
                    spacingAdornment.Adornee = nil
                end
            end)
        else
            if spacingAdornment then
                spacingAdornment:Destroy()
                spacingAdornment = nil
            end
        end
    end,
})

CombatTab:Space()
CombatTab:Section({ Title = "Combo Automation & Assists" })

-- Smart Combo Engine (Semi-Auto & Full-Auto with Cooldown Verification)
local function runSemiAutoCombo()
    sendM1()
    task.wait(0.18)
    if not verifyHitConfirm() then return end

    for _ = 2, 3 do
        task.wait(0.23)
        if Character:GetAttribute("Stunned") then return end
        sendM1()
    end
    task.wait(0.4)
end

local function runFullAutoCombo()
    sendM1()
    task.wait(0.18)
    if not verifyHitConfirm() then return end

    for _ = 2, 3 do
        task.wait(0.23)
        if Character:GetAttribute("Stunned") then return end
        sendM1()
    end

    task.wait(0.2)

    if comboCharacterPreset == "Saitama" then
        if isSkillReady(2) then
            sendKey(Enum.KeyCode.Two, 0.05)
            task.wait(1.4)
            sendKey(Enum.KeyCode.Q, 0.05)
            task.wait(0.1)
            sendM1()
            task.wait(0.23)
            sendM1()
        else
            sendM1()
        end
    elseif comboCharacterPreset == "Garou" then
        if isSkillReady(1) then
            sendKey(Enum.KeyCode.One, 0.05)
            task.wait(1.1)
            sendKey(Enum.KeyCode.Q, 0.05)
            task.wait(0.1)
            sendM1()
            task.wait(0.23)
            if isSkillReady(3) then
                sendKey(Enum.KeyCode.Three, 0.05)
            else
                sendM1()
            end
        else
            sendM1()
        end
    elseif comboCharacterPreset == "Genos" then
        if isSkillReady(1) then
            sendKey(Enum.KeyCode.One, 0.05)
            task.wait(1.3)
            sendM1()
            task.wait(0.23)
            if isSkillReady(3) then
                sendKey(Enum.KeyCode.Three, 0.05)
            end
        else
            sendM1()
        end
    elseif comboCharacterPreset == "Sonic" then
        if isSkillReady(2) then
            sendKey(Enum.KeyCode.Two, 0.05)
            task.wait(0.8)
            sendKey(Enum.KeyCode.Space, 0.05)
            task.wait(0.15)
            sendM1()
        else
            sendM1()
        end
    elseif comboCharacterPreset == "MetalBat" then
        if isSkillReady(3) then
            sendKey(Enum.KeyCode.Three, 0.05)
            task.wait(1.3)
            sendM1()
            task.wait(0.23)
            if isSkillReady(4) then
                sendKey(Enum.KeyCode.Four, 0.05)
            end
        else
            sendM1()
        end
    else
        sendM1()
    end
end

local function triggerSmartCombo()
    if isComboRunning or not comboAssistEnabled then return end
    isComboRunning = true

    if comboExecutionMode == "Semi-Auto" then
        runSemiAutoCombo()
    else
        runFullAutoCombo()
    end

    task.wait(0.3)
    isComboRunning = false
end

UserInputService.InputBegan:Connect(function(input, processed)
    if not comboAssistEnabled or processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local now = tick()
        touchStartTime = now
        if comboTriggerMethod == "DoubleTap" then
            if (now - lastTapTime) <= 0.22 then
                task.spawn(triggerSmartCombo)
            end
            lastTapTime = now
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if not comboAssistEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if comboTriggerMethod == "Hold" then
            if (tick() - touchStartTime) >= 0.25 then
                task.spawn(triggerSmartCombo)
            end
        end
    end
end)

CombatTab:Toggle({
    Title    = "Smart Combo Assist (Hit-Confirm)",
    Desc     = "Prime a full combo by holding or double-tapping your attack button. The combo only continues if your initial hit physically lands.",
    Value    = false,
    Callback = function(state)
        comboAssistEnabled = state
        if comboAssistEnabled then
            Notify("Combo Assist", "Smart Combo primed! Hold or double-tap to initiate.", 3)
        end
    end,
})

CombatTab:Dropdown({
    Title    = "Combo Execution Mode",
    Desc     = "Select between Semi-Auto (3x M1 pause for manual skill) or Full-Auto (automatic character combo with CD check).",
    Values   = { "Semi-Auto", "Full-Auto" },
    Value    = "Semi-Auto",
    Callback = function(val)
        comboExecutionMode = val
    end,
})

CombatTab:Dropdown({
    Title    = "Full-Auto Character Preset",
    Desc     = "Select your current character archetype to automatically chain optimal skill BnB sequences.",
    Values   = { "Saitama", "Garou", "Genos", "Sonic", "MetalBat" },
    Value    = "Saitama",
    Callback = function(val)
        comboCharacterPreset = val
    end,
})

CombatTab:Dropdown({
    Title    = "Combo Trigger Method",
    Desc     = "Select your preferred input method for chaining combos.",
    Values   = { "Hold", "DoubleTap" },
    Value    = "Hold",
    Callback = function(val)
        comboTriggerMethod = val
    end,
})

CombatTab:Space()
CombatTab:Section({ Title = "Threat Awareness" })

CombatTab:Toggle({
    Title    = "M1 Combo Tracker & Finisher Alert",
    Desc     = "Counts opponent basic attack swings in real-time, flashing a warning before their fourth strike lands so you never get caught by heavy combo finishers.",
    Value    = false,
    Callback = function(state)
        m1ComboTracker = state
        if m1ComboTracker then
            local function hookCharM1(char)
                local hum = char:WaitForChild("Humanoid", 4)
                if hum then
                    local conn = hum.AnimationPlayed:Connect(function(track)
                        if not m1ComboTracker then return end
                        local animId = track.Animation and track.Animation.AnimationId:match("%d+")
                        if animId then
                            local hitIndex = M1HitLookup[tonumber(animId)]
                            if hitIndex then
                                local pName = char.Name
                                local p = Players:GetPlayerFromCharacter(char)
                                if p then pName = p.DisplayName end
                                if hitIndex == 3 then
                                    Notify("Combo Alert", pName .. " is on Hit 3! Finisher incoming!", 1.8, "solar:danger-triangle-bold")
                                elseif hitIndex == 4 then
                                    Notify("Finisher Alert", pName .. " executed M1 Finisher!", 1.5, "solar:shield-warning-bold")
                                end
                            end
                        end
                    end)
                    table.insert(m1ComboConns, conn)
                end
            end

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    hookCharM1(p.Character)
                end
            end
        else
            for _, c in ipairs(m1ComboConns) do
                c:Disconnect()
            end
            m1ComboConns = {}
        end
    end,
})

CombatTab:Toggle({
    Title    = "Enemy Dodge Detector",
    Desc     = "Instantly notifies you the millisecond an opponent executes a side or back dash, revealing when their evasive cooldown is triggered.",
    Value    = false,
    Callback = function(state)
        dodgeDetector = state
        if dodgeDetector then
            local function hookCharDodge(char)
                local hum = char:WaitForChild("Humanoid", 4)
                if hum then
                    local conn = hum.AnimationPlayed:Connect(function(track)
                        if not dodgeDetector then return end
                        local animId = track.Animation and track.Animation.AnimationId:match("%d+")
                        if animId and DodgeAnimationIds[tonumber(animId)] then
                            local pName = char.Name
                            local p = Players:GetPlayerFromCharacter(char)
                            if p then pName = p.DisplayName end
                            Notify("Dodge Alert", pName .. " used Evasive Dash (Cooldown active)!", 2, "solar:running-bold")
                        end
                    end)
                    table.insert(dodgeConns, conn)
                end
            end

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    hookCharDodge(p.Character)
                end
            end
        else
            for _, c in ipairs(dodgeConns) do
                c:Disconnect()
            end
            dodgeConns = {}
        end
    end,
})

CombatTab:Toggle({
    Title    = "Opponent Move Announcer",
    Desc     = "Identifies and displays the exact skill name an opponent is winding up on frame one, giving you ample time to react.",
    Value    = false,
    Callback = function(state)
        moveAnnouncer = state
        if moveAnnouncer then
            local function hookCharacter(char)
                local hum = char:WaitForChild("Humanoid", 4)
                if hum then
                    local conn = hum.AnimationPlayed:Connect(function(track)
                        if not moveAnnouncer then return end
                        local animId = track.Animation and track.Animation.AnimationId:match("%d+")
                        if animId then
                            local numId = tonumber(animId)
                            local moveName = MoveAnimLookup[numId]
                            if moveName then
                                local pName = char.Name
                                local p = Players:GetPlayerFromCharacter(char)
                                if p then pName = p.DisplayName end
                                Notify("Incoming Move", pName .. " is using [" .. moveName .. "]!", 2.5, "solar:danger-triangle-bold")
                            end
                        end
                    end)
                    table.insert(moveAnnouncerConns, conn)
                end
            end

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    hookCharacter(p.Character)
                end
            end
        else
            for _, c in ipairs(moveAnnouncerConns) do
                c:Disconnect()
            end
            moveAnnouncerConns = {}
        end
    end,
})

CombatTab:Toggle({
    Title    = "Wall Combo Hit Counter",
    Desc     = "Shows a countdown of remaining hits while pinned against a wall so you can perfectly time your recovery input before the final knockback.",
    Value    = false,
    Callback = function(state)
        wallHitCounter = state
        if wallHitCounter then
            wallHitConn = workspace.ChildAdded:Connect(function(child)
                if not wallHitCounter then return end
                if child.Name:find("Wall") or child.Name:find("Hit") then
                    if Character and RootPart and (RootPart.Position - child:GetPivot().Position).Magnitude <= 12 then
                        Notify("Wall Combo", "Pinned against wall! Prepare recovery dash on final hit!", 2, "solar:swords-bold")
                    end
                end
            end)
        else
            if wallHitConn then
                wallHitConn:Disconnect()
                wallHitConn = nil
            end
        end
    end,
})

CombatTab:Toggle({
    Title    = "Target Lock Alert",
    Desc     = "Alerts you instantly whenever an enemy locks onto you or a teammate with a targeted ability before the attack connects.",
    Value    = false,
    Callback = function(state)
        targetLockAlert = state
        if targetLockAlert then
            targetLockConn = RunService.Heartbeat:Connect(function()
                for _, enemy in ipairs(Players:GetPlayers()) do
                    if enemy ~= LocalPlayer and enemy.Character then
                        local bind = enemy.Character:FindFirstChild("__CMVFXMoveBind")
                        if bind then
                            local victims = bind:FindFirstChild("__CMVFXVictimTargets")
                            if victims then
                                for _, val in ipairs(victims:GetChildren()) do
                                    if val:IsA("ObjectValue") and val.Value == Character then
                                        Notify("Target Warning", enemy.DisplayName .. " has locked onto you!", 2, "solar:danger-triangle-bold")
                                        task.wait(1.5)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            if targetLockConn then
                targetLockConn:Disconnect()
                targetLockConn = nil
            end
        end
    end,
})

CombatTab:Toggle({
    Title    = "Clash Phase Tracker",
    Desc     = "Displays an active stage timer during multi-hit clash sequences, alerting you the exact moment the final grab or strike executes.",
    Value    = false,
    Callback = function(state)
        clashPhaseTracker = state
        local thrown = workspace:FindFirstChild("Thrown")
        if clashPhaseTracker and thrown then
            clashTrackerConn = thrown.ChildAdded:Connect(function(child)
                if not clashPhaseTracker then return end
                if child.Name == "ShardSphere" or child.Name:find("WaterPalm") then
                    Notify("Clash Tracker", "Flurry Phase Active (Duration: ~2.2s)", 2, "solar:swords-bold")
                    task.delay(2.2, function()
                        if clashPhaseTracker then
                            Notify("Clash Tracker", "Final Grab Incoming! Prepare Dodge/Parry!", 2, "solar:danger-triangle-bold")
                        end
                    end)
                end
            end)
        else
            if clashTrackerConn then
                clashTrackerConn:Disconnect()
                clashTrackerConn = nil
            end
        end
    end,
})

CombatTab:Toggle({
    Title    = "Skill Hitbox Expiration Timer",
    Desc     = "Displays an exact countdown bar showing when an opponent's lingering multi-hit attack finishes, allowing you to counterattack safely without getting caught.",
    Value    = false,
    Callback = function(state)
        hitboxTimer = state
        if hitboxTimer then
            task.spawn(function()
                while hitboxTimer do
                    for _, enemy in ipairs(Players:GetPlayers()) do
                        if enemy ~= LocalPlayer and enemy.Character then
                            local bind = enemy.Character:FindFirstChild("__CMVFXMoveBind")
                            if bind and bind:GetAttribute("ActiveTime") then
                                local remaining = bind:GetAttribute("ActiveTime")
                                if remaining and remaining > 0 then
                                    Notify("Hitbox Timer", enemy.DisplayName .. " active: " .. string.format("%.1fs", remaining), 1)
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end,
})

CombatTab:Toggle({
    Title    = "Target Status Indicator",
    Desc     = "Displays clear status icons above opponents showing when they have active invulnerability frames (I-Frames), are stunned, or are blocking so you never waste attacks.",
    Value    = false,
    Callback = function(state)
        statusIndicator = state
        if statusIndicator then
            task.spawn(function()
                while statusIndicator do
                    for _, enemy in ipairs(Players:GetPlayers()) do
                        if enemy ~= LocalPlayer and enemy.Character then
                            local eChar = enemy.Character
                            local hasIFrames = eChar:GetAttribute("IFrames") or eChar:FindFirstChild("Invulnerable")
                            local isStunned = eChar:GetAttribute("Stunned") or eChar:FindFirstChild("Stun")
                            local isBlocking = eChar:GetAttribute("Blocking") or eChar:FindFirstChild("Block")
                            
                            local tag = eChar:FindFirstChild("StatusTagBillboard")
                            if not tag and (hasIFrames or isStunned or isBlocking) then
                                local head = eChar:FindFirstChild("Head")
                                if head then
                                    local bb = Instance.new("BillboardGui")
                                    bb.Name = "StatusTagBillboard"
                                    bb.Size = UDim2.fromOffset(100, 25)
                                    bb.StudsOffset = Vector3.new(0, 2.5, 0)
                                    bb.AlwaysOnTop = true
                                    bb.Parent = eChar
                                    
                                    local txt = Instance.new("TextLabel")
                                    txt.Size = UDim2.fromScale(1, 1)
                                    txt.BackgroundTransparency = 1
                                    txt.TextColor3 = Color3.fromHex("#FFCC00")
                                    txt.Font = Enum.Font.GothamBold
                                    txt.TextSize = 14
                                    txt.Parent = bb
                                end
                            end
                            if tag and tag:FindFirstChildOfClass("TextLabel") then
                                local txt = tag:FindFirstChildOfClass("TextLabel")
                                if hasIFrames then
                                    txt.Text = "[ I-FRAMES ]"
                                    txt.TextColor3 = Color3.fromHex("#38BDF8")
                                elseif isStunned then
                                    txt.Text = "[ STUNNED ]"
                                    txt.TextColor3 = Color3.fromHex("#EF4444")
                                elseif isBlocking then
                                    txt.Text = "[ BLOCKING ]"
                                    txt.TextColor3 = Color3.fromHex("#10B981")
                                else
                                    tag:Destroy()
                                end
                            end
                        end
                    end
                    task.wait(0.2)
                end
            end)
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("StatusTagBillboard") then
                    p.Character.StatusTagBillboard:Destroy()
                end
            end
        end
    end,
})

CombatTab:Space()
CombatTab:Section({ Title = "Combat Mechanics" })

CombatTab:Toggle({
    Title    = "Action Readiness HUD",
    Desc     = "Displays a small color-coded reticle showing when your character has fully regained control to attack or dash out of stun states.",
    Value    = false,
    Callback = function(state)
        actionReadinessHUD = state
        if actionReadinessHUD then
            task.spawn(function()
                while actionReadinessHUD do
                    if Character and Character:FindFirstChild("Head") then
                        if not readinessBillboard then
                            readinessBillboard = Instance.new("BillboardGui")
                            readinessBillboard.Name = "ActionReadinessHUD"
                            readinessBillboard.Size = UDim2.fromOffset(80, 20)
                            readinessBillboard.StudsOffset = Vector3.new(0, 3.8, 0)
                            readinessBillboard.AlwaysOnTop = true
                            readinessBillboard.Parent = Character.Head

                            local txt = Instance.new("TextLabel")
                            txt.Size = UDim2.fromScale(1, 1)
                            txt.BackgroundTransparency = 1
                            txt.Font = Enum.Font.GothamBold
                            txt.TextSize = 12
                            txt.Parent = readinessBillboard
                        end

                        local isFrozen = Character:FindFirstChild("Freeze") or Character:FindFirstChild("Slowed")
                        local isRagdoll = Character:FindFirstChild("Ragdoll")
                        local isStunned = Character:GetAttribute("Stunned")
                        local label = readinessBillboard:FindFirstChildOfClass("TextLabel")

                        if isFrozen or isRagdoll or isStunned then
                            label.Text = "LOCKED"
                            label.TextColor3 = Color3.fromHex("#EF4444")
                        else
                            label.Text = "READY"
                            label.TextColor3 = Color3.fromHex("#10B981")
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            if readinessBillboard then
                readinessBillboard:Destroy()
                readinessBillboard = nil
            end
        end
    end,
})

CombatTab:Button({
    Title    = "Directional Awakening Burst",
    Desc     = "Fires your awakening directly toward your current movement direction via the native combat remote, eliminating startup input delay.",
    Icon     = "solar:bolt-bold",
    Callback = function()
        pcall(function()
            if Character then
                local comm = Character:FindFirstChild("Communicate")
                if comm and Humanoid then
                    comm:FireServer({
                        ["Key"] = Enum.KeyCode.G,
                        ["MoveDirection"] = Humanoid.MoveDirection
                    })
                    Notify("Louis Hub", "Directional Awakening Burst fired!", 2)
                    return
                end
            end
            VirtualInput:SendKeyEvent(true, Enum.KeyCode.G, false, game)
            task.wait(0.05)
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.G, false, game)
        end)
    end,
})

CombatTab:Toggle({
    Title    = "Anti-Ragdoll / Quick Recovery",
    Desc     = "Prevents prolonged ground knockdown states and automatically forces your character to stand up immediately.",
    Value    = false,
    Callback = function(state)
        antiRagdoll = state
        if antiRagdoll then
            task.spawn(function()
                while antiRagdoll do
                    if Character and Humanoid then
                        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                        Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                        if Humanoid.Sit then
                            Humanoid.Sit = false
                        end
                    end
                    task.wait(0.08)
                end
            end)
        end
    end,
})

-- ========================================================
-- TAB 2: MOVEMENT
-- ========================================================
local MoveTab = Window:Tab({
    Title  = "Movement",
    Icon   = "solar:running-bold",
    Desc   = "Mobility enhancements, parameters and boundaries",
    Border = true,
})

MoveTab:Section({ Title = "Mobility Enhancements" })

MoveTab:Toggle({
    Title    = "Smooth Dash (Anti-Trip)",
    Desc     = "Removes collision with rubble and crater stones so your dashes and side-hops never get stuck on broken terrain.",
    Value    = false,
    Callback = function(state)
        smoothDash = state
        if smoothDash then
            smoothDashConn = RunService.Stepped:Connect(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        if obj.CollisionGroup == "debricol" or obj.Name:find("Rock") or obj.Name:find("Debris") then
                            obj.CanCollide = false
                        end
                    end
                end
            end)
            Notify("Louis Hub", "Smooth Dash active: Rubble collisions neutralized!", 3)
        else
            if smoothDashConn then
                smoothDashConn:Disconnect()
                smoothDashConn = nil
            end
        end
    end,
})

MoveTab:Toggle({
    Title    = "Ground Snap Stabilizer",
    Desc     = "Calculates floor height beneath your character during fast dashes, preventing accidental airborne float states during rapid M1 chains.",
    Value    = false,
    Callback = function(state)
        groundSnap = state
        if groundSnap then
            groundSnapConn = RunService.Heartbeat:Connect(function()
                if Character and RootPart and Humanoid and Humanoid.FloorMaterial == Enum.Material.Air then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterType = Enum.RaycastFilterType.Include
                    local mapFolder = workspace:FindFirstChild("Map") or workspace:FindFirstChild("Built")
                    if mapFolder then
                        rayParams.FilterDescendantsInstances = { mapFolder, workspace.Terrain }
                        local rayResult = workspace:Raycast(RootPart.Position + Vector3.new(0, 2, 0), Vector3.new(0, -6, 0), rayParams)
                        if rayResult and (RootPart.Position.Y - rayResult.Position.Y) <= 2.5 then
                            RootPart.CFrame = CFrame.new(Vector3.new(RootPart.Position.X, rayResult.Position.Y + 3, RootPart.Position.Z)) * RootPart.CFrame.Rotation
                        end
                    end
                end
            end)
        else
            if groundSnapConn then
                groundSnapConn:Disconnect()
                groundSnapConn = nil
            end
        end
    end,
})

MoveTab:Toggle({
    Title    = "TPWalk (Instant Velocity)",
    Desc     = "Translates character coordinates directly along your movement direction to bypass standard physics dampening.",
    Value    = false,
    Callback = function(state)
        tpwalkEnabled = state
        if tpwalkEnabled then
            tpwalkConn = RunService.Heartbeat:Connect(function(delta)
                if tpwalkEnabled and Humanoid and RootPart and Humanoid.MoveDirection.Magnitude > 0 then
                    RootPart.CFrame = RootPart.CFrame + (Humanoid.MoveDirection * (tpwalkSpeed * delta * 60))
                end
            end)
            Notify("Louis Hub", "TPWalk active!", 2)
        else
            if tpwalkConn then
                tpwalkConn:Disconnect()
                tpwalkConn = nil
            end
        end
    end,
})

MoveTab:Slider({
    Title     = "TPWalk Speed Multiplier",
    Desc      = "Adjustment scale for coordinate displacement rate",
    Step      = 0.5,
    Value     = { Min = 1, Max = 10, Default = 2 },
    IsTooltip = true,
    Callback  = function(val)
        tpwalkSpeed = val
    end,
})

MoveTab:Space()
MoveTab:Section({ Title = "Character & Camera Parameters" })

MoveTab:Slider({
    Title     = "Uncapped Sensitivity Multiplier",
    Desc      = "Expands your camera turning speed beyond native menu limits for instant 180-degree flick turns and ultra-responsive aiming.",
    Step      = 0.1,
    Value     = { Min = 1, Max = 5, Default = 1 },
    IsTooltip = true,
    Callback  = function(val)
        uncappedSensitivity = val
        pcall(function()
            LocalPlayer:SetAttribute("S_Sensitivity", val)
            LocalPlayer:SetAttribute("S_MobileSensitivity", val)
        end)
    end,
})

MoveTab:Slider({
    Title     = "Shoulder Distance Horizontal (X)",
    Desc      = "Adjusts your over-the-shoulder camera horizontal distance for superior combat field visibility.",
    Step      = 0.25,
    Value     = { Min = 1, Max = 5, Default = 1.75 },
    IsTooltip = true,
    Callback  = function(val)
        shiftlockOffsetX = val
        pcall(function()
            LocalPlayer:SetAttribute("S_ShiftlockX", val)
        end)
    end,
})

MoveTab:Slider({
    Title     = "Shoulder Distance Vertical (Y)",
    Desc      = "Adjusts your over-the-shoulder camera elevation angle.",
    Step      = 0.25,
    Value     = { Min = -2, Max = 3, Default = 0 },
    IsTooltip = true,
    Callback  = function(val)
        shiftlockOffsetY = val
        pcall(function()
            LocalPlayer:SetAttribute("S_ShiftlockY", val)
        end)
    end,
})

MoveTab:Space()

MoveTab:Toggle({
    Title    = "Custom WalkSpeed",
    Desc     = "Overrides default movement speed with dynamic frame-by-frame enforcement.",
    Value    = false,
    Callback = function(state)
        customSpeedEnabled = state
        if not state and Humanoid then
            Humanoid.WalkSpeed = 16
        end
    end,
})

MoveTab:Slider({
    Title     = "WalkSpeed Slider",
    Step      = 1,
    Value     = { Min = 16, Max = 150, Default = 16 },
    IsTooltip = true,
    Callback  = function(val)
        customWalkSpeed = val
    end,
})

MoveTab:Space()

MoveTab:Toggle({
    Title    = "Custom JumpPower",
    Desc     = "Overrides default vertical jump height.",
    Value    = false,
    Callback = function(state)
        customJumpEnabled = state
        if not state and Humanoid then
            Humanoid.JumpPower = 50
        end
    end,
})

MoveTab:Slider({
    Title     = "JumpPower Slider",
    Step      = 1,
    Value     = { Min = 50, Max = 250, Default = 50 },
    IsTooltip = true,
    Callback  = function(val)
        customJumpPower = val
    end,
})

RunService.RenderStepped:Connect(function()
    if Humanoid then
        if customSpeedEnabled then
            Humanoid.WalkSpeed = customWalkSpeed
        end
        if customJumpEnabled then
            Humanoid.UseJumpPower = true
            Humanoid.JumpPower = customJumpPower
        end
    end
end)

MoveTab:Space()
MoveTab:Section({ Title = "Bypasses & Boundaries" })

MoveTab:Toggle({
    Title    = "NoClip",
    Desc     = "Disables limb collisions on stepped cycles, allowing character movement through map geometry.",
    Value    = false,
    Callback = function(state)
        noclip = state
        if noclip then
            noclipConn = RunService.Stepped:Connect(function()
                if Character and noclip then
                    for _, part in ipairs(Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConn then
                noclipConn:Disconnect()
                noclipConn = nil
            end
        end
    end,
})

MoveTab:Toggle({
    Title    = "Anti-Void Safezone",
    Desc     = "Monitors falling depth and catches your character above void boundaries, safely returning you to the map.",
    Value    = false,
    Callback = function(state)
        antiVoid = state
        if antiVoid then
            task.spawn(function()
                while antiVoid do
                    if RootPart and RootPart.Position.Y < -50 then
                        RootPart.AssemblyLinearVelocity = Vector3.zero
                        RootPart.CFrame = CFrame.new(0, 50, 0)
                        Notify("Louis Hub", "Anti-Void activated: Repositioned to safety!", 3)
                    end
                    task.wait(0.2)
                end
            end)
        end
    end,
})

-- ========================================================
-- TAB 3: VISUALS
-- ========================================================
local VisualsTab = Window:Tab({
    Title  = "Visuals",
    Icon   = "solar:eye-bold",
    Desc   = "Threat awareness, radar, and post-FX clarity",
    Border = true,
})

VisualsTab:Section({ Title = "Threat Awareness" })

VisualsTab:Toggle({
    Title    = "Incoming Threat Radar",
    Desc     = "Alerts you instantly whenever an enemy throws an object or projectile in your direction.",
    Value    = false,
    Callback = function(state)
        threatRadar = state
        local thrown = workspace:FindFirstChild("Thrown")
        if threatRadar and thrown then
            threatRadarConn = thrown.ChildAdded:Connect(function(child)
                if not threatRadar then return end
                task.wait(0.05)
                if child and RootPart then
                    local childPos = child:IsA("BasePart") and child.Position or (child:IsA("Model") and child:GetPivot().Position)
                    if childPos then
                        local dist = math.floor((RootPart.Position - childPos).Magnitude)
                        if dist <= 120 then
                            Notify("Threat Radar", "Incoming projectile detected (" .. dist .. " studs)!", 2, "solar:danger-triangle-bold")
                        end
                    end
                end
            end)
        else
            if threatRadarConn then
                threatRadarConn:Disconnect()
                threatRadarConn = nil
            end
        end
    end,
})

VisualsTab:Space()
VisualsTab:Section({ Title = "Camera & Clarity" })

VisualsTab:Toggle({
    Title    = "Distortion Wave Neutralizer",
    Desc     = "Disables expanding 3D air distortion spheres during high-impact clashes to maintain sharp visual clarity and smooth frame rates.",
    Value    = false,
    Callback = function(state)
        distortionNeutralizer = state
        local thrown = workspace:FindFirstChild("Thrown")
        if distortionNeutralizer and thrown then
            distortionConn = thrown.ChildAdded:Connect(function(child)
                if not distortionNeutralizer then return end
                if child.Name == "DistortionMesh" or child.Name:find("Distort") then
                    if child:IsA("BasePart") then
                        child.Transparency = 1
                    end
                end
            end)
        else
            if distortionConn then
                distortionConn:Disconnect()
                distortionConn = nil
            end
        end
    end,
})

VisualsTab:Toggle({
    Title    = "Anti-Fisheye (FOV Stabilizer)",
    Desc     = "Locks your camera's field of view to prevent sudden extreme zooms and fisheye distortions during ultimate awakening moves.",
    Value    = false,
    Callback = function(state)
        antiFisheye = state
        if antiFisheye then
            antiFisheyeConn = RunService.RenderStepped:Connect(function()
                if Camera then
                    Camera.FieldOfView = lockedFOV
                end
            end)
            Notify("Louis Hub", "Anti-Fisheye active: FOV locked to " .. lockedFOV, 3)
        else
            if antiFisheyeConn then
                antiFisheyeConn:Disconnect()
                antiFisheyeConn = nil
            end
        end
    end,
})

VisualsTab:Slider({
    Title     = "Target Static FOV",
    Desc      = "Preferred field of view to lock",
    Step      = 1,
    Value     = { Min = 60, Max = 110, Default = 70 },
    IsTooltip = true,
    Callback  = function(val)
        lockedFOV = val
    end,
})

VisualsTab:Dropdown({
    Title    = "Custom Shift-Lock Reticle",
    Desc     = "Customizes your central shift-lock targeting reticle directly through native overlay settings.",
    Values   = { "Default Crosshair", "Minimal Dot", "Precision Diamond" },
    Value    = "Default Crosshair",
    Callback = function(val)
        pcall(function()
            if val == "Minimal Dot" then
                LocalPlayer:SetAttribute("S_ShiftlockSkin", "rbxassetid://132438947521974")
            elseif val == "Precision Diamond" then
                LocalPlayer:SetAttribute("S_ShiftlockSkin", "rbxassetid://6031094678")
            else
                LocalPlayer:SetAttribute("S_ShiftlockSkin", "")
            end
        end)
    end,
})

VisualsTab:Toggle({
    Title    = "Screen Stabilizer",
    Desc     = "Completely removes camera shake during huge impacts and ultimate moves, keeping your crosshair steady.",
    Value    = false,
    Callback = function(state)
        screenStabilizer = state
        if screenStabilizer then
            _G.ServerRunning = false
            Notify("Louis Hub", "Screen Stabilizer active: Shakes neutralized!", 3)
        else
            _G.ServerRunning = true
        end
    end,
})

VisualsTab:Toggle({
    Title    = "Clear Vision (Anti-Smoke)",
    Desc     = "Filters out thick dust and smoke clouds so you can clearly track your opponent during intense clashes.",
    Value    = false,
    Callback = function(state)
        clearVision = state
        if clearVision then
            clearVisionConn = workspace.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("ParticleEmitter") then
                    local name = descendant.Name:lower()
                    if name:find("smoke") or name:find("dust") then
                        descendant.Enabled = false
                    end
                end
            end)
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") then
                    local name = v.Name:lower()
                    if name:find("smoke") or name:find("dust") then
                        v.Enabled = false
                    end
                end
            end
        else
            if clearVisionConn then
                clearVisionConn:Disconnect()
                clearVisionConn = nil
            end
        end
    end,
})

VisualsTab:Toggle({
    Title    = "Anti-Flashbang (Post-FX Cleaner)",
    Desc     = "Removes sudden white flashes, heavy blur, and blinding screen color changes during awakening transformations and ultimate moves.",
    Value    = false,
    Callback = function(state)
        antiFlashbang = state
        if antiFlashbang then
            antiFlashConn = Lighting.ChildAdded:Connect(function(child)
                if child:IsA("ColorCorrectionEffect") or child:IsA("BlurEffect") or child:IsA("BloomEffect") then
                    child.Enabled = false
                end
            end)
            for _, fx in ipairs(Lighting:GetChildren()) do
                if fx:IsA("ColorCorrectionEffect") or fx:IsA("BlurEffect") or fx:IsA("BloomEffect") then
                    fx.Enabled = false
                end
            end
            if Camera then
                for _, fx in ipairs(Camera:GetChildren()) do
                    if fx:IsA("ColorCorrectionEffect") or fx:IsA("BlurEffect") or fx:IsA("BloomEffect") then
                        fx.Enabled = false
                    end
                end
            end
            Notify("Louis Hub", "Anti-Flashbang enabled: Post-effects cleaned!", 3)
        else
            if antiFlashConn then
                antiFlashConn:Disconnect()
                antiFlashConn = nil
            end
        end
    end,
})

VisualsTab:Toggle({
    Title    = "Disable Impact Frames",
    Desc     = "Removes jarring black-and-white screen flash overlays during heavy hits to reduce eye fatigue and keep your vision clear.",
    Value    = false,
    Callback = function(state)
        disableImpactFrames = state
        local pGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if disableImpactFrames and pGui then
            impactFramesConn = pGui.ChildAdded:Connect(function(child)
                if child.Name == "CMVFXImpactFramesGui" then
                    child.Enabled = false
                end
            end)
            local existing = pGui:FindFirstChild("CMVFXImpactFramesGui")
            if existing then
                existing.Enabled = false
            end
        else
            if impactFramesConn then
                impactFramesConn:Disconnect()
                impactFramesConn = nil
            end
        end
    end,
})

VisualsTab:Toggle({
    Title    = "Anti-Cinematic Lock (Free Cam)",
    Desc     = "Maintains full 360-degree camera freedom even while trapped in enemy cinematic ultimate moves, keeping you aware of your surroundings.",
    Value    = false,
    Callback = function(state)
        antiCinematicLock = state
        if antiCinematicLock then
            antiCinematicConn = RunService.RenderStepped:Connect(function()
                if Camera and Camera.CameraType == Enum.CameraType.Scriptable then
                    Camera.CameraType = Enum.CameraType.Custom
                    if Humanoid then
                        Camera.CameraSubject = Humanoid
                    end
                end
            end)
        else
            if antiCinematicConn then
                antiCinematicConn:Disconnect()
                antiCinematicConn = nil
            end
        end
    end,
})

VisualsTab:Space()
VisualsTab:Section({ Title = "Player Tracking & Status" })

VisualsTab:Toggle({
    Title    = "Player Device & Latency Radar",
    Desc     = "Displays enemy device type (PC, Mobile, Console), exact real-time ping in milliseconds, and competitive rank above their head.",
    Value    = false,
    Callback = function(state)
        playerTelemetryRadar = state
        if playerTelemetryRadar then
            task.spawn(function()
                while playerTelemetryRadar do
                    for _, enemy in ipairs(Players:GetPlayers()) do
                        if enemy ~= LocalPlayer and enemy.Character then
                            local head = enemy.Character:FindFirstChild("Head")
                            if head then
                                local bb = enemy.Character:FindFirstChild("TelemetryBillboard")
                                if not bb then
                                    bb = Instance.new("BillboardGui")
                                    bb.Name = "TelemetryBillboard"
                                    bb.Size = UDim2.fromOffset(140, 20)
                                    bb.StudsOffset = Vector3.new(0, 5.8, 0)
                                    bb.AlwaysOnTop = true
                                    bb.Parent = enemy.Character

                                    local txt = Instance.new("TextLabel")
                                    txt.Size = UDim2.fromScale(1, 1)
                                    txt.BackgroundTransparency = 1
                                    txt.Font = Enum.Font.GothamBold
                                    txt.TextSize = 11
                                    txt.TextColor3 = Color3.fromHex("#38BDF8")
                                    txt.Parent = bb
                                end
                                local device = enemy:GetAttribute("Console") and "CONSOLE" or (enemy:GetAttribute("Mobile") and "MOBILE" or "PC")
                                local ping = math.ceil(enemy:GetAttribute("Ping") or 0)
                                local label = bb:FindFirstChildOfClass("TextLabel")
                                if label then
                                    label.Text = string.format("[%s] %dms", device, ping)
                                    if ping > 120 then
                                        label.TextColor3 = Color3.fromHex("#EF4444")
                                    elseif ping > 70 then
                                        label.TextColor3 = Color3.fromHex("#F59E0B")
                                    else
                                        label.TextColor3 = Color3.fromHex("#10B981")
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.4)
                end
            end)
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("TelemetryBillboard") then
                    p.Character.TelemetryBillboard:Destroy()
                end
            end
        end
    end,
})

VisualsTab:Toggle({
    Title    = "Enemy Awakening Meter ESP",
    Desc     = "Displays numeric percentage bars above opponents' heads showing their exact Awakening / Ultimate gauge progression.",
    Value    = false,
    Callback = function(state)
        enemyAwakeningESP = state
        if enemyAwakeningESP then
            task.spawn(function()
                while enemyAwakeningESP do
                    for _, enemy in ipairs(Players:GetPlayers()) do
                        if enemy ~= LocalPlayer and enemy.Character then
                            local head = enemy.Character:FindFirstChild("Head")
                            if head then
                                local bb = enemy.Character:FindFirstChild("EnemyAwakeningBillboard")
                                if not bb then
                                    bb = Instance.new("BillboardGui")
                                    bb.Name = "EnemyAwakeningBillboard"
                                    bb.Size = UDim2.fromOffset(100, 20)
                                    bb.StudsOffset = Vector3.new(0, 4.5, 0)
                                    bb.AlwaysOnTop = true
                                    bb.Parent = enemy.Character

                                    local txt = Instance.new("TextLabel")
                                    txt.Size = UDim2.fromScale(1, 1)
                                    txt.BackgroundTransparency = 1
                                    txt.Font = Enum.Font.GothamBold
                                    txt.TextSize = 13
                                    txt.Parent = bb
                                end
                                local ultPercent = math.floor(enemy:GetAttribute("Ultimate") or 0)
                                local txt = bb:FindFirstChildOfClass("TextLabel")
                                if txt then
                                    txt.Text = "Awakening: " .. ultPercent .. "%"
                                    txt.TextColor3 = ultPercent >= 100 and Color3.fromHex("#FF0055") or Color3.fromHex("#FFCC00")
                                end
                            end
                        end
                    end
                    task.wait(0.2)
                end
            end)
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("EnemyAwakeningBillboard") then
                    p.Character.EnemyAwakeningBillboard:Destroy()
                end
            end
        end
    end,
})

VisualsTab:Toggle({
    Title    = "Persistent Health Monitor",
    Desc     = "Keeps your health and opponent health meters visible at all times with numeric percentage overlays so you are never surprised by lethal damage.",
    Value    = false,
    Callback = function(state)
        persistentHealth = state
        pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, persistentHealth)
        end)
    end,
})

local function applyESP(player)
    if player == LocalPlayer then return end

    local function createHighlight(char)
        if not char then return end
        local highlight = char:FindFirstChild("LouisHub_ESP")
        if not highlight then
            highlight = Instance.new("Highlight")
            highlight.Name = "LouisHub_ESP"
            highlight.FillColor = Color3.fromHex("#FF3366")
            highlight.OutlineColor = Color3.fromHex("#FFFFFF")
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = char
            table.insert(espHighlights, highlight)
        end
    end

    if player.Character then
        createHighlight(player.Character)
    end
    player.CharacterAdded:Connect(createHighlight)
end

local function removeESP()
    for _, h in ipairs(espHighlights) do
        if h and h.Parent then
            h:Destroy()
        end
    end
    espHighlights = {}
end

VisualsTab:Toggle({
    Title    = "Player Highlight ESP",
    Desc     = "Highlights all opponents through walls with high-visibility player chams.",
    Value    = false,
    Callback = function(state)
        espEnabled = state
        if espEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                applyESP(p)
            end
            Players.PlayerAdded:Connect(function(p)
                if espEnabled then applyESP(p) end
            end)
        else
            removeESP()
        end
    end,
})

-- ========================================================
-- TAB 4: MISCELLANEOUS & PERFORMANCE
-- ========================================================
local MiscTab = Window:Tab({
    Title  = "Miscellaneous",
    Icon   = "solar:tuning-bold",
    Desc   = "Memory purgers, visual culling, and server tools",
    Border = true,
})

MiscTab:Section({ Title = "Staff & Safety Protections" })

MiscTab:Toggle({
    Title    = "Staff & Admin Safety Radar",
    Desc     = "Alerts you instantly or safely rejoins another server if a verified game developer, staff member, or QA tester enters your match.",
    Value    = false,
    Callback = function(state)
        staffSafetyRadar = state
        if staffSafetyRadar then
            local function checkPlayer(p)
                local role = StaffDirectory[p.UserId]
                if role then
                    Notify("Safety Warning", string.format("Verified %s [%s] detected in server!", role, p.DisplayName), 5, "solar:danger-triangle-bold")
                    if autoLeaveOnStaff then
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end
                end
            end

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then checkPlayer(p) end
            end
            staffRadarConn = Players.PlayerAdded:Connect(checkPlayer)
        else
            if staffRadarConn then
                staffRadarConn:Disconnect()
                staffRadarConn = nil
            end
        end
    end,
})

MiscTab:Toggle({
    Title    = "Auto-Rejoin on Staff Detection",
    Desc     = "Automatically rejoins a fresh server instance if staff enters to keep your account safe.",
    Value    = false,
    Callback = function(state)
        autoLeaveOnStaff = state
    end,
})

MiscTab:Space()
MiscTab:Section({ Title = "Performance Booster" })

MiscTab:Toggle({
    Title    = "SmartBone Cloth Optimizer",
    Desc     = "Disables background cape, hair, and cloth bone simulations on other players to drastically reduce CPU lag in crowded lobbies.",
    Value    = false,
    Callback = function(state)
        smartBoneOptimizer = state
        if smartBoneOptimizer then
            for _, part in ipairs(CollectionService:GetTagged("SmartBone")) do
                if part:IsDescendantOf(workspace) and not (Character and part:IsDescendantOf(Character)) then
                    part:SetAttribute("UpdateRate", 0)
                end
            end
            Notify("Louis Hub", "SmartBone Optimizer active: Cloth CPU cycles trimmed!", 3)
        end
    end,
})

MiscTab:Toggle({
    Title    = "Mesh Animation Culler",
    Desc     = "Freezes animated slash and wind mesh flipbooks that occur outside your camera view to preserve maximum rendering performance.",
    Value    = false,
    Callback = function(state)
        meshCulling = state
        shared.cull = shared.cull or {}
        shared.cull.work = function(pos)
            if not meshCulling then return true end
            if not Camera or not pos then return true end
            local _, onScreen = Camera:WorldToViewportPoint(pos)
            return onScreen
        end
        if meshCulling then
            Notify("Louis Hub", "Mesh Culler active: Offscreen flipbooks suppressed!", 3)
        end
    end,
})

MiscTab:Toggle({
    Title    = "Smart VFX Culling",
    Desc     = "Stops rendering complex visual effects happening behind your back or off-screen to significantly boost your FPS during massive team fights.",
    Value    = false,
    Callback = function(state)
        smartVfxCulling = state
        if smartVfxCulling then
            smartCullConn = RunService.Heartbeat:Connect(function()
                local thrown = workspace:FindFirstChild("Thrown")
                if thrown and Camera then
                    for _, child in ipairs(thrown:GetChildren()) do
                        local pos = child:IsA("BasePart") and child.Position or (child:IsA("Model") and child:GetPivot().Position)
                        if pos then
                            local _, onScreen = Camera:WorldToViewportPoint(pos)
                            if not onScreen then
                                for _, emitter in ipairs(child:GetDescendants()) do
                                    if emitter:IsA("ParticleEmitter") then
                                        emitter.Enabled = false
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            Notify("Louis Hub", "Smart VFX Culling activated!", 3)
        else
            if smartCullConn then
                smartCullConn:Disconnect()
                smartCullConn = nil
            end
        end
    end,
})

MiscTab:Toggle({
    Title    = "Shockwave Ring Neutralizer",
    Desc     = "Disables massive expanding shockwave rings and distortion waves during clashes, keeping the center of your screen clean and your framerate steady.",
    Value    = false,
    Callback = function(state)
        shockwaveNeutralizer = state
        if shockwaveNeutralizer then
            shockwaveConn = workspace.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("BasePart") and descendant.Parent and descendant.Parent.Name == "Rings" then
                    descendant.Transparency = 1
                    for _, em in ipairs(descendant:GetDescendants()) do
                        if em:IsA("ParticleEmitter") then
                            em.Enabled = false
                        end
                    end
                end
            end)
        else
            if shockwaveConn then
                shockwaveConn:Disconnect()
                shockwaveConn = nil
            end
        end
    end,
})

MiscTab:Button({
    Title    = "Debris Memory Cleaner",
    Desc     = "Clears accumulated rubble data to eliminate micro-stutters and frame drops during massive building destruction.",
    Icon     = "solar:trash-bin-trash-bold",
    Callback = function()
        pcall(function()
            local count = 0
            local thrown = workspace:FindFirstChild("Thrown")
            if thrown then
                for _, part in ipairs(thrown:GetChildren()) do
                    part:Destroy()
                    count = count + 1
                end
            end
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.CollisionGroup == "debricol" or obj:GetAttribute("VoxelDebris")) then
                    obj:Destroy()
                    count = count + 1
                end
            end
            Notify("Louis Hub", "Debris Cleaner: Purged " .. count .. " rubble instances!", 3)
        end)
    end,
})

MiscTab:Button({
    Title    = "Boost FPS / Global Clean",
    Desc     = "Disables heavy world textures, particle emitters, and global shadow calculations for maximum performance on low-end devices.",
    Icon     = "solar:zap-bold",
    Callback = function()
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            settings().Rendering.QualityLevel = 1
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsA("MeshPart") then
                    v.Material = Enum.Material.SmoothPlastic
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") then
                    v.Enabled = false
                end
            end
            Notify("Louis Hub", "Global Clean applied: Textures and particle loads minimized!", 3)
        end)
    end,
})

MiscTab:Space()
MiscTab:Section({ Title = "Server & Menu Actions" })

MiscTab:Toggle({
    Title    = "Force Enable Reset Character",
    Desc     = "Forces the Escape menu's Reset Character option to remain enabled, allowing you to respawn freely if stuck in bugged ragdoll states.",
    Value    = false,
    Callback = function(state)
        forceResetEnabled = state
        if forceResetEnabled then
            forceResetThread = task.spawn(function()
                while forceResetEnabled do
                    pcall(function()
                        StarterGui:SetCore("ResetButtonCallback", true)
                    end)
                    task.wait(1)
                end
            end)
            Notify("Louis Hub", "Reset Character option unlocked!", 3)
        else
            if forceResetThread then
                task.cancel(forceResetThread)
                forceResetThread = nil
            end
        end
    end,
})

MiscTab:Button({
    Title    = "Rejoin Server",
    Desc     = "Instantly reconnects your client to the current battlegrounds server instance.",
    Icon     = "solar:refresh-bold",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,
})

-- ========================================================
-- TAB 5: SETTINGS & PROFILES
-- ========================================================
if not RunService:IsStudio() and writefile then
    local ConfigTab = Window:Tab({
        Title  = "Settings",
        Icon   = "solar:settings-bold",
        Desc   = "Save and load custom profile configurations",
        Border = true,
    })

    local ConfigManager = Window.ConfigManager
    local ConfigName = "default"

    local ConfigNameInput = ConfigTab:Input({
        Title       = "Configuration Profile Name",
        Placeholder = "default",
        Callback    = function(val)
            ConfigName = val
        end,
    })

    ConfigTab:Space()

    local AllConfigs = ConfigManager:AllConfigs()
    local ConfigDropdown = ConfigTab:Dropdown({
        Title    = "Saved Profiles",
        Values   = AllConfigs,
        Value    = table.find(AllConfigs, ConfigName) and ConfigName or nil,
        Callback = function(val)
            ConfigName = val
            ConfigNameInput:Set(val)
        end,
    })

    ConfigTab:Space()

    ConfigTab:Button({
        Title    = "Save Current Profile",
        Icon     = "solar:diskette-bold",
        Callback = function()
            Window.CurrentConfig = ConfigManager:Config(ConfigName)
            if Window.CurrentConfig:Save() then
                Notify("Louis Hub", "Profile '" .. ConfigName .. "' saved successfully!", 3)
            end
            ConfigDropdown:Refresh(ConfigManager:AllConfigs())
        end,
    })

    ConfigTab:Button({
        Title    = "Load Selected Profile",
        Icon     = "solar:folder-open-bold",
        Callback = function()
            Window.CurrentConfig = ConfigManager:CreateConfig(ConfigName)
            if Window.CurrentConfig:Load() then
                Notify("Louis Hub", "Profile '" .. ConfigName .. "' loaded successfully!", 3)
            end
        end,
    })
end

Notify("Louis Hub", "The Strongest Battlegrounds Ultimate Suite initialized!", 4)
