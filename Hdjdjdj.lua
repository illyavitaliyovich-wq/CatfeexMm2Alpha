local UserInputService, CurrentCamera, n1, n2, u13, n3, u15, u16, u17, v18, v25, u29, u31, u32, u61, u62, t3, t4, v68, v78, u120, n17, u126, u127, u128, v145, u147, u148, u149, u150, u151, u156, u172, u173, u174, u175, u176, u177, u178, v183, u184, u185, u186, u187, u188, u189, u198, u199, id, u201, u202, u205, u206, u207, u208, u209, u210, u211, u212, v232, v239, v244, u252, u257, u263, u270, u276, u281, u287, u293, v301, v302, farmSet, farmKillAll, farmKillMurdererSet

do
    local u9, u10, u99, u105, u110, u116, u157
    local Players = game:GetService('Players')
    local Workspace, RunService, LocalPlayer, u129, u130, u131, u162, u163, u164, u165, u166, u167, u168, u169, t25, v220, uDim2, t26

    do
        local u98, u104, u222
        local v125, uDim2_2

        do
            local u218
            local v21, v115, t17

            do
                local Lighting, TextLabel

                do
                    local ReplicatedStorage = game:GetService('ReplicatedStorage')
                    local Stats = game:GetService('Stats')

                    Workspace = game:GetService('Workspace')
                    UserInputService = game:GetService('UserInputService')
                    RunService = game:GetService('RunService')
                    Lighting = game:GetService('Lighting')
                    LocalPlayer = Players.LocalPlayer
                    CurrentCamera = Workspace.CurrentCamera
                    u9 = false
                    u10 = false
                    n1 = 200
                    n2 = 200
                    u13 = false
                    n3 = 70
                    u15 = false
                    u16 = false
                    u17 = true
                    v18 = loadstring(game:HttpGet('https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua'))()

                    v18:SetTheme('Crimson')

                    local YELLOW = Color3.fromRGB(255, 210, 0)
                    local YELLOW_DARK = Color3.fromRGB(200, 150, 0)

                    local farmOn = false
                    local farmBusy = false
                    local farmBagFull = false
                    local farmSPEED = 31
                    local farmSTOP_DIST = 2.5
                    local farmMAX_COINS = 40
                    local farmJUMP_HEIGHT = 7.2
                    local farmJUMPS_UP = 100
                    local farmOFFSET_Y = farmJUMP_HEIGHT * farmJUMPS_UP
                    local farmCoinList = {}
                    local farmLastScan = 0
                    local farmLastCoin = nil
                    local farmIgnored = {}
                    local farmSkyPlat = nil
                    local farmGrabGunOn = false
                    local farmAutoShootConn = nil
                    local farmLastShoot = 0
                    local farmLeadMul = 1.25
                    local farmAUTO_SHOOT_INTERVAL = 2.9
                    local farmINFINITE_INTERVAL = 0.05
                    local farmWallbangOn = false
                    local farmStatus = nil
                    -- Радиус: дальше — монеты игнорируются полностью
                    local farmMAX_FARM_DIST = 200
                    -- Порог "близкой" монеты: ближе — TP + noclip, дальше — плавный полёт без noclip
                    local farmNEAR_DIST = 100

                    local function f_getRoot() local c = LocalPlayer.Character return c and c:FindFirstChild('HumanoidRootPart') end
                    local function f_getHead() local c = LocalPlayer.Character return c and c:FindFirstChild('Head') end
                    local function f_getHum() local c = LocalPlayer.Character return c and c:FindFirstChildOfClass('Humanoid') end
                    local function f_setNoclip(on)
                        local char = LocalPlayer.Character
                        if not char then return end
                        for _, p in ipairs(char:GetChildren()) do
                            if p:IsA('BasePart') then p.CanCollide = not on
                            elseif p:IsA('Accessory') then
                                local h = p:FindFirstChild('Handle')
                                if h then h.CanCollide = not on end
                            end
                        end
                    end
                    local function f_hardStop(root)
                        if not root then return end
                        root.AssemblyLinearVelocity = Vector3.zero
                        root.AssemblyAngularVelocity = Vector3.zero
                    end
                    local function f_restore()
                        local hum = f_getHum()
                        if hum then hum.PlatformStand = false hum.AutoRotate = true end
                        f_setNoclip(false)
                        local r = f_getRoot() if r then f_hardStop(r) end
                    end
                    local function f_isLobby()
                        local root = f_getRoot()
                        local char = LocalPlayer.Character
                        local lobby = Workspace:FindFirstChild('Lobby') or Workspace:FindFirstChild('RegularLobby')
                        if lobby and char and char:IsDescendantOf(lobby) then return true end
                        if lobby and root then
                            for _, d in ipairs(lobby:GetDescendants()) do
                                if d:IsA('BasePart') then
                                    if (d.Position - root.Position).Magnitude < 80 then
                                        if not Workspace:FindFirstChild('CoinContainer', true) then return true end
                                    end
                                    break
                                end
                            end
                        end
                        local coinBox = Workspace:FindFirstChild('CoinContainer', true)
                        local map = Workspace:FindFirstChild('Map')
                        if not coinBox and not map and lobby then return true end
                        return false
                    end
                    local function f_rootPosForHead(coinPos)
                        local r = f_getRoot() local h = f_getHead()
                        if not r then return coinPos + Vector3.new(0, 2, 0) end
                        if not h then return coinPos + Vector3.new(0, 1.5, 0) end
                        return coinPos - (h.Position - r.Position)
                    end
                    local function f_nameHasCoin(n)
                        n = string.lower(tostring(n or ''))
                        return string.find(n, 'coin', 1, true) or string.find(n, 'bag', 1, true) or string.find(n, 'currency', 1, true)
                    end
                    local function f_getCoinCount()
                        local best = 0
                        local pg = LocalPlayer:FindFirstChild('PlayerGui')
                        pcall(function()
                            if not pg then return end
                            local main = pg:FindFirstChild('MainGUI')
                            local src = main or pg
                            for _, d in ipairs(src:GetDescendants()) do
                                if d:IsA('TextLabel') or d:IsA('TextBox') then
                                    local v = tonumber(d.Text)
                                    if v and v >= 0 and v <= 40 then
                                        local p = d.Parent
                                        for _ = 1, 8 do
                                            if not p then break end
                                            if f_nameHasCoin(p.Name) then
                                                if v > best then best = v end
                                                break
                                            end
                                            p = p.Parent
                                        end
                                    end
                                end
                            end
                        end)
                        return best
                    end
                    local function f_playerHasTool(plr, name)
                        if not plr then return false end
                        local c = plr.Character
                        local bp = plr:FindFirstChild('Backpack')
                        if c and c:FindFirstChild(name) then return true end
                        if bp and bp:FindFirstChild(name) then return true end
                        return false
                    end
                    local function f_myRole()
                        if f_playerHasTool(LocalPlayer, 'Knife') then return 'Murderer' end
                        if f_playerHasTool(LocalPlayer, 'Gun') then return 'Sheriff' end
                        return 'Innocent'
                    end
                    local function f_iAmGunner()
                        local hasGun = f_playerHasTool(LocalPlayer, 'Gun')
                        local hasKnife = f_playerHasTool(LocalPlayer, 'Knife')
                        return hasGun and not hasKnife
                    end
                    local function f_getPing()
                        local ping = 50
                        pcall(function() ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue() end)
                        return ping
                    end
                    local function f_equipGun()
                        local c = LocalPlayer.Character
                        local bp = LocalPlayer:FindFirstChild('Backpack')
                        if c and c:FindFirstChild('Gun') then return c.Gun end
                        if bp and bp:FindFirstChild('Gun') and c then bp.Gun.Parent = c return c:FindFirstChild('Gun') end
                        return nil
                    end
                    local function f_unequipGun()
                        local c = LocalPlayer.Character
                        local bp = LocalPlayer:FindFirstChild('Backpack')
                        if not c or not bp then return end
                        local g = c:FindFirstChild('Gun')
                        if g then pcall(function() g.Parent = bp end) end
                    end
                    local function f_equipKnife()
                        local c = LocalPlayer.Character
                        local bp = LocalPlayer:FindFirstChild('Backpack')
                        if c and c:FindFirstChild('Knife') then return c.Knife end
                        if bp and bp:FindFirstChild('Knife') and c then bp.Knife.Parent = c return c:FindFirstChild('Knife') end
                        return nil
                    end
                    local function f_findMurderer()
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character then
                                local h = plr.Character:FindFirstChildOfClass('Humanoid')
                                local bp = plr:FindFirstChild('Backpack')
                                local hasK = plr.Character:FindFirstChild('Knife') ~= nil
                                local hasKbp = bp and bp:FindFirstChild('Knife') ~= nil
                                if h and h.Health > 0 and (hasK or hasKbp) then return plr end
                            end
                        end
                        return nil
                    end
                    local function f_canSee(char)
                        if not char then return false end
                        local head = char:FindFirstChild('Head') or char:FindFirstChild('HumanoidRootPart')
                        if not head then return false end
                        local cam = Workspace.CurrentCamera
                        if not cam then return false end
                        local origin = cam.CFrame.Position
                        local dir = head.Position - origin
                        local dist = dir.Magnitude
                        if dist < 1 then return true end
                        local params = RaycastParams.new()
                        params.FilterType = Enum.RaycastFilterType.Exclude
                        params.FilterDescendantsInstances = { LocalPlayer.Character }
                        params.IgnoreWater = true
                        local hit = Workspace:Raycast(origin, dir.Unit * dist, params)
                        if not hit then return true end
                        return hit.Instance:IsDescendantOf(char)
                    end
                    local function f_shootAt(char)
                        local gun = f_equipGun()
                        if not gun or not char then return false end
                        local thrp = char:FindFirstChild('HumanoidRootPart')
                        local torso = char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
                        local myRoot = f_getRoot()
                        if not thrp or not torso or not myRoot then return false end
                        local lead = (f_getPing() / 1000) * farmLeadMul
                        local vel = thrp.AssemblyLinearVelocity
                        local aim = torso.Position
                        if vel.Magnitude >= 1 then aim = torso.Position + (vel * lead) end
                        local lookCF = CFrame.new(myRoot.Position, aim)
                        local hitCF = CFrame.new(aim)
                        local ev = gun:FindFirstChild('ShootEvent') or gun:FindFirstChild('Shoot')
                        if ev then pcall(function() ev:FireServer(lookCF, hitCF) end) return true end
                        return false
                    end
                    local function f_killMurdererShoot()
                        local m = f_findMurderer()
                        if not m or not m.Character then return false end
                        local gun = f_equipGun()
                        if not gun then return false end
                        local thrp = m.Character:FindFirstChild('HumanoidRootPart')
                        if not thrp then return false end
                        local ev = gun:FindFirstChild('Shoot') or gun:FindFirstChild('ShootEvent')
                        if not ev then return false end
                        local myHRP = f_getRoot()
                        if not myHRP then return false end
                        local savedCF = myHRP.CFrame
                        local away = myHRP.Position - thrp.Position
                        if away.Magnitude > 0.1 then
                            local backPos = myHRP.Position + away.Unit * 5
                            myHRP.CFrame = CFrame.new(backPos, thrp.Position)
                        end
                        pcall(function()
                            ev:FireServer(thrp.CFrame * CFrame.new(0, 0, 2), thrp.CFrame)
                        end)
                        myHRP.CFrame = savedCF
                        pcall(function()
                            myHRP.AssemblyLinearVelocity = Vector3.zero
                            myHRP.AssemblyAngularVelocity = Vector3.zero
                        end)
                        f_unequipGun()
                        return true
                    end
                    local function f_murdererKillAll()
                        local r = f_getRoot()
                        if not r then return end
                        local knife = f_equipKnife()
                        if not knife then return end
                        local targets = {}
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character then
                                local h = plr.Character:FindFirstChildOfClass('Humanoid')
                                local hrp = plr.Character:FindFirstChild('HumanoidRootPart')
                                if h and h.Health > 0 and hrp then
                                    table.insert(targets, {plr = plr, hrp = hrp, hum = h, savedCF = hrp.CFrame})
                                end
                            end
                        end
                        if #targets == 0 then
                            if farmStatus then farmStatus:SetDesc('KILL ALL: нет целей') end
                            return
                        end
                        local baseCF = r.CFrame
                        local fwd = baseCF.LookVector
                        local singlePos = baseCF.Position + fwd * 3
                        local singleCF = CFrame.new(singlePos, singlePos + fwd)
                        for _, t in ipairs(targets) do
                            if t.hrp and t.hrp.Parent then
                                pcall(function()
                                    t.hrp.CFrame = singleCF
                                    t.hrp.AssemblyLinearVelocity = Vector3.zero
                                    t.hrp.AssemblyAngularVelocity = Vector3.zero
                                end)
                            end
                        end
                        if farmStatus then farmStatus:SetDesc('KILL ALL: ' .. #targets .. ' в одной точке') end
                        local t0 = tick()
                        while tick() - t0 < 3 do
                            for _, t in ipairs(targets) do
                                if t.hrp and t.hrp.Parent and t.hum and t.hum.Health > 0 then
                                    pcall(function()
                                        t.hrp.CFrame = singleCF
                                        t.hrp.AssemblyLinearVelocity = Vector3.zero
                                        t.hrp.AssemblyAngularVelocity = Vector3.zero
                                    end)
                                end
                            end
                            knife = f_equipKnife()
                            task.wait(0.05)
                        end
                        for _, t in ipairs(targets) do
                            if t.hrp and t.hrp.Parent and t.hum and t.hum.Health > 0 then
                                pcall(function()
                                    t.hrp.CFrame = t.savedCF
                                    t.hrp.AssemblyLinearVelocity = Vector3.zero
                                    t.hrp.AssemblyAngularVelocity = Vector3.zero
                                end)
                            end
                        end
                        if farmStatus then farmStatus:SetDesc('KILL ALL: done (' .. #targets .. ')') end
                    end

                    farmKillAll = function()
                        task.spawn(function()
                            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild('HumanoidRootPart') then
                                if farmStatus then farmStatus:SetDesc('Kill All: char not ready') end
                                return
                            end
                            if not f_playerHasTool(LocalPlayer, 'Knife') then
                                if farmStatus then farmStatus:SetDesc('Kill All: no Knife (not Murderer)') end
                                return
                            end
                            if farmStatus then farmStatus:SetDesc('KILL ALL: started...') end
                            f_murdererKillAll()
                        end)
                    end

                    local function f_clearSky() if farmSkyPlat then pcall(function() farmSkyPlat:Destroy() end) farmSkyPlat = nil end end
                    local function f_goSky()
                        local r = f_getRoot()
                        if not r then return end
                        local up = r.Position + Vector3.new(0, farmOFFSET_Y, 0)
                        r.CFrame = CFrame.new(up)
                        f_hardStop(r)
                        f_clearSky()
                        farmSkyPlat = Instance.new('Part')
                        farmSkyPlat.Size = Vector3.new(20, 1, 20)
                        farmSkyPlat.Anchored = true
                        farmSkyPlat.CanCollide = true
                        farmSkyPlat.Transparency = 0.4
                        farmSkyPlat.Color = YELLOW
                        farmSkyPlat.Material = Enum.Material.Neon
                        farmSkyPlat.Parent = Workspace
                        farmSkyPlat.CFrame = CFrame.new(up - Vector3.new(0, 3, 0))
                    end
                    local function f_isGunPart(obj) return obj and obj:IsA('BasePart') and (obj.Name == 'GunDrop' or obj.Name == 'GunPart') end
                    local function f_snapOnce(obj, root)
                        pcall(function()
                            obj.CFrame = root.CFrame * CFrame.new(0, 1.5, -1)
                            obj.AssemblyLinearVelocity = Vector3.zero
                            obj.AssemblyAngularVelocity = Vector3.zero
                        end)
                    end
                    local function f_snapGun(obj)
                        if not farmGrabGunOn then return end
                        if not f_isGunPart(obj) then return end
                        local root = f_getRoot()
                        if not root then return end
                        task.spawn(function()
                            for i = 1, 10 do
                                if not obj or not obj.Parent or not farmGrabGunOn then break end
                                local r = f_getRoot()
                                if not r then break end
                                f_snapOnce(obj, r)
                                task.wait()
                            end
                        end)
                    end
                    Workspace.DescendantAdded:Connect(function(obj)
                        if not obj:IsA('BasePart') then return end
                        f_snapGun(obj)
                    end)

                    local function f_tryPickupGun()
                        local root = f_getRoot()
                        if not root then return false end
                        if f_playerHasTool(LocalPlayer, 'Gun') then return false end
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if f_isGunPart(obj) then
                                pcall(function()
                                    obj.CFrame = root.CFrame * CFrame.new(0, 1.5, -1)
                                    obj.AssemblyLinearVelocity = Vector3.zero
                                    obj.AssemblyAngularVelocity = Vector3.zero
                                end)
                                return true
                            end
                        end
                        return false
                    end

                    local function f_doGrabGun()
                        if not farmGrabGunOn then return end
                        local root = f_getRoot()
                        if not root then return end
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if f_isGunPart(obj) then
                                task.spawn(function()
                                    for i = 1, 10 do
                                        if not obj or not obj.Parent or not farmGrabGunOn then break end
                                        local r = f_getRoot()
                                        if not r then break end
                                        f_snapOnce(obj, r)
                                        task.wait()
                                    end
                                end)
                            end
                        end
                    end
                    local function f_getCoinContainer() return Workspace:FindFirstChild('CoinContainer', true) end
                    local function f_countCoinsWorld()
                        local n = 0
                        local c = f_getCoinContainer()
                        if c then
                            for _, o in ipairs(c:GetChildren()) do
                                if o.Name == 'Coin_Server' or o.Name == 'Coin' then n = n + 1 end
                            end
                        end
                        return n
                    end
                    local function f_scanCoins()
                        local now = tick()
                        if now - farmLastScan < 1.2 and #farmCoinList > 0 then return end
                        farmLastScan = now
                        local list = {}
                        local c = f_getCoinContainer()
                        if c then
                            for _, o in ipairs(c:GetChildren()) do
                                if o.Name == 'Coin_Server' or o.Name == 'Coin' then
                                    local part = o:IsA('BasePart') and o or o:FindFirstChildWhichIsA('BasePart')
                                    if part and not farmIgnored[part] then list[#list + 1] = part end
                                end
                            end
                        end
                        farmCoinList = list
                    end

                    -- ★ Ищем монету в радиусе farmMAX_FARM_DIST. Дальние игнорируются.
                    local function f_nearestCoin(fromPos)
                        f_scanCoins()
                        local best, bestD = nil, math.huge
                        for i = #farmCoinList, 1, -1 do
                            local p = farmCoinList[i]
                            if not p or not p.Parent or farmIgnored[p] then
                                table.remove(farmCoinList, i)
                            elseif p ~= farmLastCoin then
                                local d = (p.Position - fromPos).Magnitude
                                if d <= farmMAX_FARM_DIST and d < bestD then
                                    bestD = d
                                    best = p
                                end
                            end
                        end
                        return best
                    end

                    -- ★ Логика:
                    --   Если монета БЛИЖЕ farmNEAR_DIST (100 студов) → noclip ON, мгновенный TP
                    --   Если монета ДАЛЬШЕ farmNEAR_DIST → noclip OFF, плавный полёт (старая логика)
                    local function f_flyToCoin(coin)
                        if not coin or not coin.Parent then return false end
                        local r0 = f_getRoot()
                        if not r0 then return false end
                        local dist = (coin.Position - r0.Position).Magnitude

                        -- ★ БЛИЗКАЯ МОНЕТА → TP + noclip
                        if dist <= farmNEAR_DIST then
                            f_setNoclip(true)
                            local r = f_getRoot()
                            if not r then return false end
                            local targetRoot = f_rootPosForHead(coin.Position)
                            local dir = targetRoot - r.Position
                            local look = Vector3.new(dir.X, 0, dir.Z)
                            if look.Magnitude > 0.1 then
                                r.CFrame = CFrame.new(targetRoot, targetRoot + look.Unit)
                            else
                                r.CFrame = CFrame.new(targetRoot)
                            end
                            f_hardStop(r)
                            task.wait(0.05)
                            local r2 = f_getRoot()
                            if r2 then
                                local h2 = f_getHead()
                                local hp2 = h2 and h2.Position or r2.Position
                                if (coin.Position - hp2).Magnitude <= farmSTOP_DIST + 2 then
                                    return true
                                end
                            end
                            return false
                        end

                        -- ★ ДАЛЬНЯЯ МОНЕТА → noclip OFF + плавный полёт (старая логика)
                        f_setNoclip(false)
                        local t0 = tick()
                        local lastPos, lastT = nil, 0
                        while farmOn and not farmBagFull and coin and coin.Parent and (tick() - t0) < 14 do
                            if f_isLobby() then f_restore() return false end
                            local r = f_getRoot()
                            local h = f_getHead()
                            if not r then return false end
                            local targetRoot = f_rootPosForHead(coin.Position)
                            local hp = h and h.Position or r.Position
                            if (coin.Position - hp).Magnitude <= farmSTOP_DIST then
                                r.CFrame = CFrame.new(targetRoot)
                                f_hardStop(r)
                                return true
                            end
                            local dir = targetRoot - r.Position
                            local d = dir.Magnitude
                            if d < 0.5 then
                                r.CFrame = CFrame.new(targetRoot)
                                f_hardStop(r)
                                return true
                            end
                            local now = tick()
                            local didTp = false
                            if lastPos and (now - lastT) >= 0.3 then
                                if (r.Position - lastPos).Magnitude < 0.5 then
                                    local np = r.Position + dir.Unit * 5
                                    local look = Vector3.new(dir.X, 0, dir.Z)
                                    if look.Magnitude > 0.1 then r.CFrame = CFrame.new(np, np + look.Unit) else r.CFrame = CFrame.new(np) end
                                    f_hardStop(r)
                                    didTp = true
                                end
                                lastPos = r.Position
                                lastT = now
                            elseif not lastPos then
                                lastPos = r.Position
                                lastT = now
                            end
                            if not didTp then
                                local step = math.min(farmSPEED * 0.03, d)
                                local np = r.Position + dir.Unit * step
                                local look = Vector3.new(dir.X, 0, dir.Z)
                                if look.Magnitude > 0.1 then r.CFrame = CFrame.new(np, np + look.Unit) else r.CFrame = CFrame.new(np) end
                                f_hardStop(r)
                            end
                            task.wait(0.03)
                        end
                        return false
                    end

                    local function f_stopPost()
                        farmGrabGunOn = false
                        if farmAutoShootConn then farmAutoShootConn:Disconnect() farmAutoShootConn = nil end
                        f_clearSky()
                    end
                    local function f_startAutoShoot()
                        if farmAutoShootConn then farmAutoShootConn:Disconnect() farmAutoShootConn = nil end
                        farmAutoShootConn = RunService.Heartbeat:Connect(function()
                            if not farmOn then return end
                            local interval = farmAUTO_SHOOT_INTERVAL
                            local inf = farmBagFull and f_iAmGunner()
                            if inf then interval = farmINFINITE_INTERVAL f_equipGun() end
                            if tick() - farmLastShoot < interval then return end
                            local m = f_findMurderer()
                            if not m or not m.Character then return end
                            if farmWallbangOn then
                                if f_killMurdererShoot() then farmLastShoot = tick() end
                            else
                                if not f_canSee(m.Character) then return end
                                f_equipGun()
                                if f_shootAt(m.Character) then farmLastShoot = tick() end
                            end
                        end)
                    end

                    local function f_onBagFull()
                        if farmBagFull then return end
                        farmBagFull = true
                        f_restore()
                        local role = f_myRole()
                        if role == 'Murderer' then
                            task.spawn(function()
                                while farmBagFull and farmOn do f_murdererKillAll() task.wait(0.15) end
                            end)
                            if farmStatus then farmStatus:SetDesc('40 · Murderer: KILL ALL') end
                        else
                            f_goSky()
                            farmWallbangOn = true
                            farmGrabGunOn = true
                            f_doGrabGun()
                            task.spawn(function()
                                while farmBagFull and farmOn do
                                    if not f_playerHasTool(LocalPlayer, 'Gun') then f_doGrabGun() else f_equipGun() end
                                    task.wait(0.4)
                                end
                            end)
                            f_startAutoShoot()
                            if role == 'Sheriff' then
                                if farmStatus then farmStatus:SetDesc('40 · Sheriff: sky + Kill Murderer') end
                            else
                                if farmStatus then farmStatus:SetDesc('40 · Innocent: sky + grab gun + Kill Murderer') end
                            end
                        end
                    end

                    local function f_prepareLoop()
                        farmLastCoin = nil
                        farmIgnored = {}
                        farmLastScan = 0
                        farmCoinList = {}
                        f_stopPost()
                        farmBagFull = false
                    end
                    local function f_startFarm()
                        if farmBusy then return end
                        farmBusy = true
                        task.spawn(function()
                            while farmOn do
                                f_prepareLoop()
                                f_restore()
                                if farmStatus then farmStatus:SetDesc('waiting coins...') end
                                local waited = 0
                                while farmOn do
                                    if not f_isLobby() and f_countCoinsWorld() > 0 then break end
                                    f_restore()
                                    waited = waited + 0.4
                                    task.wait(0.4)
                                    if waited > 90 then break end
                                end
                                if not farmOn then break end
                                if f_isLobby() then
                                    task.wait(0.5)
                                else
                                    local hum = f_getHum()
                                    if hum then hum.PlatformStand = true hum.AutoRotate = false end
                                    while farmOn and not farmBagFull do
                                        if f_isLobby() then f_restore() break end
                                        local cnt = f_getCoinCount()
                                        if farmStatus then farmStatus:SetDesc('coins: ' .. cnt .. '/40 · ' .. f_myRole()) end
                                        if cnt >= farmMAX_COINS then f_onBagFull() break end
                                        f_tryPickupGun()
                                        local r = f_getRoot()
                                        if not r then
                                            task.wait(0.25)
                                        else
                                            local hum2 = f_getHum()
                                            if hum2 then hum2.PlatformStand = true end
                                            local coin = f_nearestCoin(r.Position)
                                            if coin then
                                                local d = (coin.Position - r.Position).Magnitude
                                                -- Noclip включается только если монета близкая
                                                if d <= farmNEAR_DIST then
                                                    f_setNoclip(true)
                                                else
                                                    f_setNoclip(false)
                                                end
                                                if f_flyToCoin(coin) then
                                                    farmIgnored[coin] = true
                                                    farmLastCoin = coin
                                                    task.wait(0.05)
                                                end
                                            else
                                                if farmStatus then
                                                    farmStatus:SetDesc('нет монет в радиусе ' .. farmMAX_FARM_DIST .. ' · ждём')
                                                end
                                                farmLastCoin = nil
                                                f_setNoclip(false)
                                                task.wait(0.3)
                                            end
                                        end
                                        task.wait()
                                    end
                                    if farmBagFull and farmOn then
                                        f_restore()
                                        if farmStatus then farmStatus:SetDesc('wait next round...') end
                                        while farmOn and farmBagFull do
                                            if f_isLobby() then
                                                f_restore()
                                                task.wait(0.6)
                                            else
                                                if f_countCoinsWorld() > 0 and f_getCoinCount() < farmMAX_COINS then break end
                                                task.wait(0.5)
                                            end
                                        end
                                    elseif f_isLobby() then
                                        task.wait(0.3)
                                    else
                                        break
                                    end
                                end
                            end
                            f_restore()
                            farmBusy = false
                        end)
                    end
                    local function f_setFarm(on)
                        farmOn = on == true
                        if farmOn then
                            if farmStatus then farmStatus:SetDesc('FARM STARTING...') end
                            if not farmBusy then f_startFarm() end
                        else
                            f_stopPost()
                            farmBagFull = false
                            f_restore()
                            if farmStatus then farmStatus:SetDesc('FARM STOPPING...') end
                        end
                    end

                    local farmKillMurdererConn = nil
                    local function f_setKillMurderer(on)
                        if farmKillMurdererConn then farmKillMurdererConn:Disconnect() farmKillMurdererConn = nil end
                        if not on then return end
                        farmKillMurdererConn = RunService.Heartbeat:Connect(function()
                            f_killMurdererShoot()
                        end)
                    end

                    farmSet = f_setFarm
                    farmKillMurdererSet = f_setKillMurderer

                    local silentAimEnabled = false
                    local silentAimWallshot = false
                    local silentAimCooldown = 0.25
                    local silentAimLastShot = 0
                    local silentAimLastVel = {}
                    local silentAimPrediction = true

                    local function sa_getPredictedPos(part)
                        if not part or not part:IsA("BasePart") then
                            return part and part.Position or Vector3.zero
                        end
                        if not silentAimPrediction then return part.Position end
                        local myHRP = f_getRoot()
                        if not myHRP then return part.Position end
                        local humanoid = part.Parent and part.Parent:FindFirstChildOfClass("Humanoid")
                        local state = humanoid and humanoid:GetState() or Enum.HumanoidStateType.None
                        local dist = (myHRP.Position - part.Position).Magnitude
                        local ping = 0
                        pcall(function() ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000 end)
                        local t = math.clamp(dist / math.max(myHRP.AssemblyLinearVelocity.Magnitude + 800, 800) * 0.6 + ping, 0.005, 0.12)
                        silentAimLastVel[part] = silentAimLastVel[part] or part.AssemblyLinearVelocity
                        local accel = (part.AssemblyLinearVelocity - silentAimLastVel[part]).Magnitude
                        local smooth = silentAimLastVel[part]:Lerp(part.AssemblyLinearVelocity, accel > 50 and 0.8 or 0.35)
                        silentAimLastVel[part] = smooth
                        local pos = part.Position + smooth * t
                        local inAir = state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.GettingUp
                        if inAir then
                            pos = pos + Vector3.new(0, workspace.Gravity * t * t * 0.12, 0)
                            if smooth.Y > 0 then pos = pos + Vector3.new(0, smooth.Y * t * 0.08, 0) end
                        end
                        local dy = pos.Y - part.Position.Y
                        local clamp = inAir and math.clamp(dy, -dist * 0.08, dist * 0.12) or math.clamp(dy, -dist * 0.03, dist * 0.05)
                        return Vector3.new(pos.X, part.Position.Y + clamp + 0.75, pos.Z)
                    end

                    local function sa_shootMurderer()
                        task.spawn(function()
                            pcall(function()
                                if tick() - silentAimLastShot < silentAimCooldown then return end
                                silentAimLastShot = tick()
                                local m = f_findMurderer()
                                if not m or not m.Character then return end
                                local murderer = m.Character:FindFirstChild("UpperTorso")
                                    or m.Character:FindFirstChild("Torso")
                                    or m.Character:FindFirstChild("HumanoidRootPart")
                                if not murderer then return end
                                local char = LocalPlayer.Character
                                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                if not hrp then return end
                                local gun = char:FindFirstChild("Gun")
                                if not gun then
                                    gun = LocalPlayer.Backpack:FindFirstChild("Gun")
                                    if gun then gun.Parent = char task.wait(0.1) gun = char:FindFirstChild("Gun") end
                                end
                                if not gun then return end
                                local shootRemote = gun:FindFirstChild("Shoot", true)
                                if not shootRemote then return end
                                local predPos = sa_getPredictedPos(murderer)
                                local originCFrame = CFrame.new(hrp.Position, predPos)
                                if silentAimWallshot then
                                    local fireDir = (predPos - hrp.Position).Unit
                                    if fireDir.Magnitude == 0 then fireDir = Vector3.new(0, 0, -1) end
                                    local wallshotOriginPos = predPos - (fireDir * 2)
                                    originCFrame = CFrame.new(wallshotOriginPos, predPos)
                                end
                                shootRemote:FireServer(originCFrame, CFrame.new(predPos))
                            end)
                        end)
                    end

                    local function sa_setupGun(tool)
                        if not tool or not tool:IsA("Tool") then return end
                        if tool.Name ~= "Gun" then return end
                        tool.Activated:Connect(function()
                            if silentAimEnabled then sa_shootMurderer() end
                        end)
                    end

                    task.spawn(function()
                        local function hookGun(container)
                            if not container then return end
                            for _, child in ipairs(container:GetChildren()) do
                                if child.Name == "Gun" and child:IsA("Tool") then sa_setupGun(child) end
                            end
                            container.ChildAdded:Connect(function(child)
                                if child.Name == "Gun" and child:IsA("Tool") then sa_setupGun(child) end
                            end)
                        end
                        local bp = LocalPlayer:WaitForChild("Backpack", 5)
                        if bp then hookGun(bp) end
                        if LocalPlayer.Character then hookGun(LocalPlayer.Character) end
                        LocalPlayer.CharacterAdded:Connect(function(char)
                            task.wait(0.5)
                            local b = LocalPlayer:WaitForChild("Backpack", 5)
                            if b then hookGun(b) end
                            hookGun(char)
                        end)
                    end)

                    getgenv().CatFeexSilentShoot = sa_shootMurderer
                    getgenv().CatFeexSilentSet = function(on) silentAimEnabled = on == true end
                    getgenv().CatFeexWallshotSet = function(on) silentAimWallshot = on == true end

                    do
                        local u20 = UserInputService
                        function v21(p1)
                            local u362 = nil
                            local p2Position = nil
                            local Position = nil
                            local InputBegan = p1.InputBegan
                            local u366 = p1
                            InputBegan:Connect(function(p2)
                                if p2.UserInputType == Enum.UserInputType.MouseButton1 or p2.UserInputType == Enum.UserInputType.Touch then
                                    u362 = true
                                    p2Position = p2.Position
                                    Position = u366.Position
                                end
                            end)
                            local InputChanged = p1.InputChanged
                            local u368 = p1
                            InputChanged:Connect(function(p3)
                                if u362 then
                                    if p3.UserInputType == Enum.UserInputType.MouseMovement or p3.UserInputType == Enum.UserInputType.Touch then
                                        local v838 = p3.Position - p2Position
                                        u368.Position = UDim2.new(Position.X.Scale, Position.X.Offset + v838.X, Position.Y.Scale, Position.Y.Offset + v838.Y)
                                    end
                                    return
                                end
                            end)
                            u20.InputEnded:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                    u362 = false
                                end
                            end)
                        end
                    end
                    do
                        local u22 = UserInputService
                        local u23 = v18
                        local u24 = v21
                        function v25(p4, p5, p6, p7, p8, p9, p10)
                            local v377 = 'RuzSlider_' .. p4:gsub('%s+', '_')
                            local v378 = game.CoreGui:FindFirstChild(v377)
                            if not v378 then
                                local ScreenGui = Instance.new('ScreenGui', game.CoreGui)
                                ScreenGui.Name = v377
                                ScreenGui.ResetOnSpawn = false
                                ScreenGui.DisplayOrder = 55
                                ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                                local Frame = Instance.new('Frame', ScreenGui)
                                Frame.Size = UDim2.new(0, 300, 0, 175)
                                Frame.Position = UDim2.new(0.5, -150, 0.35, 0)
                                Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
                                Frame.BackgroundTransparency = 0.08
                                Frame.BorderSizePixel = 0
                                Instance.new('UICorner', Frame).CornerRadius = UDim.new(0, 10)
                                local UIStroke = Instance.new('UIStroke', Frame)
                                UIStroke.Color = YELLOW
                                UIStroke.Thickness = 1.5
                                UIStroke.Transparency = 0.15
                                local TextLabel2 = Instance.new('TextLabel', Frame)
                                TextLabel2.Size = UDim2.new(1, -44, 0, 36)
                                TextLabel2.Position = UDim2.new(0, 12, 0, 0)
                                TextLabel2.BackgroundTransparency = 1
                                TextLabel2.Text = 'CatFeex 0.1 — ' .. p4
                                TextLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
                                TextLabel2.Font = Enum.Font.GothamBold
                                TextLabel2.TextSize = 14
                                TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
                                local TextButton = Instance.new('TextButton', Frame)
                                TextButton.Size = UDim2.new(0, 28, 0, 28)
                                TextButton.Position = UDim2.new(1, -34, 0, 4)
                                TextButton.BackgroundColor3 = YELLOW_DARK
                                TextButton.Text = 'X'
                                TextButton.TextColor3 = Color3.new(1, 1, 1)
                                TextButton.Font = Enum.Font.GothamBold
                                TextButton.TextSize = 13
                                Instance.new('UICorner', TextButton).CornerRadius = UDim.new(0, 6)
                                local u385 = ScreenGui
                                TextButton.MouseButton1Click:Connect(function() u385:Destroy() end)
                                local u386 = p7
                                local TextLabel3 = Instance.new('TextLabel', Frame)
                                TextLabel3.Size = UDim2.new(1, 0, 0, 22)
                                TextLabel3.Position = UDim2.new(0, 0, 0, 38)
                                TextLabel3.BackgroundTransparency = 1
                                TextLabel3.Text = p4 .. ':  ' .. tostring(p7)
                                TextLabel3.TextColor3 = Color3.fromRGB(210, 210, 210)
                                TextLabel3.Font = Enum.Font.Gotham
                                TextLabel3.TextSize = 13
                                local Frame2 = Instance.new('Frame', Frame)
                                Frame2.Size = UDim2.new(1, -30, 0, 10)
                                Frame2.Position = UDim2.new(0, 15, 0, 72)
                                Frame2.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                                Frame2.BorderSizePixel = 0
                                Instance.new('UICorner', Frame2).CornerRadius = UDim.new(1, 0)
                                local v390 = (p7 - p5) / (p6 - p5)
                                local Frame3 = Instance.new('Frame', Frame2)
                                Frame3.Size = UDim2.new(v390, 0, 1, 0)
                                Frame3.BackgroundColor3 = YELLOW
                                Frame3.BorderSizePixel = 0
                                Instance.new('UICorner', Frame3).CornerRadius = UDim.new(1, 0)
                                local TextButton2 = Instance.new('TextButton', Frame2)
                                TextButton2.Size = UDim2.new(0, 26, 0, 26)
                                TextButton2.Position = UDim2.new(v390, -13, 0.5, -13)
                                TextButton2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                TextButton2.Text = ''
                                TextButton2.AutoButtonColor = false
                                TextButton2.BorderSizePixel = 0
                                Instance.new('UICorner', TextButton2).CornerRadius = UDim.new(1, 0)
                                local u393 = Frame2
                                local u394 = p5
                                local u395 = p6
                                local u396 = p8
                                local u397 = TextButton2
                                local u398 = p4
                                local function v399(p11)
                                    local v841 = (p11 - u393.AbsolutePosition.X) / u393.AbsoluteSize.X
                                    local v842 = math.clamp(v841, 0, 1)
                                    local v843 = u394 + v842 * (u395 - u394)
                                    u386 = math.round(v843)
                                    if u396 and u396 > 0 then
                                        local v844 = u386 / u396
                                        u386 = math.round(v844) * u396
                                    end
                                    local v845 = (u386 - u394) / (u395 - u394)
                                    Frame3.Size = UDim2.new(v845, 0, 1, 0)
                                    u397.Position = UDim2.new(v845, -13, 0.5, -13)
                                    TextLabel3.Text = u398 .. ':  ' .. tostring(u386)
                                end
                                local u400 = false
                                TextButton2.InputBegan:Connect(function(input)
                                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then u400 = true end
                                end)
                                local InputBegan = Frame2.InputBegan
                                local u402 = v399
                                InputBegan:Connect(function(p12)
                                    if p12.UserInputType == Enum.UserInputType.MouseButton1 or p12.UserInputType == Enum.UserInputType.Touch then
                                        u400 = true
                                        u402(p12.Position.X)
                                    end
                                end)
                                local InputChanged = u22.InputChanged
                                local u404 = v399
                                InputChanged:Connect(function(p13)
                                    if u400 then
                                        if p13.UserInputType == Enum.UserInputType.MouseMovement or p13.UserInputType == Enum.UserInputType.Touch then u404(p13.Position.X) end
                                        return
                                    end
                                end)
                                u22.InputEnded:Connect(function(input)
                                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then u400 = false end
                                end)
                                local Frame4 = Instance.new('Frame', Frame)
                                Frame4.Size = UDim2.new(1, -20, 0, 36)
                                Frame4.Position = UDim2.new(0, 10, 0, 126)
                                Frame4.BackgroundTransparency = 1
                                local TextButton3 = Instance.new('TextButton', Frame4)
                                TextButton3.Size = UDim2.new(0.48, 0, 1, 0)
                                TextButton3.BackgroundColor3 = Color3.fromRGB(20, 160, 20)
                                TextButton3.Text = 'Apply'
                                TextButton3.TextColor3 = Color3.new(1, 1, 1)
                                TextButton3.Font = Enum.Font.GothamBold
                                TextButton3.TextSize = 13
                                Instance.new('UICorner', TextButton3).CornerRadius = UDim.new(0, 6)
                                local u408 = p9
                                local u409 = p4
                                TextButton3.MouseButton1Click:Connect(function()
                                    u408(u386)
                                    u23:Notify({Title = 'CatFeex 0.1', Content = tostring(u409 .. ' set to ' .. u386), Duration = 3, Icon = 'bell'})
                                end)
                                local TextButton4 = Instance.new('TextButton', Frame4)
                                TextButton4.Size = UDim2.new(0.48, 0, 1, 0)
                                TextButton4.Position = UDim2.new(0.52, 0, 0, 0)
                                TextButton4.BackgroundColor3 = Color3.fromRGB(160, 20, 20)
                                TextButton4.Text = 'Reset'
                                TextButton4.TextColor3 = Color3.new(1, 1, 1)
                                TextButton4.Font = Enum.Font.GothamBold
                                TextButton4.TextSize = 13
                                Instance.new('UICorner', TextButton4).CornerRadius = UDim.new(0, 6)
                                local u412 = ScreenGui
                                TextButton4.MouseButton1Click:Connect(function()
                                    p10()
                                    u412:Destroy()
                                end)
                                u24(Frame)
                                return
                            end
                            v378:Destroy()
                        end
                    end
                    do
                        local ScreenGui = Instance.new('ScreenGui', game.CoreGui)
                        ScreenGui.Name = 'RuzLGStar'
                        ScreenGui.ResetOnSpawn = false
                        ScreenGui.DisplayOrder = 40
                        TextLabel = Instance.new('ImageLabel', ScreenGui)
                    end
                    TextLabel.Size = UDim2.new(0, 28, 0, 28)
                    TextLabel.Position = UDim2.new(1, -34, 0, 4)
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.Image = 'rbxassetid://101992008196867'
                    TextLabel.ImageColor3 = Color3.new(1, 1, 1)
                    TextLabel.ScaleType = Enum.ScaleType.Fit
                    TextLabel.Visible = false

                    do
                        local t2, n4, u82
                        local Part = Instance.new('Part')
                        Part.Name = 'RuzPredictionPart'
                        Part.Size = Vector3.new(0.5, 0.5, 0.5)
                        Part.Anchored = true
                        Part.CanCollide = false
                        Part.Transparency = 1
                        Part.Parent = Workspace
                        u29 = nil

                        do
                            local v35
                            do
                                local u30 = Workspace
                                u31 = nil
                                u32 = nil
                                local color3 = Color3.fromRGB(255, 215, 0)
                                local function u34(p14)
                                    if u29 then u29:Destroy() u29 = nil end
                                    local Part2 = Instance.new('Part')
                                    Part2.Name = 'RuzGunMarker'
                                    Part2.Size = Vector3.new(1.5, 0.15, 1.5)
                                    Part2.Anchored = true
                                    Part2.CanCollide = false
                                    Part2.CastShadow = false
                                    Part2.Material = Enum.Material.Neon
                                    Part2.Color = Color3.fromRGB(50, 255, 80)
                                    Part2.Transparency = 0.25
                                    Part2.CFrame = CFrame.new(p14)
                                    Part2.Parent = u30
                                    local spawn = task.spawn
                                    local u416 = Part2
                                    spawn(function()
                                        while u416 and u416.Parent do
                                            for i = 0, 1, 0.05 do
                                                if not u416 or not u416.Parent then break end
                                                local v856 = i * 3.141592653589793
                                                u416.Transparency = 0.25 + 0.5 * math.sin(v856)
                                                task.wait(0.03)
                                            end
                                        end
                                    end)
                                    u29 = Part2
                                end
                                function v35(p15)
                                    if u17 then
                                        if u31 then u31:Destroy() u31 = nil end
                                        if u32 then u32:Destroy() u32 = nil end
                                        local Highlight = Instance.new('Highlight')
                                        Highlight.Adornee = p15
                                        Highlight.FillColor = color3
                                        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                        Highlight.FillTransparency = 0.35
                                        Highlight.OutlineTransparency = 0
                                        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                        Highlight.Parent = p15
                                        u31 = Highlight
                                        local v419 = p15:FindFirstChild('Handle') or (p15:IsA('Model') and p15.PrimaryPart or p15:FindFirstChildWhichIsA('BasePart')) or p15:IsA('BasePart') and p15
                                        if not v419 then
                                            if p15:IsA('Model') then u34(p15:GetModelCFrame().Position + Vector3.new(0, 0.1, 0)) end
                                            return
                                        end
                                        u34(v419.Position + Vector3.new(0, 0.1, 0))
                                        local BillboardGui = Instance.new('BillboardGui')
                                        BillboardGui.Adornee = v419
                                        BillboardGui.Size = UDim2.new(0, 130, 0, 36)
                                        BillboardGui.StudsOffset = Vector3.new(0, 4, 0)
                                        BillboardGui.AlwaysOnTop = true
                                        BillboardGui.MaxDistance = 300
                                        BillboardGui.Parent = v419
                                        local Frame = Instance.new('Frame', BillboardGui)
                                        Frame.Size = UDim2.new(1, 0, 1, 0)
                                        Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                                        Frame.BackgroundTransparency = 0.4
                                        Frame.BorderSizePixel = 0
                                        Instance.new('UICorner', Frame).CornerRadius = UDim.new(0, 6)
                                        local UIStroke = Instance.new('UIStroke', Frame)
                                        UIStroke.Color = color3
                                        UIStroke.Thickness = 1.5
                                        UIStroke.Transparency = 0.1
                                        local TextLabel4 = Instance.new('TextLabel', Frame)
                                        TextLabel4.Size = UDim2.new(1, 0, 1, 0)
                                        TextLabel4.BackgroundTransparency = 1
                                        TextLabel4.Text = 'GUN ON MAP'
                                        TextLabel4.TextColor3 = color3
                                        TextLabel4.Font = Enum.Font.GothamBlack
                                        TextLabel4.TextSize = 13
                                        TextLabel4.TextStrokeTransparency = 0.4
                                        TextLabel4.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                        u32 = BillboardGui
                                        return
                                    end
                                end
                            end
                            do
                                local u42
                                do
                                    local t1 = {}
                                    local u40 = v35
                                    local u41 = v18
                                    function u42(p16)
                                        if not t1[p16] then
                                            t1[p16] = true
                                            p16.ChildAdded:Connect(function(child)
                                                if child.Name == 'GunDrop' then
                                                    task.wait(0.1)
                                                    if u17 then u40(child) end
                                                    u41:Notify({Title = 'CatFeex 0.1', Content = 'Gun dropped on the map!', Duration = 3, Icon = 'bell'})
                                                end
                                                if child:IsA('Model') or child:IsA('Folder') then u42(child) end
                                            end)
                                            p16.ChildRemoved:Connect(function(child)
                                                if child.Name == 'GunDrop' then
                                                    if u31 then u31:Destroy() u31 = nil end
                                                    if u32 then u32:Destroy() u32 = nil end
                                                    if u29 then u29:Destroy() u29 = nil end
                                                end
                                            end)
                                            for _, child in ipairs(p16:GetChildren())do
                                                if child:IsA('Model') or child:IsA('Folder') then u42(child) end
                                            end
                                            return
                                        end
                                    end
                                end
                                u42(Workspace)
                                local ChildAdded = Workspace.ChildAdded
                                local u44 = u42
                                local u45 = v35
                                local u46 = v18
                                ChildAdded:Connect(function(p17)
                                    if p17:IsA('Model') or p17:IsA('Folder') then u44(p17) end
                                    if p17.Name == 'GunDrop' then
                                        task.wait(0.1)
                                        if u17 then u45(p17) end
                                        u46:Notify({Title = 'CatFeex 0.1', Content = 'Gun dropped on the map!', Duration = 3, Icon = 'bell'})
                                    end
                                end)
                            end
                            do
                                local spawn = task.spawn
                                local u48 = Workspace
                                local u49 = v35
                                local u50 = v18
                                spawn(function()
                                    task.wait(1.5)
                                    local GunDrop = u48:FindFirstChild('GunDrop', true)
                                    if GunDrop then
                                        if u17 then u49(GunDrop) end
                                        u50:Notify({Title = 'CatFeex 0.1', Content = 'Gun dropped on the map!', Duration = 3, Icon = 'bell'})
                                    end
                                end)
                            end
                            do
                                local u51 = Workspace
                                local u52 = v35
                                local u53 = v18
                                for _, player in ipairs(Players:GetPlayers())do
                                    if player ~= LocalPlayer then
                                        task.spawn(function(p18)
                                            local u431 = p18
                                            if p18.Character then
                                                local Character = p18.Character
                                                if Character then
                                                    local Humanoid = Character:WaitForChild('Humanoid', 5)
                                                    if Humanoid then
                                                        local Died = Humanoid.Died
                                                        local u435 = p18
                                                        local u436 = Character
                                                        Died:Connect(function()
                                                            if u435.Backpack:FindFirstChild('Gun') or u436:FindFirstChild('Gun') then
                                                                task.delay(0.8, function()
                                                                    local GunDrop = u51:FindFirstChild('GunDrop', true)
                                                                    if GunDrop then
                                                                        if u17 then u52(GunDrop) end
                                                                        u53:Notify({Title = 'CatFeex 0.1', Content = 'Gun dropped on the map!', Duration = 3, Icon = 'bell'})
                                                                    end
                                                                end)
                                                            end
                                                        end)
                                                    end
                                                end
                                            end
                                            p18.CharacterAdded:Connect(function(character)
                                                if character then
                                                    local Humanoid = character:WaitForChild('Humanoid', 5)
                                                    if Humanoid then
                                                        local Died = Humanoid.Died
                                                        local u862 = character
                                                        Died:Connect(function()
                                                            if u431.Backpack:FindFirstChild('Gun') or u862:FindFirstChild('Gun') then
                                                                task.delay(0.8, function()
                                                                    local GunDrop = u51:FindFirstChild('GunDrop', true)
                                                                    if GunDrop then
                                                                        if u17 then u52(GunDrop) end
                                                                        u53:Notify({Title = 'CatFeex 0.1', Content = 'Gun dropped on the map!', Duration = 3, Icon = 'bell'})
                                                                    end
                                                                end)
                                                            end
                                                        end)
                                                        return
                                                    end
                                                    return
                                                end
                                            end)
                                        end, player)
                                    end
                                end
                            end
                            local PlayerAdded = Players.PlayerAdded
                            local u57 = LocalPlayer
                            local u58 = Workspace
                            local u59 = v35
                            local u60 = v18
                            PlayerAdded:Connect(function(p19)
                                if p19 ~= u57 then
                                    local u438 = p19
                                    if p19.Character then
                                        local Character = p19.Character
                                        if Character then
                                            local Humanoid = Character:WaitForChild('Humanoid', 5)
                                            if Humanoid then
                                                local Died = Humanoid.Died
                                                local u442 = p19
                                                local u443 = Character
                                                Died:Connect(function()
                                                    if u442.Backpack:FindFirstChild('Gun') or u443:FindFirstChild('Gun') then
                                                        task.delay(0.8, function()
                                                            local GunDrop = u58:FindFirstChild('GunDrop', true)
                                                            if GunDrop then
                                                                if u17 then u59(GunDrop) end
                                                                u60:Notify({Title = 'CatFeex 0.1', Content = 'Gun dropped on the map!', Duration = 3, Icon = 'bell'})
                                                            end
                                                        end)
                                                    end
                                                end)
                                            end
                                        end
                                    end
                                    p19.CharacterAdded:Connect(function(character)
                                        if character then
                                            local Humanoid = character:WaitForChild('Humanoid', 5)
                                            if Humanoid then
                                                local Died = Humanoid.Died
                                                local u866 = character
                                                Died:Connect(function()
                                                    if u438.Backpack:FindFirstChild('Gun') or u866:FindFirstChild('Gun') then
                                                        task.delay(0.8, function()
                                                            local GunDrop = u58:FindFirstChild('GunDrop', true)
                                                            if GunDrop then
                                                                if u17 then u59(GunDrop) end
                                                                u60:Notify({Title = 'CatFeex 0.1', Content = 'Gun dropped on the map!', Duration = 3, Icon = 'bell'})
                                                            end
                                                        end)
                                                    end
                                                end)
                                                return
                                            end
                                            return
                                        end
                                    end)
                                end
                            end)
                            u61 = false
                            u62 = nil
                            t2 = {}
                            n4 = 0
                            t3 = {Murderer = true, Sheriff = true, Hero = true, Innocent = true, Self = true}
                            t4 = {
                                Murderer = Color3.fromRGB(255, 0, 0),
                                Sheriff = Color3.fromRGB(0, 150, 255),
                                Hero = Color3.fromRGB(255, 220, 0),
                                Innocent = Color3.fromRGB(0, 255, 0),
                            }
                            local u67 = Players
                            function v68()
                                for _, player in ipairs(u67:GetPlayers())do
                                    if player.Character then
                                        local CatFeex_ESP = player.Character:FindFirstChild('CatFeex_ESP')
                                        if CatFeex_ESP then CatFeex_ESP:Destroy() end
                                    end
                                end
                                t2 = {}
                                n4 = 0
                            end
                        end
                        do
                            local u69 = ReplicatedStorage
                            local u70 = v18
                            local u71 = RunService
                            local u72 = Players
                            local function u73(p20)
                                local info = t2[p20.Name]
                                if info then
                                    if type(info) == 'string' then
                                        local r = info:lower()
                                        if r:find('murd') then return 'Murderer' end
                                        if r:find('sheriff') then return 'Sheriff' end
                                        if r:find('hero') then return 'Hero' end
                                        if r:find('innoc') then return 'Innocent' end
                                    end
                                    if type(info) == 'table' then
                                        local role = info.Role or info.role or info.Team or info.team
                                            or info.Alignment or info.alignment or info.TeamName
                                            or info.ClassName or info.Name
                                        if role then
                                            local r = tostring(role):lower()
                                            if r:find('murd') then return 'Murderer' end
                                            if r:find('sheriff') then return 'Sheriff' end
                                            if r:find('hero') then return 'Hero' end
                                            if r:find('innoc') then return 'Innocent' end
                                        end
                                    end
                                end
                                local char = p20.Character
                                if char then
                                    local bp = p20:FindFirstChild('Backpack')
                                    local hasKnife = char:FindFirstChild('Knife') or (bp and bp:FindFirstChild('Knife'))
                                    local hasGun = char:FindFirstChild('Gun') or (bp and bp:FindFirstChild('Gun'))
                                    if hasKnife and not hasGun then return 'Murderer' end
                                    if hasGun and not hasKnife then return 'Sheriff' end
                                end
                                return 'Innocent'
                            end
                            local u74 = t3
                            local u75 = LocalPlayer
                            local function u76(p21, p22)
                                local v451 = p21:FindFirstChild('CatFeex_ESP') or Instance.new('Highlight')
                                v451.Name = 'CatFeex_ESP'
                                v451.Parent = p21
                                v451.FillColor = p22
                                v451.FillTransparency = 0.5
                                v451.OutlineColor = Color3.fromRGB(255, 255, 255)
                                v451.OutlineTransparency = 0.1
                                v451.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            end
                            local u77 = t4
                            function v78()
                                if u62 then u62:Disconnect() u62 = nil end
                                local GetCurrentPlayerData = u69:FindFirstChild('GetCurrentPlayerData', true)
                                    or u69:FindFirstChild('GetPlayerData', true)
                                    or u69:FindFirstChild('GetRoleData', true)
                                    or u69:FindFirstChild('GetData', true)
                                local Heartbeat = u71.Heartbeat
                                local u459 = GetCurrentPlayerData
                                u62 = Heartbeat:Connect(function()
                                    if not u61 then return end
                                    if u459 and u459:IsA('RemoteFunction') and tick() - n4 > 0.5 then
                                        local ok, result = pcall(function() return u459:InvokeServer() end)
                                        if ok and type(result) == 'table' then t2 = result end
                                        n4 = tick()
                                    end
                                    for _, player in ipairs(u72:GetPlayers())do
                                        if player.Character then
                                            local v871 = u73(player)
                                            local v872 = u74[v871]
                                            if player == u75 and not u74.Self then v872 = false end
                                            if not v872 then
                                                local CatFeex_ESP = player.Character:FindFirstChild('CatFeex_ESP')
                                                if CatFeex_ESP then CatFeex_ESP:Destroy() end
                                            else
                                                u76(player.Character, u77[v871])
                                            end
                                        end
                                    end
                                end)
                            end
                        end
                        do
                            local _ = v68
                            local _ = v78
                            local _ = v68
                            u82 = nil

                            getgenv().CatFeexAimActive = false
                            getgenv().CatFeexAimConn = nil

                            local function CatFeexHasKnife(plr)
                                local ch = plr and plr.Character
                                local bp = plr and plr:FindFirstChildOfClass('Backpack')
                                if ch and ch:FindFirstChild('Knife') then return true end
                                if bp and bp:FindFirstChild('Knife') then return true end
                                return false
                            end

                            getgenv().CatFeexGetMurderer = function()
                                local closest, shortest = nil, math.huge
                                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
                                local origin = myRoot and myRoot.Position or Workspace.CurrentCamera.CFrame.Position
                                for _, plr in ipairs(Players:GetPlayers()) do
                                    if plr ~= LocalPlayer and CatFeexHasKnife(plr) then
                                        local ch = plr.Character
                                        local hum = ch and ch:FindFirstChildOfClass('Humanoid')
                                        local root = ch and ch:FindFirstChild('HumanoidRootPart')
                                        if hum and hum.Health > 0 and root then
                                            local d = (origin - root.Position).Magnitude
                                            if d < shortest then
                                                shortest = d
                                                closest = ch
                                            end
                                        end
                                    end
                                end
                                return closest
                            end

                            getgenv().CatFeexAimSet = function(on)
                                getgenv().CatFeexAimActive = on == true
                                if getgenv().CatFeexAimConn then
                                    getgenv().CatFeexAimConn:Disconnect()
                                    getgenv().CatFeexAimConn = nil
                                end
                                if not on then
                                    local ch = LocalPlayer.Character
                                    local hum = ch and ch:FindFirstChildOfClass('Humanoid')
                                    if hum then Workspace.CurrentCamera.CameraSubject = hum end
                                    return
                                end
                                getgenv().CatFeexAimConn = RunService.RenderStepped:Connect(function()
                                    if not getgenv().CatFeexAimActive then return end
                                    local murderer = getgenv().CatFeexGetMurderer()
                                    if not murderer then return end
                                    local torso = murderer:FindFirstChild('UpperTorso')
                                        or murderer:FindFirstChild('Torso')
                                        or murderer:FindFirstChild('Head')
                                        or murderer:FindFirstChild('HumanoidRootPart')
                                    if not torso then return end
                                    local cam = Workspace.CurrentCamera
                                    cam.CFrame = CFrame.lookAt(cam.CFrame.Position, torso.Position)
                                    local myCh = LocalPlayer.Character
                                    local myRoot = myCh and myCh:FindFirstChild('HumanoidRootPart')
                                    if myRoot then
                                        local pos = torso.Position
                                        local vel = torso.AssemblyLinearVelocity or Vector3.zero
                                        local dist = (pos - myRoot.Position).Magnitude
                                        u82 = murderer
                                        Part.CFrame = CFrame.new(pos + vel * (dist / 250 + 0.03))
                                    end
                                end)
                            end

                            local u83 = LocalPlayer
                            local u84 = Players
                            local RenderStepped = RunService.RenderStepped
                            local function u86()
                                local Character = u83.Character
                                local v464 = Character and Character:FindFirstChild('HumanoidRootPart')
                                if v464 then
                                    local v466 = u83.Backpack:FindFirstChild('Knife') or u83.Character and u83.Character:FindFirstChild('Knife')
                                    local v468 = u83.Backpack:FindFirstChild('Gun') or u83.Character and u83.Character:FindFirstChild('Gun')
                                    local v469 = nil
                                    local n5 = (1/0)
                                    for _, player in ipairs(u84:GetPlayers())do
                                        if player ~= u83 and player.Character then
                                            local Character2 = player.Character
                                            local Humanoid = Character2:FindFirstChildOfClass('Humanoid')
                                            if Humanoid and Humanoid.Health > 0 then
                                                local HumanoidRootPart = Character2:FindFirstChild('HumanoidRootPart')
                                                if HumanoidRootPart then
                                                    local v476 = player.Backpack:FindFirstChild('Knife') or player.Character and player.Character:FindFirstChild('Knife')
                                                    local v477 = player.Backpack:FindFirstChild('Gun') or player.Character and player.Character:FindFirstChild('Gun')
                                                    local Magnitude = (HumanoidRootPart.Position - v464.Position).Magnitude
                                                    local v479 = false
                                                    if not v466 then
                                                        if not v468 then
                                                            if v476 then v479 = true Magnitude = Magnitude - 1000 end
                                                            if v477 then v479 = true end
                                                        elseif v477 or v476 then
                                                            v479 = true
                                                        end
                                                    elseif v476 then
                                                        v479 = true
                                                    end
                                                    if v479 and Magnitude < n5 then
                                                        n5 = Magnitude
                                                        v469 = Character2
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    if not v469 then
                                        for _, player in ipairs(u84:GetPlayers())do
                                            if player ~= u83 and player.Character then
                                                local Character3 = player.Character
                                                local Humanoid = Character3:FindFirstChildOfClass('Humanoid')
                                                local HumanoidRootPart = Character3:FindFirstChild('HumanoidRootPart')
                                                if Humanoid and Humanoid.Health > 0 and HumanoidRootPart then
                                                    local Magnitude = (HumanoidRootPart.Position - v464.Position).Magnitude
                                                    if Magnitude < n5 then n5 = Magnitude v469 = Character3 end
                                                end
                                            end
                                        end
                                    end
                                    return v469
                                end
                                return nil
                            end
                            local u87 = LocalPlayer
                            local u88 = Part
                            RenderStepped:Connect(function()
                                if getgenv().CatFeexAimActive then return end
                                local v486 = u86()
                                u82 = v486
                                if v486 then
                                    local Character = u87.Character
                                    local v488 = Character and Character:FindFirstChild('HumanoidRootPart')
                                    if v488 then
                                        local v489 = v486:FindFirstChild('UpperTorso') or (v486:FindFirstChild('Torso') or v486:FindFirstChild('HumanoidRootPart'))
                                        local Humanoid = v486:FindFirstChildOfClass('Humanoid')
                                        if v489 then
                                            local Position = v489.Position
                                            local v492 = (Position - v488.Position).Magnitude / 250
                                            if u13 then
                                                local ok, result = pcall(function() return u87:GetNetworkPing() end)
                                                if ok and result then v492 = v492 + result * 0.5 end
                                            end
                                            local AssemblyLinearVelocity = v489.AssemblyLinearVelocity
                                            if Humanoid then
                                                local State = Humanoid:GetState()
                                                if State == Enum.HumanoidStateType.Freefall or State == Enum.HumanoidStateType.Jumping then
                                                    AssemblyLinearVelocity = Vector3.new(AssemblyLinearVelocity.X, AssemblyLinearVelocity.Y * 0.35, AssemblyLinearVelocity.Z)
                                                end
                                            end
                                            u88.CFrame = CFrame.new(Position + AssemblyLinearVelocity * v492)
                                            return
                                        end
                                        return
                                    end
                                    return
                                end
                            end)
                        end
                        local u89 = LocalPlayer
                        local u90 = v18
                        local u91 = Part
                        local u92 = LocalPlayer
                        local u93 = v18
                        local u94 = Players
                        local u95 = LocalPlayer
                        local function u96()
                            local Character = u92.Character
                            if Character then
                                local HumanoidRootPart = Character:FindFirstChild('HumanoidRootPart')
                                if HumanoidRootPart then
                                    local v507 = u92.Backpack:FindFirstChild('Knife') or Character:FindFirstChild('Knife')
                                    if v507 then
                                        if Character ~= v507.Parent then Character.Humanoid:EquipTool(v507) task.wait(0) end
                                        local v508 = u82
                                        if not u82 then
                                            local n6 = (1/0)
                                            for _, player in ipairs(u94:GetPlayers())do
                                                if player ~= u92 and player.Character then
                                                    local HumanoidRootPart2 = player.Character:FindFirstChild('HumanoidRootPart')
                                                    local Humanoid = player.Character:FindFirstChildOfClass('Humanoid')
                                                    if HumanoidRootPart2 and Humanoid and Humanoid.Health > 0 then
                                                        local Magnitude = (HumanoidRootPart2.Position - HumanoidRootPart.Position).Magnitude
                                                        if Magnitude < n6 then n6 = Magnitude v508 = player.Character end
                                                    end
                                                end
                                            end
                                        end
                                        if v508 then
                                            local HumanoidRootPart3 = v508:FindFirstChild('HumanoidRootPart')
                                            if HumanoidRootPart3 then
                                                local v516 = v508:FindFirstChild('UpperTorso') or (v508:FindFirstChild('Torso') or HumanoidRootPart3)
                                                local AssemblyLinearVelocity = HumanoidRootPart3.AssemblyLinearVelocity
                                                local Magnitude = (v516.Position - HumanoidRootPart.Position).Magnitude
                                                local n7 = 0
                                                if u13 then
                                                    local ok, result = pcall(function() return u92:GetNetworkPing() end)
                                                    n7 = ok and result or 0
                                                end
                                                local u522 = v516.Position + Vector3.new(AssemblyLinearVelocity.X, 0, AssemblyLinearVelocity.Z) * (Magnitude / 65 + n7 * 0.5)
                                                pcall(function()
                                                    local KnifeThrown = v507:WaitForChild('Events'):WaitForChild('KnifeThrown')
                                                    local cFrame = CFrame.new(HumanoidRootPart.Position, u522)
                                                    local v881 = (function(...) local t5 = {...} t5.n = select('#', ...) return t5 end)(CFrame.new(u522))
                                                    KnifeThrown:FireServer(cFrame, unpack(v881, 1, v881.n))
                                                end)
                                                return
                                            end
                                            return
                                        end
                                        u93:Notify({Title = 'CatFeex 0.1', Content = 'No target found!', Duration = 3, Icon = 'bell'})
                                        return
                                    end
                                    u93:Notify({Title = 'CatFeex 0.1', Content = 'No knife in inventory!', Duration = 3, Icon = 'bell'})
                                    return
                                end
                                return
                            end
                        end
                        local function u97()
                            local Character = u89.Character
                            if Character then
                                local HumanoidRootPart = Character:FindFirstChild('HumanoidRootPart')
                                if HumanoidRootPart then
                                    local v499 = u89.Backpack:FindFirstChild('Gun') or Character:FindFirstChild('Gun')
                                    if v499 then
                                        if u82 then
                                            if Character ~= v499.Parent then Character.Humanoid:EquipTool(v499) task.wait(0) end
                                            local CFramePosition = u91.CFrame.Position
                                            local v501 = HumanoidRootPart.Position + Vector3.new(0, 1, 0)
                                            local cFrame = CFrame.new(v501, CFramePosition)
                                            pcall(function()
                                                local Shoot = v499:WaitForChild('Shoot')
                                                local v876 = (function(...) local t6 = {...} t6.n = select('#', ...) return t6 end)(CFrame.new(CFramePosition))
                                                Shoot:FireServer(cFrame, unpack(v876, 1, v876.n))
                                            end)
                                            return
                                        end
                                        u90:Notify({Title = 'CatFeex 0.1', Content = 'No target found.', Duration = 3, Icon = 'bell'})
                                        return
                                    end
                                    u90:Notify({Title = 'CatFeex 0.1', Content = 'No gun in inventory!', Duration = 3, Icon = 'bell'})
                                    return
                                end
                                return
                            end
                        end
                        function u98()
                            if u95.Character then
                                if not u95.Backpack:FindFirstChild('Knife') and (not u95.Character or not u95.Character:FindFirstChild('Knife')) then
                                    u97()
                                    return
                                end
                                u96()
                                return
                            end
                        end
                    end

                    u99 = false
                    do
                        local u100 = LocalPlayer
                        local u101 = UserInputService
                        local u102 = CurrentCamera
                        local u103 = RunService
                        function u104()
                            if u99 then return end
                            local Character = u100.Character
                            if not Character then return end
                            local HumanoidRootPart = Character:FindFirstChild('HumanoidRootPart')
                            if not HumanoidRootPart then return end
                            u99 = true
                            if u101.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
                                local HumanoidRootPartCFrame = HumanoidRootPart.CFrame
                                local v530 = HumanoidRootPartCFrame * CFrame.Angles(0, 3.141592653589793, 0)
                                for i = 1, 4 do
                                    HumanoidRootPart.CFrame = HumanoidRootPartCFrame:Lerp(v530, i / 4)
                                    u103.RenderStepped:Wait()
                                end
                            else
                                local CFrame2 = u102.CFrame
                                local LookVector = CFrame2.LookVector
                                local vector3 = Vector3.new(-LookVector.X, LookVector.Y, -LookVector.Z)
                                local cFrame = CFrame.lookAt(CFrame2.Position, CFrame2.Position + vector3)
                                for i = 1, 5 do
                                    u102.CFrame = CFrame2:Lerp(cFrame, i / 5)
                                    u103.RenderStepped:Wait()
                                end
                            end
                            task.wait(0.15)
                            u99 = false
                        end
                        u105 = false
                        local u106 = LocalPlayer
                        local u107 = UserInputService
                        local u108 = CurrentCamera
                        local u109 = RunService
                        function u110()
                            if u105 then return end
                            local Character = u106.Character
                            if not Character then return end
                            local HumanoidRootPart = Character:FindFirstChild('HumanoidRootPart')
                            if not HumanoidRootPart then return end
                            local Humanoid = Character:FindFirstChildOfClass('Humanoid')
                            if not Humanoid then return end
                            u105 = true
                            local v547 = u107.MouseBehavior == Enum.MouseBehavior.LockCenter
                            local _, v549, _ = HumanoidRootPart.CFrame:ToEulerAnglesYXZ()
                            local CFrame3 = u108.CFrame
                            if not v547 then
                                local v552 = v549 - 1.5707963267948966
                                for i = 1, 7 do
                                    local cFrame = CFrame.new(HumanoidRootPart.Position)
                                    local fromEulerAnglesYXZ = CFrame.fromEulerAnglesYXZ
                                    local v543 = v549 + (v552 - v549) * (i / 7)
                                    HumanoidRootPart.CFrame = cFrame * fromEulerAnglesYXZ(0, v543, 0)
                                    u109.RenderStepped:Wait()
                                end
                            else
                                local Unit = Vector3.new(CFrame3.LookVector.X, 0, CFrame3.LookVector.Z).Unit
                                local RightVectorX = CFrame3.RightVector.X
                                local RightVectorZ = CFrame3.RightVector.Z
                                local Unit2 = Vector3.new(RightVectorX, 0, RightVectorZ).Unit
                                for i = 1, 7 do
                                    local CFramePosition = u108.CFrame.Position
                                    local v543 = u108.CFrame.Position + Unit:Lerp(Unit2, RightVectorZ).Unit
                                    u108.CFrame = CFrame.lookAt(CFramePosition, v543)
                                    u109.RenderStepped:Wait()
                                end
                            end
                            local AssemblyLinearVelocity = HumanoidRootPart.AssemblyLinearVelocity
                            HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(AssemblyLinearVelocity.X, 55, AssemblyLinearVelocity.Z)
                            pcall(function() Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
                            task.wait(0.12)
                            task.wait(0.1)
                            u105 = false
                        end
                    end
                    local spawn = task.spawn
                    local u112 = ReplicatedStorage
                    spawn(function()
                        while true do
                            task.wait(2)
                            pcall(function()
                                u112.Remotes.Extras.ReplicateToy:InvokeServer('FakeBomb')
                                u112.Remotes.Extras.ReplicateToy:InvokeServer('GoldBomb')
                            end)
                        end
                    end)
                    local u113 = LocalPlayer
                    local u114 = v18
                    function v115(p23, p24)
                        local Character = u113.Character
                        if Character then
                            local v596 = u113.Backpack:FindFirstChild(p23) or Character:FindFirstChild(p23)
                            if v596 then
                                local HumanoidRootPart = Character:FindFirstChild('HumanoidRootPart')
                                if HumanoidRootPart then
                                    if Character ~= v596.Parent then Character.Humanoid:EquipTool(v596) task.wait() end
                                    pcall(function()
                                        v596.Remote:FireServer(CFrame.new(HumanoidRootPart.Position + HumanoidRootPart.CFrame.LookVector * 1.5 + Vector3.new(0, -3, 0)), 50)
                                    end)
                                    Character.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                                    HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(HumanoidRootPart.AssemblyLinearVelocity.X, 62, HumanoidRootPart.AssemblyLinearVelocity.Z)
                                    if not p24 then
                                        task.spawn(function() u10 = true task.wait(21) u10 = false end)
                                        return
                                    end
                                    task.spawn(function() u9 = true task.wait(4) u9 = false end)
                                    return
                                end
                                return
                            end
                            u114:Notify({Title = 'CatFeex 0.1', Content = tostring('No ' .. p23 .. ' found!'), Duration = 3, Icon = 'bell'})
                            return
                        end
                    end
                    u116 = false
                    local u117 = nil
                    local u118 = RunService
                    local function v119(p25)
                        local Humanoid = p25:WaitForChild('Humanoid')
                        if u117 then u117:Disconnect() end
                        local u605 = Humanoid
                        u117 = u118.RenderStepped:Connect(function()
                            if u116 then
                                local State = u605:GetState()
                                u605.WalkSpeed = (State == Enum.HumanoidStateType.Jumping or State == Enum.HumanoidStateType.Freefall) and (u605.MoveDirection.Magnitude > 0 and n2) or 16
                                return
                            end
                            u605.WalkSpeed = 16
                        end)
                    end
                    LocalPlayer.CharacterAdded:Connect(v119)
                    if LocalPlayer.Character then task.spawn(v119, LocalPlayer.Character) end
                    u120 = false
                    local u121 = nil
                    n17 = 0.5
                    local u123 = RunService
                    local u124 = CurrentCamera
                    function v125(p26)
                        u120 = p26
                        if not p26 then
                            if u121 then u121:Disconnect() u121 = nil end
                            return
                        end
                        if u121 then u121:Disconnect() end
                        u121 = u123.RenderStepped:Connect(function()
                            u124.CFrame = u124.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, n17, 0, 0, 0, 1)
                        end)
                    end
                end

                u126 = v25
                u127 = v125
                u128 = v18
                u129 = Workspace
                u130 = v18
                u131 = LocalPlayer

                t17 = {}
                do
                    t17[1] = {name = 'Neon Cyan', id = '11770890197'}
                    t17[2] = {name = 'Electric Purple', id = '11770691141'}
                    t17[3] = {name = 'Precision Dot', id = '10878218308'}
                    t17[4] = {name = 'Aim Cross', id = '10891594349'}
                    t17[5] = {name = 'Blue Spec', id = '11720475063'}
                    t17[6] = {name = 'Circle Dot', id = '10831379335'}
                    t17[7] = {name = 'Green Hit', id = '8375241602'}
                end

                getgenv().RuzOldPos = nil
                getgenv().RuzFPDH = Workspace.FallenPartsDestroyHeight
                u157 = false
                local u158 = LocalPlayer
                local u159 = v18
                local u160 = Workspace
                local function v161(p29)
                    if not u157 then
                        local Character = u158.Character
                        if Character then
                            local Humanoid = Character:FindFirstChildOfClass('Humanoid')
                            if Humanoid then
                                local RootPart = Humanoid.RootPart
                                if RootPart then
                                    local Character4 = p29.Character
                                    if Character4 then
                                        local Humanoid2 = Character4:FindFirstChildOfClass('Humanoid')
                                        local v663 = Humanoid2 and Humanoid2.RootPart
                                        local Head = Character4:FindFirstChild('Head')
                                        local Accessory = Character4:FindFirstChildOfClass('Accessory')
                                        local v666 = Accessory and Accessory:FindFirstChild('Handle')
                                        if RootPart.Velocity.Magnitude < 50 then getgenv().RuzOldPos = RootPart.CFrame end
                                        if not Humanoid2 or not Humanoid2.Sit then
                                            local v667 = Head or (v666 or Humanoid2)
                                            if v667 then u160.CurrentCamera.CameraSubject = v667 end
                                            if Character4:FindFirstChildWhichIsA('BasePart') then
                                                local u668 = RootPart
                                                local u669 = Character
                                                local function u670(p30, p31, p32)
                                                    u668.CFrame = CFrame.new(p30.Position) * p31 * p32
                                                    pcall(function() u669:SetPrimaryPartCFrame(CFrame.new(p30.Position) * p31 * p32) end)
                                                    u668.Velocity = Vector3.new(90000000, 900000000, 90000000)
                                                    u668.RotVelocity = Vector3.new(900000000, 900000000, 900000000)
                                                end
                                                local u671 = RootPart
                                                u157 = true
                                                u160.FallenPartsDestroyHeight = (0 / 0)
                                                local BodyVelocity = Instance.new('BodyVelocity')
                                                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                                                BodyVelocity.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
                                                BodyVelocity.Parent = RootPart
                                                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                                                local v673 = v663 or (Head or v666)
                                                if not v673 then
                                                    u159:Notify({Title = 'CatFeex 0.1', Content = p29.Name .. ' — no valid fling part.', Duration = 3, Icon = 'bell'})
                                                else
                                                    (function(p33)
                                                        local v904 = tick() + 2.5
                                                        local n18 = 0
                                                        while u671 and Humanoid2 do
                                                            local Magnitude = p33.Velocity.Magnitude
                                                            if not (Magnitude < 40) then
                                                                local MoveDirection = Humanoid2.MoveDirection
                                                                local WalkSpeed = Humanoid2.WalkSpeed
                                                                u670(p33, CFrame.new(MoveDirection.X * WalkSpeed * 0.12, 3, MoveDirection.Z * WalkSpeed * 0.12), CFrame.Angles(1.5707963267948966, 0, 0))
                                                                u671.Velocity = Vector3.new(900000000, 900000000, 900000000) task.wait()
                                                                u670(p33, CFrame.new(-MoveDirection.X * WalkSpeed * 0.06, -3, -MoveDirection.Z * WalkSpeed * 0.06), CFrame.Angles(0, 0, 0))
                                                                u671.Velocity = Vector3.new(900000000, 900000000, 900000000) task.wait()
                                                            else
                                                                n18 = n18 + 100
                                                                u670(p33, CFrame.new(0, 1.5, 0) + Humanoid2.MoveDirection * Magnitude / 1.25, CFrame.Angles(math.rad(n18), 0, 0)) task.wait()
                                                                u670(p33, CFrame.new(0, -1.5, 0) + Humanoid2.MoveDirection * Magnitude / 1.25, CFrame.Angles(math.rad(n18), 0, 0)) task.wait()
                                                            end
                                                            if v904 < tick() then return end
                                                        end
                                                    end)(v673)
                                                end
                                                BodyVelocity:Destroy()
                                                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                                                u160.CurrentCamera.CameraSubject = Humanoid
                                                if getgenv().RuzOldPos then
                                                    local n19 = 0
                                                    repeat
                                                        n19 = n19 + 1
                                                        RootPart.CFrame = getgenv().RuzOldPos * CFrame.new(0, 0.5, 0)
                                                        pcall(function() Character:SetPrimaryPartCFrame(getgenv().RuzOldPos * CFrame.new(0, 0.5, 0)) end)
                                                        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                                                        for _, child in ipairs(Character:GetChildren())do
                                                            if child:IsA('BasePart') then child.Velocity = Vector3.new() child.RotVelocity = Vector3.new() end
                                                        end
                                                        task.wait()
                                                    until n19 > 30 or (RootPart.Position - getgenv().RuzOldPos.p).Magnitude < 25
                                                    u160.FallenPartsDestroyHeight = getgenv().RuzFPDH
                                                    u159:Notify({Title = 'CatFeex 0.1', Content = 'Returned to previous position.', Duration = 3, Icon = 'bell'})
                                                end
                                                u157 = false
                                                return
                                            end
                                            return
                                        end
                                        u159:Notify({Title = 'CatFeex 0.1', Content = p29.Name .. ' is sitting, skipped.', Duration = 3, Icon = 'bell'})
                                        return
                                    end
                                    return
                                end
                                return
                            end
                            return
                        end
                        return
                    end
                end

                u162 = v18 u163 = Players u164 = LocalPlayer u165 = v161 u166 = v18 u167 = Players u168 = LocalPlayer u169 = v161
                local t15 = {
                    GlobalShadows = Lighting.GlobalShadows,
                    Brightness = Lighting.Brightness,
                    Ambient = Lighting.Ambient,
                    OutdoorAmbient = Lighting.OutdoorAmbient,
                }
                local t16 = {}
                u172 = nil u173 = Lighting u174 = t15 u175 = Workspace
                function u176(p34)
                    if p34:IsA('BasePart') then
                        if not t16[p34] then t16[p34] = {Material = p34.Material, CastShadow = p34.CastShadow} end
                        p34.Material = Enum.Material.SmoothPlastic
                        p34.CastShadow = false
                    end
                    if p34:IsA('Decal') or p34:IsA('Texture') then
                        if not t16[p34] then t16[p34] = {Transparency = p34.Transparency} end
                        p34.Transparency = 1
                    end
                end
                u177 = TextLabel u178 = v18
                local u179 = Lighting
                local u180 = t15
                local u181 = TextLabel
                local u182 = v18
                function v183()
                    u15 = false
                    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
                    u179.GlobalShadows = u180.GlobalShadows
                    u179.Brightness = u180.Brightness
                    u179.Ambient = u180.Ambient
                    u179.OutdoorAmbient = u180.OutdoorAmbient
                    if u172 then u172:Disconnect() u172 = nil end
                    for k, v in pairs(t16)do
                        if k and k.Parent then
                            pcall(function() for k2, v2 in pairs(v)do k[k2] = v2 end end)
                        end
                    end
                    t16 = {}
                    u181.Visible = false
                    u182:Notify({Title = 'CatFeex 0.1', Content = 'Low Graphics OFF', Duration = 3, Icon = 'bell'})
                end
                u184 = v183 u185 = Lighting u186 = v18 u187 = Lighting u188 = t15 u189 = v18
            end

            u198 = false u199 = false
            id = t17[1].id
            u201 = nil u202 = nil
            local u203 = RunService
            local function v204()
                if u202 then u202:Disconnect() u202 = nil end
                if not u199 or not u201 or not u201.Parent then
                    if u201 then u201.Rotation = 0 end
                    return
                end
                u202 = u203.RenderStepped:Connect(function()
                    if u201 and u201.Parent and u201.Visible then u201.Rotation = u201.Rotation + 4 end
                end)
            end
            u205 = RunService u206 = UserInputService u207 = LocalPlayer u208 = v204 u209 = v18 u210 = v204 u211 = t17 u212 = v21

            local CatFeex_BtnLayer = game.CoreGui:FindFirstChild('CatFeex_BtnLayer')
            if CatFeex_BtnLayer then CatFeex_BtnLayer:Destroy() end
            local ScreenGui = Instance.new('ScreenGui', game.CoreGui)
            ScreenGui.Name = 'CatFeex_BtnLayer'
            ScreenGui.ResetOnSpawn = false
            ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            ScreenGui.DisplayOrder = 10
            local u215 = ScreenGui
            t25 = {}
            local u217 = UserInputService
            function u218(p35)
                local u740 = nil
                local p36Position = nil
                local Position = nil
                local InputBegan = p35.InputBegan
                local u744 = p35
                InputBegan:Connect(function(p36)
                    if p36.UserInputType == Enum.UserInputType.MouseButton1 or p36.UserInputType == Enum.UserInputType.Touch then
                        u740 = true
                        p36Position = p36.Position
                        Position = u744.Position
                    end
                end)
                local InputChanged = p35.InputChanged
                local u746 = p35
                InputChanged:Connect(function(p37)
                    if u740 then
                        if p37.UserInputType == Enum.UserInputType.MouseMovement or p37.UserInputType == Enum.UserInputType.Touch then
                            local v923 = p37.Position - p36Position
                            u746.Position = UDim2.new(Position.X.Scale, Position.X.Offset + v923.X, Position.Y.Scale, Position.Y.Offset + v923.Y)
                        end
                        return
                    end
                end)
                u217.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        u740 = false
                    end
                end)
            end
            local u219 = t25
            function v220(p38, p39, p40, p41, p42)
                if u219[p38] then
                    u219[p38].btn:Destroy()
                    u219[p38] = nil
                end
                local TextButton = Instance.new('TextButton', u215)
                TextButton.Name = 'RuzBtn_' .. p38
                TextButton.Size = p40
                TextButton.Position = p39
                TextButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                TextButton.BackgroundTransparency = 0.6
                TextButton.Text = ''
                TextButton.AutoButtonColor = false
                TextButton.BorderSizePixel = 0
                Instance.new('UICorner', TextButton).CornerRadius = UDim.new(0, p40.Y.Offset * 0.2)
                local UIStroke = Instance.new('UIStroke', TextButton)
                UIStroke.Color = p41
                UIStroke.Thickness = 1.3
                UIStroke.Transparency = 0.5
                UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                local TextLabel = Instance.new('TextLabel', TextButton)
                TextLabel.Name = 'Lbl'
                TextLabel.Size = UDim2.new(1, 0, 1, 0)
                TextLabel.BackgroundTransparency = 1
                TextLabel.Text = p42
                TextLabel.TextColor3 = p41
                TextLabel.Font = Enum.Font.GothamBold
                TextLabel.TextSize = math.max(10, p40.Y.Offset * 0.14)
                TextLabel.TextYAlignment = Enum.TextYAlignment.Center
                TextLabel.TextXAlignment = Enum.TextXAlignment.Center
                u218(TextButton)
                u219[p38] = {btn = TextButton, stroke = UIStroke, lbl = TextLabel}
                return u219[p38]
            end
            local u221 = RunService
            function u222(p43, p44)
                local YOffset = p43.btn.Size.Y.Offset
                local v760 = math.floor(YOffset * 0.55)
                local ImageLabel = Instance.new('ImageLabel', p43.btn)
                ImageLabel.Name = 'SpinImg'
                ImageLabel.Size = UDim2.new(0, v760, 0, v760)
                ImageLabel.Position = UDim2.new(0.5, -v760 / 2, 0.5, -v760 / 2)
                ImageLabel.BackgroundTransparency = 1
                ImageLabel.Image = 'rbxassetid://' .. tostring(p44)
                p43.img = ImageLabel
                p43.lbl.Size = UDim2.new(1, 0, 0.28, 0)
                p43.lbl.Position = UDim2.new(0, 0, 0.72, 0)
                p43.lbl.TextSize = math.max(9, YOffset * 0.12)
                local spawn = task.spawn
                local u765 = ImageLabel
                spawn(function()
                    while u765 and u765.Parent do
                        u765.Rotation = u765.Rotation + 4
                        u221.RenderStepped:Wait()
                    end
                end)
                return ImageLabel
            end
            uDim2_2 = UDim2.new(0, 88, 0, 88)
            uDim2 = UDim2.new(0, 56, 0, 56)
            t26 = {
                GoldBomb = UDim2.new(0.5, -210, 0.78, 0),
                NormalBomb = UDim2.new(0.5, -110, 0.78, 0),
                Shoot = UDim2.new(0.5, -10, 0.78, 0),
                AutoShoot = UDim2.new(0.5, 82, 0.78, 16),
                AIM = UDim2.new(0.5, 175, 0.78, 16),
                ESP = UDim2.new(0.5, 248, 0.78, 16),
                Flick = UDim2.new(0.5, 320, 0.78, 16),
                Speed = UDim2.new(0.5, -278, 0.78, 16),
                Stretch = UDim2.new(0.5, -214, 0.78, 16),
                GrabGun = UDim2.new(0.5, 90, 0.68, 16),
                WallHop = UDim2.new(0.5, 154, 0.68, 16),
                FlingMurderer = UDim2.new(0.5, -278, 0.68, 16),
                FlingSheriff = UDim2.new(0.5, -214, 0.68, 16),
            }
            local u226 = t25
            local u227 = v220
            local u228 = t26
            local u229 = uDim2_2
            local u230 = v18
            local u231 = v115
            function v232(p45)
                if p45 then
                    u227('GoldBomb', u228.GoldBomb, u229, Color3.fromRGB(255, 215, 0), 'GOLD\nJUMP')
                    u226.GoldBomb.btn.MouseButton1Click:Connect(function()
                        if not u9 then u231('GoldBomb', true) return end
                        u230:Notify({Title = 'CatFeex 0.1', Content = 'Gold Bomb on cooldown.', Duration = 3, Icon = 'bell'})
                    end)
                    return
                end
                if u226.GoldBomb then u226.GoldBomb.btn:Destroy() u226.GoldBomb = nil end
            end
            local u233 = t25
            local u234 = v220
            local u235 = t26
            local u236 = uDim2_2
            local u237 = v18
            local u238 = v115
            function v239(p46)
                if p46 then
                    u234('NormalBomb', u235.NormalBomb, u236, Color3.fromRGB(0, 170, 255), 'NORMAL\nJUMP')
                    u233.NormalBomb.btn.MouseButton1Click:Connect(function()
                        if not u10 then u238('FakeBomb', false) return end
                        u237:Notify({Title = 'CatFeex 0.1', Content = 'Normal Bomb on cooldown.', Duration = 3, Icon = 'bell'})
                    end)
                    return
                end
                if u233.NormalBomb then u233.NormalBomb.btn:Destroy() u233.NormalBomb = nil end
            end
        end

        local u240 = t25
        local u241 = v220
        local u242 = t26
        local u243 = uDim2_2
        function v244(p47)
            if p47 then
                local v769 = u241('Shoot', u242.Shoot, u243, Color3.fromRGB(255, 255, 255), 'SHOOT')
                u222(v769, 5159914132)
                v769.btn.MouseButton1Click:Connect(u98)
                return
            end
            if u240.Shoot then u240.Shoot.btn:Destroy() u240.Shoot = nil end
        end

        local u240c = t25
        local u241c = v220
        local u242c = t26
        local u243c = uDim2
        local u251c = v18
        function v244autoshoot(p47c)
            if p47c then
                local v770 = u241c('AutoShoot', u242c.AutoShoot, u243c, Color3.fromRGB(255, 60, 60), 'AUTO\nSHOOT')
                u240c.AutoShoot.btn.MouseButton1Click:Connect(function()
                    local newState = not getgenv().CatFeexAutoShootOn
                    getgenv().CatFeexAutoShootOn = newState
                    if getgenv().CatFeexAutoShoot then
                        getgenv().CatFeexAutoShoot(newState)
                    end
                    u251c:Notify({
                        Title = 'CatFeex 0.1',
                        Content = newState and 'Auto Shoot ON' or 'Auto Shoot OFF',
                        Duration = 3,
                        Icon = 'bell',
                    })
                end)
                return
            end
            if u240c.AutoShoot then u240c.AutoShoot.btn:Destroy() u240c.AutoShoot = nil end
        end

        local u240b = t25
        local u241b = v220
        local u242b = t26
        local u243b = uDim2
        local u251b = v18
        function v244aim(p47b)
            if p47b then
                u241b('AIM', u242b.AIM, u243b, Color3.fromRGB(255, 100, 180), 'AIM\nOFF')
                u240b.AIM.btn.MouseButton1Click:Connect(function()
                    local newState = not getgenv().CatFeexAimActive
                    if getgenv().CatFeexAimSet then getgenv().CatFeexAimSet(newState) end
                    u251b:Notify({Title = 'CatFeex 0.1', Content = newState and 'AIM ON — камера на мурдерере' or 'AIM OFF', Duration = 3, Icon = 'bell'})
                end)
                return
            end
            if u240b.AIM then u240b.AIM.btn:Destroy() u240b.AIM = nil end
        end

        local u245 = t25
        local u246 = v220
        local u247 = t26
        local u248 = uDim2
        local u249 = v78
        local u250 = v68
        local u251 = v18
        function u252(p48)
            if p48 then
                u246('ESP', u247.ESP, u248, Color3.fromRGB(10, 140, 30), 'ESP\nOFF')
                u245.ESP.btn.MouseButton1Click:Connect(function()
                    local v926 = not u61
                    u61 = v926
                    if not v926 then
                        if u62 then u62:Disconnect() u62 = nil end
                        task.delay(0.1, u250)
                    else
                        u249()
                    end
                    u251:Notify({Title = 'CatFeex 0.1', Content = u61 and 'ESP ON' or 'ESP OFF', Duration = 3, Icon = 'bell'})
                end)
                return
            end
            if u245.ESP then u245.ESP.btn:Destroy() u245.ESP = nil end
        end
        local u253 = t25
        local u254 = v220
        local u255 = t26
        local u256 = uDim2
        function u257(p49)
            if p49 then
                u254('Flick', u255.Flick, u256, Color3.fromRGB(180, 50, 255), 'FLICK')
                u253.Flick.btn.MouseButton1Click:Connect(u104)
                return
            end
            if u253.Flick then u253.Flick.btn:Destroy() u253.Flick = nil end
        end
        local u258 = t25
        local u259 = v220
        local u260 = t26
        local u261 = uDim2
        local u262 = v18
        function u263(p50)
            if p50 then
                u259('Speed', u260.Speed, u261, Color3.fromRGB(0, 140, 120), 'SPEED')
                u258.Speed.btn.MouseButton1Click:Connect(function()
                    u116 = not u116
                    u262:Notify({Title = 'CatFeex 0.1', Content = u116 and 'Speed Glitch ON' or 'Speed Glitch OFF', Duration = 3, Icon = 'bell'})
                end)
                return
            end
            if u258.Speed then u258.Speed.btn:Destroy() u258.Speed = nil end
        end
        local u264 = t25
        local u265 = v220
        local u266 = t26
        local u267 = uDim2
        local u268 = v125
        local u269 = v18
        function u270(p51)
            if p51 then
                u265('Stretch', u266.Stretch, u267, Color3.fromRGB(200, 80, 0), 'STRETCH')
                u264.Stretch.btn.MouseButton1Click:Connect(function()
                    u120 = not u120
                    u268(u120)
                    u269:Notify({Title = 'CatFeex 0.1', Content = u120 and 'Stretch ON' or 'Stretch OFF', Duration = 3, Icon = 'bell'})
                end)
                return
            end
            if u264.Stretch then u264.Stretch.btn:Destroy() u264.Stretch = nil end
        end
    end

    local u271 = t25
    local u272 = v220
    local u273 = t26
    local u274 = uDim2

    local function u275()
        local GunDrop = u129:FindFirstChild('GunDrop', true)
        if GunDrop then
            local Character = u131.Character
            local v611 = Character and Character:FindFirstChild('HumanoidRootPart')
            if v611 then
                local targetCF = CFrame.new(v611.Position + Vector3.new(0, 2, 0))
                local moved = false
                if GunDrop:IsA('Model') then
                    local main = GunDrop.PrimaryPart or GunDrop:FindFirstChild('Handle') or GunDrop:FindFirstChildWhichIsA('BasePart')
                    if main then
                        pcall(function() GunDrop:PivotTo(targetCF) end)
                        for _, p in ipairs(GunDrop:GetDescendants()) do
                            if p:IsA('BasePart') then pcall(function() p.AssemblyLinearVelocity = Vector3.zero p.AssemblyAngularVelocity = Vector3.zero end) end
                        end
                        moved = true
                    end
                elseif GunDrop:IsA('BasePart') then
                    pcall(function() GunDrop.CFrame = targetCF GunDrop.AssemblyLinearVelocity = Vector3.zero GunDrop.AssemblyAngularVelocity = Vector3.zero end)
                    moved = true
                else
                    local p = GunDrop:FindFirstChildWhichIsA('BasePart')
                    if p then
                        pcall(function() p.CFrame = targetCF p.AssemblyLinearVelocity = Vector3.zero p.AssemblyAngularVelocity = Vector3.zero end)
                        moved = true
                    end
                end
                if moved then
                    u130:Notify({Title = 'CatFeex 0.1', Content = 'Gun teleported to you!', Duration = 3, Icon = 'bell'})
                else
                    u130:Notify({Title = 'CatFeex 0.1', Content = 'Gun has no valid part!', Duration = 3, Icon = 'bell'})
                end
                return
            end
            return
        end
        u130:Notify({Title = 'CatFeex 0.1', Content = 'No gun on map!', Duration = 3, Icon = 'bell'})
    end

    function u276(p52)
        if p52 then
            u272('GrabGun', u273.GrabGun, u274, Color3.fromRGB(200, 120, 0), 'GRAB\nGUN')
            u271.GrabGun.btn.MouseButton1Click:Connect(u275)
            return
        end
        if u271.GrabGun then u271.GrabGun.btn:Destroy() u271.GrabGun = nil end
    end
    local u277 = t25
    local u278 = v220
    local u279 = t26
    local u280 = uDim2
    function u281(p53)
        if p53 then
            u278('WallHop', u279.WallHop, u280, Color3.fromRGB(0, 210, 210), 'WALL\nHOP')
            u277.WallHop.btn.MouseButton1Click:Connect(u110)
            return
        end
        if u277.WallHop then u277.WallHop.btn:Destroy() u277.WallHop = nil end
    end
    local u282 = t25
    local u283 = v220
    local u284 = t26
    local u285 = uDim2
    local function u286()
        if not u157 then
            for _, player in ipairs(u163:GetPlayers())do
                if player ~= u164 and player.Character and (player.Backpack:FindFirstChild('Knife') or player.Character and player.Character:FindFirstChild('Knife')) then
                    local Humanoid = player.Character:FindFirstChildOfClass('Humanoid')
                    if Humanoid and Humanoid.Health > 0 then
                        u162:Notify({Title = 'CatFeex 0.1', Content = 'Flinging: ' .. player.Name, Duration = 3, Icon = 'bell'})
                        task.spawn(u165, player)
                        return
                    end
                end
            end
            u162:Notify({Title = 'CatFeex 0.1', Content = 'No knife player found!', Duration = 3, Icon = 'bell'})
            return
        end
        u162:Notify({Title = 'CatFeex 0.1', Content = 'Fling in progress...', Duration = 3, Icon = 'bell'})
    end
    function u287(p54)
        if p54 then
            u283('FlingMurderer', u284.FlingMurderer, u285, Color3.fromRGB(255, 50, 50), 'FLING\nMURD')
            u282.FlingMurderer.btn.MouseButton1Click:Connect(u286)
            return
        end
        if u282.FlingMurderer then u282.FlingMurderer.btn:Destroy() u282.FlingMurderer = nil end
    end
    local u288 = t25
    local u289 = v220
    local u290 = t26
    local u291 = uDim2
    local function u292()
        if not u157 then
            for _, player in ipairs(u167:GetPlayers())do
                if player ~= u168 and player.Character and (player.Backpack:FindFirstChild('Gun') or player.Character and player.Character:FindFirstChild('Gun')) then
                    local Humanoid = player.Character:FindFirstChildOfClass('Humanoid')
                    if Humanoid and Humanoid.Health > 0 then
                        u166:Notify({Title = 'CatFeex 0.1', Content = 'Flinging: ' .. player.Name, Duration = 3, Icon = 'bell'})
                        task.spawn(u169, player)
                        return
                    end
                end
            end
            u166:Notify({Title = 'CatFeex 0.1', Content = 'No gun player found!', Duration = 3, Icon = 'bell'})
            return
        end
        u166:Notify({Title = 'CatFeex 0.1', Content = 'Fling in progress...', Duration = 3, Icon = 'bell'})
    end
    function u293(p55)
        if p55 then
            u289('FlingSheriff', u290.FlingSheriff, u291, Color3.fromRGB(40, 130, 255), 'FLING\nSHERIF')
            u288.FlingSheriff.btn.MouseButton1Click:Connect(u292)
            return
        end
        if u288.FlingSheriff then u288.FlingSheriff.btn:Destroy() u288.FlingSheriff = nil end
    end

    local Heartbeat = RunService.Heartbeat
    local u295 = t25
    local u296 = LocalPlayer
    local u297 = UserInputService
    local u298 = Workspace
    local u299 = Players

    Heartbeat:Connect(function()
        if u295.GoldBomb then u295.GoldBomb.lbl.Text = u9 and 'WAIT...' or 'GOLD\nJUMP' end
        if u295.NormalBomb then u295.NormalBomb.lbl.Text = u10 and 'WAIT...' or 'NORMAL\nJUMP' end
        if u295.Shoot and u295.Shoot.img then
            local v779 = u296.Backpack:FindFirstChild('Knife') or u296.Character and u296.Character:FindFirstChild('Knife')
            u295.Shoot.img.Image = v779 and 'rbxassetid://9695655416' or 'rbxassetid://5159914132'
            u295.Shoot.lbl.Text = v779 and 'THROW' or 'SHOOT'
        end
        if u295.AutoShoot then
            local autoOn = getgenv().CatFeexAutoShootOn == true
            local v779b = autoOn and Color3.fromRGB(50, 255, 100) or Color3.fromRGB(255, 60, 60)
            u295.AutoShoot.lbl.Text = autoOn and 'AUTO\nON' or 'AUTO\nOFF'
            u295.AutoShoot.lbl.TextColor3 = v779b
            u295.AutoShoot.stroke.Color = v779b
        end
        if u295.AIM then
            local aimOn = getgenv().CatFeexAimActive == true
            local murdererFound = false
            for _, plr in ipairs(u299:GetPlayers()) do
                if plr ~= u296 and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass('Humanoid')
                    local bp = plr:FindFirstChild('Backpack')
                    local hasKnife = plr.Character:FindFirstChild('Knife') or (bp and bp:FindFirstChild('Knife'))
                    if hum and hum.Health > 0 and hasKnife then murdererFound = true break end
                end
            end
            if aimOn and murdererFound then
                u295.AIM.lbl.Text = 'AIM\nON'
                u295.AIM.lbl.TextColor3 = Color3.fromRGB(255, 80, 200)
                u295.AIM.stroke.Color = Color3.fromRGB(255, 80, 200)
            elseif aimOn and not murdererFound then
                u295.AIM.lbl.Text = 'NO\nMURD'
                u295.AIM.lbl.TextColor3 = Color3.fromRGB(200, 100, 100)
                u295.AIM.stroke.Color = Color3.fromRGB(200, 100, 100)
            else
                u295.AIM.lbl.Text = 'AIM\nOFF'
                u295.AIM.lbl.TextColor3 = Color3.fromRGB(255, 100, 180)
                u295.AIM.stroke.Color = Color3.fromRGB(255, 100, 180)
            end
        end
        if u295.ESP then
            local v780 = u61 and Color3.fromRGB(50, 220, 80) or Color3.fromRGB(10, 140, 30)
            u295.ESP.lbl.Text = u61 and 'ESP\nON' or 'ESP\nOFF'
            u295.ESP.lbl.TextColor3 = v780
            u295.ESP.stroke.Color = v780
        end
        if u295.Flick then
            local v781 = u297.MouseBehavior == Enum.MouseBehavior.LockCenter
            local v782 = u99 and Color3.fromRGB(255, 120, 0) or (v781 and Color3.fromRGB(120, 200, 255) or Color3.fromRGB(180, 50, 255))
            u295.Flick.lbl.Text = u99 and 'WAIT...' or 'FLICK'
            u295.Flick.lbl.TextColor3 = v782
            u295.Flick.stroke.Color = v782
        end
        if u295.WallHop then
            local v783 = u297.MouseBehavior == Enum.MouseBehavior.LockCenter
            local v784 = u105 and Color3.fromRGB(255, 120, 0) or (v783 and Color3.fromRGB(0, 255, 220) or Color3.fromRGB(0, 210, 210))
            u295.WallHop.lbl.Text = u105 and 'WAIT...' or 'WALL\nHOP'
            u295.WallHop.lbl.TextColor3 = v784
            u295.WallHop.stroke.Color = v784
        end
        if u295.Speed then
            local v785 = u116 and Color3.fromRGB(0, 220, 200) or Color3.fromRGB(0, 140, 120)
            u295.Speed.lbl.Text = u116 and 'SPEED\nON' or 'SPEED'
            u295.Speed.lbl.TextColor3 = v785
            u295.Speed.stroke.Color = v785
        end
        if u295.Stretch then
            local v786 = u120 and Color3.fromRGB(255, 140, 30) or Color3.fromRGB(200, 80, 0)
            u295.Stretch.lbl.Text = u120 and 'STRETCH\nON' or 'STRETCH'
            u295.Stretch.lbl.TextColor3 = v786
            u295.Stretch.stroke.Color = v786
        end
        if u295.GrabGun then
            local GunDrop = u298:FindFirstChild('GunDrop', true)
            local v788 = GunDrop and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(200, 100, 0)
            u295.GrabGun.lbl.Text = GunDrop and 'GRAB\nGUN' or 'NO\nGUN'
            u295.GrabGun.lbl.TextColor3 = v788
            u295.GrabGun.stroke.Color = v788
        end
    end)

    v18:Popup({
        Title = 'CatFeex 0.1',
        Icon = 'sparkles',
        Content = 'v0.1 loaded!\nSilent Aim + Kill Murderer + Kill All.',
        Buttons = {{Title = 'Start', Icon = 'arrow-right', Variant = 'Primary', Callback = function() end}},
    })

    local v300 = v18:CreateWindow({
        Title = 'CatFeex 0.1',
        Icon = 'rbxassetid://101992008196867',
        Author = 'Mmv And Mm2',
        Folder = 'CatFeexHub',
        Size = UDim2.fromOffset(700, 550),
        Theme = 'Crimson',
        Acrylic = false,
        HideSearchBar = false,
        OpenButton = {
            Title = 'CatFeex 0.1',
            Icon = 'rbxassetid://101992008196867',
            CornerRadius = UDim.new(1, 0),
            StrokeThickness = 2,
            Enabled = true,
            OnlyMobile = false,
            Color = ColorSequence.new(Color3.fromHex('#dc2626'), Color3.fromHex('#991b1b')),
        },
    }):Section({
        Title = 'CatFeex 0.1',
        Opened = true,
    })

    v301 = v300:Tab({Title = 'Main', Icon = 'zap'})
    v302 = v300:Tab({Title = 'Farm', Icon = 'tractor'})

    v301:Paragraph({
        Title = 'Auto-Loaded Buttons',
        Content = 'AIM, Auto Shoot, Gold Bomb, Normal Bomb and Shoot/Throw are enabled by default.',
    })

    local t27 = {Title = 'Show Gold Bomb', Default = true}
    local u304 = v232
    function t27.Callback(p56) u304(p56) end
    v301:Toggle(t27)

    local t28 = {Title = 'Show Normal Bomb', Default = true}
    local u306 = v239
    function t28.Callback(p57) u306(p57) end
    v301:Toggle(t28)

    local t29 = {Title = 'Show Shoot/Throw', Default = true}
    local u308 = v244
    function t29.Callback(p58) u308(p58) end
    v301:Toggle(t29)

    local t29a = {Title = 'Show Auto Shoot', Default = true}
    local u308a = v244autoshoot
    function t29a.Callback(p58a) u308a(p58a) end
    v301:Toggle(t29a)

    local t29b = {Title = 'Show AIM', Default = true}
    local u308b = v244aim
    function t29b.Callback(p58b) u308b(p58b) end
    v301:Toggle(t29b)

    v301:Divider()
    v301:Paragraph({
        Title   = 'Silent Aim',
        Content = 'При выстреле отправляет Shoot:FireServer в мурдерера (с предиктом позиции + подстройка под пинг).',
    })

    v301:Toggle({
        Title       = 'Silent Aimbot',
        Description = 'Авто-наводка на мурдерера при выстреле',
        Default     = false,
        Callback    = function(on)
            if getgenv().CatFeexSilentSet then getgenv().CatFeexSilentSet(on) end
            v18:Notify({Title = 'CatFeex 0.1', Content = on and 'Silent Aim ON' or 'Silent Aim OFF', Duration = 3, Icon = 'bell'})
        end,
    })

    v301:Toggle({
        Title       = 'Wallshot',
        Description = 'Стрелять через стены (origin за целью)',
        Default     = false,
        Callback    = function(on)
            if getgenv().CatFeexWallshotSet then getgenv().CatFeexWallshotSet(on) end
            v18:Notify({Title = 'CatFeex 0.1', Content = on and 'Wallshot ON' or 'Wallshot OFF', Duration = 3, Icon = 'bell'})
        end,
    })

    v301:Button({
        Title       = 'Shoot Now',
        Description = 'Разовый silent-выстрел в мурдерера',
        Callback    = function()
            if getgenv().CatFeexSilentShoot then task.spawn(getgenv().CatFeexSilentShoot) end
        end,
    })

    v301:Divider()

    v301:Toggle({
        Title = 'Kill Murderer',
        Description = 'Wallbang по мурдереру с обманом сервера (отпрыг 5 студов → выстрел → возврат)',
        Default = false,
        Callback = function(on)
            if farmKillMurdererSet then farmKillMurdererSet(on) end
            v18:Notify({Title = 'CatFeex 0.1', Content = on and 'Kill Murderer ON' or 'Kill Murderer OFF', Duration = 3, Icon = 'bell'})
        end,
    })
end

v301:Divider()
v301:Paragraph({Title = 'Optional Buttons', Content = 'Toggle to add or remove from screen.'})
v301:Toggle({Title = 'Load ESP Toggle', Default = false, Callback = function(p59) u252(p59) end})
v301:Toggle({Title = 'Load Flick', Default = false, Callback = function(p60) u257(p60) end})
v301:Toggle({Title = 'Load Grab Gun', Default = false, Callback = function(p61) u276(p61) end})
v301:Toggle({Title = 'Load Speed Glitch', Default = false, Callback = function(p62) u263(p62) end})
v301:Toggle({Title = 'Load Stretch', Default = false, Callback = function(p63) u270(p63) end})

v301:Button({
    Title = 'Stretch Resolution Slider',
    Description = '10% = very wide  /  100% = normal',
    Callback = function()
        local v607 = n17 * 100
        local v608 = math.round(v607)
        u126('Stretch Resolution', 10, 100, v608, 5, function(p64)
            n17 = p64 / 100
            if u120 then u127(true) end
            u128:Notify({Title = 'CatFeex 0.1', Content = 'Stretch set to ' .. p64 .. '%  (1.0 = normal)', Duration = 3, Icon = 'bell'})
        end, function()
            n17 = 0.5
            if u120 then u127(true) end
            u128:Notify({Title = 'CatFeex 0.1', Content = 'Stretch reset to 50%', Duration = 3, Icon = 'bell'})
        end)
    end,
})

v301:Toggle({Title = 'Load Fling Murderer', Default = false, Callback = function(p65) u287(p65) end})
v301:Toggle({Title = 'Load Fling Sheriff', Default = false, Callback = function(p66) u293(p66) end})
v301:Toggle({Title = 'Load Wall Hop', Default = false, Callback = function(p67) u281(p67) end})

v301:Divider()
v301:Paragraph({Title = 'Graphics', Content = 'Low: removes textures, boosts FPS.\nHigh: Bloom, SunRays.'})

local t32 = {Title = 'Low Graphics (FPS Boost)', Default = false}
local function u316()
    if u16 then
        u16 = false
        u173.Brightness = u174.Brightness
        u173.GlobalShadows = u174.GlobalShadows
        u173.Ambient = u174.Ambient
        u173.OutdoorAmbient = u174.OutdoorAmbient
        for _, child in pairs(u173:GetChildren())do
            if child:IsA('BloomEffect') or child:IsA('SunRaysEffect') or child:IsA('ColorCorrectionEffect') then child:Destroy() end
        end
    end
    u15 = true
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    pcall(function() setfpscap(9999) end)
    u173.GlobalShadows = false
    u173.Brightness = 2
    for _, descendant in ipairs(u175:GetDescendants())do
        pcall(function() u176(descendant) end)
    end
    if u172 then u172:Disconnect() end
    u172 = u175.DescendantAdded:Connect(function(descendant)
        task.wait(0.1)
        pcall(function() u176(descendant) end)
    end)
    u177.Visible = true
    u178:Notify({Title = 'CatFeex 0.1', Content = 'Low Graphics ON — FPS boost active', Duration = 3, Icon = 'bell'})
end
local u317 = v183
function t32.Callback(p71)
    if not p71 then u317() return end
    u316()
end
v301:Toggle(t32)

local t33 = {Title = 'High Graphics (Beautiful)', Default = false}
local function u319()
    if u15 then u184() end
    u16 = true
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level21 end)
    u185.GlobalShadows = true
    u185.Brightness = 3.5
    u185.Ambient = Color3.fromRGB(80, 80, 100)
    u185.OutdoorAmbient = Color3.fromRGB(100, 110, 130)
    local v701 = u185:FindFirstChildOfClass('BloomEffect') or Instance.new('BloomEffect', u185)
    v701.Intensity = 0.6 v701.Size = 24 v701.Threshold = 0.95
    local v702 = u185:FindFirstChildOfClass('SunRaysEffect') or Instance.new('SunRaysEffect', u185)
    v702.Intensity = 0.25 v702.Spread = 1
    local v703 = u185:FindFirstChildOfClass('ColorCorrectionEffect') or Instance.new('ColorCorrectionEffect', u185)
    v703.Saturation = 0.2 v703.Contrast = 0.1 v703.Brightness = 0.05
    u186:Notify({Title = 'CatFeex 0.1', Content = 'High Graphics ON', Duration = 3, Icon = 'bell'})
