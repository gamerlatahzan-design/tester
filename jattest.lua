-- ========================================================
--  LOUIS HUB - BLOX FRUITS (PRO MASTER SUITE)
--  Engine: Luna Interface Suite | Auto-Dimension & Fast Hit
--  Part 1: Core Engine, Movement, Full Quests & Farming [PATCHED]
-- ========================================================

-- ========================================================
-- SERVICES
-- ========================================================
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local VirtualUser       = game:GetService("VirtualUser")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer       = Players.LocalPlayer

-- ========================================================
-- WORLD / SEA DETECTION
-- ========================================================
local World1 = game.PlaceId == 2753915549 or game.PlaceId == 85211729168715
local World2 = game.PlaceId == 4442272183 or game.PlaceId == 79091703265657
local World3 = game.PlaceId == 7449423635 or game.PlaceId == 100117331123089

-- Anti-AFK Controller
LocalPlayer.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.zero)
end)

-- ========================================================
-- LUNA INTERFACE SUITE (Auto-Fallback Loader)
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
	if ok and res then
		Luna = res
		break
	end
end

if not Luna then
	warn("[Louis Hub] Failed to load Luna Interface Suite!")
	return
end

local function Notify(title, text, icon)
	pcall(function()
		Luna:Notification({
			Title       = title,
			Icon        = icon or "notifications_active",
			ImageSource = "Material",
			Content     = text
		})
	end)
end

-- ========================================================
-- WINDOW CREATION
-- ========================================================
local Window = Luna:CreateWindow({
	Name            = "Louis Hub",
	Subtitle        = "Blox Fruits",
	LogoID          = "82795327169782",
	LoadingEnabled  = true,
	LoadingTitle    = "Louis Hub",
	LoadingSubtitle = "Blox Fruits Pro Suite",
	ConfigSettings  = {
		RootFolder   = nil,
		ConfigFolder = "LouisHub_BloxFruits"
	},
	KeySystem   = false,
	KeySettings = {
		Title       = "Louis Hub",
		Subtitle    = "Key Verification",
		Note        = "Keyless Active",
		SaveInRoot  = false,
		SaveKey     = false,
		Key         = {"1234"}
	}
})

Window:CreateHomeTab({
	SupportedExecutors = { "Synapse X", "Krnl", "Fluxus", "Delta", "Codex", "Wave", "Hydrogen", "Arceus X" },
	DiscordInvite      = "1234",
	Icon               = 1
})

-- ========================================================
-- CORE MOVEMENT & TELEPORT ENGINE (PATCHED & ANTI-STUTTER)
-- ========================================================
local isTweening = false
local currentTween = nil
local lastTargetPos = Vector3.zero

local function WaitHRP(player)
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart", 5) or char:FindFirstChild("HumanoidRootPart")
end

local function StopTween()
	isTweening = false
	if currentTween then
		currentTween:Cancel()
		currentTween = nil
	end
	local hrp = WaitHRP(LocalPlayer)
	if hrp and hrp:FindFirstChild("BodyClip") then
		hrp.BodyClip:Destroy()
	end
end

-- Pintu Masuk dan Keluar Dimensi (Patched)
local function CheckEntrance(targetPos)
	local hrp = WaitHRP(LocalPlayer)
	if not hrp then return end
	local dist = (targetPos - hrp.Position).Magnitude

	if World1 and dist > 10000 then
		if targetPos.Y > 4000 then -- Masuk Sky 3
			ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-7894.6, 5547.1, -380.2))
			task.wait(0.5)
		elseif hrp.Position.Y > 4000 and targetPos.Y < 2000 then -- Keluar Sky 3
			ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-4607, 874, -1667))
			task.wait(0.5)
		elseif targetPos.X > 50000 then -- Masuk Underwater
			ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(61163.8, 11.6, 1819.7))
			task.wait(0.5)
		elseif hrp.Position.X > 50000 and targetPos.X < 20000 then -- Keluar Underwater
			ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(4050, -1, -1814))
			task.wait(0.5)
		end
	elseif World2 and dist > 10000 then
		if targetPos.Z > 30000 then -- Cursed Ship
			ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.2, 126.9, 32852.8))
			task.wait(0.5)
		end
	elseif World3 and dist > 10000 then
		if targetPos.Y > 900 and targetPos.X > 4000 then -- Hydra Island
			ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(5657.8, 1013.0, -335.4))
			task.wait(0.5)
		elseif targetPos.X < -11000 and targetPos.Z < -6000 then -- Mansion
			ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-12471.1, 374.9, -7551.6))
			task.wait(0.5)
		end
	end
end

local function topos(targetCFrame)
	local hrp = WaitHRP(LocalPlayer)
	if not hrp or not targetCFrame then return end

	CheckEntrance(targetCFrame.Position)

	local dist = (targetCFrame.Position - hrp.Position).Magnitude
	if dist < 20 then
		StopTween()
		hrp.CFrame = targetCFrame
		return
	end

	if isTweening and (targetCFrame.Position - lastTargetPos).Magnitude < 10 then
		return
	end

	lastTargetPos = targetCFrame.Position

	if not hrp:FindFirstChild("BodyClip") then
		local bv = Instance.new("BodyVelocity")
		bv.Name = "BodyClip"
		bv.Parent = hrp
		bv.MaxForce = Vector3.new(100000, 100000, 100000)
		bv.Velocity = Vector3.zero
	end

	local speed = 320
	local tweenTime = dist / speed
	local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)

	if currentTween then currentTween:Cancel() end
	currentTween = TweenService:Create(hrp, tweenInfo, { CFrame = targetCFrame })
	isTweening = true
	currentTween:Play()

	currentTween.Completed:Connect(function(status)
		if status == Enum.PlaybackState.Completed then
			isTweening = false
			if hrp:FindFirstChild("BodyClip") then
				hrp.BodyClip:Destroy()
			end
		end
	end)
end

-- Collision Control & Noclip
RunService.Stepped:Connect(function()
	if isTweening or _G.AutoFarm or _G.AutoFarmLevelNew or _G.AutoBoss or _G.AutoFarmMaterial or _G.SafeMode then
		if LocalPlayer.Character then
			for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end
end)

-- ========================================================
-- COMBAT & MOB MANAGEMENT HELPERS (PATCHED)
-- ========================================================
local function AutoHaki()
	local char = LocalPlayer.Character
	if char and not char:FindFirstChild("HasBuso") then
		ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
	end
end

local function EquipWeapon(weaponType)
	local bp = LocalPlayer:FindFirstChild("Backpack")
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("Humanoid") or not bp then return end

	for _, tool in ipairs(bp:GetChildren()) do
		if tool:IsA("Tool") then
			if weaponType == "Melee" and (tool.ToolTip == "Melee" or tool.Name == "Combat") then
				char.Humanoid:EquipTool(tool)
				break
			elseif weaponType == "Sword" and tool.ToolTip == "Sword" then
				char.Humanoid:EquipTool(tool)
				break
			elseif weaponType == "Gun" and tool.ToolTip == "Gun" then
				char.Humanoid:EquipTool(tool)
				break
			elseif weaponType == "Blox Fruit" and tool.ToolTip == "Blox Fruit" then
				char.Humanoid:EquipTool(tool)
				break
			elseif tool.Name == weaponType then
				char.Humanoid:EquipTool(tool)
				break
			end
		end
	end
end

local function BringMob(mobName, centerCFrame)
	local hrp = WaitHRP(LocalPlayer)
	if not hrp then return end
	pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
	for _, mob in ipairs(workspace.Enemies:GetChildren()) do
		if mob.Name == mobName and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
			if (mob.HumanoidRootPart.Position - hrp.Position).Magnitude <= 320 then
				mob.HumanoidRootPart.CFrame = centerCFrame
				mob.HumanoidRootPart.CanCollide = false
				mob.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
				mob.Humanoid.WalkSpeed = 0
				mob.Humanoid.JumpPower = 0
				if mob.Humanoid:FindFirstChild("Animator") then
					mob.Humanoid.Animator:Destroy()
				end
			end
		end
	end
end

-- ========================================================
-- FULL QUEST PROGRESSION DATABASE (LV 1 - 2575+)
-- ========================================================
local Quests_W1 = {
	{1, 9, "Bandit", 1, "BanditQuest1", CFrame.new(1059.37, 15.45, 1550.42), CFrame.new(1045.96, 27.00, 1560.82)},
	{10, 14, "Monkey", 1, "JungleQuest", CFrame.new(-1598.08, 35.55, 153.37), CFrame.new(-1448.51, 67.85, 11.46)},
	{15, 29, "Gorilla", 2, "JungleQuest", CFrame.new(-1598.08, 35.55, 153.37), CFrame.new(-1129.88, 40.46, -525.42)},
	{30, 39, "Pirate", 1, "BuggyQuest1", CFrame.new(-1141.07, 4.10, 3831.54), CFrame.new(-1103.51, 13.75, 3896.09)},
	{40, 59, "Brute", 2, "BuggyQuest1", CFrame.new(-1141.07, 4.10, 3831.54), CFrame.new(-1140.08, 14.80, 4322.92)},
	{60, 74, "Desert Bandit", 1, "DesertQuest", CFrame.new(894.48, 5.14, 4392.43), CFrame.new(924.79, 6.44, 4481.58)},
	{75, 89, "Desert Officer", 2, "DesertQuest", CFrame.new(894.48, 5.14, 4392.43), CFrame.new(1608.28, 8.61, 4371.00)},
	{90, 99, "Snow Bandit", 1, "SnowQuest", CFrame.new(1389.74, 88.15, -1298.90), CFrame.new(1354.34, 87.27, -1393.94)},
	{100, 119, "Snowman", 2, "SnowQuest", CFrame.new(1389.74, 88.15, -1298.90), CFrame.new(1201.64, 144.57, -1550.06)},
	{120, 149, "Chief Petty Officer", 1, "MarineQuest2", CFrame.new(-5039.58, 27.35, 4324.68), CFrame.new(-4881.23, 22.65, 4273.75)},
	{150, 174, "Sky Bandit", 1, "SkyQuest", CFrame.new(-4839.53, 716.36, -2619.44), CFrame.new(-4953.20, 295.74, -2899.22)},
	{175, 189, "Dark Master", 2, "SkyQuest", CFrame.new(-4839.53, 716.36, -2619.44), CFrame.new(-5259.84, 391.39, -2229.03)},
	{190, 209, "Prisoner", 1, "PrisonerQuest", CFrame.new(5308.93, 1.65, 475.12), CFrame.new(5098.97, -0.32, 474.23)},
	{210, 249, "Dangerous Prisoner", 2, "PrisonerQuest", CFrame.new(5308.93, 1.65, 475.12), CFrame.new(5654.56, 15.63, 866.29)},
	{250, 274, "Toga Warrior", 1, "ColosseumQuest", CFrame.new(-1580.04, 6.35, -2986.47), CFrame.new(-1820.21, 51.68, -2740.66)},
	{275, 299, "Gladiator", 2, "ColosseumQuest", CFrame.new(-1580.04, 6.35, -2986.47), CFrame.new(-1292.83, 56.38, -3339.03)},
	{300, 324, "Military Soldier", 1, "MagmaQuest", CFrame.new(-5313.37, 10.95, 8515.29), CFrame.new(-5411.16, 11.08, 8454.29)},
	{325, 374, "Military Spy", 2, "MagmaQuest", CFrame.new(-5313.37, 10.95, 8515.29), CFrame.new(-5802.86, 86.26, 8828.85)},
	{375, 399, "Fishman Warrior", 1, "FishmanQuest", CFrame.new(61122.65, 18.49, 1569.39), CFrame.new(60878.30, 18.48, 1543.75)},
	{400, 449, "Fishman Commando", 2, "FishmanQuest", CFrame.new(61122.65, 18.49, 1569.39), CFrame.new(61922.63, 18.48, 1493.93)},
	{450, 474, "God's Guard", 1, "SkyExp1Quest", CFrame.new(-4721.88, 843.87, -1949.96), CFrame.new(-4710.04, 845.27, -1927.30)},
	{475, 524, "Shanda", 2, "SkyExp1Quest", CFrame.new(-7859.09, 5544.19, -381.47), CFrame.new(-7678.48, 5566.40, -497.21)},
	{525, 549, "Royal Squad", 1, "SkyExp2Quest", CFrame.new(-7906.81, 5634.66, -1411.99), CFrame.new(-7624.25, 5658.13, -1467.35)},
	{550, 624, "Royal Soldier", 2, "SkyExp2Quest", CFrame.new(-7906.81, 5634.66, -1411.99), CFrame.new(-7836.75, 5645.66, -1790.62)},
	{625, 649, "Galley Pirate", 1, "FountainQuest", CFrame.new(5259.81, 37.35, 4050.02), CFrame.new(5551.02, 78.90, 3930.41)},
	{650, 9999, "Galley Captain", 2, "FountainQuest", CFrame.new(5259.81, 37.35, 4050.02), CFrame.new(5441.95, 42.50, 4950.09)}
}

local Quests_W2 = {
	{700, 724, "Raider", 1, "Area1Quest", CFrame.new(-429.54, 71.76, 1836.18), CFrame.new(-728.32, 52.77, 2345.77)},
	{725, 774, "Mercenary", 2, "Area1Quest", CFrame.new(-429.54, 71.76, 1836.18), CFrame.new(-1004.32, 80.15, 1424.61)},
	{775, 799, "Swan Pirate", 1, "Area2Quest", CFrame.new(638.43, 71.76, 918.28), CFrame.new(1068.66, 137.61, 1322.10)},
	{800, 874, "Factory Staff", 2, "Area2Quest", CFrame.new(632.69, 73.10, 918.66), CFrame.new(73.07, 81.86, -27.47)},
	{875, 899, "Marine Lieutenant", 1, "MarineQuest3", CFrame.new(-2440.79, 71.71, -3216.06), CFrame.new(-2821.37, 75.89, -3070.08)},
	{900, 949, "Marine Captain", 2, "MarineQuest3", CFrame.new(-2440.79, 71.71, -3216.06), CFrame.new(-1861.23, 80.17, -3254.69)},
	{950, 974, "Zombie", 1, "ZombieQuest", CFrame.new(-5497.06, 47.59, -795.23), CFrame.new(-5657.77, 78.96, -928.68)},
	{975, 999, "Vampire", 2, "ZombieQuest", CFrame.new(-5497.06, 47.59, -795.23), CFrame.new(-6037.66, 32.18, -1340.65)},
	{1000, 1049, "Snow Trooper", 1, "SnowMountainQuest", CFrame.new(609.85, 400.11, -5372.25), CFrame.new(549.14, 427.38, -5563.69)},
	{1050, 1099, "Winter Warrior", 2, "SnowMountainQuest", CFrame.new(609.85, 400.11, -5372.25), CFrame.new(1142.74, 475.63, -5199.41)},
	{1100, 1124, "Lab Subordinate", 1, "IceSideQuest", CFrame.new(-6064.06, 15.24, -4902.97), CFrame.new(-5707.47, 15.95, -4513.39)},
	{1125, 1174, "Horned Warrior", 2, "IceSideQuest", CFrame.new(-6064.06, 15.24, -4902.97), CFrame.new(-6341.36, 15.95, -5723.16)},
	{1175, 1199, "Magma Ninja", 1, "FireSideQuest", CFrame.new(-5428.03, 15.06, -5299.43), CFrame.new(-5449.67, 76.65, -5808.20)},
	{1200, 1249, "Lava Pirate", 2, "FireSideQuest", CFrame.new(-5428.03, 15.06, -5299.43), CFrame.new(-5213.33, 49.73, -4701.45)},
	{1250, 1274, "Ship Deckhand", 1, "ShipQuest1", CFrame.new(1037.80, 125.09, 32911.60), CFrame.new(1212.01, 150.79, 33059.24)},
	{1275, 1299, "Ship Engineer", 2, "ShipQuest1", CFrame.new(1037.80, 125.09, 32911.60), CFrame.new(919.47, 43.54, 32779.96)},
	{1300, 1324, "Ship Steward", 1, "ShipQuest2", CFrame.new(968.80, 125.09, 33244.12), CFrame.new(919.43, 129.55, 33436.03)},
	{1325, 1349, "Ship Officer", 2, "ShipQuest2", CFrame.new(968.80, 125.09, 33244.12), CFrame.new(1036.01, 181.43, 33315.72)},
	{1350, 1374, "Arctic Warrior", 1, "FrostQuest", CFrame.new(5667.65, 26.79, -6486.08), CFrame.new(5966.24, 62.97, -6179.38)},
	{1375, 1424, "Snow Lurker", 2, "FrostQuest", CFrame.new(5667.65, 26.79, -6486.08), CFrame.new(5407.07, 69.19, -6880.88)},
	{1425, 1449, "Sea Soldier", 1, "ForgottenQuest", CFrame.new(-3054.44, 235.54, -10142.81), CFrame.new(-3028.22, 64.67, -9775.42)},
	{1450, 9999, "Water Fighter", 2, "ForgottenQuest", CFrame.new(-3054.44, 235.54, -10142.81), CFrame.new(-3352.90, 285.01, -10534.84)}
}

