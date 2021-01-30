local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local tau = 2 * math.pi
local sin = math.sin
local abs = math.abs
local floor = math.floor
local round = math.round
local deg = math.deg
local atan = math.atan
local color = Color3.new
local ud2 = UDim2.new
local palette = {
    white = color(1, 1, 1);
    veryRed = color(1, 0, 0);
    comboWorm = color(0.1, 0.1, 0.1);
    cyan = color(0.2, 1, 1);
    yellow = color(1, 1, 0.2);
    green = color(0.2, 1, 0.2);
    dark = color(0.2, 0.2, 0.2);
    feverDark = color(1, 0.1, 0.1);
    feverBright = color(1, 0.25, 0.1);
    feverDarkAccent = color(1, 0.4, 0.1);
    feverBrightAccent = color(1, 0.8, 0.1);
}

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

local function grad(x, func, d)
	d = d or 0.001
	local a = func(x)
	local b = func(x + d)
	return (b - a) / d
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
        Position = ud2(0, -500, 0.4, 0);
        Size = ud2(0, 300, 0, 45);
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
    TextColor3 = palette.veryRed;
    TextStrokeTransparency = 0;
    BackgroundTransparency = 1;
    TextXAlignment = Enum.TextXAlignment.Right;
    TextYAlignment = Enum.TextYAlignment.Bottom;
    Font = Enum.Font.FredokaOne;
    Position = ud2(0, 0, 0.4, 20);
    Size = ud2(0, 100, 0, 0);
    Parent = GUI;
})

worm.subtext = instance("TextLabel", {
    ZIndex = 11;
    Text = "COMBO!";
    TextSize = 24;
    TextColor3 = palette.white;
    TextStrokeTransparency = 0;
    BackgroundTransparency = 1;
    TextXAlignment = Enum.TextXAlignment.Left;
    TextYAlignment = Enum.TextYAlignment.Bottom;
    Font = Enum.Font.FredokaOne;
    Position = ud2(1, 6, 0, 0);
    Size = ud2(1, 0, 1, 0);
    Parent = worm.text;
})

for x = 0, worm.length - 1 do
    local new = instance("Frame", {
        ZIndex = 10;
        BorderSizePixel = 0;
        BackgroundColor3 = palette.comboWorm;
        Position = ud2(0, x, 0, 0);
        Size = ud2(0, 1, 1, 0);
        Parent = worm.frame;
    })
    local newBack = instance("Frame", {
        ZIndex = 8;
        BorderSizePixel = 0;
        BackgroundColor3 = palette.comboWorm;
        Position = ud2(0, 0, 0, -5);
        Size = ud2(1, 0, 1, 10);
        Parent = new;
    })
    worm.segments[x] = new
    worm.segmentsBack[x] = newBack
end

worm.head = instance("ImageLabel", {
    ZIndex = 9;
    Image = "rbxassetid://6092002256";
    BackgroundTransparency = 1;
    AnchorPoint = Vector2.new(0.5, 0);
    Position = ud2(0, 0, 0, 0);
    Size = ud2(0, 150, 1, 0);
    Parent = worm.segments[worm.length - 1];
})

worm.back = instance("ImageLabel", {
    ZIndex = 8;
    Image = "rbxassetid://6092002256";
    BackgroundTransparency = 1;
    Position = ud2(0, -5, 0, -5);
    Size = ud2(1, 10, 1, 10);
    Parent = worm.head;
})

worm.top = instance("ImageLabel", {
    ZIndex = 9;
    Image = "rbxassetid://6092325605";
    BackgroundTransparency = 1;
    AnchorPoint = Vector2.new(1, 1);
    Position = ud2(1, -20, 0, 5);
    Size = ud2(0, 50, 0, 25);
    Parent = worm.head;
})

worm.eyes = instance("ImageLabel", {
    ZIndex = 9;
    Image = "rbxassetid://6092325147";
    BackgroundTransparency = 1;
    Position = ud2(0, 0, 0, 0);
    Size = ud2(1, 0, 1, 0);
    Parent = worm.top;
})