end
local function u320()
    u16 = false
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
    u187.Brightness = u188.Brightness
    u187.GlobalShadows = u188.GlobalShadows
    u187.Ambient = u188.Ambient
    u187.OutdoorAmbient = u188.OutdoorAmbient
    for _, child in pairs(u187:GetChildren())do
        if child:IsA('BloomEffect') or child:IsA('SunRaysEffect') or child:IsA('ColorCorrectionEffect') then child:Destroy() end
    end
    u189:Notify({Title = 'CatFeex 0.1', Content = 'High Graphics OFF', Duration = 3, Icon = 'bell'})
end
function t33.Callback(p72)
    if not p72 then u320() return end
    u319()
end
v301:Toggle(t33)

local t34 = {Title = 'FOV Slider', Description = 'Mobile-friendly field of view selector'}
local u322 = v25
local u323 = CurrentCamera
local u324 = v18
function t34.Callback()
    u322('Field of View', 30, 120, n3, 5, function(p73) n3 = p73 u323.FieldOfView = p73 end, function()
        n3 = 70 u323.FieldOfView = 70
        u324:Notify({Title = 'CatFeex 0.1', Content = 'FOV reset to 70', Duration = 3, Icon = 'bell'})
    end)
end
v301:Button(t34)

v301:Divider()
v301:Paragraph({Title = 'Extra Scripts', Content = 'Universal scripts and additional tools.'})