local Quests_W3 = {
	{1500, 1524, "Pirate Millionaire", 1, "PiratePortQuest", CFrame.new(-450.10, 107.68, 5950.72), CFrame.new(-245.99, 47.30, 5584.10)},
	{1525, 1574, "Pistol Billionaire", 2, "PiratePortQuest", CFrame.new(-450.10, 107.68, 5950.72), CFrame.new(-54.81, 83.76, 5947.84)},
	{1575, 1599, "Dragon Crew Warrior", 1, "DragonCrewQuest", CFrame.new(6750.49, 127.44, -711.03), CFrame.new(6709.76, 52.34, -1139.02)},
	{1600, 1624, "Dragon Crew Archer", 2, "DragonCrewQuest", CFrame.new(6750.49, 127.44, -711.03), CFrame.new(6668.76, 481.37, 329.12)},
	{1625, 1649, "Hydra Enforcer", 1, "VenomCrewQuest", CFrame.new(5206.40, 1004.10, 748.35), CFrame.new(4547.11, 1003.10, 334.19)},
	{1650, 1699, "Venomous Assailant", 2, "VenomCrewQuest", CFrame.new(5206.40, 1004.10, 748.35), CFrame.new(4674.92, 1134.82, 996.30)},
	{1700, 1724, "Marine Commodore", 1, "MarineTreeIsland", CFrame.new(2481.09, 74.27, -6779.64), CFrame.new(2577.25, 75.61, -7739.87)},
	{1725, 1774, "Marine Rear Admiral", 2, "MarineTreeIsland", CFrame.new(2481.09, 74.27, -6779.64), CFrame.new(3761.81, 123.91, -6823.52)},
	{1775, 1799, "Fishman Raider", 1, "DeepForestIsland3", CFrame.new(-10581.65, 330.87, -8761.18), CFrame.new(-10407.52, 331.76, -8368.51)},
	{1800, 1824, "Fishman Captain", 2, "DeepForestIsland3", CFrame.new(-10581.65, 330.87, -8761.18), CFrame.new(-10994.70, 352.38, -9002.11)},
	{1825, 1849, "Forest Pirate", 1, "DeepForestIsland", CFrame.new(-13234.04, 331.48, -7625.40), CFrame.new(-13274.47, 332.37, -7769.58)},
	{1850, 1899, "Mythological Pirate", 2, "DeepForestIsland", CFrame.new(-13234.04, 331.48, -7625.40), CFrame.new(-13680.60, 501.08, -6991.18)},
	{1900, 1924, "Jungle Pirate", 1, "DeepForestIsland2", CFrame.new(-12680.38, 389.97, -9902.01), CFrame.new(-12256.16, 331.73, -10485.83)},
	{1925, 1974, "Musketeer Pirate", 2, "DeepForestIsland2", CFrame.new(-12680.38, 389.97, -9902.01), CFrame.new(-13457.90, 391.54, -9859.17)},
	{1975, 1999, "Reborn Skeleton", 1, "HauntedQuest1", CFrame.new(-9479.21, 141.21, 5566.09), CFrame.new(-8763.72, 165.72, 6159.86)},
	{2000, 2024, "Living Zombie", 2, "HauntedQuest1", CFrame.new(-9479.21, 141.21, 5566.09), CFrame.new(-10144.13, 138.62, 5838.08)},
	{2025, 2049, "Demonic Soul", 1, "HauntedQuest2", CFrame.new(-9516.99, 172.01, 6078.46), CFrame.new(-9505.87, 172.10, 6158.99)},
	{2050, 2074, "Posessed Mummy", 2, "HauntedQuest2", CFrame.new(-9516.99, 172.01, 6078.46), CFrame.new(-9582.02, 6.25, 6205.47)},
	{2075, 2099, "Peanut Scout", 1, "NutsIslandQuest", CFrame.new(-2104.39, 38.10, -10194.21), CFrame.new(-2143.24, 47.72, -10029.99)},
	{2100, 2124, "Peanut President", 2, "NutsIslandQuest", CFrame.new(-2104.39, 38.10, -10194.21), CFrame.new(-1859.35, 38.10, -10422.42)},
	{2125, 2149, "Ice Cream Chef", 1, "IceCreamIslandQuest", CFrame.new(-820.64, 65.81, -10965.79), CFrame.new(-872.24, 65.81, -10919.95)},
	{2150, 2199, "Ice Cream Commander", 2, "IceCreamIslandQuest", CFrame.new(-820.64, 65.81, -10965.79), CFrame.new(-558.06, 112.04, -11290.77)},
	{2200, 2224, "Cookie Crafter", 1, "CakeQuest1", CFrame.new(-2021.32, 37.79, -12028.72), CFrame.new(-2374.13, 37.79, -12125.30)},
	{2225, 2249, "Cake Guard", 2, "CakeQuest1", CFrame.new(-2021.32, 37.79, -12028.72), CFrame.new(-1598.30, 43.77, -12244.58)},
	{2250, 2274, "Baking Staff", 1, "CakeQuest2", CFrame.new(-1927.91, 37.79, -12842.53), CFrame.new(-1887.80, 77.61, -12998.35)},
	{2275, 2299, "Head Baker", 2, "CakeQuest2", CFrame.new(-1927.91, 37.79, -12842.53), CFrame.new(-2216.18, 82.88, -12869.29)},
	{2300, 2324, "Cocoa Warrior", 1, "ChocQuest1", CFrame.new(233.22, 29.87, -12201.23), CFrame.new(-21.55, 80.57, -12352.38)},
	{2325, 2349, "Chocolate Bar Battler", 2, "ChocQuest1", CFrame.new(233.22, 29.87, -12201.23), CFrame.new(582.59, 77.18, -12463.16)},
	{2350, 2374, "Sweet Thief", 1, "ChocQuest2", CFrame.new(150.50, 30.69, -12774.50), CFrame.new(165.18, 76.05, -12600.83)},
	{2375, 2399, "Candy Rebel", 2, "ChocQuest2", CFrame.new(150.50, 30.69, -12774.50), CFrame.new(134.86, 77.24, -12876.54)},
	{2400, 2424, "Candy Pirate", 1, "CandyQuest1", CFrame.new(-1150.04, 20.37, -14446.33), CFrame.new(-1310.50, 26.01, -14562.40)},
	{2425, 2449, "Snow Demon", 2, "CandyQuest1", CFrame.new(-1150.04, 20.37, -14446.33), CFrame.new(-880.20, 71.24, -14538.60)},
	{2450, 2474, "Isle Outlaw", 1, "TikiQuest1", CFrame.new(-16547.74, 61.13, -173.41), CFrame.new(-16442.81, 116.13, -264.46)},
	{2475, 2524, "Island Boy", 2, "TikiQuest1", CFrame.new(-16547.74, 61.13, -173.41), CFrame.new(-16901.26, 84.06, -192.88)},
	{2525, 2549, "Isle Champion", 2, "TikiQuest2", CFrame.new(-16539.07, 55.68, 1051.57), CFrame.new(-16641.67, 235.78, 1031.28)},
	{2550, 2574, "Serpent Hunter", 1, "TikiQuest3", CFrame.new(-16665.19, 104.59, 1579.69), CFrame.new(-16521.06, 106.09, 1488.78)},
	{2575, 9999, "Skull Slayer", 2, "TikiQuest3", CFrame.new(-16665.19, 104.59, 1579.69), CFrame.new(-16855.04, 122.45, 1478.15)}
}

local Mon = ""
local LevelQuest = 1
local NameQuest = ""
local NameMon = ""
local CFrameQuest = CFrame.new()
local CFrameMon = CFrame.new()

local function CheckQuest()
	local data = LocalPlayer:WaitForChild("Data", 5)
	local lvl = data and data:WaitForChild("Level", 5) and data.Level.Value or 1
	local list = World1 and Quests_W1 or (World2 and Quests_W2 or (World3 and Quests_W3 or {}))

	for _, q in ipairs(list) do
		if lvl >= q[1] and lvl <= q[2] then
			Mon = q[3]
			LevelQuest = q[4]
			NameQuest = q[5]
			NameMon = q[3]
			CFrameQuest = q[6]
			CFrameMon = q[7]
			break
		end
	end
end

-- Submerged Island Level Progression (Lv 2600 - 2750)
local MonNew = ""
local LevelQuestNew = 1
local NameQuestNew = ""
local NameMonNew = ""
local CFrameQuestNew = CFrame.new()
local CFrameMonNew = CFrame.new()

local function CheckQuestNew()
	local data = LocalPlayer:WaitForChild("Data", 5)
	local lvl = data and data:WaitForChild("Level", 5) and data.Level.Value or 2600

	if lvl >= 2600 and lvl <= 2624 then
		MonNew = "Reef Bandit"
		LevelQuestNew = 1
		NameQuestNew = "SubmergedQuest1"
		NameMonNew = "Reef Bandit"
		CFrameQuestNew = CFrame.new(10882.264, -2086.322, 10034.226)
		CFrameMonNew = CFrame.new(10736.6191, -2087.8439, 9338.4882)
	elseif lvl >= 2625 and lvl <= 2649 then
		MonNew = "Coral Pirate"
		LevelQuestNew = 2
		NameQuestNew = "SubmergedQuest1"
		NameMonNew = "Coral Pirate"
		CFrameQuestNew = CFrame.new(10882.264, -2086.322, 10034.226)
		CFrameMonNew = CFrame.new(10965.1025, -2158.8842, 9177.2597)
	elseif lvl >= 2650 and lvl <= 2674 then
		MonNew = "Sea Chanter"
		LevelQuestNew = 1
		NameQuestNew = "SubmergedQuest2"
		NameMonNew = "Sea Chanter"
		CFrameQuestNew = CFrame.new(10882.264, -2086.322, 10034.226)
		CFrameMonNew = CFrame.new(10621.0342, -2087.844, 10102.0332)
	elseif lvl >= 2675 then
		MonNew = "Ocean Prophet"
		LevelQuestNew = 2
		NameQuestNew = "SubmergedQuest2"
		NameMonNew = "Ocean Prophet"
		CFrameQuestNew = CFrame.new(10882.264, -2086.322, 10034.226)
		CFrameMonNew = CFrame.new(11056.1445, -2001.6717, 10117.4493)
	end
end

-- ========================================================
-- BACKGROUND AUTO FARM WORKERS
-- ========================================================
-- Standard Auto Farm Level Worker
task.spawn(function()
	while task.wait(0.15) do
		if _G.AutoFarm then
			pcall(function()
				local char = LocalPlayer.Character
				local hrp = WaitHRP(LocalPlayer)
				if not char or not hrp or char.Humanoid.Health <= 0 then return end

				CheckQuest()
				local questGui = LocalPlayer.PlayerGui.Main.Quest

				if questGui.Visible then
					local title = questGui.Container.QuestTitle.Title.Text
					if not string.find(title, NameMon) then
						ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
						return
					end

					local targetMob = nil
					for _, mob in ipairs(workspace.Enemies:GetChildren()) do
						if mob.Name == Mon and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
							targetMob = mob
							break
						end
					end

					if targetMob then
						AutoHaki()
						EquipWeapon(_G.SelectWeapon or "Melee")

						local mobHrp = targetMob.HumanoidRootPart
						local farmPos = mobHrp.CFrame * CFrame.new(0, 25, 0)
						topos(farmPos)

						BringMob(Mon, mobHrp.CFrame)

						VirtualUser:CaptureController()
						VirtualUser:Button1Down(Vector2.new(640, 360))
						task.wait(0.05)
						VirtualUser:Button1Up(Vector2.new(640, 360))
					else
						topos(CFrameMon)
					end
				else
					if (hrp.Position - CFrameQuest.Position).Magnitude > 15 then
						topos(CFrameQuest)
					else
						ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest)
					end
				end
			end)
		end
	end
end)

-- Submerged Farm Level New Worker
task.spawn(function()
	while task.wait(0.15) do
		if _G.AutoFarmLevelNew then
			pcall(function()
				local char = LocalPlayer.Character
				local hrp = WaitHRP(LocalPlayer)
				if not char or not hrp or char.Humanoid.Health <= 0 then return end

				CheckQuestNew()
				local questGui = LocalPlayer.PlayerGui.Main.Quest

				if questGui.Visible then
					local title = questGui.Container.QuestTitle.Title.Text
					if not string.find(title, NameMonNew) then
						ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
						return
					end

					local targetMob = nil
					for _, mob in ipairs(workspace.Enemies:GetChildren()) do
						if mob.Name == MonNew and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
							targetMob = mob
							break
						end
					end

					if targetMob then
						AutoHaki()
						EquipWeapon(_G.SelectWeapon or "Melee")

						local mobHrp = targetMob.HumanoidRootPart
						local farmPos = mobHrp.CFrame * CFrame.new(0, 25, 0)
						topos(farmPos)

						BringMob(MonNew, mobHrp.CFrame)

						VirtualUser:CaptureController()
						VirtualUser:Button1Down(Vector2.new(640, 360))
						task.wait(0.05)
						VirtualUser:Button1Up(Vector2.new(640, 360))
					else
						topos(CFrameMonNew)
					end
				else
					if (hrp.Position - CFrameQuestNew.Position).Magnitude > 15 then
						topos(CFrameQuestNew)
					else
						ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", NameQuestNew, LevelQuestNew)
					end
				end
			end)
		end
	end
end)

