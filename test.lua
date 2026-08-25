-- ========================================================
-- 1. LOAD LUNA INTERFACE SUITE
-- ========================================================
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Global State Flags
local isLocked = false
local isFastGacha = false
local gachaSpeed = 0.05
local petWhitelist = {}
local auraWhitelist = {}
local lockedOldItems = {}
local isAutoEvolve = false
local disablePopupsConnection = nil

-- ========================================================
-- DATA TABLES
-- ========================================================
local allCrystals = {
	"Industrial Crystal",
	"Jungle Crystal",
	"Galaxy Oracle Crystal",
	"Muscle Elite Crystal",
	"Legends Crystal",
	"Inferno Crystal",
	"Mythical Crystal",
	"Frost Crystal",
	"Green Crystal",
	"Blue Crystal"
}

local masterPetList = {
	-- Industrial Crystal
	"Apex Overlord",
	"Titan Reactor",
	"Plasma Ravager",
	"Reactor Beast",
	"Volt Talon",
	"Core Pup",

	-- Jungle Gym
	"Neon Guardian",
	"Muscle Sensei",
	"Golden Viking",

	-- Galaxy Oracle Crystal
	"Darkstar Hunter",
	"Lighting Strike Phantom",
	"Eternal Strike Leviathan",

	-- Muscle Elite Crystal
	"Cybernetic Showdown Dragon",
	"Aether Spirit Bunny",
	"Ultimate Supernova Pegasus",
	"Dark Legends Manticore",
	"Phantom Genesis Dragon",
	"Frostwave Legends Penguin",

	-- Legends Crystal
	"Ultra Birdie",
	"Magic Butterfly",
	"White Pheonix",
	"Green Firecaster",

	-- Inferno Crystal
	"Infernal Dragon",
	"Golden Pheonix",
	"White Pegasus",
	"Red Firecaster",

	-- Mythical Crystal
	"Blue Firecaster",
	"Purple Falcon",
	"Red Dragon",

	-- Frost Crystal
	"Blue Pheonix",
	"Orange Pegasus",
	"Purple Dragon",
	"Yellow Butterfly",

	-- Green Crystal
	"Crimson Falcon",
	"Green Butterfly",
	"Dark Golem",
	"Silver Dog",

	-- Blue Crystal
	"Dark Vampy",
	"Blue Bunny",
	"Red Kitty",
	"Blue Birdie",
	"Orange Hedgehog"
}

local masterAuraList = {
	-- Jungle Aura
	"Entropic Blast Aura",
	"Eternal Megastrike Aura",
	"Grand SuperNova Aura",

	-- Galaxy Aura
	"Muscle King Aura",
	"Azure Tundra Aura",
	"Ultra Inferno Aura",

	-- Standard Auras
	"Unique Aura",
	"Epic Aura",
	"Rare Aura",
	"Advanced Aura",
	"Basic Aura"
}

local gymLocationsMap = {
	["Starter Island"] = "Starter Island",
	["Legend Beach"] = "Legend Beach",
	["Frost Gym"] = "Frost Gym",
	["Mythical Gym"] = "Mythical Gym",
	["Eternal Gym"] = "Eternal Gym",
	["Legends Gym"] = "Legends Gym",
	["Muscle King"] = "Muscle King",
	["Jungle Gym"] = "Jungle Gym",
	["Industrial Gym"] = "Industrial Gym"
}

local machineTypesMap = {
	"Treadmill",
	"Bench Press",
	"Squat",
	"Pullup",
	"Deadlift",
	"Boulder"
}

local selectedGymLocation = "Starter Island"
local selectedMachineName = "Treadmill"

local selectedCrystal = allCrystals[1]
local currentSelectedPet = masterPetList[1]
local currentSelectedAura = masterAuraList[1]

-- Helper Number Formatter
local function formatAbbrev(n)
	n = tonumber(n) or 0
	if n >= 1e15 then return string.format("%.2fQ", n / 1e15)
	elseif n >= 1e12 then return string.format("%.2fT", n / 1e12)
	elseif n >= 1e9 then return string.format("%.2fB", n / 1e9)
	elseif n >= 1e6 then return string.format("%.2fM", n / 1e6)
	elseif n >= 1e3 then return string.format("%.2fK", n / 1e3)
	else return tostring(n) end
end

-- ========================================================
-- CREATE MAIN WINDOW
-- ========================================================
local Window = Luna:CreateWindow({
	Name = "Muscle Legends",
	Subtitle = "by Louis Hub",
	LogoID = nil,
	LoadingEnabled = true,
	LoadingTitle = "Muscle Legends",
	LoadingSubtitle = "by Louis Hub",

	ConfigSettings = {
		ConfigFolder = "LouisHubLegends"
	},

	KeySystem = false,
})

Window:CreateHomeTab({
	SupportedExecutors = {
		"Synapse X", "Krnl", "Fluxus", "Script-Ware", "Wave", "Solara", "Delta", "Codex"
	},
	DiscordInvite = "xhxMeyzana",
	Icon = 1
})

-- Helper: Auto-equip Punch Tool
local function equipPunchTool()
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	local character = LocalPlayer.Character
	if character then
		local punchTool = character:FindFirstChild("Punch") or (backpack and backpack:FindFirstChild("Punch"))
		if punchTool and punchTool.Parent ~= character then
			punchTool.Parent = character
		end
	end
end

-- Helper: Lock Inventory Shield
local function lockCurrentInventory()
	lockedOldItems = {}
	local petsFolder = LocalPlayer:FindFirstChild("petsFolder")
	if petsFolder then
		for _, category in pairs(petsFolder:GetChildren()) do
			for _, pet in pairs(category:GetChildren()) do
				lockedOldItems[pet] = true
			end
		end
	end

	local aurasFolder = LocalPlayer:FindFirstChild("aurasFolder") or LocalPlayer:FindFirstChild("auraFolder")
	if aurasFolder then
		for _, category in pairs(aurasFolder:GetChildren()) do
			for _, aura in pairs(category:GetChildren()) do
				lockedOldItems[aura] = true
			end
		end
	end
	print("[PROTECTION] Existing inventory locked and protected!")
end

