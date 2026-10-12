local UserInputService, CurrentCamera, n1, n2, u13, n3, u15, u16, u17, v18, v25, u29, u31, u32, u61, u62, t3, t4, v68, v78, u120, n17, u126, u127, u128, v145, u147, u148, u149, u150, u151, u156, u172, u173, u174, u175, u176, u177, u178, v183, u184, u185, u186, u187, u188, u189, u198, u199, id, u201, u202, u205, u206, u207, u208, u209, u210, u211, u212, v232, v239, v244, u252, u257, u263, u270, u276, u281, u287, u293, v301, v302, farmSet, farmKillAll, farmKillMurderSet, farmSetSkinLaser

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
                    local farmSPEED = 32
                    local farmSTOP_DIST = 2.5
                    local farmMAX_COINS = 40
                    local farmJUMP_HEIGHT = 7.2
                    local farmJUMPS_UP = 100
                    local farmOFFSET_Y = 40
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

                    local STEP_STUDS = 3
                    local function f_predictAim(char)
                        if not char then return nil end
                        local hrp = char:FindFirstChild('HumanoidRootPart')
                        if not hrp then return nil end
                        local torso = char:FindFirstChild('Torso')
                            or char:FindFirstChild('UpperTorso')
                            or char:FindFirstChild('Head')
                            or hrp
                        local basePos = torso.Position
                        local vel = hrp.AssemblyLinearVelocity
                        local horiz = Vector3.new(vel.X, 0, vel.Z)
                        if horiz.Magnitude < 2 then
                            return basePos
                        end
                        return basePos + horiz.Unit * STEP_STUDS
                    end

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
                        if c and (c:FindFirstChild(name) or c:FindFirstChild(name:lower())) then return true end
                        if bp and (bp:FindFirstChild(name) or bp:FindFirstChild(name:lower())) then return true end
                        return false
                    end
                    local function f_myRole()
                        if f_playerHasTool(LocalPlayer, 'Knife') then return 'Murderer' end
                        if f_playerHasTool(LocalPlayer, 'Gun') then return 'Sheriff' end
                        return 'Innocent'
                    end

                    local function f_equipGun()
                        local c = LocalPlayer.Character
                        local bp = LocalPlayer:FindFirstChild('Backpack')
                        if not c then return nil end
                        local g = c:FindFirstChild('Gun') or c:FindFirstChild('gun')
                        if g then return g end
                        if bp then
                            local g2 = bp:FindFirstChild('Gun') or bp:FindFirstChild('gun')
                            if g2 then
                                pcall(function() g2.Parent = c end)
                                return c:FindFirstChild('Gun') or c:FindFirstChild('gun')
                            end
                        end
                        return nil
                    end

                    local function f_equipKnife()
                        local c = LocalPlayer.Character
                        local bp = LocalPlayer:FindFirstChild('Backpack')
                        if c and c:FindFirstChild('Knife') then return c.Knife end
                        if bp and bp:FindFirstChild('Knife') and c then bp.Knife.Parent = c return c:FindFirstChild('Knife') end
                        return nil
                    end

                    local function f_findMurderer()
                        local best, bestDist = nil, math.huge
                        local myRoot = f_getRoot()
                        local myPos = myRoot and myRoot.Position or Vector3.zero
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character then
                                local h = plr.Character:FindFirstChildOfClass('Humanoid')
                                local bp = plr:FindFirstChild('Backpack')
                                local hasK = plr.Character:FindFirstChild('Knife') ~= nil
                                local hasKbp = bp and bp:FindFirstChild('Knife') ~= nil
                                if h and h.Health > 0 and (hasK or hasKbp) then
                                    local hrp = plr.Character:FindFirstChild('HumanoidRootPart')
                                    if hrp then
                                        local d = (hrp.Position - myPos).Magnitude
                                        if d < bestDist then bestDist = d best = plr end
                                    else
                                        best = plr
                                    end
                                end
                            end
                        end
                        return best
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

                    local function f_fireGunSimple(gun, myRoot, aim)
                        if not gun then return false end
                        local ev = gun:FindFirstChild('Shoot') or gun:FindFirstChild('ShootEvent')
                        if not ev then return false end
                        local lookCF = CFrame.new(myRoot.Position + Vector3.new(0, 1, 0), aim)
                        local hitCF = CFrame.new(aim)
                        pcall(function() ev:FireServer(lookCF, hitCF) end)
                        return true
                    end

                    local function f_killMurderShoot()
                        local m = f_findMurderer()
                        if not m or not m.Character then return false end
                        local gun = f_equipGun()
                        if not gun then return false end
                        local myRoot = f_getRoot()
                        if not myRoot then return false end
                        local aim = f_predictAim(m.Character)
                        if not aim then return false end
                        return f_fireGunSimple(gun, myRoot, aim)
                    end

                    -- ================== KILL ALL ==================
                    local killAllOn = false
                    local killAllRunning = false
                    local killAllSaved = {}
                    local killAllOriginalCF = {}
                    local killAllWasAllDead = false

                    local function f_killAllRelease()
                        for hrp, st in pairs(killAllSaved) do
                            if hrp and hrp.Parent then pcall(function() hrp.Anchored = st.Anchored hrp.CanCollide = st.CanCollide end) end
                        end
                        killAllSaved = {}
                    end

                    local function f_killAllRestorePositions()
                        for plr, cf in pairs(killAllOriginalCF) do
                            if plr and plr.Parent and plr.Character then
                                local hrp = plr.Character:FindFirstChild('HumanoidRootPart')
                                if hrp then
                                    pcall(function()
                                        hrp.Anchored = false hrp.CFrame = cf
                                        hrp.AssemblyLinearVelocity = Vector3.zero
                                        hrp.AssemblyAngularVelocity = Vector3.zero
                                    end)
                                end
                            end
                        end
                        killAllOriginalCF = {}
                    end

                    local function f_killAllLoop()
                        killAllRunning = true
                        if farmStatus then farmStatus:SetDesc('KILL ALL: wait 3s...') end
                        local t0 = tick()
                        while killAllOn and (tick() - t0 < 3) do task.wait(0.1) end
                        if not killAllOn then killAllRunning = false if farmStatus then farmStatus:SetDesc('KILL ALL: OFF') end return end
                        if farmStatus then farmStatus:SetDesc('KILL ALL: ON') end
                        while killAllOn do
                            local r = f_getRoot()
                            if not r then task.wait(0.1)
                            else
                                local aheadCF = r.CFrame * CFrame.new(0, 0, -2)
                                local anyAlive = false
                                for _, plr in ipairs(Players:GetPlayers()) do
                                    if plr ~= LocalPlayer and plr.Character then
                                        local h = plr.Character:FindFirstChildOfClass('Humanoid')
                                        local hrp = plr.Character:FindFirstChild('HumanoidRootPart')
                                        if h and h.Health > 0 and hrp then
                                            anyAlive = true
                                            if not killAllOriginalCF[plr] then killAllOriginalCF[plr] = hrp.CFrame end
                                            if not killAllSaved[hrp] then killAllSaved[hrp] = {Anchored = hrp.Anchored, CanCollide = hrp.CanCollide} end
                                            pcall(function()
                                                hrp.Anchored = false hrp.CFrame = aheadCF
                                                hrp.AssemblyLinearVelocity = Vector3.zero
                                                hrp.AssemblyAngularVelocity = Vector3.zero
                                                hrp.Anchored = true hrp.CanCollide = false
                                            end)
                                        end
                                    end
                                end
                                local k = f_equipKnife()
                                if k then for i = 1, 3 do if not killAllOn then break end pcall(function() k:Activate() end) task.wait(0.05) end
                                else task.wait(0.05) end
                                if (not anyAlive) and next(killAllOriginalCF) ~= nil then
                                    if not killAllWasAllDead then
                                        killAllWasAllDead = true
                                        f_killAllRelease()
                                        task.wait(3)
                                        f_killAllRestorePositions()
                                        killAllWasAllDead = false
                                    else task.wait(0.05) end
                                else killAllWasAllDead = false task.wait(0.05) end
                            end
                        end
                        f_killAllRelease()
                        f_killAllRestorePositions()
                        killAllWasAllDead = false
                        killAllRunning = false
                        if farmStatus then farmStatus:SetDesc('KILL ALL: OFF') end
                    end

                    farmKillAll = function()
                        if killAllOn then
                            killAllOn = false
                            if farmStatus then farmStatus:SetDesc('KILL ALL: OFF') end
                            v18:Notify({Title = 'CatFeex 0.1', Content = 'KILL ALL OFF', Duration = 3, Icon = 'bell'})
                            return
                        end
                        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild('HumanoidRootPart') then
                            v18:Notify({Title = 'CatFeex 0.1', Content = 'Kill All: char not ready', Duration = 3, Icon = 'bell'})
                            return
                        end
                        if not f_playerHasTool(LocalPlayer, 'Knife') then
                            v18:Notify({Title = 'CatFeex 0.1', Content = 'Kill All: no Knife (not Murderer)', Duration = 3, Icon = 'bell'})
                            return
                        end
                        killAllOn = true
                        killAllOriginalCF = {}
                        killAllWasAllDead = false
                        if farmStatus then farmStatus:SetDesc('KILL ALL: 3s...') end
                        v18:Notify({Title = 'CatFeex 0.1', Content = 'KILL ALL ON (3s delay)', Duration = 3, Icon = 'bell'})
                        if not killAllRunning then task.spawn(f_killAllLoop) end
                    end

                    -- ================== FARM ==================
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
                        if c then for _, o in ipairs(c:GetChildren()) do if o.Name == 'Coin_Server' or o.Name == 'Coin' then n = n + 1 end end end
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
                    local function f_nearestCoin(fromPos)
                        f_scanCoins()
                        local best, bestD = nil, math.huge
                        for i = #farmCoinList, 1, -1 do
                            local p = farmCoinList[i]
                            if not p or not p.Parent or farmIgnored[p] then table.remove(farmCoinList, i)
                            elseif p ~= farmLastCoin then
                                local d = (p.Position - fromPos).Magnitude
                                if d < bestD then bestD = d best = p end
                            end
                        end
                        return best
                    end
                    local function f_flyToCoin(coin)
                        local t0 = tick()
                        local lastPos, lastT = nil, 0
                        while farmOn and not farmBagFull and coin and coin.Parent and (tick() - t0) < 14 do
                            if f_isLobby() then f_restore() return false end
                            local r = f_getRoot()
                            local h = f_getHead()
                            if not r then return false end
                            local targetRoot = f_rootPosForHead(coin.Position)
                            local hp = h and h.Position or r.Position
                            if (coin.Position - hp).Magnitude <= farmSTOP_DIST then r.CFrame = CFrame.new(targetRoot) f_hardStop(r) return true end
                            local dir = targetRoot - r.Position
                            local dist = dir.Magnitude
                            if dist < 0.5 then r.CFrame = CFrame.new(targetRoot) f_hardStop(r) return true end
                            local now = tick()
                            local didTp = false
                            if lastPos and (now - lastT) >= 0.3 then
                                if (r.Position - lastPos).Magnitude < 0.5 then
                                    local np = r.Position + dir.Unit * 5
                                    local look = Vector3.new(dir.X, 0, dir.Z)
                                    if look.Magnitude > 0.1 then r.CFrame = CFrame.new(np, np + look.Unit) else r.CFrame = CFrame.new(np) end
                                    f_hardStop(r) didTp = true
                                end
                                lastPos = r.Position lastT = now
                            elseif not lastPos then lastPos = r.Position lastT = now end
                            if not didTp then
                                local step = math.min(farmSPEED * 0.03, dist)
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

                    local function f_startAutoShootFarm()
                        if farmAutoShootConn then farmAutoShootConn:Disconnect() farmAutoShootConn = nil end
                        farmAutoShootConn = RunService.Heartbeat:Connect(function()
                            if not farmOn then return end
                            if not farmBagFull then return end
                            local m = f_findMurderer()
                            if not m or not m.Character then return end
                            local mHum = m.Character:FindFirstChildOfClass('Humanoid')
                            if not mHum or mHum.Health <= 0 then return end
                            if not f_canSee(m.Character) then return end
                            local c = LocalPlayer.Character
                            local bp = LocalPlayer:FindFirstChild('Backpack')
                            if c and not (c:FindFirstChild('Gun') or c:FindFirstChild('gun')) and bp then
                                local g = bp:FindFirstChild('Gun') or bp:FindFirstChild('gun')
                                if g then pcall(function() g.Parent = c end) end
                            end
                            f_killMurderShoot()
                        end)
                    end

                    local function f_onBagFull()
                        if farmBagFull then return end
                        farmBagFull = true
                        f_restore()
                        local role = f_myRole()
                        if role == 'Murderer' then
                            if not killAllOn then farmKillAll() end
                            if farmStatus then farmStatus:SetDesc('40 | Murderer: KILL ALL ON') end
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
                            f_startAutoShootFarm()
                            if farmStatus then farmStatus:SetDesc('40 | ' .. role .. ': sky + Kill Murder') end
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
                                    f_setNoclip(true)
                                    local hum = f_getHum()
                                    if hum then hum.PlatformStand = true hum.AutoRotate = false end
                                    while farmOn and not farmBagFull do
                                        if f_isLobby() then f_restore() break end
                                        local cnt = f_getCoinCount()
                                        if farmStatus then farmStatus:SetDesc('coins: ' .. cnt .. '/40 | ' .. f_myRole()) end
                                        if cnt >= farmMAX_COINS then f_onBagFull() break end
                                        f_tryPickupGun()
                                        local r = f_getRoot()
                                        if not r then
                                            task.wait(0.25)
                                        else
                                            local hum2 = f_getHum()
                                            if hum2 then hum2.PlatformStand = true end
                                            f_setNoclip(true)
                                            local coin = f_nearestCoin(r.Position)
                                            if coin then
                                                if f_flyToCoin(coin) then
                                                    farmIgnored[coin] = true
                                                    farmLastCoin = coin
                                                    task.wait(0.15)
                                                end
                                            else
                                                farmLastCoin = nil
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

                    -- ================== KILL MURDER (SPOOF) ==================
                    local farmKillMurderConn = nil
                    local killMurderLast = 0
                    local KILL_MURDER_COOLDOWN = 0.35
                    local KILL_MURDER_BACK = 5

                    local function f_killMurderSpoofShot()
                        local m = f_findMurderer()
                        if not m or not m.Character then return false, 'no_murderer' end
                        local mHum = m.Character:FindFirstChildOfClass('Humanoid')
                        if not mHum or mHum.Health <= 0 then return false, 'dead' end
                        local mRoot = m.Character:FindFirstChild('HumanoidRootPart')
                        if not mRoot then return false, 'no_root' end
                        local c = LocalPlayer.Character
                        local bp = LocalPlayer:FindFirstChild('Backpack')
                        if c and not (c:FindFirstChild('Gun') or c:FindFirstChild('gun')) and bp then
                            local g = bp:FindFirstChild('Gun') or bp:FindFirstChild('gun')
                            if g then pcall(function() g.Parent = c end) end
                        end
                        local gun = f_equipGun()
                        if not gun then return false, 'no_gun' end
                        local ev = gun:FindFirstChild('Shoot') or gun:FindFirstChild('ShootEvent')
                        if not ev then return false, 'no_event' end
                        local aim = f_predictAim(m.Character)
                        if not aim then return false, 'no_aim' end
                        local fakeCF = mRoot.CFrame * CFrame.new(0, 0, KILL_MURDER_BACK)
                        pcall(function() ev:FireServer(CFrame.new(fakeCF.Position + Vector3.new(0, 1, 0), aim), CFrame.new(aim)) end)
                        return true
                    end

                    local function f_setKillMurder(on)
                        if farmKillMurderConn then farmKillMurderConn:Disconnect() farmKillMurderConn = nil end
                        if not on then killMurderLast = 0 return end
                        killMurderLast = 0
                        farmKillMurderConn = RunService.Heartbeat:Connect(function()
                            if tick() - killMurderLast < KILL_MURDER_COOLDOWN then return end
                            killMurderLast = tick()
                            local ok, reason = f_killMurderSpoofShot()
                            if not ok and reason == 'dead' then
                                if farmKillMurderConn then farmKillMurderConn:Disconnect() farmKillMurderConn = nil end
                                v18:Notify({Title = 'CatFeex 0.1', Content = 'Kill Murder: murderer dead, OFF', Duration = 3, Icon = 'bell'})
                            end
                        end)
                    end

                    -- ================== AUTO SHOOT ==================
                    local autoShootConn = nil
                    local function f_setAutoShoot(on)
                        if autoShootConn then autoShootConn:Disconnect() autoShootConn = nil end
                        if not on then return end
                        autoShootConn = RunService.Heartbeat:Connect(function()
                            local char = LocalPlayer.Character
                            local root = char and char:FindFirstChild('HumanoidRootPart')
                            if not root then return end
                            local m = f_findMurderer()
                            if not m or not m.Character then return end
                            local mHum = m.Character:FindFirstChildOfClass('Humanoid')
                            if not mHum or mHum.Health <= 0 then return end
                            if not f_canSee(m.Character) then return end
                            local c = LocalPlayer.Character
                            local bp = LocalPlayer:FindFirstChild('Backpack')
                            if c and not (c:FindFirstChild('Gun') or c:FindFirstChild('gun')) and bp then
                                local g = bp:FindFirstChild('Gun') or bp:FindFirstChild('gun')
                                if g then pcall(function() g.Parent = c end) end
                            end
                            f_killMurderShoot()
                        end)
                    end
                    getgenv().CatFeexAutoShoot = f_setAutoShoot

                    -- ================== SKIN LAZER (GUN) ==================
                    local skinLaserOn = false
                    local skinOriginals = {}
                    local LASER_MESH_ID = 'rbxassetid://130099641'
                    local LASER_TEXTURE_ID = 'rbxassetid://130093033'
                    local LASER_HANDLE_SIZE = Vector3.new(0.26, 0.6, 1.25)
                    local LASER_MESH_SCALE = Vector3.new(0.56, 0.56, 0.56)

                    local function isGunTool(t)
                        if not t or not t:IsA('Tool') then return false end
                        return t.Name:lower() == 'gun'
                    end

                    local function saveSkinOrig(tool)
                        if skinOriginals[tool] then return end
                        local h = tool:FindFirstChild('Handle')
                        if not h then return end
                        local m = h:FindFirstChildOfClass('SpecialMesh') or h:FindFirstChildOfClass('BlockMesh') or h:FindFirstChildOfClass('CylinderMesh')
                        skinOriginals[tool] = {
                            Size = h.Size, Color = h.Color, Material = h.Material, Transparency = h.Transparency,
                            MeshClass = m and m.ClassName or nil,
                            MeshId = m and m:IsA('SpecialMesh') and m.MeshId or '',
                            TextureId = m and m:IsA('SpecialMesh') and m.TextureId or '',
                            Scale = m and m:IsA('SpecialMesh') and m.Scale or Vector3.new(1,1,1),
                        }
                    end

                    local function restoreSkinOrig(tool)
                        local orig = skinOriginals[tool]
                        if not orig then return end
                        local h = tool:FindFirstChild('Handle')
                        if h then
                            h.Size = orig.Size h.Color = orig.Color h.Material = orig.Material h.Transparency = orig.Transparency
                            for _, m in ipairs(h:GetChildren()) do
                                if m:IsA('SpecialMesh') or m:IsA('BlockMesh') or m:IsA('CylinderMesh') then m:Destroy() end
                            end
                            if orig.MeshClass then
                                local m
                                if orig.MeshClass == 'BlockMesh' then m = Instance.new('BlockMesh')
                                elseif orig.MeshClass == 'CylinderMesh' then m = Instance.new('CylinderMesh')
                                else m = Instance.new('SpecialMesh') end
                                if m:IsA('SpecialMesh') then m.MeshId = orig.MeshId m.TextureId = orig.TextureId m.Scale = orig.Scale end
                                m.Parent = h
                            end
                        end
                        skinOriginals[tool] = nil
                    end

                    local function applyLaserSkin(tool)
                        if not isGunTool(tool) then return end
                        local h = tool:FindFirstChild('Handle')
                        if not h then return end
                        saveSkinOrig(tool)
                        for _, m in ipairs(h:GetChildren()) do
                            if m:IsA('SpecialMesh') or m:IsA('BlockMesh') or m:IsA('CylinderMesh') then m:Destroy() end
                        end
                        h.Size = LASER_HANDLE_SIZE
                        h.Color = Color3.fromRGB(0, 170, 255)
                        h.Material = Enum.Material.Neon
                        h.Transparency = 0
                        local mesh = Instance.new('SpecialMesh')
                        mesh.MeshId = LASER_MESH_ID
                        mesh.TextureId = LASER_TEXTURE_ID
                        mesh.Scale = LASER_MESH_SCALE
                        mesh.Parent = h
                    end

                    local function skinScanAll()
                        local char = LocalPlayer.Character
                        local bp = LocalPlayer:FindFirstChildOfClass('Backpack')
                        if char then for _, t in ipairs(char:GetChildren()) do if t:IsA('Tool') then if skinLaserOn then applyLaserSkin(t) else restoreSkinOrig(t) end end end end
                        if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA('Tool') then if skinLaserOn then applyLaserSkin(t) else restoreSkinOrig(t) end end end end
                    end

                    local function skinWatch(c)
                        if not c then return end
                        c.ChildAdded:Connect(function(child)
                            if child:IsA('Tool') then
                                task.wait(0.1)
                                if skinLaserOn then applyLaserSkin(child) else restoreSkinOrig(child) end
                            end
                        end)
                    end

                    do
                        local bp = LocalPlayer:FindFirstChildOfClass('Backpack')
                        if bp then skinWatch(bp) end
                        if LocalPlayer.Character then skinWatch(LocalPlayer.Character) end
                    end

                    LocalPlayer.CharacterAdded:Connect(function(char)
                        task.wait(0.5)
                        local bp = LocalPlayer:FindFirstChildOfClass('Backpack')
                        if bp then skinWatch(bp) end
                        skinWatch(char)
                        if skinLaserOn then skinScanAll() end
                    end)

                    farmSetSkinLaser = function(on)
                        skinLaserOn = on == true
                        if skinLaserOn then skinScanAll()
                        else
                            local char = LocalPlayer.Character
                            local bp = LocalPlayer:FindFirstChildOfClass('Backpack')
                            if char then for _, t in ipairs(char:GetChildren()) do if t:IsA('Tool') then restoreSkinOrig(t) end end end
                            if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA('Tool') then restoreSkinOrig(t) end end end
                        end
                    end

                    farmSet = f_setFarm
                    farmKillMurderSet = f_setKillMurder

                    -- ================== DRAG HELPER ==================
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
                                    u362 = true p2Position = p2.Position Position = u366.Position
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

                    -- ================== BUTTON LAYER ==================
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
                                u740 = true p36Position = p36.Position Position = u744.Position
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
                        if u219[p38] then u219[p38].btn:Destroy() u219[p38] = nil end
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
                        UIStroke.Color = p41 UIStroke.Thickness = 1.3 UIStroke.Transparency = 0.5
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
                        task.spawn(function()
                            while ImageLabel and ImageLabel.Parent do
                                ImageLabel.Rotation = ImageLabel.Rotation + 4
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

                -- ================== BOMB FUNCTION ==================
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

                -- ================== SHOOT / AIM / FLICK / SPEED / STRETCH / WALL HOP ==================
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
        end
    end
end

-- ============================================================
-- WINDOW
-- ============================================================
v18:Popup({
    Title = 'CatFeex 0.1',
    Icon = 'sparkles',
    Content = 'v0.1 loaded!\nAll features + Skin Lazer (Gun).',
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
function t27.Callback(p56) v232(p56) end
v301:Toggle(t27)

local t28 = {Title = 'Show Normal Bomb', Default = true}
function t28.Callback(p57) v239(p57) end
v301:Toggle(t28)

v301:Toggle({
    Title = 'Kill Murder (SPOOF behind back)',
    Description = 'Server thinks you stand 5 studs behind murderer.',
    Default = false,
    Callback = function(on)
        if farmKillMurderSet then farmKillMurderSet(on) end
        v18:Notify({Title = 'CatFeex 0.1', Content = on and 'Kill Murder ON' or 'Kill Murder OFF', Duration = 3, Icon = 'bell'})
    end,
})

v301:Toggle({
    Title = 'Skin Lazer (Gun)',
    Description = 'Gives the Gun a blue laser skin.',
    Default = false,
    Callback = function(on)
        if farmSetSkinLaser then farmSetSkinLaser(on) end
        v18:Notify({Title = 'CatFeex 0.1', Content = on and 'Lazer skin ON' or 'Lazer skin OFF', Duration = 3, Icon = 'bell'})
    end,
})

v301:Toggle({Title = 'Auto Shoot', Description = 'Auto fires at murderer when visible', Default = false, Callback = function(on) f_setAutoShoot(on) end})

v301:Divider()
v301:Paragraph({Title = 'Graphics', Content = 'Low: FPS boost. High: Bloom, SunRays.'})

v302:Toggle({
    Title = 'Farm ON/OFF',
    Description = 'Auto-farm 40 coins',
    Default = false,
    Callback = function(on) farmSet(on) end,
})

farmStatus = v302:Paragraph({Title = 'Status', Content = 'FARM OFF'})

v302:Button({
    Title = 'KILL ALL (Murderer) - toggle',
    Description = 'Press -> ON (3s). Press again -> OFF.',
    Callback = function() farmKillAll() end,
})

task.wait(0.4)
v232(true)
v239(true)
v18:Notify({
    Title = 'CatFeex 0.1',
    Content = 'CatFeex 0.1 Ready!',
    Duration = 3,
    Icon = 'bell',
})
print('[CatFeex 0.1] loaded. All features + Skin Lazer (Gun).')
