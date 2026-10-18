local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ===== CONFIGURACIÓN ULTRA-RÁPIDA (SIN REBOTES) =====
local TOGGLE_KEY = Enum.KeyCode.H
local REST_TIME = 0.05         -- Velocidad extrema
local TRAVEL_DELAY = 0         -- Sin esperas entre vuelos
local TRAVEL_SPEED = 24        
local HOVER_HEIGHT = 0         -- Vuela DIRECTO a la moneda, impacto instantáneo
local DROP_TIME = 0            -- Sin tiempo de caída
local SAFE_DISTANCE = 40   
local AVOID_PLAYERS = false    
local SKIP_SECONDS = 3         -- Ignora la posición visitada durante 3 segundos
local REQUIRE_VISIBLE = false 
local MAX_FARM_DISTANCE = 1500 

-- ===== THEME =====
local BG = Color3.fromRGB(24, 24, 30)
local PANEL = Color3.fromRGB(38, 38, 48)
local TEXT = Color3.fromRGB(235, 235, 240)
local SUBTEXT = Color3.fromRGB(200, 200, 220) 
local GREEN = Color3.fromRGB(70, 190, 110)
local RED = Color3.fromRGB(200, 70, 70)

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "SmartTpGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 0)
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.Position = UDim2.new(0, 20, 0.35, 0)
frame.BackgroundColor3 = BG
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(60, 60, 75)
stroke.Thickness = 1
Instance.new("UIListLayout", frame).SortOrder = Enum.SortOrder.LayoutOrder

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundTransparency = 1
header.LayoutOrder = 1
header.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "InstaFarm v7"
title.TextColor3 = TEXT
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -34, 0, 5)
minBtn.BackgroundColor3 = PANEL
minBtn.Text = "–"
minBtn.TextColor3 = TEXT
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.Parent = header
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 0, 0)
body.AutomaticSize = Enum.AutomaticSize.Y
body.BackgroundTransparency = 1
body.LayoutOrder = 2
body.Parent = frame

local pad = Instance.new("UIPadding", body)
pad.PaddingLeft = UDim.new(0, 12)
pad.PaddingRight = UDim.new(0, 12)
pad.PaddingBottom = UDim.new(0, 12)

local list = Instance.new("UIListLayout", body)
list.Padding = UDim.new(0, 8)
list.SortOrder = Enum.SortOrder.LayoutOrder

minBtn.MouseButton1Click:Connect(function()
	body.Visible = not body.Visible
	minBtn.Text = body.Visible and "–" or "+"
end)

local order = 0
local function nextOrder()
	order += 1
	return order
end

local function makeButton(text, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 34)
	b.BackgroundColor3 = color
	b.Text = text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 13
	b.AutoButtonColor = true
	b.LayoutOrder = nextOrder()
	b.Parent = body
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	return b
end

local function makeRow(label, default)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 28)
	row.BackgroundTransparency = 1
	row.LayoutOrder = nextOrder()
	row.Parent = body

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -70, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = label
	lbl.TextColor3 = SUBTEXT
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0, 62, 1, 0)
	box.Position = UDim2.new(1, -62, 0, 0)
	box.BackgroundColor3 = PANEL
	box.Text = tostring(default)
	box.TextColor3 = TEXT
	box.Font = Enum.Font.GothamMedium
	box.TextSize = 12
	box.ClearTextOnFocus = false
	box.Parent = row
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
	return box
end

local mainBtn = makeButton("Auto Farm: OFF  [H]", RED)
local avoidBtn = makeButton("Avoid players: OFF", PANEL)
local safeBox = makeRow("Safe distance", SAFE_DISTANCE)
local restBox = makeRow("Rest at target", REST_TIME)
local travelBox = makeRow("Delay before TP", TRAVEL_DELAY)
local speedBox = makeRow("Fly speed", TRAVEL_SPEED)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 34)
status.BackgroundColor3 = PANEL
status.BackgroundTransparency = 0.4
status.Text = "Idle"
status.TextColor3 = SUBTEXT
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextWrapped = true
status.LayoutOrder = nextOrder()
status.Parent = body
Instance.new("UICorner", status).CornerRadius = UDim.new(0, 6)