-- Mob Aura Worker
task.spawn(function()
	while task.wait(0.2) do
		if _G.AutoNear then
			pcall(function()
				local char = LocalPlayer.Character
				local hrp = WaitHRP(LocalPlayer)
				if not char or not hrp or char.Humanoid.Health <= 0 then return end

				for _, mob in ipairs(workspace.Enemies:GetChildren()) do
					if not _G.AutoNear then break end
					if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
						if (hrp.Position - mob.HumanoidRootPart.Position).Magnitude <= 400 then
							AutoHaki()
							EquipWeapon(_G.SelectWeapon or "Melee")

							local mobHrp = mob.HumanoidRootPart
							topos(mobHrp.CFrame * CFrame.new(0, 25, 0))

							mobHrp.CanCollide = false
							mobHrp.Size = Vector3.new(50, 50, 50)
							mob.Humanoid.WalkSpeed = 0

							VirtualUser:CaptureController()
							VirtualUser:Button1Down(Vector2.new(640, 360))
							task.wait(0.05)
							VirtualUser:Button1Up(Vector2.new(640, 360))
						end
					end
				end
			end)
		end
	end
end)

-- Safe Mode Sentinel Worker
task.spawn(function()
	while task.wait(0.2) do
		if _G.SafeMode then
			pcall(function()
				local char = LocalPlayer.Character
				local hrp = WaitHRP(LocalPlayer)
				if char and hrp and char:FindFirstChild("Humanoid") then
					if char.Humanoid.Health > 0 and char.Humanoid.Health <= (char.Humanoid.MaxHealth * 0.25) then
						StopTween()
						local safeBV = hrp:FindFirstChild("SafeBV")
						if not safeBV then
							safeBV = Instance.new("BodyVelocity", hrp)
							safeBV.Name = "SafeBV"
							safeBV.MaxForce = Vector3.new(100000, 100000, 100000)
							safeBV.Velocity = Vector3.zero
						end
						hrp.CFrame = hrp.CFrame + Vector3.new(0, 250, 0)
						repeat task.wait(0.5) until not _G.SafeMode or char.Humanoid.Health >= (char.Humanoid.MaxHealth * 0.8)
						if hrp:FindFirstChild("SafeBV") then hrp.SafeBV:Destroy() end
					end
				end
			end)
		end
	end
end)

-- ========================================================
-- TAB: FARMING (LUNA INTERFACE)
-- ========================================================
local TabFarming = Window:CreateTab({
	Name        = "Farming",
	Icon        = "fitness_center",
	ImageSource = "Material",
	ShowTitle   = true
})

TabFarming:CreateSection("Combat Equipment")

_G.SelectWeapon = "Melee"
TabFarming:CreateDropdown({
	Name          = "Select Combat Tool",
	Description   = "Select weapon discipline for automated farming",
	Options       = {"Melee", "Sword", "Gun", "Blox Fruit"},
	CurrentOption = {"Melee"},
	MultipleOptions = false,
	Callback      = function(OptionTable)
		_G.SelectWeapon = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
	end
}, "CombatToolDropdown")

TabFarming:CreateSection("Level Progression (Main Farm)")

TabFarming:CreateToggle({
	Name         = "Auto Farm Level",
	Description  = "Automatically grinds quest progression from Level 1 to 2575+",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoFarm = State
		if not State then StopTween() end
	end
}, "AutoFarmLevelToggle")

TabFarming:CreateToggle({
	Name         = "Farm Level New (Submerged)",
	Description  = "Grinds Submerged Island quests (Level 2600 - 2750)",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoFarmLevelNew = State
		if not State then StopTween() end
	end
}, "AutoFarmLevelNewToggle")

TabFarming:CreateToggle({
	Name         = "Auto Kill Near (Mob Aura)",
	Description  = "Strikes all monsters within 400 studs proximity",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoNear = State
		if not State then StopTween() end
	end
}, "MobAuraToggle")

TabFarming:CreateSection("Defensive Safeguards")

TabFarming:CreateToggle({
	Name         = "Auto Buso Haki",
	Description  = "Ensures armament enhancement is constantly engaged",
	CurrentValue = true,
	Callback     = function(State)
		_G.AutoHaki = State
	end
}, "AutoHakiToggle")

TabFarming:CreateToggle({
	Name         = "Auto Safe Mode (Low HP)",
	Description  = "Elevates into stratosphere when health falls below 25%",
	CurrentValue = false,
	Callback     = function(State)
		_G.SafeMode = State
	end
}, "SafeModeToggle")

-- ========================================================
-- ARCHITECTURE BRIDGE: EXPOSE CORE TO SUBSEQUENT PARTS
-- ========================================================
getgenv().LouisHub = getgenv().LouisHub or {}
local Louis = getgenv().LouisHub

Louis.Window        = Window
Louis.Notify        = Notify
Louis.topos         = topos
Louis.StopTween     = StopTween
Louis.WaitHRP       = WaitHRP
Louis.CheckEntrance = CheckEntrance
Louis.EquipWeapon   = EquipWeapon
Louis.AutoHaki      = AutoHaki
Louis.BringMob      = BringMob
Louis.World1        = World1
Louis.World2        = World2
Louis.World3        = World3

Notify("Louis Hub", "Blox Fruits Part 1 (Core & Farm) Patched!", "check_circle")

-- ========================================================
--  LOUIS HUB - BLOX FRUITS (PRO MASTER SUITE)
--  Part 2: Bosses, Materials, Sea Events & Special Islands
-- ========================================================

local Louis         = getgenv().LouisHub or {}
local Window        = Louis.Window
local Notify        = Louis.Notify or function(...) end
local topos         = Louis.topos
local StopTween     = Louis.StopTween
local WaitHRP       = Louis.WaitHRP
local EquipWeapon   = Louis.EquipWeapon
local AutoHaki      = Louis.AutoHaki
local BringMob      = Louis.BringMob
local World1        = Louis.World1
local World2        = Louis.World2
local World3        = Louis.World3

if not Window then
	warn("[Louis Hub] Error: Window dari Part 1 tidak ditemukan! Pastikan Part 1 sudah terpasang di atas.")
	return
end

-- ========================================================
-- TAB: BOSS & MATERIALS
-- ========================================================
local TabBoss = Window:CreateTab({
	Name        = "Boss & Material",
	Icon        = "swords",
	ImageSource = "Material",
	ShowTitle   = true
})

TabBoss:CreateSection("Material Gathering")

local Materials = {
	["Radioactive"]   = {mob = "Factory Staff", pos = CFrame.new(-507.78, 73, -126.45)},
	["Mystic Droplet"]= {mob = "Water Fighter", pos = CFrame.new(-3352.9, 285.01, -10534.84)},
	["Magma Ore"]     = {mob = World1 and "Military Spy" or "Lava Pirate", pos = World1 and CFrame.new(-5850.28, 77.28, 8848.67) or CFrame.new(-5234.6, 51.95, -4732.27)},
	["Angel Wings"]   = {mob = "Royal Soldier", pos = CFrame.new(-7827.15, 5606.91, -1705.58)},
	["Leather"]       = {mob = World1 and "Pirate" or (World2 and "Marine Captain" or "Jungle Pirate"), pos = World1 and CFrame.new(-1211.87, 4.78, 3916.83) or (World2 and CFrame.new(-2010.5, 73, -3326.62) or CFrame.new(-11975.78, 331.77, -10620.03))},
	["Scrap Metal"]   = {mob = World1 and "Brute" or (World2 and "Mercenary" or "Pirate Millionaire"), pos = World1 and CFrame.new(-1132.42, 14.84, 4293.3) or (World2 and CFrame.new(-972.3, 73.04, 1419.29) or CFrame.new(-289.63, 43.82, 5583.66))},
	["Conjured Cocoa"]= {mob = "Chocolate Bar Battler", pos = CFrame.new(744.79, 24.76, -12637.72)},
	["Dragon Scale"]  = {mob = "Dragon Crew Warrior", pos = CFrame.new(5824.06, 51.38, -1106.69)},
	["Gunpowder"]     = {mob = "Pistol Billionaire", pos = CFrame.new(-379.61, 73.84, 5928.52)},
	["Fish Tail"]     = {mob = "Fishman Captain", pos = CFrame.new(-10961.01, 331.79, -8914.29)},
	["Mini Tusk"]     = {mob = "Mythological Pirate", pos = CFrame.new(-13516.04, 469.81, -6899.16)},
	["Ectoplasm"]     = {mob = "Ship Deckhand", pos = CFrame.new(911.35, 125.95, 33159.53)}
}

local MatList = {}
for k, _ in pairs(Materials) do table.insert(MatList, k) end
local selectedMaterial = MatList[1]

TabBoss:CreateDropdown({
	Name          = "Select Material",
	Description   = "Target item to farm automatically",
	Options       = MatList,
	CurrentOption = {MatList[1]},
	MultipleOptions = false,
	Callback      = function(OptionTable)
		selectedMaterial = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
	end
}, "SelectedMaterialDropdown")

TabBoss:CreateToggle({
	Name         = "Auto Farm Material",
	Description  = "Teleports and eliminates designated material mobs",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoFarmMaterial = State
		if not State then StopTween() end
	end
}, "AutoFarmMaterialToggle")

task.spawn(function()
	while task.wait(0.2) do
		if _G.AutoFarmMaterial and selectedMaterial and Materials[selectedMaterial] then
			pcall(function()
				local data = Materials[selectedMaterial]
				local mob = workspace.Enemies:FindFirstChild(data.mob)
				if mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
					AutoHaki()
					EquipWeapon(_G.SelectWeapon or "Melee")
					topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0))
					mob.HumanoidRootPart.CanCollide = false
					mob.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
					VirtualUser:CaptureController()
					VirtualUser:Button1Down(Vector2.new(640, 360))
					task.wait(0.05)
					VirtualUser:Button1Up(Vector2.new(640, 360))
				else
					topos(data.pos)
				end
			end)
		end
	end
end)

TabBoss:CreateSection("World Boss Combat")

local BossList = World1 and {
	"The Gorilla King", "Bobby", "Yeti", "Mob Leader", "Vice Admiral", "Warden",
	"Chief Warden", "Swan", "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God", "Cyborg", "Saber Expert"
} or (World2 and {
	"Diamond", "Jeremy", "Fajita", "Don Swan", "Smoke Admiral", "Cursed Captain",
	"Darkbeard", "Order", "Awakened Ice Admiral", "Tide Keeper"
} or (World3 and {
	"Stone", "Island Empress", "Hydra Leader", "Kilo Admiral", "Captain Elephant",
	"Beautiful Pirate", "rip_indra True Form", "Longma", "Soul Reaper", "Cake Queen", "Tyrant of the Skies"
} or {}))

local selectedBoss = BossList[1] or ""

TabBoss:CreateDropdown({
	Name          = "Select Boss",
	Description   = "Target boss instance to hunt",
	Options       = BossList,
	CurrentOption = {BossList[1] or "None"},
	MultipleOptions = false,
	Callback      = function(OptionTable)
		selectedBoss = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
	end
}, "SelectedBossDropdown")

local bossStatusLabel = TabBoss:CreateLabel({
	Text  = "Boss Status: Scanning...",
	Style = 2
})

task.spawn(function()
	while task.wait(1.5) do
		if selectedBoss and selectedBoss ~= "" then
			local found = workspace.Enemies:FindFirstChild(selectedBoss) or ReplicatedStorage:FindFirstChild(selectedBoss)
			pcall(function()
				bossStatusLabel:Set(found and ("Boss Status: " .. selectedBoss .. " [SPAWNED]") or ("Boss Status: " .. selectedBoss .. " [DORMANT]"))
			end)
		end
	end
end)

TabBoss:CreateToggle({
	Name         = "Auto Farm Selected Boss",
	Description  = "Automatically hunts and engages chosen boss",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoBoss = State
		if not State then StopTween() end
	end
}, "AutoBossToggle")

