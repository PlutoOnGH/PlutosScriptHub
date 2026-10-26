--==================================================
-- PLUTO'S SCRIPT HUB
-- MURDER MYSTERY 2
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local DiscordInvite = "https://discord.gg/sr9Q3rn9Bf"

local Rayfield = loadstring(game:HttpGet(
    "https://sirius.menu/rayfield"
))()

local Window = Rayfield:CreateWindow({
    Name = "Pluto's Script Hub",
    LoadingTitle = "Pluto's Script Hub",
    LoadingSubtitle = "Murder Mystery 2",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false,
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    Size = UDim2.new(0, 350, 0, 300)
})

local function Notify(title, message, duration)
    Rayfield:Notify({
        Title = title,
        Content = message,
        Duration = duration or 5
    })
end

--==================================================
-- CONFIGURATION STATE
--==================================================

local ConfigValues = {
    RoleESPToggle = false,
    CoinESPToggle = false,
    AutoCoinsToggle = false,
    AutoPickupToggle = false,
    RoleNotifierToggle = false,

    WalkSpeedToggle = false,
    WalkSpeedSlider = 32,
    InfiniteJumpToggle = false,
    NoclipToggle = false,
    AntiAFKToggle = false
}

local ConfigControls = {}

local LoopTokens = {}

local function StartLoop(key, interval, action)
    LoopTokens[key] = (LoopTokens[key] or 0) + 1
    local token = LoopTokens[key]

    task.spawn(function()
        while ConfigValues[key] and LoopTokens[key] == token do
            local ok, err = pcall(action)

            if not ok then
                warn("[Pluto's Script Hub] " .. key .. ": " .. tostring(err))
            end

            task.wait(interval)
        end
    end)
end

local function StopLoop(key)
    LoopTokens[key] = (LoopTokens[key] or 0) + 1
end

--==================================================
-- MURDER MYSTERY 2 HELPERS
--==================================================

local MURDERER_TOOLS = {"Knife"}
local SHERIFF_TOOLS = {"Gun", "Revolver"}

local ROLE_COLORS = {
    Murderer = Color3.fromRGB(255, 60, 60),
    Sheriff = Color3.fromRGB(60, 150, 255),
    Innocent = Color3.fromRGB(0, 255, 0)
}

local function HasTool(player, toolNames)
    local containers = {}
    local character = player.Character
    local backpack = player:FindFirstChildOfClass("Backpack")

    if character then
        table.insert(containers, character)
    end

    if backpack then
        table.insert(containers, backpack)
    end

    for _, container in ipairs(containers) do
        for _, toolName in ipairs(toolNames) do
            local tool = container:FindFirstChild(toolName)

            if tool and tool:IsA("Tool") then
                return true
            end
        end
    end

    return false
end

local function GetRole(player)
    if HasTool(player, MURDERER_TOOLS) then
        return "Murderer"
    end

    if HasTool(player, SHERIFF_TOOLS) then
        return "Sheriff"
    end

    return nil
end

local function IsInsidePlayerCharacter(object)
    local current = object

    while current and current ~= workspace do
        if current:IsA("Model") and Players:GetPlayerFromCharacter(current) then
            return true
        end

        current = current.Parent
    end

    return false
end

local function GetCoinParts()
    local coins = {}

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("BasePart")
            and string.find(string.lower(object.Name), "coin", 1, true)
            and not IsInsidePlayerCharacter(object) then

            table.insert(coins, object)
        end
    end

    return coins
end

local function GetDroppedWeapons()
    local weapons = {}

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("Tool") and not IsInsidePlayerCharacter(object) then
            local name = string.lower(object.Name)

            if string.find(name, "gun", 1, true)
                or string.find(name, "knife", 1, true) then

                table.insert(weapons, object)
            end
        end
    end

    return weapons
end

local function TouchObject(target)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not root or not target or not target.Parent then
        return false
    end

    local part = target

    if not part:IsA("BasePart") then
        part = target:FindFirstChild("Handle")
            or target:FindFirstChildWhichIsA("BasePart", true)
    end

    if not part then
        return false
    end

    if typeof(firetouchinterest) == "function" then
        pcall(firetouchinterest, root, part, 0)
        pcall(firetouchinterest, root, part, 1)
        return true
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid:MoveTo(part.Position)
        return true
    end

    return false