-- Helper: Filter New Gacha Items
local function filterNewGachaItems()
	local petsFolder = LocalPlayer:FindFirstChild("petsFolder")
	if petsFolder then
		for _, category in pairs(petsFolder:GetChildren()) do
			for _, pet in pairs(category:GetChildren()) do
				if not lockedOldItems[pet] then
					lockedOldItems[pet] = true
					if not petWhitelist[pet.Name] then
						ReplicatedStorage.rEvents.sellPetEvent:FireServer("sellPet", pet)
					else
						print("[PET SAVED]: " .. pet.Name)
					end
				end
			end
		end
	end

	local aurasFolder = LocalPlayer:FindFirstChild("aurasFolder") or LocalPlayer:FindFirstChild("auraFolder")
	if aurasFolder then
		for _, category in pairs(aurasFolder:GetChildren()) do
			for _, aura in pairs(category:GetChildren()) do
				if not lockedOldItems[aura] then
					lockedOldItems[aura] = true
					if not auraWhitelist[aura.Name] then
						if ReplicatedStorage.rEvents:FindFirstChild("sellAuraEvent") then
							ReplicatedStorage.rEvents.sellAuraEvent:FireServer("sellAura", aura)
						else
							ReplicatedStorage.rEvents.sellPetEvent:FireServer("sellPet", aura)
						end
					else
						print("[AURA SAVED]: " .. aura.Name)
					end
				end
			end
		end
	end
end

-- Helper: Disable Egg Cutscene Animations
local function disableEggAnimation()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	if playerGui then
		for _, gui in pairs(playerGui:GetChildren()) do
			local name = gui.Name:lower()
			if name:find("open") or name:find("egg") or name:find("crystal") or name:find("pet") then
				if gui:IsA("ScreenGui") then
					gui.Enabled = false
				end
			end
		end
	end
end

-- Helper: Auto Pet Evolution
local function evolveAllPets()
	local petsFolder = LocalPlayer:FindFirstChild("petsFolder")
	if not petsFolder then return end

	for _, category in pairs(petsFolder:GetChildren()) do
		for _, pet in pairs(category:GetChildren()) do
			ReplicatedStorage.rEvents.petEvolveEvent:FireServer("evolvePet", pet.Name)
		end
	end
end

-- Helper: Grab All Statistics
local function getFullStats(target)
	if not target then return nil end
	local ls = target:FindFirstChild("leaderstats")

	local str = (ls and ls:FindFirstChild("Strength") and ls.Strength.Value) or (target:FindFirstChild("strength") and target.strength.Value) or 0
	local reb = (ls and ls:FindFirstChild("Rebirths") and ls.Rebirths.Value) or (ls and ls:FindFirstChild("Rebirth") and ls.Rebirth.Value) or (target:FindFirstChild("rebirths") and target.rebirths.Value) or 0
	local dur = (ls and ls:FindFirstChild("Durability") and ls.Durability.Value) or (target:FindFirstChild("durability") and target.durability.Value) or 0
	local agi = (ls and ls:FindFirstChild("Agility") and ls.Agility.Value) or (target:FindFirstChild("agility") and target.agility.Value) or 0
	local gems = (ls and ls:FindFirstChild("Gems") and ls.Gems.Value) or (target:FindFirstChild("gems") and target.gems.Value) or 0
	local kills = (ls and ls:FindFirstChild("Kills") and ls.Kills.Value) or (ls and ls:FindFirstChild("Brawls") and ls.Brawls.Value) or 0
	local good = (target:FindFirstChild("goodKarma") and target.goodKarma.Value) or 0
	local evil = (target:FindFirstChild("evilKarma") and target.evilKarma.Value) or 0
	local size = (target:FindFirstChild("customSize") and target.customSize.Value) or (target:FindFirstChild("muscleSize") and target.muscleSize.Value) or 1

	local totalPets = 0
	local petsFolder = target:FindFirstChild("petsFolder")
	if petsFolder then
		for _, cat in pairs(petsFolder:GetChildren()) do
			totalPets = totalPets + #cat:GetChildren()
		end
	end

	return {
		Strength = str, Durability = dur, Agility = agi, Rebirths = reb,
		Gems = gems, Kills = kills, GoodKarma = good, EvilKarma = evil,
		Size = size, TotalPets = totalPets
	}
end


-- ==================== TAB 1: FARMING ====================
local TabFarming = Window:CreateTab({
	Name = "Farming",
	Icon = "fitness_center",
	ImageSource = "Material",
	ShowTitle = true
})

TabFarming:CreateSection("Developer Note")
TabFarming:CreateLabel({
	Text = "LOUIS HATES GYM FARMING, BECAUSE HE IS LAZYYYYYYY",
	Style = 2
})

-- TRAINING TOOL FARM
TabFarming:CreateSection("Training Tool Settings")

local selectedTool = "Weight"
TabFarming:CreateDropdown({
	Name = "Select Training Tool",
	Description = "Select the tool you want to use for auto-training",
	Options = {"Weight", "Pushups", "Situps", "Handstands"},
	CurrentOption = {"Weight"},
	MultipleOptions = false,
	Callback = function(OptionTable)
		selectedTool = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
	end
}, "SelectedTool")

TabFarming:CreateToggle({
	Name = "Auto Strength (Selected Tool)",
	CurrentValue = false,
	Callback = function(State)
		deku = State
		while deku do task.wait(0.5)
			local args = { [1] = "rep" }
			LocalPlayer.muscleEvent:FireServer(unpack(args))
			
			local backpack = LocalPlayer:FindFirstChild("Backpack")
			local character = LocalPlayer.Character
			if backpack and character and selectedTool then
				local tool = backpack:FindFirstChild(selectedTool)
				if tool then 
					tool.Parent = character
				end
			end
		end
	end
}, "AutoStrength")

-- NON-TOOL GYM MACHINES FARM (ACCURATE PER-GYM SYSTEM)
TabFarming:CreateSection("Gym Machines Farm (Non-Tool)")

local gymOptionsList = {
	"Starter Island",
	"Legend Beach",
	"Frost Gym",
	"Mythical Gym",
	"Eternal Gym",
	"Legends Gym",
	"Muscle King",
	"Jungle Gym",
	"Industrial Gym"
}

TabFarming:CreateDropdown({
	Name = "1. Select Gym Location",
	Description = "Select the gym where you want to train",
	Options = gymOptionsList,
	CurrentOption = {gymOptionsList[1]},
	MultipleOptions = false,
	Callback = function(OptionTable)
		selectedGymLocation = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
	end
}, "GymLocationSelect")

TabFarming:CreateDropdown({
	Name = "2. Select Machine Type",
	Description = "Select the machine equipment inside the chosen gym",
	Options = machineTypesMap,
	CurrentOption = {machineTypesMap[1]},
	MultipleOptions = false,
	Callback = function(OptionTable)
		selectedMachineName = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
	end
}, "GymMachineSelect")

