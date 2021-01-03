local RunService = game:GetService("RunService")
local character = owner.Character
local remote = Instance.new("RemoteEvent")
remote.Name = "VRRemote"
remote.Parent = character

local Motors = {
	Neck = {
		Motor = character.Torso["Neck"];
		Default = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0);
	};
	LeftArm = {
		Motor = character.Torso["Left Shoulder"];
		Default = CFrame.new(-1, 0.5, 0, -4.37113883e-08, 0, -1, 0, 0.99999994, 0, 1, 0, -4.37113883e-08);
	};
	RightArm = {
		Motor = character.Torso["Right Shoulder"];
		Default = CFrame.new(1, 0.5, 0, -4.37113883e-08, 0, 1, -0, 0.99999994, 0, -1, 0, -4.37113883e-08);
	};
}

local head = CFrame.new()
local leftHand = CFrame.new()
local rightHand = CFrame.new()

remote.OnServerEvent:Connect(function(player, mode, ...)
	if player.Character == character then
		local args = {...}
		if mode == "Position" then
			head = args[1]
			leftHand = args[2]
			rightHand = args[3]
		end
	end
end)

RunService.Stepped:Connect(function()
	local rootrot = character.HumanoidRootPart.CFrame - character.HumanoidRootPart.Position
	local headrot = (head - head.Position):ToObjectSpace(rootrot)
	local x, y, z = headrot:ToEulerAnglesXYZ()
	Motors.Neck.Motor.C0 = Motors.Neck.Default * CFrame.fromEulerAnglesXYZ(x, -z, -y)
	local larmrot = (leftHand - leftHand.Position):ToObjectSpace(rootrot)
	local x, y, z = larmrot:ToEulerAnglesXYZ()
	Motors.LeftArm.Motor.C0 = Motors.LeftArm.Default * CFrame.fromEulerAnglesXYZ(-z, -y, x)
	local rarmrot = (rightHand - rightHand.Position):ToObjectSpace(rootrot)
	local x, y, z = rarmrot:ToEulerAnglesXYZ()
	Motors.RightArm.Motor.C0 = Motors.RightArm.Default * CFrame.fromEulerAnglesXYZ(z, -y, -x)
end)

NLS([[
local VRService = game:GetService("VRService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
local StarterGui = game:GetService("StarterGui")
--StarterGui:SetCore("VRLaserPointerMode", 0)
--StarterGui:SetCore("VREnableControllerModels", false)



local character = script.Parent
local VRSpin = 0
local VRRig = Instance.new("Model")
do
	do
		local limb = Instance.new("Part")
		limb.Size = Vector3.new(0.5, 1, 0.5)
		limb.Anchored = true
		limb.CanCollide = false
		limb.Name = "Left Arm"
		limb.Parent = VRRig
	end
	do
		local limb = Instance.new("Part")
		limb.Size = Vector3.new(0.5, 1, 0.5)
		limb.Anchored = true
		limb.CanCollide = false
		limb.Name = "Right Arm"
		limb.Parent = VRRig
	end
	do
		local shirt = Instance.new("Shirt")
		shirt.Parent = VRRig
	end
	do
		local human = Instance.new("Humanoid")
		human.MaxHealth = 0	
		human.Parent = VRRig
	end
	VRRig.Parent = workspace.CurrentCamera
end
local thumbstick2 = Vector2.new(0, 0)
local gyro = Instance.new("BodyGyro")
gyro.MaxTorque = Vector3.new(0, 1000000, 0)
gyro.P = 1000000
gyro.Parent = character.HumanoidRootPart

RunService.RenderStepped:Connect(function()
	VRSpin = VRSpin + thumbstick2.X * -0.1	
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.CFrame = CFrame.new(character.HumanoidRootPart.Position) * CFrame.new(0, 1.5, 0) * CFrame.Angles(0, VRSpin, 0)
	local camera = workspace.CurrentCamera.CFrame
	local head = camera * VRService:GetUserCFrame(Enum.UserCFrame.Head)
	local leftHand = camera * VRService:GetUserCFrame(Enum.UserCFrame.LeftHand) * CFrame.Angles(math.rad(90), 0, 0)
	local rightHand = camera * VRService:GetUserCFrame(Enum.UserCFrame.RightHand) * CFrame.Angles(math.rad(90), 0, 0)
	VRRig.Clothing.ShirtTemplate = character.Shirt.ShirtTemplate
	VRRig["Left Arm"].Color = character["Left Arm"].Color
	VRRig["Right Arm"].Color = character["Right Arm"].Color
	VRRig["Left Arm"].CFrame = leftHand * CFrame.new(0, 0.5, 0)
	VRRig["Right Arm"].CFrame = rightHand * CFrame.new(0, 0.5, 0)
	gyro.CFrame = CFrame.Angles(0, VRSpin, 0)		
	character.VRRemote:FireServer("Position", head, leftHand, rightHand)
	for _, v in pairs(character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.LocalTransparencyModifier = 1
		end
	end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Thumbstick2 then
		thumbstick2 = input.Position
	end
end)



local function onPlayer(player)
	if player == Players.LocalPlayer then return end

	local billboard = Instance.new("BillboardGui")
	billboard.ResetOnSpawn = false
	billboard.ClipsDescendants = false
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 2, 0)
	billboard.Size = UDim2.new(0, 0, 0, 25)
	billboard.MaxDistance = 42
	billboard.Parent = PlayerGui

	billboard.Adornee = player.Character:FindFirstChild("Head")
	player.CharacterAdded:Connect(function(character)
		billboard.Adornee = character:WaitForChild("Head")
	end)

	local messages = {}

	player.Chatted:Connect(function(message)
		local frame = Instance.new("Frame")
		frame.BorderSizePixel = 0
		frame.Visible = false
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 5)
		corner.Parent = frame
		local text = Instance.new("TextLabel")
		text.BackgroundTransparency = 1
		text.Font = Enum.Font.SourceSansBold
		text.TextSize = 20
		text.Text = message
		text.Size = UDim2.new(1, 0, 1, 0)
		text.Parent = frame
		frame.AnchorPoint = Vector2.new(0.5, 0)
		frame.Position = UDim2.new(0.5, 0, 0, 0)
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.Parent = billboard
		for i, frame in pairs(messages) do
			TweenService:Create(
				frame,
				TweenInfo.new(0.1),
				{
					Position = UDim2.new(0.5, 0, -i, -i * 5);
				}
			):Play()
		end
		wait()
		if messages[4] then
			messages[4]:Destroy()
			messages[4] = nil
		end
		table.insert(messages, 1, frame)
		frame.Size = UDim2.new(0, text.TextBounds.X + 10, 1, 0)
		frame.Visible = true
		spawn(function()
			wait(5)
			frame.Visible = false
		end)
	end)
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in pairs(Players:GetPlayers()) do
	onPlayer(player)
end
]], character)
