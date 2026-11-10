# Roblox RPG Script

Realmforge RPG is a Roblox RPG script package with three playable classes, server-validated combat, class abilities, enemy AI, XP and leveling, coins, data saving, and a generated HUD.

## Install

1. In Roblox Studio, create a `ModuleScript` named `ClassConfig` under `ReplicatedStorage` and paste in `ReplicatedStorage/ClassConfig.lua`.
2. Create a `Script` named `RPGServer` under `ServerScriptService` and paste in `ServerScriptService/RPGServer.server.lua`.
3. Create a `Script` named `EnemySpawner` under `ServerScriptService` and paste in `ServerScriptService/EnemySpawner.server.lua`.
4. Create a `LocalScript` named `RPGClient` under `StarterPlayer > StarterPlayerScripts` and paste in `StarterPlayer/StarterPlayerScripts/RPGClient.client.lua`.
5. For Studio DataStore testing, publish the experience and enable Studio access to API services.

## Use

1. Run the experience. The spawner creates training slimes around the origin.
2. Left-click to attack nearby enemies. Attacks are validated and applied by the server.
3. Press Q to use your class ability.
4. Use the on-screen buttons to choose Knight, Ranger, or Mage.
5. Defeat enemies to earn XP and coins. XP increases your level, and player data is saved through Roblox DataStoreService.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/2f11092b-8449-43c7-b634-851bbdbe06ce?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=2f11092b-8449-43c7-b634-851bbdbe06ce