task.spawn(function()
	while task.wait(0.2) do
		if _G.AutoBoss and selectedBoss and selectedBoss ~= "" then
			pcall(function()
				local boss = workspace.Enemies:FindFirstChild(selectedBoss)
				if boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 and boss:FindFirstChild("HumanoidRootPart") then
					AutoHaki()
					EquipWeapon(_G.SelectWeapon or "Melee")
					topos(boss.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
					boss.HumanoidRootPart.CanCollide = false
					boss.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
					VirtualUser:CaptureController()
					VirtualUser:Button1Down(Vector2.new(640, 360))
					task.wait(0.05)
					VirtualUser:Button1Up(Vector2.new(640, 360))
				elseif ReplicatedStorage:FindFirstChild(selectedBoss) then
					local bPart = ReplicatedStorage:FindFirstChild(selectedBoss):FindFirstChild("HumanoidRootPart")
					if bPart then topos(bPart.CFrame * CFrame.new(0, 20, 0)) end
				end
			end)
		end
	end
end)

TabBoss:CreateSection("Special Raid Bosses")

TabBoss:CreateToggle({
	Name         = "Auto Kill Darkbeard (Sea 2)",
	Description  = "Tracks and attacks Darkbeard",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoDarkBoss = State
		if not State then StopTween() end
	end
}, "DarkbeardToggle")

task.spawn(function()
	while task.wait(0.2) do
		if _G.AutoDarkBoss then
			pcall(function()
				local db = workspace.Enemies:FindFirstChild("Darkbeard")
				if db and db:FindFirstChild("Humanoid") and db.Humanoid.Health > 0 and db:FindFirstChild("HumanoidRootPart") then
					AutoHaki()
					EquipWeapon(_G.SelectWeapon or "Melee")
					topos(db.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
					VirtualUser:CaptureController()
					VirtualUser:Button1Down(Vector2.new(640, 360))
					task.wait(0.05)
					VirtualUser:Button1Up(Vector2.new(640, 360))
				end
			end)
		end
	end
end)

TabBoss:CreateToggle({
	Name         = "Auto Kill Cursed Captain (Sea 2)",
	Description  = "Tracks and attacks Cursed Captain on Ship",
	CurrentValue = false,
	Callback     = function(State)
		_G.CursedCaptain = State
		if not State then StopTween() end
	end
}, "CursedCaptainToggle")

task.spawn(function()
	while task.wait(0.2) do
		if _G.CursedCaptain then
			pcall(function()
				local cc = workspace.Enemies:FindFirstChild("Cursed Captain")
				if cc and cc:FindFirstChild("Humanoid") and cc.Humanoid.Health > 0 and cc:FindFirstChild("HumanoidRootPart") then
					AutoHaki()
					EquipWeapon(_G.SelectWeapon or "Melee")
					topos(cc.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
					VirtualUser:CaptureController()
					VirtualUser:Button1Down(Vector2.new(640, 360))
					task.wait(0.05)
					VirtualUser:Button1Up(Vector2.new(640, 360))
				end
			end)
		end
	end
end)

TabBoss:CreateToggle({
	Name         = "Auto Kill rip_indra True Form (Sea 3)",
	Description  = "Tracks and attacks rip_indra at Castle on the Sea",
	CurrentValue = false,
	Callback     = function(State)
		_G.RipIndraKill = State
		if not State then StopTween() end
	end
}, "RipIndraToggle")

task.spawn(function()
	while task.wait(0.2) do
		if _G.RipIndraKill then
			pcall(function()
				local indra = workspace.Enemies:FindFirstChild("rip_indra True Form") or workspace.Enemies:FindFirstChild("rip_indra")
				if indra and indra:FindFirstChild("Humanoid") and indra.Humanoid.Health > 0 and indra:FindFirstChild("HumanoidRootPart") then
					AutoHaki()
					EquipWeapon(_G.SelectWeapon or "Melee")
					topos(indra.HumanoidRootPart.CFrame * CFrame.new(0, -35, 0))
					VirtualUser:CaptureController()
					VirtualUser:Button1Down(Vector2.new(640, 360))
					task.wait(0.05)
					VirtualUser:Button1Up(Vector2.new(640, 360))
				end
			end)
		end
	end
end)

-- ========================================================
-- TAB: SEA EVENTS (NAVAL OPERATIONS)
-- ========================================================
local TabSea = Window:CreateTab({
	Name        = "Sea Events",
	Icon        = "waves",
	ImageSource = "Material",
	ShowTitle   = true
})

TabSea:CreateSection("Naval Autonomous Navigation")

TabSea:CreateToggle({
	Name         = "Auto Sail Boat (Danger Zone 6)",
	Description  = "Purchases PirateBrigade and cruises to deep danger zones",
	CurrentValue = false,
	Callback     = function(State)
		_G.SailBoat = State
		if not State then StopTween() end
	end
}, "AutoSailBoatToggle")

task.spawn(function()
	while task.wait(1) do
		if _G.SailBoat and World3 then
			pcall(function()
				local enemies = workspace.Enemies
				local hasSeaMobs = enemies:FindFirstChild("Terrorshark") or enemies:FindFirstChild("Shark") or enemies:FindFirstChild("Piranha") or enemies:FindFirstChild("Fish Crew Member")
				
				if hasSeaMobs then
					if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
						LocalPlayer.Character.Humanoid.Sit = false
					end
					return
				end

				local boats = workspace.Boats
				local myBoat = boats:FindFirstChild("PirateBrigade")

				if not myBoat then
					topos(CFrame.new(-16927.4, 9.0, 433.8))
					task.wait(0.5)
					ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyBoat", "PirateBrigade")
				else
					local seat = myBoat:FindFirstChild("VehicleSeat")
					local char = LocalPlayer.Character
					if seat and char and char:FindFirstChild("Humanoid") then
						if not char.Humanoid.Sit then
							char.HumanoidRootPart.CFrame = seat.CFrame * CFrame.new(0, 2, 0)
						else
							seat.CFrame = CFrame.new(-37813.6, -0.3, 6105.1)
						end
					end
				end
			end)
		end
	end
end)

TabSea:CreateSection("Sea Monsters Elimination")

TabSea:CreateToggle({
	Name         = "Auto Kill Terrorshark",
	Description  = "Attacks Terrorshark and dodges Typhoon Splash",
	CurrentValue = false,
	Callback     = function(State)
		_G.Autoterrorshark = State
		if not State then StopTween() end
	end
}, "AutoTerrorsharkToggle")

task.spawn(function()
	while task.wait(0.15) do
		if _G.Autoterrorshark and World3 then
			pcall(function()
				local ts = workspace.Enemies:FindFirstChild("Terrorshark")
				if ts and ts:FindFirstChild("Humanoid") and ts.Humanoid.Health > 0 and ts:FindFirstChild("HumanoidRootPart") then
					if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
						LocalPlayer.Character.Humanoid.Sit = false
					end
					AutoHaki()
					EquipWeapon(_G.SelectWeapon or "Melee")

					local elevation = 60
					if workspace._WorldOrigin:FindFirstChild("Typhoon Splash") then
						elevation = 280 -- Menghindar ke atas dari skill Typhoon
					end

					topos(ts.HumanoidRootPart.CFrame * CFrame.new(0, elevation, 0))
					ts.HumanoidRootPart.CanCollide = false
					ts.Humanoid.WalkSpeed = 0

					VirtualUser:CaptureController()
					VirtualUser:Button1Down(Vector2.new(640, 360))
					task.wait(0.05)
					VirtualUser:Button1Up(Vector2.new(640, 360))
				end
			end)
		end
	end
end)

TabSea:CreateToggle({
	Name         = "Auto Kill Shark",
	Description  = "Eliminates basic predatory sharks",
	CurrentValue = false,
	Callback     = function(State)
		_G.KillShark = State
		if not State then StopTween() end
	end
}, "KillSharkToggle")

task.spawn(function()
	while task.wait(0.15) do
		if _G.KillShark and World3 then
			pcall(function()
				local shark = workspace.Enemies:FindFirstChild("Shark")
				if shark and shark:FindFirstChild("Humanoid") and shark.Humanoid.Health > 0 and shark:FindFirstChild("HumanoidRootPart") then
					AutoHaki()
					EquipWeapon(_G.SelectWeapon or "Melee")
					topos(shark.HumanoidRootPart.CFrame * CFrame.new(0, 35, 0))
					shark.HumanoidRootPart.CanCollide = false
					VirtualUser:CaptureController()
					VirtualUser:Button1Down(Vector2.new(640, 360))
					task.wait(0.05)
					VirtualUser:Button1Up(Vector2.new(640, 360))
				end
			end)
		end
	end
end)

TabSea:CreateToggle({
	Name         = "Auto Kill Piranha",
	Description  = "Eliminates sea piranhas",
	CurrentValue = false,
	Callback     = function(State)
		_G.KillPiranha = State
		if not State then StopTween() end
	end
}, "KillPiranhaToggle")

task.spawn(function()
	while task.wait(0.15) do
		if _G.KillPiranha and World3 then
			pcall(function()
				local piranha = workspace.Enemies:FindFirstChild("Piranha")
				if piranha and piranha:FindFirstChild("Humanoid") and piranha.Humanoid.Health > 0 and piranha:FindFirstChild("HumanoidRootPart") then
					AutoHaki()
					EquipWeapon(_G.SelectWeapon or "Melee")
					topos(piranha.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
					piranha.HumanoidRootPart.CanCollide = false
					VirtualUser:CaptureController()
					VirtualUser:Button1Down(Vector2.new(640, 360))
					task.wait(0.05)
					VirtualUser:Button1Up(Vector2.new(640, 360))
				end
			end)
		end
	end
end)

TabSea:CreateToggle({
	Name         = "Auto Kill Fish Crew Member",
	Description  = "Eliminates Fish Crew members",
	CurrentValue = false,
	Callback     = function(State)
		_G.KillFishCrew = State
		if not State then StopTween() end
	end
}, "KillFishCrewToggle")

task.spawn(function()
	while task.wait(0.15) do
		if _G.KillFishCrew and World3 then
			pcall(function()
				local crew = workspace.Enemies:FindFirstChild("Fish Crew Member")
				if crew and crew:FindFirstChild("Humanoid") and crew.Humanoid.Health > 0 and crew:FindFirstChild("HumanoidRootPart") then
					AutoHaki()
					EquipWeapon(_G.SelectWeapon or "Melee")
					topos(crew.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
					crew.HumanoidRootPart.CanCollide = false
					VirtualUser:CaptureController()
					VirtualUser:Button1Down(Vector2.new(640, 360))
					task.wait(0.05)
					VirtualUser:Button1Up(Vector2.new(640, 360))
				end
			end)
		end
	end
end)

-- ========================================================
-- TAB: SPECIAL ISLANDS (KITSUNE, MIRAGE, VOLCANO)
-- ========================================================
local TabSpecial = Window:CreateTab({
	Name        = "Special Islands",
	Icon        = "explore",
	ImageSource = "Material",
	ShowTitle   = true
})

TabSpecial:CreateSection("Kitsune Island Operations")

local kitsuneStatusLabel = TabSpecial:CreateLabel({
	Text  = "Kitsune Island: Scanning...",
	Style = 2
})

task.spawn(function()
	while task.wait(2) do
		local kIsland = workspace.Map:FindFirstChild("KitsuneIsland")
		pcall(function()
			kitsuneStatusLabel:Set(kIsland and "Kitsune Island: [ACTIVE IN SERVER]" or "Kitsune Island: [NOT SPAWNED]")
		end)
	end
end)

TabSpecial:CreateToggle({
	Name         = "Auto Tween Kitsune Shrine",
	Description  = "Transports directly to the active Kitsune neon altar",
	CurrentValue = false,
	Callback     = function(State)
		_G.TweenToKitsune = State
		if not State then StopTween() end
	end
}, "KitsuneShrineToggle")

task.spawn(function()
	while task.wait(0.5) do
		if _G.TweenToKitsune then
			pcall(function()
				local shrine = workspace.Map:FindFirstChild("KitsuneIsland") and workspace.Map.KitsuneIsland:FindFirstChild("ShrineActive")
				if shrine then
					local neon = shrine:FindFirstChild("NeonShrinePart") or shrine:FindFirstChildWhichIsA("BasePart")
					if neon then topos(neon.CFrame * CFrame.new(0, 5, 10)) end
				end
			end)
		end
	end
end)

TabSpecial:CreateToggle({
	Name         = "Auto Collect Azure Ember",
	Description  = "Instantly snaps to collected blue spirit embers",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoAzuerEmber = State
	end
}, "AzureEmberToggle")

task.spawn(function()
	while task.wait(0.1) do
		if _G.AutoAzuerEmber then
			pcall(function()
				if workspace:FindFirstChild("AttachedAzureEmber") or workspace:FindFirstChild("EmberTemplate") then
					local ember = workspace:FindFirstChild("EmberTemplate") or workspace:FindFirstChild("AttachedAzureEmber")
					local part = ember:FindFirstChild("Part") or ember:FindFirstChildWhichIsA("BasePart")
					local hrp = WaitHRP(LocalPlayer)
					if part and hrp then
						hrp.CFrame = part.CFrame
					end
				end
			end)
		end
	end
end)

TabSpecial:CreateSection("Mirage Island Operations")

local mirageStatusLabel = TabSpecial:CreateLabel({
	Text  = "Mirage Island: Scanning...",
	Style = 2
})

task.spawn(function()
	while task.wait(2) do
		local mIsland = workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island")
		pcall(function()
			mirageStatusLabel:Set(mIsland and "Mirage Island: [ACTIVE IN SERVER]" or "Mirage Island: [NOT SPAWNED]")
		end)
	end
end)

TabSpecial:CreateToggle({
	Name         = "Auto Tween Mirage Island",
	Description  = "Flies directly above Mirage Island center",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoMysticIsland = State
		if not State then StopTween() end
	end
}, "AutoMirageIslandToggle")

task.spawn(function()
	while task.wait(0.5) do
		if _G.AutoMysticIsland then
			pcall(function()
				local loc = workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island")
				if loc then topos(loc.CFrame * CFrame.new(0, 320, 0)) end
			end)
		end
	end
end)

TabSpecial:CreateToggle({
	Name         = "Look at Moon + Race V3 (Key T)",
	Description  = "Aims camera directly at the moon and triggers Race V3 ability",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoDooHee = State
	end
}, "LookMoonToggle")

task.spawn(function()
	while task.wait(1) do
		if _G.AutoDooHee then
			pcall(function()
				local cam = workspace.CurrentCamera
				local moonDir = game:GetService("Lighting"):GetMoonDirection()
				if cam and moonDir then
					cam.CFrame = CFrame.lookAt(cam.CFrame.Position, cam.CFrame.Position + moonDir * 100)
					task.wait(0.2)
					VirtualUser:SendKeyEvent(true, Enum.KeyCode.T, false, game)
					task.wait(0.05)
					VirtualUser:SendKeyEvent(false, Enum.KeyCode.T, false, game)
				end
			end)
		end
	end
end)

TabSpecial:CreateToggle({
	Name         = "Auto Find & Tween to Gear",
	Description  = "Scans Mirage Island for the hidden neon Gear and collects it",
	CurrentValue = false,
	Callback     = function(State)
		_G.TweenMGear = State
		if not State then StopTween() end
	end
}, "FindGearToggle")

task.spawn(function()
	while task.wait(0.5) do
		if _G.TweenMGear then
			pcall(function()
				local mystic = workspace.Map:FindFirstChild("MysticIsland")
				if mystic then
					for _, part in ipairs(mystic:GetChildren()) do
						if part:IsA("MeshPart") and part.Material == Enum.Material.Neon then
							topos(part.CFrame)
							break
						end
					end
				end
			end)
		end
	end
end)

TabSpecial:CreateSection("Prehistoric / Volcano Island Operations")

TabSpecial:CreateButton({
	Name        = "Craft Volcanic Magnet",
	Description = "Direct server request to craft the Volcanic Magnet item",
	Callback    = function()
		ReplicatedStorage.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "Volcanic Magnet")
		Notify("Louis Hub", "Crafting request for Volcanic Magnet sent.", "check_circle")
	end
})

local prehistoricStatusLabel = TabSpecial:CreateLabel({
	Text  = "Prehistoric Island: Scanning...",
	Style = 2
})

task.spawn(function()
	while task.wait(2) do
		local pIsland = workspace.Map:FindFirstChild("PrehistoricIsland")
		pcall(function()
			prehistoricStatusLabel:Set(pIsland and "Prehistoric Island: [ACTIVE IN SERVER]" or "Prehistoric Island: [NOT SPAWNED]")
		end)
	end
end)

TabSpecial:CreateToggle({
	Name         = "Auto Defend Prehistoric (Break Lava)",
	Description  = "Eliminates lethal lava rocks inside the volcano",
	CurrentValue = false,
	Callback     = function(State)
		_G.DefendVolcano = State
		if not State then StopTween() end
	end
}, "DefendVolcanoToggle")

task.spawn(function()
	while task.wait(0.3) do
		if _G.DefendVolcano then
			pcall(function()
				local island = workspace.Map:FindFirstChild("PrehistoricIsland")
				if island and island:FindFirstChild("Core") then
					local rocks = island.Core:FindFirstChild("VolcanoRocks")
					if rocks then
						for _, rModel in ipairs(rocks:GetChildren()) do
							local rock = rModel:FindFirstChild("volcanorock")
							if rock and rock:IsA("MeshPart") then
								local c = rock.Color
								if c == Color3.fromRGB(185, 53, 56) or c == Color3.fromRGB(185, 53, 57) then
									topos(rock.CFrame)
									AutoHaki()
									EquipWeapon(_G.SelectWeapon or "Melee")
									VirtualUser:CaptureController()
									VirtualUser:Button1Down(Vector2.new(640, 360))
									task.wait(0.05)
									VirtualUser:Button1Up(Vector2.new(640, 360))
									break
								end
							end
						end
					end
				end
			end)
		end
	end
end)

TabSpecial:CreateToggle({
	Name         = "Auto Kill Lava Golem",
	Description  = "Defeats spawned Lava Golems on Prehistoric Island",
	CurrentValue = false,
	Callback     = function(State)
		_G.KillGolem = State
		if not State then StopTween() end
	end
}, "KillGolemToggle")

task.spawn(function()
	while task.wait(0.2) do
		if _G.KillGolem then
			pcall(function()
				local golem = workspace.Enemies:FindFirstChild("Lava Golem")
				if golem and golem:FindFirstChild("Humanoid") and golem.Humanoid.Health > 0 and golem:FindFirstChild("HumanoidRootPart") then
					AutoHaki()
					EquipWeapon(_G.SelectWeapon or "Melee")
					topos(golem.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
					golem.HumanoidRootPart.CanCollide = false
					VirtualUser:CaptureController()
					VirtualUser:Button1Down(Vector2.new(640, 360))
					task.wait(0.05)
					VirtualUser:Button1Up(Vector2.new(640, 360))
				end
			end)
		end
	end
end)

TabSpecial:CreateToggle({
	Name         = "Auto Collect Dino Bones",
	Description  = "Snaps to scattered DinoBone artifacts on the island",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoCollectBone = State
	end
}, "CollectDinoBonesToggle")

task.spawn(function()
	while task.wait(0.5) do
		if _G.AutoCollectBone then
			pcall(function()
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("BasePart") and obj.Name == "DinoBone" then
						topos(obj.CFrame)
						task.wait(0.3)
					end
				end
			end)
		end
	end
end)

TabSpecial:CreateToggle({
	Name         = "Auto Collect Dragon Eggs",
	Description  = "Submits egg pickup remote upon discovery",
	CurrentValue = false,
	Callback     = function(State)
		_G.CollectEgg = State
	end
}, "CollectEggToggle")

task.spawn(function()
	while task.wait(1) do
		if _G.CollectEgg then
			pcall(function()
				ReplicatedStorage.Modules.Net["RE/CollectedDragonEgg"]:FireServer()
			end)
		end
	end
end)

-- Bridge extension
Louis.TabBoss    = TabBoss
Louis.TabSea     = TabSea
Louis.TabSpecial = TabSpecial

Notify("Louis Hub", "Blox Fruits Part 2 (Boss, Sea & Islands) Loaded!", "check_circle")

-- ========================================================
--  LOUIS HUB - BLOX FRUITS (PRO MASTER SUITE)
--  Part 3: Race V4, Raids/Dungeons, Quest Puzzles & Fishing
-- ========================================================

local Louis         = getgenv().LouisHub or {}
local Window        = Louis.Window
local Notify        = Louis.Notify or function(...) end
local topos         = Louis.topos
local StopTween     = Louis.StopTween
local WaitHRP       = Louis.WaitHRP
local EquipWeapon   = Louis.EquipWeapon
local AutoHaki      = Louis.AutoHaki
local BringMob      = Louis.BringMob
local World1        = Louis.World1
local World2        = Louis.World2
local World3        = Louis.World3

if not Window then
	warn("[Louis Hub] Error: Window dari Part 1 tidak ditemukan! Pastikan Part 1 dan Part 2 sudah terpasang di atas.")
	return
end

-- ========================================================
-- TAB: RACE V4 & TEMPLE OF TIME
-- ========================================================
local TabRaceV4 = Window:CreateTab({
	Name        = "Race V4",
	Icon        = "military_tech",
	ImageSource = "Material",
	ShowTitle   = true
})

TabRaceV4:CreateSection("Temple of Time Navigation")

TabRaceV4:CreateButton({
	Name        = "Teleport to Great Tree Peak",
	Description = "Transports to the summit of the Great Tree",
	Callback    = function()
		topos(CFrame.new(3030.39, 2280.61, -7320.18))
	end
})

TabRaceV4:CreateButton({
	Name        = "Teleport to Temple of Time",
	Description = "Transports directly inside the Temple of Time",
	Callback    = function()
		topos(CFrame.new(28286.35, 14895.30, 102.62))
	end
})

TabRaceV4:CreateButton({
	Name        = "Teleport to Lever Pull",
	Description = "Positions character at the secret V4 activation lever",
	Callback    = function()
		topos(CFrame.new(28575.18, 14936.62, 72.31))
	end
})

TabRaceV4:CreateButton({
	Name        = "Teleport to The Clock Room",
	Description = "Transports directly in front of the giant clock",
	Callback    = function()
		topos(CFrame.new(29553.78, 15066.61, -88.27))
	end
})

TabRaceV4:CreateSection("Race Trial Doors & Ancient One")

TabRaceV4:CreateButton({
	Name        = "Teleport to My Race Trial Door",
	Description = "Automatically detects your current race and enters respective door",
	Callback    = function()
		local myRace = LocalPlayer:WaitForChild("Data"):WaitForChild("Race").Value
		topos(CFrame.new(28286.35, 14895.30, 102.62))
		task.wait(0.3)

		if myRace == "Human" then
			topos(CFrame.new(29221.82, 14890.97, -205.99))
		elseif myRace == "Skypiea" or myRace == "Sky" then
			topos(CFrame.new(28960.15, 14919.62, 235.03))
		elseif myRace == "Fishman" then
			topos(CFrame.new(28231.17, 14890.97, -211.64))
		elseif myRace == "Cyborg" then
			topos(CFrame.new(28502.68, 14895.97, -423.72))
		elseif myRace == "Ghoul" then
			topos(CFrame.new(28674.24, 14890.67, 445.43))
		elseif myRace == "Mink" then
			topos(CFrame.new(29012.34, 14890.97, -380.14))
		end
		Notify("Louis Hub", "Navigated to " .. myRace .. " Trial Door", "check_circle")
	end
})

TabRaceV4:CreateButton({
	Name        = "Buy Ancient One Training Upgrade",
	Description = "Submits server request to upgrade your equipped V4 gear",
	Callback    = function()
		ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeRace", "Buy")
		Notify("Louis Hub", "Race upgrade transaction dispatched.", "check_circle")
	end
})

TabRaceV4:CreateSection("Trial Automation & PvP")

TabRaceV4:CreateToggle({
	Name         = "Auto Complete Race Trial",
	Description  = "Automatically clears trial objectives (Mink, Fishman, Human, Ghoul, etc.)",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoQuestRace = State
		if not State then StopTween() end
	end
}, "AutoCompleteTrialToggle")

task.spawn(function()
	while task.wait(0.2) do
		if _G.AutoQuestRace and World3 then
			pcall(function()
				local race = LocalPlayer.Data.Race.Value

				if race == "Fishman" then
					local sb = workspace.SeaBeasts:FindFirstChild("SeaBeast1")
					if sb and sb:FindFirstChild("HumanoidRootPart") then
						AutoHaki()
						EquipWeapon(_G.SelectWeapon or "Melee")
						topos(sb.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
						VirtualUser:CaptureController()
						VirtualUser:Button1Down(Vector2.new(640, 360))
						task.wait(0.05)
						VirtualUser:Button1Up(Vector2.new(640, 360))
					end
				elseif race == "Mink" then
					for _, obj in ipairs(workspace:GetDescendants()) do
						if obj.Name == "StartPoint" and obj:IsA("BasePart") then
							topos(obj.CFrame * CFrame.new(0, 3, 0))
							_G.AutoQuestRace = false
							break
						end
					end
				elseif race == "Human" or race == "Ghoul" then
					for _, enemy in ipairs(workspace.Enemies:GetChildren()) do
						if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
							AutoHaki()
							EquipWeapon(_G.SelectWeapon or "Melee")
							topos(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0))
							enemy.HumanoidRootPart.CanCollide = false
							VirtualUser:CaptureController()
							VirtualUser:Button1Down(Vector2.new(640, 360))
							task.wait(0.05)
							VirtualUser:Button1Up(Vector2.new(640, 360))
							break
						end
					end
				elseif race == "Cyborg" then
					topos(CFrame.new(28654, 14898.78, -30))
				elseif race == "Skypiea" or race == "Sky" then
					local cyl = workspace.Map:FindFirstChild("SkyTrial") and workspace.Map.SkyTrial:FindFirstChild("snowisland_Cylinder.081", true)
					if cyl and cyl:IsA("BasePart") then
						topos(cyl.CFrame)
					end
				end
			end)
		end
	end
end)

TabRaceV4:CreateToggle({
	Name         = "Auto Eliminate Players in Trial",
	Description  = "Automatically targets and defeats opposing trial contestants",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoKillV4 = State
		if not State then StopTween() end
	end
}, "KillTrialPlayersToggle")

task.spawn(function()
	while task.wait(0.15) do
		if _G.AutoKillV4 then
			pcall(function()
				local hrp = WaitHRP(LocalPlayer)
				if not hrp then return end

				for _, char in ipairs(workspace.Characters:GetChildren()) do
					if char.Name ~= LocalPlayer.Name and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart") then
						if (hrp.Position - char.HumanoidRootPart.Position).Magnitude <= 260 then
							AutoHaki()
							EquipWeapon(_G.SelectWeapon or "Melee")
							topos(char.HumanoidRootPart.CFrame * CFrame.new(0, 5, 2))
							char.HumanoidRootPart.CanCollide = false
							char.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
							VirtualUser:CaptureController()
							VirtualUser:Button1Down(Vector2.new(640, 360))
							task.wait(0.05)
							VirtualUser:Button1Up(Vector2.new(640, 360))
							break
						end
					end
				end
			end)
		end
	end
end)

-- ========================================================
-- TAB: RAIDS & DUNGEONS
-- ========================================================
local TabRaid = Window:CreateTab({
	Name        = "Raids",
	Icon        = "military_tech",
	ImageSource = "Material",
	ShowTitle   = true
})

TabRaid:CreateSection("Fruit Raids Operations")

local RaidChips = {
	"Flame", "Ice", "Sand", "Dark", "Light", "Magma",
	"Quake", "Buddha", "Spider", "Phoenix", "Lightning", "Dough"
}
local selectedRaidChip = RaidChips[1]

TabRaid:CreateDropdown({
	Name          = "Select Raid Chip",
	Description   = "Designate chip element for purchase",
	Options       = RaidChips,
	CurrentOption = {RaidChips[1]},
	MultipleOptions = false,
	Callback      = function(OptionTable)
		selectedRaidChip = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
	end
}, "RaidChipDropdown")

TabRaid:CreateToggle({
	Name         = "Auto Buy Selected Chip",
	Description  = "Automatically purchases designated microchip with Beli/Frags",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoBuyChip = State
	end
}, "AutoBuyChipToggle")

task.spawn(function()
	while task.wait(1) do
		if _G.AutoBuyChip and selectedRaidChip then
			pcall(function()
				ReplicatedStorage.Remotes.CommF_:InvokeServer("RaidsNpc", "Select", selectedRaidChip)
			end)
		end
	end
end)

TabRaid:CreateToggle({
	Name         = "Auto Start Raid",
	Description  = "Teleports to raid lab, sets spawn, and triggers activation button",
	CurrentValue = false,
	Callback     = function(State)
		_G.StartRaid = State
		if not State then StopTween() end
	end
}, "AutoStartRaidToggle")

task.spawn(function()
	while task.wait(1.5) do
		if _G.StartRaid then
			pcall(function()
				local bp = LocalPlayer.Backpack
				local char = LocalPlayer.Character
				local hasChip = (bp and bp:FindFirstChild("Special Microchip")) or (char and char:FindFirstChild("Special Microchip"))

				if hasChip and not LocalPlayer.PlayerGui.Main.Timer.Visible then
					if World2 then
						topos(CFrame.new(-6438.7, 250.6, -4501.5))
						task.wait(0.5)
						ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSpawnPoint")
						local btn = workspace.Map.CircleIsland.RaidSummon2.Button.Main.ClickDetector
						if btn then fireclickdetector(btn) end
					elseif World3 then
						ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-5075.5, 314.5, -3150.0))
						task.wait(0.5)
						topos(CFrame.new(-5017.4, 314.8, -2823.0))
						ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSpawnPoint")
						local btn = workspace.Map["Boat Castle"].RaidSummon2.Button.Main.ClickDetector
						if btn then fireclickdetector(btn) end
					end
				end
			end)
		end
	end
end)

TabRaid:CreateToggle({
	Name         = "Auto Clear Raid Islands (1 - 5)",
	Description  = "Eliminates waves and advances through all 5 raid islands",
	CurrentValue = false,
	Callback     = function(State)
		_G.Dungeon = State
		if not State then StopTween() end
	end
}, "AutoDungeonToggle")

local function GetActiveRaidIsland()
	local locs = workspace._WorldOrigin.Locations
	local hrp = WaitHRP(LocalPlayer)
	if not hrp then return nil end

	for i = 5, 1, -1 do
		local island = locs:FindFirstChild("Island " .. i)
		if island and (island.Position - hrp.Position).Magnitude <= 4500 then
			return island
		end
	end
	return nil
end

task.spawn(function()
	while task.wait(0.2) do
		if _G.Dungeon then
			pcall(function()
				local targetMob = nil
				for _, enemy in ipairs(workspace.Enemies:GetChildren()) do
					if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and enemy:FindFirstChild("HumanoidRootPart") then
						targetMob = enemy
						break
					end
				end

				if targetMob then
					AutoHaki()
					EquipWeapon(_G.SelectWeapon or "Melee")
					topos(targetMob.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0))
					targetMob.HumanoidRootPart.CanCollide = false
					VirtualUser:CaptureController()
					VirtualUser:Button1Down(Vector2.new(640, 360))
					task.wait(0.05)
					VirtualUser:Button1Up(Vector2.new(640, 360))
				else
					local currentIsland = GetActiveRaidIsland()
					if currentIsland then
						topos(currentIsland.CFrame * CFrame.new(0, 50, 0))
					end
				end
			end)
		end
	end
end)

TabRaid:CreateToggle({
	Name         = "Auto Buy Cheap Fruits (Chip Fuel)",
	Description  = "Purchases low-cost fruits from dealer inventory to exchange for chips",
	CurrentValue = false,
	Callback     = function(State)
		_G.Autofruit = State
	end
}, "AutoCheapFruitToggle")

task.spawn(function()
	while task.wait(2) do
		if _G.Autofruit then
			local cheapList = {"Rocket-Rocket", "Spin-Spin", "Chop-Chop", "Spring-Spring", "Bomb-Bomb", "Smoke-Smoke"}
			for _, fruit in ipairs(cheapList) do
				pcall(function()
					ReplicatedStorage.Remotes.CommF_:InvokeServer("LoadFruit", fruit)
				end)
			end
		end
	end
end)

TabRaid:CreateSection("Law Raid (Order) - Sea 2")

TabRaid:CreateButton({
	Name        = "Buy Law Microchip ($1,000 Frags)",
	Description = "Acquires Law raid access chip",
	Callback    = function()
		ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Microchip", "2")
		Notify("Louis Hub", "Purchased Law Microchip.", "check_circle")
	end
})

TabRaid:CreateButton({
	Name        = "Start Law Raid",
	Description = "Activates summon button on Circle Island",
	Callback    = function()
		pcall(function()
			fireclickdetector(workspace.Map.CircleIsland.RaidSummon.Button.Main.ClickDetector)
			Notify("Louis Hub", "Law Raid initiated.", "check_circle")
		end)
	end
})

TabRaid:CreateToggle({
	Name         = "Auto Farm Law Boss (Order)",
	Description  = "Engages and eliminates Law raid boss automatically",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoLawRaid = State
		if not State then StopTween() end
	end
}, "AutoLawToggle")

task.spawn(function()
	while task.wait(0.2) do
		if _G.AutoLawRaid and World2 then
			pcall(function()
				local order = workspace.Enemies:FindFirstChild("Order")
				if order and order:FindFirstChild("Humanoid") and order.Humanoid.Health > 0 and order:FindFirstChild("HumanoidRootPart") then
					AutoHaki()
					EquipWeapon(_G.SelectWeapon or "Melee")
					topos(order.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
					order.HumanoidRootPart.CanCollide = false
					VirtualUser:CaptureController()
					VirtualUser:Button1Down(Vector2.new(640, 360))
					task.wait(0.05)
					VirtualUser:Button1Up(Vector2.new(640, 360))
				end
			end)
		end
	end
end)

-- ========================================================
-- TAB: QUEST ITEMS & PUZZLES
-- ========================================================
local TabQuest = Window:CreateTab({
	Name        = "Quest & Items",
	Icon        = "extension",
	ImageSource = "Material",
	ShowTitle   = true
})

TabQuest:CreateSection("Sea 1: Saber V1 Sword Quest")

TabQuest:CreateToggle({
	Name         = "Auto Complete Saber Quest",
	Description  = "Automates 5 Jungle plates, Desert torch, ice cup, Mob Leader & Saber Expert",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoSaber = State
		if not State then StopTween() end
	end
}, "AutoSaberToggle")

task.spawn(function()
	while task.wait(0.5) do
		if _G.AutoSaber and World1 then
			pcall(function()
				local comm = ReplicatedStorage.Remotes.CommF_
				local junglePlate = workspace.Map.Jungle.QuestPlates.Door

				-- Step 1: Injak 5 Plat Jungle
				if junglePlate.Transparency == 0 then
					local plates = workspace.Map.Jungle.QuestPlates
					for i = 1, 5 do
						local p = plates:FindFirstChild("Plate" .. i)
						if p and p:FindFirstChild("Button") then
							topos(p.Button.CFrame)
							task.wait(0.6)
						end
					end
					return
				end

				-- Step 2: Ambil Obor & Bakar Pintu Desert
				local desertDoor = workspace.Map.Desert.Burn.Part
				if desertDoor.Transparency == 0 then
					local bp = LocalPlayer.Backpack
					local char = LocalPlayer.Character
					local torch = (bp and bp:FindFirstChild("Torch")) or (char and char:FindFirstChild("Torch"))
					if torch then
						EquipWeapon("Torch")
						topos(CFrame.new(1114.61, 5.04, 4350.22))
					else
						topos(CFrame.new(-1610.00, 11.50, 164.00))
					end
					return
				end

				-- Step 3: Isi Air Cup di Snow Cave & Kasih ke Sick Man
				local sickStatus = comm:InvokeServer("ProQuestProgress", "SickMan")
				if sickStatus == 0 then
					comm:InvokeServer("ProQuestProgress", "GetCup")
					task.wait(0.2)
					EquipWeapon("Cup")
					topos(CFrame.new(1398.7, 37.3, -1322.6))
					task.wait(0.5)
					comm:InvokeServer("ProQuestProgress", "FillCup", LocalPlayer.Character:FindFirstChild("Cup"))
					task.wait(0.2)
					topos(CFrame.new(1389.7, 88.1, -1298.9))
					task.wait(0.5)
					comm:InvokeServer("ProQuestProgress", "SickMan")
					return
				end

				-- Step 4: Bunuh Mob Leader & Ambil Relic
				local richStatus = comm:InvokeServer("ProQuestProgress", "RichSon")
				if richStatus == 0 then
					local mobLeader = workspace.Enemies:FindFirstChild("Mob Leader")
					if mobLeader and mobLeader:FindFirstChild("Humanoid") and mobLeader.Humanoid.Health > 0 then
						AutoHaki()
						EquipWeapon(_G.SelectWeapon or "Melee")
						topos(mobLeader.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0))
						VirtualUser:CaptureController()
						VirtualUser:Button1Down(Vector2.new(640, 360))
						task.wait(0.05)
						VirtualUser:Button1Up(Vector2.new(640, 360))
					else
						topos(CFrame.new(-2850.20, 7.39, 5354.99))
					end
					return
				elseif richStatus == 1 then
					comm:InvokeServer("ProQuestProgress", "RichSon")
					task.wait(0.5)
					EquipWeapon("Relic")
					topos(CFrame.new(-1404.91, 29.97, 3.80))
					return
				end

				-- Step 5: Bunuh Saber Expert
				local saber = workspace.Enemies:FindFirstChild("Saber Expert")
				if saber and saber:FindFirstChild("Humanoid") and saber.Humanoid.Health > 0 then
					AutoHaki()
					EquipWeapon(_G.SelectWeapon or "Melee")
					topos(saber.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0))
					VirtualUser:CaptureController()
					VirtualUser:Button1Down(Vector2.new(640, 360))
					task.wait(0.05)
					VirtualUser:Button1Up(Vector2.new(640, 360))
				else
					topos(CFrame.new(-1442.16, 29.87, -28.35))
				end
			end)
		end
	end
end)

TabQuest:CreateSection("Sea 2: Bartilo & Sea 3 Unlocks")

TabQuest:CreateToggle({
	Name         = "Auto Complete Bartilo Quest",
	Description  = "Defeats 50 Swan Pirates, eliminates Jeremy, and solves Colosseum plate code",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoBartilo = State
		if not State then StopTween() end
	end
}, "AutoBartiloToggle")

task.spawn(function()
	while task.wait(0.5) do
		if _G.AutoBartilo and World2 then
			pcall(function()
				local comm = ReplicatedStorage.Remotes.CommF_
				local progress = comm:InvokeServer("BartiloQuestProgress", "Bartilo")

				if progress == 0 then
					-- Kills 50 Swan Pirates
					local qGui = LocalPlayer.PlayerGui.Main.Quest
					if not qGui.Visible then
						topos(CFrame.new(-456.28, 73.02, 299.89))
						task.wait(0.5)
						comm:InvokeServer("StartQuest", "BartiloQuest", 1)
					else
						local mob = workspace.Enemies:FindFirstChild("Swan Pirate")
						if mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
							AutoHaki()
							EquipWeapon(_G.SelectWeapon or "Melee")
							topos(mob.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0))
							VirtualUser:CaptureController()
							VirtualUser:Button1Down(Vector2.new(640, 360))
							task.wait(0.05)
							VirtualUser:Button1Up(Vector2.new(640, 360))
						else
							topos(CFrame.new(932.62, 156.10, 1180.27))
						end
					end
				elseif progress == 1 then
					-- Kills Jeremy
					local jeremy = workspace.Enemies:FindFirstChild("Jeremy")
					if jeremy and jeremy:FindFirstChild("Humanoid") and jeremy.Humanoid.Health > 0 then
						AutoHaki()
						EquipWeapon(_G.SelectWeapon or "Melee")
						topos(jeremy.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
						VirtualUser:CaptureController()
						VirtualUser:Button1Down(Vector2.new(640, 360))
						task.wait(0.05)
						VirtualUser:Button1Up(Vector2.new(640, 360))
					else
						topos(CFrame.new(2099.88, 448.93, 648.99))
					end
				elseif progress == 2 then
					-- Kode Meja Colosseum
					local codes = {
						CFrame.new(-1850.49, 13.17, 1750.89), CFrame.new(-1858.87, 19.37, 1712.01),
						CFrame.new(-1803.94, 16.57, 1750.89), CFrame.new(-1858.55, 16.86, 1724.79),
						CFrame.new(-1869.54, 15.98, 1681.00), CFrame.new(-1800.09, 16.49, 1684.52),
						CFrame.new(-1819.26, 14.79, 1717.90), CFrame.new(-1813.51, 14.86, 1724.79)
					}
					for _, pos in ipairs(codes) do
						topos(pos)
						task.wait(0.8)
					end
					_G.AutoBartilo = false
					Notify("Louis Hub", "Bartilo Quest Solved!", "check_circle")
				end
			end)
		end
	end
end)

TabQuest:CreateToggle({
	Name         = "Auto Travel Sea 3 Quest",
	Description  = "Defeats rip_indra inside Castle on the Sea to unlock Third Sea portal",
	CurrentValue = false,
	Callback     = function(State)
		_G.ThirdSea = State
		if not State then StopTween() end
	end
}, "AutoThirdSeaToggle")

task.spawn(function()
	while task.wait(0.5) do
		if _G.ThirdSea and World2 then
			pcall(function()
				local comm = ReplicatedStorage.Remotes.CommF_
				comm:InvokeServer("ZQuestProgress", "Begin")
				local indra = workspace.Enemies:FindFirstChild("rip_indra")
				if indra and indra:FindFirstChild("Humanoid") and indra.Humanoid.Health > 0 then
					AutoHaki()
					EquipWeapon(_G.SelectWeapon or "Melee")
					topos(indra.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
					VirtualUser:CaptureController()
					VirtualUser:Button1Down(Vector2.new(640, 360))
					task.wait(0.05)
					VirtualUser:Button1Up(Vector2.new(640, 360))
				else
					comm:InvokeServer("TravelZou")
				end
			end)
		end
	end
end)

TabQuest:CreateSection("Sea 3: Legendary Swords (Yama & Tushita)")

TabQuest:CreateToggle({
	Name         = "Auto Pull Yama Sword",
	Description  = "Checks 30+ Elite Hunter kills and claims Yama from the waterfall cavern",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoYama = State
	end
}, "AutoYamaToggle")

task.spawn(function()
	while task.wait(1) do
		if _G.AutoYama and World3 then
			pcall(function()
				local eliteProgress = ReplicatedStorage.Remotes.CommF_:InvokeServer("EliteHunter", "Progress")
				if eliteProgress and eliteProgress >= 30 then
					local sealed = workspace.Map:FindFirstChild("Waterfall") and workspace.Map.Waterfall:FindFirstChild("SealedKatana")
					if sealed and sealed:FindFirstChild("Handle") and sealed.Handle:FindFirstChild("ClickDetector") then
						topos(sealed.Handle.CFrame)
						task.wait(0.5)
						fireclickdetector(sealed.Handle.ClickDetector)
					end
				end
			end)
		end
	end
end)

TabQuest:CreateToggle({
	Name         = "Auto Light Tushita Torches",
	Description  = "Equips Holy Torch and sequentially lights all 5 secret torches in Floating Turtle",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoHolyTorch = State
		if not State then StopTween() end
	end
}, "AutoHolyTorchToggle")

task.spawn(function()
	while task.wait(1) do
		if _G.AutoHolyTorch and World3 then
			pcall(function()
				EquipWeapon("Holy Torch")
				local torchList = {
					CFrame.new(-10752, 417, -9366), CFrame.new(-11672, 334, -9474),
					CFrame.new(-12132, 521, -10655), CFrame.new(-13336, 486, -6985),
					CFrame.new(-13489, 332, -7925)
				}
				for _, tPos in ipairs(torchList) do
					if not _G.AutoHolyTorch then break end
					topos(tPos)
					task.wait(1.2)
				end
				_G.AutoHolyTorch = false
				Notify("Louis Hub", "All 5 Tushita Torches Activated!", "check_circle")
			end)
		end
	end
end)

TabQuest:CreateToggle({
	Name         = "Auto Defeat Longma (Tushita Drop)",
	Description  = "Hunts Longma in his secret domain to obtain Tushita sword",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoGetTushita = State
		if not State then StopTween() end
	end
}, "AutoLongmaToggle")

task.spawn(function()
	while task.wait(0.2) do
		if _G.AutoGetTushita and World3 then
			pcall(function()
				local longma = workspace.Enemies:FindFirstChild("Longma")
				if longma and longma:FindFirstChild("Humanoid") and longma.Humanoid.Health > 0 then
					AutoHaki()
					EquipWeapon(_G.SelectWeapon or "Melee")
					topos(longma.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
					VirtualUser:CaptureController()
					VirtualUser:Button1Down(Vector2.new(640, 360))
					task.wait(0.05)
					VirtualUser:Button1Up(Vector2.new(640, 360))
				else
					topos(CFrame.new(-10217.9, 338.3, -9443.4))
				end
			end)
		end
	end
end)

-- ========================================================
-- TAB: AUTO FISHING
-- ========================================================
local TabFishing = Window:CreateTab({
	Name        = "Fishing",
	Icon        = "phishing",
	ImageSource = "Material",
	ShowTitle   = true
})

TabFishing:CreateSection("Equipment & Lures")

local Rods = {"Fishing Rod", "Gold Rod", "Shark Rod", "Shell Rod", "Treasure Rod"}
local selectedRod = Rods[1]

TabFishing:CreateDropdown({
	Name          = "Select Fishing Rod",
	Description   = "Rod model equipped for casting",
	Options       = Rods,
	CurrentOption = {Rods[1]},
	MultipleOptions = false,
	Callback      = function(OptionTable)
		selectedRod = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
	end
}, "FishingRodDropdown")

local Baits = {"Basic Bait", "Kelp Bait", "Good Bait", "Abyssal Bait", "Frozen Bait", "Epic Bait", "Carnivore Bait"}
local selectedBait = Baits[1]

TabFishing:CreateDropdown({
	Name          = "Select Fishing Lure",
	Description   = "Bait applied to increase catch rate",
	Options       = Baits,
	CurrentOption = {Baits[1]},
	MultipleOptions = false,
	Callback      = function(OptionTable)
		selectedBait = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
		pcall(function()
			local fReq = ReplicatedStorage:FindFirstChild("FishReplicated") and ReplicatedStorage.FishReplicated:FindFirstChild("FishingRequest")
			if fReq then fReq:InvokeServer("SelectBait", selectedBait) end
		end)
	end
}, "FishingBaitDropdown")

TabFishing:CreateSection("Fishing Automation Engine")

TabFishing:CreateToggle({
	Name         = "Auto Fishing Active",
	Description  = "Automatically casts line, waits for bites, and hooks fish instantly",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoFishing = State
	end
}, "AutoFishingToggle")

task.spawn(function()
	while task.wait(0.2) do
		if _G.AutoFishing then
			pcall(function()
				local fRep = ReplicatedStorage:FindFirstChild("FishReplicated")
				local fReq = fRep and fRep:FindFirstChild("FishingRequest")
				if not fReq then return end

				local char = LocalPlayer.Character
				local hrp = WaitHRP(LocalPlayer)
				if not char or not hrp then return end

				local tool = char:FindFirstChildOfClass("Tool")
				if not tool or tool.Name ~= selectedRod then
					local bpTool = LocalPlayer.Backpack:FindFirstChild(selectedRod)
					if bpTool then char.Humanoid:EquipTool(bpTool) end
					tool = char:FindFirstChild(selectedRod)
				end

				if tool then
					local state = tool:GetAttribute("State") or tool:GetAttribute("ServerState")
					if state == "ReeledIn" or not state then
						local castPos = hrp.Position + (hrp.CFrame.LookVector * 25)
						fReq:InvokeServer("StartCasting")
						task.wait(0.1)
						fReq:InvokeServer("CastLineAtLocation", castPos, 100, true)
					elseif state == "Biting" then
						fReq:InvokeServer("Catching", true)
						task.wait(0.1)
						fReq:InvokeServer("Catch", 1)
					end
				end
			end)
		end
	end
end)

-- Bridge extension
Louis.TabRaceV4  = TabRaceV4
Louis.TabRaid    = TabRaid
Louis.TabQuest   = TabQuest
Louis.TabFishing = TabFishing

Notify("Louis Hub", "Blox Fruits Part 3 (Race V4, Raids, Quests & Fishing) Loaded!", "check_circle")

-- ========================================================
--  LOUIS HUB - BLOX FRUITS (PRO MASTER SUITE)
--  Part 4: Fruits, Teleport, ESP, Shop, Utility & Codes [PATCHED]
-- ========================================================

local Louis         = getgenv().LouisHub or {}
local Window        = Louis.Window
local Notify        = Louis.Notify or function(...) end
local topos         = Louis.topos
local StopTween     = Louis.StopTween
local WaitHRP       = Louis.WaitHRP
local EquipWeapon   = Louis.EquipWeapon
local AutoHaki      = Louis.AutoHaki
local BringMob      = Louis.BringMob
local World1        = Louis.World1
local World2        = Louis.World2
local World3        = Louis.World3

if not Window then
	warn("[Louis Hub] Error: Window dari Part 1 tidak ditemukan! Pastikan Part 1, 2, dan 3 sudah terpasang di atas.")
	return
end

-- ========================================================
-- TAB: FRUITS & STOCK
-- ========================================================
local TabFruit = Window:CreateTab({
	Name        = "Fruit & Stock",
	Icon        = "apple",
	ImageSource = "Material",
	ShowTitle   = true
})

TabFruit:CreateSection("Fruit Inventory Management")

TabFruit:CreateToggle({
	Name         = "Auto Store Fruits",
	Description  = "Automatically deposits any devil fruits in backpack or hand into treasure inventory",
	CurrentValue = false,
	Callback     = function(State)
		_G.AutoStoreFruit = State
	end
}, "AutoStoreFruitToggle")

task.spawn(function()
	while task.wait(1) do
		if _G.AutoStoreFruit then
			pcall(function()
				local bp = LocalPlayer:FindFirstChild("Backpack")
				if bp then
					for _, item in ipairs(bp:GetChildren()) do
						if item:IsA("Tool") and (string.find(item.Name, "Fruit") or item.ToolTip == "Blox Fruit") then
							ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", item:GetAttribute("OriginalName") or item.Name, item)
						end
					end
				end
				local char = LocalPlayer.Character
				if char then
					for _, item in ipairs(char:GetChildren()) do
						if item:IsA("Tool") and (string.find(item.Name, "Fruit") or item.ToolTip == "Blox Fruit") then
							ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", item:GetAttribute("OriginalName") or item.Name, item)
						end
					end
				end
			end)
		end
	end
end)

TabFruit:CreateButton({
	Name        = "Random Fruit (Blox Fruit Gacha)",
	Description = "Purchases random fruit from Blox Fruit Gacha Cousin",
	Callback    = function()
		local res = ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
		if res then
			Notify("Louis Hub", "Gacha transaction completed.", "card_giftcard")
		end
	end
})

TabFruit:CreateSection("Fruit Sniper & Tracking")

TabFruit:CreateToggle({
	Name         = "Auto Teleport to Fruit Spawn (Tween)",
	Description  = "Flies directly to any naturally spawned fruit on the current map",
	CurrentValue = false,
	Callback     = function(State)
		_G.TweenFruit = State
		if not State then StopTween() end
	end
}, "TweenFruitToggle")

task.spawn(function()
	while task.wait(1) do
		if _G.TweenFruit then
			pcall(function()
				for _, obj in ipairs(workspace:GetChildren()) do
					if string.find(obj.Name, "Fruit") and obj:FindFirstChild("Handle") then
						topos(obj.Handle.CFrame)
						break
					end
				end
			end)
		end
	end
end)

TabFruit:CreateToggle({
	Name         = "Instant Snap to Fruit (Grab Fruit)",
	Description  = "Directly snaps character coordinates onto target fruit",
	CurrentValue = false,
	Callback     = function(State)
		_G.GrabFruit = State
	end
}, "GrabFruitToggle")

task.spawn(function()
	while task.wait(0.5) do
		if _G.GrabFruit then
			pcall(function()
				local hrp = WaitHRP(LocalPlayer)
				for _, obj in ipairs(workspace:GetChildren()) do
					if string.find(obj.Name, "Fruit") and obj:FindFirstChild("Handle") and hrp then
						hrp.CFrame = obj.Handle.CFrame
						break
					end
				end
			end)
		end
	end
end)

TabFruit:CreateSection("Live Merchant Fruit Stock")

local function formatPrice(num)
	local text = tostring(num)
	repeat
		local count
		text, count = text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	until count == 0
	return text
end

local function GetStockText()
	local text = "Advance Fruit Stock:\n"
	local ok1, res1 = pcall(function() return ReplicatedStorage.Remotes.CommF_:InvokeServer("GetFruits", true) end)
	if ok1 and res1 then
		local found = false
		for _, item in pairs(res1) do
			if item.OnSale then
				text = text .. "- " .. item.Name .. " ($" .. formatPrice(item.Price) .. ")\n"
				found = true
			end
		end
		if not found then text = text .. "- Stock Kosong.\n" end
	else
		text = text .. "- Gagal mengambil data.\n"
	end

	text = text .. "\nNormal Fruit Stock:\n"
	local ok2, res2 = pcall(function() return ReplicatedStorage.Remotes.CommF_:InvokeServer("GetFruits") end)
	if ok2 and res2 then
		local found = false
		for _, item in pairs(res2) do
			if item.OnSale then
				text = text .. "- " .. item.Name .. " ($" .. formatPrice(item.Price) .. ")\n"
				found = true
			end
		end
		if not found then text = text .. "- Stock Kosong.\n" end
	else
		text = text .. "- Gagal mengambil data.\n"
	end
	return text
end

local stockLabel = TabFruit:CreateLabel({
	Text  = "Memuat data stock...",
	Style = 2
})

TabFruit:CreateButton({
	Name        = "Refresh Fruit Stock Catalog",
	Description = "Pulls latest merchant availability from server",
	Callback    = function()
		stockLabel:Set(GetStockText())
		Notify("Louis Hub", "Fruit stock refreshed.", "refresh")
	end
})
pcall(function() stockLabel:Set(GetStockText()) end)

-- ========================================================
-- TAB: NAVIGATION & TELEPORT
-- ========================================================
local TabTeleport = Window:CreateTab({
	Name        = "Navigation",
	Icon        = "place",
	ImageSource = "Material",
	ShowTitle   = true
})

TabTeleport:CreateSection("Island Destinations (Auto-Filtered)")

local Islands_W1 = {
	["WindMill"]       = CFrame.new(979.79, 16.51, 1429.04),
	["Marine"]         = CFrame.new(-2566.43, 6.85, 2045.25),
	["Middle Town"]    = CFrame.new(-690.33, 15.09, 1582.23),
	["Jungle"]         = CFrame.new(-1612.79, 36.85, 149.12),
	["Pirate Village"] = CFrame.new(-1181.30, 4.75, 3803.54),
	["Desert"]         = CFrame.new(944.15, 20.92, 4373.30),
	["Snow Island"]    = CFrame.new(1347.80, 104.66, -1319.73),
	["MarineFord"]     = CFrame.new(-4914.82, 50.96, 4281.02),
	["Colosseum"]      = CFrame.new(-1427.62, 7.28, -2792.77),
	["Sky Island 1"]   = CFrame.new(-4869.10, 733.46, -2667.01),
	["Prison"]         = CFrame.new(4875.33, 5.65, 734.85),
	["Magma Village"]  = CFrame.new(-5247.71, 12.88, 8504.96),
	["Fountain City"]  = CFrame.new(5127.12, 59.50, 4105.44)
}

local Islands_W2 = {
	["The Cafe"]          = CFrame.new(-380.47, 77.22, 255.82),
	["Flamingo Mansion"]  = CFrame.new(-483.73, 332.03, 595.32),
	["Green Zone"]        = CFrame.new(-2448.53, 73.01, -3210.63),
	["Zombie Island"]     = CFrame.new(-5622.03, 492.19, -781.78),
	["Two Snow Mountain"] = CFrame.new(753.14, 408.23, -5274.61),
	["Punk Hazard"]       = CFrame.new(-6127.65, 15.95, -5040.28),
	["Cursed Ship"]       = CFrame.new(923.40, 125.05, 32885.87),
	["Ice Castle"]        = CFrame.new(6148.41, 294.38, -6741.11),
	["Forgotten Island"]  = CFrame.new(-3032.76, 317.89, -10075.37)
}

local Islands_W3 = {
	["Mansion"]           = CFrame.new(-12471.17, 374.94, -7551.67),
	["Port Town"]         = CFrame.new(-226.75, 20.60, 5538.34),
	["Great Tree"]        = CFrame.new(2681.27, 1682.80, -7190.98),
	["Castle On The Sea"] = CFrame.new(-5083.26, 314.60, -3175.67),
	["Hydra Island"]      = CFrame.new(5291.24, 1005.44, 393.76),
	["Floating Turtle"]   = CFrame.new(-13274.52, 531.82, -7579.22),
	["Haunted Castle"]    = CFrame.new(-9515.37, 164.00, 5786.06),
	["Ice Cream Island"]  = CFrame.new(-902.56, 79.93, -10988.84),
	["Peanut Island"]     = CFrame.new(-2062.74, 50.47, -10232.56),
	["Cake Island"]       = CFrame.new(-1884.77, 19.32, -11666.89),
	["Cocoa Island"]      = CFrame.new(87.94, 73.55, -12319.46),
	["Candy Island"]      = CFrame.new(-1014.42, 149.11, -14555.96),
	["Tiki Outpost"]      = CFrame.new(-16218.68, 9.08, 445.61),
	["Dragon Dojo"]       = CFrame.new(5743.31, 1206.91, 936.01)
}

local currentIslandTable = World1 and Islands_W1 or (World2 and Islands_W2 or (World3 and Islands_W3 or {}))
local islandKeys = {}
for name, _ in pairs(currentIslandTable) do table.insert(islandKeys, name) end
local selectedTargetIsland = islandKeys[1] or ""

TabTeleport:CreateDropdown({
	Name          = "Select Island",
	Description   = "Destinations available in your current Sea",
	Options       = #islandKeys > 0 and islandKeys or {"No Island Found"},
	CurrentOption = {#islandKeys > 0 and islandKeys[1] or "No Island Found"},
	MultipleOptions = false,
	Callback      = function(OptionTable)
		selectedTargetIsland = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
	end
}, "IslandDropdown")

TabTeleport:CreateButton({
	Name        = "Teleport to Selected Island",
	Description = "Executes smooth transit to chosen island",
	Callback    = function()
		if currentIslandTable[selectedTargetIsland] then
			topos(currentIslandTable[selectedTargetIsland])
			Notify("Louis Hub", "Navigating to " .. selectedTargetIsland, "place")
		end
	end
})

TabTeleport:CreateSection("World Travel (Sea 1, 2, 3)")

TabTeleport:CreateButton({
	Name        = "Travel to First Sea",
	Description = "Transfers server to Sea 1",
	Callback    = function()
		ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelMain")
	end
})

TabTeleport:CreateButton({
	Name        = "Travel to Second Sea (Dressrosa)",
	Description = "Transfers server to Sea 2",
	Callback    = function()
		ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
	end
})

TabTeleport:CreateButton({
	Name        = "Travel to Third Sea (Zou)",
	Description = "Transfers server to Sea 3",
	Callback    = function()
		ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou")
	end
})

-- ========================================================
-- TAB: VISUALS & ESP
-- ========================================================
local TabESP = Window:CreateTab({
	Name        = "Visuals",
	Icon        = "visibility",
	ImageSource = "Material",
	ShowTitle   = true
})

TabESP:CreateSection("Player ESP Radar")

local ESP_TAG = "LouisHub_ESP"

local function UpdatePlayerESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		pcall(function()
			if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") then
				local head = plr.Character.Head
				if _G.ESPPlayer then
					local hrp = WaitHRP(LocalPlayer)
					local dist = hrp and math.floor((hrp.Position - head.Position).Magnitude / 3) or 0
					local hp = math.floor((plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth) * 100)

					local gui = head:FindFirstChild(ESP_TAG)
					if not gui then
						gui = Instance.new("BillboardGui", head)
						gui.Name = ESP_TAG
						gui.Size = UDim2.new(1, 200, 1, 30)
						gui.AlwaysOnTop = true
						gui.Adornee = head
						gui.ExtentsOffset = Vector3.new(0, 2, 0)

						local lbl = Instance.new("TextLabel", gui)
						lbl.Name = "InfoLabel"
						lbl.Size = UDim2.new(1, 0, 1, 0)
						lbl.BackgroundTransparency = 1
						lbl.Font = Enum.Font.GothamBold
						lbl.TextSize = 13
						lbl.TextStrokeTransparency = 0.5
						lbl.TextColor3 = (plr.Team == LocalPlayer.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
					end
					gui.InfoLabel.Text = plr.Name .. " | " .. dist .. "m\nHP: " .. hp .. "%"
				else
					if head:FindFirstChild(ESP_TAG) then head[ESP_TAG]:Destroy() end
				end
			end
		end)
	end
end

TabESP:CreateToggle({
	Name         = "Player ESP",
	Description  = "Displays player names, distance and health percentage",
	CurrentValue = false,
	Callback     = function(State)
		_G.ESPPlayer = State
		if not State then UpdatePlayerESP() end
	end
}, "PlayerESPToggle")

TabESP:CreateSection("Object & Resource ESP")

local function UpdateChestESP()
	for _, chest in ipairs(CollectionService:GetTagged("_ChestTagged")) do
		pcall(function()
			if _G.ChestESP and not chest:GetAttribute("IsDisabled") then
				local hrp = WaitHRP(LocalPlayer)
				local dist = hrp and math.floor((hrp.Position - chest:GetPivot().Position).Magnitude / 3) or 0
				local gui = chest:FindFirstChild(ESP_TAG)
				if not gui then
					gui = Instance.new("BillboardGui", chest)
					gui.Name = ESP_TAG
					gui.Size = UDim2.new(1, 150, 1, 30)
					gui.AlwaysOnTop = true
					gui.Adornee = chest

					local lbl = Instance.new("TextLabel", gui)
					lbl.Name = "Text"
					lbl.Size = UDim2.new(1, 0, 1, 0)
					lbl.BackgroundTransparency = 1
					lbl.Font = Enum.Font.GothamBold
					lbl.TextSize = 12
					lbl.TextStrokeTransparency = 0.5
					lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
				end
				gui.Text.Text = "Chest | " .. dist .. "m"
			else
				if chest:FindFirstChild(ESP_TAG) then chest[ESP_TAG]:Destroy() end
			end
		end)
	end
end

TabESP:CreateToggle({
	Name         = "Chest ESP",
	Description  = "Highlights world gold, silver, and diamond chests",
	CurrentValue = false,
	Callback     = function(State)
		_G.ChestESP = State
		if not State then UpdateChestESP() end
	end
}, "ChestESPToggle")

local function UpdateFruitESP()
	for _, item in ipairs(workspace:GetChildren()) do
		pcall(function()
			if string.find(item.Name, "Fruit") and item:FindFirstChild("Handle") then
				local handle = item.Handle
				if _G.FruitESP then
					local hrp = WaitHRP(LocalPlayer)
					local dist = hrp and math.floor((hrp.Position - handle.Position).Magnitude / 3) or 0
					local gui = handle:FindFirstChild(ESP_TAG)
					if not gui then
						gui = Instance.new("BillboardGui", handle)
						gui.Name = ESP_TAG
						gui.Size = UDim2.new(1, 150, 1, 30)
						gui.AlwaysOnTop = true
						gui.Adornee = handle

						local lbl = Instance.new("TextLabel", gui)
						lbl.Name = "Text"
						lbl.Size = UDim2.new(1, 0, 1, 0)
						lbl.BackgroundTransparency = 1
						lbl.Font = Enum.Font.GothamBold
						lbl.TextSize = 13
						lbl.TextStrokeTransparency = 0.5
						lbl.TextColor3 = Color3.fromRGB(255, 85, 85)
					end
					gui.Text.Text = item.Name .. "\n" .. dist .. "m"
				else
					if handle:FindFirstChild(ESP_TAG) then handle[ESP_TAG]:Destroy() end
				end
			end
		end)
	end
end

TabESP:CreateToggle({
	Name         = "Fruit ESP",
	Description  = "Highlights dropped or spawned devil fruits across the map",
	CurrentValue = false,
	Callback     = function(State)
		_G.FruitESP = State
		if not State then UpdateFruitESP() end
	end
}, "FruitESPToggle")

local function UpdateFlowerESP()
	for _, item in ipairs(workspace:GetChildren()) do
		pcall(function()
			if item.Name == "Flower1" or item.Name == "Flower2" then
				if _G.FlowerESP then
					local hrp = WaitHRP(LocalPlayer)
					local dist = hrp and math.floor((hrp.Position - item.Position).Magnitude / 3) or 0
					local gui = item:FindFirstChild(ESP_TAG)
					if not gui then
						gui = Instance.new("BillboardGui", item)
						gui.Name = ESP_TAG
						gui.Size = UDim2.new(1, 150, 1, 30)
						gui.AlwaysOnTop = true
						gui.Adornee = item

						local lbl = Instance.new("TextLabel", gui)
						lbl.Name = "Text"
						lbl.Size = UDim2.new(1, 0, 1, 0)
						lbl.BackgroundTransparency = 1
						lbl.Font = Enum.Font.GothamBold
						lbl.TextSize = 12
						lbl.TextStrokeTransparency = 0.5
						lbl.TextColor3 = (item.Name == "Flower1") and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(255, 50, 50)
					end
					gui.Text.Text = (item.Name == "Flower1" and "Blue Flower" or "Red Flower") .. " | " .. dist .. "m"
				else
					if item:FindFirstChild(ESP_TAG) then item[ESP_TAG]:Destroy() end
				end
			end
		end)
	end
end

TabESP:CreateToggle({
	Name         = "Flower ESP (Race V2)",
	Description  = "Highlights blue and red quest flowers in Sea 2",
	CurrentValue = false,
	Callback     = function(State)
		_G.FlowerESP = State
		if not State then UpdateFlowerESP() end
	end
}, "FlowerESPToggle")

local function UpdateBerryESP()
	for _, bush in ipairs(CollectionService:GetTagged("BerryBush")) do
		pcall(function()
			if _G.BerryESP and bush.Parent then
				local hrp = WaitHRP(LocalPlayer)
				local dist = hrp and math.floor((hrp.Position - bush:GetPivot().Position).Magnitude / 3) or 0
				local gui = bush.Parent:FindFirstChild(ESP_TAG)
				if not gui then
					gui = Instance.new("BillboardGui", bush.Parent)
					gui.Name = ESP_TAG
					gui.Size = UDim2.new(1, 150, 1, 30)
					gui.AlwaysOnTop = true
					gui.Adornee = bush.Parent
					gui.ExtentsOffset = Vector3.new(0, 2, 0)

					local lbl = Instance.new("TextLabel", gui)
					lbl.Name = "Text"
					lbl.Size = UDim2.new(1, 0, 1, 0)
					lbl.BackgroundTransparency = 1
					lbl.Font = Enum.Font.GothamBold
					lbl.TextSize = 12
					lbl.TextStrokeTransparency = 0.5
					lbl.TextColor3 = Color3.fromRGB(255, 255, 0)
				end
				gui.Text.Text = "Berry Bush | " .. dist .. "m"
			else
				if bush.Parent and bush.Parent:FindFirstChild(ESP_TAG) then
					bush.Parent[ESP_TAG]:Destroy()
				end
			end
		end)
	end
end

TabESP:CreateToggle({
	Name         = "Berry Bush ESP",
	Description  = "Highlights wild berry harvesting bushes",
	CurrentValue = false,
	Callback     = function(State)
		_G.BerryESP = State
		if not State then UpdateBerryESP() end
	end
}, "BerryESPToggle")

task.spawn(function()
	while task.wait(1.5) do
		if _G.ESPPlayer then UpdatePlayerESP() end
		if _G.ChestESP then UpdateChestESP() end
		if _G.FruitESP then UpdateFruitESP() end
		if _G.FlowerESP then UpdateFlowerESP() end
		if _G.BerryESP then UpdateBerryESP() end
	end
end)

-- ========================================================
-- TAB: SHOP & CRAFTING (PATCHED: NO ADDBUTTON CRASH)
-- ========================================================
local TabShop = Window:CreateTab({
	Name        = "Shop",
	Icon        = "shopping_cart",
	ImageSource = "Material",
	ShowTitle   = true
})

TabShop:CreateSection("Fighting Styles (Melee V1 & V2)")

TabShop:CreateButton({Name = "Buy Black Leg ($150k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyBlackLeg") end})
TabShop:CreateButton({Name = "Buy Electro ($550k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyElectro") end})
TabShop:CreateButton({Name = "Buy Water Kung Fu ($750k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyFishmanKarate") end})
TabShop:CreateButton({Name = "Buy Dragon Claw (1.5k F)", Callback = function()
	ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "1")
	ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "2")
end})

