local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function instance(name, properties)
    local new = Instance.new(name)
    if properties then
        for k, v in pairs(properties) do
            new[k] = v
        end
    end
    return new
end

local function exp(a, bias)
	bias = bias or 2.71828
	if bias == 1 then
		return a
	end
	return ((bias ^ a) - 1) / (bias - 1)
end

local function batch(parent, properties)
    for _, child in pairs(parent:GetDescendants()) do
        for k, v in pairs(properties) do
            child[k] = v
        end
    end
end

local GUI = instance("ScreenGui", { DisplayOrder = 5; ResetOnSpawn = true; IgnoreGuiInset = true; Name = "RythmGui"; Parent = player:FindFirstChildOfClass("PlayerGui"); })

local frame = 0
local rythm = {
    sound = instance("Sound", {
        SoundId = "rbxassetid://663704873";
        Playing = true;
        Volume = 1.5;
        Parent = GUI;
    });
    offset = 0;
    bpm = 120;
    introLength = 3;
    mainLength = 9;
    feverLength = 16;
    fever = 0;
    time = 0;
    rawBeat = 0;
    beat = 0;
    lastBeat = 0;
    nearestBeat = 0;
    lastNearestBeat = 0;
}

local guiBeatFrame = instance("Frame", { BackgroundTransparency = 1; AnchorPoint = Vector2.new(0.5, 0.5); Position = UDim2.new(0.5, 0, 0.5, 0); Size = UDim2.new(1, -32, 1, -32); Parent = GUI; })
instance("Frame", { BorderSizePixel = 0; Position = UDim2.new(0, 0, 0, 0); Size = UDim2.new(1, 0, 0, 8); Parent = guiBeatFrame; })
instance("Frame", { BorderSizePixel = 0; Position = UDim2.new(0, 0, 1, -8); Size = UDim2.new(1, 0, 0, 8); Parent = guiBeatFrame; })
instance("Frame", { BorderSizePixel = 0; Position = UDim2.new(0, 0, 0, 8); Size = UDim2.new(0, 8, 1, -16); Parent = guiBeatFrame; })
instance("Frame", { BorderSizePixel = 0; Position = UDim2.new(1, -8, 0, 8); Size = UDim2.new(0, 8, 1, -16); Parent = guiBeatFrame; })
local guiBeatFrameOutlines = instance("Frame", { BackgroundTransparency = 1; AnchorPoint = Vector2.new(0.5, 0.5); Position = UDim2.new(0.5, 0, 0.5, 0); Size = UDim2.new(1, -32, 1, -32); Parent = GUI; })
instance("Frame", { BorderSizePixel = 0; Position = UDim2.new(0, 0, 0, 0); Size = UDim2.new(1, 0, 0, 3); Parent = guiBeatFrameOutlines; })
instance("Frame", { BorderSizePixel = 0; Position = UDim2.new(0, 0, 1, -3); Size = UDim2.new(1, 0, 0, 3); Parent = guiBeatFrameOutlines; })
instance("Frame", { BorderSizePixel = 0; Position = UDim2.new(0, 0, 0, 3); Size = UDim2.new(0, 3, 1, -6); Parent = guiBeatFrameOutlines; })
instance("Frame", { BorderSizePixel = 0; Position = UDim2.new(1, -3, 0, 3); Size = UDim2.new(0, 3, 1, -6); Parent = guiBeatFrameOutlines; })
instance("Frame", { BorderSizePixel = 0; Position = UDim2.new(0, 5, 0, 5); Size = UDim2.new(1, -10, 0, 3); Parent = guiBeatFrameOutlines; })
instance("Frame", { BorderSizePixel = 0; Position = UDim2.new(0, 5, 1, -8); Size = UDim2.new(1, -10, 0, 3); Parent = guiBeatFrameOutlines; })
instance("Frame", { BorderSizePixel = 0; Position = UDim2.new(0, 5, 0, 8); Size = UDim2.new(0, 3, 1, -16); Parent = guiBeatFrameOutlines; })
instance("Frame", { BorderSizePixel = 0; Position = UDim2.new(1, -8, 0, 8); Size = UDim2.new(0, 3, 1, -16); Parent = guiBeatFrameOutlines; })

