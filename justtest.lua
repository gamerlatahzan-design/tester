-- ========================================================
--  LOUIS HUB - MUSCLE LEGENDS (PRO MASTER SUITE)
--  Engine: Obsidian UI Library | 100% Full English Interface
--  Zero-Damage Sweet Spots | Clean Combat | Full Architecture
--  Dedicated Custom Overlays | Full Enchantment Suite
-- ========================================================

-- ========================================================
-- SERVICES & LOCAL PLAYER
-- ========================================================
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local UserInputService  = game:GetService("UserInputService")
local Lighting          = game:GetService("Lighting")
local VirtualUser       = game:GetService("VirtualUser")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
	LocalPlayer = Players.LocalPlayer
	task.wait()
end
local playerGui = LocalPlayer:WaitForChild("PlayerGui", 15) or LocalPlayer:FindFirstChildOfClass("PlayerGui")

-- ========================================================
-- OBSIDIAN UI LIBRARY LOADER
-- ========================================================
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = nil
local okLib, resLib = pcall(function()
	return loadstring(game:HttpGet(repo .. "Library.lua", true))()
end)

if okLib and resLib then
	Library = resLib
else
	warn("[Louis Hub] Failed to load Obsidian UI Library!")
	return
end

local Options = Library.Options
local Toggles = Library.Toggles

local function Notify(title, text)
	pcall(function()
		if Library and Library.Notify then
			Library:Notify(string.format("[%s] %s", title, text), 4)
		end
	end)
end

-- ========================================================
-- HELPER FUNCTIONS & NETWORK WRAPPERS
-- ========================================================
local function formatAbbrev(n)
	n = tonumber(n) or 0
	if n >= 1e15 then return string.format("%.2fQ", n / 1e15)
	elseif n >= 1e12 then return string.format("%.2fT", n / 1e12)
	elseif n >= 1e9  then return string.format("%.2fB", n / 1e9)
	elseif n >= 1e6  then return string.format("%.2fM", n / 1e6)
	elseif n >= 1e3  then return string.format("%.2fK", n / 1e3)
	else return tostring(n) end
end

local function safeTouch(part1, part2, toggle)
	if firetouchinterest and part1 and part2 then
		pcall(function()
			firetouchinterest(part1, part2, toggle)
		end)
	end
end

local function fireMuscleEvent(...)
	local mEvent = LocalPlayer:FindFirstChild("muscleEvent") or ReplicatedStorage:FindFirstChild("muscleEvent")
	if mEvent and mEvent:IsA("RemoteEvent") then
		local args = {...}
		pcall(function()
			mEvent:FireServer(unpack(args))
		end)
	end
end

local function invokeRebirth()
	local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
	local remote = rEvents and rEvents:FindFirstChild("rebirthRemote")
	if remote then
		pcall(function()
			remote:InvokeServer("rebirthRequest")
		end)
	end
end

local function changePlayerSize(size)
	local rEvents = ReplicatedStorage:FindFirstChild("rEvents")
	local remote = rEvents and rEvents:FindFirstChild("changeSpeedSizeRemote")
	if remote then
		pcall(function()
			remote:InvokeServer("changeSize", size)
		end)
	end
end

local function makeDraggable(topbarObject, object)
	if not topbarObject or not object then return end
	local dragging = false
	local dragInput, dragStart, startPos

	topbarObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = object.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	topbarObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			object.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- ========================================================
-- STATE FLAGS & CONFIGURATION
-- ========================================================
local autoStrength = false
local repSpeedMode = "Normal Rep"
local fastPunch = false
local autoRebirth = false
local autoRebirthStay = false
local autoFood = false
local autoEggs = false
local farmMuscleKing = false
local autoRock = false
local autoTrainMachine = false

local fastRebirthActive = false
local selectedRebirthMode = "Fast Rebirth"
local selectedRebirthPet = "Common Boss Pet"
local maxRebirths = 999999999

local selectedTool = "Weight"
local selectedWorkoutStation = "Starter Gym - Bench Press"
local selectedRock = "Tiny Rock"
local selectedMKTool = "Weight"

local killAllPlayers = false
local autoTargetPlayer = false
local autoFarmKarma = false
local antiRagdoll = false
local autoDodge = false
local autoJoinBrawl = false
local lastDodgeTime = 0
local killMethod = "Teleport Inside Target"
local selectedTargetPlayer = ""
local selectedKarmaMode = "Good Karma"
local killAuraRadius = 30

local autoFarmBoss = false
local autoDodgeStomp = true
local autoClaimChest = true
local tagAndReturnEnabled = false
local show2DBossBar = true
local muteBossMedia = true
local autoResetSize = true
local isTaggingInProgress = false
local preTagWorkoutCFrame = nil

local bossDistanceOffset = 46.5
local bossOverrideActive = false
local preBossWorkoutCFrame = nil
local bossArenaCFrame = nil
local bossActiveDetected = false
local currentTargetBossPart = nil
local currentTargetBossModel = nil
local bossFollowConnection = nil

local sessionDamageDealt = 0
local liveCalculatedDPS = 0
local recentDamageWindows = {}
local rainbowBuffEndTime = 0
local bossMobilityStatus = "Stationary"

local showStatsHUD = false
local showBossHUD = false

local isFastGacha2x = false
local isFastGacha5x = false
local isFastGacha15x = false
local gachaSpeed = 0.05
local petWhitelist = {}
local auraWhitelist = {}
local lockedOldItems = {}
local isAutoEvolve = false
local shopItemsList = {}
local shopItemNames = {}
local selectedShopItemKey = ""
local autoBuyShopPet = false

local autoEnchantPet = false
local fastEnchant = true
local autoClaimFreeSpin = false
local protectEnchantedPets = true
local selectedEnchantPetKey = ""
local selectedTargetEnchant = "Any"
local selectedTargetTier = "Tier I (Any Tier)"
local enchantSpinsCount = 0
local freeSpinReadyTimestamp = 0
local cachedEnchantPetMap = {}
local cachedEnchantPetNames = {}

local selectedTiersToSell = { ["Basic"] = true }
local autoSellByTier = false
local autoSellNonWhitelistedPets = false
local autoSellNonWhitelistedAuras = false

local walkOnWater = false
local waterWalkPart = nil
local noclip = false
local dndActive = false
local dndConnection = nil
local isLocked = false
local hidePopups = false
local popupAddedConnection = nil

-- Top-level UI Label References (Prevents nil call errors)
local bossRadarStatusLabel = nil
local bossLiveHealthLabel = nil
local bossMobilityLabel = nil
local bossTimerLabel = nil
local bossDespawnTimerLabel = nil
local damageAnalyticsLabel = nil
local lootScalingLabel = nil
local rainbowBuffLabel = nil

local enchantSpinsLabel = nil
local freeSpinTimerLabel = nil
local currentPetEnchantStatusLabel = nil

-- Protected Items Directory
local protectedBossItems = {
	["Common Aura"] = true, ["Rare Aura"] = true, ["Epic Aura"] = true, ["Legendary Aura"] = true,
	["Mythic Aura"] = true, ["Rainbow Aura"] = true, ["Concrete Barbell"] = true, ["Gem Treadmill"] = true,
	["Purple Pullups"] = true, ["Golden Barbell"] = true, ["Lava Treadmill"] = true, ["Crystal Dumbbell"] = true,
	["Common Boss Pet"] = true, ["Rare Boss Pet"] = true, ["Epic Boss Pet"] = true, ["Legendary Boss Pet"] = true,
	["Mythic Boss Pet"] = true, ["Rainbow Boss Pet"] = true, ["Rainbow Golem"] = true
}

local allCrystals = {
	"Industrial Crystal", "Jungle Crystal", "Galaxy Oracle Crystal", "Muscle Elite Crystal",
	"Legends Crystal", "Inferno Crystal", "Mythical Crystal", "Frost Crystal", "Green Crystal", "Blue Crystal"
}

local masterPetList = {
	"Apex Overlord", "Titan Reactor", "Plasma Ravager", "Reactor Beast", "Volt Talon", "Core Pup",
	"Neon Guardian", "Muscle Sensei", "Golden Viking", "Darkstar Hunter", "Lighting Strike Phantom",
	"Eternal Strike Leviathan", "Cybernetic Showdown Dragon", "Aether Spirit Bunny", "Ultimate Supernova Pegasus",
	"Dark Legends Manticore", "Phantom Genesis Dragon", "Frostwave Legends Penguin", "Ultra Birdie",
	"Magic Butterfly", "White Pheonix", "Green Firecaster", "Infernal Dragon", "Golden Pheonix",
	"White Pegasus", "Red Firecaster", "Blue Firecaster", "Purple Falcon", "Red Dragon",
	"Blue Pheonix", "Orange Pegasus", "Purple Dragon", "Yellow Butterfly", "Crimson Falcon",
	"Green Butterfly", "Dark Golem", "Silver Dog", "Dark Vampy", "Blue Bunny", "Red Kitty",
	"Blue Birdie", "Orange Hedgehog"
}

local masterAuraList = {
	"Entropic Blast Aura", "Eternal Megastrike Aura", "Grand SuperNova Aura",
	"Muscle King Aura", "Azure Tundra Aura", "Ultra Inferno Aura",
	"Unique Aura", "Epic Aura", "Rare Aura", "Advanced Aura", "Basic Aura"
}

local petTiersList = { "Basic", "Advanced", "Rare", "Epic", "Unique" }

local chestDataOrdered = {
	{ Name = "Golden Chest", RemoteName = "Golden Chest", Pos = CFrame.new(-137.273956, 14.9224882, -273.372284) },
	{ Name = "Frost Chest", RemoteName = "Enchanted Chest", Pos = CFrame.new(-2572.9082, 14.9224863, -556.064514) },
	{ Name = "Mythic Chest", RemoteName = "Mythical Chest", Pos = CFrame.new(2210.25635, 14.9224873, 915.522278) },
	{ Name = "Eternal Chest", RemoteName = "Magma Chest", Pos = CFrame.new(-6724.78076, 14.9224873, -1466.87891) },
	{ Name = "Legends Chest", RemoteName = "Legends Chest", Pos = CFrame.new(4660.6084, 1008.64093, -3691.42407) },
	{ Name = "Jungle Chest", RemoteName = "Jungle Chest", Pos = CFrame.new(-7904.46777, 11.8928919, 3023.01318) },
	{ Name = "Industrial Chest", RemoteName = "Industrial Chest", Pos = CFrame.new(-4745.36865, 65.5666656, 5590.00732) }
}

local allGymWorkoutsList = {
	"Starter Gym - Bench Press", "Starter Gym - Pullup Bar", "Starter Gym - Treadmill",
	"Frost Gym - Bench Press", "Frost Gym - Squat", "Frost Gym - Pullup Bar", "Frost Gym - Treadmill",
	"Mythic Gym - Bench Press", "Mythic Gym - Pullup Bar", "Mythic Gym - Squat", "Mythic Gym - Treadmill",
	"Eternal Gym - Bench Press", "Eternal Gym - Deadlift", "Eternal Gym - Squat", "Eternal Gym - Treadmill",
	"Legends Gym - Bench Press", "Legends Gym - Pullup Bar", "Legends Gym - Squat", "Legends Gym - Treadmill",
	"Muscle King - Throne Area", "Jungle Gym - Bench Press", "Jungle Gym - Pullup Bar", "Jungle Gym - Squat",
	"Jungle Gym - Deadlift", "Jungle Gym - Treadmill", "Industrial Gym - Bench Press", "Industrial Gym - Deadlift",
	"Industrial Gym - Squat", "Industrial Gym - Pullup Bar", "Industrial Gym - Treadmill"
}

local rockList = {
	"Tiny Rock", "Punching Rock", "Frozen Rock", "Inferno Rock",
	"Rock Of Legends", "Muscle King Mountain", "Ancient Jungle Rock", "Industrial Rock"
}

local enchantTypeList = {
	"Any", "Ferocity (Damage Multiplier)", "Might (+Strength%)", "Fortitude (+Durability%)",
	"Swiftness (+Agility%)", "Juggernaut (+Str & Dur%)", "Frenzy (+Str & Agi%)", "Endurance (+Dur & Agi%)"
}

local enchantTierTargetList = {
	"Tier I (Any Tier)", "Tier II or Higher", "Tier III or Higher", "Tier IV Only (Godly 0.5%)"
}

local gymLocations = {
	["1. Golden Gym (Legend Beach)"] = CFrame.new(-137.273956, 14.9224882, -273.372284),
	["2. Frost Gym"]                 = CFrame.new(-2572.9082, 14.9224863, -556.064514),
	["3. Mythic Gym"]                = CFrame.new(2210.25635, 14.9224873, 915.522278),
	["4. Eternal Gym"]               = CFrame.new(-6724.78076, 14.9224873, -1466.87891),
	["5. Legends Gym"]               = CFrame.new(4660.6084, 1008.64093, -3691.42407),
	["6. Jungle Gym"]                = CFrame.new(-7904.46777, 11.8928919, 3023.01318),
	["7. Industrial Gym"]            = CFrame.new(-4745.36865, 65.5666656, 5590.00732),
	["Pet Enchant Machine"]          = CFrame.new(-22.428, 14.885, -282.164),
	["Tiny Island"]                  = CFrame.new(-4.25301933, 220.993713, 1963.60168),
	["Muscle King"]                  = CFrame.new(-8762.23438, 24.8225193, -5714.77148)
}

local brawlLocations = {
	["Brawl Arena 1"] = CFrame.new(985.910645, 163.795364, -7037.80615),
	["Brawl Arena 2"] = CFrame.new(4466.75342, 334.973602, -8425.74512),
	["Brawl Arena 3"] = CFrame.new(-1901.87695, 251.895432, -5899.64795)
}

local activeCodes = {
	"bossstrike", "bossguard", "BossStrike", "BossGuard",
	"junglegym500", "epicmuscle20", "mightygems2500", "ultimate250",
	"spacegems50", "megalift50", "speedy50", "EpicReward500",
	"MillionWarriors", "FrostGems10", "Musclestorm50", "SkyAgility50",
	"GalaxyCrystal50", "SuperMuscle100", "SuperPunch100", "Launch250", "Momentum", " Enchantment"
}

local selectedCrystal = allCrystals[1]
local currentSelectedPet = masterPetList[1]
local currentSelectedAura = masterAuraList[1]
local currentSelectedSellPet = masterPetList[1]
local currentSelectedSellAura = masterAuraList[1]
local selectedInspectPlayer = ""

