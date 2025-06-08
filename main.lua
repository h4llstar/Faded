loadstring(game:HttpGet("https://raw.githubusercontent.com/drillygzzly/Roblox-UI-Libs/main/Yun%20V2%20Lib/Yun%20V2%20Lib%20Source.lua"))()

local Library = initLibrary()
local Window = Library:Load({name = "FF2 QB Aimbot", sizeX = 460, sizeY = 500, color = Color3.fromRGB(255, 255, 255)})

local MainTab = Window:Tab("QB Aimbot")
local AimSection = MainTab:Section{name = "Throw Assist", column = 1}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local config = {
	enabled = false,
	target = nil,
	throwType = "Bullet",
	autoPower = true
}

-- Build player dropdown content
local playerList = {}
for _, p in ipairs(Players:GetPlayers()) do
	if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team then
		table.insert(playerList, p.Name)
	end
end

AimSection:Toggle{
	Name = "Enable Aimbot",
	flag = "aim_enabled",
	callback = function(state)
		config.enabled = state
	end
}

AimSection:dropdown{
	name = "Lock to Player",
	content = playerList,
	multichoice = false,
	callback = function(name)
		config.target = Players:FindFirstChild(name)
	end
}

AimSection:dropdown{
	name = "Throw Type",
	content = {"Bullet", "Dot", "Fade", "Lob"},
	multichoice = false,
	callback = function(val)
		config.throwType = val
	end
}

AimSection:Toggle{
	Name = "Auto Power",
	flag = "auto_power",
	callback = function(val)
		config.autoPower = val
	end
}

local function calculatePower(dist)
	local multiplier = ({
		Bullet = 1.3,
		Dot = 1.1,
		Fade = 1.25,
		Lob = 0.9
	})[config.throwType] or 1.2
	return math.clamp(math.floor(dist * multiplier), 30, 95)
end

RunService.RenderStepped:Connect(function()
	if not config.enabled or not config.target then return end
	if not config.target.Character or not config.target.Character:FindFirstChild("HumanoidRootPart") then return end

	local hrp = config.target.Character.HumanoidRootPart
	local predict = hrp.Position + (hrp.Velocity * 0.14)
	local dist = (predict - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude

	Mouse.TargetFilter = workspace
	Mouse.Hit = CFrame.new(predict)

	if config.autoPower then
		local power = calculatePower(dist)
		local gui = LocalPlayer.PlayerGui:FindFirstChild("Main")
		if gui and gui:FindFirstChild("ThrowPower") then
			gui.ThrowPower.Text = tostring(power)
		end
	end
end)
