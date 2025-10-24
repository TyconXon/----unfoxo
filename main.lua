local MyCharacterMod = RegisterMod("! ! Unfoxo ! !", 1)

local gabrielType = Isaac.GetPlayerTypeByName("The Kid", false) -- Exactly as in the xml. The second argument is if you want the Tainted variant.
local hairCostume = Isaac.GetCostumeIdByPath("gfx/characters/gabriel_hair.anm2") -- Exact path, with the "resources" folder as the root
local stolesCostume = Isaac.GetCostumeIdByPath("gfx/characters/gabriel_stoles.anm2") -- Exact path, with the "resources" folder as the root
local BACK_CAPE_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/judas_back_cape.anm2")
local scheduler = include("scheduler")
local sfx = SFXManager()
local music = MusicManager()

local SONUD_BLOOD = Isaac.GetSoundIdByName("BloodSpurt")
local MUSIC_DIE = Isaac.GetMusicIdByName("MightIsTightButRight")

local floor = {}

scheduler.Init(MyCharacterMod)

function MyCharacterMod:GiveCostumesOnInit(player)
    if player:GetPlayerType() ~= gabrielType then
        return -- End the function early. The below code doesn't run, as long as the player isn't Gabriel.
    end
   
    floor = nil
    player:AddNullCostume(hairCostume)
    player:AddNullCostume(BACK_CAPE_COSTUME)
    -- player:AddNullCostume(stolesCostume)
end

MyCharacterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MyCharacterMod.GiveCostumesOnInit)


--------------------------------------------------------------------------------------------------


local game = Game() -- We only need to get the game object once. It's good forever!
local DAMAGE_REDUCTION = 0
function MyCharacterMod:HandleStartingStats(player, flag)
    if player:GetPlayerType() ~= gabrielType then
        return -- End the function early. The below code doesn't run, as long as the player isn't Gabriel.
    end

    if flag == CacheFlag.CACHE_DAMAGE then
        -- Every time the game reevaluates how much damage the player should have, it will reduce the player's damage by DAMAGE_REDUCTION, which is 0.6
        player.Damage = player.Damage - DAMAGE_REDUCTION
    end
end

MyCharacterMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, MyCharacterMod.HandleStartingStats)

function MyCharacterMod:HandleHolyWaterTrail(player)
    if player:GetPlayerType() ~= gabrielType then
        return -- End the function early. The below code doesn't run, as long as the player isn't Gabriel.
    end

    -- Every 4 frames. The percentage sign is the modulo operator, which returns the remainder of a division operation!
    -- if game:GetFrameCount() % 4 == 0 then
    --     -- Vector.Zero is the same as Vector(0, 0). It is a constant!
    --     local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, player.Position, Vector.Zero, player):ToEffect()
    --     creep.SpriteScale = Vector(0.5, 0.5) -- Make it smaller!
    --     creep:Update() -- Update it to get rid of the initial red animation that lasts a single frame.
    -- end
end

MyCharacterMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MyCharacterMod.HandleHolyWaterTrail)

function MyCharacterMod.chanceMult()
    return math.floor(math.max((Isaac.GetPlayer(0).Luck/2) + 1, 1))
end