-- ========================================================
-- CORE REUSABLE FUNCTIONS
-- ========================================================
local function getPlayerKarma(player)
	if not player then return 0, 0 end
	local evil, good = 0, 0
	pcall(function()
		if player:FindFirstChild("evilKarma") then evil = tonumber(player.evilKarma.Value) or evil end
		if player:FindFirstChild("goodKarma") then good = tonumber(player.goodKarma.Value) or good end
		local ls = player:FindFirstChild("leaderstats")
		if ls then
			if ls:FindFirstChild("Evil Karma") then evil = tonumber(ls["Evil Karma"].Value) or evil end
			if ls:FindFirstChild("Good Karma") then good = tonumber(ls["Good Karma"].Value) or good end
		end
		evil = tonumber(player:GetAttribute("evilKarma")) or evil
		good = tonumber(player:GetAttribute("goodKarma")) or good
	end)
	return evil, good
end

local function getFullStats(target)
	if not target then return nil end
	local str, reb, dur, agi, gems, kills = 0, 0, 0, 0, 0, 0
	local evil, good = getPlayerKarma(target)
	local size = 1
	local totalPets = 0

	pcall(function()
		local ls = target:FindFirstChild("leaderstats")
		str = (ls and ls:FindFirstChild("Strength") and ls.Strength.Value) or (target:FindFirstChild("strength") and target.strength.Value) or 0
		reb = (ls and ls:FindFirstChild("Rebirths") and ls.Rebirths.Value) or (ls and ls:FindFirstChild("Rebirth") and ls.Rebirth.Value) or (target:FindFirstChild("rebirths") and target.rebirths.Value) or 0
		dur = (ls and ls:FindFirstChild("Durability") and ls.Durability.Value) or (target:FindFirstChild("durability") and target.durability.Value) or 0
		agi = (ls and ls:FindFirstChild("Agility") and ls.Agility.Value) or (target:FindFirstChild("agility") and target.agility.Value) or 0
		gems = (ls and ls:FindFirstChild("Gems") and ls.Gems.Value) or (target:FindFirstChild("gems") and target.gems.Value) or 0
		kills = (ls and ls:FindFirstChild("Kills") and ls.Kills.Value) or (ls and ls:FindFirstChild("Brawls") and ls.Brawls.Value) or 0
		size = (target:FindFirstChild("customSize") and target.customSize.Value) or (target:FindFirstChild("muscleSize") and target.muscleSize.Value) or 1

		local petsFolder = target:FindFirstChild("petsFolder")
		if petsFolder then
			for _, cat in pairs(petsFolder:GetChildren()) do
				totalPets = totalPets + #cat:GetChildren()
			end
		end
	end)

	return {
		Strength = str, Durability = dur, Agility = agi, Rebirths = reb,
		Gems = gems, Kills = kills, GoodKarma = good, EvilKarma = evil,
		Size = size, TotalPets = totalPets
	}
end

local function isServerBossActive()
	local active = false
	pcall(function()
		active = workspace:GetAttribute("BossActive") == true
		local hp = workspace:GetAttribute("BossHealth")
		active = active and (not hp or hp > 0)
	end)
	return active
end

local function getPlayerList()
	local list = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			table.insert(list, p.Name)
		end
	end
	if #list == 0 then table.insert(list, "No other players") end
	return list
end

-- ========================================================
-- CUSTOM HUD 1 & 2 (STATS & RAID BOSS OVERLAYS)
-- ========================================================
local statsScreenGui = Instance.new("ScreenGui")
statsScreenGui.Name = "LouisHub_CharacterStatsHUD"
statsScreenGui.ResetOnSpawn = false
statsScreenGui.DisplayOrder = 9999
statsScreenGui.Enabled = false
if playerGui then statsScreenGui.Parent = playerGui end

local statsMainFrame = Instance.new("Frame")
statsMainFrame.Name = "StatsMainFrame"
statsMainFrame.Size = UDim2.new(0, 240, 0, 280)
statsMainFrame.Position = UDim2.new(0.02, 0, 0.32, 0)
statsMainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
statsMainFrame.BackgroundTransparency = 0.7
statsMainFrame.BorderSizePixel = 0
statsMainFrame.Active = true
statsMainFrame.Parent = statsScreenGui

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 14)
statsCorner.Parent = statsMainFrame

local statsStroke = Instance.new("UIStroke")
statsStroke.Color = Color3.fromRGB(255, 255, 255)
statsStroke.Thickness = 1.5
statsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
statsStroke.Parent = statsMainFrame

local statsHeader = Instance.new("TextLabel")
statsHeader.Name = "Header"
statsHeader.Size = UDim2.new(1, 0, 0, 32)
statsHeader.BackgroundTransparency = 1
statsHeader.Text = "CHARACTER STATS"
statsHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
statsHeader.Font = Enum.Font.GothamBold
statsHeader.TextSize = 13
statsHeader.Parent = statsMainFrame

local statsDivider = Instance.new("Frame")
statsDivider.Name = "Divider"
statsDivider.Size = UDim2.new(0.9, 0, 0, 1)
statsDivider.Position = UDim2.new(0.05, 0, 0, 32)
statsDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
statsDivider.BackgroundTransparency = 0.5
statsDivider.BorderSizePixel = 0
statsDivider.Parent = statsMainFrame

local statsListContainer = Instance.new("Frame")
statsListContainer.Name = "ListContainer"
statsListContainer.Size = UDim2.new(1, -24, 1, -44)
statsListContainer.Position = UDim2.new(0, 12, 0, 38)
statsListContainer.BackgroundTransparency = 1
statsListContainer.Parent = statsMainFrame

local statsLayout = Instance.new("UIListLayout")
statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
statsLayout.Padding = UDim.new(0, 4)
statsLayout.Parent = statsListContainer

local hudStatLabels = {}
local statFields = { "Strength", "Durability", "Agility", "Rebirths", "Gems", "Brawls / Kills", "Karma Alignment", "Muscle Size", "Total Pets" }
for idx, name in ipairs(statFields) do
	local lbl = Instance.new("TextLabel")
	lbl.Name = name:gsub("%s+", "") .. "Label"
	lbl.Size = UDim2.new(1, 0, 0, 21)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 11.5
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = string.format("• %s: Loading...", name)
	lbl.LayoutOrder = idx
	lbl.Parent = statsListContainer
	hudStatLabels[name] = lbl
end
makeDraggable(statsHeader, statsMainFrame)

-- RAID BOSS MONITOR HUD
local bossScreenGui = Instance.new("ScreenGui")
bossScreenGui.Name = "LouisHub_RaidBossMonitorHUD"
bossScreenGui.ResetOnSpawn = false
bossScreenGui.DisplayOrder = 9999
bossScreenGui.Enabled = false
if playerGui then bossScreenGui.Parent = playerGui end

local bossMainFrame = Instance.new("Frame")
bossMainFrame.Name = "BossMainFrame"
bossMainFrame.Size = UDim2.new(0, 260, 0, 175)
bossMainFrame.Position = UDim2.new(0.5, -130, 0.05, 0)
bossMainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bossMainFrame.BackgroundTransparency = 0.7
bossMainFrame.BorderSizePixel = 0
bossMainFrame.Active = true
bossMainFrame.Parent = bossScreenGui

local bossCorner = Instance.new("UICorner")
bossCorner.CornerRadius = UDim.new(0, 14)
bossCorner.Parent = bossMainFrame

local bossStroke = Instance.new("UIStroke")
bossStroke.Color = Color3.fromRGB(255, 255, 255)
bossStroke.Thickness = 1.5
bossStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
bossStroke.Parent = bossMainFrame

local bossHeader = Instance.new("TextLabel")
bossHeader.Name = "Header"
bossHeader.Size = UDim2.new(1, 0, 0, 30)
bossHeader.BackgroundTransparency = 1
bossHeader.Text = "RAID BOSS RADAR"
bossHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
bossHeader.Font = Enum.Font.GothamBold
bossHeader.TextSize = 13
bossHeader.Parent = bossMainFrame

local bossDivider = Instance.new("Frame")
bossDivider.Name = "Divider"
bossDivider.Size = UDim2.new(0.9, 0, 0, 1)
bossDivider.Position = UDim2.new(0.05, 0, 0, 30)
bossDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
bossDivider.BackgroundTransparency = 0.5
bossDivider.BorderSizePixel = 0
bossDivider.Parent = bossMainFrame

local bossStatusTag = Instance.new("TextLabel")
bossStatusTag.Name = "StatusTag"
bossStatusTag.Size = UDim2.new(1, -20, 0, 26)
bossStatusTag.Position = UDim2.new(0, 10, 0, 36)
bossStatusTag.BackgroundTransparency = 1
bossStatusTag.Text = "WAITING BOSS..."
bossStatusTag.TextColor3 = Color3.fromRGB(255, 225, 75)
bossStatusTag.Font = Enum.Font.GothamBold
bossStatusTag.TextSize = 14
bossStatusTag.Parent = bossMainFrame

local bossLine1 = Instance.new("TextLabel")
bossLine1.Name = "Line1"
bossLine1.Size = UDim2.new(1, -20, 0, 20)
bossLine1.Position = UDim2.new(0, 10, 0, 68)
bossLine1.BackgroundTransparency = 1
bossLine1.Text = "Next Boss in: Calculating..."
bossLine1.TextColor3 = Color3.fromRGB(240, 240, 240)
bossLine1.Font = Enum.Font.GothamMedium
bossLine1.TextSize = 11.5
bossLine1.TextXAlignment = Enum.TextXAlignment.Center
bossLine1.Parent = bossMainFrame

local bossLine2 = Instance.new("TextLabel")
bossLine2.Name = "Line2"
bossLine2.Size = UDim2.new(1, -20, 0, 20)
bossLine2.Position = UDim2.new(0, 10, 0, 94)
bossLine2.BackgroundTransparency = 1
bossLine2.Text = "DPS: 0 | Total Damage: 0"
bossLine2.TextColor3 = Color3.fromRGB(240, 240, 240)
bossLine2.Font = Enum.Font.GothamMedium
bossLine2.TextSize = 11.5
bossLine2.TextXAlignment = Enum.TextXAlignment.Center
bossLine2.Parent = bossMainFrame

local bossLine3 = Instance.new("TextLabel")
bossLine3.Name = "Line3"
bossLine3.Size = UDim2.new(1, -20, 0, 20)
bossLine3.Position = UDim2.new(0, 10, 0, 120)
bossLine3.BackgroundTransparency = 1
bossLine3.Text = "Time Left: Standby"
bossLine3.TextColor3 = Color3.fromRGB(180, 180, 180)
bossLine3.Font = Enum.Font.GothamMedium
bossLine3.TextSize = 11
bossLine3.TextXAlignment = Enum.TextXAlignment.Center
bossLine3.Parent = bossMainFrame
makeDraggable(bossHeader, bossMainFrame)

-- Background Live HUD Loop
task.spawn(function()
	while true do
		if showStatsHUD then
			local s = getFullStats(LocalPlayer)
			if s then
				pcall(function()
					hudStatLabels["Strength"].Text = string.format("• Strength: %s", formatAbbrev(s.Strength))
					hudStatLabels["Durability"].Text = string.format("• Durability: %s", formatAbbrev(s.Durability))
					hudStatLabels["Agility"].Text = string.format("• Agility: %s", formatAbbrev(s.Agility))
					hudStatLabels["Rebirths"].Text = string.format("• Rebirths: %s", formatAbbrev(s.Rebirths))
					hudStatLabels["Gems"].Text = string.format("• Gems: %s", formatAbbrev(s.Gems))
					hudStatLabels["Brawls / Kills"].Text = string.format("• Kills: %s", formatAbbrev(s.Kills))

					local karmaMode = "Neutral"
					if s.GoodKarma > s.EvilKarma then
						karmaMode = string.format("Good (+%s)", formatAbbrev(s.GoodKarma))
					elseif s.EvilKarma > s.GoodKarma then
						karmaMode = string.format("Evil (+%s)", formatAbbrev(s.EvilKarma))
					end
					hudStatLabels["Karma Alignment"].Text = string.format("• Karma: %s", karmaMode)
					hudStatLabels["Muscle Size"].Text = string.format("• Muscle Size: %s", tostring(s.Size))
					hudStatLabels["Total Pets"].Text = string.format("• Total Pets: %d", s.TotalPets)
				end)
			end
		end

		if showBossHUD then
			local isAlive = isServerBossActive()
			local serverTime = workspace:GetServerTimeNow()

			if isAlive then
				bossStatusTag.Text = "FIGHT WITH BOSS"
				bossStatusTag.TextColor3 = Color3.fromRGB(50, 255, 120)

				local directBossHealth = (currentTargetBossModel and currentTargetBossModel:GetAttribute("Health"))
					or workspace:GetAttribute("BossHealth")
				local wsMaxHealth = workspace:GetAttribute("BossMaxHealth")

				if typeof(directBossHealth) == "number" and typeof(wsMaxHealth) == "number" and wsMaxHealth > 0 then
					local pct = math.clamp(math.floor((directBossHealth / wsMaxHealth) * 100), 0, 100)
					bossLine1.Text = string.format("HP: %s / %s (%d%%)", formatAbbrev(directBossHealth), formatAbbrev(wsMaxHealth), pct)
				else
					bossLine1.Text = "HP: Scanning..."
				end

				bossLine2.Text = string.format("DPS: %s | DMG Dealt: %s", formatAbbrev(liveCalculatedDPS), formatAbbrev(sessionDamageDealt))

				local defeatTimestamp = workspace:GetAttribute("BossDefeatTime")
				if typeof(defeatTimestamp) == "number" and defeatTimestamp > serverTime then
					local remDefeat = math.max(0, math.floor(defeatTimestamp - serverTime))
					bossLine3.Text = string.format("Battle Ends In: %02d:%02d", math.floor(remDefeat / 60), remDefeat % 60)
				else
					bossLine3.Text = "Mobility: " .. tostring(bossMobilityStatus)
				end
			else
				bossStatusTag.Text = "WAITING BOSS..."
				bossStatusTag.TextColor3 = Color3.fromRGB(255, 215, 60)

				local nextSpawn = workspace:GetAttribute("BossSpawnNextTime")
					or ReplicatedStorage:GetAttribute("BossSpawnNextTime")

				if nextSpawn and nextSpawn > serverTime then
					local rem = math.max(0, math.floor(nextSpawn - serverTime))
					bossLine1.Text = string.format("Next Boss in: %02d:%02d", math.floor(rem / 60), rem % 60)
				else
					bossLine1.Text = "Next Boss in: Spawning Imminently..."
				end

				bossLine2.Text = string.format("DPS: 0 | Last Session: %s", formatAbbrev(sessionDamageDealt))
				bossLine3.Text = "Status: Arena Clear"
			end
		end

		task.wait(0.5)
	end
end)

