-- [[ LOUIS HUB: SIMPLIFIED HYBRID LOADER ]]
-- AUTH: Louis | VERSION: 1.7 (FREE - WITH CATEGORY SELECTOR)

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer or Players.PlayerAdded:Wait()

local function SecureKick(msg)
    pcall(function() LP:Kick(msg) end)
end

-- Clipboard fallback resolver
local setclipboard = setclipboard or toclipboard or set_clipboard or (syn and syn.write_clipboard)

-- [[ DATABASE MAPPING (Place ID / Game ID) ]]
local SupportedGames = {
    [11379739543] = {
        GameName = "Timebomb Duels Free Version",
        Options = {
            {
                Name = "Timebomb Duels Max",
                ScriptURL = "https://raw.githubusercontent.com/gamerlatahzan-design/SSLH-SourceCode-/main/SourceCodeTBDFreeMaxVersion.lua"
            },
            {
                Name = "Timebomb Duels Lite",
                ScriptURL = "https://raw.githubusercontent.com/gamerlatahzan-design/SSLH-SourceCode-/main/SourceCodeTBDFreeLiteVersion.lua"
            }
        }
    },
    [98752102030179] = {
        GameName = "Timebomb Duels Free Version (Pro Server)",
        Options = {
            {
                Name = "Timebomb Duels Free",
                ScriptURL = "https://raw.githubusercontent.com/gamerlatahzan-design/SSLH-SourceCode-/main/SourceCodeTBDFreeMaxVersion.lua"
            },
            {
                Name = "Timebomb Duels Lite",
                ScriptURL = "https://raw.githubusercontent.com/gamerlatahzan-design/SSLH-SourceCode-/main/SourceCodeTBDFreeLiteVersion.lua"
            }
        }
    },
    [100178831086674] = {
        GameName = "Time Bomb AnkleBreak Free Version",
        Options = {
            {
                Name = "Time Bomb AnkleBreak Max",
                ScriptURL = "https://raw.githubusercontent.com/gamerlatahzan-design/SSLH-SourceCode-/main/SourceCodeTBDFreeMaxVersion.lua"
            },
            {
                Name = "Time Bomb AnkleBreak Lite",
                ScriptURL = "https://raw.githubusercontent.com/gamerlatahzan-design/SSLH-SourceCode-/main/SourceCodeTBDFreeLiteVersion.lua"
            }
        }
    },
    [142823291] = {
        GameName = "Murder Mystery 2",
        Options = {
            {
                Name = "Murder Mystery 2",
                ScriptURL = "https://raw.githubusercontent.com/gamerlatahzan-design/SSLH-SourceCode-/main/SourceCodeMM2Version.lua"
            }
        }
    },
    [121330469999373] = {
        GameName = "MMV",
        Options = {
            {
                Name = "MMV",
                ScriptURL = "https://raw.githubusercontent.com/gamerlatahzan-design/SSLH-SourceCode-/main/SourceCodeMM2Version.lua"
            }
        }
    }
}

local CurrentPlaceID = game.PlaceId
local CurrentUniverseID = game.GameId
local GameData = SupportedGames[CurrentPlaceID] or SupportedGames[CurrentUniverseID]

-- Map ID Validation & Fallback Logic
if not GameData then
    GameData = {
        GameName = "Universal Aimbot",
        Options = {
            {
                Name = "Universal Aimbot",
                ScriptURL = "https://raw.githubusercontent.com/gamerlatahzan-design/SSLH-SourceCode-/main/SourceCodeAimbotUniversalVersion.lua"
            }
        }
    }
end

-- [[ FETCH & EXECUTION ]]
local function ExecuteScript(selectedOption)
    local content
    for i = 1, 3 do
        local success, res = pcall(function() 
            return game:HttpGet(selectedOption.ScriptURL .. "?cache=" .. math.random(1, 999999)) 
        end)
        if success and res and res ~= "404: Not Found" then 
            content = res 
            break 
        end
        task.wait(1)
    end

    if not content then
        SecureKick("LOUIS HUB: Failed to download script assets.")
        return
    end

    -- Execute script via standard loadstring
    local compileSuccess, mainFunc = pcall(loadstring, content)
    if compileSuccess and type(mainFunc) == "function" then
        local runSuccess, runResult = pcall(mainFunc)
        if not runSuccess then
            warn("LOUIS HUB: Runtime error during execution: " .. tostring(runResult))
        end
    else
        SecureKick("LOUIS HUB: Failed to process script.")
    end
end