local t35 = {Title = 'Load Emotes GUI', Description = '7yd7 emote panel'}
local u326 = v18
function t35.Callback()
    local ok, result = pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua'))()
    end)
    u326:Notify({Title = 'CatFeex 0.1', Content = ok and 'Emotes GUI loaded!' or 'Error: ' .. tostring(result), Duration = 3, Icon = 'bell'})
end
v301:Button(t35)

local t36 = {Title = 'Load Infinite Yield', Description = 'Admin script'}
local u328 = v18
function t36.Callback()
    local ok, result = pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end)
    u328:Notify({Title = 'CatFeex 0.1', Content = ok and 'Infinite Yield loaded!' or 'Error: ' .. tostring(result), Duration = 3, Icon = 'bell'})
end
v301:Button(t36)

v301:Divider()

local t38 = {Title = 'Auto Ping Prediction', Description = 'Adds ping offset to shoot and throw', Default = false}
local u332 = v18
function t38.Callback(p75)
    u13 = p75
    u332:Notify({Title = 'CatFeex 0.1', Content = p75 and 'Ping Prediction ON' or 'Ping Prediction OFF', Duration = 3, Icon = 'bell'})
end
v301:Toggle(t38)

local t39 = {Title = 'Speed Glitch Slider', Description = 'Mobile-friendly speed selector'}
local u334 = v25
local u335 = v18
function t39.Callback()
    u334('Speed Glitch', 50, 600, n2, 10, function(p76) n2 = p76 end, function()
        n2 = 200
        u335:Notify({Title = 'CatFeex 0.1', Content = 'Speed reset to 200', Duration = 3, Icon = 'bell'})
    end)