local guiBeatFrame = instance("Frame", { BackgroundTransparency = 1; AnchorPoint = Vector2.new(0.5, 0.5); Position = ud2(0.5, 0, 0.5, 0); Size = ud2(1, -32, 1, -32); Parent = GUI; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = ud2(0, 0, 0, 0); Size = ud2(1, 0, 0, 8); Parent = guiBeatFrame; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = ud2(0, 0, 1, -8); Size = ud2(1, 0, 0, 8); Parent = guiBeatFrame; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = ud2(0, 0, 0, 8); Size = ud2(0, 8, 1, -16); Parent = guiBeatFrame; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = ud2(1, -8, 0, 8); Size = ud2(0, 8, 1, -16); Parent = guiBeatFrame; })
local guiBeatFrameOutlines = instance("Frame", { BackgroundTransparency = 1; AnchorPoint = Vector2.new(0.5, 0.5); Position = ud2(0.5, 0, 0.5, 0); Size = ud2(1, -32, 1, -32); Parent = GUI; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = ud2(0, 0, 0, 0); Size = ud2(1, 0, 0, 3); Parent = guiBeatFrameOutlines; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = ud2(0, 0, 1, -3); Size = ud2(1, 0, 0, 3); Parent = guiBeatFrameOutlines; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = ud2(0, 0, 0, 3); Size = ud2(0, 3, 1, -6); Parent = guiBeatFrameOutlines; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = ud2(1, -3, 0, 3); Size = ud2(0, 3, 1, -6); Parent = guiBeatFrameOutlines; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = ud2(0, 5, 0, 5); Size = ud2(1, -10, 0, 3); Parent = guiBeatFrameOutlines; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = ud2(0, 5, 1, -8); Size = ud2(1, -10, 0, 3); Parent = guiBeatFrameOutlines; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = ud2(0, 5, 0, 8); Size = ud2(0, 3, 1, -16); Parent = guiBeatFrameOutlines; })
instance("Frame", { ZIndex = 30; BorderSizePixel = 0; Position = ud2(1, -8, 0, 8); Size = ud2(0, 3, 1, -16); Parent = guiBeatFrameOutlines; })

