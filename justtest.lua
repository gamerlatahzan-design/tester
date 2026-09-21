-- ========================================================
--  LOUIS HUB - MUSCLE LEGENDS (PRO MASTER SUITE)
--  Dual Engine Architecture: Luna Interface Suite + Obsidian
--  Zero-Damage Sweet Spots | Clean Combat | Full Architecture
--  Shared Backend Logic | Two-Way State Sync | Auto-Dock Switcher
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

-- ========================================================
-- DUAL UI LIBRARY LOADERS (AUTO-FALLBACK)
-- ========================================================
local Luna = nil
local lunaUrls = {
	"https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua",
	"https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua",
	"https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/main/source.lua"
}

for _, url in ipairs(lunaUrls) do
	local ok, res = pcall(function()
		return loadstring(game:HttpGet(url, true))()
	end)
	if ok and res and typeof(res) == "table" then
		Luna = res
		break
	end
end

local ObsidianLib = nil
pcall(function()
	local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
	ObsidianLib = loadstring(game:HttpGet(repo .. "Library.lua", true))()
end)

local function Notify(title, text, icon)
	pcall(function()
		if Luna and Luna.Notification then
			Luna:Notification({
				Title       = title,
				Icon        = icon or "notifications_active",
				ImageSource = "Material",
				Content     = text
			})
		elseif ObsidianLib and ObsidianLib.Notify then
			ObsidianLib:Notify(string.format("[%s] %s", title, text), 4)
		end
	end)
end

-- ========================================================
-- SAFE HELPERS (PREVENT NIL CALL CRASHES)
-- ========================================================
local function safeSetLabel(lbl, text)
	if not lbl then return end
	pcall(function()
		if typeof(lbl.Set) == "function" then
			local ok = pcall(function() lbl:Set({ Text = tostring(text) }) end)
			if not ok then pcall(function() lbl:Set(tostring(text)) end) end
		elseif typeof(lbl.SetText) == "function" then
			lbl:SetText(tostring(text))
		elseif typeof(lbl.Update) == "function" then
			lbl:Update(tostring(text))
		end
	end)
end

local function safeSetSlider(slider, val)
	if not slider then return end
	pcall(function()
		if typeof(slider.SetValue) == "function" then
			slider:SetValue(val)
		elseif typeof(slider.Set) == "function" then
			local ok = pcall(function() slider:Set({ CurrentValue = val }) end)
			if not ok then pcall(function() slider:Set(val) end) end
		end
	end)
end

local function safeRefreshDropdown(dropdown, options)
	if not dropdown then return end
	pcall(function()
		if typeof(dropdown.Refresh) == "function" then
			dropdown:Refresh(options, true)
		elseif typeof(dropdown.SetOptions) == "function" then
			dropdown:SetOptions(options)
		elseif typeof(dropdown.Update) == "function" then
			dropdown:Update(options)
		elseif typeof(dropdown.Set) == "function" then
			local ok = pcall(function() dropdown:Set({ Options = options }) end)
			if not ok then pcall(function() dropdown:Set(options) end) end
		end
	end)
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
		pcall(function(...)
			mEvent:FireServer(...)
		end, ...)
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

local function formatAbbrev(n)
	n = tonumber(n) or 0
	if n >= 1e15 then return string.format("%.2fQ", n / 1e15)
	elseif n >= 1e12 then return string.format("%.2fT", n / 1e12)
	elseif n >= 1e9  then return string.format("%.2fB", n / 1e9)
	elseif n >= 1e6  then return string.format("%.2fM", n / 1e6)
	elseif n >= 1e3  then return string.format("%.2fK", n / 1e3)
	else return tostring(n) end
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
local popupAddedConnection = nil
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

local bossHeightSlider = nil

-- UI Reference Maps for Dual-Sync
local lunaToggles = {}
local activeUIName = "Luna"
local lunaWindowInstance = nil
local obsidianWindowInstance = nil