end
v301:Button(t39)

v301:Dropdown({
    Title = 'Velocity Cap',
    Options = {'50', '100', '150', '200', '300', '500'},
    Default = '200',
    Callback = function(p77) n1 = tonumber(p77) or 200 end,
})

v302:Paragraph({
    Title = 'Auto Farm',
    Content = 'Автофарм 40 монет + автоматика:\nInnocent/Sheriff — наверх → grab gun → Kill Murderer\nMurderer — kill all\n★ Монеты ≤100 студов → TP + noclip ON\n★ Монеты 100–200 студов → плавный полёт без noclip (старая логика)\n★ Дальше 200 → игнор\n★ Если рядом монет нет — ждём',
})

v302:Button({
    Title = 'Farm Radius Slider',
    Description = 'Общий радиус фарма.\nМонеты за его пределами игнорируются полностью.\nПо умолчанию 200',
    Callback = function()
        u126('Farm Radius', 50, 400, farmMAX_FARM_DIST, 25, function(p)
            farmMAX_FARM_DIST = p
            v18:Notify({Title = 'CatFeex 0.1', Content = 'Farm radius = ' .. p .. ' studs', Duration = 3, Icon = 'bell'})
        end, function()
            farmMAX_FARM_DIST = 200
            v18:Notify({Title = 'CatFeex 0.1', Content = 'Farm radius reset to 200', Duration = 3, Icon = 'bell'})
        end)
    end,
})