end

--==================================================
-- MURDER MYSTERY 2 TAB
--==================================================

local MM2Tab = Window:CreateTab("🔪 Murder Mystery 2")

MM2Tab:CreateParagraph({
    Title = "Murder Mystery 2",
    Content = "Role trackers, coin helpers, and weapon pickup automation."
})

-- ROLES

MM2Tab:CreateSection("Roles")

local RoleESPEnabled = false
local RoleESPObjects = {}

local function RemoveRoleESP(player)
    local data = RoleESPObjects[player]

    if not data then
        return
    end

    if data.Highlight then
        data.Highlight:Destroy()
    end

    if data.Billboard then
        data.Billboard:Destroy()
    end

    RoleESPObjects[player] = nil
end

local function ClearRoleESP()
    local players = {}

    for player in pairs(RoleESPObjects) do
        table.insert(players, player)
    end

    for _, player in ipairs(players) do
        RemoveRoleESP(player)
    end
end

local function CreateRoleESP(player, role)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not character or not root then
        return
    end

    RemoveRoleESP(player)

    local color = ROLE_COLORS[role]

    local highlight = Instance.new("Highlight")
    highlight.Name = "PlutoRoleESP"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = color
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.35
    highlight.OutlineTransparency = 0.1
    highlight.Parent = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlutoRoleTag"
    billboard.Adornee = root
    billboard.Size = UDim2.new(0, 200, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = role:upper() .. " | " .. player.DisplayName
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.25
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    RoleESPObjects[player] = {
        Role = role,
        Highlight = highlight,
        Billboard = billboard
    }
end

local function UpdateRoleESP()
    if not RoleESPEnabled then
        if next(RoleESPObjects) then
            ClearRoleESP()
        end

        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local role = GetRole(player) or "Innocent"
            local data = RoleESPObjects[player]

            if not data
                or data.Role ~= role
                or not data.Highlight
                or data.Highlight.Adornee ~= player.Character then

                CreateRoleESP(player, role)
            end
        end
    end

    for player in pairs(RoleESPObjects) do
        if not player.Parent or not player.Character then
            RemoveRoleESP(player)
        end
    end
end

ConfigControls.RoleESPToggle = MM2Tab:CreateToggle({
    Name = "Role ESP",
    CurrentValue = false,
    Flag = "RoleESPToggle",

    Callback = function(value)
        ConfigValues.RoleESPToggle = value
        RoleESPEnabled = value

        if not value then
            ClearRoleESP()
        end
    end
})

task.spawn(function()
    while task.wait(0.5) do
        local ok, err = pcall(UpdateRoleESP)

        if not ok then
            warn("[Pluto's Script Hub] Role ESP: " .. tostring(err))
        end
    end
end)

-- ROLE NOTIFIER

local RoleNotifierEnabled = false
local LastMurderer = nil
local LastSheriff = nil

local function CheckRoles()
    local murderer, sheriff = nil, nil

    for _, player in ipairs(Players:GetPlayers()) do
        local role = GetRole(player)

        if role == "Murderer" then
            murderer = player
        elseif role == "Sheriff" then
            sheriff = player
        end
    end

    if murderer and murderer ~= LastMurderer then
        if murderer == LocalPlayer then
            Notify("Roles", "You are the Murderer!")
        else
            Notify("Roles", murderer.DisplayName .. " is the Murderer")
        end
    end

    if sheriff and sheriff ~= LastSheriff then
        if sheriff == LocalPlayer then
            Notify("Roles", "You are the Sheriff!")
        else
            Notify("Roles", sheriff.DisplayName .. " is the Sheriff")
        end
    end

    LastMurderer = murderer
    LastSheriff = sheriff
end

ConfigControls.RoleNotifierToggle = MM2Tab:CreateToggle({
    Name = "Role Notifier",
    CurrentValue = false,
    Flag = "RoleNotifierToggle",

    Callback = function(value)
        ConfigValues.RoleNotifierToggle = value
        RoleNotifierEnabled = value

        if value then
            StartLoop("RoleNotifierToggle", 1, CheckRoles)
        else
            StopLoop("RoleNotifierToggle")
            LastMurderer = nil
            LastSheriff = nil
        end
    end
})

-- COINS

MM2Tab:CreateSection("Coins")

local CoinESPEnabled = false
local CoinESPObjects = {}

local function RemoveCoinESP(part)
    local billboard = CoinESPObjects[part]

    if billboard then
        billboard:Destroy()
    end

    CoinESPObjects[part] = nil
end

local function ClearCoinESP()
    local parts = {}

    for part in pairs(CoinESPObjects) do
        table.insert(parts, part)
    end

    for _, part in ipairs(parts) do
        RemoveCoinESP(part)
    end
end

local function CreateCoinESP(part)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlutoCoinESP"
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 60, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 1.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = "Coin"
    label.TextColor3 = Color3.fromRGB(255, 215, 0)
    label.TextStrokeTransparency = 0.35
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    return billboard
end

local function UpdateCoinESP()
    if not CoinESPEnabled then
        return
    end

    local seen = {}

    for _, coin in ipairs(GetCoinParts()) do
        seen[coin] = true

        if not CoinESPObjects[coin] then
            CoinESPObjects[coin] = CreateCoinESP(coin)
        end
    end

    local stale = {}

    for part in pairs(CoinESPObjects) do
        if not seen[part] or not part.Parent then
            table.insert(stale, part)
        end
    end

    for _, part in ipairs(stale) do
        RemoveCoinESP(part)
    end
end

ConfigControls.CoinESPToggle = MM2Tab:CreateToggle({
    Name = "Coin ESP",
    CurrentValue = false,
    Flag = "CoinESPToggle",

    Callback = function(value)
        ConfigValues.CoinESPToggle = value
        CoinESPEnabled = value

        if value then
            StartLoop("CoinESPToggle", 1, UpdateCoinESP)
        else
            StopLoop("CoinESPToggle")
            ClearCoinESP()
        end
    end
})

local function CollectCoins()
    local coins = GetCoinParts()

    if #coins == 0 then
        return
    end

    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not character or not root then
        return
    end

    if typeof(firetouchinterest) ~= "function" then
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if not humanoid then
            return
        end

        local nearest, nearestDistance = nil, math.huge

        for _, coin in ipairs(coins) do
            local distance = (coin.Position - root.Position).Magnitude

            if distance < nearestDistance then
                nearest, nearestDistance = coin, distance
            end
        end

        if nearest then
            humanoid:MoveTo(nearest.Position)
        end

        return
    end

    for _, coin in ipairs(coins) do
        if not ConfigValues.AutoCoinsToggle then
            return
        end

        pcall(firetouchinterest, root, coin, 0)
        pcall(firetouchinterest, root, coin, 1)
        task.wait(0.05)
    end
end

ConfigControls.AutoCoinsToggle = MM2Tab:CreateToggle({
    Name = "Auto Collect Coins",
    CurrentValue = false,
    Flag = "AutoCoinsToggle",

    Callback = function(value)
        ConfigValues.AutoCoinsToggle = value

        if value then
            StartLoop("AutoCoinsToggle", 1, CollectCoins)
        else
            StopLoop("AutoCoinsToggle")
        end
    end
})

-- WEAPONS

MM2Tab:CreateSection("Weapons")

local function PickupWeapons()
    for _, weapon in ipairs(GetDroppedWeapons()) do
        if not ConfigValues.AutoPickupToggle then
            return
        end

        TouchObject(weapon)
        task.wait(0.15)
    end
end

ConfigControls.AutoPickupToggle = MM2Tab:CreateToggle({
    Name = "Auto Pickup Dropped Weapons",
    CurrentValue = false,
    Flag = "AutoPickupToggle",

    Callback = function(value)
        ConfigValues.AutoPickupToggle = value

        if value then
            StartLoop("AutoPickupToggle", 1, PickupWeapons)
        else
            StopLoop("AutoPickupToggle")
        end
    end
})

MM2Tab:CreateParagraph({
    Title = "Notes",
    Content = "Role detection reads the Knife and Gun tools from player inventories. Anyone without either is shown as an innocent in bright green."
})

--==================================================
-- PLAYER TAB
--==================================================

local PlayerTab = Window:CreateTab("Player")

-- WALK SPEED

local WalkSpeedEnabled = false
local WalkSpeedValue = 32
local OriginalWalkSpeed = nil
local WalkSpeedConnection = nil

local function ApplyWalkSpeed()
    if not WalkSpeedEnabled then
        return
    end

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        if OriginalWalkSpeed == nil then
            OriginalWalkSpeed = humanoid.WalkSpeed
        end

        humanoid.WalkSpeed = WalkSpeedValue
    end
end

local function SetWalkSpeedEnabled(value)
    WalkSpeedEnabled = value

    if WalkSpeedConnection then
        WalkSpeedConnection:Disconnect()
        WalkSpeedConnection = nil
    end

    if value then
        OriginalWalkSpeed = nil
        ApplyWalkSpeed()

        WalkSpeedConnection = LocalPlayer.CharacterAdded:Connect(function(character)
            OriginalWalkSpeed = nil
            character:WaitForChild("Humanoid", 5)
            task.wait(0.1)
            ApplyWalkSpeed()
        end)
    else
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid and OriginalWalkSpeed then
            humanoid.WalkSpeed = OriginalWalkSpeed
        end

        OriginalWalkSpeed = nil
    end
end

ConfigControls.WalkSpeedToggle = PlayerTab:CreateToggle({
    Name = "Walk Speed",
    CurrentValue = false,
    Flag = "WalkSpeedToggle",

    Callback = function(value)
        ConfigValues.WalkSpeedToggle = value
        SetWalkSpeedEnabled(value)
    end
})

ConfigControls.WalkSpeedSlider = PlayerTab:CreateSlider({
    Name = "Walk Speed Amount",
    Range = {16, 100},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 32,
    Flag = "WalkSpeedSlider",

    Callback = function(value)
        ConfigValues.WalkSpeedSlider = value
        WalkSpeedValue = value
        ApplyWalkSpeed()
    end
})

-- INFINITE JUMP

local InfiniteJumpEnabled = false

UserInputService.JumpRequest:Connect(function()
    if not InfiniteJumpEnabled then
        return
    end

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

ConfigControls.InfiniteJumpToggle = PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",

    Callback = function(value)
        ConfigValues.InfiniteJumpToggle = value
        InfiniteJumpEnabled = value
    end
})