-- ========================================================
-- DATA TABLES
-- ========================================================
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

local selectedCrystal = allCrystals[1]
local currentSelectedPet = masterPetList[1]
local currentSelectedAura = masterAuraList[1]
local currentSelectedSellPet = masterPetList[1]
local currentSelectedSellAura = masterAuraList[1]

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
		if active and (not hp or hp > 0) then
			active = true
		else
			active = false
		end
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
-- CUSTOM HUD 1 & 2 (STATS & RAID BOSS OVERLAYS)
-- ========================================================
local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10) or LocalPlayer:FindFirstChildOfClass("PlayerGui")

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

-- ========================================================
-- TWO-WAY SYNC SYSTEM
-- ========================================================
local isSyncing = false
local function syncToggle(name, value, source)
	if isSyncing then return end
	isSyncing = true
	pcall(function()
		if source == "Luna" then
			if ObsidianLib and ObsidianLib.Toggles and ObsidianLib.Toggles[name] then
				ObsidianLib.Toggles[name]:SetValue(value)
			end
		elseif source == "Obsidian" then
			if lunaToggles[name] then
				if lunaToggles[name].SetValue then
					lunaToggles[name]:SetValue(value)
				elseif lunaToggles[name].Set then
					lunaToggles[name]:Set(value)
				end
			end
		end
	end)
	isSyncing = false
end

-- ========================================================
-- BACKEND EVENT & WORKER HANDLERS
-- ========================================================
local function setAutoStrength(state, source)
	autoStrength = state
	syncToggle("AutoStrength", state, source)
	if autoStrength then
		task.spawn(function()
			while autoStrength do
				if not bossOverrideActive then
					fireMuscleEvent("rep")
					if repSpeedMode == "Ultra Rep" then
						fireMuscleEvent("rep")
					end

					local backpack = LocalPlayer:FindFirstChild("Backpack")
					local character = LocalPlayer.Character
					if backpack and character and selectedTool then
						local tool = backpack:FindFirstChild(selectedTool)
						if tool and tool.Parent ~= character then tool.Parent = character end
					end
				end

				if repSpeedMode == "Ultra Rep" then
					task.wait(0.02)
				elseif repSpeedMode == "Fast Rep" then
					task.wait(0.08)
				else
					task.wait(0.45)
				end
			end
		end)
	end
end

local function setAutoTrainMachine(state, source)
	autoTrainMachine = state
	syncToggle("AutoTrainMachine", state, source)
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

					if myHum and myHum.Sit then
						isSeatedOnMachine = true
					else
						isSeatedOnMachine = false
					end

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
						if repSpeedMode == "Ultra Rep" then
							fireMuscleEvent("rep")
						end
					end
				end

				if repSpeedMode == "Ultra Rep" then
					task.wait(0.02)
				elseif repSpeedMode == "Fast Rep" then
					task.wait(0.08)
				else
					task.wait(0.4)
				end
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

local function setAutoRock(state, source)
	autoRock = state
	syncToggle("AutoRock", state, source)
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

local function setAutoRebirth(state, source)
	autoRebirth = state
	syncToggle("AutoRebirth", state, source)
	if autoRebirth then
		task.spawn(function()
			while autoRebirth do
				if not bossOverrideActive then
					local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
					local rebirthsVal = leaderstats and leaderstats:FindFirstChild("Rebirths")
					if rebirthsVal and rebirthsVal.Value >= maxRebirths then
						autoRebirth = false
						syncToggle("AutoRebirth", false, "Luna")
						Notify("Louis Hub", "Rebirth goal reached.", "check_circle")
						break
					end
					invokeRebirth()
				end
				task.wait(0.1)
			end
		end)
	end
end