v302:Button({
    Title = 'Near Distance Slider',
    Description = 'Порог "близкой" монеты.\n≤ этого расстояния → TP + noclip ON\n> этого расстояния → плавный полёт без noclip (старая логика)\nПо умолчанию 100',
    Callback = function()
        u126('Near Distance', 20, 400, farmNEAR_DIST, 10, function(p)
            farmNEAR_DIST = p
            v18:Notify({Title = 'CatFeex 0.1', Content = 'Near distance = ' .. p .. ' studs', Duration = 3, Icon = 'bell'})
        end, function()
            farmNEAR_DIST = 100
            v18:Notify({Title = 'CatFeex 0.1', Content = 'Near distance reset to 100', Duration = 3, Icon = 'bell'})
        end)
    end,
})

v302:Toggle({
    Title = 'Farm ON/OFF',
    Description = 'Автофарм монет: близкие через TP+noclip, дальние плавным полётом',
    Default = false,
    Callback = function(on) farmSet(on) end,
})

farmStatus = v302:Paragraph({
    Title = 'Status',
    Content = 'FARM OFF',
})

v302:Divider()
v302:Paragraph({
    Title = 'Murderer Tools',
    Content = 'Инструменты для роли Murderer.\nKILL ALL — все игроки телепортируются в ОДНУ точку перед тобой на 3 сек и стоят там.',
})