-- NOCLIP

local NoclipEnabled = false
local NoclipConnection = nil

local function SetNoclip(value)
    NoclipEnabled = value

    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end

    if value then
        NoclipConnection = RunService.Stepped:Connect(function()
            local character = LocalPlayer.Character

            if not character then
                return
            end

            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        local character = LocalPlayer.Character

        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

ConfigControls.NoclipToggle = PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",

    Callback = function(value)
        ConfigValues.NoclipToggle = value
        SetNoclip(value)
    end
})

-- ANTI-AFK

local AntiAFKEnabled = false

ConfigControls.AntiAFKToggle = PlayerTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFKToggle",

    Callback = function(value)
        ConfigValues.AntiAFKToggle = value
        AntiAFKEnabled = value
    end
})

LocalPlayer.Idled:Connect(function()
    if AntiAFKEnabled then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

--==================================================
-- SETTINGS TAB: NAMED CONFIGS + AUTO-LOAD
--==================================================

local SettingsTab = Window:CreateTab("Settings")

local CONFIG_ROOT = "PlutosScriptHub"
local CONFIG_FOLDER = CONFIG_ROOT .. "/MM2_Configs"
local AUTOLOAD_PATH = CONFIG_ROOT .. "/MM2_autoload.json"

local SelectedConfigName = ""
local AutoLoadEnabled = false
local AutoLoadConfigName = ""
local ConfigNameInputValue = "My MM2 Config"
local ConfigDropdown
local AutoLoadToggle

local function FileApiAvailable()
    return typeof(writefile) == "function"
        and typeof(readfile) == "function"
        and typeof(listfiles) == "function"
        and typeof(makefolder) == "function"
end

local function EnsureConfigFolders()
    if not FileApiAvailable() then
        return false
    end

    pcall(function()
        if typeof(isfolder) ~= "function" or not isfolder(CONFIG_ROOT) then
            makefolder(CONFIG_ROOT)
        end
    end)

    pcall(function()
        if typeof(isfolder) ~= "function" or not isfolder(CONFIG_FOLDER) then
            makefolder(CONFIG_FOLDER)
        end
    end)

    return true
end

local function CleanConfigName(name)
    name = tostring(name or "")
    name = name:gsub("%.json$", "")
    name = name:gsub("[^%w%-%_ ]", "")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    name = name:gsub("%s+", "_")
    return name:sub(1, 40)
end

local function ConfigPath(name)
    return CONFIG_FOLDER .. "/" .. CleanConfigName(name) .. ".json"
end

local function ListSavedConfigs()
    local names = {}

    if not EnsureConfigFolders() then
        return names
    end

    local ok, files = pcall(listfiles, CONFIG_FOLDER)

    if not ok or type(files) ~= "table" then
        return names
    end

    for _, path in ipairs(files) do
        local filename = tostring(path):match("([^/\\]+)$")
        local name = filename and filename:match("(.+)%.json$")

        if name then
            table.insert(names, name)
        end
    end

    table.sort(names)
    return names
end

local function SaveAutoLoadSetting()
    if not EnsureConfigFolders() then
        return false
    end

    return pcall(function()
        writefile(AUTOLOAD_PATH, HttpService:JSONEncode({
            Enabled = AutoLoadEnabled,
            ConfigName = AutoLoadConfigName
        }))
    end)
end

local function RefreshConfigDropdown()
    local names = ListSavedConfigs()
    local options = #names > 0 and names or {"No saved configs"}

    if ConfigDropdown and type(ConfigDropdown.Refresh) == "function" then
        pcall(function()
            ConfigDropdown:Refresh(options, true)
        end)
    end

    if SelectedConfigName ~= "" and not table.find(names, SelectedConfigName) then
        SelectedConfigName = ""
    end
end

local function SaveCurrentConfig(name)
    name = CleanConfigName(name)

    if name == "" then
        Notify("Configs", "Enter a name before saving.")
        return false
    end

    if not EnsureConfigFolders() then
        Notify("Configs", "Your executor does not support the required file APIs.")
        return false
    end

    local ok, err = pcall(function()
        writefile(ConfigPath(name), HttpService:JSONEncode(ConfigValues))
    end)

    if not ok then
        Notify("Config Error", tostring(err))
        return false
    end

    SelectedConfigName = name
    RefreshConfigDropdown()
    Notify("Configs", "Saved config: " .. name)

    return true
end

local function LoadConfig(name, silent)
    name = CleanConfigName(name)

    if name == "" then
        if not silent then
            Notify("Configs", "Select a saved config first.")
        end

        return false
    end

    if not EnsureConfigFolders() then
        if not silent then
            Notify("Configs", "Your executor does not support the required file APIs.")
        end

        return false
    end

    local path = ConfigPath(name)
    local exists = false

    if typeof(isfile) == "function" then
        local ok, result = pcall(isfile, path)
        exists = ok and result
    else
        exists = pcall(readfile, path)
    end

    if not exists then
        if not silent then
            Notify("Configs", "Config not found: " .. name)
        end

        return false
    end

    local readOk, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)

    if not readOk or type(decoded) ~= "table" then
        if not silent then
            Notify("Config Error", "That config file is invalid.")
        end

        return false
    end

    for key, control in pairs(ConfigControls) do
        local value = decoded[key]

        if value ~= nil then
            local setOk = false

            if control and type(control.Set) == "function" then
                setOk = pcall(function()
                    control:Set(value)
                end)
            end

            if not setOk then
                ConfigValues[key] = value
            end
        end
    end

    SelectedConfigName = name

    if not silent then
        Notify("Configs", "Loaded config: " .. name)
    end

    return true
