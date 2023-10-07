local MODULE = table.Copy(AEvent.BaseModule)
MODULE.CategoryID = "Command:Weapons"
MODULE.Name = "Health"

MODULE:AddCommand({
    ID = "Command:Weapons:GiveWeapon",
    Name = "give weapon class '...'",
    ExtraSelection = function()
        return {
            {
                text = "weapon class",
                Type = "String Input",
                data = {},
            },
        }
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            ply:Give(data.data[1].selected)
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Weapons:StripWeapon",
    Name = "strip weapon class '...'",
    ExtraSelection = function()
        return {
            {
                text = "weapon class",
                Type = "String Input",
                data = {},
            },
        }
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            ply:StripWeapon(data.data[1].selected)
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Weapons:StripAllWeapon",
    Name = "strip all weapons",
    ExtraSelection = function()
        return false
    end,
    RunCommand = function(data)
        for _, ply in ipairs(data.players) do
            ply:StripWeapons()
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Weapons:GiveAmmo",
    Name = "give '...' ammo",
    ExtraSelection = function()
        return {
            {
                text = "ammo amount",
                Type = "Int Input",
                data = {},
            },
        }
    end,
    RunCommand = function(data)
        local ammoTypes = game.GetAmmoTypes()
        for _, ply in ipairs(data.players) do
            for _, v in ipairs(ammoTypes) do
                ply:GiveAmmo(data.data[1].selected, v, true)
            end
        end
    end,
})

MODULE:AddCommand({
    ID = "Command:Weapons:SetAmmo",
    Name = "set ammo to '...'",
    ExtraSelection = function()
        return {
            {
                text = "ammo amount",
                Type = "Int Input",
                data = {},
            },
        }
    end,
    RunCommand = function(data)
        local ammoTypes = game.GetAmmoTypes()
        for _, ply in ipairs(data.players) do
            for _, v in ipairs(ammoTypes) do
                ply:SetAmmo(data.data[1].selected, v)
            end
        end
    end,
})
AEvent:CreateCommand(MODULE)