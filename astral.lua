local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Window = Library:CreateWindow({
    Title = "Astral | Legit",
    Center = true,
    AutoShow = true
})

local Tabs = {
    Legit = Window:AddTab("Legit"),
    Ragebot = Window:AddTab("Ragebot"),
    Settings = Window:AddTab("Settings")
}

local MainGroup = Tabs.Legit:AddLeftGroupbox("Main")
local ESPGroup = Tabs.Legit:AddRightGroupbox("ESP")
local RageGroup = Tabs.Ragebot:AddLeftGroupbox("Ragebot")
local SettingsGroup = Tabs.Settings:AddLeftGroupbox("UI Settings")

getgenv().Settings = {
    Triggerbot = false,
    TriggerDelay = 0.05,
    TeamCheck = true,

    Hitbox = false,
    HitboxSize = 8,
    HitboxPart = "Head",

    Ragebot = false,
    HitSound = false,
    SelectedHitSound = "Bell",

    FOV = 360,
    MatchDelay = 5,

    ESP = false,
    ESPTeamCheck = true
}

MainGroup:AddToggle("Triggerbot", {
    Text = "Triggerbot",
    Default = false,

    Callback = function(Value)
        Settings.Triggerbot = Value
    end
})

MainGroup:AddSlider("TriggerDelay", {
    Text = "Trigger Delay",
    Default = 0.05,
    Min = 0,
    Max = 1,
    Rounding = 2,

    Callback = function(Value)
        Settings.TriggerDelay = Value
    end
})

MainGroup:AddToggle("TeamCheck", {
    Text = "Team Check",
    Default = true,

    Callback = function(Value)
        Settings.TeamCheck = Value
    end
})

MainGroup:AddDivider()

MainGroup:AddToggle("Hitbox", {
    Text = "Hitbox Expander",
    Default = false,

    Callback = function(Value)
        Settings.Hitbox = Value
    end
})

MainGroup:AddSlider("HitboxSize", {
    Text = "Hitbox Size",
    Default = 8,
    Min = 3,
    Max = 20,
    Rounding = 1,

    Callback = function(Value)
        Settings.HitboxSize = Value
    end
})

MainGroup:AddDropdown("HitboxPart", {
    Values = {"Head", "HumanoidRootPart"},
    Default = 1,
    Multi = false,

    Text = "Hitbox Part",

    Callback = function(Value)
        Settings.HitboxPart = Value
    end
})

ESPGroup:AddToggle("ESP", {
    Text = "Streamproof ESP",
    Default = false,

    Callback = function(Value)
        Settings.ESP = Value
    end
})

ESPGroup:AddToggle("ESPTeamCheck", {
    Text = "ESP Team Check",
    Default = true,

    Callback = function(Value)
        Settings.ESPTeamCheck = Value
    end
})

RageGroup:AddToggle("Ragebot", {
    Text = "Ragebot",
    Default = false,

    Callback = function(Value)
        Settings.Ragebot = Value
    end
})

RageGroup:AddToggle("HitSound", {
    Text = "Hit Sounds",
    Default = false,

    Callback = function(Value)
        Settings.HitSound = Value
    end
})

RageGroup:AddDropdown("SelectedHitSound", {
    Values = {
        "Bell",
        "Bubble",
        "Pop",
        "Minecraft",
        "Rust",
        "Skeet"
    },

    Default = 1,
    Multi = false,

    Text = "Hit Sound",

    Callback = function(Value)
        Settings.SelectedHitSound = Value
    end
})

SettingsGroup:AddButton("Unload Script", function()
    Library:Unload()

    if getgenv().Connection then
        getgenv().Connection:Disconnect()
    end

    for _, Drawing in pairs(getgenv().ESPDrawings or {}) do
        Drawing:Remove()
    end
end)

getgenv().ESPDrawings = {}

local function CreateESP(Player)
    local Box = Drawing.new("Square")

    Box.Visible = false
    Box.Color = Color3.fromRGB(255,255,255)
    Box.Thickness = 1
    Box.Filled = false

    ESPDrawings[Player] = Box
end

local function RemoveESP(Player)
    if ESPDrawings[Player] then
        ESPDrawings[Player]:Remove()
        ESPDrawings[Player] = nil
    end
end

for _, Player in ipairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        CreateESP(Player)
    end
end

Players.PlayerAdded:Connect(function(Player)
    if Player ~= LocalPlayer then
        CreateESP(Player)
    end
end)

Players.PlayerRemoving:Connect(RemoveESP)

local HitSounds = {
    Bell = "rbxassetid://6534947240",
    Bubble = "rbxassetid://198598793",
    Pop = "rbxassetid://8745692251",
    Minecraft = "rbxassetid://4018616850",
    Rust = "rbxassetid://5043539486",
    Skeet = "rbxassetid://4753603610"
}

local function PlayHitSound()
    if not Settings.HitSound then
        return
    end

    local Sound = Instance.new("Sound")

    Sound.SoundId = HitSounds[Settings.SelectedHitSound]
    Sound.Volume = 2
    Sound.Parent = game:GetService("SoundService")

    Sound:Play()

    Sound.Ended:Connect(function()
        Sound:Destroy()
    end)
end

local MatchStarted = false

task.spawn(function()
    task.wait(Settings.MatchDelay)
    MatchStarted = true
end)