TabShop:CreateButton({Name = "Buy Superhuman ($3M)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySuperhuman") end})
TabShop:CreateButton({Name = "Buy Death Step ($5M + 5k F)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyDeathStep") end})
TabShop:CreateButton({Name = "Buy Sharkman Karate ($2.5M + 5k F)", Callback = function()
	ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySharkmanKarate", true)
	ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySharkmanKarate")
end})
TabShop:CreateButton({Name = "Buy Electric Claw ($3M + 5k F)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyElectricClaw") end})
TabShop:CreateButton({Name = "Buy Dragon Talon ($3M + 5k F)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyDragonTalon") end})
TabShop:CreateButton({Name = "Buy Godhuman ($5M + 5k F)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyGodhuman") end})
TabShop:CreateButton({Name = "Buy Sanguine Art ($5M + 5k F)", Callback = function()
	ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySanguineArt", true)
	ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySanguineArt")
end})

TabShop:CreateSection("Abilities & Enhancements")

TabShop:CreateButton({Name = "Buy Geppo ($10k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Geppo") end})
TabShop:CreateButton({Name = "Buy Buso Haki ($25k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Buso") end})
TabShop:CreateButton({Name = "Buy Soru ($25k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Soru") end})
TabShop:CreateButton({Name = "Buy Ken Haki ($750k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("KenTalk", "Buy") end})

TabShop:CreateSection("Swords & Guns")

TabShop:CreateButton({Name = "Buy Katana ($1k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Katana") end})
TabShop:CreateButton({Name = "Buy Cutlass ($1k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Cutlass") end})
TabShop:CreateButton({Name = "Buy Dual Katana ($12k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Duel Katana") end})
TabShop:CreateButton({Name = "Buy Triple Katana ($60k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Triple Katana") end})
TabShop:CreateButton({Name = "Buy Iron Mace ($25k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Iron Mace") end})
TabShop:CreateButton({Name = "Buy Pipe ($100k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Pipe") end})
TabShop:CreateButton({Name = "Buy Soul Cane ($750k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Soul Cane") end})
TabShop:CreateButton({Name = "Buy Bisento ($1.2M)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Bisento") end})
TabShop:CreateButton({Name = "Buy Slingshot ($5k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Slingshot") end})
TabShop:CreateButton({Name = "Buy Flintlock ($10.5k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Flintlock") end})
TabShop:CreateButton({Name = "Buy Refined Flintlock ($65k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Refined Flintlock") end})
TabShop:CreateButton({Name = "Buy Cannon ($100k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Cannon") end})
TabShop:CreateButton({Name = "Buy Kabucha (1.5k F)", Callback = function()
	ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Slingshot", "1")
	ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Slingshot", "2")
end})

