--credits
--GitHub: RealEgret249


local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local userInputService = game:GetService("UserInputService")

-- Vérifier si l'UI existe déjà
local screenGui = player:FindFirstChild("PlayerGui"):FindFirstChild("CustomUI")
if screenGui then
	screenGui:Destroy()
end
local ToggleGui = player:FindFirstChild("PlayerGui"):FindFirstChild("CustomUI")
if ToggleGui then
	ToggleGui:Destroy()
end
-- 📌 Fonction pour recréer l'UI après la mort
local function recreateUI()
	-- Debug

	-- Supprime l'ancienne UI si elle existe
	if screenGui then
		screenGui:Destroy()
	end

	-- Créer une nouvelle UI
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CustomUI"
	screenGui.Parent = player:WaitForChild("PlayerGui")
	screenGui.Enabled = false
	ToggleGui = Instance.new("ScreenGui")
	ToggleGui.Name = "CustomUI"
	ToggleGui.Parent = player:WaitForChild("PlayerGui")
	ToggleGui.Enabled = true

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
		button.BackgroundTransparency = 0.5
		button.ZIndex = 10

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = button

		return button
	end

	-- 🔘 Recréer les boutons
	local infJumpButton = createStyledButton(screenGui, "Inf Jump", UDim2.new(0, 10, 0, 10), Color3.fromRGB(30, 30, 30))
	local flyButton = createStyledButton(screenGui, "Fly", UDim2.new(0, 10, 0, 60), Color3.fromRGB(255, 215, 0))
	local noClipButton = createStyledButton(screenGui, "No-Clip", UDim2.new(0, 10, 0, 110), Color3.fromRGB(255, 0, 0))
	local godModeButton = createStyledButton(screenGui, "God Mode", UDim2.new(0, 10, 0, 160), Color3.fromRGB(128, 0, 128))
	local espButton = createStyledButton(screenGui, "ESP", UDim2.new(0, 10, 0, 210), Color3.fromRGB(85, 170, 0))


	



	-- 🏆 Inf Jump Toggle
	local infJumpEnabled = false
	infJumpButton.MouseButton1Click:Connect(function()
		infJumpEnabled = not infJumpEnabled
		infJumpButton.Text = infJumpEnabled and "Inf Jump: ON" or "Inf Jump"
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
		flyButton.Text = flying and "Fly: ON" or "Fly" 
		flyButton.BackgroundColor3 = flying and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(255, 215, 0)
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
		noClipButton.Text = noClipEnabled and "No-Clip: ON" or "No-Clip"
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
		godModeButton.Text = godModeEnabled and "God Mode: ON" or "God Mode"
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
	local espEnabled = false
	local Players = game:GetService("Players")

	-- Fonction pour ajouter un effet de surbrillance au personnage d'un joueur
	local function highlightPlayer(player)
		if player.Character then
			if not player.Character:FindFirstChild("Highlight") then
				local highlight = Instance.new("Highlight")
				highlight.Parent = player.Character
				highlight.FillColor = Color3.fromRGB(255, 255, 0)  -- Jaune
				highlight.OutlineColor = Color3.fromRGB(0, 0, 0)   -- Noir
				highlight.FillTransparency = 0.5                   -- Semi-transparent
				highlight.OutlineTransparency = 0                  -- Contour solide
			end
		end
	end

	-- Fonction pour supprimer l'effet de surbrillance du personnage d'un joueur
	local function unhighlightPlayer(player)
		if player.Character then
			local highlight = player.Character:FindFirstChild("Highlight")
			if highlight then
				highlight:Destroy()
			end
		end
	end

	-- Fonction pour activer/désactiver l'ESP
	local function toggleESP()
		espEnabled = not espEnabled

		if espEnabled then
			-- Activer l'ESP : Ajouter des surbrillances à tous les joueurs
			for _, player in ipairs(Players:GetPlayers()) do
				highlightPlayer(player)

				-- Écouter l'événement CharacterAdded pour les respawns
				player.CharacterAdded:Connect(function()
					highlightPlayer(player)
				end)

				-- Écouter l'événement CharacterRemoving pour la mort
				player.CharacterRemoving:Connect(function()
					unhighlightPlayer(player)
				end)
			end

			-- Connecter l'événement pour les nouveaux joueurs
			Players.PlayerAdded:Connect(function(player)
				highlightPlayer(player)

				-- Écouter l'événement CharacterAdded pour les respawns
				player.CharacterAdded:Connect(function()
					highlightPlayer(player)
				end)

				-- Écouter l'événement CharacterRemoving pour la mort
				player.CharacterRemoving:Connect(function()
					unhighlightPlayer(player)
				end)
			end)
		else
			-- Désactiver l'ESP : Supprimer les surbrillances de tous les joueurs
			for _, player in ipairs(Players:GetPlayers()) do
				unhighlightPlayer(player)
			end
		end
	end

	-- Mettre à jour le texte du bouton ESP
	local function updateESPButton()
		espButton.Text = espEnabled and "ESP: ON" or "ESP"
		espButton.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(85, 170, 0)
	end

	-- Connecter le bouton ESP pour activer/désactiver l'ESP
	espButton.MouseButton1Click:Connect(function()
		toggleESP()
		updateESPButton()
	end)

	local Toggle = Instance.new("TextLabel")
	Toggle.TextSize = 24
	Toggle.Text = "Ctrl to toggle"
	Toggle.Position = UDim2.new(0.41, 0,0, 0)
	Toggle.TextColor3 = Color3.fromRGB(255,255,255)
	Toggle.BackgroundTransparency = 1
	Toggle.Parent = ToggleGui
	Toggle.Size = UDim2.new(0, 180, 0, 40)
	wait(5)
	Toggle.TextTransparency = 0.1
	wait(0.1)
	Toggle.TextTransparency = 0.3
	wait(0.1)
	Toggle.TextTransparency = 0.5
	wait(0.1)
	Toggle.TextTransparency = 0.7
	wait(0.1)
	Toggle.TextTransparency = 0.9
	Toggle:Destroy()

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
	if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl or  input.KeyCode == Enum.KeyCode.RightControl then
		screenGui.Enabled = not screenGui.Enabled
		print("🎭 UI Toggle: " .. tostring(screenGui.Enabled)) -- Debug
	end
end)

-- 🏁 **Démarrage Initial**
recreateUI()

