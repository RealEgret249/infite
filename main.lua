local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local userInputService = game:GetService("UserInputService")

-- Vérifier si l'UI existe déjà
local screenGui = player:FindFirstChild("PlayerGui"):FindFirstChild("CustomUI")
if screenGui then
	screenGui:Destroy()
end

-- 📌 Fonction pour recréer l'UI après la mort
local function recreateUI()
	print("🔄 Recréation de l'UI...") -- Debug

	-- Supprime l'ancienne UI si elle existe
	if screenGui then
		screenGui:Destroy()
	end

	-- Créer une nouvelle UI
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CustomUI"
	screenGui.Parent = player:WaitForChild("PlayerGui")
	screenGui.Enabled = true -- Afficher l'UI par défaut

	-- Fonction pour créer des boutons
	local function createStyledButton(parent, text, position, color)
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(0, 180, 0, 40)
		button.Position = position
		button.BackgroundColor3 = color
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 18
		button.Text = text
		button.Font = Enum.Font.GothamBold
		button.Parent = parent

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = button

		return button
	end

	-- 🔘 Recréer les boutons
	local infJumpButton = createStyledButton(screenGui, "Inf Jump", UDim2.new(0, 10, 0, 10), Color3.fromRGB(30, 30, 30))
	local flyButton = createStyledButton(screenGui, "Fly", UDim2.new(0, 10, 0, 60), Color3.fromRGB(255, 215, 0))
	local noClipButton = createStyledButton(screenGui, "No-Clip OFF", UDim2.new(0, 10, 0, 110), Color3.fromRGB(255, 0, 0))
	local godModeButton = createStyledButton(screenGui, "God Mode", UDim2.new(0, 10, 0, 160), Color3.fromRGB(128, 0, 128))
	local killPartButton = createStyledButton(screenGui, "Killer Part", UDim2.new(0, 10, 0, 210), Color3.fromRGB(255, 69, 0))

	print("✅ Boutons recréés !") -- Debug

	-- 🏆 Inf Jump Toggle
	local infJumpEnabled = false
	infJumpButton.MouseButton1Click:Connect(function()
		infJumpEnabled = not infJumpEnabled
		infJumpButton.Text = infJumpEnabled and "Inf Jump: ON" or "Inf Jump: OFF"
		infJumpButton.BackgroundColor3 = infJumpEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(30, 30, 30)
	end)

	userInputService.JumpRequest:Connect(function()
		if infJumpEnabled and humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)

	-- 🚀 Fly Toggle
	local flying = false
	local speed = 50
	local bodyGyro = nil
	local bodyVelocity = nil
	local upVelocity = 0
	local forwardVelocity = 0
	local rightVelocity = 0

	flyButton.MouseButton1Click:Connect(function()
		flying = not flying
		if flying then
			bodyGyro = Instance.new("BodyGyro", character.PrimaryPart)
			bodyGyro.P, bodyGyro.maxTorque = 9e4, Vector3.new(9e9, 9e9, 9e9)
			bodyGyro.cframe = character.PrimaryPart.CFrame
			bodyVelocity = Instance.new("BodyVelocity", character.PrimaryPart)
			bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
			humanoid.PlatformStand = true
			if noClipEnabled then
				for _, part in pairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		else
			bodyGyro:Destroy()
			bodyVelocity:Destroy()
			humanoid.PlatformStand = false

			-- Réactiver les collisions si le No-Clip est désactivé
			if not noClipEnabled then
				for _, part in pairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = true
					end
				end
			end
		end
	end)

	-- Handle movement
	local move = {E = speed, Space = speed, Q = -speed, W = speed, S = -speed, A = -speed, D = speed}

	userInputService.InputBegan:Connect(function(input)
		if flying then
			local key = input.KeyCode.Name
			if move[key] then
				if key == "E" or key == "Space" then
					upVelocity = move[key]
				elseif key == "Q" then
					upVelocity = move[key]
				elseif key == "W" or key == "S" then
					forwardVelocity = move[key]
				elseif key == "A" or key == "D" then
					rightVelocity = move[key]
				end
			end
		end
	end)

	userInputService.InputEnded:Connect(function(input)
		if flying then
			local key = input.KeyCode.Name
			if key == "E" or key == "Space" then upVelocity = 0
			elseif key == "Q" then upVelocity = 0
			elseif key == "W" or key == "S" then forwardVelocity = 0
			elseif key == "A" or key == "D" then rightVelocity = 0 end
		end
	end)

	-- Update fly mech
	game:GetService("RunService").RenderStepped:Connect(function()
		if flying and character.PrimaryPart then
			bodyGyro.cframe = workspace.CurrentCamera.CFrame
			bodyVelocity.velocity = workspace.CurrentCamera.CFrame.LookVector * forwardVelocity
				+ workspace.CurrentCamera.CFrame.RightVector * rightVelocity + Vector3.new(0, upVelocity, 0)
		end
	end)

	-- 🏃‍♂️ No-Clip Toggle
	local noClipEnabled = false
	noClipButton.MouseButton1Click:Connect(function()
		noClipEnabled = not noClipEnabled
		noClipButton.Text = noClipEnabled and "No-Clip: ON" or "No-Clip: OFF"
		noClipButton.BackgroundColor3 = noClipEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(255, 0, 0)

		-- Activer/désactiver le No-Clip
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = not noClipEnabled
			end
		end
	end)

	-- Optionnel : Activer/désactiver le No-Clip avec une touche (par exemple, "N")
	userInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Enum.KeyCode.N then
			noClipEnabled = not noClipEnabled
			noClipButton.Text = noClipEnabled and "No-Clip: ON" or "No-Clip: OFF"
			noClipButton.BackgroundColor3 = noClipEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(255, 0, 0)

			-- Activer/désactiver le No-Clip
			for _, part in pairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = not noClipEnabled
				end
			end
		end
	end)

	local godModeEnabled = false
	godModeButton.MouseButton1Click:Connect(function()
		godModeEnabled = not godModeEnabled
		godModeButton.Text = godModeEnabled and "God Mode: ON" or "God Mode: OFF"
		godModeButton.BackgroundColor3 = godModeEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(128, 0, 128)

		if godModeEnabled then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				-- Définir la santé à une valeur élevée
				humanoid.Health = math.huge

				-- Empêcher toute modification de la santé
				humanoid:GetPropertyChangedSignal("Health"):Connect(function()
					if godModeEnabled then
						
						humanoid.Health = math.huge
					end
				end)

				-- Désactiver les dégâts
				humanoid:SetAttribute("GodModeEnabled", true)
			end
		else
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				-- Réactiver les dégâts
				humanoid:SetAttribute("GodModeEnabled", false)
			end
		end
	end)


	-- Configuration
	local KILLER_PART_DAMAGE = 100 -- Damage dealt by the Killer Part
	local KILLER_PART_COLOR = Color3.fromRGB(255, 0, 0) -- Red color for the Killer Part
	local KILLER_PART_SIZE = Vector3.new(5, 1, 5) -- Size of the Killer Part
	local KILLER_PART_POSITION_OFFSET = Vector3.new(0, -3, 0) -- Position offset below the player

	-- Function to create a Killer Part
	local function createKillerPart()
		-- Create the Killer Part
		local killerPart = Instance.new("Part")
		killerPart.Name = "KillerPart"
		killerPart.Size = KILLER_PART_SIZE
		killerPart.Position = character.PrimaryPart.Position + KILLER_PART_POSITION_OFFSET
		killerPart.Anchored = true
		killerPart.BrickColor = BrickColor.new(KILLER_PART_COLOR)
		killerPart.Material = Enum.Material.Neon
		killerPart.CanCollide = false
		killerPart.CanTouch = true
		killerPart.Parent = workspace

		-- Add a hitbox (optional, for better collision detection)
		local hitbox = Instance.new("BoxHandleAdornment")
		hitbox.Size = killerPart.Size
		hitbox.Adornee = killerPart
		hitbox.Transparency = 0.5
		hitbox.Color3 = KILLER_PART_COLOR
		hitbox.ZIndex = 10
		hitbox.Parent = killerPart

		-- Function to handle player touch
		local function onTouched(otherPart)
			local touchedCharacter = otherPart.Parent
			local humanoid = touchedCharacter:FindFirstChildOfClass("Humanoid")

			if humanoid and humanoid ~= character:FindFirstChildOfClass("Humanoid") then
				-- Check if the player has God Mode enabled
				if humanoid:GetAttribute("GodModeEnabled") then
					print("🛡️ God Mode protects the player!") -- Debug
				else
					-- Deal damage to the player
					humanoid:TakeDamage(KILLER_PART_DAMAGE)
					print("💀 Player touched the Killer Part!") -- Debug
				end
			end
		end

		-- Connect the Touched event
		killerPart.Touched:Connect(onTouched)

		return killerPart
	end

	-- Function to spawn the Killer Part
	local function spawnKillerPart()
		print("🔥 Spawning Killer Part...") -- Debug

		if not character or not character.PrimaryPart then
			print("⚠️ Error: character.PrimaryPart is missing!") -- Debug
			return
		end

		-- Create the Killer Part
		local killerPart = createKillerPart()
		print("✅ Killer Part created at:", killerPart.Position) -- Debug
	end

	-- Example: Spawn the Killer Part when a button is clicked
	local killPartButton = killPartButton
		killPartButton.MouseButton1Click:Connect(spawnKillerPart)
end

-- 🌀 **Recréer l'UI à chaque respawn**
player.CharacterAdded:Connect(function(newCharacter)
	print("🔄 Personnage respawn !") -- Debug
	character = newCharacter
	humanoid = character:FindFirstChildOfClass("Humanoid")

	-- Attendre un peu pour éviter les erreurs
	wait(0.5)
	recreateUI()
end)

-- 🎭 **Afficher/Cacher l'interface avec "U"**
userInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.U then
		screenGui.Enabled = not screenGui.Enabled
		print("🎭 UI Toggle: " .. tostring(screenGui.Enabled)) -- Debug
	end
end)

-- 🏁 **Démarrage Initial**
recreateUI()
