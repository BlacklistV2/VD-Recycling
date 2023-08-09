Config = {}

Config.Debug = false
Config.DebugPoly = false

Config.Enter = vec3(992.3944, -3097.8555, -38.9959) --Place player spawns at when entering
Config.Exit = vec3(55.6883, 6472.1714, 31.4253) --Place player spawns at when exiting

Config.SearchTime = math.random(8000, 12000) --Time it takes to search
Config.PunchInTime = 8000 --Time to punch in
Config.DisposeTime = 4000 --Time to get reward

Config.Rewards = {
    { item = 'steel', min = 2, max = 4},
    { item = 'plastic', min = 2, max = 4},
    { item = 'iron', min = 2, max = 4}
}
