local HttpService = game:GetService("HttpService")

local screenRoot = CFrame.new(0, 20, -40)
local screen = {}
local width = 80
local height = 45
local rps = 4
local resolution = 0.2

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
		pixel.Parent = script
		screen[i] = pixel
	end
end

while true do
	xpcall(function()
		local before = tick()
		local query = string.format("http://86.25.73.27/?w=%s&h=%s", width, height)
		local data = HttpService:JSONDecode(HttpService:GetAsync(query))
		for i, v in pairs(data.pixels) do
			local pixel = screen[i - 1]			
			pixel.Color = Color3.fromRGB(v[1], v[2], v[3])
		end
		local after = tick()
		--print("took", after - before)
	end, function(e)
		warn("error")
		warn(e)
	end)
	wait(1 / rps)
end