v302:Button({
    Title = 'KILL ALL (Murderer)',
    Description = 'Все игроки в одной точке перед тобой на 3 сек (не двигаются)',
    Callback = function() farmKillAll() end,
})

v302:Divider()
v302:Paragraph({
    Title = 'Infos',
    Content = 'Farm radius: 200 studs\nNear distance: 100 studs\nБлиже 100 → TP + noclip\n100–200 → плавный полёт без noclip\nДальше 200 → игнор\nMax coins: 40\nAuto-pickup Gun: ON',
})

local t40 = {Title = 'Enable ESP', Default = false}
local u337 = v78
local u338 = v68
local u339 = v18
function t40.Callback(p78)
    u61 = p78
    if not p78 then
        if u62 then u62:Disconnect() u62 = nil end
        task.delay(0.1, u338)
    else
        u337()
    end
    u339:Notify({Title = 'CatFeex 0.1', Content = p78 and 'ESP ON' or 'ESP OFF', Duration = 3, Icon = 'bell'})
end
v301:Toggle(t40)

local t41 = {Title = 'Show Murderer', Default = true}
local u341 = t3
function t41.Callback(p79) u341.Murderer = p79 end
v301:Toggle(t41)

local t42 = {Title = 'Show Sheriff', Default = true}
local u343 = t3
function t42.Callback(p80) u343.Sheriff = p80 end
v301:Toggle(t42)

