local punchedIn = false
local randPackage = nil
local carryingBox = false
local activeZone = nil
local boxObject = nil
local animDict = "anim@heists@box_carry@"
searchProps = {}
Props = {}
local blips = {
     {title="Recycling Plant", colour=48, id=728, x = 61.0532, y = 6467.9380, z = 31.4161}
  }

Citizen.CreateThread(function()

    for _, info in pairs(blips) do
      info.blip = AddBlipForCoord(info.x, info.y, info.z)
      SetBlipSprite(info.blip, info.id)
      SetBlipDisplay(info.blip, 4)
      SetBlipScale(info.blip, 1.0)
      SetBlipColour(info.blip, info.colour)
      SetBlipAsShortRange(info.blip, true)
	  BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(info.title)
      EndTextCommandSetBlipName(info.blip)
    end
end)

function HoldBox()
    local playerPed = GetPlayerPed(-1)

    local boxModel = GetHashKey("prop_cs_cardbox_01")
    RequestModel(boxModel)
    while not HasModelLoaded(boxModel) do
        Citizen.Wait(0)
    end

    boxObject = CreateObject(boxModel, 0, 0, 0, true, true, true)
    AttachEntityToEntity(boxObject, playerPed, GetPedBoneIndex(playerPed, 0x49D9), 0.14958754132738, 0.00048084661165959, 0.23682357403272, 23.867112834595, -39.879443335001, 10.477985942299, true, true, false, true, 1, true)

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end
    TaskPlayAnim(playerPed, animDict, "idle", 8.0, -8.0, -1, 50, 0, false, false, false)
    SetEntityAsNoLongerNeeded(boxObject)
end

function DropBox()
    local playerPed = GetPlayerPed(-1)
    ClearPedTasks(playerPed)
    DetachEntity(boxObject, true, true)
    SetEntityAsMissionEntity(boxObject, true, true)
    DeleteEntity(boxObject)
    boxObject = nil
end

function loadModel(model)
    local time = 1000
    if not HasModelLoaded(model) then if Config.Debug then print("^5Debug^7: ^2Loading Model^7: '^6"..model.."^7'") end
	while not HasModelLoaded(model) do if time > 0 then time = time - 1 RequestModel(model)
		else time = 1000 print("^5Debug^7: ^3LoadModel^7: ^2Timed out loading model ^7'^6"..model.."^7'") break end
		Wait(10) end
	end
end

function makeProp(data, freeze, synced)
    loadModel(data.prop)
    local prop = CreateObject(data.prop, data.coords.x, data.coords.y, data.coords.z, synced or 0, synced or 0, 0)
    SetEntityHeading(prop, data.coords.w)
    FreezeEntityPosition(prop, freeze or 0)
    if Config.Debug then print("^5Debug^7: ^6Prop ^2Created ^7: '^6"..prop.."^7'") end
    return prop
end

function destroyProp(entity)
	if Config.Debug then print("^5Debug^7: ^2Destroying Prop^7: '^6"..entity.."^7'") end
	SetEntityAsMissionEntity(entity) Wait(5)
	DetachEntity(entity, true, true) Wait(5)
	DeleteEntity(entity)
end

function unloadModel(model) if Config.Debug then print("^5Debug^7: ^2Removing Model^7: '^6"..model.."^7'") end SetModelAsNoLongerNeeded(model) end

RegisterNetEvent('vd_recycling:searchBin', function()
local time = Config.SearchTime
    if not carryingBox then
        if lib.progressBar({
            duration = time,
            label = 'Searching..',
            useWhileDead = false,
            canCancel = false,
            disable = {
                move = true,
                car = true,
                combat = true,
            },
            anim = {
                dict = 'amb@prop_human_bum_bin@base',
                clip = 'base'
            },
        }) then
            carryingBox = true
            HoldBox()
            SetEntityDrawOutline(randPackage, false)
            SetEntityDrawOutline(`prop_recyclebin_04_a`, true)
            SetEntityDrawOutlineColor(255, 255, 255, 1.0)
            SetEntityDrawOutlineShader(1)
        else
            exports['okokNotify']:Alert('Cancelled!', 'Searching Cancelled!', 5000, 'info', true)
        end
    else
        exports['okokNotify']:Alert('Alert!', 'Youre already carrying a box!', 5000, 'info', true)
    end
end)