getgenv().Connection = RunService.RenderStepped:Connect(function()
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then

            local SameTeam = false

            pcall(function()
                SameTeam = Player.Team == LocalPlayer.Team
            end)

            if Settings.TeamCheck and SameTeam then
                continue
            end

            local Part = Player.Character:FindFirstChild(Settings.HitboxPart)

            if Part then
                if Settings.Hitbox then
                    if Settings.HitboxPart == "Head" then
                        Part.Size = Vector3.new(
                            Settings.HitboxSize,
                            Settings.HitboxSize,
                            Settings.HitboxSize
                        )
                    else
                        Part.Size = Vector3.new(
                            Settings.HitboxSize,
                            Settings.HitboxSize,
                            2
                        )
                    end

                    Part.Transparency = 0.5
                    Part.CanCollide = false
                    Part.Massless = true
                end
                

if Settings.Ragebot and MatchStarted then

    local Closest = nil
    local ClosestDistance = math.huge

    for _, Player in ipairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer and Player.Character then

        local Humanoid =
            Player.Character:FindFirstChildOfClass("Humanoid")

        local Root =
            Player.Character:FindFirstChild("HumanoidRootPart")

        -- alive check
        if Humanoid
        and Humanoid.Health > 0
        and Root then

            local SameTeam = false

            pcall(function()
                SameTeam = Player.Team == LocalPlayer.Team
            end)

            if Settings.TeamCheck and SameTeam then
                continue
            end

            local Position, Visible =
                Camera:WorldToViewportPoint(Root.Position)

            -- FOV check
            if Visible then

                local Distance = (
                    Vector2.new(Position.X, Position.Y) -
                    Vector2.new(Mouse.X, Mouse.Y)
                ).Magnitude

                -- only target inside FOV
                if Distance < ClosestDistance
                and Distance <= 360 then
                    ClosestDistance = Distance
                    Closest = Player
                end
            end
        end
    end
end

    if Closest and Closest.Character then

        local target =
            Closest.Character:FindFirstChild("HumanoidRootPart")
            or Closest.Character:FindFirstChild("Head")

        if target then

            local velocity = target.AssemblyLinearVelocity

            local distance = (
                LocalPlayer.Character.HumanoidRootPart.Position -
                target.Position
            ).Magnitude

            local prediction =
                math.clamp(distance / 350, 0.11, 0.22)

            local predicted =
                target.Position +
                (velocity * prediction)

            predicted = predicted + Vector3.new(0, 0.15, 0)

            local args = {
                {
                    hitPos = predicted,
                    to = predicted,
                    hitInstance = target,

                    id = 1,
                    mode = "single",

                    hitNormal = (
                        predicted -
                        LocalPlayer.Character.HumanoidRootPart.Position
                    ).Unit,

                    effects = {
                        Frost = 0,
                        Ricochet = 0,
                        Barrage = 0
                    },

                    ownerUserId = LocalPlayer.UserId,
                    kind = "bullet",
                    isCharacterHit = true,
                    isADS = false
                }
            }

            ReplicatedStorage.Remotes.ShootReplicate:FireServer(unpack(args))
             MatchStarted = false

    task.wait(Settings.MatchDelay)

    MatchStarted = true

            if Settings.HitSound then
                PlayHitSound()
            end
        end
    end
end

                if Settings.Triggerbot then
                    local Target = Mouse.Target

                    if Target and Target == Part then
                        local TargetPlayer = Players:GetPlayerFromCharacter(Part.Parent)

                        if TargetPlayer then
                            local IsSameTeam = false

                            pcall(function()
                                IsSameTeam = TargetPlayer.Team == LocalPlayer.Team
                            end)

                            if not (Settings.TeamCheck and IsSameTeam) then
                                task.wait(Settings.TriggerDelay)

                                mouse1press()
                                task.wait()
                                mouse1release()
                            end
                        end
                    end
                end
            end
        end
    end

    for Player, Box in pairs(ESPDrawings) do
        local Character = Player.Character

        if Character then
            local Root = Character:FindFirstChild("HumanoidRootPart")
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")

            if Root and Humanoid and Humanoid.Health > 0 then

                local SameTeam = false

                pcall(function()
                    SameTeam = Player.Team == LocalPlayer.Team
                end)

                if Settings.ESPTeamCheck and SameTeam then
                    Box.Visible = false
                    continue
                end

                local Position, Visible = Camera:WorldToViewportPoint(Root.Position)

                if Visible and Settings.ESP then
                    local Size = (Camera:WorldToViewportPoint(Root.Position - Vector3.new(0,3,0)).Y -
                                 Camera:WorldToViewportPoint(Root.Position + Vector3.new(0,2.6,0)).Y)

                    local Width = math.abs(Size / 2)

                    Box.Size = Vector2.new(Width, math.abs(Size))
                    Box.Position = Vector2.new(
                        Position.X - Width / 2,
                        Position.Y - math.abs(Size) / 2
                    )

                    Box.Visible = true
                else
                    Box.Visible = false
                end
            else
                Box.Visible = false
            end
        else
            Box.Visible = false
        end
    end
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

ThemeManager:SetFolder("AstralHub")
SaveManager:SetFolder("AstralHub/Game")

SaveManager:IgnoreThemeSettings()

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