-- Background Boss In-Menu Telemetry Loop (Safe Execution)
task.spawn(function()
	while true do
		local isAlive = isServerBossActive()
		local nextSpawn = workspace:GetAttribute("BossSpawnNextTime") or ReplicatedStorage:GetAttribute("BossSpawnNextTime")
		local serverTime = workspace:GetServerTimeNow()

		if bossTimerLabel then
			if nextSpawn and nextSpawn > serverTime then
				local rem = math.max(0, math.floor(nextSpawn - serverTime))
				bossTimerLabel:SetText(string.format("Next Boss in: %02d:%02d", math.floor(rem / 60), rem % 60))
			else
				bossTimerLabel:SetText("Next Boss in: Active / Imminent")
			end
		end

		if bossDespawnTimerLabel then
			local defeatTimestamp = workspace:GetAttribute("BossDefeatTime")
			if typeof(defeatTimestamp) == "number" and defeatTimestamp > serverTime then
				local remDefeat = math.max(0, math.floor(defeatTimestamp - serverTime))
				bossDespawnTimerLabel:SetText(string.format("Time Left: %02d:%02d:%02d", math.floor(remDefeat / 3600), math.floor((remDefeat % 3600) / 60), remDefeat % 60))
			else
				bossDespawnTimerLabel:SetText("Time Left: Standby")
			end
		end

		if lootScalingLabel then
			local rebirths = 0
			local ls = LocalPlayer:FindFirstChild("leaderstats")
			if ls and ls:FindFirstChild("Rebirths") then rebirths = tonumber(ls.Rebirths.Value) or 0 end
			local steps = math.min(math.floor(rebirths / 5000), 8)
			lootScalingLabel:SetText(string.format("Rebirth Loot Bonus: +%d%% Gems, +%d Items", steps * 25, math.min(math.floor(rebirths / 5000), 5)))
		end

		if rainbowBuffLabel then
			if rainbowBuffEndTime > os.clock() then
				local remB = math.floor(rainbowBuffEndTime - os.clock())
				rainbowBuffLabel:SetText(string.format("Rainbow Buff: %02d:%02d Active", math.floor(remB / 60), remB % 60))
			else
				rainbowBuffLabel:SetText("Rainbow Buff: Inactive")
			end
		end

		if bossRadarStatusLabel and bossLiveHealthLabel and bossMobilityLabel and damageAnalyticsLabel then
			local directBossHealth = (currentTargetBossModel and currentTargetBossModel:GetAttribute("Health")) or workspace:GetAttribute("BossHealth")
			local wsMaxHealth = workspace:GetAttribute("BossMaxHealth")

			if isAlive and typeof(directBossHealth) == "number" and typeof(wsMaxHealth) == "number" and wsMaxHealth > 0 then
				local dName = workspace:GetAttribute("BossDisplayName") or "Raid Boss"
				local rName = workspace:GetAttribute("BossRarityName") or "Boss"
				local pct = math.clamp(math.floor((directBossHealth / wsMaxHealth) * 100), 0, 100)
				bossRadarStatusLabel:SetText("Boss Status: [ACTIVE] " .. dName .. " (" .. rName .. ")")
				bossLiveHealthLabel:SetText(string.format("Boss Health: %s / %s (%d%%)", formatAbbrev(directBossHealth), formatAbbrev(wsMaxHealth), pct))
				bossMobilityLabel:SetText("Boss Movement: " .. tostring(bossMobilityStatus))
				damageAnalyticsLabel:SetText(string.format("Damage: %s | DPS: %s", formatAbbrev(sessionDamageDealt), formatAbbrev(liveCalculatedDPS)))
			else
				bossRadarStatusLabel:SetText("Boss Status: [DORMANT] Clear")
				bossLiveHealthLabel:SetText("Boss Health: Dormant")
				bossMobilityLabel:SetText("Boss Movement: Dormant")
				damageAnalyticsLabel:SetText("Damage Dealt: Standby")
			end
		end

		if show2DBossBar then
			local pGui = LocalPlayer:FindFirstChild("PlayerGui")
			local bGui = pGui and pGui:FindFirstChild("BossScreenGui")
			local bBar = bGui and bGui:FindFirstChild("BossHealthBar")
			if bBar and not bBar.Visible and isAlive then bBar.Visible = true end
		end

		if muteBossMedia then
			local pGui = LocalPlayer:FindFirstChild("PlayerGui")
			if pGui then
				local notice = pGui:FindFirstChild("bossSpawnNotificationRuntime")
				if notice then notice:Destroy() end
			end
		end

		task.wait(1)
	end
end)

-- Background Enchantment In-Menu Telemetry Loop (Safe Execution)
task.spawn(function()
	while true do
		local enchantRemote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("petEnchantRemote")
		if enchantRemote then
			pcall(function()
				local res = enchantRemote:InvokeServer("getState")
				if type(res) == "table" and res.State then
					if res.State.Spins ~= nil then enchantSpinsCount = tonumber(res.State.Spins) or 0 end
					if res.State.FreeSpinRemaining ~= nil then freeSpinReadyTimestamp = os.clock() + (tonumber(res.State.FreeSpinRemaining) or 0) end
				end
			end)
		end

		if enchantSpinsLabel then
			enchantSpinsLabel:SetText(string.format("Available Spins: %d Spins", enchantSpinsCount))
		end

		if freeSpinTimerLabel then
			local rem = math.max(0, math.floor(freeSpinReadyTimestamp - os.clock()))
			if rem <= 0 then
				freeSpinTimerLabel:SetText("Daily Free Spin: [READY TO CLAIM]")
			else
				freeSpinTimerLabel:SetText(string.format("Daily Free Spin In: %02d:%02d:%02d", math.floor(rem / 3600), math.floor((rem % 3600) / 60), rem % 60))
			end
		end

		if currentPetEnchantStatusLabel then
			local targetPet = cachedEnchantPetMap[selectedEnchantPetKey]
			if targetPet and targetPet.Parent then
				local eName, eTier = getPetEnchantInfo(targetPet)
				local rMap = { [1] = "Tier I", [2] = "Tier II", [3] = "Tier III", [4] = "Tier IV (MAX)" }
				currentPetEnchantStatusLabel:SetText(string.format("Current: %s • %s [%s]", targetPet.Name, eName, rMap[eTier] or "No Enchant"))
			else
				currentPetEnchantStatusLabel:SetText("Selected Pet Status: Select a pet below")
			end
		end

		task.wait(1.5)
	end
end)

-- ========================================================
-- PROMPT & INTERACT HANDLER
-- ========================================================
local lastPromptClickTime = 0
local function autoConfirmPrompts()
	if os.clock() - lastPromptClickTime < 0.25 then return end
	local pGui = LocalPlayer:FindFirstChild("PlayerGui")
	if not pGui then return end

	for _, btn in ipairs(pGui:GetDescendants()) do
		if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
			local name = btn.Name:lower()
			local txt = (btn:IsA("TextButton") and btn.Text:lower()) or ""
			if txt == "yes" or txt:find("yes") or txt:find("confirm") or txt:find("claim") or txt == "ok" or name:find("confirm") or name:find("claim") then
				lastPromptClickTime = os.clock()
				pcall(function()
					if firesignal then
						firesignal(btn.MouseButton1Click)
						firesignal(btn.Activated)
					end
				end)
				break
			end
		end
	end
end

-- ========================================================
-- HIDE STAT POPUPS ELEMENT LISTENER
-- ========================================================
local function hidePopupElement(v)
	if not hidePopups then return end
	if v:IsA("BillboardGui") then
		v.Enabled = false
	elseif v:IsA("TextLabel") or v:IsA("ImageLabel") or v:IsA("Frame") then
		local txt = (v:IsA("TextLabel") and v.Text:lower()) or ""
		local n = v.Name:lower()
		if txt:find("%+") or txt:find("strength") or txt:find("agility") or txt:find("durability") or n:find("gain") or n:find("popup") or n:find("stat") then
			v.Visible = false
			if v.Parent and v.Parent:IsA("Frame") then
				v.Parent.Visible = false
			elseif v.Parent and v.Parent:IsA("BillboardGui") then
				v.Parent.Enabled = false
			end
		end
	end
end

-- ========================================================
-- SHOP & ENCHANTMENT HELPERS
-- ========================================================
local function getShopItemName(item)
	if not item then return "Unknown" end
	local name = item.Name
	local petNameVal = item:FindFirstChild("petName") or item:FindFirstChild("Pet") or item:FindFirstChild("Name")
	if petNameVal and petNameVal:IsA("ValueBase") then name = tostring(petNameVal.Value) end
	if item:GetAttribute("petName") then name = tostring(item:GetAttribute("petName")) end
	return name
end

local function getShopItemCost(item)
	if not item then return "N/A" end
	local costVal = item:FindFirstChild("cost") or item:FindFirstChild("price") or item:FindFirstChild("gems") or item:FindFirstChild("Gems")
	if costVal and costVal:IsA("ValueBase") then return formatAbbrev(costVal.Value) .. " Gems" end
	if item:GetAttribute("cost") then return formatAbbrev(item:GetAttribute("cost")) .. " Gems" end
	return "Free / N/A"
end

local function refreshShopData()
	shopItemsList = {}
	shopItemNames = {}
	local shopFolder = ReplicatedStorage:FindFirstChild("shared")
		and ReplicatedStorage.shared:FindFirstChild("runtime")
		and ReplicatedStorage.shared.runtime:FindFirstChild("cPetShopFolder")

	if shopFolder then
		for i, item in ipairs(shopFolder:GetChildren()) do
			local dispName = getShopItemName(item)
			local costStr = getShopItemCost(item)
			local key = string.format("[%d] %s (%s)", i, dispName, costStr)
			shopItemsList[key] = item
			table.insert(shopItemNames, key)
		end
	end
	if #shopItemNames == 0 then table.insert(shopItemNames, "No Stock Listed") end
	selectedShopItemKey = shopItemNames[1]
end
pcall(refreshShopData)

local function getPetEnchantInfo(pet)
	if not pet or not pet.Parent then return "None", 0 end
	local eName = "None"
	local eTier = 0
	pcall(function()
		eName = pet:GetAttribute("Enchant") or (pet:FindFirstChild("Enchant") and pet.Enchant.Value) or "None"
		eTier = pet:GetAttribute("EnchantTier") or (pet:FindFirstChild("EnchantTier") and pet.EnchantTier.Value) or 0
	end)
	return tostring(eName), tonumber(eTier) or 0
end

local function getEnchantMachineInstance()
	for _, obj in ipairs(CollectionService:GetTagged("PetEnchant")) do
		if obj:IsA("Model") or obj:IsA("BasePart") then return obj end
	end
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and (obj.Name == "PetEnchant" or obj.Name == "PetEnchantMachine") then
			return obj
		elseif obj:IsA("ProximityPrompt") and obj.Name == "petEnchantPrompt" and obj.Parent then
			return obj.Parent:IsA("Model") and obj.Parent or obj.Parent
		end
	end
	return nil
end

local function getEnchantMachineCFrame()
	local machine = getEnchantMachineInstance()
	if machine then
		if machine:IsA("Model") then
			return machine.PrimaryPart and machine.PrimaryPart.CFrame or machine:GetPivot()
		elseif machine:IsA("BasePart") then
			return machine.CFrame
		end
	end
	return CFrame.new(-22.428, 14.885, -282.164)
end

local function refreshEnchantPetsList()
	cachedEnchantPetMap = {}
	cachedEnchantPetNames = {}
	local petsFolder = LocalPlayer:FindFirstChild("petsFolder")
	local romanTiers = { [1] = "I", [2] = "II", [3] = "III", [4] = "IV" }

	if petsFolder then
		local index = 1
		for _, category in ipairs(petsFolder:GetChildren()) do
			for _, pet in ipairs(category:GetChildren()) do
				local eName, eTier = getPetEnchantInfo(pet)
				local tierStr = romanTiers[eTier] or "None"
				local key = string.format("[%d] %s • %s %s", index, pet.Name, eName, tierStr)
				cachedEnchantPetMap[key] = pet
				table.insert(cachedEnchantPetNames, key)
				index = index + 1
			end
		end
	end
	if #cachedEnchantPetNames == 0 then table.insert(cachedEnchantPetNames, "No Pets Available") end
	selectedEnchantPetKey = cachedEnchantPetNames[1]
end
pcall(refreshEnchantPetsList)

local function triggerMachineInteraction()
	pcall(function()
		local VIM = game:GetService("VirtualInputManager")
		VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
		task.wait(0.04)
		VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
	end)
	pcall(function()
		local pGui = LocalPlayer:FindFirstChild("PlayerGui")
		if pGui then
			for _, v in ipairs(pGui:GetDescendants()) do
				if (v:IsA("ImageButton") or v:IsA("TextButton")) and v.Visible then
					local name = v.Name:lower()
					local text = (v:IsA("TextButton") and v.Text:lower()) or ""
					if name:find("interact") or name:find("machine") or name:find("use") or text == "e" or text:find("interact") then
						if firesignal then
							firesignal(v.MouseButton1Click)
							firesignal(v.Activated)
						end
					end
				end
			end
		end
	end)
end

local function equipPunchTool()
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	local character = LocalPlayer.Character
	if character then
		local punchTool = character:FindFirstChild("Punch") or (backpack and backpack:FindFirstChild("Punch"))
		if punchTool and punchTool.Parent ~= character then punchTool.Parent = character end
		return punchTool
	end
	return nil
end