end

SettingsTab:CreateParagraph({
    Title = "Configuration Manager",
    Content = "Save and load named presets of your MM2 and Player settings. Configs are stored locally by your executor."
})

SettingsTab:CreateInput({
    Name = "Config Name",
    CurrentValue = "My MM2 Config",
    PlaceholderText = "Enter a config name",
    RemoveTextAfterFocusLost = false,
    Flag = "ConfigNameInput",

    Callback = function(value)
        ConfigNameInputValue = tostring(value or "")
    end
})

local InitialConfigNames = ListSavedConfigs()
local InitialConfigOptions = #InitialConfigNames > 0
    and InitialConfigNames
    or {"No saved configs"}

if #InitialConfigNames > 0 then
    SelectedConfigName = InitialConfigNames[1]
end

ConfigDropdown = SettingsTab:CreateDropdown({
    Name = "Saved Configs",
    Options = InitialConfigOptions,
    CurrentOption = {InitialConfigOptions[1]},
    MultipleOptions = false,
    Flag = "SavedConfigDropdown",

    Callback = function(option)
        if type(option) == "table" then
            SelectedConfigName = tostring(option[1] or "")
        else
            SelectedConfigName = tostring(option or "")
        end

        if SelectedConfigName == "No saved configs" then
            SelectedConfigName = ""
        end

        if AutoLoadEnabled and SelectedConfigName ~= "" then
            AutoLoadConfigName = SelectedConfigName
            SaveAutoLoadSetting()
        end
    end
})

