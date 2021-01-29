local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local tau = 2 * math.pi

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

local function lerp(a, b, alpha)
    return a + (b - a) * alpha
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
    combo = 0;
    fever = 0;
    time = 0;
    rawBeat = 0;
    beat = 0;
    lastBeat = 0;
    nearestBeat = 0;
    lastNearestBeat = 0;
}

local worm = {
    frame = instance("Frame", {
        BackgroundTransparency = 1;
        AnchorPoint = Vector2.new(0, 1);
        Position = UDim2.new(0, -500, 0.4, 0);
        Size = UDim2.new(0, 300, 0, 40);
        Parent = GUI;
    });
    length = 400;
    segments = {};
    segmentsBack = {};
    visible = false;
}

worm.scale = instance("UIScale", {
    Parent = worm.frame;
})

worm.text = instance("TextLabel", {
    ZIndex = 11;
    Text = "0";
    TextSize = 64;
    TextColor3 = Color3.new(1, 0, 0);
    TextStrokeTransparency = 0;
    BackgroundTransparency = 1;
    TextXAlignment = Enum.TextXAlignment.Right;
    TextYAlignment = Enum.TextYAlignment.Bottom;
    Font = Enum.Font.FredokaOne;
    Position = UDim2.new(0, 0, 0.4, 20);
    Size = UDim2.new(0, 100, 0, 0);
    Parent = GUI;
})

worm.subtext = instance("TextLabel", {
    ZIndex = 11;
    Text = "COMBO!";
    TextSize = 24;
    TextColor3 = Color3.new(1, 1, 1);
    TextStrokeTransparency = 0;
    BackgroundTransparency = 1;
    TextXAlignment = Enum.TextXAlignment.Left;
    TextYAlignment = Enum.TextYAlignment.Bottom;
    Font = Enum.Font.FredokaOne;
    Position = UDim2.new(1, 6, 0, 0);
    Size = UDim2.new(1, 0, 1, 0);
    Parent = worm.text;
})

for x = 0, worm.length - 1 do
    local new = instance("Frame", {
        ZIndex = 10;
        BorderSizePixel = 0;
        BackgroundColor3 = Color3.new(0.1, 0.1, 0.1);
        Position = UDim2.new(0, x, 0, 0);
        Size = UDim2.new(0, 1, 1, 0);
        Parent = worm.frame;
    })
    local newBack = instance("Frame", {
        ZIndex = 9;
        BorderSizePixel = 0;
        BackgroundColor3 = Color3.new(0.1, 0.1, 0.1);
        Position = UDim2.new(0, 0, 0, -5);
        Size = UDim2.new(1, 0, 1, 10);
        Parent = new;
    })
    worm.segments[x] = new
    worm.segmentsBack[x] = newBack
end

local guiBeatFrame = instance("Frame", { BackgroundTransparency = 1; AnchorPoint = Vector2.new(0.5, 0.5); Position = UDim2.new(0.5, 0, 0.5, 0); Size = UDim2.new(1, -32, 1, -32); Parent = GUI; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = UDim2.new(0, 0, 0, 0); Size = UDim2.new(1, 0, 0, 8); Parent = guiBeatFrame; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = UDim2.new(0, 0, 1, -8); Size = UDim2.new(1, 0, 0, 8); Parent = guiBeatFrame; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = UDim2.new(0, 0, 0, 8); Size = UDim2.new(0, 8, 1, -16); Parent = guiBeatFrame; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = UDim2.new(1, -8, 0, 8); Size = UDim2.new(0, 8, 1, -16); Parent = guiBeatFrame; })
local guiBeatFrameOutlines = instance("Frame", { BackgroundTransparency = 1; AnchorPoint = Vector2.new(0.5, 0.5); Position = UDim2.new(0.5, 0, 0.5, 0); Size = UDim2.new(1, -32, 1, -32); Parent = GUI; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = UDim2.new(0, 0, 0, 0); Size = UDim2.new(1, 0, 0, 3); Parent = guiBeatFrameOutlines; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = UDim2.new(0, 0, 1, -3); Size = UDim2.new(1, 0, 0, 3); Parent = guiBeatFrameOutlines; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = UDim2.new(0, 0, 0, 3); Size = UDim2.new(0, 3, 1, -6); Parent = guiBeatFrameOutlines; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = UDim2.new(1, -3, 0, 3); Size = UDim2.new(0, 3, 1, -6); Parent = guiBeatFrameOutlines; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = UDim2.new(0, 5, 0, 5); Size = UDim2.new(1, -10, 0, 3); Parent = guiBeatFrameOutlines; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = UDim2.new(0, 5, 1, -8); Size = UDim2.new(1, -10, 0, 3); Parent = guiBeatFrameOutlines; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = UDim2.new(0, 5, 0, 8); Size = UDim2.new(0, 3, 1, -16); Parent = guiBeatFrameOutlines; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = UDim2.new(1, -8, 0, 8); Size = UDim2.new(0, 3, 1, -16); Parent = guiBeatFrameOutlines; })