local autoGymMachine = false
TabFarming:CreateToggle({
	Name = "Auto Farm Selected Machine",
	Description = "Teleports to and continuously trains on the selected gym machine",
	CurrentValue = false,
	Callback = function(State)
		autoGymMachine = State
		if autoGymMachine then
			task.spawn(function()
				while autoGymMachine do
					local char = LocalPlayer.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")
					local machinesFolder = workspace:FindFirstChild("machinesFolder")

					if hrp and machinesFolder then
						local gymClean = selectedGymLocation:lower():gsub(" ", "")
						local machClean = selectedMachineName:lower():gsub(" ", "")

						-- Search for the exact machine model inside workspace.machinesFolder
						for _, machine in pairs(machinesFolder:GetChildren()) do
							local mNameClean = machine.Name:lower():gsub(" ", "")
							if mNameClean:find(gymClean) and mNameClean:find(machClean) then
								local interactPart = machine:FindFirstChildWhichIsA("Seat") 
												  or machine:FindFirstChild("Seat") 
												  or machine:FindFirstChild("Interact")
												  or machine:FindFirstChild("Main")
												  or machine:FindFirstChildWhichIsA("BasePart")

								if interactPart then
									-- Snap player onto machine interact pad
									hrp.CFrame = interactPart.CFrame + Vector3.new(0, 2, 0)
									firetouchinterest(hrp, interactPart, 0)
									firetouchinterest(hrp, interactPart, 1)

									if LocalPlayer:FindFirstChild("muscleEvent") then
										LocalPlayer.muscleEvent:FireServer("rep")
									end
								end
							end
						end
					end
					task.wait(0.1)
				end
			end)
		end
	end
}, "AutoGymMachine")

-- AUTO REBIRTH SECTION
TabFarming:CreateSection("Auto Rebirth System")

local maxRebirths = 999999999
TabFarming:CreateInput({
	Name = "Limit Rebirths (Stop Rebirth)",
	Description = "Enter target Rebirth number to automatically stop auto-rebirth",
	PlaceholderText = "Example: 100",
	CurrentValue = "",
	Numeric = true,
	Enter = true,
	Callback = function(Text)
		local num = tonumber(Text)
		if num then
			maxRebirths = num
			Luna:Notification({
				Title = "Rebirth Limit Set",
				Content = "Auto Rebirth will automatically stop after reaching " .. num .. " Rebirths.",
				Icon = "info",
				ImageSource = "Material"
			})
		else
			maxRebirths = 999999999
		end
	end
}, "MaxRebirthInput")

TabFarming:CreateToggle({
	Name = "Auto Rebirth (Normal)",
	CurrentValue = false,
	Callback = function(State)
		dragons = State
		while dragons do task.wait(0.1)
			local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
			local rebirthsVal = leaderstats and leaderstats:FindFirstChild("Rebirths")
			
			if rebirthsVal and rebirthsVal.Value >= maxRebirths then
				dragons = false
				Luna:Notification({
					Title = "Target Reached",
					Content = "Auto Rebirth disabled (reached " .. maxRebirths .. " Rebirths).",
					Icon = "warning",
					ImageSource = "Material"
				})
				break
			end

			local args = { [1] = "rebirthRequest" }
			ReplicatedStorage.rEvents.rebirthRemote:InvokeServer(unpack(args))
		end
	end
}, "AutoRebirth")

-- REBIRTH ANTI-BEACH STAY
local autoRebirthStay = false
TabFarming:CreateToggle({
	Name = "Auto Rebirth (Anti-Beach / Lock In Gym)",
	Description = "Rebirths and locks your character at your current gym so you never teleport back to spawn beach",
	CurrentValue = false,
	Callback = function(State)
		autoRebirthStay = State
		if autoRebirthStay then
			task.spawn(function()
				while autoRebirthStay do
					local char = LocalPlayer.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")
					local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
					local rebirthsVal = leaderstats and leaderstats:FindFirstChild("Rebirths")
					
					if rebirthsVal and rebirthsVal.Value >= maxRebirths then
						autoRebirthStay = false
						Luna:Notification({
							Title = "Target Reached",
							Content = "Auto Rebirth stopped (reached " .. maxRebirths .. " Rebirths).",
							Icon = "warning",
							ImageSource = "Material"
						})
						break
					end

					if hrp then
						local currentGymPos = hrp.CFrame
						ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
						
						task.wait(0.15)
						local newChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
						local newHrp = newChar:WaitForChild("HumanoidRootPart", 3)
						if newHrp then
							newHrp.CFrame = currentGymPos
						end
					end
					task.wait(0.5)
				end
			end)
		end
	end
}, "AutoRebirthStay")

-- AUTO CONSUME FOOD/PROTEIN ITEMS
TabFarming:CreateSection("Auto Consume Items (AFK)")

local autoFood = false
TabFarming:CreateToggle({
	Name = "Auto Consume Protein Egg / Shake / Bar",
	Description = "Automatically eats/consumes Protein Eggs, Bars, and Shakes from backpack",
	CurrentValue = false,
	Callback = function(State)
		autoFood = State
		if autoFood then
			task.spawn(function()
				while autoFood do
					local backpack = LocalPlayer:FindFirstChild("Backpack")
					local char = LocalPlayer.Character

					if backpack and char then
						for _, item in pairs(backpack:GetChildren()) do
							if item:IsA("Tool") then
								local n = item.Name:lower()
								if n:find("egg") or n:find("protein") or n:find("shake") or n:find("bar") or n:find("snack") then
									item.Parent = char
									task.wait(0.05)
									item:Activate()
								end
							end
						end
					end
					task.wait(1)
				end
			end)
		end
	end
}, "AutoConsumeFood")

TabFarming:CreateSection("Other Automation")

local selectedMKTool = "Weight"
TabFarming:CreateDropdown({
	Name = "Muscle King Tool",
	Description = "Select which tool to equip while farming Muscle King",
	Options = {"Weight", "Pushups", "Situps", "Handstands"},
	CurrentOption = {"Weight"},
	MultipleOptions = false,
	Callback = function(OptionTable)
		selectedMKTool = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
	end
}, "MKToolDropdown")

local farmMuscleKing = false
local mkCFrame = CFrame.new(-8731.53613, 23.7440701, -5864.24268, 0.475939035, 4.83328328e-08, 0.879478276, -6.21004403e-08, 1, -2.13499405e-08, -0.879478276, -4.4454719e-08, 0.475939035)
local mkNoclipConnection

