RegisterNetEvent('vd_recycling:giveitem')
AddEventHandler('vd_recycling:giveitem', function(Item, Amount)
local Player = source
local Item = Item
local Amount = Amount
exports.ox_inventory:AddItem(Player, Item, Amount)
end)

RegisterNetEvent('vd_recycling:removeitem')
AddEventHandler('vd_recycling:removeitem', function(Item, Amount)
local Player = source
local Item = Item
local Amount = Amount
exports.ox_inventory:RemoveItem(Player, Item, Amount)
end)