RunService.RenderStepped:Connect(function(delta)
    frame = frame + 1
    rythm.time = rythm.time + delta
    rythm.rawBeat = rythm.time * (rythm.bpm / 60)
    rythm.beat = math.floor(rythm.rawBeat)
    rythm.nearestBeat = math.round(rythm.rawBeat)

    if rythm.lastBeat ~= rythm.beat then
        if rythm.fever == 0 then
            if rythm.beat >= 4 then
                print("idle")
                rythm.time = 0
                rythm.fever = rythm.fever + 0.125
            end
        else
            if rythm.beat % 8 == 4 then
                rythm.fever = rythm.fever + 0.125

                local pattern = (rythm.beat - 4) / 8
                if rythm.fever < 0.5 then
                    print("intro")
                    if pattern >= rythm.introLength then
                        pattern = 0
                    end
                elseif rythm.fever < 1 then
                    print("main")
                    if pattern >= rythm.introLength + rythm.mainLength then
                        pattern = rythm.introLength
                    elseif pattern < rythm.introLength then
                        pattern = rythm.introLength
                    end
                else
                    print("fever")
                    if pattern >= rythm.introLength + rythm.mainLength + rythm.feverLength then
                        pattern = rythm.introLength + rythm.mainLength
                    elseif pattern < rythm.introLength + rythm.mainLength then
                        pattern = rythm.introLength + rythm.mainLength
                    end
                end
                if pattern ~= (rythm.beat - 4) / 8 then
                    rythm.beat = (pattern * 8 + 4)
                    rythm.time = rythm.beat / (rythm.bpm / 60)
                end

                print(rythm.fever, pattern)
            end
        end
        rythm.lastBeat = rythm.beat
    end
    
    if rythm.lastNearestBeat ~= rythm.nearestBeat then
        rythm.lastNearestBeat = rythm.nearestBeat
    end

    if math.abs(rythm.time - rythm.sound.TimePosition) > 0.1 then
        rythm.sound.TimePosition = rythm.time
    end

    if rythm.fever == 0 then
        batch(guiBeatFrame, {
            BackgroundTransparency = rythm.rawBeat % 1;
            BackgroundColor3 = Color3.new(1, 1, 1);
        })
        batch(guiBeatFrameOutlines, {
            BackgroundTransparency = 1;
        })
    else
        if rythm.beat % 8 < 4 then
            if rythm.fever < 1 then
                batch(guiBeatFrame, {
                    BackgroundTransparency = rythm.rawBeat % 1;
                    BackgroundColor3 = Color3.new(1, 1, 1);
                })
            else
                if frame % 8 >= 6 then
                    batch(guiBeatFrame, {
                        BackgroundTransparency = rythm.rawBeat % 1;
                        BackgroundColor3 = Color3.new(1, 1, 1)
                    })
                elseif frame % 8 >= 4 then
                    batch(guiBeatFrame, {
                        BackgroundTransparency = rythm.rawBeat % 1;
                        BackgroundColor3 = Color3.new(0.2, 1, 1)
                    })
                elseif frame % 6 >= 2 then
                    batch(guiBeatFrame, {
                        BackgroundTransparency = rythm.rawBeat % 1;
                        BackgroundColor3 = Color3.new(1, 1, 0.2)
                    })
                else
                    batch(guiBeatFrame, {
                        BackgroundTransparency = rythm.rawBeat % 1;
                        BackgroundColor3 = Color3.new(0.2, 1, 0.2);
                    })
                end
            end
            batch(guiBeatFrameOutlines, {
                BackgroundTransparency = 1;
            })
        else
            if rythm.beat % 4 == 3 then
                if frame % 4 < 2 then
                    batch(guiBeatFrameOutlines, {
                        BackgroundTransparency = rythm.rawBeat % 1;
                        BackgroundColor3 = Color3.new(0.2, 0.2, 0.2);
                    })
                else
                    batch(guiBeatFrameOutlines, {
                        BackgroundTransparency = rythm.rawBeat % 1;
                        BackgroundColor3 = Color3.new(1, 1, 1);
                    })
                end
            else
                batch(guiBeatFrameOutlines, {
                    BackgroundTransparency = rythm.rawBeat % 1;
                    BackgroundColor3 = Color3.new(0.2, 0.2, 0.2);
                })
            end
            batch(guiBeatFrame, {
                BackgroundTransparency = 1;
            })
        end
    end
end)

GUI.Parent = player.PlayerGui