TabFarming:CreateToggle({
	Name = "Farm Muscle King",
	Description = "Teleports to Muscle King, locks position, locks size to 1, enables noclip, and auto reps",
	CurrentValue = false,
	Callback = function(State)
		farmMuscleKing = State
		if farmMuscleKing then
			ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", 1)

			mkNoclipConnection = RunService.Stepped:Connect(function()
				if farmMuscleKing and LocalPlayer.Character then
					for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
				end
			end)
			
			task.spawn(function()
				while farmMuscleKing do
					if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
						LocalPlayer.Character.HumanoidRootPart.CFrame = mkCFrame
						LocalPlayer.Character.HumanoidRootPart.Anchored = true
						LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
					end
					
					local backpack = LocalPlayer:FindFirstChild("Backpack")
					local character = LocalPlayer.Character
					if backpack and character and selectedMKTool then
						local tool = backpack:FindFirstChild(selectedMKTool) or character:FindFirstChild(selectedMKTool)
						if tool and tool.Parent ~= character then 
							tool.Parent = character
						end
					end

					LocalPlayer.muscleEvent:FireServer("rep")
					task.wait(0.1)
				end
				if mkNoclipConnection then mkNoclipConnection:Disconnect() end
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
					LocalPlayer.Character.HumanoidRootPart.Anchored = false
				end
			end)
		else
			if mkNoclipConnection then mkNoclipConnection:Disconnect() end
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				LocalPlayer.Character.HumanoidRootPart.Anchored = false
			end
		end
	end
}, "FarmMuscleKing")

TabFarming:CreateToggle({
	Name = "Auto Speed Keypress",
	CurrentValue = false,
	Callback = function(State)
		China = State
		local args = { [1] = "changeSize", [2] = 1 }
		ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer(unpack(args))
		while China do task.wait()
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(243.039078, 4.8158493, 361.3414)
				keypress(0x57) task.wait(.1) keyrelease(0x57)
			end
		end    
	end
}, "AutoSpeedKeypress")

TabFarming:CreateToggle({
	Name = "Auto Join Brawl",
	CurrentValue = false,
	Callback = function(State)
		hot = State
		while hot do task.wait(2)
			local args = { [1] = "joinBrawl" }
			ReplicatedStorage.rEvents.brawlEvent:FireServer(unpack(args))
		end
	end
}, "AutoJoinBrawl")

local killAllPlayers = false
TabFarming:CreateToggle({
	Name = "Kill All Player",
	Description = "Locks onto players and auto-punches them (Automatically sets size to 1)",
	CurrentValue = false,
	Callback = function(State)
		killAllPlayers = State
		if killAllPlayers then
			ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", 1)

			task.spawn(function()
				while killAllPlayers do
					local plrs = Players:GetPlayers()
					local targetFound = false
					
					for _, target in ipairs(plrs) do
						if not killAllPlayers then break end
						
						if target ~= LocalPlayer and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 and not target.Character:FindFirstChildOfClass("ForceField") then
							targetFound = true
							local startTime = os.clock()
							
							while killAllPlayers and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health > 0 and not target.Character:FindFirstChildOfClass("ForceField") and (os.clock() - startTime < 2) do
								local targetPart = target.Character.HumanoidRootPart
								if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
									LocalPlayer.Character.HumanoidRootPart.CFrame = targetPart.CFrame * CFrame.new(0, 0, 2.5)
								end
								
								equipPunchTool()
								LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
								LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
								task.wait(0.05)
							end
						end
					end
					
					if not targetFound then
						task.wait(0.5)
					end
				end
			end)
		end
	end
}, "KillAllPlayers")


-- ==================== TAB 2: GLITCH PET (ROCKS) ====================
local TabGlitch = Window:CreateTab({
	Name = "Glitch Pet",
	Icon = "pets",
	ImageSource = "Material",
	ShowTitle = true
})

TabGlitch:CreateSection("Select Target Rock")

local selectedRock = "Tiny Rock"
local rockList = {
	"Tiny Rock",
	"Punching Rock",
	"Frozen Rock",
	"Inferno Rock",
	"Rock Of Legends",
	"Muscle King Mountain",
	"Ancient Jungle Rock",
	"Industrial Rock"
}

TabGlitch:CreateDropdown({
	Name = "Select Target Rock",
	Description = "Select the target rock you want to punch",
	Options = rockList,
	CurrentOption = {"Tiny Rock"},
	MultipleOptions = false,
	Callback = function(OptionTable)
		selectedRock = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
	end
}, "SelectedRockDropdown")

TabGlitch:CreateSection("Glitch Automation")