local function bindNumber(box, get, set, minValue)
	box.FocusLost:Connect(function()
		local n = tonumber(box.Text)
		if n then set(math.max(minValue, n)) end
		box.Text = tostring(get())
	end)
end
bindNumber(safeBox, function() return SAFE_DISTANCE end, function(v) SAFE_DISTANCE = v end, 0)
bindNumber(restBox, function() return REST_TIME end, function(v) REST_TIME = v end, 0)
bindNumber(travelBox, function() return TRAVEL_DELAY end, function(v) TRAVEL_DELAY = v end, 0)
bindNumber(speedBox, function() return TRAVEL_SPEED end, function(v) TRAVEL_SPEED = v end, 1)

local function refreshAvoid()
	avoidBtn.Text = "Avoid players: " .. (AVOID_PLAYERS and "ON" or "OFF")
	avoidBtn.BackgroundColor3 = AVOID_PLAYERS and Color3.fromRGB(150, 80, 20) or PANEL
end
avoidBtn.MouseButton1Click:Connect(function()
	AVOID_PLAYERS = not AVOID_PLAYERS
	refreshAvoid()
end)
refreshAvoid()

-- ===== Helpers =====
local enabled = false
local visited = 0
local skipUntilObj = setmetatable({}, { __mode = "k" })
local skippedPositions = {} -- NUEVO: Evita volver a la misma coordenada espacial
local containerCache

local function findContainer()
	if containerCache and containerCache.Parent then
		return containerCache
	end
	for _, obj in workspace:GetDescendants() do
		local lowerName = string.lower(obj.Name)
		if string.find(lowerName, "coin") or string.find(lowerName, "cand") then
			if obj:IsA("BasePart") or obj:IsA("Model") then
				containerCache = obj.Parent
				return containerCache
			end
		end
	end
	return nil
end

local function getTargetPart(target)
	for _, desc in target:GetDescendants() do
		if desc:IsA("TouchInterest") then
			return desc.Parent
		end
	end
	if target:IsA("BasePart") then
		return target
	elseif target:IsA("Model") then
		return target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)
	end
end

local function isTargetVisible(part)
	if not part or not part:IsDescendantOf(workspace) then return false end
	if REQUIRE_VISIBLE and part.Transparency >= 1 then return false end
	return true
end

local function getRoot()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return nil end
	return char:FindFirstChild("HumanoidRootPart")
end

