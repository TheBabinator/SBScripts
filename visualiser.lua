local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local player = owner
local character = owner.Character

local music = Instance.new("Sound")
music.Volume = 1
music.Name = "VMusic"
music.Parent = character.HumanoidRootPart

local eq = Instance.new("EqualizerSoundEffect")
eq.LowGain = 0
eq.MidGain = 0
eq.HighGain = 0
eq.Parent = music

local color = Instance.new("Color3Value")
color.Value = Color3.fromHSV(math.random(), 1, 1)
color.Name = "VColor"
color.Parent = music

local sensitivity = Instance.new("NumberValue")
sensitivity.Value = 1
sensitivity.Name = "VSensitivity"
sensitivity.Parent = music

local locals = {}

local commands = {
	play = function(args)
		local id = table.remove(args, 1)
		if not string.find(id, "://") then
			id = "rbxassetid://"..id
		end
		music:Stop()
		music.SoundId = id
		music.Looped = true
		music:Play()
	end;
	once = function(args)
		local id = table.remove(args, 1)
		if not string.find(id, "://") then
			id = "rbxassetid://"..id
		end
		music:Stop()
		music.SoundId = id
		music.Looped = false
		music:Play()
	end;
	pause = function(args)
		music:Pause()
	end;
	resume = function(args)
		music:Play()
	end;
	stop = function(args)
		music:Stop()
	end;
	boost = function(args)
		local newsensitivity = tonumber(table.remove(args, 1) or 1)
		sensitivity.Value = newsensitivity
	end;
	volume = function(args)
		local volume = tonumber(table.remove(args, 1) or 1)
		music.Volume = volume
	end;
	speed = function(args)
		local speed = tonumber(table.remove(args, 1) or 1)
		music.PlaybackSpeed = speed
	end;
	color = function(args)
		local r = tonumber(table.remove(args, 1) or 255)
		local g = tonumber(table.remove(args, 1) or 0)
		local b = tonumber(table.remove(args, 1) or 0)
		color.Value = Color3.fromRGB(r, g, b)
	end;
	eq = function(args)
		local lo = tonumber(table.remove(args, 1) or 0)
		local mid = tonumber(table.remove(args, 1) or 0)
		local hi = tonumber(table.remove(args, 1) or 0)
		eq.LowGain = lo
		eq.MidGain = mid
		eq.HighGain = hi
	end;
	dismiss = function(args)
		for _, gui in pairs(locals) do
			gui:Destroy()
		end
		locals = {}
		music:Destroy()
		script:Destroy()
	end;
	wait = function(args)
		wait(tonumber(table.remove(args, 1)))
	end;
}

player.Chatted:Connect(function(message)
	local args = string.split(message, " ")
	if args[1] == "/e" then
		table.remove(args, 1)
	end
	while #args > 0 do
		local command = table.remove(args, 1)
		if commands[command] then
			commands[command](args)
		else
			break
		end
	end
end)

character.AncestryChanged:Connect(function()
	for _, gui in pairs(locals) do
		gui:Destroy()
	end
	locals = {}
	music:Destroy()
	script:Destroy()
end)