local autoRock = false
TabGlitch:CreateToggle({
	Name = "Auto Punch Rock (2x Faster / Dual Hand)",
	Description = "Executes fast dual-hand touch punch triggers on selected rock without moving",
	CurrentValue = false,
	Callback = function(State)
		autoRock = State
		if autoRock then
			task.spawn(function()
				while autoRock do
					local char = LocalPlayer.Character
					local target = workspace:FindFirstChild("machinesFolder") and workspace.machinesFolder:FindFirstChild(selectedRock)
					local rockPart = target and (target:FindFirstChild("Rock") or target:FindFirstChildWhichIsA("BasePart"))
					
					if rockPart and LocalPlayer:FindFirstChild("muscleEvent") then
						local rightHand = char and (char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm"))
						local leftHand  = char and (char:FindFirstChild("LeftHand")  or char:FindFirstChild("Left Arm"))

						if rightHand then
							firetouchinterest(rightHand, rockPart, 0)
							firetouchinterest(rightHand, rockPart, 1)
							LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
						end

						if leftHand then
							firetouchinterest(leftHand, rockPart, 0)
							firetouchinterest(leftHand, rockPart, 1)
							LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
						end
					end
					task.wait(0.1)
				end
			end)
		end
	end
}, "AutoPunchRock")


-- ==================== TAB 3: GACHA & WHITELIST ====================
local TabGacha = Window:CreateTab({
	Name = "Gacha & Whitelist",
	Icon = "stars",
	ImageSource = "Material",
	ShowTitle = true
})

TabGacha:CreateSection("Whitelist Configurations")

TabGacha:CreateDropdown({
	Name = "Select Crystal",
	Description = "Select the type of crystal you want to open",
	Options = allCrystals,
	CurrentOption = {allCrystals[1]},
	MultipleOptions = false,
	Callback = function(OptionTable)
		selectedCrystal = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
	end
}, "SelectCrystalDropdown")

-- --- PET WHITELIST SECTION ---
TabGacha:CreateSection("Pet Whitelist Filter")

TabGacha:CreateDropdown({
	Name = "Select Pet",
	Description = "Select a pet to add to your whitelist filter",
	Options = masterPetList,
	CurrentOption = {masterPetList[1]},
	MultipleOptions = false,
	Callback = function(OptionTable)
		currentSelectedPet = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
	end
}, "SelectPetDropdown")

TabGacha:CreateButton({
	Name = "Add Pet to Whitelist",
	Callback = function()
		petWhitelist[currentSelectedPet] = true
		Luna:Notification({
			Title = "Pet Whitelisted",
			Content = currentSelectedPet .. " has been successfully whitelisted.",
			Icon = "check_circle",
			ImageSource = "Material"
		})
	end
})

TabGacha:CreateButton({
	Name = "Reset Pet Whitelist",
	Callback = function()
		petWhitelist = {}
		Luna:Notification({
			Title = "Whitelist Reset",
			Content = "All pet whitelists have been cleared.",
			Icon = "delete",
			ImageSource = "Material"
		})
	end
})

-- --- AURA WHITELIST SECTION ---
TabGacha:CreateSection("Aura Whitelist Filter")

TabGacha:CreateDropdown({
	Name = "Select Aura",
	Description = "Select an aura to add to your whitelist filter",
	Options = masterAuraList,
	CurrentOption = {masterAuraList[1]},
	MultipleOptions = false,
	Callback = function(OptionTable)
		currentSelectedAura = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
	end
}, "SelectAuraDropdown")

TabGacha:CreateButton({
	Name = "Add Aura to Whitelist",
	Callback = function()
		auraWhitelist[currentSelectedAura] = true
		Luna:Notification({
			Title = "Aura Whitelisted",
			Content = currentSelectedAura .. " has been successfully whitelisted.",
			Icon = "check_circle",
			ImageSource = "Material"
		})
	end
})

TabGacha:CreateButton({
	Name = "Reset Aura Whitelist",
	Callback = function()
		auraWhitelist = {}
		Luna:Notification({
			Title = "Whitelist Reset",
			Content = "All aura whitelists have been cleared.",
			Icon = "delete",
			ImageSource = "Material"
		})
	end
})

TabGacha:CreateSection("Auto Gacha Control")

TabGacha:CreateToggle({
	Name = "Fast Auto Gacha (Safe Mode)",
	Description = "Opens crystals extremely fast, protects existing items, and auto-sells non-whitelisted items",
	CurrentValue = false,
	Callback = function(State)
		isFastGacha = State

		if isFastGacha then
			lockCurrentInventory()
			disableEggAnimation()

			task.spawn(function()
				while isFastGacha do
					task.spawn(function()
						ReplicatedStorage.rEvents.openCrystalRemote:InvokeServer("openCrystal", selectedCrystal)
					end)

					filterNewGachaItems()
					task.wait(gachaSpeed)
				end
			end)
		end
	end
}, "FastAutoGacha")

TabGacha:CreateSection("Auto Pet Evolution")

TabGacha:CreateButton({
	Name = "Evolve All Pets (One-Click)",
	Callback = function()
		evolveAllPets()
		Luna:Notification({
			Title = "Evolution Executed",
			Content = "Attempted to evolve all 5/5 pets in your inventory.",
			Icon = "auto_awesome",
			ImageSource = "Material"
		})
	end
})

TabGacha:CreateToggle({
	Name = "Auto Evolve Pets",
	Description = "Automatically checks and evolves eligible 5/5 pets every 1.5 seconds",
	CurrentValue = false,
	Callback = function(State)
		isAutoEvolve = State
		if isAutoEvolve then
			task.spawn(function()
				while isAutoEvolve do
					evolveAllPets()
					task.wait(1.5)
				end
			end)
		end
	end
}, "AutoEvolvePets")


-- ==================== TAB 4: STAT POWER (VIEWER) ====================
local TabStats = Window:CreateTab({
	Name = "Stat Power",
	Icon = "leaderboard",
	ImageSource = "Material",
	ShowTitle = true
})

TabStats:CreateSection("My Character Statistics")

TabStats:CreateButton({
	Name = "Check My Stats (Show Notification)",
	Description = "Displays all of your Strength, Durability, Agility, Rebirths, Gems, Karma, and Pets in a notification",
	Callback = function()
		local s = getFullStats(LocalPlayer)
		if s then
			local msg = string.format(
				"Str: %s | Dur: %s | Agi: %s\nReb: %s | Gems: %s | Kills: %s\nGood: %s | Evil: %s | Size: %s | Pets: %d",
				formatAbbrev(s.Strength), formatAbbrev(s.Durability), formatAbbrev(s.Agility),
				formatAbbrev(s.Rebirths), formatAbbrev(s.Gems), formatAbbrev(s.Kills),
				formatAbbrev(s.GoodKarma), formatAbbrev(s.EvilKarma), tostring(s.Size), s.TotalPets
			)
			Luna:Notification({
				Title = "Your Stats (" .. LocalPlayer.DisplayName .. ")",
				Content = msg,
				Icon = "person",
				ImageSource = "Material"
			})
		end
	end
})

TabStats:CreateSection("Inspect Other Players")

local playerNamesList = {}
local function updatePlayerNames()
	playerNamesList = {}
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			table.insert(playerNamesList, p.Name)
		end
	end
	if #playerNamesList == 0 then
		table.insert(playerNamesList, "No other players")
	end
	return playerNamesList
end
updatePlayerNames()

local selectedTargetPlayer = playerNamesList[1]

TabStats:CreateDropdown({
	Name = "Select Target Player",
	Description = "Select a player from the server to inspect their stats",
	Options = playerNamesList,
	CurrentOption = {playerNamesList[1]},
	MultipleOptions = false,
	Callback = function(OptionTable)
		selectedTargetPlayer = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
	end
}, "InspectPlayerDropdown")

TabStats:CreateButton({
	Name = "Inspect Selected Player",
	Description = "Reads and displays all statistics of the chosen player",
	Callback = function()
		local target = Players:FindFirstChild(selectedTargetPlayer)
		if target then
			local s = getFullStats(target)
			if s then
				local msg = string.format(
					"Str: %s | Dur: %s | Agi: %s\nReb: %s | Gems: %s | Kills: %s\nGood: %s | Evil: %s | Size: %s | Pets: %d",
					formatAbbrev(s.Strength), formatAbbrev(s.Durability), formatAbbrev(s.Agility),
					formatAbbrev(s.Rebirths), formatAbbrev(s.Gems), formatAbbrev(s.Kills),
					formatAbbrev(s.GoodKarma), formatAbbrev(s.EvilKarma), tostring(s.Size), s.TotalPets
				)
				Luna:Notification({
					Title = "Stats: @" .. target.Name,
					Content = msg,
					Icon = "search",
					ImageSource = "Material"
				})
			end
		else
			Luna:Notification({
				Title = "Error",
				Content = "Player not found or has left the server!",
				Icon = "error",
				ImageSource = "Material"
			})
		end
	end
})

TabStats:CreateButton({
	Name = "Refresh Player List",
	Description = "Refreshes the server player list in case new players joined",
	Callback = function()
		updatePlayerNames()
		Luna:Notification({
			Title = "Player List Refreshed",
			Content = "Current total server players: " .. #Players:GetPlayers(),
			Icon = "refresh",
			ImageSource = "Material"
		})
	end
})


-- ==================== TAB 5: CHESTS ====================
local TabChests = Window:CreateTab({
	Name = "Chests",
	Icon = "lock_open",
	ImageSource = "Material",
	ShowTitle = true
})

TabChests:CreateSection("Claim Chests (Manual / Separate)")

local chests = {
	"Magma Chest", 
	"Mythical Chest", 
	"Golden Chest", 
	"Enchanted Chest", 
	"Legends Chest",
	"Jungle Chest",     
	"Industrial Chest"  
}

TabChests:CreateButton({
	Name = "Claim All Chests",
	Callback = function()
		for _, chest in ipairs(chests) do
			ReplicatedStorage.rEvents.checkChestRemote:InvokeServer(chest)
			task.wait(0.2)
		end
		Luna:Notification({
			Title = "Request Sent",
			Content = "Claim requests for all chests sent to the server.",
			Icon = "info",
			ImageSource = "Material"
		})
	end
})

TabChests:CreateDivider()

for _, chest in ipairs(chests) do
	TabChests:CreateButton({
		Name = "Claim " .. chest,
		Callback = function()
			ReplicatedStorage.rEvents.checkChestRemote:InvokeServer(chest)
			Luna:Notification({
				Title = "Claim Chest",
				Content = "Claim request for " .. chest .. " sent.",
				Icon = "info",
				ImageSource = "Material"
			})
		end
	})
end


-- ==================== TAB 6: IN-GAME CONTROLS & UTILITIES ====================
local TabUtils = Window:CreateTab({
	Name = "Utilities",
	Icon = "tune",
	ImageSource = "Material",
	ShowTitle = true
})

-- --- SECTION 1: OFFICIAL CONTROLS (SERVER-SYNCED) ---
TabUtils:CreateSection("Official Controls (Synced with Game Settings)")

TabUtils:CreateSlider({
	Name = "Set Official Muscle Size",
	Description = "Changes your server-side muscle size (Syncs with in-game settings)",
	Range = {1, 50},
	Increment = 1,
	CurrentValue = 1,
	Callback = function(Val)
		ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", Val)
	end
}, "OfficialSizeSlider")

TabUtils:CreateButton({
	Name = "Preset: Official Size 1 (Anti-Hitbox / Tiny)",
	Callback = function()
		ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", 1)
		Luna:Notification({
			Title = "Size Changed",
			Content = "Your muscle size has been set to 1 (Tiny).",
			Icon = "accessibility",
			ImageSource = "Material"
		})
	end
})

TabUtils:CreateSlider({
	Name = "Set Official WalkSpeed",
	Description = "Syncs with in-game Agility speed settings remote",
	Range = {16, 250},
	Increment = 1,
	CurrentValue = 16,
	Callback = function(Val)
		pcall(function() ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer("changeSpeed", Val) end)
		pcall(function() ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer("changeWalkSpeed", Val) end)
	end
}, "OfficialSpeedSlider")


-- --- SECTION 2: NON-OFFICIAL CONTROLS (CLIENT-SIDE) ---
TabUtils:CreateSection("Non-Official Controls (Client-Side Modifications)")

TabUtils:CreateSlider({
	Name = "Custom WalkSpeed (Client)",
	Description = "Directly modifies Humanoid WalkSpeed value",
	Range = {16, 300},
	Increment = 1,
	CurrentValue = 16,
	Callback = function(Val)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			LocalPlayer.Character.Humanoid.WalkSpeed = Val
		end
	end
}, "CustomWalkSpeed")

TabUtils:CreateSlider({
	Name = "Custom JumpPower (Client)",
	Description = "Directly modifies Humanoid JumpPower value",
	Range = {50, 350},
	Increment = 1,
	CurrentValue = 50,
	Callback = function(Val)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			local hum = LocalPlayer.Character.Humanoid
			hum.UseJumpPower = true
			hum.JumpPower = Val
		end
	end
}, "CustomJumpPower")


-- --- SECTION 3: PERFORMANCE & VISUALS (ANTI-LAG & FPS BOOST) ---
TabUtils:CreateSection("Performance & Clean Screen")

-- Anti-Lag / Fast FPS Booster
TabUtils:CreateButton({
	Name = "🚀 Anti-Lag / Fast FPS Booster",
	Description = "Lowers heavy textures, disables shadows & particles for super smooth FPS",
	Callback = function()
		-- Optimize Lighting
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 9e9
		Lighting.Brightness = 1
		settings().Rendering.QualityLevel = 1

		-- Optimize Workspace Assets
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") and not v:IsA("MeshPart") then
				v.Material = Enum.Material.SmoothPlastic
				v.Reflectance = 0
			elseif v:IsA("Decal") or v:IsA("Texture") then
				v.Transparency = 1
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
				v.Enabled = false
			end
		end
		
		Luna:Notification({
			Title = "FPS Boosted",
			Content = "Anti-Lag & Performance mode activated!",
			Icon = "speed",
			ImageSource = "Material"
		})
	end
})

-- Disable Training Stat Gain Popups / Frames
local hidePopups = false
TabUtils:CreateToggle({
	Name = "Hide Training Stat Popups (Clean Screen)",
	Description = "Removes floating frames and text (+Strength, +Agility, etc.) on screen while grinding",
	CurrentValue = false,
	Callback = function(State)
		hidePopups = State
		if hidePopups then
			disablePopupsConnection = RunService.RenderStepped:Connect(function()
				if hidePopups and LocalPlayer:FindFirstChild("PlayerGui") then
					for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
						if gui:IsA("BillboardGui") or gui:IsA("TextLabel") then
							local txt = gui.Text or ""
							if txt:find("%+") or txt:lower():find("strength") or txt:lower():find("agility") or txt:lower():find("durability") then
								gui.Visible = false
							end
						end
					end
				end
			end)
			Luna:Notification({
				Title = "Popups Disabled",
				Content = "Stat increase frames and floating popups are now hidden.",
				Icon = "visibility_off",
				ImageSource = "Material"
			})
		else
			if disablePopupsConnection then
				disablePopupsConnection:Disconnect()
				disablePopupsConnection = nil
			end
		end
	end
}, "HidePopupsToggle")


-- --- SECTION 4: REDEEM PROMO CODES ---
TabUtils:CreateSection("Redeem Promo Codes")

local activeCodes = {
	"junglegym500",
	"epicmuscle20",
	"mightygems2500",
	"ultimate250",
	"spacegems50",
	"megalift50",
	"speedy50",
	"EpicReward500",
	"MillionWarriors",
	"FrostGems10",
	"Musclestorm50",
	"SkyAgility50",
	"GalaxyCrystal50",
	"SuperMuscle100",
	"SuperPunch100",
	"Launch250"
}

TabUtils:CreateButton({
	Name = "🎁 Redeem All Active Codes",
	Description = "Redeems all active working promo codes in Muscle Legends",
	Callback = function()
		local codeRemote = ReplicatedStorage:FindFirstChild("rEvents") and ReplicatedStorage.rEvents:FindFirstChild("codeRemote")
		if codeRemote then
			for _, code in ipairs(activeCodes) do
				pcall(function() codeRemote:InvokeServer(code) end)
				task.wait(0.08)
			end
			Luna:Notification({
				Title = "Codes Redeemed",
				Content = "All working codes have been submitted to server!",
				Icon = "card_giftcard",
				ImageSource = "Material"
			})
		end
	end
})


-- --- SECTION 5: EXPLOITS & EXTRA UTILITIES ---
TabUtils:CreateSection("Exploits & Extra Features")

TabUtils:CreateToggle({
	Name = "Lock Position",
	Description = "Locks your character's position (Anchors HumanoidRootPart)",
	CurrentValue = false,
	Callback = function(State)
		isLocked = State
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.Anchored = isLocked
		end
	end
}, "LockPosition")

local dndConnection
TabUtils:CreateToggle({
	Name = "Do Not Disturb (DND)",
	CurrentValue = false,
	Callback = function(State)
		china1 = State
		if china1 then
			if not dndConnection then
				dndConnection = RunService.RenderStepped:Connect(function()
					if china1 and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
						LocalPlayer.Character.Humanoid:ChangeState(11)
						LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(4011, 26043, -2394)
					end
				end)
			end
		else
			if dndConnection then
				dndConnection:Disconnect()
				dndConnection = nil
			end
		end
	end
}, "DoNotDisturb")

TabUtils:CreateButton({
	Name = "FE Invis",
	Callback = function()
		local savepos = LocalPlayer.Character.HumanoidRootPart.CFrame
		LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(915.095215, 37.5268936, 349.808533)
		task.wait(0.5)
		local Character = LocalPlayer.Character
		local Clone = Character.LowerTorso.Root:Clone()
		Character.LowerTorso.Root:Destroy()
		Clone.Parent = Character.LowerTorso
		task.wait(0.5)
		LocalPlayer.Character.HumanoidRootPart.CFrame = savepos

		LocalPlayer.CharacterAdded:Connect(function()
			task.wait(3)
			local savepos2 = LocalPlayer.Character.HumanoidRootPart.CFrame
			LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(915.095215, 37.5268936, 349.808533)
			local Character2 = LocalPlayer.Character
			local Clone2 = Character2.LowerTorso.Root:Clone()
			Character2.LowerTorso.Root:Destroy()
			Clone2.Parent = Character2.LowerTorso
			task.wait(0.5)
			LocalPlayer.Character.HumanoidRootPart.CFrame = savepos2 
		end) 
	end
})

TabUtils:CreateButton({
	Name = "Turn Small (Size 1)",
	Callback = function()   
		local args = { [1] = "changeSize", [2] = 1 }
		ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer(unpack(args))
	end
})

TabUtils:CreateButton({
	Name = "BTools",
	Callback = function() 
		game.StarterGui:SetCoreGuiEnabled(2, true)
		local a = Instance.new("HopperBin", LocalPlayer.Backpack)
		a.BinType = 2
		local b = Instance.new("HopperBin", LocalPlayer.Backpack)
		b.BinType = 3
		local c = Instance.new("HopperBin", LocalPlayer.Backpack)
		c.BinType = 4 
	end
})

TabUtils:CreateButton({
	Name = "G NoClip (G to Toggle)",
	Callback = function() 
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
	end
})

TabUtils:CreateButton({
	Name = "B Fly (B to Toggle)",
	Callback = function()
		local gogo1000 = 0
		local MOUSE = LocalPlayer:GetMouse()
		
		MOUSE.KeyDown:Connect(function(KEY)
			if KEY:lower() == 'b' then
				gogo1000 = gogo1000 + 1
				_G.FLYING = false
			
				local T = LocalPlayer.Character.UpperTorso
				local CONTROL = {F = 0, B = 0, L = 0, R = 0}
				local lCONTROL = {F = 0, B = 0, L = 0, R = 0}
				local SPEED = 5
			
				local function FLY()
					_G.FLYING = true
					local BG = Instance.new('BodyGyro', T)
					local BV = Instance.new('BodyVelocity', T)
					BG.P = 9e4
					BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
					BG.cframe = T.CFrame
					BV.velocity = Vector3.new(0, 0.1, 0)
					BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
				
					task.spawn(function()
						repeat task.wait()
							LocalPlayer.Character.Humanoid.PlatformStand = true
							if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 then
								SPEED = 50
							elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0) and SPEED ~= 0 then
								SPEED = 0
							end
							if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 then
								BV.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B) * 0.2, 0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
								lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
							elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and SPEED ~= 0 then
								BV.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B) * 0.2, 0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
							else
								BV.velocity = Vector3.new(0, 0.1, 0)
							end
							BG.cframe = game.Workspace.CurrentCamera.CoordinateFrame
						until not _G.FLYING
						CONTROL = {F = 0, B = 0, L = 0, R = 0}
						lCONTROL = {F = 0, B = 0, L = 0, R = 0}
						SPEED = 0
						BG:Destroy()
						BV:Destroy()
						LocalPlayer.Character.Humanoid.PlatformStand = false
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
			
				if gogo1000 == 2 then
					_G.FLYING = false
					gogo1000 = 0
				end
			end
		end) 
	end
})