TabShop:CreateSection("Accessories & Crafts")

TabShop:CreateButton({Name = "Buy Black Cape ($50k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Black Cape") end})
TabShop:CreateButton({Name = "Buy Swordsman Hat ($150k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Swordsman Hat") end})
TabShop:CreateButton({Name = "Buy Tomoe Ring ($500k)", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Tomoe Ring") end})
TabShop:CreateButton({Name = "Craft SharkTooth", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "SharkTooth") end})
TabShop:CreateButton({Name = "Craft TerrorJaw", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "TerrorJaw") end})
TabShop:CreateButton({Name = "Craft SharkAnchor", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "SharkAnchor") end})
TabShop:CreateButton({Name = "Craft LeviathanCrown", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "LeviathanCrown") end})
TabShop:CreateButton({Name = "Craft LeviathanShield", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "LeviathanShield") end})
TabShop:CreateButton({Name = "Craft LeviathanBoat", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "LeviathanBoat") end})
TabShop:CreateButton({Name = "Craft LegendaryScroll", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "LegendaryScroll") end})
TabShop:CreateButton({Name = "Craft MythicalScroll", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("CraftItem", "Craft", "MythicalScroll") end})

TabShop:CreateSection("Race & Stat Resets")

TabShop:CreateButton({Name = "Change to Ghoul Race", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("Ectoplasm", "Change", 4) end})
TabShop:CreateButton({Name = "Change to Cyborg Race", Callback = function() ReplicatedStorage.Remotes.CommF_:InvokeServer("CyborgTrainer", "Buy") end})
TabShop:CreateButton({Name = "Reset Stats (2.5k Frags)", Callback = function()
	ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "1")
	ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "2")