local localScript = [[
    do
        while not script:WaitForChild("Character") do
            wait()
        end
        while not script.Character.Value do
            wait()
        end
    end
    local RunService = game:GetService("RunService")
    local character = script.Character.Value
    local root = character:WaitForChild("HumanoidRootPart")
    local music = root:WaitForChild("VMusic")
    local color = music:WaitForChild("VColor")
    local sensitivity = music:WaitForChild("VSensitivity")
    local barcount = 16
    
    local part = Instance.new("Part")
    part.CanCollide = false
    part.CastShadow = false
    part.Material = Enum.Material.Neon
    part.Parent = character
    
    local light = Instance.new("PointLight")
    light.Range = 32
    light.Parent = part
    
    local pfront = Instance.new("ParticleEmitter")
    pfront.Texture = "rbxassetid://241650934"
    pfront.EmissionDirection = Enum.NormalId.Front
    pfront.LightEmission = 1
    pfront.Lifetime = NumberRange.new(5)
    pfront.VelocityInheritance = 1
    pfront.Parent = part
    
    local pback = Instance.new("ParticleEmitter")
    pback.Texture = "rbxassetid://241650934"
    pback.EmissionDirection = Enum.NormalId.Back
    pback.LightEmission = 1
    pback.Lifetime = NumberRange.new(5)
    pback.VelocityInheritance = 1
    pback.Parent = part
    
    local pleft = Instance.new("ParticleEmitter")
    pleft.Texture = "rbxassetid://241650934"
    pleft.EmissionDirection = Enum.NormalId.Left
    pleft.LightEmission = 1
    pleft.Lifetime = NumberRange.new(5)
    pleft.VelocityInheritance = 1
    pleft.Parent = part
    
    local pright = Instance.new("ParticleEmitter")
    pright.Texture = "rbxassetid://241650934"
    pright.EmissionDirection = Enum.NormalId.Right
    pright.LightEmission = 1
    pright.Lifetime = NumberRange.new(5)
    pright.VelocityInheritance = 1
    pright.Parent = part
    
    local bars = {}
    for i = 1, barcount do
        local bar = Instance.new("Part")
        bar.CanCollide = false
        bar.CastShadow = false
        bar.Material = Enum.Material.Neon
        bar.Parent = part
        bars[i] = {bar, ((math.pi * 2) / barcount) * (i - 1)}
    end
    
    local function lerp(a, b, v)
        return a + ((b - a) * v)
    end
    
    local function exp(a, bias)
        bias = bias or 2.71828
        if bias == 1 then
            return a
        end
        return ((bias ^ a) - 1) / (bias - 1)
    end
    
    local function complimentaryColor(color)
        local h, s, v = color:ToHSV()
        h = (h + 0.5) % 1
        return Color3.fromHSV(h, s, v)
    end
    
    local loud = 0
    local bass = 0
    local rot = 0
    local sint = 0
    
    RunService.RenderStepped:Connect(function()
        if not character:FindFirstChild("HumanoidRootPart") then
            script:Destroy()
        end
        
        local color = color.Value
        local complimentary = complimentaryColor(color)
        local real = math.clamp(music.PlaybackLoudness / 1000 * sensitivity.Value, 0, 1)
        if real > loud then
            loud = real
        else
            loud = lerp(loud, real, 0.05)
        end
        if loud > bass then
            bass = lerp(bass, loud, 0.025)
        else
            bass = lerp(bass, loud, 0.0125)
        end
        rot += bass * 0.29 + 0.01
        sint += 0.05 * (exp(loud) + 1)
        part.Velocity = character.HumanoidRootPart.Velocity
        part.RotVelocity = character.HumanoidRootPart.RotVelocity
        part.CFrame = CFrame.new(character.HumanoidRootPart.Position) * CFrame.new(0, 6, 0) * CFrame.Angles(0, rot, 0)
        part.Color = Color3.new(0, 0, 0):Lerp(color, math.clamp(exp(loud, 0.01), 0, 1))
        part.Size = Vector3.new(1, 1, 1) + (Vector3.new(0.5, 0.5, 0.5) * exp(loud, 0.01)) + (Vector3.new(-0.5, 1, -0.5) * exp(bass, 0.1))
        for _, bar in pairs(bars) do
            bar[1].Color = Color3.new(0, 0, 0):Lerp(complimentary, math.clamp(exp(loud, 0.01), 0, 1))
            bar[1].Size = Vector3.new(0.2, 0.2, 0.2) + Vector3.new(6, 0, 0) * exp(loud, 0.01) * (math.sin(sint + bar[2] * (exp(bass, 0.1) * 30 + 2)) * 0.15 + 0.85)
            bar[1].CFrame = CFrame.new(character.HumanoidRootPart.Position) * CFrame.new(0, 6, 0) * CFrame.Angles(0, rot * -0.1, 0) * CFrame.Angles(0, bar[2] * 0.5, 0)
        end
        light.Color = color
        light.Brightness = exp(loud) * 2
        local size = loud * (bass + 0.5)
        local speed = loud * 10
        local accel = exp(bass * 2)
        pfront.Size = NumberSequence.new(size, 0)
        pfront.Acceleration = Vector3.new(0, accel, 0)
        pfront.Rate = bass * 60
        pfront.Speed = NumberRange.new(speed)
        pfront.Color = ColorSequence.new(color)
        pback.Size = NumberSequence.new(size, 0)
        pback.Acceleration = Vector3.new(0, accel, 0)
        pback.Rate = bass * 60
        pback.Speed = NumberRange.new(speed)
        pback.Color = ColorSequence.new(color)
        pleft.Size = NumberSequence.new(size, 0)
        pleft.Acceleration = Vector3.new(0, accel, 0)
        pleft.Rate = bass * 60
        pleft.Speed = NumberRange.new(speed)
        pleft.Color = ColorSequence.new(color)
        pright.Size = NumberSequence.new(size, 0)
        pright.Acceleration = Vector3.new(0, accel, 0)
        pright.Rate = bass * 60
        pright.Speed = NumberRange.new(speed)
        pright.Color = ColorSequence.new(color)
    end)    
]]

for _, player in pairs(Players:GetPlayers()) do
    local gui = Instance.new("ScreenGui")
    local scr = NLS(localScript, gui)
    local charval = Instance.new("ObjectValue")
    charval.Name = "Character"
    charval.Value = character
    charval.Parent = scr
    gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")
	table.insert(locals, gui)
end

game.Players.PlayerAdded:Connect(function(player)
    local gui = Instance.new("ScreenGui")
    local scr = NLS(localScript, gui)
    local charval = Instance.new("ObjectValue")
    charval.Name = "Character"
    charval.Value = character
    charval.Parent = scr
    gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")
	table.insert(locals, gui)
end)