local function attackPlayerReal(target, method)
	if not target or not target.Character then return end
	local myChar = LocalPlayer.Character
	if not myChar then return end

	local myHrp = myChar:FindFirstChild("HumanoidRootPart")
	local targetHrp = target.Character:FindFirstChild("HumanoidRootPart") or target.Character:FindFirstChild("Torso") or target.Character:FindFirstChild("UpperTorso")
	local targetHum = target.Character:FindFirstChild("Humanoid")

	if not myHrp or not targetHrp or not targetHum or targetHum.Health <= 0 or target.Character:FindFirstChildOfClass("ForceField") then
		return
	end

	local punchTool = equipPunchTool()
	if punchTool then punchTool:Activate() end

	if method == "Teleport Inside Target" then
		myHrp.CFrame = targetHrp.CFrame
	elseif method == "Teleport Behind" then
		myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 2.5)
	end

	local rHand = myChar:FindFirstChild("RightHand") or myChar:FindFirstChild("Right Arm")
	local lHand = myChar:FindFirstChild("LeftHand") or myChar:FindFirstChild("Left Arm")

	safeTouch(rHand, targetHrp, 0)
	safeTouch(rHand, targetHrp, 1)
	safeTouch(lHand, targetHrp, 0)
	safeTouch(lHand, targetHrp, 1)

	fireMuscleEvent("punch", "rightHand")
	fireMuscleEvent("punch", "leftHand")
end

local function getArenaLocation()
	if bossArenaCFrame then return bossArenaCFrame end
	for _, spawn in ipairs(CollectionService:GetTagged("BossArenaSpawn")) do
		if spawn:IsA("BasePart") then bossArenaCFrame = spawn.CFrame * CFrame.new(0, 8, 0) return bossArenaCFrame end
	end
	for _, base in ipairs(CollectionService:GetTagged("BossArenaBase")) do
		if base:IsA("BasePart") then bossArenaCFrame = base.CFrame * CFrame.new(0, 15, 0) return bossArenaCFrame end
	end
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and (obj.Name == "BossArenaSpawn" or obj.Name == "BossArenaBase") then
			bossArenaCFrame = obj.CFrame * CFrame.new(0, 10, 0) return bossArenaCFrame
		end
	end
	return bossArenaCFrame
end

local function findPhysicalBossModel()
	local tagged = CollectionService:GetTagged("BossEventBoss")
	for _, model in ipairs(tagged) do
		if model:IsA("Model") and not Players:GetPlayerFromCharacter(model) and not Players:FindFirstChild(model.Name) then
			if not model:GetAttribute("BossDeathPhase") then
				local hitbox = model:FindFirstChild("BossDamageHitbox") or model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
				if hitbox and hitbox:IsA("BasePart") then return model, hitbox end
			end
		end
	end
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) and not Players:FindFirstChild(obj.Name) then
			local n = obj.Name:lower()
			if (n:find("boss") or n:find("golem") or n:find("monster")) and not (n:find("arena") or n:find("gate") or n:find("door") or n:find("spawn") or n:find("board")) then
				if not obj:GetAttribute("BossDeathPhase") then
					local hitbox = obj:FindFirstChild("BossDamageHitbox") or obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
					if hitbox and hitbox:IsA("BasePart") then return obj, hitbox end
				end
			end
		end
	end
	return nil, nil
end

local lastAnnouncedChest = nil
local function autoClaimBossChest()
	local chests = CollectionService:GetTagged("BossEventChest")
	if #chests == 0 then
		for _, obj in ipairs(workspace:GetChildren()) do
			if obj:IsA("Model") and obj.Name:find("Chest") and obj.Name:find("Rig") then
				table.insert(chests, obj)
			end
		end
	end

	for _, chest in ipairs(chests) do
		local rIndex = chest:GetAttribute("BossRarityIndex")
		if rIndex and chest ~= lastAnnouncedChest then
			lastAnnouncedChest = chest
			local rNames = { [1]="Common", [2]="Rare", [3]="Epic", [4]="Legendary", [5]="Mythic", [6]="Rainbow" }
			Notify("Chest Found!", string.format("[%s Chest] has spawned in the arena!", rNames[rIndex] or "Boss"))
		end

		if not chest:GetAttribute("BossChestEmerging") then
			local prompt = chest:FindFirstChild("bossChestPrompt", true) or chest:FindFirstChildWhichIsA("ProximityPrompt", true)
			if prompt and prompt.Enabled then
				local promptPart = prompt.Parent
				local myChar = LocalPlayer.Character
				local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
				if myHrp and promptPart and promptPart:IsA("BasePart") then
					myHrp.CFrame = promptPart.CFrame * CFrame.new(0, 3, 0)
					task.wait(0.15)
					prompt.HoldDuration = 0
					if fireproximityprompt then pcall(function() fireproximityprompt(prompt, 0) end) end
					return true
				end
			end
		end
	end
	return false
end

-- ========================================================
-- OBSIDIAN WINDOW CREATION
-- ========================================================
local Window = Library:CreateWindow({
	Title = "Louis Hub",
	Footer = "Muscle Legends (Obsidian Master Suite)",
	Icon = 82795327169782,
	NotifySide = "Right",
	ShowCustomCursor = false
})

local Tabs = {
	Farming     = Window:AddTab('Farming'),
	Combat      = Window:AddTab('Combat'),
	Boss        = Window:AddTab('Raid Boss'),
	Companions  = Window:AddTab('Companions'),
	Enchantment = Window:AddTab('Enchantment'),
	Liquidate   = Window:AddTab('Liquidate'),
	Telemetry   = Window:AddTab('Telemetry'),
	Spoils      = Window:AddTab('Spoils'),
	Utility     = Window:AddTab('Utility'),
	Navigation  = Window:AddTab('Navigation'),
	['UI Settings'] = Window:AddTab('UI Settings')
}

-- ========================================================
-- TAB 1: FARMING
-- ========================================================
local RepBox = Tabs.Farming:AddLeftGroupbox('Rep Training')
RepBox:AddDropdown('TrainingToolDropdown', {
	Values = {"Weight", "Pushups", "Situps", "Handstands"},
	Default = 1,
	Multi = false,
	Text = 'Training Tool',
	Callback = function(v) selectedTool = v end
})

RepBox:AddDropdown('RepSpeedModeDropdown', {
	Values = {"Normal Rep", "Fast Rep", "Ultra Rep"},
	Default = 1,
	Multi = false,
	Text = 'Rep Speed Mode',
	Callback = function(v) repSpeedMode = v end
})

RepBox:AddToggle('AutoStrengthToggle', {
	Text = 'Auto Strength',
	Default = false,
	Tooltip = 'Automatically trains reps with chosen equipment',
	Callback = function(v)
		autoStrength = v
		if autoStrength then
			task.spawn(function()
				while autoStrength do
					if not bossOverrideActive then
						fireMuscleEvent("rep")
						if repSpeedMode == "Ultra Rep" then fireMuscleEvent("rep") end
						local backpack = LocalPlayer:FindFirstChild("Backpack")
						local character = LocalPlayer.Character
						if backpack and character and selectedTool then
							local tool = backpack:FindFirstChild(selectedTool)
							if tool and tool.Parent ~= character then tool.Parent = character end
						end
					end
					if repSpeedMode == "Ultra Rep" then task.wait(0.02)
					elseif repSpeedMode == "Fast Rep" then task.wait(0.08)
					else task.wait(0.45) end
				end
			end)
		end
	end
})

local GymBox = Tabs.Farming:AddLeftGroupbox('Gym Machines')
GymBox:AddDropdown('WorkoutStationDropdown', {
	Values = allGymWorkoutsList,
	Default = 1,
	Multi = false,
	Text = 'Select Workout Station',
	Callback = function(v) selectedWorkoutStation = v end
})

GymBox:AddToggle('AutoTrainMachineToggle', {
	Text = 'Auto Train Machine',
	Default = false,
	Tooltip = 'Teleports to station, enters machine safely, and trains',
	Callback = function(v)
		autoTrainMachine = v
		if autoTrainMachine then
			task.spawn(function()
				local isSeatedOnMachine = false
				local lastStationTarget = ""
				while autoTrainMachine do
					if not bossOverrideActive then
						local myChar = LocalPlayer.Character
						local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
						local myHum = myChar and myChar:FindFirstChild("Humanoid")

						if lastStationTarget ~= selectedWorkoutStation then
							lastStationTarget = selectedWorkoutStation
							isSeatedOnMachine = false
							if myHum then myHum.Sit = false end
							task.wait(0.2)
						end

						isSeatedOnMachine = myHum and myHum.Sit
						if not isSeatedOnMachine then
							local rawMachineName = selectedWorkoutStation:gsub(".* %- ", "")
							local targetMachine = nil
							local mFolder = workspace:FindFirstChild("machinesFolder")
							if mFolder then
								for _, m in ipairs(mFolder:GetChildren()) do
									if m.Name:lower():find(rawMachineName:lower()) or rawMachineName:lower():find(m.Name:lower()) then
										targetMachine = m break
									end
								end
							end
							if not targetMachine then
								for _, m in ipairs(workspace:GetDescendants()) do
									if m:IsA("Model") and (m.Name:lower() == rawMachineName:lower() or m.Name:lower():find(rawMachineName:lower())) then
										targetMachine = m break
									end
								end
							end
							if targetMachine and myHrp then
								local interactPart = targetMachine.PrimaryPart or targetMachine:FindFirstChildWhichIsA("BasePart")
								if interactPart then
									myHrp.CFrame = interactPart.CFrame * CFrame.new(0, 2, 0)
									task.wait(0.15)
									triggerMachineInteraction()
									task.wait(0.25)
								end
							end
						else
							fireMuscleEvent("rep")
							if repSpeedMode == "Ultra Rep" then fireMuscleEvent("rep") end
						end
					end
					if repSpeedMode == "Ultra Rep" then task.wait(0.02)
					elseif repSpeedMode == "Fast Rep" then task.wait(0.08)
					else task.wait(0.4) end
				end
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
					LocalPlayer.Character.Humanoid.Sit = false
				end
			end)
		else
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
				LocalPlayer.Character.Humanoid.Sit = false
			end
		end
	end
})

local RockBox = Tabs.Farming:AddLeftGroupbox('Rock Training')
RockBox:AddDropdown('RockDropdown', {
	Values = rockList,
	Default = 1,
	Multi = false,
	Text = 'Select Rock',
	Callback = function(v) selectedRock = v end
})