function MyCharacterMod:HandleInstaDeath(Entity, Amount, DamageFlags, Source, CountdownFrames)
    if Entity:ToPlayer() == nil or Entity:ToPlayer():GetPlayerType() ~= gabrielType then
        return nil-- End the function early. The below code doesn't run, as long as the player isn't Gabriel.
    end
    

    local player = Entity:ToPlayer()
    if not player.Visible then 
        return false
    end
    player.Velocity = Vector(0,0)
    Game():ShakeScreen(20)
    local explosionRng = RNG()
    explosionRng:SetSeed(math.max(Random(), 1), 32)

    local MAX_BLOOD_GIB_SUBTYPE = 3
    local MIN_GIBS = 60 -- max is double this
    local gibCount = explosionRng:RandomInt(MIN_GIBS + 1) + MIN_GIBS
    for _ = 1, gibCount do
        local speed = explosionRng:RandomInt(8) + 1
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, explosionRng:RandomInt(MAX_BLOOD_GIB_SUBTYPE + 1), player.Position, RandomVector() * speed, player)
    end

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, player.Position, Vector.Zero, player)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, player.Position, Vector.Zero, player)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, player.Position, Vector.Zero, player)
    -- SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE)

   

    -- player:DropTrinket(Entity.Position, false)
    -- player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)


    -- if math.random(12 * MyCharacterMod.chanceMult()) == 2 then
    --     player:AddTrinket(TrinketType.TRINKET_MOMS_TOENAIL)
    -- end
    
    -- if math.random(13* MyCharacterMod.chanceMult()) == 2 then
    --     player:AddTrinket(TrinketType.TRINKET_BROWN_CAP)
    -- end

    -- if math.random(50* MyCharacterMod.chanceMult()) == 2 then
    --     player:AddTrinket(TrinketType.TRINKET_TORN_CARD)
    -- end

    -- if math.random(3* MyCharacterMod.chanceMult()) == 2 then
    --     player:AddTrinket(TrinketType.TRINKET_PURPLE_HEART)
    -- end
    
    -- player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
    sfx:Play(SONUD_BLOOD)
    music:Play(MUSIC_DIE, 1)
    player.Luck = player.Luck - 0.5
    scheduler.Schedule(10, function ()
        
        -- Isaac.ExecuteCommand("stage ".. tostring(Game():GetLevel():GetStage()) .. toletter(Game():GetLevel():GetStageType()))
        
            -- if math.random(4* MyCharacterMod.chanceMult()) == 2 then
            --     player:UseActiveItem(CollectibleType.COLLECTIBLE_R_KEY, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            -- else
            --     player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
            -- end
    end)
    scheduler.Schedule(15, function ()
        -- player.Visible = true
    end)
    
    
    player.Visible = false
    return nil
end

MyCharacterMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, MyCharacterMod.HandleInstaDeath)

function toletter(r)
    if r == 0 then
        return ""
    end
    if r == 1 then
        return "a"
    end
    if r == 2 then
        return "b"
    end
    if r == 4 then
        return "c"
    end
    if r == 5 then
        return "d"
    end
end

function MyCharacterMod:OnRoomClear(rng, spawnpos)
    -- if math.random(3* MyCharacterMod.chanceMult()) == 2 then
    --     Isaac.Spawn(4, 3, 0, spawnpos, Vector.Zero, nil)
    -- end
    -- if math.random(3* MyCharacterMod.chanceMult()) == 2 then
    --     Isaac.Spawn(4, 4, 0, spawnpos, Vector.Zero, nil)
    -- end
    -- if math.random(10* MyCharacterMod.chanceMult()) == 2 then
    --     Isaac.Spawn(4, 18, 0, spawnpos, Vector.Zero, nil)
    -- end
end
MyCharacterMod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, MyCharacterMod.OnRoomClear)

function MyCharacterMod:myFunction()
    if Input.IsActionPressed(ButtonAction.ACTION_RESTART, 0) and not Isaac.GetPlayer(0).Visible then
        Isaac.ExecuteCommand("stage ".. tostring(Game():GetLevel():GetStage()) .. toletter(Game():GetLevel():GetStageType()))
        Isaac.GetPlayer(0).Visible = true
    end
end
MyCharacterMod:AddCallback(ModCallbacks.MC_POST_UPDATE, MyCharacterMod.myFunction)

function MyCharacterMod:getActionValueOverride(entity, hook, button)
    if not Isaac.GetPlayer(0).Visible then
        return false -- this basically turns your movement input to 0
    end
    return nil
end
MyCharacterMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, MyCharacterMod.getActionValueOverride, InputHook.IS_ACTION_PRESSED)