local function touchingLobby(root)
	if not root then return false end
	for _, obj in workspace:GetDescendants() do
		if obj:IsA("SpawnLocation") then
			if (root.Position - obj.Position).Magnitude < 150 then
				return true
			end
		end
	end
	
	local rayOrigin = root.Position
	local rayDirection = Vector3.new(0, -15, 0) 
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {player.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	if result and result.Instance then
		local current = result.Instance
		while current and current ~= workspace do
			local name = string.lower(current.Name)
			if string.find(name, "lobby") or string.find(name, "spawn") then
				return true
			end
			current = current.Parent
		end
	end
	return false
end

local function playerNear(position)
	if not AVOID_PLAYERS then return false end
	for _, other in Players:GetPlayers() do
		if other ~= player then
			local char = other.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp and (hrp.Position - position).Magnitude < SAFE_DISTANCE then
				return true
			end
		end
	end
	return false
end

local function collectTargets(container)
	local result = {}
	local visibleCount = 0
	local now = os.clock()
	
	for _, obj in container:GetDescendants() do 
		local lowerName = string.lower(obj.Name)
		if string.find(lowerName, "coin") or string.find(lowerName, "cand") then
			local part = getTargetPart(obj)
			if part and isTargetVisible(part) then
				visibleCount += 1
				
				-- 1. Ignorar si el objeto ya se visitó
				if skipUntilObj[obj] and skipUntilObj[obj] > now then continue end
				
				-- 2. NUEVO: Ignorar si ESTA POSICIÓN ESPACIAL se visitó hace poco
				local posIsSkipped = false
				for sp, exp in pairs(skippedPositions) do
					if now > exp then
						skippedPositions[sp] = nil -- Limpiar posiciones expiradas
					elseif (part.Position - sp).Magnitude < 3 then
						posIsSkipped = true
						break
					end
				end
				
				if posIsSkipped then continue end
				
				-- 3. Ignorar por jugadores
				if playerNear(part.Position) then continue end
				
				table.insert(result, { target = obj, part = part })
			end
		end
	end
	return result, visibleCount
end

local function touch(root, part)
	if firetouchinterest then
		pcall(function()
			firetouchinterest(root, part, 0)
			firetouchinterest(root, part, 1)
		end)
	end
end

local function glideAbove(root, part)
	local targetPos = part.CFrame + Vector3.new(0, HOVER_HEIGHT, 0)
	local distance = (targetPos.Position - root.Position).Magnitude
	local duration = math.max(distance / TRAVEL_SPEED, 0.05)

	root.AssemblyLinearVelocity = Vector3.zero
	root.Anchored = true

	local tween = TweenService:Create(
		root,
		TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{ CFrame = targetPos }
	)
	tween:Play()

	task.spawn(function()
		while tween.PlaybackState == Enum.PlaybackState.Playing do
			if not enabled or not isTargetVisible(part) or touchingLobby(root) then
				tween:Cancel()
				break
			end
			task.wait(0.05)
		end
	end)

	tween.Completed:Wait()
	root.Anchored = false
end

-- ===== Main loop =====
local function loop()
	while enabled do
		local root = getRoot()
		if not root then
			status.Text = "Waiting for character..."
			task.wait(0.5)
			continue
		end

		if touchingLobby(root) then
			status.Text = ("Waiting in lobby zone | Visited: %d"):format(visited)
			task.wait(0.5)
			continue
		end

		local container = findContainer()
		if not container then
			status.Text = "Waiting for round (No targets)"
			task.wait(1)
			continue
		end

		local targets, visibleCount = collectTargets(container)

		if visibleCount == 0 or #targets == 0 then
			status.Text = ("No targets left / skipped | Visited: %d"):format(visited)
			task.wait(0.2)
			continue
		end

		local pos = root.Position
		local best, bestDist
		for _, entry in targets do
			local d = (entry.part.Position - pos).Magnitude
			if not bestDist or d < bestDist then
				best, bestDist = entry, d
			end
		end
		local entry = best

		if bestDist > MAX_FARM_DISTANCE then
			status.Text = ("In Lobby (Map too far) | Visited: %d"):format(visited)
			task.wait(1)
			continue
		end

		-- REGISTRAMOS EL TARGET INMEDIATAMENTE ANTES DE VOLAR PARA EVITAR REPETICIÓN
		skipUntilObj[entry.target] = os.clock() + SKIP_SECONDS
		skippedPositions[entry.part.Position] = os.clock() + SKIP_SECONDS

		if TRAVEL_DELAY > 0 then task.wait(TRAVEL_DELAY) end

		root = getRoot()
		if not enabled or not root or touchingLobby(root) then continue end

		status.Text = ("Zipping... %d studs"):format(math.floor(bestDist))
		glideAbove(root, entry.part) 

		if not enabled or touchingLobby(root) then continue end
		
		touch(root, entry.part) 
		visited += 1

		if REST_TIME > 0 then task.wait(REST_TIME) end
	end
	status.Text = ("Idle | Visited: %d"):format(visited)
end

local function setEnabled(state)
	enabled = state
	mainBtn.Text = "Auto Farm: " .. (enabled and "ON" or "OFF") .. "  [H]"
	mainBtn.BackgroundColor3 = enabled and GREEN or RED
	if enabled then
		task.spawn(loop)
	else
		local root = getRoot()
		if root then root.Anchored = false end
	end
end

mainBtn.MouseButton1Click:Connect(function()
	setEnabled(not enabled)
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == TOGGLE_KEY then
		setEnabled(not enabled)
	end
end)