local function setFastRebirth(state, source)
	fastRebirthActive = state
	syncToggle("FastRebirth", state, source)
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
						Notify("Louis Hub", "Equipped " .. selectedRebirthPet .. "!", "check_circle")
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
						syncToggle("FastRebirth", false, "Luna")
						Notify("Louis Hub", "Rebirth cap reached!", "check_circle")
						break
					end

					fireMuscleEvent("rep")
					if selectedRebirthMode == "Ultra Rebirth" then
						fireMuscleEvent("rep")
					end

					local backpack = LocalPlayer:FindFirstChild("Backpack")
					local character = LocalPlayer.Character
					if backpack and character and selectedTool then
						local tool = backpack:FindFirstChild(selectedTool)
						if tool and tool.Parent ~= character then tool.Parent = character end
					end

					invokeRebirth()
				end

				if selectedRebirthMode == "Ultra Rebirth" then
					task.wait(0.03)
				else
					task.wait(0.12)
				end
			end
		end)
	end
end

-- ========================================================
-- BUILD FRONTEND 1: LUNA INTERFACE SUITE
-- ========================================================
local LunaWindow = nil
pcall(function()
	LunaWindow = Luna:CreateWindow({
		Name            = "Louis Hub",
		Subtitle        = "Muscle Legends (Luna Edition)",
		LogoID          = "82795327169782",
		LoadingEnabled  = false,
		ConfigSettings  = { RootFolder = nil, ConfigFolder = "LouisHub" },
		KeySystem       = false
	})
end)