RegisterNetEvent('vd_recycling:getReward', function()
local rewardIndex = math.random(1, #Config.Rewards)
local rewardData = Config.Rewards[rewardIndex]
local amount = math.random(rewardData.min, rewardData.max)
local reward = rewardData.item
    if carryingBox then
        if lib.progressCircle({
            duration = Config.DisposeTime,
            useWhileDead = false,
            canCancel = false,
            disable = {
                move = true,
                car = true,
                combat = true,
            },
        }) then
            TriggerServerEvent('vd_recycling:giveitem', reward, amount)
            TriggerEvent('vd_recycling:newLoc')
            DropBox()
            carryingBox = false
        else
            exports['okokNotify']:Alert('Cancelled!', 'Disposing Cancelled!', 5000, 'info', true)
        end
    else
        exports['okokNotify']:Alert('Alert!', 'Go search a bin first!', 5000, 'info', true)
    end
end)

RegisterNetEvent('vd_recycling:punchIn')
AddEventHandler('vd_recycling:punchIn', function()
    if not punchedIn then
        punchedIn = true
        if lib.progressCircle({
            duration = Config.PunchInTime,
            useWhileDead = false,
            canCancel = false,
            disable = {
                move = true,
                car = true,
                combat = true,
            },
            anim = {
                dict = 'mp_safehousevagos@boss',
                clip = 'vagos_boss_keyboard_b'
            },
        }) then
        
            randPackage = searchProps[math.random(1, #searchProps)]
            SetEntityDrawOutline(randPackage, true)
            SetEntityDrawOutlineColor(255, 255, 255, 1.0)
            SetEntityDrawOutlineShader(1)
            local coords = GetEntityCoords(randPackage)
            activeZone = exports.ox_target:addSphereZone({
                coords = vec3(coords.x, coords.y, coords.z + 1),
                radius = 1.5,
                debug = Config.Debug,
                options = {
                    {
                        name = 'search',
                        label = 'Search',
                        distance = 2.5,
                        event = 'vd_recycling:searchBin',
                        icon = 'fa-sharp fa-regular fa-circle'
                    }
                }
            })
        else
        
        end
    else
    exports['okokNotify']:Alert('Punched In!', 'Already punched in, get started!', 5000, 'info', true)
    end
end)

RegisterNetEvent('vd_recycling:newLoc')
AddEventHandler('vd_recycling:newLoc', function()
    if activeZone ~= nil then
        exports.ox_target:removeZone(activeZone)
        SetEntityDrawOutline(randPackage, false)
    end

            randPackage = searchProps[math.random(1, #searchProps)]
            SetEntityDrawOutline(randPackage, true)
            SetEntityDrawOutlineColor(255, 255, 255, 1.0)
            SetEntityDrawOutlineShader(1)
            local coords = GetEntityCoords(randPackage)
            activeZone = exports.ox_target:addSphereZone({
                coords = vec3(coords.x, coords.y, coords.z + 1),
                radius = 1.5,
                debug = Config.Debug,
                options = {
                    {
                        name = 'search',
                        label = 'Search',
                        event = 'vd_recycling:searchBin',
                        distance = 2.5,
                        icon = 'fa-sharp fa-regular fa-circle'
                    }
                }
            })
end)

function onEnter(self)
    local alert = lib.alertDialog({
        header = 'Recycling Plant!',
        content = 'Third-Eye the laptop to Punch In!',
        centered = true,
        cancel = true
    })
    print(alert)
    print('entered recycling warehoue')
    makeProp({prop = `prop_recyclebin_04_a`,		coords = vector4(993.26165771484, -3109.0383300781, -39.999885559082, 0.0)}, 1, 0) --
	searchProps[#searchProps+1] = makeProp({prop = `prop_cratepile_07a`,		coords = vector4(1003.6661376953, -3091.849609375, -39.999885559082, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ba_prop_battle_crate_art_02_bc`,		coords = vector4(1006.0225830078, -3091.7231445313, -39.872150421143, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ba_prop_battle_crate_biohazard_bc`,		coords = vector4(1008.5004272461, -3091.7231445313, -39.884292602539, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `sm_prop_smug_crate_m_tobacco`,		coords = vector4(1010.8915405273, -3091.9899902344, -39.999885559082, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `sm_prop_smug_crate_01a`,		coords = vector4(1013.2913208008, -3091.9899902344, -40.000034332275, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ba_prop_battle_crate_med_bc`,		coords = vector4(1018.1947021484, -3091.6889648438, -39.875385284424, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `prop_cratepile_07a`,		coords = vector4(1018.1841430664, -3096.9411621094, -39.995037841797, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `sm_prop_smug_crate_m_tobacco`,		coords = vector4(1015.65625, -3096.9411621094, -40.00577545166, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `prop_drop_crate_01_set2`,		coords = vector4(11010.9002685547, -3096.9411621094, -39.468029022217, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ba_prop_battle_crate_art_02_bc`,		coords = vector4(1008.5, -3096.9411621094, -39.881149291992, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `sm_prop_smug_crate_01a`,		coords = vector4(1006.0223388672, -3096.9411621094, -40.004768371582, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `sm_prop_smug_crate_01a`,		coords = vector4(1003.716003418, -3102.7248535156, -40.004768371582, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ba_prop_battle_crate_biohazard_bc`,		coords = vector4(1006.1392822266, -3102.7348632813, -39.878765106201, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ex_Prop_Crate_Closed_BC`,		coords = vector4(1008.4108886719, -3102.7348632813, -39.898906707764, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ex_prop_crate_wlife_sc`,		coords = vector4(1013.2644042969, -3102.7348632813, -40.013065338135, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ex_Prop_Crate_furJacket_SC`,		coords = vector4(1015.639831543, -3102.7348632813, -40.012802124023, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ex_Prop_Crate_Elec_BC`,		coords = vector4(1015.6989135742, -3108.2502441406, -39.990798339844, 0.0)}, 1, 0) --
    searchProps[#searchProps+1] = makeProp({prop = `ex_Prop_Crate_Jewels_racks_BC`,		coords = vector4(1010.9719238281, -3108.2502441406, -39.9989282226563, 0.0)}, 1, 0) --
end

function onExit(self)
    print('left recycling warehoue')
        punchedIn = false
        if Config.Debug then print("^5Debug^7: ^3ClearProps^7() ^2Exiting building^7, ^2clearing previous props ^7(^2if any^7)") end
        for _, v in pairs(searchProps) do unloadModel(GetEntityModel(v)) DeleteObject(v) end searchProps = {}
        for _, v in pairs(Props) do unloadModel(GetEntityModel(v)) DeleteObject(v) end Props = {}
end
 
local poly = lib.zones.poly({
    points = {
        vec(990.2048, -3087.7419, -38),
        vec(990.9404, -3114.7329, -38),
        vec(1028.2522, -3113.5142, -38),
        vec(1028.1239, -3089.1282, -38),
    },
    thickness = 10,
    debug = true,
    onEnter = onEnter,
    onExit = onExit,
})