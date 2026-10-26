--==================================================
-- PLUTO'S SCRIPT HUB
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

local LUMBER_EMPIRE_ID = 99686412871121
local MY_HAUNTED_HOUSE_ID = 17278083429
local MURDER_MYSTERY_2_ID = 142823291
local IsLumberEmpire = game.PlaceId == LUMBER_EMPIRE_ID

local Rayfield = loadstring(game:HttpGet(
    "https://sirius.menu/rayfield"
))()

local Window = Rayfield:CreateWindow({
    Name = "Pluto's Script Hub",
    LoadingTitle = "Pluto's Script Hub",
    LoadingSubtitle = "Game + Universal Features",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "PlutosScriptHub",
        FileName = "PlutoConfig"
    },
    KeySystem = false,
    Theme = "Amethyst"
})

local function Notify(title, message)
    Rayfield:Notify({
        Title = title,
        Content = message,
        Duration = 4
    })
end

--==================================================
-- CONFIGURATION STATE
--==================================================

local CONFIG_ROOT = "PlutosScriptHub"
local CONFIG_FOLDER = CONFIG_ROOT .. "/Configs"
local AUTOLOAD_PATH = CONFIG_ROOT .. "/autoload.json"

local ConfigValues = {
    AutoUpgradeToggle = false,
    TreeAutoUpgradeToggle = false,
    AutoRebirthToggle = false,

    AirportAutoHangarToggle = false,
    AirportAutoFlightToggle = false,
    AirportAutoUpgradeToggle = false,

    MM2RoleESPToggle = false,
    MM2RoleNotifierToggle = false,
    MM2CoinESPToggle = false,
    MM2AutoCoinsToggle = false,
    MM2AutoPickupToggle = false,

    WalkSpeedToggle = false,
    WalkSpeedSlider = 32,
    FlyToggle = false,
    FlySpeedSlider = 50,
    InfiniteJumpToggle = false,
    NoclipToggle = false,
    InstantPromptToggle = false,
    AntiAFKToggle = false,
    PlayerESPToggle = false,
    ESPOpacitySlider = 50,
    HubOpacitySlider = 100
}

local ConfigControls = {}
local SelectedConfigName = ""
local AutoLoadEnabled = false
local AutoLoadConfigName = ""
local ConfigNameInputValue = "My Config"

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

        if name and name ~= "autoload" then
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

    local ok = pcall(function()
        writefile(AUTOLOAD_PATH, HttpService:JSONEncode({
            Enabled = AutoLoadEnabled,
            ConfigName = AutoLoadConfigName
        }))
    end)

    return ok
end

--==================================================
-- HUB OPACITY HELPERS
--==================================================

local HubOpacity = 100
local OriginalBackgrounds = {}
local LastOpacityPanel = nil

local function FindHubPanel()
    local containers = {}

    pcall(function()
        table.insert(containers, CoreGui)
    end)

    pcall(function()
        table.insert(containers, LocalPlayer:WaitForChild("PlayerGui"))
    end)

    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    local bestPanel, bestArea = nil, 0

    for _, container in ipairs(containers) do
        pcall(function()
            for _, object in ipairs(container:GetDescendants()) do
                if object:IsA("TextLabel")
                    and string.find(string.lower(object.Text), "pluto's script hub", 1, true) then

                    local ancestor = object.Parent

                    while ancestor and ancestor ~= container do
                        if ancestor:IsA("Frame") or ancestor:IsA("ScrollingFrame") then
                            local size = ancestor.AbsoluteSize
                            local area = size.X * size.Y

                            local plausible = size.X >= 350
                                and size.Y >= 250
                                and size.X < viewport.X * 0.90
                                and size.Y < viewport.Y * 0.90

                            if plausible and area > bestArea then
                                bestPanel, bestArea = ancestor, area
                            end
                        end

                        ancestor = ancestor.Parent
                    end
                end
            end
        end)
    end

    return bestPanel
end