local t43 = {Title = 'Show Hero', Default = true}
local u345 = t3
function t43.Callback(p81) u345.Hero = p81 end
v301:Toggle(t43)

local t44 = {Title = 'Show Innocents', Default = true}
local u347 = t3
function t44.Callback(p82) u347.Innocent = p82 end
v301:Toggle(t44)

local t45 = {Title = 'Show Self', Default = true}
local u349 = t3
function t45.Callback(p83) u349.Self = p83 end
v301:Toggle(t45)

local t46 = {Title = 'Dropped Gun ESP', Default = true}
local u351 = v18
function t46.Callback(p84)
    u17 = p84
    if not p84 then
        if u31 then u31:Destroy() u31 = nil end
        if u32 then u32:Destroy() u32 = nil end
        if u29 then u29:Destroy() u29 = nil end
    end
    u351:Notify({Title = 'CatFeex 0.1', Content = p84 and 'Gun ESP ON' or 'Gun ESP OFF', Duration = 3, Icon = 'bell'})
end
v301:Toggle(t46)

local t47 = {Title = 'Murderer Color', Default = Color3.fromRGB(255, 0, 0)}
local u353 = t4
function t47.Callback(p85) u353.Murderer = p85 end
v301:ColorPicker(t47)

local t48 = {Title = 'Sheriff Color', Default = Color3.fromRGB(0, 150, 255)}
local u355 = t4
function t48.Callback(p86) u355.Sheriff = p86 end
v301:ColorPicker(t48)

local t49 = {Title = 'Hero Color', Default = Color3.fromRGB(255, 220, 0)}
local u357 = t4
function t49.Callback(p87) u357.Hero = p87 end
v301:ColorPicker(t49)

local t50 = {Title = 'Innocent Color', Default = Color3.fromRGB(0, 255, 0)}
local u359 = t4
function t50.Callback(p88) u359.Innocent = p88 end
v301:ColorPicker(t50)

task.wait(0.4)
v232(true)
v239(true)
v244(true)
v244autoshoot(true)
v244aim(true)
v18:Notify({
    Title = 'CatFeex 0.1',
    Content = 'CatFeex 0.1 Ready!',
    Duration = 3,
    Icon = 'bell',
})
print('[CatFeex 0.1] loaded. Kill Murderer + Kill All + Farm.')