end})
TabShop:CreateButton({Name = "Reroll Race (3k Frags)", Callback = function()
	ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Reroll", "1")
	ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Reroll", "2")
end})

-- ========================================================
-- TAB: UTILITY, SERVER & CODES (PATCHED)
-- ========================================================
local TabUtils = Window:CreateTab({
	Name        = "Utility",
	Icon        = "settings",
	ImageSource = "Material",
	ShowTitle   = true
})

TabUtils:CreateSection("Automated Stats Allocation")

local autoMelee, autoDefense, autoSword, autoGun, autoFruit = false, false, false, false, false

TabUtils:CreateToggle({Name = "Auto Upgrade Melee", CurrentValue = false, Callback = function(v) autoMelee = v end})
TabUtils:CreateToggle({Name = "Auto Upgrade Defense", CurrentValue = false, Callback = function(v) autoDefense = v end})
TabUtils:CreateToggle({Name = "Auto Upgrade Sword", CurrentValue = false, Callback = function(v) autoSword = v end})
TabUtils:CreateToggle({Name = "Auto Upgrade Gun", CurrentValue = false, Callback = function(v) autoGun = v end})
TabUtils:CreateToggle({Name = "Auto Upgrade Demon Fruit", CurrentValue = false, Callback = function(v) autoFruit = v end})

