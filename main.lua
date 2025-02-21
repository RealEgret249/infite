local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local userInputService = game:GetService("UserInputService")

-- Création de l'interface
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.Enabled = false

-- Fonction pour créer des boutons stylés
local function createStyledButton(parent, text, position, color)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 180, 0, 40) -- Taille moyenne
	button.Position = position
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 18
	button.Text = text
	button.Font = Enum.Font.GothamBold
	button.Parent = parent

	-- Bord arrondi
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button

	-- Ombre légère
	local shadow = Instance.new("UIStroke")
	shadow.Parent = button
	shadow.Thickness = 2
	shadow.Color = Color3.fromRGB(50, 50, 50)

	-- Effet de survol (hover)
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.2)
	end)
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = color
	end)

	return button
end

-- Création des boutons
local infJumpButton = createStyledButton(screenGui, "Inf Jump", UDim2.new(0, 10, 0, 10), Color3.fromRGB(30, 30, 30))
local flyButton = createStyledButton(screenGui, "Fly", UDim2.new(0, 10, 0, 60), Color3.fromRGB(255, 215, 0))
local noClipButton = createStyledButton(screenGui, "No-Clip OFF", UDim2.new(0, 10, 0, 110), Color3.fromRGB(255, 0, 0))

-- 📌 INF JUMP
local infJumpEnabled = false
infJumpButton.MouseButton1Click:Connect(function()
	infJumpEnabled = not infJumpEnabled
	infJumpButton.Text = infJumpEnabled and "Inf Jump: ON" or "Inf Jump: OFF"
end)

userInputService.JumpRequest:Connect(function()
	if infJumpEnabled then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- 🚀 FLY
local flying = false
local bodyGyro, bodyVelocity
flyButton.MouseButton1Click:Connect(function()
	flying = not flying
	flyButton.Text = flying and "Fly: ON" or "Fly: OFF"

	if flying then
		bodyGyro = Instance.new("BodyGyro", character.PrimaryPart)
		bodyGyro.P, bodyGyro.maxTorque = 9e4, Vector3.new(9e9, 9e9, 9e9)
		bodyGyro.cframe = character.PrimaryPart.CFrame

		bodyVelocity = Instance.new("BodyVelocity", character.PrimaryPart)
		bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)

		humanoid.PlatformStand = true
	else
		bodyGyro:Destroy()
		bodyVelocity:Destroy()
		humanoid.PlatformStand = false
	end
end)

-- 🏃‍♂️ NO-CLIP
local noClipEnabled = false
noClipButton.MouseButton1Click:Connect(function()
	noClipEnabled = not noClipEnabled
	noClipButton.Text = noClipEnabled and "No-Clip: ON" or "No-Clip: OFF"

	if noClipEnabled then
		game:GetService("RunService").Stepped:Connect(function()
			if noClipEnabled then
				for _, part in pairs(character:GetChildren()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
	end
end)

-- 🎭 Activer/Désactiver l'interface avec "U"
userInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.U then
		screenGui.Enabled = not screenGui.Enabled
	end
end)
