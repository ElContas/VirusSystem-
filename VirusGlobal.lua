--// VirusGlobal.lua
--// Sistema global para Map y Player
--// Compatible con Xeno / CouRoblox
--// Por seguridad, solo client-side visual, no altera servidores públicos

local Global = {}
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- VARIABLES GLOBALES
local selectionMode = false
local selectedParts = {}
local category = nil
local highlights = {}
local lines = {}
local billboards = {}

-- UTILIDADES
local function createHighlight(part, color)
	local hl = Instance.new("Highlight")
	hl.Parent = part
	hl.FillColor = color
	hl.OutlineColor = color
	hl.Adornee = part
	table.insert(highlights, hl)
	return hl
end

local function createBillboard(part, text)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 200, 0, 50)
	bb.AlwaysOnTop = true
	bb.Parent = part
	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.new(1, 0, 1, 0)
	tl.BackgroundTransparency = 1
	tl.Text = text
	tl.TextColor3 = Color3.new(1,1,1)
	tl.TextStrokeTransparency = 0
	tl.Font = Enum.Font.GothamBold
	tl.TextScaled = true
	tl.Parent = bb
	table.insert(billboards, bb)
	return bb
end

local function clearVisuals()
	for _, h in pairs(highlights) do h:Destroy() end
	for _, b in pairs(billboards) do b:Destroy() end
	for _, l in pairs(lines) do l:Destroy() end
	highlights, billboards, lines = {}, {}, {}
end

-- MATERIAL / COLOR / TRANSPARENCIA / SIZE / POSITION / DELETE
function Global.StartMaterialEditor()
	selectionMode = true
	print("[VirusGlobal] Selección de Material iniciada.")
	UIS.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.LeftControl then
			-- multi selección
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			local target = Mouse.Target
			if target and target:IsA("BasePart") then
				createHighlight(target, Color3.fromRGB(0, 255, 0))
				table.insert(selectedParts, target)
				print("Seleccionado:", target.Name)
			end
		end
	end)
end

function Global.ApplyMaterial(mat)
	for _, p in pairs(selectedParts) do
		p.Material = Enum.Material[mat] or Enum.Material.Plastic
	end
	print("[VirusGlobal] Material aplicado:", mat)
end

function Global.ApplyColor(color)
	for _, p in pairs(selectedParts) do
		p.Color = color
	end
	print("[VirusGlobal] Color aplicado:", color)
end

function Global.ApplyTransparency(val)
	for _, p in pairs(selectedParts) do
		p.Transparency = val
	end
	print("[VirusGlobal] Transparencia aplicada:", val)
end

function Global.ApplyPosition(newPos)
	for _, p in pairs(selectedParts) do
		p.Position = newPos
	end
	print("[VirusGlobal] Posición aplicada:", tostring(newPos))
end

function Global.ApplySize(size)
	for _, p in pairs(selectedParts) do
		p.Size = size
	end
	print("[VirusGlobal] Tamaño aplicado:", tostring(size))
end

function Global.DeleteParts()
	for _, p in pairs(selectedParts) do
		p:Destroy()
	end
	selectedParts = {}
	print("[VirusGlobal] Partes eliminadas.")
end

-- ITEM DETECTION Y TELEPORT
local categories = {
	["WorkBench/Fire"] = {
		"Washing Machine", "Oil Barrel", "Geom of the Forest Fragment", "Cultist Prototype", "Cultist Experiment",
		"Cultis Gem", "Tyre", "Sheet Metal", "Broken Fan", "Fuel Canister", "Old Radio", "Coal", "Wood", "Sapling",
		"Chair", "Bolt", "Broken Microwave", "Old Car Engine"
	},
	["Tools"] = {
		"Thorn Body Armor", "Riot Shield", "Tactical Shotgun", "Morningstar", "Kunai", "Strong Axe", "Strong Flashlight",
		"MedKit", "Chainsaw", "Giant Sack", "Good Sack", "Snowball", "Ice Axe", "Bandage", "Rifle Ammo", "Rifle", "Revolver",
		"Good Axe", "Halloween Candle", "Revolver Ammo", "Old Taming Flute", "Old Flashlight", "Spear"
	},
	["Food"] = {
		"Stew", "Cooked Ribs", "Ribs", "Cooked Morsel", "Cooked Steak", "Pumpkin", "Morsel", "Carrot", "Berry", "Steak"
	},
	["Extra"] = {
		"Defense Blueprint", "Mamooth Tuck", "Artic Fox Pelt", "Bear Pelt", "Coin Stack", "Kraken Kid", "Item Chest3",
		"Seed Box", "Leather Body", "Cultist", "Wolf Pelt", "Bunny Foot", "Polar Bear Pelt", "Alpha Wolf Pelt"
	}
}

function Global.StartItemDetection(cat)
	clearVisuals()
	category = cat
	local items = workspace:FindFirstChild("Items")
	if not items then
		warn("No se encontró carpeta Items en workspace")
		return
	end

	for _, obj in pairs(items:GetChildren()) do
		for _, name in pairs(categories[cat] or {}) do
			if string.find(string.lower(obj.Name), string.lower(name)) then
				local color = Color3.fromRGB(0, 170, 255)
				createHighlight(obj.PrimaryPart or obj, color)
				createBillboard(obj.PrimaryPart or obj, obj.Name .. "\n" .. tostring(obj.PrimaryPart.Position))
			end
		end
	end
	print("[VirusGlobal] Detección completada para categoría:", cat)
end

function Global.TeleportToRandom(cat)
	local items = workspace:FindFirstChild("Items")
	if not items then return end
	local found = {}
	for _, obj in pairs(items:GetChildren()) do
		for _, name in pairs(categories[cat] or {}) do
			if string.find(string.lower(obj.Name), string.lower(name)) then
				table.insert(found, obj)
			end
		end
	end
	if #found > 0 then
		local randomItem = found[math.random(1, #found)]
		local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
		if hrp and randomItem.PrimaryPart then
			hrp.CFrame = randomItem.PrimaryPart.CFrame + Vector3.new(0, 5, 0)
			print("[VirusGlobal] Teleport a:", randomItem.Name)
		end
	else
		warn("[VirusGlobal] No se encontraron ítems de esa categoría.")
	end
end

-- RESET VISUALS
function Global.ClearAll()
	clearVisuals()
	selectedParts = {}
	print("[VirusGlobal] Visuales limpiados.")
end

return Global