task.spawn(function()
	while task.wait(0.2) do
		local data = LocalPlayer:FindFirstChild("Data")
		local points = data and data:FindFirstChild("Points") and data.Points.Value or 0
		if points >= 1 then
			local function addPoint(statName)
				ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", statName, 1)
			end
			if autoMelee then addPoint("Melee") end
			if autoDefense then addPoint("Defense") end
			if autoSword then addPoint("Sword") end
			if autoGun then addPoint("Gun") end
			if autoFruit then addPoint("Demon Fruit") end
		end
	end
end)

TabUtils:CreateSection("Client Physical Buffs")

TabUtils:CreateSlider({
	Name         = "Custom WalkSpeed",
	Description  = "Direct walkspeed override",
	Range        = {16, 300},
	Increment    = 1,
	CurrentValue = 16,
	Callback     = function(Val)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.WalkSpeed = Val
		end
	end
}, "WalkSpeedSlider")

TabUtils:CreateSlider({
	Name         = "Custom JumpPower",
	Description  = "Direct jump power override",
	Range        = {50, 400},
	Increment    = 1,
	CurrentValue = 50,
	Callback     = function(Val)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.UseJumpPower = true
			char.Humanoid.JumpPower = Val
		end
	end
}, "JumpPowerSlider")

TabUtils:CreateToggle({
	Name         = "Walk on Water",
	Description  = "Solidifies ocean surface plane",
	CurrentValue = false,
	Callback     = function(State)
		_G.WalkWater = State
		local plane = workspace.Map:FindFirstChild("WaterBase-Plane")
		if plane then
			plane.Size = State and Vector3.new(1000, 112, 1000) or Vector3.new(1000, 80, 1000)
		end
	end
}, "WalkOnWaterToggle")

TabUtils:CreateSection("Visuals & Performance")

TabUtils:CreateButton({
	Name        = "FPS Boost (Ultra Low)",
	Description = "Strips heavy textures, shadows, and decals for maximum framerate",
	Callback    = function()
		settings().Rendering.QualityLevel = "Level01"
		for _, obj in ipairs(game:GetDescendants()) do
			if obj:IsA("BasePart") then
				obj.Material = Enum.Material.Plastic
			elseif obj:IsA("Decal") or obj:IsA("Texture") then
				obj.Transparency = 1
			elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
				obj.Lifetime = NumberRange.new(0)
			end
		end
		Notify("Louis Hub", "Rendering optimization applied.", "check_circle")
	end
})

TabUtils:CreateSection("All 60+ Promo Codes")

local AllCodes = {
	"NOMOREHACK", "BANEXPLOIT", "WildDares", "BossBuild", "GetPranked",
	"EARN_FRUITS", "FIGHT4FRUIT", "NOEXPLOITER", "NOOB2ADMIN", "CODESLIDE",
	"ADMINHACKED", "ADMINDARES", "fruitconcepts", "krazydares", "TRIPLEABUSE",
	"SEATROLLING", "24NOADMIN", "REWARDFUN", "Chandler", "NEWTROLL",
	"KITT_RESET", "Sub2CaptainMaui", "kittgaming", "Sub2Fer999", "Enyu_is_Pro",
	"Magicbus", "JCWK", "Starcodeheo", "Bluxxy", "fudd10_v2",
	"SUB2GAMERROBOT_EXP1", "Sub2NoobMaster123", "Sub2UncleKizaru", "Sub2Daigrock", "Axiore",
	"TantaiGaming", "StrawHatMaine", "Sub2OfficialNoobie", "Fudd10", "Bignews",
	"TheGreatAce", "SECRET_ADMIN", "SUB2GAMERROBOT_RESET1", "SUB2OFFICIALNOOBIE", "AXIORE",
	"BIGNEWS", "BLUXXY", "CHANDLER", "ENYU_IS_PRO", "FUDD10",
	"FUDD10_V2", "KITTGAMING", "MAGICBUS", "STARCODEHEO", "STRAWHATMAINE",
	"SUB2CAPTAINMAUI", "SUB2DAIGROCK", "SUB2FER999", "SUB2NOOBMASTER123", "SUB2UNCLEKIZARU",
	"TANTAIGAMING", "THEGREATACE"
}

TabUtils:CreateButton({
	Name        = "Redeem All 60+ Server Codes",
	Description = "Batch submits every known active promo code",
	Callback    = function()
		Notify("Louis Hub", "Processing code redemptions...", "sync")
		for _, code in ipairs(AllCodes) do
			pcall(function()
				ReplicatedStorage.Remotes.Redeem:InvokeServer(code)
			end)
			task.wait(0.06)
		end
		Notify("Louis Hub", "All codes processed.", "check_circle")
	end
})

TabUtils:CreateSection("Server Connection")

TabUtils:CreateButton({
	Name        = "Rejoin Current Server",
	Description = "Reconnects to current PlaceId",
	Callback    = function()
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	end
})

TabUtils:CreateButton({
	Name        = "Server Hop",
	Description = "Reroutes to an active alternative instance",
	Callback    = function()
		local placeId = game.PlaceId
		local res = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
		for _, s in pairs(res.data) do
			if s.playing < s.maxPlayers and s.id ~= game.JobId then
				TeleportService:TeleportToPlaceInstance(placeId, s.id, LocalPlayer)
				break
			end
		end
	end
})

-- ========================================================
-- LUNA NATIVE CONFIGURATION & THEME
-- ========================================================
local ThemeTab = Window:CreateTab({
	Name        = "Theme",
	Icon        = "palette",
	ImageSource = "Material",
	ShowTitle   = true
})
ThemeTab:BuildThemeSection()

local ConfigTab = Window:CreateTab({
	Name        = "Profiles",
	Icon        = "settings",
	ImageSource = "Material",
	ShowTitle   = true
})
ConfigTab:BuildConfigSection()

Notify("Louis Hub", "Blox Fruits Pro Master Suite Fully Initialized! (All Parts Complete)", "verified")
