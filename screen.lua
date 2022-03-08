-- screen 160 90 2 0 20 -40 0.2

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local owner = owner or Players:WaitForChild("TheBabinator")
local base = "http://86.25.73.27/"
local ready = false
local screen = nil
local screenModel = nil
local screenRoot = nil
local width = nil
local height = nil
local resolution = nil
local frequency = nil
local loss = 0

local function newScreen(x, y, z, w, h, r, f)
	if screenModel then
		screenModel:Destroy()
	end
	
	ready = false
	screen = {}
	screenModel = Instance.new("Model")
	screenRoot = CFrame.new(x, y, z)
	width = w
	height = h
	resolution = r
	frequency = f

	for x = 0, width - 1 do
		for y = 0, height - 1 do
			local i = x + y * width
			local pixel = Instance.new("Part")
			pixel.Anchored = true
			pixel.Size = Vector3.new(resolution, resolution, 0)
			pixel.Material = Enum.Material.SmoothPlastic
			pixel.CanQuery = false
			pixel.CanCollide = false
			pixel.CanTouch = false
			pixel.CastShadow = false
			pixel.Color = Color3.new()
			pixel.CFrame = screenRoot * CFrame.new(x * resolution - width * resolution / 2, -y * resolution + height * resolution / 2, 0)
			pixel.Parent = screenModel
			screen[i] = pixel
		end
	end
	screenModel.Parent = script
	
	pcall(function()
		HttpService:GetAsync(base)
	end)
	
	ready = true
end

owner.Chatted:Connect(function(msg)
	local words = string.split(msg, " ")
	if words[1] == "/e" then
		table.remove(words, 1)
	end
	if words[1] == "screen" then
		local w = tonumber(words[2]) or 320
		local h = tonumber(words[3]) or 180
		local f = tonumber(words[4]) or 1
		local x = tonumber(words[5]) or 0
		local y = tonumber(words[6]) or 20
		local z = tonumber(words[7]) or -40
		local r = tonumber(words[8]) or 0.2
		newScreen(x, y, z, w, h, r, f)
	end
end)

while true do
	if ready then
		xpcall(function()
			local before = tick()
			local query = string.format("%s?w=%s&h=%s&l=%s", base, width, height, loss)
			local data = HttpService:JSONDecode(HttpService:GetAsync(query))
			local pixels = 0
			for _, v in pairs(data.pixels) do
				local pixel = screen[v[1]]
				pixel.Color = Color3.fromRGB(v[2], v[3], v[4])
				pixels += 1
			end
			local after = tick()
			print("took", after - before, "changed", pixels)
		end, function(e)
			warn("error")
			warn(e)
		end)
		task.wait(1 / frequency)
	else
		task.wait(1)
	end
end