local frame = 0
local delta = 0
while true do
    frame = frame + 1
    rythm.time = rythm.time + delta
    rythm.rawBeat = rythm.time * (rythm.bpm / 60)
    rythm.beat = floor(rythm.rawBeat)
    rythm.nearestBeat = round(rythm.rawBeat)

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

    if abs(rythm.time - rythm.sound.TimePosition) > 0.1 then
        rythm.sound.TimePosition = rythm.time
    end

    if rythm.fever == 0 then
        batch(guiBeatFrame, {
            BackgroundTransparency = rythm.rawBeat % 1;
            BackgroundColor3 = palette.white;
        })
        batch(guiBeatFrameOutlines, {
            BackgroundTransparency = 1;
        })
    else
        if rythm.beat % 8 < 4 then
            if rythm.fever < 1 then
                batch(guiBeatFrame, {
                    BackgroundTransparency = rythm.rawBeat % 1;
                    BackgroundColor3 = palette.white;
                })
            else
                if frame % 8 >= 6 then
                    batch(guiBeatFrame, {
                        BackgroundTransparency = rythm.rawBeat % 1;
                        BackgroundColor3 = palette.white;
                    })
                elseif frame % 8 >= 4 then
                    batch(guiBeatFrame, {
                        BackgroundTransparency = rythm.rawBeat % 1;
                        BackgroundColor3 = palette.cyan;
                    })
                elseif frame % 6 >= 2 then
                    batch(guiBeatFrame, {
                        BackgroundTransparency = rythm.rawBeat % 1;
                        BackgroundColor3 = palette.yellow;
                    })
                else
                    batch(guiBeatFrame, {
                        BackgroundTransparency = rythm.rawBeat % 1;
                        BackgroundColor3 = palette.green;
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
                        BackgroundColor3 = palette.dark;
                    })
                else
                    batch(guiBeatFrameOutlines, {
                        BackgroundTransparency = rythm.rawBeat % 1;
                        BackgroundColor3 = palette.white;
                    })
                end
            else
                batch(guiBeatFrameOutlines, {
                    BackgroundTransparency = rythm.rawBeat % 1;
                    BackgroundColor3 = palette.dark;
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
            worm.text.Visible = false
            worm.frame.Position = ud2(0, lerp(worm.frame.Position.X.Offset, -worm.length, 0.01), 0.4, 0)
        end
    else
        if not worm.visible then
            worm.visible = true
            worm.text.Visible = true
        end
        if rythm.fever < 0.5 then
            worm.text.Text = rythm.combo
            worm.subtext.Text = "COMBO!"
            worm.subtext.TextColor3 = palette.white
            worm.subtext.TextXAlignment = Enum.TextXAlignment.Left
            worm.subtext.TextSize = 24
            worm.head.ImageColor3 = palette.comboWorm
            worm.top.ImageColor3 = worm.head.ImageColor3
            worm.back.ImageColor3 = worm.head.ImageColor3
            worm.frame.Position = ud2(0, lerp(worm.frame.Position.X.Offset, -worm.length + exp(rythm.fever, 0.01) * 250, 0.1), 0.4, 0)
            worm.scale.Scale = 1
            for x, segment in pairs(worm.segments) do
                local y1 = -lerp(0, sin(x / worm.length * 6 * tau) * 5 + 5, abs(sin(rythm.rawBeat * 0.5 * tau)))
                local y2 = 0
                local y = lerp(y1, y2, exp(x / worm.length, 1000))
                segment.Position = ud2(0, x, 0, y)
                segment.BackgroundColor3 = palette.comboWorm
            end
            for x, segment in pairs(worm.segmentsBack) do
                segment.BackgroundColor3 = palette.comboWorm
            end
            worm.head.Rotation = 0
        elseif rythm.fever < 1 then
            worm.text.Text = rythm.combo
            worm.subtext.Text = "COMBO!"
            worm.subtext.TextColor3 = palette.white
            worm.subtext.TextXAlignment = Enum.TextXAlignment.Left
            worm.subtext.TextSize = 24
            worm.head.ImageColor3 = palette.comboWorm
            worm.top.ImageColor3 = worm.head.ImageColor3
            worm.back.ImageColor3 = worm.head.ImageColor3
            worm.frame.Position = ud2(0, lerp(worm.frame.Position.X.Offset, -worm.length + exp(rythm.fever, 0.01) * 300, 0.1), 0.4, 0)
            worm.scale.Scale = 1
            for x, segment in pairs(worm.segments) do
                local y1 = -lerp(0, sin(x / worm.length * 6 * tau) * 5 + 5, abs(sin(rythm.rawBeat * 0.5 * tau)))
                local y2 = sin((rythm.rawBeat + x / worm.length) * tau) * 40
                local y = lerp(y1, y2, exp(x / worm.length, 400))
                segment.Position = ud2(0, x, 0, y)
                segment.BackgroundColor3 = palette.comboWorm
            end
            for x, segment in pairs(worm.segmentsBack) do
                segment.BackgroundColor3 = palette.comboWorm
            end
            local gradient = grad(1, function(x)
                local y = sin((rythm.rawBeat + x / worm.length) * tau) * 40
                return y
			end)
			local angle = deg(atan(gradient))
            worm.head.Rotation = angle
        else
            worm.text.Text = ""
            worm.subtext.Text = "FEVER!"
            worm.subtext.TextColor3 = palette.feverBrightAccent:Lerp(palette.feverDarkAccent, rythm.rawBeat % 1)
            worm.subtext.TextXAlignment = Enum.TextXAlignment.Center
            worm.subtext.TextSize = 64
            worm.head.ImageColor3 = rythm.fever >= 2 and palette.feverBrightAccent:Lerp(palette.feverDarkAccent, rythm.rawBeat % 1) or palette.feverBright:Lerp(palette.feverDark, rythm.rawBeat % 1)
            worm.top.ImageColor3 = worm.head.ImageColor3
            worm.back.ImageColor3 = palette.white
            worm.frame.Position = ud2(0, lerp(worm.frame.Position.X.Offset, -250, 0.01), 0.4, 0)
            worm.scale.Scale = 1 + (1 - (rythm.rawBeat % 1)) * 0.25
            for x, segment in pairs(worm.segments) do
                local y1 = sin((x / worm.length - rythm.rawBeat) * tau) * 20
                local y2 = 0
                local y = lerp(y1, y2, exp(x / worm.length, 1000))
                segment.Position = ud2(0, x, 0, y)
                segment.BackgroundColor3 = rythm.fever - 1 >= (x / worm.length) and palette.feverBrightAccent:Lerp(palette.feverDarkAccent, rythm.rawBeat % 1) or palette.feverBright:Lerp(palette.feverDark, rythm.rawBeat % 1)
            end
            for x, segment in pairs(worm.segmentsBack) do
                segment.BackgroundColor3 = palette.white
            end
            worm.head.Rotation = 0
        end
    end
    delta = RunService.RenderStepped:Wait()
end

GUI.Parent = player.PlayerGui