TabUtils:CreateButton({
	Name = "Teleport to Random Player",
	Callback = function()
		local allPlrs = Players:GetPlayers()
		local randomPlayer = allPlrs[math.random(1, #allPlrs)]
		if randomPlayer and randomPlayer.Character and randomPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(randomPlayer.Character.Head.Position)
		end 
	end
})

TabUtils:CreateButton({
	Name = "Copy My Coordinates (CFrame)",
	Callback = function()
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local cframe = LocalPlayer.Character.HumanoidRootPart.CFrame
			if setclipboard then
				setclipboard("CFrame.new(" .. tostring(cframe) .. ")")
				Luna:Notification({
					Title = "Coordinates Copied",
					Content = "CFrame position copied to clipboard!",
					Icon = "info",
					ImageSource = "Material"
				})
			end
		end
	end
})

TabUtils:CreateButton({
	Name = "Lag Switch F3",
	Callback = function()
		local lagState = false
		local settingsNet = settings()
		UserInputService.InputEnded:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.F3 then
				lagState = not lagState
				settingsNet.Network.IncomingReplicationLag = lagState and 10 or 0
			end
		end) 
	end
})

TabUtils:CreateButton({
	Name = "ServerHop",
	Callback = function()
		local PlaceID = game.PlaceId
		local AllIDs = {}
		local foundAnything = ""
		local actualHour = os.date("!*t").hour
		local File = pcall(function()
			AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json"))
		end)
		if not File then
			table.insert(AllIDs, actualHour)
			writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
		end
		
		local function TPReturner()
			local Site;
			if foundAnything == "" then
				Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
			else
				Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
			end
			local ID = ""
			if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
				foundAnything = Site.nextPageCursor
			end
			local num = 0;
			for _,v in pairs(Site.data) do
				local Possible = true
				ID = tostring(v.id)
				if tonumber(v.maxPlayers) > tonumber(v.playing) then
					for _,Existing in pairs(AllIDs) do
						if num ~= 0 then
							if ID == tostring(Existing) then
								Possible = false
							end
						else
							if tonumber(actualHour) ~= tonumber(Existing) then
								pcall(function()
									delfile("NotSameServers.json")
									AllIDs = {}
									table.insert(AllIDs, actualHour)
								end)
							end
						end
						num = num + 1
					end
					if Possible == true then
						table.insert(AllIDs, ID)
						task.wait()
						pcall(function()
							writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
							task.wait()
							TeleportService:TeleportToPlaceInstance(PlaceID, ID, LocalPlayer)
						end)
						task.wait(4)
					end
				end
			end
		end

		local function Teleport()
			while task.wait() do
				pcall(function()
					TPReturner()
					if foundAnything ~= "" then
						TPReturner()
					end
				end)
			end
		end
		Teleport()
	end
})

TabUtils:CreateButton({
	Name = "Rejoin Server",
	Callback = function()
		TeleportService:Teleport(game.PlaceId, LocalPlayer) 
	end
})


-- ==================== TAB 7: TELEPORTS ====================
local TabTeleports = Window:CreateTab({
	Name = "Teleports",
	Icon = "place",
	ImageSource = "Material",
	ShowTitle = true
})

local gymLocations = {
	["Legends Gym"] = CFrame.new(4298.60059, 1121.89404, -3898.68066),
	["Mythical Gym"] = CFrame.new(2386.89038, 139.607956, 1094.26367),
	["Frost Gym"] = CFrame.new(-2752.56543, 125.822533, -386.73703),
	["Eternal Gym"] = CFrame.new(-6917.79248, 182.352829, -1336.63928),
	["Tiny Island"] = CFrame.new(-4.25301933, 220.993713, 1963.60168),
	["Muscle King"] = CFrame.new(-8762.23438, 24.8225193, -5714.77148, -0.0424589366, -2.01793515e-08, 0.999098241, 1.09165219e-08, 1, 2.06614867e-08, -0.999098241, 1.17839427e-08, -0.0424589366),
	["Jungle Island"] = CFrame.new(-8583.75781, 14.4014921, 2284.3645, 0.80577755, -1.08421894e-09, -0.59221828, -1.5227688e-09, 1, -3.90266885e-09, 0.59221828, 4.04649469e-09, 0.80577755),
	["Industrial Island"] = CFrame.new(-5174.05225, 68.0752106, 4763.09521, -0.0735666156, -1.07769393e-08, 0.997290313, 1.14036789e-08, 1, 1.16474306e-08, -0.997290313, 1.22296404e-08, -0.0735666156)
}

local brawlLocations = {
	["Brawl Aura 1"] = CFrame.new(985.910645, 163.795364, -7037.80615),
	["Brawl Aura 2"] = CFrame.new(4466.75342, 334.973602, -8425.74512),
	["Brawl Aura 3"] = CFrame.new(-1901.87695, 251.895432, -5899.64795)
}

TabTeleports:CreateSection("Select Gym Location")

TabTeleports:CreateDropdown({
	Name = "Select Gym / Island",
	Description = "Select a location to teleport instantly",
	Options = {"Select Location...", "Legends Gym", "Mythical Gym", "Frost Gym", "Eternal Gym", "Tiny Island", "Muscle King", "Jungle Island", "Industrial Island"},
	CurrentOption = {"Select Location..."},
	MultipleOptions = false,
	Callback = function(OptionTable)
		local choice = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
		if choice ~= "Select Location..." then
			local cframe = gymLocations[choice]
			if cframe and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
			end
		end
	end
}, "GymDropdown")

TabTeleports:CreateSection("Brawl Teleports")

TabTeleports:CreateDropdown({
	Name = "Select Brawl Arena",
	Description = "Select a brawl arena to teleport instantly",
	Options = {"Select Location...", "Brawl Aura 1", "Brawl Aura 2", "Brawl Aura 3"},
	CurrentOption = {"Select Location..."},
	MultipleOptions = false,
	Callback = function(OptionTable)
		local choice = typeof(OptionTable) == "table" and OptionTable[1] or OptionTable
		if choice ~= "Select Location..." then
			local cframe = brawlLocations[choice]
			if cframe and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
			end
		end
	end
}, "BrawlDropdown")


-- ==================== TAB 8: CREDITS & CONFIGS ====================
local TabCredits = Window:CreateTab({
	Name = "Credits & Configs",
	Icon = "info",
	ImageSource = "Material",
	ShowTitle = true
})

TabCredits:CreateSection("Credits")
TabCredits:CreateLabel({ Text = "Credits to a r q for UI Library", Style = 2 })
TabCredits:CreateLabel({ Text = "Credits to DekuDimz#7960", Style = 2 })

TabCredits:CreateSection("Customize UI Theme")
TabCredits:BuildThemeSection()

local TabSave = Window:CreateTab({
	Name = "Config Settings",
	Icon = "settings",
	ImageSource = "Material",
	ShowTitle = true
})
TabSave:BuildConfigSection()

-- Persistent Lock Position Listener
LocalPlayer.CharacterAdded:Connect(function(char)
	if isLocked then
		task.wait(1)
		local hrp = char:WaitForChild("HumanoidRootPart", 5)
		if hrp then hrp.Anchored = true end
	end
end)

-- Anti-AFK Loop
task.spawn(function()
	while true do
		task.wait(600)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
			LocalPlayer.Character.Head:Destroy()
		end
	end
end)
