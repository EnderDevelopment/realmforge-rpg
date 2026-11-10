local ClassConfig = {}

ClassConfig.Classes = {
    Knight = {
        Description = "Durable frontline fighter with a sweeping strike.",
        MaxHealth = 180,
        Damage = 24,
        Range = 11,
        Cooldown = 0.8,
        AbilityCooldown = 12,
        AbilityName = "Whirlwind",
        Color = Color3.fromRGB(190, 76, 61),
    },
    Ranger = {
        Description = "Mobile ranged fighter with a piercing volley.",
        MaxHealth = 115,
        Damage = 19,
        Range = 60,
        Cooldown = 0.65,
        AbilityCooldown = 10,
        AbilityName = "Multi Shot",
        Color = Color3.fromRGB(81, 165, 106),
    },
    Mage = {
        Description = "Fragile spellcaster with powerful area magic.",
        MaxHealth = 95,
        Damage = 29,
        Range = 48,
        Cooldown = 1.05,
        AbilityCooldown = 14,
        AbilityName = "Meteor Burst",
        Color = Color3.fromRGB(89, 134, 210),
    },
}

return ClassConfig