function MyCharacterMod:getActionValueOverride2(entity, hook, button)
    if not Isaac.GetPlayer(0).Visible then 
        return 0.0 -- this basically turns your movement input to 0
    end
    return nil
end
MyCharacterMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, MyCharacterMod.getActionValueOverride2, InputHook.GET_ACTION_VALUE)


function MyCharacterMod:myFunction2(collectibleID, rngObj, playerWhoUsedItem, useFlags, activeSlot, varData)
    return not Isaac.GetPlayer(0).Visible
end
MyCharacterMod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, MyCharacterMod.myFunction2)

function MyCharacterMod:OnKill(entity)
    -- if math.random(3* MyCharacterMod.chanceMult()) == 2 then
    --     if math.random(3 * MyCharacterMod.chanceMult()) == 2 then
    --         Isaac.Spawn(44, 0, 0, entity.Position, Vector.Zero, nil)
    --     elseif math.random(9* MyCharacterMod.chanceMult()) == 2 then
    --         Isaac.Spawn(877, 0, 0, entity.Position, Vector.Zero, nil)
    --     elseif math.random(13* MyCharacterMod.chanceMult()) == 2 then
    --         Isaac.Spawn(218, 0, 0, entity.Position, Vector.Zero, nil)
    --     end
    --     if math.random(50* MyCharacterMod.chanceMult()) == 2 then
    --         Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_D12, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
    --     end
    --     if math.random(12* MyCharacterMod.chanceMult()) == 2 then
    --         Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
    --     end
    --     if math.random(50* MyCharacterMod.chanceMult()) == 2 then
    --         Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_D7, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
    --     end
    -- end
end
MyCharacterMod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, MyCharacterMod.OnKill)
local function includes(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

--MC_POST_GET_COLLECTIBLE
function MyCharacterMod:OnSpawnItem()
    print(floor)
    if includes(floor, (Game():GetLevel():GetCurrentRoomDesc().Data.Type .. Game():GetLevel():GetAbsoluteStage())) then
        -- Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_MOVING_BOX, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        return CollectibleType.COLLECTIBLE_POOP
    else
        floor[#floor + 1] = Game():GetLevel():GetCurrentRoomDesc().Data.Type..Game():GetLevel():GetAbsoluteStage()
    end
    -- if math.random(4) == 2 then
    --     scheduler.Schedule(50, function ()
    --         Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_DATAMINER, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
    --     end)
    -- else
    -- if math.random(3) == 2 then
    --     scheduler.Schedule(35, function ()
    --         Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_ETERNAL_D6, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
    --     end)
    -- end
end
MyCharacterMod:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, MyCharacterMod.OnSpawnItem)

--------------------------------------------------------------------------------------------------

local TAINTED_GABRIEL_TYPE = Isaac.GetPlayerTypeByName("Gabriel", true)
local HOLY_OUTBURST_ID = Isaac.GetItemIdByName("Holy Outburst")
local game = Game()

---@param player EntityPlayer
function MyCharacterMod:TaintedGabrielInit(player)
    if player:GetPlayerType() ~= TAINTED_GABRIEL_TYPE then
        return
    end

    player:SetPocketActiveItem(HOLY_OUTBURST_ID, ActiveSlot.SLOT_POCKET, true)

    local pool = game:GetItemPool()
    pool:RemoveCollectible(HOLY_OUTBURST_ID)
end

MyCharacterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MyCharacterMod.TaintedGabrielInit)

function MyCharacterMod:HolyOutburstUse(_, _, player)
    local spawnPos = player.Position

    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER, 0, spawnPos, Vector.Zero, player):ToEffect()
    creep.Scale = 2
    creep:Update()

    return true
end

MyCharacterMod:AddCallback(ModCallbacks.MC_USE_ITEM, MyCharacterMod.HolyOutburstUse, HOLY_OUTBURST_ID)