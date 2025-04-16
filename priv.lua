local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local GoldenApe = workspace.SharedObjects.Characters:WaitForChild("Kurama")
local GoldenApeRoot = GoldenApe:WaitForChild("RootPart")

-- Config
local JUMP_HEIGHT = 250
local ORBIT_RADIUS = 100
local BASE_SPEED = 4
local BOOSTED_SPEED = 20
local PLATFORM_OFFSET = Vector3.new(0, -3, 0)
local DEBUG_MODE = true

-- Visual platform
local platform = Instance.new("Part")
platform.Name = "OrbitPlatform"
platform.Anchored = true
platform.CanCollide = true
platform.Size = Vector3.new(4, 1, 4)
platform.Transparency = 0.5
platform.Color = Color3.fromRGB(255, 170, 0)
platform.Parent = workspace

-- Animator setup
local animator = GoldenApe:FindFirstChildOfClass("Animator") or
    (GoldenApe:FindFirstChildOfClass("AnimationController") and 
     GoldenApe:FindFirstChildOfClass("AnimationController"):FindFirstChildOfClass("Animator"))

-- Orbit state
local angle = 0
local currentSpeed = BASE_SPEED
local baseHeight = GoldenApeRoot.Position.Y
local currentHeight = baseHeight

-- Create a height value for tweening
local heightValue = Instance.new("NumberValue")
heightValue.Value = baseHeight + 100

-- Function to smoothly tween height
local function tweenHeight(newHeight, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(heightValue, tweenInfo, { Value = newHeight }):Play()
end

-- Orbit function (runs nonstop)
RunService.Heartbeat:Connect(function(dt)
    angle += currentSpeed * dt

    local x = math.cos(angle) * ORBIT_RADIUS
    local z = math.sin(angle) * ORBIT_RADIUS
    local targetPos = GoldenApeRoot.Position + Vector3.new(x, 330, z)
    targetPos = Vector3.new(targetPos.X, heightValue.Value, targetPos.Z)

    -- Rotate to face GoldenApe and move
    root.CFrame = CFrame.new(targetPos, GoldenApeRoot.Position)

    -- Move platform below character
    platform.CFrame = CFrame.new(targetPos + PLATFORM_OFFSET)
end)

-- Boost speed/height when animation plays
local function setupAnimationDetection()
    if not animator then
        warn("No animator found on GoldenApe.")
        return
    end

    animator.AnimationPlayed:Connect(function(track)
        if DEBUG_MODE then print("Animation started - boosting...") end

        currentSpeed = BOOSTED_SPEED
        tweenHeight(GoldenApeRoot.Position.Y + JUMP_HEIGHT, 0.3) -- Smoothly raise height

        track.Stopped:Connect(function()
            if DEBUG_MODE then print("Animation stopped - reverting...") end

            currentSpeed = BASE_SPEED
            tweenHeight(GoldenApeRoot.Position.Y, 0.3) -- Smoothly return to base height
        end)
    end)
end

-- Cleanup
character.AncestryChanged:Connect(function()
    if not character:IsDescendantOf(game) then
        platform:Destroy()
    end
end)

while true do
    task.wait(0.2)
    GoldenApeRoot.Anchored = true
    workspace.SharedObjects.Characters.Kurama.HumanoidRootPart.Anchored = true
    end

-- Init
setupAnimationDetection()