SettingsTab:CreateButton({
    Name = "Save Config",

    Callback = function()
        SaveCurrentConfig(ConfigNameInputValue)
    end
})

SettingsTab:CreateButton({
    Name = "Load Selected Config",

    Callback = function()
        LoadConfig(SelectedConfigName, false)
    end
})

SettingsTab:CreateButton({
    Name = "Refresh Config List",

    Callback = function()
        RefreshConfigDropdown()
        Notify("Configs", "Saved config list refreshed.")
    end
})

AutoLoadToggle = SettingsTab:CreateToggle({
    Name = "Auto-Load Selected Config",
    CurrentValue = false,
    Flag = "AutoLoadConfigToggle",

    Callback = function(value)
        if value and SelectedConfigName == "" then
            AutoLoadEnabled = false
            Notify("Configs", "Select a saved config before enabling auto-load.")

            task.defer(function()
                if AutoLoadToggle and type(AutoLoadToggle.Set) == "function" then
                    pcall(function()
                        AutoLoadToggle:Set(false)
                    end)
                end
            end)

            return
        end

        AutoLoadEnabled = value
        AutoLoadConfigName = value and SelectedConfigName or ""

        if SaveAutoLoadSetting() then
            Notify(
                "Configs",
                value
                    and ("Auto-load enabled for: " .. AutoLoadConfigName)
                    or "Auto-load disabled."
            )
        else
            Notify("Configs", "Could not save auto-load setting; check executor file access.")
        end
    end
})