if LunaWindow then
	local TabFarming = LunaWindow:CreateTab({ Name = "Farming", Icon = "fitness_center", ImageSource = "Material", ShowTitle = true })
	TabFarming:CreateSection("Rep Method")

	TabFarming:CreateDropdown({
		Name = "Training Tool", Options = {"Weight", "Pushups", "Situps", "Handstands"}, CurrentOption = {"Weight"}, MultipleOptions = false,
		Callback = function(opt) selectedTool = typeof(opt) == "table" and opt[1] or opt end
	}, "Luna_Tool")

	TabFarming:CreateDropdown({
		Name = "Rep Speed Mode", Options = {"Normal Rep", "Fast Rep", "Ultra Rep"}, CurrentOption = {"Normal Rep"}, MultipleOptions = false,
		Callback = function(opt) repSpeedMode = typeof(opt) == "table" and opt[1] or opt end
	}, "Luna_RepSpeed")

	lunaToggles["AutoStrength"] = TabFarming:CreateToggle({
		Name = "Auto Strength", Description = "Trains reps with chosen tool", CurrentValue = false,
		Callback = function(s) setAutoStrength(s, "Luna") end
	}, "AutoStrength")

	TabFarming:CreateSection("Gym Machines")
	TabFarming:CreateDropdown({
		Name = "Workout Station", Options = allGymWorkoutsList, CurrentOption = {allGymWorkoutsList[1]}, MultipleOptions = false,
		Callback = function(opt) selectedWorkoutStation = typeof(opt) == "table" and opt[1] or opt end
	}, "Luna_Machine")

	lunaToggles["AutoTrainMachine"] = TabFarming:CreateToggle({
		Name = "Auto Train Machine", Description = "Safely enters station and trains", CurrentValue = false,
		Callback = function(s) setAutoTrainMachine(s, "Luna") end
	}, "AutoTrainMachine")

	TabFarming:CreateSection("Rock Training")
	TabFarming:CreateDropdown({
		Name = "Target Rock", Options = rockList, CurrentOption = {"Tiny Rock"}, MultipleOptions = false,
		Callback = function(opt) selectedRock = typeof(opt) == "table" and opt[1] or opt end
	}, "Luna_Rock")

	lunaToggles["AutoRock"] = TabFarming:CreateToggle({
		Name = "Auto Punch Rock", Description = "Dual fist hits for durability", CurrentValue = false,
		Callback = function(s) setAutoRock(s, "Luna") end
	}, "AutoRock")

	TabFarming:CreateSection("Fast Rebirth Suite")
	pcall(function()
		TabFarming:CreateParagraph({
			Title = "Fast Rebirth Requirement",
			Text  = "NOTE: To ensure Fast Rebirth works properly, you MUST equip one of the supported multiplier pets: Common Boss Pet, Rare Boss Pet, or Titan Pack Pet! The script will automatically locate and equip your chosen pet below."
		})
	end)

	TabFarming:CreateDropdown({
		Name = "Select Multiplier Pet", Options = {"Common Boss Pet", "Rare Boss Pet", "Titan Pack Pet"}, CurrentOption = {"Common Boss Pet"}, MultipleOptions = false,
		Callback = function(opt) selectedRebirthPet = typeof(opt) == "table" and opt[1] or opt end
	}, "Luna_RebirthPet")

	TabFarming:CreateDropdown({
		Name = "Rebirth Speed Mode", Options = {"Fast Rebirth", "Ultra Rebirth"}, CurrentOption = {"Fast Rebirth"}, MultipleOptions = false,
		Callback = function(opt) selectedRebirthMode = typeof(opt) == "table" and opt[1] or opt end
	}, "Luna_RebirthSpeed")

	lunaToggles["FastRebirth"] = TabFarming:CreateToggle({
		Name = "Fast Rebirth", Description = "Auto-equips pet, trains strength, and rebirths", CurrentValue = false,
		Callback = function(s) setFastRebirth(s, "Luna") end
	}, "FastRebirth")

	lunaToggles["AutoRebirth"] = TabFarming:CreateToggle({
		Name = "Auto Rebirth", Description = "Normal rebirth cycle", CurrentValue = false,
		Callback = function(s) setAutoRebirth(s, "Luna") end
	}, "AutoRebirth")

	local TabBoss = LunaWindow:CreateTab({ Name = "Raid Boss", Icon = "sports_kabaddi", ImageSource = "Material", ShowTitle = true })
	TabBoss:CreateSection("Boss Overlays & Automation")

	TabBoss:CreateToggle({
		Name = "Raid Boss Monitor HUD", Description = "Standalone rounded overlay monitoring Boss HP, DPS, & Timer", CurrentValue = false,
		Callback = function(s) showBossHUD = s; bossScreenGui.Enabled = showBossHUD end
	}, "Luna_BossHUD")

	lunaToggles["AutoFarmBoss"] = TabBoss:CreateToggle({
		Name = "Auto Farm Boss", Description = "Prioritizes boss, attacks from above, and claims victory chest", CurrentValue = false,
		Callback = function(s) autoFarmBoss = s; syncToggle("AutoFarmBoss", s, "Luna"); if autoFarmBoss then startSmoothBossTracking() else stopSmoothBossTracking() end end
	}, "AutoFarmBoss")

	TabBoss:CreateToggle({
		Name = "Dodge Boss Stomp", Description = "Lifts vertically into sky safezone during ground shockwaves", CurrentValue = true,
		Callback = function(s) autoDodgeStomp = s end
	}, "Luna_DodgeStomp")

	local TabStats = LunaWindow:CreateTab({ Name = "Telemetry", Icon = "leaderboard", ImageSource = "Material", ShowTitle = true })
	TabStats:CreateSection("HUD Indicators")

	TabStats:CreateToggle({
		Name = "Character Stats HUD", Description = "Standalone rounded overlay with live character stats", CurrentValue = false,
		Callback = function(s) showStatsHUD = s; statsScreenGui.Enabled = showStatsHUD end
	}, "Luna_StatsHUD")
end

-- ========================================================
-- BUILD FRONTEND 2: OBSIDIAN UI LIBRARY
-- ========================================================
local ObsidianWindow = nil
if ObsidianLib then
	pcall(function()
		ObsidianWindow = ObsidianLib:CreateWindow({
			Title = "Louis Hub",
			Footer = "Muscle Legends (Obsidian Edition)",
			Icon = 82795327169782,
			NotifySide = "Right",
			ShowCustomCursor = false
		})
	end)