-- [[ UI SELECTION GENERATOR ]]
local function CreateSelectorUI(gameData, onSelected)
    -- Target ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LouisHubSelector"
    ScreenGui.ResetOnSpawn = false
    
    local coreGuiSuccess, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if coreGuiSuccess and coreGui then
        ScreenGui.Parent = coreGui
    else
        ScreenGui.Parent = LP:WaitForChild("PlayerGui")
    end

    ---------------------------------------------------------
    -- [0] SCREEN BLUR EFFECT (~30% INTENSITY)
    ---------------------------------------------------------
    local BlurEffect = Instance.new("BlurEffect")
    BlurEffect.Name = "LouisHubBlur"
    BlurEffect.Size = 0
    BlurEffect.Parent = Lighting

    -- Fade-in blur animation
    TweenService:Create(BlurEffect, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = 18
    }):Play()

    -- Calculate UI Dimensions
    local optionCount = #gameData.Options
    local targetHeight = 50 + (optionCount * 46) + 15
    if targetHeight < 175 then targetHeight = 175 end
    if targetHeight > 380 then targetHeight = 380 end

    ---------------------------------------------------------
    -- [1] LEFT FRAME: VERSION INFORMATION
    ---------------------------------------------------------
    local InfoFrame = Instance.new("Frame")
    InfoFrame.Name = "InfoFrame"
    InfoFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    InfoFrame.Position = UDim2.new(0.5, -165, 0.5, 0)
    InfoFrame.Size = UDim2.new(0, 230, 0, 0)
    InfoFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    InfoFrame.BackgroundTransparency = 0.4 -- 40% Background Transparency
    InfoFrame.BorderSizePixel = 0
    InfoFrame.ClipsDescendants = true
    InfoFrame.Parent = ScreenGui

    local InfoCorner = Instance.new("UICorner")
    InfoCorner.CornerRadius = UDim.new(0, 10)
    InfoCorner.Parent = InfoFrame

    local InfoStroke = Instance.new("UIStroke")
    InfoStroke.Thickness = 1.5
    InfoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    InfoStroke.Parent = InfoFrame

    -- Info Header
    local InfoHeader = Instance.new("Frame")
    InfoHeader.Name = "Header"
    InfoHeader.Size = UDim2.new(1, 0, 0, 50)
    InfoHeader.BackgroundTransparency = 1
    InfoHeader.Parent = InfoFrame

    local InfoTitle = Instance.new("TextLabel")
    InfoTitle.Name = "Title"
    InfoTitle.Size = UDim2.new(1, 0, 0, 25)
    InfoTitle.Position = UDim2.new(0, 0, 0, 10)
    InfoTitle.BackgroundTransparency = 1
    InfoTitle.Text = "VERSION GUIDE"
    InfoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    InfoTitle.Font = Enum.Font.GothamBold
    InfoTitle.TextSize = 13
    InfoTitle.Parent = InfoHeader

    local InfoSubTitle = Instance.new("TextLabel")
    InfoSubTitle.Name = "SubTitle"
    InfoSubTitle.Size = UDim2.new(1, 0, 0, 15)
    InfoSubTitle.Position = UDim2.new(0, 0, 0, 30)
    InfoSubTitle.BackgroundTransparency = 1
    InfoSubTitle.Text = "Device Performance Guide"
    InfoSubTitle.TextColor3 = Color3.fromRGB(190, 170, 220)
    InfoSubTitle.Font = Enum.Font.GothamSemibold
    InfoSubTitle.TextSize = 10
    InfoSubTitle.Parent = InfoHeader

    -- Info Content
    local InfoContent = Instance.new("Frame")
    InfoContent.Name = "Content"
    InfoContent.Size = UDim2.new(1, -24, 1, -55)
    InfoContent.Position = UDim2.new(0, 12, 0, 50)
    InfoContent.BackgroundTransparency = 1
    InfoContent.Parent = InfoFrame

    local InfoListLayout = Instance.new("UIListLayout")
    InfoListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    InfoListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    InfoListLayout.Padding = UDim.new(0, 6)
    InfoListLayout.Parent = InfoContent

    -- Lite Info Section (Lucide Icon: zap)
    local LiteHeaderRow = Instance.new("Frame")
    LiteHeaderRow.Size = UDim2.new(1, 0, 0, 16)
    LiteHeaderRow.BackgroundTransparency = 1
    LiteHeaderRow.Parent = InfoContent

    local LiteIcon = Instance.new("ImageLabel")
    LiteIcon.Name = "Icon"
    LiteIcon.Size = UDim2.new(0, 15, 0, 15)
    LiteIcon.Position = UDim2.new(0, 0, 0.5, 0)
    LiteIcon.AnchorPoint = Vector2.new(0, 0.5)
    LiteIcon.BackgroundTransparency = 1
    LiteIcon.Image = "rbxassetid://10723343321" -- Raw Lucide Zap Image Asset ID
    LiteIcon.ImageColor3 = Color3.fromRGB(220, 180, 255)
    LiteIcon.ScaleType = Enum.ScaleType.Fit
    LiteIcon.Parent = LiteHeaderRow

    -- Fallback handler if image fails to render
    LiteIcon:GetPropertyChangedSignal("IsLoaded"):Connect(function()
        if not LiteIcon.IsLoaded then
            LiteIcon.Image = "rbxassetid://10709819149" -- Automatic Fallback Asset ID
        end
    end)

    local LiteTitle = Instance.new("TextLabel")
    LiteTitle.Size = UDim2.new(1, -20, 1, 0)
    LiteTitle.Position = UDim2.new(0, 20, 0, 0)
    LiteTitle.BackgroundTransparency = 1
    LiteTitle.Text = "LITE VERSION"
    LiteTitle.TextColor3 = Color3.fromRGB(220, 180, 255)
    LiteTitle.Font = Enum.Font.GothamBold
    LiteTitle.TextSize = 11
    LiteTitle.TextXAlignment = Enum.TextXAlignment.Left
    LiteTitle.Parent = LiteHeaderRow

    local LiteDesc = Instance.new("TextLabel")
    LiteDesc.Size = UDim2.new(1, 0, 0, 36)
    LiteDesc.BackgroundTransparency = 1
    LiteDesc.Text = "Specifically designed for low-end / potato devices. Maximizes performance and reduces lag."
    LiteDesc.TextColor3 = Color3.fromRGB(210, 210, 210)
    LiteDesc.Font = Enum.Font.Gotham
    LiteDesc.TextSize = 9
    LiteDesc.TextWrapped = true
    LiteDesc.TextXAlignment = Enum.TextXAlignment.Left
    LiteDesc.TextYAlignment = Enum.TextYAlignment.Top
    LiteDesc.Parent = InfoContent

    -- Separator
    local Separator = Instance.new("Frame")
    Separator.Size = UDim2.new(1, 0, 0, 1)
    Separator.BackgroundColor3 = Color3.fromRGB(60, 45, 80)
    Separator.BorderSizePixel = 0
    Separator.Parent = InfoContent

    -- Max Info Section (Lucide Icon: flame)
    local MaxHeaderRow = Instance.new("Frame")
    MaxHeaderRow.Size = UDim2.new(1, 0, 0, 16)
    MaxHeaderRow.BackgroundTransparency = 1
    MaxHeaderRow.Parent = InfoContent

    local MaxIcon = Instance.new("ImageLabel")
    MaxIcon.Name = "Icon"
    MaxIcon.Size = UDim2.new(0, 15, 0, 15)
    MaxIcon.Position = UDim2.new(0, 0, 0.5, 0)
    MaxIcon.AnchorPoint = Vector2.new(0, 0.5)
    MaxIcon.BackgroundTransparency = 1
    MaxIcon.Image = "rbxassetid://10723376114" -- Raw Lucide Flame Image Asset ID
    MaxIcon.ImageColor3 = Color3.fromRGB(220, 180, 255)
    MaxIcon.ScaleType = Enum.ScaleType.Fit
    MaxIcon.Parent = MaxHeaderRow

    local MaxTitle = Instance.new("TextLabel")
    MaxTitle.Size = UDim2.new(1, -20, 1, 0)
    MaxTitle.Position = UDim2.new(0, 20, 0, 0)
    MaxTitle.BackgroundTransparency = 1
    MaxTitle.Text = "MAX VERSION"
    MaxTitle.TextColor3 = Color3.fromRGB(220, 180, 255)
    MaxTitle.Font = Enum.Font.GothamBold
    MaxTitle.TextSize = 11
    MaxTitle.TextXAlignment = Enum.TextXAlignment.Left
    MaxTitle.Parent = MaxHeaderRow

    local MaxDesc = Instance.new("TextLabel")
    MaxDesc.Size = UDim2.new(1, 0, 0, 36)
    MaxDesc.BackgroundTransparency = 1
    MaxDesc.Text = "Designed for standard / normal devices. Unlocks complete features and maximum capabilities."
    MaxDesc.TextColor3 = Color3.fromRGB(210, 210, 210)
    MaxDesc.Font = Enum.Font.Gotham
    MaxDesc.TextSize = 9
    MaxDesc.TextWrapped = true
    MaxDesc.TextXAlignment = Enum.TextXAlignment.Left
    MaxDesc.TextYAlignment = Enum.TextYAlignment.Top
    MaxDesc.Parent = InfoContent

    ---------------------------------------------------------
    -- [2] RIGHT TOP FRAME: SELECTION MENU
    ---------------------------------------------------------
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 115, 0.5, -32)
    MainFrame.Size = UDim2.new(0, 310, 0, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BackgroundTransparency = 0.4 -- 40% Background Transparency
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 1.5
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = MainFrame

    -- Header Frame
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = "LOUIS HUB FREE"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.Parent = Header

    local SubTitle = Instance.new("TextLabel")
    SubTitle.Name = "SubTitle"
    SubTitle.Size = UDim2.new(1, 0, 0, 15)
    SubTitle.Position = UDim2.new(0, 0, 0, 30)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "Select version for " .. gameData.GameName
    SubTitle.TextColor3 = Color3.fromRGB(190, 170, 220)
    SubTitle.Font = Enum.Font.GothamSemibold
    SubTitle.TextSize = 10
    SubTitle.Parent = Header

    -- Content Frame
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 1, -50)
    Content.Position = UDim2.new(0, 0, 0, 50)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.Parent = Content

    -- Option Buttons Construction
    for idx, option in ipairs(gameData.Options) do
        local Button = Instance.new("TextButton")
        Button.Name = option.Name
        Button.Size = UDim2.new(0, 275, 0, 38)
        Button.BackgroundColor3 = Color3.fromRGB(25, 22, 32)
        Button.BackgroundTransparency = 0.3
        Button.BorderSizePixel = 0
        Button.Text = option.Name
        Button.TextColor3 = Color3.fromRGB(240, 240, 240)
        Button.Font = Enum.Font.GothamBold
        Button.TextSize = 11
        Button.Parent = Content

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = Button

        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Thickness = 1
        BtnStroke.Color = Color3.fromRGB(60, 45, 80)
        BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        BtnStroke.Parent = Button

        -- Hover Animations
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(50, 35, 75),
                BackgroundTransparency = 0.15,
                Size = UDim2.new(0, 280, 0, 38)
            }):Play()
            TweenService:Create(BtnStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Color = Color3.fromRGB(180, 130, 240)
            }):Play()
        end)

        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(25, 22, 32),
                BackgroundTransparency = 0.3,
                Size = UDim2.new(0, 275, 0, 38)
            }):Play()
            TweenService:Create(BtnStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Color = Color3.fromRGB(60, 45, 80)
            }):Play()
        end)

        Button.MouseButton1Down:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(70, 45, 95),
                BackgroundTransparency = 0.05
            }):Play()
        end)

        -- Close UI & Exit Blur Animation On Select
        Button.MouseButton1Click:Connect(function()
            -- Play Exit Tweens
            local closeMain = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 310, 0, 0)
            })
            local closeInfo = TweenService:Create(InfoFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 230, 0, 0)
            })
            local closeBlur = TweenService:Create(BlurEffect, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = 0
            })

            closeMain:Play()
            closeInfo:Play()
            closeBlur:Play()

            closeMain.Completed:Wait()
            BlurEffect:Destroy()
            ScreenGui:Destroy()
            
            onSelected(option)
        end)
    end

    ---------------------------------------------------------
    -- [3] RIGHT BOTTOM FRAME: DISCORD COMMUNITY FRAME
    ---------------------------------------------------------
    local DiscordFrame = Instance.new("TextButton")
    DiscordFrame.Name = "DiscordFrame"
    DiscordFrame.AnchorPoint = Vector2.new(0.5, 0)
    DiscordFrame.Position = UDim2.new(0.5, 115, 0.5, (targetHeight / 2) - 22)
    DiscordFrame.Size = UDim2.new(0, 310, 0, 52)
    DiscordFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    DiscordFrame.BackgroundTransparency = 0.4 -- 40% Background Transparency
    DiscordFrame.BorderSizePixel = 0
    DiscordFrame.AutoButtonColor = false
    DiscordFrame.Text = ""
    DiscordFrame.ClipsDescendants = true
    DiscordFrame.Parent = ScreenGui

    local DiscordCorner = Instance.new("UICorner")
    DiscordCorner.CornerRadius = UDim.new(0, 10)
    DiscordCorner.Parent = DiscordFrame

    local DiscordStroke = Instance.new("UIStroke")
    DiscordStroke.Thickness = 1.5
    DiscordStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    DiscordStroke.Parent = DiscordFrame

    -- Discord Icon
    local DiscordIcon = Instance.new("ImageLabel")
    DiscordIcon.Name = "DiscordIcon"
    DiscordIcon.Size = UDim2.new(0, 22, 0, 22)
    DiscordIcon.Position = UDim2.new(0, 14, 0.5, 0)
    DiscordIcon.AnchorPoint = Vector2.new(0, 0.5)
    DiscordIcon.BackgroundTransparency = 1
    DiscordIcon.Image = "rbxassetid://10734888228" -- Lucide Message/Community Icon
    DiscordIcon.ImageColor3 = Color3.fromRGB(180, 140, 255)
    DiscordIcon.ScaleType = Enum.ScaleType.Fit
    DiscordIcon.Parent = DiscordFrame

    -- Discord Title
    local DiscordTitle = Instance.new("TextLabel")
    DiscordTitle.Name = "Title"
    DiscordTitle.Size = UDim2.new(1, -50, 0, 18)
    DiscordTitle.Position = UDim2.new(0, 44, 0, 9)
    DiscordTitle.BackgroundTransparency = 1
    DiscordTitle.Text = "JOIN DISCORD COMMUNITY"
    DiscordTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    DiscordTitle.Font = Enum.Font.GothamBold
    DiscordTitle.TextSize = 11
    DiscordTitle.TextXAlignment = Enum.TextXAlignment.Left
    DiscordTitle.Parent = DiscordFrame

    -- Discord Subtitle / Link
    local DiscordSubTitle = Instance.new("TextLabel")
    DiscordSubTitle.Name = "SubTitle"
    DiscordSubTitle.Size = UDim2.new(1, -50, 0, 14)
    DiscordSubTitle.Position = UDim2.new(0, 44, 0, 27)
    DiscordSubTitle.BackgroundTransparency = 1
    DiscordSubTitle.Text = "https://discord.gg/xhxMeyzana"
    DiscordSubTitle.TextColor3 = Color3.fromRGB(190, 170, 220)
    DiscordSubTitle.Font = Enum.Font.Gotham
    DiscordSubTitle.TextSize = 10
    DiscordSubTitle.TextXAlignment = Enum.TextXAlignment.Left
    DiscordSubTitle.Parent = DiscordFrame

    -- Click Event: Auto-Copy Clipboard & Feedback
    DiscordFrame.MouseButton1Click:Connect(function()
        if setclipboard then
            pcall(function()
                setclipboard("https://discord.gg/xhxMeyzana")
            end)
        end

        DiscordSubTitle.Text = "✓ Copied to Clipboard!"
        DiscordSubTitle.TextColor3 = Color3.fromRGB(130, 255, 170)

        task.delay(2, function()
            if DiscordSubTitle and DiscordSubTitle.Parent then
                DiscordSubTitle.Text = "https://discord.gg/xhxMeyzana"
                DiscordSubTitle.TextColor3 = Color3.fromRGB(190, 170, 220)
            end
        end)
    end)

    -- Hover effect for Discord Button
    DiscordFrame.MouseEnter:Connect(function()
        TweenService:Create(DiscordFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(30, 25, 45),
            BackgroundTransparency = 0.25
        }):Play()
    end)

    DiscordFrame.MouseLeave:Connect(function()
        TweenService:Create(DiscordFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(15, 15, 15),
            BackgroundTransparency = 0.4
        }):Play()
    end)

    ---------------------------------------------------------
    -- [4] WHITE & PURPLE ANIMATED STROKE (LOOP)
    ---------------------------------------------------------
    task.spawn(function()
        local colorWhite = Color3.fromRGB(255, 255, 255)
        local colorPurple = Color3.fromRGB(170, 0, 255)
        local timer = 0

        while MainFrame and MainFrame.Parent do
            timer = timer + 0.03
            local alpha = (math.sin(timer) + 1) / 2 -- Smooth sine wave transition
            local animatedColor = colorWhite:Lerp(colorPurple, alpha)

            MainStroke.Color = animatedColor
            InfoStroke.Color = animatedColor
            DiscordStroke.Color = animatedColor
            task.wait(0.02)
        end
    end)

    ---------------------------------------------------------
    -- [5] EXECUTION ENTRANCE ANIMATIONS
    ---------------------------------------------------------
    TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 310, 0, targetHeight)
    }):Play()

    TweenService:Create(InfoFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 230, 0, targetHeight)
    }):Play()
end

-- [[ FLOW CONTROLLER ]]
if #GameData.Options > 1 then
    CreateSelectorUI(GameData, function(selectedOption)
        ExecuteScript(selectedOption)
    end)
else
    ExecuteScript(GameData.Options[1])
end