local function ApplyHubOpacity()
    local panel = FindHubPanel()

    if not panel then
        return false
    end

    LastOpacityPanel = panel

    local opacity = math.clamp(HubOpacity, 0, 100) / 100
    local transparency = 1 - opacity
    local panelSize = panel.AbsoluteSize
    local panelArea = panelSize.X * panelSize.Y

    local function SetBackground(guiObject)
        if OriginalBackgrounds[guiObject] == nil then
            OriginalBackgrounds[guiObject] = guiObject.BackgroundTransparency
        end

        local original = OriginalBackgrounds[guiObject]

        guiObject.BackgroundTransparency =
            original + ((1 - original) * transparency)
    end

    SetBackground(panel)

    for _, child in ipairs(panel:GetDescendants()) do
        if child:IsA("Frame") or child:IsA("ScrollingFrame") then
            local size = child.AbsoluteSize
            local area = size.X * size.Y

            if panelArea > 0
                and area >= panelArea * 0.20
                and size.X >= panelSize.X * 0.45
                and size.Y >= panelSize.Y * 0.30 then

                SetBackground(child)
            end
        end
    end

    return true
end

--==================================================
-- GAME-SPECIFIC TABS
--==================================================

if IsLumberEmpire then

    --==================================================
    -- LUMBER EMPIRE TAB (FIRST)
    --==================================================

    local LumberTab = Window:CreateTab(
        "🪓 Lumber Empire",
        4483362458
    )

    LumberTab:CreateParagraph({
        Title = "Lumber Empire",
        Content = "Game-specific tools and automation."
    })

    LumberTab:CreateButton({
        Name = "Hire Worker",

        Callback = function()
            local success, err = pcall(function()
                ReplicatedStorage
                    :WaitForChild("Remotes")
                    :WaitForChild("HireWorker")
                    :FireServer()
            end)

            if success then
                Notify("Lumber Empire", "Request sent.")
            else
                Notify("Error", tostring(err))
            end
        end
    })

    local LumberLoopTokens = {}

    local function StartLumberLoop(key, action)
        LumberLoopTokens[key] = (LumberLoopTokens[key] or 0) + 1
        local token = LumberLoopTokens[key]

        task.spawn(function()
            while ConfigValues[key]
                and LumberLoopTokens[key] == token do

                local ok, err = pcall(action)

                if not ok then
                    warn("[Pluto's Script Hub] " .. key .. ": " .. tostring(err))
                end

                task.wait(1)
            end
        end)
    end

    local function BuyLumberUpgrade(upgradeName)
        ReplicatedStorage
            :WaitForChild("Remotes")
            :WaitForChild("BuyUpgrade")
            :FireServer(upgradeName)
    end

    -- WORKER & TRUCK AUTO UPGRADE

    LumberTab:CreateSection("Worker & Truck Auto Upgrade")

    ConfigControls.AutoUpgradeToggle = LumberTab:CreateToggle({
        Name = "Worker & Truck Auto Upgrade",
        CurrentValue = false,
        Flag = "AutoUpgradeToggle",

        Callback = function(value)
            ConfigValues.AutoUpgradeToggle = value

            if value then
                StartLumberLoop("AutoUpgradeToggle", function()
                    ReplicatedStorage
                        :WaitForChild("Remotes")
                        :WaitForChild("HireWorker")
                        :FireServer()

                    for _, upgradeName in ipairs({
                        "TruckLevel",
                        "TruckSpeed",
                        "WorkerPower",
                        "WorkerCarry",
                        "WorkerSpeed"
                    }) do
                        if not ConfigValues.AutoUpgradeToggle then
                            break
                        end

                        BuyLumberUpgrade(upgradeName)
                        task.wait(1)
                    end
                end)
            else
                LumberLoopTokens.AutoUpgradeToggle =
                    (LumberLoopTokens.AutoUpgradeToggle or 0) + 1
            end
        end
    })

    -- TREE & EVENT TREE AUTO UPGRADE

    LumberTab:CreateSection("Tree & Event Tree Auto Upgrade")

    ConfigControls.TreeAutoUpgradeToggle = LumberTab:CreateToggle({
        Name = "Tree & Event Tree Auto Upgrade",
        CurrentValue = false,
        Flag = "TreeAutoUpgradeToggle",

        Callback = function(value)
            ConfigValues.TreeAutoUpgradeToggle = value

            if value then
                StartLumberLoop("TreeAutoUpgradeToggle", function()
                    for _, upgradeName in ipairs({
                        "TreeLuck",
                        "TreeRegrow",
                        "HauntTime",
                        "HauntTrees"
                    }) do
                        if not ConfigValues.TreeAutoUpgradeToggle then
                            break
                        end

                        BuyLumberUpgrade(upgradeName)
                        task.wait(1)
                    end
                end)
            else
                LumberLoopTokens.TreeAutoUpgradeToggle =
                    (LumberLoopTokens.TreeAutoUpgradeToggle or 0) + 1
            end
        end
    })

    -- AUTO REBIRTH

    LumberTab:CreateSection("Rebirth")

    ConfigControls.AutoRebirthToggle = LumberTab:CreateToggle({
        Name = "Auto Rebirth",
        CurrentValue = false,
        Flag = "AutoRebirthToggle",

        Callback = function(value)
            ConfigValues.AutoRebirthToggle = value

            if value then
                StartLumberLoop("AutoRebirthToggle", function()
                    ReplicatedStorage
                        :WaitForChild("Remotes")
                        :WaitForChild("Rebirth")
                        :FireServer()
                end)
            else
                LumberLoopTokens.AutoRebirthToggle =
                    (LumberLoopTokens.AutoRebirthToggle or 0) + 1
            end
        end
    })

    --==================================================
    -- AIRPORT TAB (SECOND)
    --==================================================

    local AirportTab = Window:CreateTab(
        "✈️ Airport",
        4483362458
    )

    AirportTab:CreateParagraph({
        Title = "Airport Automation",
        Content = "Automate hangars, flights, and airport upgrades."
    })

    local AirportLoopTokens = {}

    local function StartAirportLoop(key, action)
        AirportLoopTokens[key] = (AirportLoopTokens[key] or 0) + 1
        local token = AirportLoopTokens[key]

        task.spawn(function()
            while ConfigValues[key]
                and AirportLoopTokens[key] == token do

                local ok, err = pcall(action)

                if not ok then
                    warn("[Pluto's Script Hub] " .. key .. ": " .. tostring(err))
                end

                task.wait(1)
            end
        end)
    end

    local function GetAirportRemote(remoteName)
        return ReplicatedStorage
            :WaitForChild("Remotes")
            :WaitForChild(remoteName)
    end

    -- AUTO HANGAR

    ConfigControls.AirportAutoHangarToggle = AirportTab:CreateToggle({
        Name = "Auto Hangar",
        CurrentValue = false,
        Flag = "AirportAutoHangarToggle",

        Callback = function(value)
            ConfigValues.AirportAutoHangarToggle = value

            if value then
                StartAirportLoop("AirportAutoHangarToggle", function()
                    local airportBuy = GetAirportRemote("AirportBuy")

                    for _, hangarId in ipairs({1, 2, 3}) do
                        if not ConfigValues.AirportAutoHangarToggle then
                            break
                        end

                        airportBuy:FireServer(hangarId)
                        task.wait(0.35)
                    end
                end)
            else
                AirportLoopTokens.AirportAutoHangarToggle =
                    (AirportLoopTokens.AirportAutoHangarToggle or 0) + 1
            end
        end
    })

    -- AUTO FLIGHT

    ConfigControls.AirportAutoFlightToggle = AirportTab:CreateToggle({
        Name = "Auto Flight",
        CurrentValue = false,
        Flag = "AirportAutoFlightToggle",

        Callback = function(value)
            ConfigValues.AirportAutoFlightToggle = value

            if value then
                StartAirportLoop("AirportAutoFlightToggle", function()
                    GetAirportRemote("SendPlane"):FireServer("MapleRidge")
                end)
            else
                AirportLoopTokens.AirportAutoFlightToggle =
                    (AirportLoopTokens.AirportAutoFlightToggle or 0) + 1
            end
        end
    })

    -- AUTO AIRPORT UPGRADE

    ConfigControls.AirportAutoUpgradeToggle = AirportTab:CreateToggle({
        Name = "Auto Airport Upgrade",
        CurrentValue = false,
        Flag = "AirportAutoUpgradeToggle",

        Callback = function(value)
            ConfigValues.AirportAutoUpgradeToggle = value

            if value then
                StartAirportLoop("AirportAutoUpgradeToggle", function()
                    local buyUpgrade = GetAirportRemote("BuyUpgrade")

                    for _, upgradeName in ipairs({
                        "FlightSpeed",
                        "CargoHold",
                        "LogDiscount"
                    }) do
                        if not ConfigValues.AirportAutoUpgradeToggle then
                            break
                        end

                        buyUpgrade:FireServer(upgradeName)
                        task.wait(0.35)
                    end
                end)
            else
                AirportLoopTokens.AirportAutoUpgradeToggle =
                    (AirportLoopTokens.AirportAutoUpgradeToggle or 0) + 1
            end
        end
    })

