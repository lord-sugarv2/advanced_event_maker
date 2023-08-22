local MODULE = {}
MODULE.ID = "HOOK:OnEventPlayerDies" -- THIS MUST BE UNIQUE
MODULE.Name = "when an event player dies" -- Nice text that gets displayed to represent the ID

hook.Add("HOOK:OnEventPlayerDies", "HOOK:OnEventPlayerDies", function(data, ply)
    for _, v in ipairs(data) do
        AEvent:RunCommands(v.commands, ply)
    end
end)

hook.Add("PlayerDeath", MODULE.ID..":PlayerDeath", function(victim, inflictor, attacker)
    if not AEvent:IsInEvent(victim) then return end
    hook.Run("HOOK:OnEventPlayerDies", AEvent:GetHooksFromDATA("HOOK:OnEventPlayerDies", AEvent.CurrentEvent), victim)
end)

AEvent:CreateHook(MODULE)

local MODULE = {}
MODULE.ID = "HOOK:OnEventPlayerKillsPlayer"
MODULE.Name = "when an event player kills another player"

hook.Add("HOOK:OnEventPlayerKillsPlayer", "HOOK:OnEventPlayerKillsPlayer", function(data, ply)
    for _, v in ipairs(data) do
        AEvent:RunCommands(v.commands, ply)
    end
end)

hook.Add("PlayerDeath", MODULE.ID..":PlayerDeath", function(victim, inflictor, attacker)
    if not attacker or not IsValid(attacker) or not attacker:IsPlayer() or not AEvent:IsInEvent(attacker) then return end
    hook.Run("HOOK:OnEventPlayerKillsPlayer", AEvent:GetHooksFromDATA("HOOK:OnEventPlayerKillsPlayer", AEvent.CurrentEvent), attacker)
end)

AEvent:CreateHook(MODULE)

local MODULE = {}
MODULE.ID = "HOOK:OnDamaged"
MODULE.Name = "when an event player gets damaged"

hook.Add("HOOK:OnDamaged", "HOOK:OnDamaged", function(data, ply)
    for _, v in ipairs(data) do
        AEvent:RunCommands(v.commands, ply)
    end
end)

hook.Add("EntityTakeDamage", MODULE.ID..":EntityTakeDamage", function(ply, dmginfo)
    if not ply:IsPlayer() or not AEvent:IsInEvent(ply) then return end
    hook.Run("HOOK:OnDamaged", AEvent:GetHooksFromDATA("HOOK:OnDamaged", AEvent.CurrentEvent), ply)
end)

AEvent:CreateHook(MODULE)

local MODULE = {}
MODULE.ID = "HOOK:OnDoneDamage"
MODULE.Name = "when an event player damages someone"

hook.Add("HOOK:OnDoneDamage", "HOOK:OnDoneDamage", function(data, ply)
    for _, v in ipairs(data) do
        AEvent:RunCommands(v.commands, ply)
    end
end)

hook.Add("EntityTakeDamage", MODULE.ID..":EntityTakeDamage", function(ply, dmginfo)
    local attacker = dmginfo:GetAttacker()
    if not attacker:IsPlayer() or not AEvent:IsInEvent(attacker) then return end
    hook.Run("HOOK:OnDoneDamage", AEvent:GetHooksFromDATA("HOOK:OnDoneDamage", AEvent.CurrentEvent), attacker)
end)

AEvent:CreateHook(MODULE)