end

if ObsidianWindow then
	local OTabs = {
		Farming   = ObsidianWindow:AddTab('Farming'),
		Combat    = ObsidianWindow:AddTab('Combat'),
		Boss      = ObsidianWindow:AddTab('Raid Boss'),
		Enchant   = ObsidianWindow:AddTab('Enchantment'),
		Telemetry = ObsidianWindow:AddTab('Telemetry'),
		Settings  = ObsidianWindow:AddTab('UI Settings')
	}

	local FarmBox = OTabs.Farming:AddLeftGroupbox('Rep Training')
	FarmBox:AddDropdown('Obsidian_Tool', {
		Values = {"Weight", "Pushups", "Situps", "Handstands"}, Default = 1, Multi = false, Text = 'Training Tool',
		Callback = function(v) selectedTool = v end
	})
	FarmBox:AddDropdown('Obsidian_RepSpeed', {
		Values = {"Normal Rep", "Fast Rep", "Ultra Rep"}, Default = 1, Multi = false, Text = 'Rep Speed Mode',
		Callback = function(v) repSpeedMode = v end
	})
	FarmBox:AddToggle('AutoStrength', {
		Text = 'Auto Strength', Default = false,
		Callback = function(v) setAutoStrength(v, "Obsidian") end
	})

	local RebirthBox = OTabs.Farming:AddRightGroupbox('Fast Rebirth Suite')
	RebirthBox:AddDropdown('Obsidian_RebirthPet', {
		Values = {"Common Boss Pet", "Rare Boss Pet", "Titan Pack Pet"}, Default = 1, Multi = false, Text = 'Multiplier Pet',
		Callback = function(v) selectedRebirthPet = v end
	})
	RebirthBox:AddDropdown('Obsidian_RebirthSpeed', {
		Values = {"Fast Rebirth", "Ultra Rebirth"}, Default = 1, Multi = false, Text = 'Rebirth Mode',
		Callback = function(v) selectedRebirthMode = v end
	})
	RebirthBox:AddToggle('FastRebirth', {
		Text = 'Fast Rebirth', Default = false,
		Callback = function(v) setFastRebirth(v, "Obsidian") end
	})
	RebirthBox:AddToggle('AutoRebirth', {
		Text = 'Auto Rebirth', Default = false,
		Callback = function(v) setAutoRebirth(v, "Obsidian") end
	})

	local BossBox = OTabs.Boss:AddLeftGroupbox('Boss Automation')
	BossBox:AddToggle('AutoFarmBoss', {
		Text = 'Auto Farm Boss', Default = false,
		Callback = function(v) autoFarmBoss = v; syncToggle("AutoFarmBoss", v, "Obsidian"); if autoFarmBoss then startSmoothBossTracking() else stopSmoothBossTracking() end end
	})
	BossBox:AddToggle('Obsidian_BossHUD', {
		Text = 'Raid Boss Monitor HUD', Default = false,
		Callback = function(v) showBossHUD = v; bossScreenGui.Enabled = showBossHUD end
	})

	local StatBox = OTabs.Telemetry:AddLeftGroupbox('Live HUD')
	StatBox:AddToggle('Obsidian_StatsHUD', {
		Text = 'Character Stats HUD', Default = false,
		Callback = function(v) showStatsHUD = v; statsScreenGui.Enabled = showStatsHUD end
	})
end

-- ========================================================
-- FLOATING UI SWITCHER BUTTON (AUTO-DOCKING ENGINE)
-- ========================================================
local switcherGui = Instance.new("ScreenGui")
switcherGui.Name = "LouisHub_FloatingSwitcher"
switcherGui.ResetOnSpawn = false
switcherGui.DisplayOrder = 10001
if playerGui then switcherGui.Parent = playerGui end