elseif game.PlaceId == MY_HAUNTED_HOUSE_ID then

    local HauntedTab = Window:CreateTab(
        "My Haunted House",
        4483362458
    )

    HauntedTab:CreateParagraph({
        Title = "My Haunted House",
        Content = "Game-specific tools and features."
    })

    HauntedTab:CreateButton({
        Name = "Open Haunted House Script",

        Callback = function()
            local success, err = pcall(function()
                loadstring(game:HttpGet(
                    "https://raw.githubusercontent.com/Johndoe305/hauntedhousescript/refs/heads/main/script.lua"
                ))()
            end)

            if success then
                Notify("Haunted House", "Script launched.")
            else
                Notify("Script Error", tostring(err))
            end
        end
    })

elseif game.PlaceId == MURDER_MYSTERY_2_ID then

    --==================================================
    -- MURDER MYSTERY 2 TAB
    --==================================================

    local MM2Tab = Window:CreateTab(
        "🔪 Murder Mystery 2",
        4483362458
    )

    MM2Tab:CreateParagraph({
        Title = "Murder Mystery 2",
        Content = "Role trackers, coin helpers, and weapon pickup automation."
    })

    local MM2LoopTokens = {}

    local function StartMM2Loop(key, interval, action)
        MM2LoopTokens[key] = (MM2LoopTokens[key] or 0) + 1
        local token = MM2LoopTokens[key]

        task.spawn(function()
            while ConfigValues[key] and MM2LoopTokens[key] == token do
                local ok, err = pcall(action)

                if not ok then
                    warn("[Pluto's Script Hub] " .. key .. ": " .. tostring(err))
                end

                task.wait(interval)
            end
        end)
    end

    local function StopMM2Loop(key)
        MM2LoopTokens[key] = (MM2LoopTokens[key] or 0) + 1
    end

    local MURDERER_TOOLS = {"Knife"}
    local SHERIFF_TOOLS = {"Gun", "Revolver"}

    local ROLE_COLORS = {
        Murderer = Color3.fromRGB(255, 60, 60),
        Sheriff = Color3.fromRGB(60, 150, 255)
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
                local role = GetRole(player)

                if role then
                    local data = RoleESPObjects[player]

                    if not data
                        or data.Role ~= role
                        or not data.Highlight
                        or data.Highlight.Adornee ~= player.Character then

                        CreateRoleESP(player, role)
                    end
                else
                    RemoveRoleESP(player)
                end
            end
        end

        for player in pairs(RoleESPObjects) do
            if not player.Parent or not player.Character then
                RemoveRoleESP(player)
            end
        end
    end

    ConfigControls.MM2RoleESPToggle = MM2Tab:CreateToggle({
        Name = "Role ESP",
        CurrentValue = false,
        Flag = "MM2RoleESPToggle",

        Callback = function(value)
            ConfigValues.MM2RoleESPToggle = value
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

    ConfigControls.MM2RoleNotifierToggle = MM2Tab:CreateToggle({
        Name = "Role Notifier",
        CurrentValue = false,
        Flag = "MM2RoleNotifierToggle",

        Callback = function(value)
            ConfigValues.MM2RoleNotifierToggle = value

            if value then
                StartMM2Loop("MM2RoleNotifierToggle", 1, CheckRoles)
            else
                StopMM2Loop("MM2RoleNotifierToggle")
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
            if next(CoinESPObjects) then
                ClearCoinESP()
            end

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

    ConfigControls.MM2CoinESPToggle = MM2Tab:CreateToggle({
        Name = "Coin ESP",
        CurrentValue = false,
        Flag = "MM2CoinESPToggle",

        Callback = function(value)
            ConfigValues.MM2CoinESPToggle = value
            CoinESPEnabled = value

            if value then
                StartMM2Loop("MM2CoinESPToggle", 1, UpdateCoinESP)
            else
                StopMM2Loop("MM2CoinESPToggle")
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
            if not ConfigValues.MM2AutoCoinsToggle then
                return
            end

            pcall(firetouchinterest, root, coin, 0)
            pcall(firetouchinterest, root, coin, 1)
            task.wait(0.05)
        end
    end

    ConfigControls.MM2AutoCoinsToggle = MM2Tab:CreateToggle({
        Name = "Auto Collect Coins",
        CurrentValue = false,
        Flag = "MM2AutoCoinsToggle",

        Callback = function(value)
            ConfigValues.MM2AutoCoinsToggle = value

            if value then
                StartMM2Loop("MM2AutoCoinsToggle", 1, CollectCoins)
            else
                StopMM2Loop("MM2AutoCoinsToggle")
            end
        end
    })

    -- WEAPONS

    MM2Tab:CreateSection("Weapons")

    local function PickupWeapons()
        for _, weapon in ipairs(GetDroppedWeapons()) do
            if not ConfigValues.MM2AutoPickupToggle then
                return
            end

            TouchObject(weapon)
            task.wait(0.15)
        end
    end

    ConfigControls.MM2AutoPickupToggle = MM2Tab:CreateToggle({
        Name = "Auto Pickup Dropped Weapons",
        CurrentValue = false,
        Flag = "MM2AutoPickupToggle",

        Callback = function(value)
            ConfigValues.MM2AutoPickupToggle = value

            if value then
                StartMM2Loop("MM2AutoPickupToggle", 1, PickupWeapons)
            else
                StopMM2Loop("MM2AutoPickupToggle")
            end
        end
    })

    MM2Tab:CreateParagraph({
        Title = "Notes",
        Content = "Role detection reads the Knife and Gun tools from player inventories, so it updates as soon as a round starts."
    })

end

--==================================================
-- UNIVERSAL TAB
--==================================================

local UniversalTab = Window:CreateTab(
    "Universal",
    4483362458
)

UniversalTab:CreateParagraph({
    Title = "Universal Features",
    Content = "Player utilities available from the Universal tab."
})

UniversalTab:CreateSection("External Script")

UniversalTab:CreateParagraph({
    Title = "Infinite Yield",
    Content = "Load Infinite Yield separately from the player utilities below."
})

UniversalTab:CreateButton({
    Name = "Load Infinite Yield",

    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"
            ))()
        end)

        if not success then
            Notify("Error", tostring(err))
        end
    end
})

UniversalTab:CreateSection("Player Configurations")

--==================================================
-- WALK SPEED
--==================================================

local WalkSpeedEnabled = false
local WalkSpeedValue = 32

local function ApplyWalkSpeed()
    local character = LocalPlayer.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")

    if humanoid and WalkSpeedEnabled then
        humanoid.WalkSpeed = WalkSpeedValue
    end
end

ConfigControls.WalkSpeedToggle = UniversalTab:CreateToggle({
    Name = "Walk Speed",
    CurrentValue = false,
    Flag = "WalkSpeedToggle",

    Callback = function(value)
        ConfigValues.WalkSpeedToggle = value
        WalkSpeedEnabled = value
        ApplyWalkSpeed()
    end
})

ConfigControls.WalkSpeedSlider = UniversalTab:CreateSlider({
    Name = "Walk Speed Amount",
    Range = {16, 200},
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

--==================================================
-- FLY
--==================================================

local FlyEnabled = false
local FlySpeed = 50
local FlyConnection
local FlyVelocity
local FlyGyro

local function StopFly()
    FlyEnabled = false

    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

    if FlyVelocity then
        FlyVelocity:Destroy()
        FlyVelocity = nil
    end

    if FlyGyro then
        FlyGyro:Destroy()
        FlyGyro = nil
    end

    local character = LocalPlayer.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.PlatformStand = false
    end
end

local function StartFly()
    StopFly()

    local character = LocalPlayer.Character
    local root = character
        and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then
        Notify("Fly", "Character not found.")
        return
    end

    FlyEnabled = true
    humanoid.PlatformStand = true

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    FlyVelocity.Velocity = Vector3.zero
    FlyVelocity.Parent = root

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    FlyGyro.P = 10000
    FlyGyro.CFrame = root.CFrame
    FlyGyro.Parent = root

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not FlyEnabled or not root.Parent then
            StopFly()
            return
        end

        local camera = workspace.CurrentCamera
        local direction = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction += camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction -= camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction += camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction -= camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction += Vector3.new(0, 1, 0)
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            direction -= Vector3.new(0, 1, 0)
        end

        if direction.Magnitude > 0 then
            direction = direction.Unit * FlySpeed
        end

        FlyVelocity.Velocity = direction
        FlyGyro.CFrame = camera.CFrame
    end)
end

-- Only display Fly controls outside Lumber Empire.

if not IsLumberEmpire then
    ConfigControls.FlyToggle = UniversalTab:CreateToggle({
        Name = "Fly",
        CurrentValue = false,
        Flag = "FlyToggle",

        Callback = function(value)
            ConfigValues.FlyToggle = value

            if value then
                StartFly()
            else
                StopFly()
            end
        end
    })

    ConfigControls.FlySpeedSlider = UniversalTab:CreateSlider({
        Name = "Fly Speed",
        Range = {10, 200},
        Increment = 5,
        Suffix = "Speed",
        CurrentValue = 50,
        Flag = "FlySpeedSlider",

        Callback = function(value)
            ConfigValues.FlySpeedSlider = value
            FlySpeed = value
        end
    })
end

--==================================================
-- INFINITE JUMP
--==================================================

local InfiniteJumpEnabled = false

UserInputService.JumpRequest:Connect(function()
    if not InfiniteJumpEnabled then
        return
    end

    local character = LocalPlayer.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Only display Infinite Jump outside Lumber Empire.

if not IsLumberEmpire then
    ConfigControls.InfiniteJumpToggle = UniversalTab:CreateToggle({
        Name = "Infinite Jump",
        CurrentValue = false,
        Flag = "InfiniteJumpToggle",

        Callback = function(value)
            ConfigValues.InfiniteJumpToggle = value
            InfiniteJumpEnabled = value
        end
    })
end

--==================================================
-- NOCLIP
--==================================================

local NoclipEnabled = false
local NoclipConnection

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

ConfigControls.NoclipToggle = UniversalTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",

    Callback = function(value)
        ConfigValues.NoclipToggle = value
        SetNoclip(value)
    end
})

--==================================================
-- INSTANT PROXIMITY PROMPT
--==================================================

local InstantPromptEnabled = false

ConfigControls.InstantPromptToggle = UniversalTab:CreateToggle({
    Name = "Instant Proximity Prompt",
    CurrentValue = false,
    Flag = "InstantPromptToggle",

    Callback = function(value)
        ConfigValues.InstantPromptToggle = value
        InstantPromptEnabled = value

        if value then
            Notify("Prompts", "Instant prompt enabled.")
        end
    end
})

local function UpdatePrompt(prompt)
    if InstantPromptEnabled and prompt:IsA("ProximityPrompt") then
        pcall(function()
            prompt.HoldDuration = 0
        end)
    end
end

for _, object in ipairs(workspace:GetDescendants()) do
    UpdatePrompt(object)
end

workspace.DescendantAdded:Connect(function(object)
    UpdatePrompt(object)
end)

RunService.Heartbeat:Connect(function()
    if not InstantPromptEnabled then
        return
    end

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("ProximityPrompt") then
            pcall(function()
                object.HoldDuration = 0
            end)
        end
    end
end)

--==================================================
-- ANTI-AFK
--==================================================

local AntiAFKEnabled = false

ConfigControls.AntiAFKToggle = UniversalTab:CreateToggle({
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
-- PLAYER ESP
--==================================================

local ESPEnabled = false
local ESPOpacity = 50
local ESPObjects = {}

local function RemoveESP(player)
    local data = ESPObjects[player]

    if not data then
        return
    end

    if data.Highlight then
        data.Highlight:Destroy()
    end

    if data.Billboard then
        data.Billboard:Destroy()
    end

    ESPObjects[player] = nil
end

local function CreateESP(player)
    if player == LocalPlayer then
        return
    end

    RemoveESP(player)

    local character = player.Character

    if not character then
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")

    if not root then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "PlutoPlayerESP"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Color3.fromRGB(170, 85, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 1 - (ESPOpacity / 100)
    highlight.OutlineTransparency = 1 - (ESPOpacity / 100)
    highlight.Enabled = ESPEnabled
    highlight.Parent = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlutoPlayerName"
    billboard.Adornee = root
    billboard.Size = UDim2.new(0, 200, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = ESPEnabled
    billboard.Parent = character

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = player.DisplayName .. " (@" .. player.Name .. ")"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.25
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    ESPObjects[player] = {
        Highlight = highlight,
        Billboard = billboard
    }
end

local function UpdateESP()
    for _, data in pairs(ESPObjects) do
        if data.Highlight then
            data.Highlight.FillTransparency = 1 - (ESPOpacity / 100)
            data.Highlight.OutlineTransparency = 1 - (ESPOpacity / 100)
            data.Highlight.Enabled = ESPEnabled
        end

        if data.Billboard then
            data.Billboard.Enabled = ESPEnabled
        end
    end
end

local function RefreshESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
end

-- Only display Player ESP controls outside Lumber Empire.

if not IsLumberEmpire then
    ConfigControls.PlayerESPToggle = UniversalTab:CreateToggle({
        Name = "Player ESP",
        CurrentValue = false,
        Flag = "PlayerESPToggle",

        Callback = function(value)
            ConfigValues.PlayerESPToggle = value
            ESPEnabled = value

            if value then
                RefreshESP()
            end

            UpdateESP()
        end
    })

    ConfigControls.ESPOpacitySlider = UniversalTab:CreateSlider({
        Name = "ESP Opacity",
        Range = {0, 100},
        Increment = 5,
        Suffix = "%",
        CurrentValue = 50,
        Flag = "ESPOpacitySlider",

        Callback = function(value)
            ConfigValues.ESPOpacitySlider = value
            ESPOpacity = value
            UpdateESP()
        end
    })
end

local function ConnectPlayer(player)
    if player == LocalPlayer then
        return
    end

    player.CharacterAdded:Connect(function()
        task.wait(1)

        if ESPEnabled then
            CreateESP(player)
        end
    end)

    player.CharacterRemoving:Connect(function()
        RemoveESP(player)
    end)

    if ESPEnabled and player.Character then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(ConnectPlayer)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    ConnectPlayer(player)
end

--==================================================
-- SETTINGS TAB: NAMED CONFIGS + AUTO-LOAD
--==================================================

local SettingsTab = Window:CreateTab("Settings", 4483362458)
local ConfigDropdown
local AutoLoadToggle

SettingsTab:CreateParagraph({
    Title = "Configuration Manager",
    Content = "Save named presets of your hub toggles and slider values, then load them later or enable auto-load. Configs are stored locally by your executor."
})

SettingsTab:CreateInput({
    Name = "Config Name",
    CurrentValue = "My Config",
    PlaceholderText = "Enter a config name",
    RemoveTextAfterFocusLost = false,
    Flag = "ConfigNameInput",

    Callback = function(value)
        ConfigNameInputValue = tostring(value or "")
    end
})

local function RefreshConfigDropdown()
    local names = ListSavedConfigs()
    local options = #names > 0 and names or {"No saved configs"}

    if ConfigDropdown and type(ConfigDropdown.Refresh) == "function" then
        pcall(function()
            ConfigDropdown:Refresh(options, true)
        end)
    end

    if SelectedConfigName ~= "" then
        local found = false

        for _, name in ipairs(names) do
            if name == SelectedConfigName then
                found = true
                break
            end
        end

        if not found then
            SelectedConfigName = ""
        end
    end

    return names
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
        local ok = pcall(readfile, path)
        exists = ok
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

    if decoded.HubOpacitySlider ~= nil then
        HubOpacity = math.clamp(
            tonumber(decoded.HubOpacitySlider) or 100,
            0,
            100
        )

        ConfigValues.HubOpacitySlider = HubOpacity

        task.spawn(function()
            for _ = 1, 20 do
                if ApplyHubOpacity() then
                    break
                end

                task.wait(0.25)
            end
        end)
    end

    SelectedConfigName = name

    if not silent then
        Notify("Configs", "Loaded config: " .. name)
    end

    return true
end

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
        AutoLoadEnabled = value

        if value then
            if SelectedConfigName == "" then
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

            AutoLoadConfigName = SelectedConfigName
        else
            AutoLoadConfigName = ""
        end

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

        AutoLoadConfigName = saved.ConfigName
        SelectedConfigName = saved.ConfigName
        AutoLoadEnabled = true

        if AutoLoadToggle and type(AutoLoadToggle.Set) == "function" then
            pcall(function()
                AutoLoadToggle:Set(true)
            end)
        else
            AutoLoadEnabled = true
        end

        LoadConfig(AutoLoadConfigName, true)
        Notify("Configs", "Auto-loaded: " .. AutoLoadConfigName)
    end
end)

--==================================================
-- INFO TAB
--==================================================

local InfoTab = Window:CreateTab("Info", 4483362458)

InfoTab:CreateParagraph({
    Title = "Pluto's Script Hub",
    Content = "Adjust the hub panel background transparency or copy the Discord invite."
})

ConfigControls.HubOpacitySlider = InfoTab:CreateSlider({
    Name = "Hub Opacity",
    Range = {0, 100},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 100,
    Flag = "HubOpacitySlider",

    Callback = function(value)
        ConfigValues.HubOpacitySlider = value
        HubOpacity = value

        local applied = ApplyHubOpacity()

        if not applied then
            task.spawn(function()
                for _ = 1, 8 do
                    task.wait(0.25)

                    if ApplyHubOpacity() then
                        return
                    end
                end

                Notify(
                    "Hub Opacity",
                    "This Rayfield layout could not be detected, so opacity may not be supported here."
                )
            end)
        end
    end
})

InfoTab:CreateButton({
    Name = "Copy Discord Invite",

    Callback = function()
        local invite = "https://discord.gg/sr9Q3rn9Bf"
        local copied = false

        if typeof(setclipboard) == "function" then
            copied = pcall(setclipboard, invite)
        elseif typeof(toclipboard) == "function" then
            copied = pcall(toclipboard, invite)
        end

        if copied then
            Notify("Discord", "Invite link copied to your clipboard!")
        else
            Notify("Discord Invite", invite .. " (clipboard access unavailable)")
        end
    end
})

task.spawn(function()
    for _ = 1, 10 do
        if ApplyHubOpacity() then
            break
        end

        task.wait(0.5)
    end
end)

task.spawn(function()
    while task.wait(0.75) do
        if HubOpacity < 100 then
            ApplyHubOpacity()
        end
    end
end)

Notify(
    "Pluto's Script Hub",
    "Game-specific and Universal tabs loaded!"
)