RockBox:AddToggle('AutoPunchRockToggle', {
	Text = 'Auto Punch Rock',
	Default = false,
	Tooltip = 'Dual-fist rock puncher for durability',
	Callback = function(v)
		autoRock = v
		if autoRock then
			task.spawn(function()
				while autoRock do
					if not bossOverrideActive then
						local char = LocalPlayer.Character
						local target = workspace:FindFirstChild("machinesFolder") and workspace.machinesFolder:FindFirstChild(selectedRock)
						local rockPart = target and (target:FindFirstChild("Rock") or target:FindFirstChildWhichIsA("BasePart"))
						if rockPart then
							local punchTool = equipPunchTool()
							if punchTool then punchTool:Activate() end
							local rightHand = char and (char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm"))
							local leftHand  = char and (char:FindFirstChild("LeftHand")  or char:FindFirstChild("Left Arm"))
							safeTouch(rightHand, rockPart, 0)
							safeTouch(rightHand, rockPart, 1)
							safeTouch(leftHand, rockPart, 0)
							safeTouch(leftHand, rockPart, 1)
							fireMuscleEvent("punch", "rightHand")
							fireMuscleEvent("punch", "leftHand")
						end
					end
					task.wait(fastPunch and 0.03 or 0.1)
				end
			end)
		end
	end
})

local FastRebirthBox = Tabs.Farming:AddRightGroupbox('Fast Rebirth Suite')
FastRebirthBox:AddLabel('NOTE: You MUST equip one of these 3 pets for Fast Rebirth to function properly!', true)

FastRebirthBox:AddDropdown('FastRebirthPetDropdown', {
	Values = {"Common Boss Pet", "Rare Boss Pet", "Titan Pack Pet"},
	Default = 1,
	Multi = false,
	Text = 'Multiplier Pet',
	Callback = function(v) selectedRebirthPet = v end
})

FastRebirthBox:AddDropdown('FastRebirthSpeedDropdown', {
	Values = {"Fast Rebirth", "Ultra Rebirth"},
	Default = 1,
	Multi = false,
	Text = 'Rebirth Speed Mode',
	Callback = function(v) selectedRebirthMode = v end
})

FastRebirthBox:AddToggle('FastRebirthToggle', {
	Text = 'Fast Rebirth',
	Default = false,
	Tooltip = 'Equips chosen pet, trains required strength, and rebirths instantly',
	Callback = function(v)
		fastRebirthActive = v
		if fastRebirthActive then
			task.spawn(function()
				local equipRemote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("equipPetEvent")
				local function equipRequiredPet()
					local petsFolder = LocalPlayer:FindFirstChild("petsFolder")
					if petsFolder and equipRemote then
						local foundPet = nil
						for _, cat in ipairs(petsFolder:GetChildren()) do
							for _, pet in ipairs(cat:GetChildren()) do
								local n = pet.Name:lower()
								if selectedRebirthPet == "Common Boss Pet" and n:find("common boss pet") then
									foundPet = pet break
								elseif selectedRebirthPet == "Rare Boss Pet" and n:find("rare boss pet") then
									foundPet = pet break
								elseif selectedRebirthPet == "Titan Pack Pet" and (n:find("titan") or n:find("reactor beast") or n:find("plasma")) then
									foundPet = pet break
								end
							end
							if foundPet then break end
						end
						if foundPet then
							pcall(function()
								equipRemote:FireServer("unequipAll")
								task.wait(0.08)
								equipRemote:FireServer("equipPet", foundPet)
							end)
							Notify("Louis Hub", "Equipped " .. selectedRebirthPet .. "!")
						end
					end
				end
				equipRequiredPet()

				while fastRebirthActive do
					if not bossOverrideActive then
						local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
						local rebirthsVal = leaderstats and leaderstats:FindFirstChild("Rebirths")
						if rebirthsVal and rebirthsVal.Value >= maxRebirths then
							fastRebirthActive = false
							if Toggles and Toggles.FastRebirthToggle then Toggles.FastRebirthToggle:SetValue(false) end
							Notify("Louis Hub", "Rebirth cap reached!")
							break
						end
						fireMuscleEvent("rep")
						if selectedRebirthMode == "Ultra Rebirth" then fireMuscleEvent("rep") end
						local backpack = LocalPlayer:FindFirstChild("Backpack")
						local character = LocalPlayer.Character
						if backpack and character and selectedTool then
							local tool = backpack:FindFirstChild(selectedTool)
							if tool and tool.Parent ~= character then tool.Parent = character end
						end
						invokeRebirth()
					end
					if selectedRebirthMode == "Ultra Rebirth" then task.wait(0.03) else task.wait(0.12) end
				end
			end)
		end
	end
})

local RebirthBox = Tabs.Farming:AddRightGroupbox('Auto Rebirth')
RebirthBox:AddInput('MaxRebirthInput', {
	Default = '',
	Numeric = true,
	Finished = true,
	Text = 'Rebirth Target Cap',
	Placeholder = 'Example: 500',
	Callback = function(v) maxRebirths = tonumber(v) or 999999999; Notify("Louis Hub", "Target cap set to " .. tostring(maxRebirths)) end
})

RebirthBox:AddToggle('AutoRebirthToggle', {
	Text = 'Auto Rebirth',
	Default = false,
	Tooltip = 'Executes rebirth continuously upon qualification',
	Callback = function(v)
		autoRebirth = v
		if autoRebirth then
			task.spawn(function()
				while autoRebirth do
					if not bossOverrideActive then
						local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
						local rebirthsVal = leaderstats and leaderstats:FindFirstChild("Rebirths")
						if rebirthsVal and rebirthsVal.Value >= maxRebirths then
							autoRebirth = false
							if Toggles and Toggles.AutoRebirthToggle then Toggles.AutoRebirthToggle:SetValue(false) end
							Notify("Louis Hub", "Rebirth goal reached.")
							break
						end
						invokeRebirth()
					end
					task.wait(0.1)
				end
			end)
		end
	end
})

RebirthBox:AddToggle('AutoRebirthStayToggle', {
	Text = 'Lock Gym on Rebirth',
	Default = false,
	Tooltip = 'Locks coordinate to current gym across respawns',
	Callback = function(v)
		autoRebirthStay = v
		if autoRebirthStay then
			task.spawn(function()
				while autoRebirthStay do
					if not bossOverrideActive then
						local char = LocalPlayer.Character
						local hrp = char and char:FindFirstChild("HumanoidRootPart")
						local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
						local rebirthsVal = leaderstats and leaderstats:FindFirstChild("Rebirths")
						if rebirthsVal and rebirthsVal.Value >= maxRebirths then autoRebirthStay = false break end
						if hrp then
							local currentGymPos = hrp.CFrame
							invokeRebirth()
							task.wait(0.15)
							local newChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
							local newHrp = newChar:WaitForChild("HumanoidRootPart", 3)
							if newHrp then newHrp.CFrame = currentGymPos end
						end
					end
					task.wait(0.5)
				end
			end)
		end
	end
})

local NutritionBox = Tabs.Farming:AddRightGroupbox('Nutrition & Throne')
NutritionBox:AddToggle('AutoFoodToggle', {
	Text = 'Auto Eat Snacks',
	Default = false,
	Tooltip = 'Automatically consumes protein bars and shakes',
	Callback = function(v)
		autoFood = v
		if autoFood then
			task.spawn(function()
				while autoFood do
					if not bossOverrideActive then
						local backpack = LocalPlayer:FindFirstChild("Backpack")
						local char = LocalPlayer.Character
						if backpack and char then
							for _, item in ipairs(backpack:GetChildren()) do
								if not autoFood or bossOverrideActive then break end
								if item:IsA("Tool") then
									local n = item.Name:lower()
									if (n:find("protein") and not n:find("egg")) or n:find("shake") or n:find("bar") or n:find("snack") or n:find("drink") then
										item.Parent = char
										task.wait(0.1)
										item:Activate()
										task.wait(0.15)
										autoConfirmPrompts()
										task.wait(0.2)
									end
								end
							end
						end
					end
					task.wait(0.8)
				end
			end)
		end
	end
})

NutritionBox:AddToggle('AutoEggsToggle', {
	Text = 'Auto Eat 2x Strength Eggs',
	Default = false,
	Tooltip = 'Automatically consumes strength multiplier eggs',
	Callback = function(v)
		autoEggs = v
		if autoEggs then
			task.spawn(function()
				while autoEggs do
					if not bossOverrideActive then
						local backpack = LocalPlayer:FindFirstChild("Backpack")
						local char = LocalPlayer.Character
						if backpack and char then
							for _, item in ipairs(backpack:GetChildren()) do
								if not autoEggs or bossOverrideActive then break end
								if item:IsA("Tool") and item.Name:lower():find("egg") then
									item.Parent = char
									task.wait(0.1)
									item:Activate()
									task.wait(0.15)
									autoConfirmPrompts()
									task.wait(0.2)
								end
							end
						end
					end
					task.wait(1)
				end
			end)
		end
	end
})

NutritionBox:AddDropdown('MKToolDropdown', {
	Values = {"Weight", "Pushups", "Situps", "Handstands"},
	Default = 1,
	Multi = false,
	Text = 'Muscle King Tool',
	Callback = function(v) selectedMKTool = v end
})

NutritionBox:AddToggle('FarmMuscleKingToggle', {
	Text = 'Farm Muscle King',
	Default = false,
	Tooltip = 'Teleports to throne, sets size 1, enables noclip and reps',
	Callback = function(v)
		farmMuscleKing = v
		if farmMuscleKing then
			changePlayerSize(1)
			local mkCFrame = CFrame.new(-8731.53613, 23.7440701, -5864.24268)
			task.spawn(function()
				while farmMuscleKing do
					if not bossOverrideActive then
						if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
							LocalPlayer.Character.HumanoidRootPart.CFrame = mkCFrame
							LocalPlayer.Character.HumanoidRootPart.Anchored = true
							LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
						end
						local backpack = LocalPlayer:FindFirstChild("Backpack")
						local character = LocalPlayer.Character
						if backpack and character and selectedMKTool then
							local tool = backpack:FindFirstChild(selectedMKTool) or character:FindFirstChild(selectedMKTool)
							if tool and tool.Parent ~= character then tool.Parent = character end
						end
						fireMuscleEvent("rep")
					end
					task.wait(repSpeedMode == "Ultra Rep" and 0.02 or 0.08)
				end
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
					LocalPlayer.Character.HumanoidRootPart.Anchored = false
				end
			end)
		else
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				LocalPlayer.Character.HumanoidRootPart.Anchored = false
			end
		end
	end
})

-- ========================================================
-- TAB 2: COMBAT
-- ========================================================
local TargetBox = Tabs.Combat:AddLeftGroupbox('Targeting Settings')
TargetBox:AddDropdown('KillMethodDropdown', {
	Values = {"Teleport Inside Target", "Kill Aura", "Teleport Behind"},
	Default = 1,
	Multi = false,
	Text = 'Kill Method',
	Callback = function(v) killMethod = v end
})

TargetBox:AddSlider('KillAuraRadiusSlider', {
	Text = 'Kill Aura Radius',
	Min = 10,
	Max = 9999,
	Default = 30,
	Rounding = 0,
	Callback = function(v) killAuraRadius = v end
})

TargetBox:AddToggle('FastPunchToggle', {
	Text = 'Fast Punch',
	Default = false,
	Tooltip = 'Removes punch animation cooldown for rapid hits',
	Callback = function(v) fastPunch = v end
})

local ElimBox = Tabs.Combat:AddLeftGroupbox('Player Elimination')
ElimBox:AddToggle('KillAllPlayersToggle', {
	Text = 'Kill All Players',
	Default = false,
	Tooltip = 'Attacks all players in server',
	Callback = function(v)
		killAllPlayers = v
		if killAllPlayers then
			task.spawn(function()
				while killAllPlayers do
					if not bossOverrideActive then
						for _, target in ipairs(Players:GetPlayers()) do
							if not killAllPlayers or bossOverrideActive then break end
							if target ~= LocalPlayer and target.Character then
								local targetHum = target.Character:FindFirstChild("Humanoid")
								local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
								local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
								if targetHum and targetHrp and myHrp and targetHum.Health > 0 and not target.Character:FindFirstChildOfClass("ForceField") then
									if killMethod == "Kill Aura" then
										if (myHrp.Position - targetHrp.Position).Magnitude <= killAuraRadius then
											attackPlayerReal(target, killMethod)
										end
									else
										local startTime = os.clock()
										while killAllPlayers and not bossOverrideActive and target.Character and targetHum.Health > 0 and not target.Character:FindFirstChildOfClass("ForceField") and (os.clock() - startTime < 1.5) do
											attackPlayerReal(target, killMethod)
											task.wait(fastPunch and 0.02 or 0.05)
										end
									end
								end
							end
						end
					end
					task.wait(fastPunch and 0.02 or 0.05)
				end
			end)
		end
	end
})

ElimBox:AddDropdown('TargetPlayerDropdown', {
	Values = getPlayerList(),
	Default = 1,
	Multi = false,
	Text = 'Select Player',
	Callback = function(v) selectedTargetPlayer = v end
})

ElimBox:AddButton({
	Text = 'Refresh Players',
	Func = function()
		if Options and Options.TargetPlayerDropdown then
			Options.TargetPlayerDropdown:SetValues(getPlayerList())
		end
		Notify("Louis Hub", "Player list refreshed.")
	end
})

ElimBox:AddToggle('AutoTargetPlayerToggle', {
	Text = 'Auto Kill Target',
	Default = false,
	Tooltip = 'Continuously hunts selected player',
	Callback = function(v)
		autoTargetPlayer = v
		if autoTargetPlayer then
			task.spawn(function()
				while autoTargetPlayer do
					if not bossOverrideActive then
						local target = Players:FindFirstChild(selectedTargetPlayer)
						if target and target.Character then
							local targetHum = target.Character:FindFirstChild("Humanoid")
							local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
							local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
							if targetHum and targetHrp and myHrp and targetHum.Health > 0 and not target.Character:FindFirstChildOfClass("ForceField") then
								if killMethod == "Kill Aura" then
									if (myHrp.Position - targetHrp.Position).Magnitude <= killAuraRadius then
										attackPlayerReal(target, killMethod)
									end
								else
									attackPlayerReal(target, killMethod)
								end
							end
						end
					end
					task.wait(fastPunch and 0.02 or 0.05)
				end
			end)
		end
	end
})

local DefenseBox = Tabs.Combat:AddRightGroupbox('Karma & Defense')
DefenseBox:AddDropdown('KarmaModeDropdown', {
	Values = {"Good Karma", "Evil Karma"},
	Default = 1,
	Multi = false,
	Text = 'Karma Alignment',
	Callback = function(v) selectedKarmaMode = v end
})

DefenseBox:AddToggle('AutoFarmKarmaToggle', {
	Text = 'Auto Farm Karma',
	Default = false,
	Tooltip = 'Eliminates players matching selected karma',
	Callback = function(v)
		autoFarmKarma = v
		if autoFarmKarma then
			task.spawn(function()
				while autoFarmKarma do
					if not bossOverrideActive then
						for _, target in ipairs(Players:GetPlayers()) do
							if not autoFarmKarma or bossOverrideActive then break end
							if target ~= LocalPlayer and target.Character then
								local targetHum = target.Character:FindFirstChild("Humanoid")
								local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
								local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
								if targetHum and targetHrp and myHrp and targetHum.Health > 0 and not target.Character:FindFirstChildOfClass("ForceField") then
									if isTargetKarmaEligible(target, selectedKarmaMode) then
										if killMethod == "Kill Aura" then
											if (myHrp.Position - targetHrp.Position).Magnitude <= killAuraRadius then
												attackPlayerReal(target, killMethod)
											end
										else
											local startTime = os.clock()
											while autoFarmKarma and not bossOverrideActive and target.Character and targetHum.Health > 0 and not target.Character:FindFirstChildOfClass("ForceField") and (os.clock() - startTime < 1.5) do
												attackPlayerReal(target, killMethod)
												task.wait(fastPunch and 0.02 or 0.05)
											end
										end
									end
								end
							end
						end
					end
					task.wait(fastPunch and 0.03 or 0.08)
				end
			end)
		end
	end
})

DefenseBox:AddToggle('AutoDodgeToggle', {
	Text = 'Auto Dodge Players',
	Default = false,
	Tooltip = 'Sidesteps behind attackers on incoming swings',
	Callback = function(v)
		autoDodge = v
		if autoDodge then
			task.spawn(function()
				while autoDodge do
					local myChar = LocalPlayer.Character
					local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
					if myHrp then
						for _, enemy in ipairs(Players:GetPlayers()) do
							if not autoDodge then break end
							if enemy ~= LocalPlayer and enemy.Character then
								local eChar = enemy.Character
								local eHrp = eChar:FindFirstChild("HumanoidRootPart")
								local eHum = eChar:FindFirstChild("Humanoid")
								if eHrp and eHum and eHum.Health > 0 then
									if (myHrp.Position - eHrp.Position).Magnitude <= 8 and eChar:FindFirstChildOfClass("Tool") then
										if (os.clock() - lastDodgeTime > 0.35) then
											lastDodgeTime = os.clock()
											myHrp.CFrame = eHrp.CFrame * CFrame.new(0, 0, 6)
											task.wait(0.05)
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
	end
})

DefenseBox:AddToggle('AntiRagdollToggle', {
	Text = 'Anti-Ragdoll',
	Default = false,
	Tooltip = 'Immunizes character to stuns, knockdowns, and ragdoll',
	Callback = function(v)
		antiRagdoll = v
		if antiRagdoll then
			task.spawn(function()
				while antiRagdoll do
					if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
						LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
						LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
						LocalPlayer.Character.Humanoid.Sit = false
					end
					task.wait(0.1)
				end
			end)
		end
	end
})

DefenseBox:AddToggle('AutoJoinBrawlToggle', {
	Text = 'Auto Join Brawl',
	Default = false,
	Tooltip = 'Automatically accepts arena brawl invitations',
	Callback = function(v)
		autoJoinBrawl = v
		if autoJoinBrawl then
			task.spawn(function()
				while autoJoinBrawl do
					local bRemote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("brawlEvent")
					if bRemote then pcall(function() bRemote:FireServer("joinBrawl") end) end
					task.wait(2)
				end
			end)
		end
	end
})

-- ========================================================
-- TAB 3: RAID BOSS
-- ========================================================
local BossLiveBox = Tabs.Boss:AddLeftGroupbox('Live Boss Telemetry')
bossRadarStatusLabel = BossLiveBox:AddLabel('Boss Status: Scanning...', true)
bossLiveHealthLabel = BossLiveBox:AddLabel('Boss Health: Standby', true)
bossMobilityLabel = BossLiveBox:AddLabel('Boss Movement: Standby', true)
bossTimerLabel = BossLiveBox:AddLabel('Next Boss in: Calculating...', true)
bossDespawnTimerLabel = BossLiveBox:AddLabel('Time Left: Standby', true)
damageAnalyticsLabel = BossLiveBox:AddLabel('Damage Dealt: 0 | DPS: 0', true)
lootScalingLabel = BossLiveBox:AddLabel('Rebirth Loot Bonus: Calculating...', true)
rainbowBuffLabel = BossLiveBox:AddLabel('Rainbow Buff: Inactive', true)

BossLiveBox:AddToggle('RaidBossMonitorHUDToggle', {
	Text = 'Raid Boss Monitor HUD',
	Default = false,
	Tooltip = 'Displays sleek standalone rounded overlay monitoring live Boss HP, DPS, & Timer',
	Callback = function(v)
		showBossHUD = v
		bossScreenGui.Enabled = showBossHUD
	end
})

BossLiveBox:AddToggle('Show2DBossBarToggle', {
	Text = 'Show 2D Health Bar',
	Default = true,
	Tooltip = 'Forces official 2D boss health HUD on screen',
	Callback = function(v) show2DBossBar = v end
})

BossLiveBox:AddToggle('MuteBossMediaToggle', {
	Text = 'Mute Boss Audio & Popups',
	Default = true,
	Tooltip = 'Silences loud boss BGM and removes 26-second admin cutscenes',
	Callback = function(v) muteBossMedia = v end
})

BossLiveBox:AddToggle('AutoResetSizeToggle', {
	Text = 'Auto Reset to Size 1',
	Default = true,
	Tooltip = 'Automatically resets character to tiny Size 1 when leaving arena',
	Callback = function(v) autoResetSize = v end
})

local BossAutoBox = Tabs.Boss:AddRightGroupbox('Boss Automation & Sweet Spot')
BossAutoBox:AddLabel('Recommended Sweet Spot: Common Boss 46 - 47 Studs', true)

BossAutoBox:AddSlider('BossAltitudeSlider', {
	Text = 'Attack Altitude',
	Min = 1,
	Max = 1000,
	Default = 46,
	Rounding = 0,
	Callback = function(v) bossDistanceOffset = v end
})

BossAutoBox:AddButton({
	Text = 'Refresh Default Stud (46)',
	Func = function()
		bossDistanceOffset = 46.5
		if Options and Options.BossAltitudeSlider then
			Options.BossAltitudeSlider:SetValue(46)
		end
		Notify("Louis Hub", "Altitude set to 46 studs.")
	end
})

BossAutoBox:AddToggle('AutoFarmBossToggle', {
	Text = 'Auto Farm Boss',
	Default = false,
	Tooltip = 'Prioritizes boss, attacks from above head, claims chest, and restores workout',
	Callback = function(v)
		autoFarmBoss = v
		if autoFarmBoss then
			if not isServerBossActive() then
				Notify("Louis Hub", "Boss dormant. Standing by for spawn...")
			end
			startSmoothBossTracking()
			task.spawn(function()
				while autoFarmBoss do
					if isServerBossActive() then
						if not bossOverrideActive then
							bossOverrideActive = true
							local myChar = LocalPlayer.Character
							local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
							if myHrp then preBossWorkoutCFrame = myHrp.CFrame end
							Notify("Louis Hub", "Boss Spawned! Prioritizing Raid Boss...")
						end

						local currentBossModel, currentBossPart = findPhysicalBossModel()
						if not currentBossPart then
							local arenaPos = getArenaLocation()
							local myChar = LocalPlayer.Character
							local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
							if arenaPos and myHrp then
								myHrp.CFrame = arenaPos
								task.wait(0.3)
								currentBossModel, currentBossPart = findPhysicalBossModel()
							end
						end

						if currentBossPart and currentBossModel then
							currentTargetBossPart = currentBossPart
							currentTargetBossModel = currentBossModel
							if not bossActiveDetected then
								bossActiveDetected = true
								local bossName = currentBossModel:GetAttribute("BossDisplayName") or workspace:GetAttribute("BossDisplayName") or "Raid Boss"
								local bossRarity = currentBossModel:GetAttribute("BossRarityName") or workspace:GetAttribute("BossRarityName") or "Boss"
								Notify("Louis Hub", "Boss Engaged: " .. bossName .. " [" .. bossRarity .. "]")
							end

							local myChar = LocalPlayer.Character
							local punchTool = equipPunchTool()
							if punchTool then punchTool:Activate() end

							local rHand = myChar and (myChar:FindFirstChild("RightHand") or myChar:FindFirstChild("Right Arm"))
							local lHand = myChar and (myChar:FindFirstChild("LeftHand") or myChar:FindFirstChild("Left Arm"))

							safeTouch(rHand, currentBossPart, 0)
							safeTouch(rHand, currentBossPart, 1)
							safeTouch(lHand, currentBossPart, 0)
							safeTouch(lHand, currentBossPart, 1)

							fireMuscleEvent("punch", "rightHand")
							fireMuscleEvent("punch", "leftHand")
							task.wait(0.28)
						else
							task.wait(0.5)
						end
					else
						currentTargetBossModel = nil
						currentTargetBossPart = nil
						if bossActiveDetected then
							bossActiveDetected = false
							local myChar = LocalPlayer.Character
							local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
							if myHrp and not isLocked then myHrp.Anchored = false end
							Notify("Louis Hub", "Boss Defeated! Claiming chest...")

							local rName = workspace:GetAttribute("BossRarityName")
							if rName and rName:lower():find("rainbow") then
								rainbowBuffEndTime = os.clock() + 900
								Notify("Louis Hub", "Rainbow Buff Activated for 15 Minutes!")
							end

							if autoClaimChest then
								for _ = 1, 15 do
									if autoClaimBossChest() then break end
									task.wait(0.4)
								end
							end

							if bossOverrideActive then
								task.wait(1)
								if autoResetSize then changePlayerSize(1) end
								if preBossWorkoutCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
									LocalPlayer.Character.HumanoidRootPart.CFrame = preBossWorkoutCFrame
									task.wait(0.3)
								end
								bossOverrideActive = false
								Notify("Louis Hub", "Raid complete! Resuming previous workout...")
							end
						else
							if autoClaimChest then autoClaimBossChest() end
						end
						task.wait(1.5)
					end
				end
				stopSmoothBossTracking()
			end)
		else
			stopSmoothBossTracking()
		end
	end
})

BossAutoBox:AddToggle('DodgeBossStompToggle', {
	Text = 'Dodge Boss Stomp',
	Default = true,
	Tooltip = 'Automatically lifts straight up to sky safezone during ground shockwaves',
	Callback = function(v) autoDodgeStomp = v end
})

BossAutoBox:AddToggle('TagAndReturnToggle', {
	Text = 'Hit Boss Once & Return',
	Default = false,
	Tooltip = 'Hits boss once to qualify for loot, then returns to gym while others finish it',
	Callback = function(v) tagAndReturnEnabled = v end
})

task.spawn(function()
	while true do
		if tagAndReturnEnabled and not isTaggingInProgress and not autoFarmBoss then
			if isServerBossActive() and LocalPlayer:GetAttribute("BossChestEligible") ~= true then
				isTaggingInProgress = true
				local myChar = LocalPlayer.Character
				local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
				if myHrp then
					preTagWorkoutCFrame = myHrp.CFrame
					local arenaPos = getArenaLocation()
					if arenaPos then
						myHrp.CFrame = arenaPos
						task.wait(0.3)
					end
					local bossModel, hitbox = findPhysicalBossModel()
					if hitbox and bossModel then
						Notify("Louis Hub", "Tagging boss for loot eligibility...")
						currentTargetBossPart = hitbox
						currentTargetBossModel = bossModel
						startSmoothBossTracking()

						local tagTimeout = os.clock() + 15
						while tagAndReturnEnabled and isTaggingInProgress and os.clock() < tagTimeout do
							if LocalPlayer:GetAttribute("BossChestEligible") == true then break end
							local punchTool = equipPunchTool()
							if punchTool then punchTool:Activate() end
							local rHand = myChar:FindFirstChild("RightHand") or myChar:FindFirstChild("Right Arm")
							local lHand = myChar:FindFirstChild("LeftHand") or myChar:FindFirstChild("Left Arm")
							safeTouch(rHand, hitbox, 0)
							safeTouch(rHand, hitbox, 1)
							safeTouch(lHand, hitbox, 0)
							safeTouch(lHand, hitbox, 1)
							fireMuscleEvent("punch", "rightHand")
							fireMuscleEvent("punch", "leftHand")
							task.wait(0.28)
						end
						stopSmoothBossTracking()
						if preTagWorkoutCFrame and myChar and myChar:FindFirstChild("HumanoidRootPart") then
							myChar.HumanoidRootPart.CFrame = preTagWorkoutCFrame
							Notify("Louis Hub", "Reward qualified! Returned to station.")
						end
					end
				end
				isTaggingInProgress = false
			end
		end
		task.wait(1.5)
	end
end)

BossAutoBox:AddToggle('AutoClaimChestToggle', {
	Text = 'Auto Claim Boss Chest',
	Default = true,
	Tooltip = 'Automatically claims the boss victory chest as soon as it appears',
	Callback = function(v) autoClaimChest = v end
})

BossAutoBox:AddButton({
	Text = 'Claim Boss Chest Now',
	Func = function()
		if not autoClaimBossChest() then
			Notify("Louis Hub", "No active reward chest found.")
		end
	end
})

BossAutoBox:AddButton({
	Text = 'Teleport to Boss',
	Func = function()
		local bossModel, bossPart = findPhysicalBossModel()
		local myChar = LocalPlayer.Character
		local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if bossPart and myHrp then
			myHrp.CFrame = CFrame.lookAt(bossPart.Position + Vector3.new(0, 46.5, 0), bossPart.Position)
			Notify("Louis Hub", "Teleported to boss.")
		end
	end
})

BossAutoBox:AddButton({
	Text = 'Teleport to Arena',
	Func = function()
		local cf = getArenaLocation()
		local myChar = LocalPlayer.Character
		local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if cf and myHrp then
			myHrp.CFrame = cf
			Notify("Louis Hub", "Arrived at arena.")
		end
	end
})

-- ========================================================
-- TAB 4: COMPANIONS
-- ========================================================
local PetShopBox = Tabs.Companions:AddLeftGroupbox('Pet Shop')
PetShopBox:AddDropdown('ShopPetDropdown', {
	Values = shopItemNames,
	Default = 1,
	Multi = false,
	Text = 'Select Shop Pet',
	Callback = function(v) selectedShopItemKey = v end
})

PetShopBox:AddButton({
	Text = 'Buy Selected Pet',
	Func = function()
		local item = shopItemsList[selectedShopItemKey]
		local remote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("cPetShopRemote")
		if item and remote then
			pcall(function() remote:InvokeServer(item) end)
			Notify("Louis Hub", "Purchased: " .. tostring(selectedShopItemKey))
		end
	end
})

PetShopBox:AddToggle('AutoBuyShopPetToggle', {
	Text = 'Auto Buy Shop Pet',
	Default = false,
	Callback = function(v)
		autoBuyShopPet = v
		if autoBuyShopPet then
			task.spawn(function()
				while autoBuyShopPet do
					local item = shopItemsList[selectedShopItemKey]
					local remote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("cPetShopRemote")
					if item and remote then pcall(function() remote:InvokeServer(item) end) end
					task.wait(0.5)
				end
			end)
		end
	end
})

PetShopBox:AddButton({
	Text = 'Refresh Shop Pets',
	Func = function()
		refreshShopData()
		if Options and Options.ShopPetDropdown then
			Options.ShopPetDropdown:SetValues(shopItemNames)
		end
		Notify("Louis Hub", "Shop refreshed.")
	end
})

local PetMgmtBox = Tabs.Companions:AddLeftGroupbox('Pet Management')
PetMgmtBox:AddButton({ Text = 'Smart Equip Best Pets', Func = function() smartEquipBestPets(); Notify("Louis Hub", "Best pets equipped.") end })
PetMgmtBox:AddButton({ Text = 'Evolve All Pets', Func = function() evolveAllPets(); Notify("Louis Hub", "Pets evolved.") end })
PetMgmtBox:AddToggle('AutoEvolveToggle', {
	Text = 'Auto Evolve',
	Default = false,
	Callback = function(v)
		isAutoEvolve = v
		if isAutoEvolve then
			task.spawn(function()
				while isAutoEvolve do evolveAllPets() task.wait(1.5) end
			end)
		end
	end
})

local GachaBox = Tabs.Companions:AddRightGroupbox('Fast Crystal Open')
GachaBox:AddDropdown('SelectCrystalDropdown', {
	Values = allCrystals,
	Default = 1,
	Multi = false,
	Text = 'Select Crystal',
	Callback = function(v) selectedCrystal = v end
})

GachaBox:AddToggle('FastGacha2xToggle', {
	Text = 'Fast Open (1x)',
	Default = false,
	Callback = function(v)
		isFastGacha2x = v
		if isFastGacha2x then
			lockCurrentInventory()
			disableEggAnimation()
			task.spawn(function()
				while isFastGacha2x do
					task.spawn(function()
						local r = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("openCrystalRemote")
						if r then pcall(function() r:InvokeServer("openCrystal", selectedCrystal) end) end
					end)
					filterNewGachaItems()
					task.wait(gachaSpeed)
				end
			end)
		end
	end
})

GachaBox:AddToggle('FastGacha5xToggle', {
	Text = 'Fast Open (3x)',
	Default = false,
	Callback = function(v)
		isFastGacha5x = v
		if isFastGacha5x then
			lockCurrentInventory()
			disableEggAnimation()
			task.spawn(function()
				while isFastGacha5x do
					task.spawn(function()
						local r = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("openCrystalRemote")
						if r then pcall(function() r:InvokeServer("openCrystalBulk", selectedCrystal, 3) end) end
					end)
					filterNewGachaItems()
					task.wait(gachaSpeed)
				end
			end)
		end
	end
})

GachaBox:AddToggle('FastGacha15xToggle', {
	Text = 'Fast Open (10x)',
	Default = false,
	Callback = function(v)
		isFastGacha15x = v
		if isFastGacha15x then
			lockCurrentInventory()
			disableEggAnimation()
			task.spawn(function()
				while isFastGacha15x do
					task.spawn(function()
						local r = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("openCrystalRemote")
						if r then pcall(function() r:InvokeServer("openCrystalBulk", selectedCrystal, 10) end) end
					end)
					filterNewGachaItems()
					task.wait(gachaSpeed)
				end
			end)
		end
	end
})

local WhitelistBox = Tabs.Companions:AddRightGroupbox('Gacha Whitelist')
WhitelistBox:AddDropdown('SelectPetDropdown', {
	Values = masterPetList,
	Default = 1,
	Multi = false,
	Text = 'Select Pet to Keep',
	Callback = function(v) currentSelectedPet = v end
})
WhitelistBox:AddButton({ Text = 'Whitelist Pet', Func = function() petWhitelist[currentSelectedPet] = true; Notify("Louis Hub", currentSelectedPet .. " added to whitelist.") end })
WhitelistBox:AddButton({ Text = 'Clear Pet Whitelist', Func = function() petWhitelist = {}; Notify("Louis Hub", "Pet whitelist cleared.") end })

WhitelistBox:AddDropdown('SelectAuraDropdown', {
	Values = masterAuraList,
	Default = 1,
	Multi = false,
	Text = 'Select Aura to Keep',
	Callback = function(v) currentSelectedAura = v end
})
WhitelistBox:AddButton({ Text = 'Whitelist Aura', Func = function() auraWhitelist[currentSelectedAura] = true; Notify("Louis Hub", currentSelectedAura .. " added to whitelist.") end })
WhitelistBox:AddButton({ Text = 'Clear Aura Whitelist', Func = function() auraWhitelist = {}; Notify("Louis Hub", "Aura whitelist cleared.") end })

-- ========================================================
-- TAB 5: ENCHANTMENT
-- ========================================================
local EnchantStatusBox = Tabs.Enchantment:AddLeftGroupbox('Machine Status & Nav')
enchantSpinsLabel = EnchantStatusBox:AddLabel('Available Spins: Scanning...', true)
freeSpinTimerLabel = EnchantStatusBox:AddLabel('Daily Free Spin: Calculating...', true)
currentPetEnchantStatusLabel = EnchantStatusBox:AddLabel('Selected Pet Status: Standby', true)

EnchantStatusBox:AddButton({
	Text = 'Teleport to Enchant Machine',
	Func = function()
		local myChar = LocalPlayer.Character
		local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if myHrp then
			myHrp.CFrame = getEnchantMachineCFrame() * CFrame.new(0, 0, 5)
			Notify("Louis Hub", "Arrived at Pet Enchant Machine.")
		end
	end
})

EnchantStatusBox:AddToggle('AutoClaimFreeSpinToggle', {
	Text = 'Auto Claim Daily Free Spin',
	Default = false,
	Callback = function(v)
		autoClaimFreeSpin = v
		if autoClaimFreeSpin then
			task.spawn(function()
				while autoClaimFreeSpin do
					if freeSpinReadyTimestamp <= os.clock() then
						local targetPet = cachedEnchantPetMap[selectedEnchantPetKey]
						local enchantRemote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("petEnchantRemote")
						if targetPet and enchantRemote then
							local myChar = LocalPlayer.Character
							local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
							local machineCFrame = getEnchantMachineCFrame()
							if myHrp and machineCFrame and (myHrp.Position - machineCFrame.Position).Magnitude > 18 then
								myHrp.CFrame = machineCFrame * CFrame.new(0, 0, 4)
								task.wait(0.2)
							end
							pcall(function() enchantRemote:InvokeServer("spin", targetPet) end)
							Notify("Louis Hub", "Claimed daily free enchant spin!")
							freeSpinReadyTimestamp = os.clock() + 86400
						end
					end
					task.wait(5)
				end
			end)
		end
	end
})

EnchantStatusBox:AddToggle('ProtectEnchantsToggle', {
	Text = 'Protect Tier III/IV Enchanted Pets',
	Default = true,
	Callback = function(v)
		protectEnchantedPets = v
		Notify("Louis Hub", "Protection: " .. (protectEnchantedPets and "Enabled" or "Disabled"))
	end
})

local EnchantRollBox = Tabs.Enchantment:AddRightGroupbox('Targeted Enchant Roller')
EnchantRollBox:AddDropdown('EnchantPetDropdown', {
	Values = cachedEnchantPetNames,
	Default = 1,
	Multi = false,
	Text = 'Select Pet to Enchant',
	Callback = function(v) selectedEnchantPetKey = v end
})

EnchantRollBox:AddButton({
	Text = 'Refresh Pet List',
	Func = function()
		refreshEnchantPetsList()
		if Options and Options.EnchantPetDropdown then
			Options.EnchantPetDropdown:SetValues(cachedEnchantPetNames)
		end
		Notify("Louis Hub", "Pet list refreshed.")
	end
})

EnchantRollBox:AddDropdown('TargetEnchantDropdown', {
	Values = enchantTypeList,
	Default = 1,
	Multi = false,
	Text = 'Target Enchantment',
	Callback = function(v) selectedTargetEnchant = v end
})

EnchantRollBox:AddDropdown('TargetTierDropdown', {
	Values = enchantTierTargetList,
	Default = 1,
	Multi = false,
	Text = 'Minimum Target Tier',
	Callback = function(v) selectedTargetTier = v end
})

EnchantRollBox:AddToggle('FastEnchantToggle', {
	Text = 'Fast Enchant (Skip Animation)',
	Default = true,
	Callback = function(v) fastEnchant = v end
})

EnchantRollBox:AddToggle('AutoEnchantPetToggle', {
	Text = 'Auto Enchant Pet',
	Default = false,
	Callback = function(v)
		autoEnchantPet = v
		if autoEnchantPet then
			task.spawn(function()
				local enchantRemote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("petEnchantRemote")
				if not enchantRemote then Notify("Louis Hub", "Enchant remote missing!"); autoEnchantPet = false; return end

				local reqMinTier = 1
				if selectedTargetTier:find("Tier II") then reqMinTier = 2
				elseif selectedTargetTier:find("Tier III") then reqMinTier = 3
				elseif selectedTargetTier:find("Tier IV") then reqMinTier = 4 end
				local cleanTargetEnchant = selectedTargetEnchant:gsub(" %(.*%)", "")

				while autoEnchantPet do
					local targetPet = cachedEnchantPetMap[selectedEnchantPetKey]
					if not targetPet or not targetPet.Parent then Notify("Louis Hub", "Target pet missing from inventory!"); autoEnchantPet = false; break end

					local myChar = LocalPlayer.Character
					local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
					local machineCFrame = getEnchantMachineCFrame()
					if myHrp and machineCFrame and (myHrp.Position - machineCFrame.Position).Magnitude > 18 then
						myHrp.CFrame = machineCFrame * CFrame.new(0, 0, 4)
						task.wait(0.2)
					end

					pcall(function() enchantRemote:InvokeServer("spin", targetPet) end)
					task.wait(fastEnchant and 0.25 or 1.2)

					local currentName, currentTier = getPetEnchantInfo(targetPet)
					if currentTier >= 4 then
						autoEnchantPet = false
						Notify("GODLY TIER IV ROLLED!", string.format("[%s Tier IV] rolled! Preserving pet.", currentName))
						break
					end

					local isEnchantTypeMatched = (cleanTargetEnchant == "Any") or (currentName:lower():find(cleanTargetEnchant:lower()))
					if isEnchantTypeMatched and (currentTier >= reqMinTier) and currentTier > 0 then
						autoEnchantPet = false
						Notify("Target Reached!", string.format("Rolled %s (Tier %d)!", currentName, currentTier))
						break
					end

					if enchantSpinsCount <= 0 and (freeSpinReadyTimestamp > os.clock()) then
						autoEnchantPet = false
						Notify("Louis Hub", "Out of spins!")
						break
					end
				end
				refreshEnchantPetsList()
			end)
		end
	end
})

-- ========================================================
-- TAB 6: LIQUIDATE (SELLING)
-- ========================================================
local SellTierBox = Tabs.Liquidate:AddLeftGroupbox('Sell Pets by Tier')
SellTierBox:AddDropdown('SellTierDropdown', {
	Values = petTiersList,
	Default = 1,
	Multi = true,
	Text = 'Select Tiers to Sell',
	Callback = function(v) selectedTiersToSell = v end
})

SellTierBox:AddButton({ Text = 'Sell Selected Tiers Now', Func = function() sellPetsBySelectedTiers(); Notify("Louis Hub", "Pets sold.") end })
SellTierBox:AddToggle('AutoSellTierToggle', {
	Text = 'Auto Sell Selected Tiers',
	Default = false,
	Callback = function(v)
		autoSellByTier = v
		if autoSellByTier then
			task.spawn(function()
				while autoSellByTier do sellPetsBySelectedTiers(); task.wait(1) end
			end)
		end
	end
})

local SellWhitelistBox = Tabs.Liquidate:AddRightGroupbox('Sell by Whitelist')
SellWhitelistBox:AddDropdown('SellPetWhitelistDropdown', {
	Values = masterPetList,
	Default = 1,
	Multi = false,
	Text = 'Select Pet to Keep',
	Callback = function(v) currentSelectedSellPet = v end
})
SellWhitelistBox:AddButton({ Text = 'Add Pet to Protection', Func = function() petWhitelist[currentSelectedSellPet] = true; Notify("Louis Hub", currentSelectedSellPet .. " protected.") end })
SellWhitelistBox:AddButton({ Text = 'Sell All Non-Whitelisted Pets Now', Func = function() sellPetsNonWhitelisted(); Notify("Louis Hub", "Non-whitelisted pets sold.") end })
SellWhitelistBox:AddToggle('AutoSellNonWhitelistedPetsToggle', {
	Text = 'Auto Sell Non-Whitelisted Pets',
	Default = false,
	Callback = function(v)
		autoSellNonWhitelistedPets = v
		if autoSellNonWhitelistedPets then
			task.spawn(function()
				while autoSellNonWhitelistedPets do sellPetsNonWhitelisted(); task.wait(1.5) end
			end)
		end
	end
})

SellWhitelistBox:AddDropdown('SellAuraWhitelistDropdown', {
	Values = masterAuraList,
	Default = 1,
	Multi = false,
	Text = 'Select Aura to Keep',
	Callback = function(v) currentSelectedSellAura = v end
})
SellWhitelistBox:AddButton({ Text = 'Add Aura to Protection', Func = function() auraWhitelist[currentSelectedSellAura] = true; Notify("Louis Hub", currentSelectedSellAura .. " protected.") end })
SellWhitelistBox:AddButton({ Text = 'Sell All Non-Whitelisted Auras Now', Func = function() sellAurasNonWhitelisted(); Notify("Louis Hub", "Non-whitelisted auras sold.") end })
SellWhitelistBox:AddToggle('AutoSellNonWhitelistedAurasToggle', {
	Text = 'Auto Sell Non-Whitelisted Auras',
	Default = false,
	Callback = function(v)
		autoSellNonWhitelistedAuras = v
		if autoSellNonWhitelistedAuras then
			task.spawn(function()
				while autoSellNonWhitelistedAuras do sellAurasNonWhitelisted(); task.wait(1.5) end
			end)
		end
	end
})

-- ========================================================
-- TAB 7: TELEMETRY
-- ========================================================
local TelemetryHUDBox = Tabs.Telemetry:AddLeftGroupbox('HUD Overlays')
TelemetryHUDBox:AddToggle('ShowStatsHUDToggle', {
	Text = 'Character Stats HUD',
	Default = false,
	Tooltip = 'Displays sleek standalone rounded overlay with real-time character statistics',
	Callback = function(v)
		showStatsHUD = v
		statsScreenGui.Enabled = showStatsHUD
	end
})

TelemetryHUDBox:AddButton({
	Text = 'View My Stats',
	Func = function()
		local s = getFullStats(LocalPlayer)
		if s then
			Notify("Stats: " .. LocalPlayer.DisplayName, string.format("Str: %s | Dur: %s | Agi: %s\nReb: %s | Gems: %s | Kills: %s", formatAbbrev(s.Strength), formatAbbrev(s.Durability), formatAbbrev(s.Agility), formatAbbrev(s.Rebirths), formatAbbrev(s.Gems), formatAbbrev(s.Kills)))
		end
	end
})

local PlayerInspectBox = Tabs.Telemetry:AddRightGroupbox('Player Inspection')
PlayerInspectBox:AddDropdown('InspectPlayerDropdown', {
	Values = getPlayerList(),
	Default = 1,
	Multi = false,
	Text = 'Select Player to Inspect',
	Callback = function(v) selectedInspectPlayer = v end
})

PlayerInspectBox:AddButton({
	Text = 'Inspect Player',
	Func = function()
		local target = Players:FindFirstChild(selectedInspectPlayer)
		if target then
			local s = getFullStats(target)
			if s then
				Notify("Stats: @" .. target.Name, string.format("Str: %s | Dur: %s | Agi: %s\nReb: %s | Gems: %s | Kills: %s", formatAbbrev(s.Strength), formatAbbrev(s.Durability), formatAbbrev(s.Agility), formatAbbrev(s.Rebirths), formatAbbrev(s.Gems), formatAbbrev(s.Kills)))
			end
		else
			Notify("Louis Hub", "Player not located.")
		end
	end
})

PlayerInspectBox:AddButton({
	Text = 'Refresh Player List',
	Func = function()
		if Options and Options.InspectPlayerDropdown then
			Options.InspectPlayerDropdown:SetValues(getPlayerList())
		end
		Notify("Louis Hub", "Player list refreshed.")
	end
})

-- ========================================================
-- TAB 8: SPOILS (CHESTS)
-- ========================================================
local ChestAutoBox = Tabs.Spoils:AddLeftGroupbox('World Chest Sweep')
ChestAutoBox:AddButton({
	Text = 'Smart Claim All 7 Chests',
	Func = function()
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local orig = hrp.CFrame
		Notify("Louis Hub", "Collecting chests...")
		task.spawn(function()
			for _, c in ipairs(chestDataOrdered) do
				hrp.CFrame = c.Pos
				task.wait(2)
				local r = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("checkChestRemote")
				if r then pcall(function() r:InvokeServer(c.RemoteName) end) end
				task.wait(0.1)
			end
			hrp.CFrame = orig
			Notify("Louis Hub", "All world chests collected.")
		end)
	end
})

local ChestIndivBox = Tabs.Spoils:AddRightGroupbox('Individual Chests')
for _, c in ipairs(chestDataOrdered) do
	ChestIndivBox:AddButton({
		Text = 'Claim ' .. c.Name,
		Func = function()
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local orig = hrp.CFrame
				hrp.CFrame = c.Pos
				task.wait(2)
				local r = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("checkChestRemote")
				if r then pcall(function() r:InvokeServer(c.RemoteName) end) end
				task.wait(0.1)
				hrp.CFrame = orig
			end
		end
	})
end

-- ========================================================
-- TAB 9: UTILITIES
-- ========================================================
local UtilModBox = Tabs.Utility:AddLeftGroupbox('Character Modifiers')
UtilModBox:AddSlider('OfficialMuscleSizeSlider', {
	Text = 'Official Muscle Size',
	Min = 1,
	Max = 100,
	Default = 1,
	Rounding = 0,
	Callback = function(v) changePlayerSize(v) end
})
UtilModBox:AddButton({ Text = 'Size 1 (Tiny)', Func = function() changePlayerSize(1) end })
UtilModBox:AddButton({ Text = 'Size 100 (Max Reach)', Func = function() changePlayerSize(100) end })

UtilModBox:AddSlider('OfficialSpeedSlider', {
	Text = 'Official Speed',
	Min = 16,
	Max = 250,
	Default = 16,
	Rounding = 0,
	Callback = function(v)
		local remote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("changeSpeedSizeRemote")
		if remote then pcall(function() remote:InvokeServer("changeSpeed", v); remote:InvokeServer("changeWalkSpeed", v) end) end
	end
})

UtilModBox:AddSlider('CustomWalkSpeedSlider', {
	Text = 'Client WalkSpeed',
	Min = 16,
	Max = 300,
	Default = 16,
	Rounding = 0,
	Callback = function(v) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end end
})

UtilModBox:AddSlider('CustomJumpPowerSlider', {
	Text = 'Client JumpPower',
	Min = 50,
	Max = 350,
	Default = 50,
	Rounding = 0,
	Callback = function(v) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = v end end
})

local UtilPassBox = Tabs.Utility:AddLeftGroupbox('Passive Systems & Codes')
UtilPassBox:AddToggle('WalkOnWaterToggle', {
	Text = 'Walk on Water',
	Default = false,
	Callback = function(v)
		walkOnWater = v
		if walkOnWater then
			if not waterWalkPart then
				waterWalkPart = Instance.new("Part")
				waterWalkPart.Name = "WaterWalkPlatform"
				waterWalkPart.Size = Vector3.new(40, 1, 40)
				waterWalkPart.Transparency = 1
				waterWalkPart.Anchored = true
				waterWalkPart.CanCollide = true
				waterWalkPart.Parent = workspace
			end
			task.spawn(function()
				while walkOnWater do
					local char = LocalPlayer.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")
					if hrp and waterWalkPart then waterWalkPart.CFrame = CFrame.new(hrp.Position.X, -0.5, hrp.Position.Z) end
					task.wait(0.05)
				end
				if waterWalkPart then waterWalkPart:Destroy(); waterWalkPart = nil end
			end)
		else
			if waterWalkPart then waterWalkPart:Destroy(); waterWalkPart = nil end
		end
	end
})

UtilPassBox:AddToggle('HidePopupsToggle', {
	Text = 'Hide Stat Popups',
	Default = false,
	Tooltip = 'Hides floating +strength and +durability gain text smoothly',
	Callback = function(v)
		hidePopups = v
		if hidePopups then
			local pGui = LocalPlayer:FindFirstChild("PlayerGui")
			if pGui then
				for _, gui in pairs(pGui:GetDescendants()) do
					hidePopupElement(gui)
				end
				if not popupAddedConnection then
					popupAddedConnection = pGui.DescendantAdded:Connect(hidePopupElement)
				end
			end
		else
			if popupAddedConnection then
				popupAddedConnection:Disconnect()
				popupAddedConnection = nil
			end
		end
	end
})

UtilPassBox:AddButton({ Text = 'FPS Booster', Func = function() Lighting.GlobalShadows = false; settings().Rendering.QualityLevel = 1; Notify("Louis Hub", "FPS Boosted.") end })
UtilPassBox:AddButton({
	Text = 'Redeem All Promo Codes',
	Func = function()
		local codeRemote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("codeRemote")
		if codeRemote then
			for _, code in ipairs(activeCodes) do
				pcall(function() codeRemote:InvokeServer(code) end)
				task.wait(0.08)
			end
			Notify("Louis Hub", "Promo codes submitted.")
		end
	end
})

local UtilExploitBox = Tabs.Utility:AddRightGroupbox('Movement & Exploits')
UtilExploitBox:AddToggle('AnchorPositionToggle', {
	Text = 'Anchor Position',
	Default = false,
	Callback = function(v) isLocked = v; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.Anchored = v end end
})

UtilExploitBox:AddToggle('DoNotDisturbToggle', {
	Text = 'Do Not Disturb (DND)',
	Default = false,
	Callback = function(v)
		dndActive = v
		if dndActive then
			if not dndConnection then
				dndConnection = RunService.RenderStepped:Connect(function()
					if dndActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
						LocalPlayer.Character.Humanoid:ChangeState(11)
						LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(4011, 26043, -2394)
					end
				end)
			end
		else
			if dndConnection then dndConnection:Disconnect(); dndConnection = nil end
		end
	end
})

UtilExploitBox:AddButton({
	Text = 'FE Invisibility',
	Func = function()
		local char = LocalPlayer.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("LowerTorso") or not char.LowerTorso:FindFirstChild("Root") then return end
		local savepos = char.HumanoidRootPart.CFrame
		char.HumanoidRootPart.CFrame = CFrame.new(915.095215, 37.5268936, 349.808533)
		task.wait(0.5)
		local Clone = char.LowerTorso.Root:Clone()
		char.LowerTorso.Root:Destroy()
		Clone.Parent = char.LowerTorso
		task.wait(0.5)
		char.HumanoidRootPart.CFrame = savepos
	end
})

UtilExploitBox:AddButton({
	Text = 'Spawn BTools',
	Func = function()
		pcall(function()
			game.StarterGui:SetCoreGuiEnabled(2, true)
			local a = Instance.new("HopperBin", LocalPlayer.Backpack) a.BinType = 2
			local b = Instance.new("HopperBin", LocalPlayer.Backpack) b.BinType = 3
			local c = Instance.new("HopperBin", LocalPlayer.Backpack) c.BinType = 4
		end)
	end
})

UtilExploitBox:AddButton({
	Text = 'NoClip (Press G)',
	Func = function()
		noclip = false
		RunService.Stepped:Connect(function()
			if noclip and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
				LocalPlayer.Character.Humanoid:ChangeState(11)
			end
		end)
		local mouse = LocalPlayer:GetMouse()
		mouse.KeyDown:Connect(function(key)
			if key == "g" then
				noclip = not noclip
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
					LocalPlayer.Character.Humanoid:ChangeState(11)
				end
			end
		end)
		Notify("Louis Hub", "Press G to toggle noclip.")
	end
})

UtilExploitBox:AddButton({
	Text = 'Fly (Press B)',
	Func = function()
		local gogo1000 = 0
		local MOUSE = LocalPlayer:GetMouse()
		local isFlying = false

		MOUSE.KeyDown:Connect(function(KEY)
			if KEY:lower() == 'b' then
				gogo1000 = gogo1000 + 1
				isFlying = false
				local T = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("UpperTorso") or LocalPlayer.Character:FindFirstChild("Torso"))
				if not T then return end
				local CONTROL = {F = 0, B = 0, L = 0, R = 0}
				local lCONTROL = {F = 0, B = 0, L = 0, R = 0}
				local SPEED = 5

				local function FLY()
					isFlying = true
					local BG = Instance.new('BodyGyro', T)
					local BV = Instance.new('BodyVelocity', T)
					BG.P = 9e4
					BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
					BG.cframe = T.CFrame
					BV.velocity = Vector3.new(0, 0.1, 0)
					BV.maxForce = Vector3.new(9e9, 9e9, 9e9)

					task.spawn(function()
						repeat task.wait()
							if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
								LocalPlayer.Character.Humanoid.PlatformStand = true
							end
							if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 then SPEED = 50 else SPEED = 0 end
							if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 then
								BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
								lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
							elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and SPEED ~= 0 then
								BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
							else
								BV.velocity = Vector3.new(0, 0.1, 0)
							end
							BG.cframe = workspace.CurrentCamera.CoordinateFrame
						until not isFlying
						CONTROL = {F = 0, B = 0, L = 0, R = 0}
						lCONTROL = {F = 0, B = 0, L = 0, R = 0}
						SPEED = 0
						BG:Destroy()
						BV:Destroy()
						if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
							LocalPlayer.Character.Humanoid.PlatformStand = false
						end
					end)
				end

				MOUSE.KeyDown:Connect(function(K)
					if K:lower() == 'w' then CONTROL.F = 1
					elseif K:lower() == 's' then CONTROL.B = -1
					elseif K:lower() == 'a' then CONTROL.L = -1
					elseif K:lower() == 'd' then CONTROL.R = 1 end
				end)

				MOUSE.KeyUp:Connect(function(K)
					if K:lower() == 'w' then CONTROL.F = 0
					elseif K:lower() == 's' then CONTROL.B = 0
					elseif K:lower() == 'a' then CONTROL.L = 0
					elseif K:lower() == 'd' then CONTROL.R = 0 end
				end)

				FLY()
				if gogo1000 == 2 then isFlying = false gogo1000 = 0 end
			end
		end)
		Notify("Louis Hub", "Press B to toggle flight.")
	end
})

UtilExploitBox:AddButton({
	Text = 'Random Player TP',
	Func = function()
		local allPlrs = Players:GetPlayers()
		local validPlrs = {}
		for _, p in ipairs(allPlrs) do
			if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then table.insert(validPlrs, p) end
		end
		if #validPlrs > 0 then
			local rp = validPlrs[math.random(1, #validPlrs)]
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(rp.Character.Head.Position)
			end
		end
	end
})

UtilExploitBox:AddButton({
	Text = 'Copy CFrame',
	Func = function()
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local cf = LocalPlayer.Character.HumanoidRootPart.CFrame
			pcall(function()
				if setclipboard then
					setclipboard("CFrame.new(" .. tostring(cf) .. ")")
					Notify("Louis Hub", "CFrame copied to clipboard.")
				end
			end)
		end
	end
})

UtilExploitBox:AddButton({
	Text = 'Lag Switch (F3)',
	Func = function()
		local lagState = false
		pcall(function()
			local settingsNet = settings()
			UserInputService.InputEnded:Connect(function(input)
				if input.KeyCode == Enum.KeyCode.F3 then
					lagState = not lagState
					settingsNet.Network.IncomingReplicationLag = lagState and 10 or 0
				end
			end)
		end)
		Notify("Louis Hub", "F3 to toggle lag switch.")
	end
})

UtilExploitBox:AddButton({ Text = 'Rejoin Server', Func = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end })

-- ========================================================
-- TAB 10: NAVIGATION
-- ========================================================
local NavGymBox = Tabs.Navigation:AddLeftGroupbox('Gyms & Islands')
NavGymBox:AddDropdown('SelectGymDropdown', {
	Values = { "Select Location...", "1. Golden Gym (Legend Beach)", "2. Frost Gym", "3. Mythic Gym", "4. Eternal Gym", "5. Legends Gym", "6. Jungle Gym", "7. Industrial Gym", "Pet Enchant Machine", "Tiny Island", "Muscle King" },
	Default = 1,
	Multi = false,
	Text = 'Select Gym',
	Callback = function(v)
		if v ~= "Select Location..." then
			local cf = gymLocations[v]
			if v == "Pet Enchant Machine" then cf = getEnchantMachineCFrame() * CFrame.new(0, 0, 4) end
			if cf and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				LocalPlayer.Character.HumanoidRootPart.CFrame = cf
			end
		end
	end
})

local NavBrawlBox = Tabs.Navigation:AddRightGroupbox('Brawl Arenas')
NavBrawlBox:AddDropdown('SelectBrawlDropdown', {
	Values = {"Select Location...", "Brawl Arena 1", "Brawl Arena 2", "Brawl Arena 3"},
	Default = 1,
	Multi = false,
	Text = 'Select Brawl Arena',
	Callback = function(v)
		if v ~= "Select Location..." and brawlLocations[v] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame = brawlLocations[v]
		end
	end
})

-- ========================================================
-- TAB 11: UI SETTINGS & OBSIDIAN MANAGERS
-- ========================================================
local SettingsBox = Tabs['UI Settings']:AddLeftGroupbox('Menu Keybind')
SettingsBox:AddLabel('Menu Keybind'):AddKeyPicker('MenuKeybind', { Default = 'RightControl', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind

local ThemeManager = nil
local SaveManager = nil
pcall(function()
	ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua", true))()
	SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua", true))()
end)

if ThemeManager then
	ThemeManager:SetLibrary(Library)
	ThemeManager:SetFolder('LouisHub')
	ThemeManager:ApplyToTab(Tabs['UI Settings'])
end

if SaveManager then
	SaveManager:SetLibrary(Library)
	SaveManager:SetFolder('LouisHub/MuscleLegends')
	SaveManager:BuildConfigSection(Tabs['UI Settings'])
end

-- ========================================================
-- RUNTIME LISTENERS & ANTI-AFK
-- ========================================================
LocalPlayer.CharacterAdded:Connect(function(char)
	if isLocked then
		task.wait(1)
		local hrp = char:WaitForChild("HumanoidRootPart", 5)
		if hrp then hrp.Anchored = true end
	end
	if autoFarmBoss and isServerBossActive() then
		local targetCFrame = bossArenaCFrame or getArenaLocation()
		if targetCFrame then
			task.spawn(function()
				local hrp = char:WaitForChild("HumanoidRootPart", 5)
				if hrp then
					task.wait(0.3)
					hrp.CFrame = targetCFrame * CFrame.new(0, 15, 0)
					hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end
			end)
		end
	end
end)

LocalPlayer.Idled:Connect(function()
	pcall(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new(0, 0))
	end)
end)

Notify("Louis Hub", "Obsidian Master Suite Active!")
