exports.ox_target:addSphereZone({
	coords = vec3(993.5995, -3109.0598, -38.9999),
	radius = 1,
    debug = Config.Debug,
	options = {
		{
			name = 'dispose',
            distance = 1.2,
			icon = 'fa-solid fa-recycle',
			label = 'Dispose',
			event = 'vd_recycling:getReward'
		}
	}
})

exports.ox_target:addSphereZone({
	coords = vec3(994.9576, -3100.0081, -39.1834),
	radius = 1,
    debug = Config.Debug,
	options = {
		{
			name = 'start',
            distance = 1.2,
			icon = 'fa-solid fa-recycle',
			label = 'Punch In',
			event = 'vd_recycling:punchIn'
		}
	}
})

exports.ox_target:addSphereZone({
	coords = Config.Enter,
	radius = 1,
    debug = Config.Debug,
	options = {
		{
			name = 'teleOut',
            distance = 1.2,
			icon = 'fa-solid fa-recycle',
			label = 'Exit Warehouse',
			onSelect = function()
                teleOut()
            end
		}
	}
})

exports.ox_target:addSphereZone({
	coords = Config.Exit,
	radius = 1,
    debug = Config.Debug,
	options = {
		{
			name = 'teleInside',
            distance = 1.2,
			icon = 'fa-solid fa-recycle',
			label = 'Enter Warehouse',
			onSelect = function()
                teleInside()
            end
		}
	}
})

function teleInside()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do	Citizen.Wait(10) end
    SetEntityCoords(PlayerPedId(), Config.Enter)
    DoScreenFadeIn(500)
end

function teleOut()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do	Citizen.Wait(10) end
    SetEntityCoords(PlayerPedId(), Config.Exit)
    DoScreenFadeIn(500)
end