task.defer(function()
    task.wait(1)

    if not EnsureConfigFolders() then
        return
    end

    local ok, saved = pcall(function()
        if typeof(isfile) == "function" and not isfile(AUTOLOAD_PATH) then
            return nil
        end

        return HttpService:JSONDecode(readfile(AUTOLOAD_PATH))
    end)

    if ok
        and type(saved) == "table"
        and saved.Enabled == true
        and type(saved.ConfigName) == "string" then

        AutoLoadEnabled = true
        AutoLoadConfigName = saved.ConfigName
        SelectedConfigName = saved.ConfigName

        if AutoLoadToggle and type(AutoLoadToggle.Set) == "function" then
            pcall(function()
                AutoLoadToggle:Set(true)
            end)
        end

        LoadConfig(AutoLoadConfigName, true)
        Notify("Configs", "Auto-loaded: " .. AutoLoadConfigName)
    end
end)

--==================================================
-- INFO TAB
--==================================================

local InfoTab = Window:CreateTab("Info")

InfoTab:CreateParagraph({
    Title = "Pluto's Script Hub",
    Content = "Murder Mystery 2 role trackers, coin helpers, and universal player utilities."
})

InfoTab:CreateButton({
    Name = "Copy Discord Invite",

    Callback = function()
        local copied = false

        if typeof(setclipboard) == "function" then
            copied = pcall(setclipboard, DiscordInvite)
        elseif typeof(toclipboard) == "function" then
            copied = pcall(toclipboard, DiscordInvite)
        end

        if copied then
            Notify("Discord", "Invite link copied to your clipboard!")
        else
            Notify("Discord Invite", DiscordInvite, 8)
        end
    end
})

Notify("Murder Mystery 2", "Hub loaded!")

task.spawn(function()
    task.wait(0.75)

    if RoleNotifierEnabled then
        CheckRoles()
    end
end)