local switcherFrame = Instance.new("Frame")
switcherFrame.Name = "SwitcherFrame"
switcherFrame.Size = UDim2.new(0, 140, 0, 32)
switcherFrame.Position = UDim2.new(1, -160, 0, 15)
switcherFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
switcherFrame.BackgroundTransparency = 0.25
switcherFrame.BorderSizePixel = 0
switcherFrame.Active = true
switcherFrame.Parent = switcherGui

local switcherCorner = Instance.new("UICorner")
switcherCorner.CornerRadius = UDim.new(0, 8)
switcherCorner.Parent = switcherFrame

local switcherStroke = Instance.new("UIStroke")
switcherStroke.Color = Color3.fromRGB(255, 255, 255)
switcherStroke.Thickness = 1.2
switcherStroke.Parent = switcherFrame

local switcherButton = Instance.new("TextButton")
switcherButton.Name = "ToggleButton"
switcherButton.Size = UDim2.new(1, 0, 1, 0)
switcherButton.BackgroundTransparency = 1
switcherButton.Text = "Switch UI: Obsidian"
switcherButton.TextColor3 = Color3.fromRGB(255, 255, 255)
switcherButton.Font = Enum.Font.GothamBold
switcherButton.TextSize = 11
switcherButton.Parent = switcherFrame
makeDraggable(switcherFrame, switcherFrame)

local function locateMainFrame(gui)
	if not gui then return nil end
	for _, child in ipairs(gui:GetChildren()) do
		if child:IsA("Frame") and child.Visible and child.AbsoluteSize.X > 200 then
			return child
		end
	end
	return nil
end

local function applyUISwitch(targetUI)
	activeUIName = targetUI
	local lunaGui = nil
	local obsidianGui = nil

	for _, g in ipairs(playerGui:GetChildren()) do
		if g:IsA("ScreenGui") and g ~= switcherGui and g ~= statsScreenGui and g ~= bossScreenGui then
			local n = g.Name:lower()
			if n:find("luna") or (g:FindFirstChild("MainFrame") and not n:find("obsidian")) then
				lunaGui = g
			elseif n:find("obsidian") or n:find("linoria") or g:FindFirstChild("Container") then
				obsidianGui = g
			end
		end
	end

	if targetUI == "Obsidian" then
		if lunaGui then lunaGui.Enabled = false end
		if obsidianGui then obsidianGui.Enabled = true end
		switcherButton.Text = "Switch UI: Luna"
		Notify("Louis Hub", "Switched to Obsidian UI!", "swap_horiz")
	else
		if obsidianGui then obsidianGui.Enabled = false end
		if lunaGui then lunaGui.Enabled = true end
		switcherButton.Text = "Switch UI: Obsidian"
		Notify("Louis Hub", "Switched to Luna UI!", "swap_horiz")
	end
end

switcherButton.MouseButton1Click:Connect(function()
	if activeUIName == "Luna" then
		applyUISwitch("Obsidian")
	else
		applyUISwitch("Luna")
	end
end)

-- Auto-Dock Position Keeper to Top-Right of Active Window
RunService.RenderStepped:Connect(function()
	local activeFrame = nil
	if activeUIName == "Luna" and lunaWindowInstance then
		activeFrame = lunaWindowInstance
	elseif activeUIName == "Obsidian" and obsidianWindowInstance then
		activeFrame = obsidianWindowInstance
	end

	if activeFrame and activeFrame.Parent and activeFrame.Visible then
		local pos = activeFrame.AbsolutePosition
		local size = activeFrame.AbsoluteSize
		local targetX = pos.X + size.X - switcherFrame.AbsoluteSize.X
		local targetY = math.max(10, pos.Y - switcherFrame.AbsoluteSize.Y - 6)
		switcherFrame.Position = UDim2.new(0, targetX, 0, targetY)
	end
end)

-- Start default UI state
task.defer(function()
	applyUISwitch("Luna")
end)

Notify("Louis Hub", "Master Suite Active: Dual Engine Running!", "check_circle")