RunService.RenderStepped:Connect(function(delta)
    frame = frame + 1
    rythm.time = rythm.time + delta
    rythm.rawBeat = rythm.time * (rythm.bpm / 60)
    rythm.beat = math.floor(rythm.rawBeat)
    rythm.nearestBeat = math.round(rythm.rawBeat)

    if rythm.lastBeat ~= rythm.beat then
        if rythm.fever == 0 then
            if rythm.beat >= 4 then
                rythm.fever = rythm.fever + 0.125
                rythm.combo = rythm.combo + 1

                print("idle")
                rythm.time = 0
            end
        else
            if rythm.beat % 8 == 4 then
                rythm.fever = rythm.fever + 0.125
                rythm.combo = rythm.combo + 1

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
    
    if rythm.combo < 2 then
        if worm.visible then
            worm.visible = false
            worm.frame.Position = UDim2.new(0, lerp(worm.frame.Position.X.Offset, -worm.length, 0.01), 0.4, 0)
        end
    else
        if not worm.visible then
            worm.visible = true
        end
        if rythm.fever < 0.5 then
            worm.text.Text = rythm.combo
            worm.text.TextColor3 = Color3.new(1, 0, 0)
            worm.text.TextXAlignment = Enum.TextXAlignment.Right
            worm.subtext.Text = "COMBO!"
            worm.frame.Position = UDim2.new(0, lerp(worm.frame.Position.X.Offset, -worm.length + exp(rythm.fever, 0.01) * 250, 0.1), 0.4, 0)
            worm.scale.Scale = 1
            for x, segment in pairs(worm.segments) do
                local y1 = -lerp(0, math.sin(x / worm.length * 6 * tau) * 5 + 5, math.abs(math.sin(rythm.rawBeat * 0.5 * tau)))
                local y2 = 0
                local y = lerp(y1, y2, exp(x / worm.length, 1000))
                segment.Position = UDim2.new(0, x, 0, y)
                segment.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
            end
            for x, segment in pairs(worm.segmentsBack) do
                segment.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
            end
        elseif rythm.fever < 1 then
            worm.text.Text = rythm.combo
            worm.text.TextColor3 = Color3.new(1, 0, 0)
            worm.text.TextXAlignment = Enum.TextXAlignment.Right
            worm.subtext.Text = "COMBO!"
            worm.frame.Position = UDim2.new(0, lerp(worm.frame.Position.X.Offset, -worm.length + exp(rythm.fever, 0.01) * 300, 0.1), 0.4, 0)
            worm.scale.Scale = 1
            for x, segment in pairs(worm.segments) do
                local y1 = -lerp(0, math.sin(x / worm.length * 6 * tau) * 5 + 5, math.abs(math.sin(rythm.rawBeat * 0.5 * tau)))
                local y2 = math.sin(rythm.rawBeat * tau) * 40
                local y = lerp(y1, y2, exp(x / worm.length, 400))
                segment.Position = UDim2.new(0, x, 0, y)
                segment.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
            end
            for x, segment in pairs(worm.segmentsBack) do
                segment.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
            end
        else
            worm.text.Text = "FEVER!"
            worm.text.TextColor3 = Color3.new(1, 0.5, 0):Lerp(Color3.new(1, 0.3, 0), rythm.rawBeat % 1)
            worm.text.TextXAlignment = Enum.TextXAlignment.Left
            worm.subtext.Text = ""
            worm.frame.Position = UDim2.new(0, lerp(worm.frame.Position.X.Offset, -250, 0.01), 0.4, 0)
            worm.scale.Scale = 1 + (1 - (rythm.rawBeat % 1)) * 0.25
            for x, segment in pairs(worm.segments) do
                local y1 = math.sin((x / worm.length - rythm.rawBeat) * tau) * 20
                local y2 = 0
                local y = lerp(y1, y2, exp(x / worm.length, 1000))
                segment.Position = UDim2.new(0, x, 0, y)
                segment.BackgroundColor3 = rythm.fever - 1 >= (x / worm.length) and Color3.new(1, 0.8, 0.1):Lerp(Color3.new(1, 0.4, 0.1), rythm.rawBeat % 1) or Color3.new(1, 0.25, 0.1):Lerp(Color3.new(1, 0.1, 0.1), rythm.rawBeat % 1)
            end
            for x, segment in pairs(worm.segmentsBack) do
                segment.BackgroundColor3 = Color3.new(1, 1, 1)
            end
        end
    end
end)

GUI.Parent = player.PlayerGui
