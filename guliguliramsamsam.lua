local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ICON_IMAGE = "rbxassetid://110552700896064"
local ICON_SIZE = 45
local ICON_POSITION = UDim2.new(0, 20, 0, 20)

local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "UIToggleIcon"
ToggleGui.Parent = game:GetService("CoreGui")
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleGui.ResetOnSpawn = false

local IconButton = Instance.new("ImageButton")
IconButton.Name = "IconButton"
IconButton.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
IconButton.Position = ICON_POSITION
IconButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
IconButton.BorderSizePixel = 0
IconButton.Active = true
IconButton.AutoButtonColor = false
IconButton.Image = ""
IconButton.ClipsDescendants = true
IconButton.Parent = ToggleGui

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(1, 0)
IconCorner.Parent = IconButton

local Icon = Instance.new("ImageLabel")
Icon.Name = "Icon"
Icon.Size = UDim2.new(0.7, 0, 0.7, 0)
Icon.Position = UDim2.new(0.15, 0, 0.15, 0)
Icon.BackgroundTransparency = 1
Icon.Image = ICON_IMAGE
Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
Icon.ScaleType = Enum.ScaleType.Fit
Icon.Parent = IconButton

local IconImageCorner = Instance.new("UICorner")
IconImageCorner.CornerRadius = UDim.new(1, 0)
IconImageCorner.Parent = Icon

local dragging = false
local dragInput, mousePos, framePos
local hasDragged = false
local uiVisible = true
local ToggleCallback = nil

local function update(input)
    local delta = input.Position - mousePos
    local newPos = UDim2.new(
        framePos.X.Scale,
        framePos.X.Offset + delta.X,
        framePos.Y.Scale,
        framePos.Y.Offset + delta.Y
    )
    TweenService:Create(IconButton, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Position = newPos
    }):Play()
    hasDragged = true
end

IconButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = IconButton.Position
        hasDragged = false
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

IconButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

IconButton.MouseButton1Click:Connect(function()
    if not hasDragged then
        if ToggleCallback then
            pcall(function()
                local isVisible = ToggleCallback()
                uiVisible = isVisible ~= nil and not isVisible or not uiVisible
            end)
            return
        end
    end
    task.wait(0.1)
    hasDragged = false
end)

return {
    ToggleGui = ToggleGui,
    IconButton = IconButton,

    SetIcon = function(assetId)
        Icon.Image = assetId
    end,

    SetColor = function(color) end,

    SetPosition = function(position)
        IconButton.Position = position
    end,

    SetCallback = function(callback)
        ToggleCallback = callback
    end,

    SetState = function(state)
        uiVisible = not state
        TweenService:Create(IconButton, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(20, 20, 25)
        }):Play()
    end,

    ToggleUI = function()
        if ToggleCallback then
            pcall(function()
                local isVisible = ToggleCallback()
                uiVisible = isVisible ~= nil and not isVisible or not uiVisible
            end)
        end
    end
}
