local QBCore = exports['qb-core']:GetCoreObject()

-- Functions --

local function GetFuel(vehicle)
	return DecorGetFloat(vehicle, Config.SyphonFuelDecor)
end

local function SetFuel(vehicle, fuel)
	if type(fuel) == 'number' and fuel >= 0 and fuel <= 100 then
		SetVehicleFuelLevel(vehicle, fuel + 0.0)
		DecorSetFloat(vehicle, Config.SyphonFuelDecor, GetVehicleFuelLevel(vehicle))
	end
end

local function PoliceAlert(coords)
    local chance = math.random(1,100)
    if chance < Config.SyphonPoliceCallChance then
        if Config.SyphonDispatchSystem == "ps-dispatch" then
            exports['ps-dispatch']:SuspiciousActivity()
        elseif Config.SyphonDispatchSystem == "qb-dispatch" then
           TriggerServerEvent('qb-dispatch:911call', coords)
        elseif Config.SyphonDispatchSystem == "qb-default" then
            TriggerServerEvent('cdn-syphoning:callcops', coords)
        elseif Config.SyphonDispatchSystem == "custom" then
            -- Put your own dispatch system here
        else
            if Config.SyphonDebug then print("There was an attempt to call police but this dispatch system is not supported!") end
        end
    end
end

-- Events --
RegisterNetEvent('cdn-syphoning:syphon:menu', function(itemData)
    if IsPedInAnyVehicle(PlayerPedId(), false) then QBCore.Functions.Notify('You cannot syphon from the inside of the vehicle!', 'error') return end
    if Config.SyphonDebug then print("Item Data: "..json.encode(itemData)) end
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local vehiclecoords = GetEntityCoords(vehicle)
    local pedcoords = GetEntityCoords(PlayerPedId())
    if #(vehiclecoords - pedcoords) > 2.5 then return end
    if GetVehicleBodyHealth(vehicle) < 100 then QBCore.Functions.Notify("Vehicle is too damaged!", 'error') return end
    local nogas if itemData.info.gasamount < 1 then nogas = true Nogasstring = "You have no gas in your Syphon Kit!" else nogas = false Nogasstring = "Put your stolen gasoline to use and refuel the vehicle!" end 
    local syphonfull if itemData.info.gasamount == Config.SyphonKitCap then syphonfull = true Stealfuelstring = "Your Syphon Kit is full! It only fits "..Config.SyphonKitCap.."L!" elseif GetFuel(vehicle) < 1 then syphonfull = true Stealfuelstring = "This vehicle's fuel tank is empty." else syphonfull = false Stealfuelstring = "Steal fuel from an unsuspecting victim!" end -- Disable Options based on item data
    exports['qb-menu']:openMenu({
        {
            header = "Syphoning Kit",
            isMenuHeader = true,
        },
        {
            header = "Syphon",
            txt = Stealfuelstring, 
            params = {
                event = "cdn-syphoning:syphon",
                args = {
                    itemData = itemData,
                    reason = "syphon",
                },
            },
            icon = "fas fa-fire-flame-simple",
            disabled = syphonfull,
        },
        {
            header = "Refuel",
            txt = Nogasstring, 
            icon = "fas fa-gas-pump",
            params = {
                event = "cdn-syphoning:syphon",
                args = {
                    itemData = itemData,
                    reason = "refuel",
                },
            },
            disabled = nogas,
        },
        {
            header = "Cancel",
            txt = "I actually don't want to use this anymore. I've turned a new leaf!", 
            icon = "fas fa-times-circle",
        },
    })
end)

RegisterCommand('setfuel0', function ()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    SetFuel(vehicle, 0)
end, false)

RegisterCommand('setfuel100', function ()
    local vehicle = QBCore.Functions.GetClosestVehicle()
    SetFuel(vehicle, 100)
end, false)

RegisterCommand('testpolicecall', function ()
    PoliceAlert(GetEntityCoords(PlayerPedId()))
end, false)

RegisterNetEvent('cdn-syphoning:syphon', function(data)
    local reason = data.reason local HasSyphon = QBCore.Functions.HasItem("syphoningkit", 1)
    if Config.SyphonDebug then print('Item Data Syphon: '..json.encode(data.itemData)) end if Config.SyphonDebug then print('Reason: '..reason) end
    if HasSyphon then
        local currentsyphonamount = data.itemData.info.gasamount
        local fitamount = (Config.SyphonKitCap - currentsyphonamount)
        local vehicle = QBCore.Functions.GetClosestVehicle()
        local vehiclecoords = GetEntityCoords(vehicle)
        local pedcoords = GetEntityCoords(PlayerPedId())
        if #(vehiclecoords - pedcoords) > 2.5 then return end -- If car is farther than 2.5 then return end
        local cargasamount = GetFuel(vehicle)
        local maxsyphon = math.floor(GetFuel(vehicle))
        if Config.SyphonKitCap <= 100 then 
            if maxsyphon > Config.SyphonKitCap then
                maxsyphon = Config.SyphonKitCap
            end
        end
        if maxsyphon >= fitamount then
            Stealstring = fitamount
        else
            Stealstring = maxsyphon
        end
        if reason == "syphon" then
            local syphon = exports['qb-input']:ShowInput({
                header = "Select how much gas to steal.",
                submitText = "Begin Syphoning",
                inputs = {
                    {
                        type = 'number',
                        isRequired = true,
                        name = 'amount',
                        text = 'You can steal ' .. Stealstring .. 'L from the car.'
                    }
                }
            })
            if syphon then
                if not syphon.amount then return end
                if tonumber(syphon.amount) < 0 then QBCore.Functions.Notify('You cannot steal a negative amount!', 'error') return end if tonumber(syphon.amount) == 0 then QBCore.Functions.Notify('You have to steal more than 0L!', 'error') return end
                if tonumber(syphon.amount) > maxsyphon then QBCore.Functions.Notify("You cannot syphon this much, your can won't fit it! You can only fit: "..fitamount.." Liters.", 'error') return end
                if currentsyphonamount + syphon.amount > Config.SyphonKitCap then QBCore.Functions.Notify("You cannot syphon this much, your can won't fit it! You can only fit: "..fitamount.." Liters.", 'error') return end
                if (tonumber(syphon.amount) <= tonumber(cargasamount)) then
                    local removeamount = (tonumber(cargasamount) - tonumber(syphon.amount))
                    local syphonstring
                    if tonumber(syphon.amount) < 10 then syphonstring = string.sub(syphon.amount, 1, 1) else syphonstring = string.sub(syphon.amount, 1, 2) end -- This is to remove the .0 part from them end for the notification.
                    local syphontimer = 600 * syphon.amount if tonumber(syphon.amount) < 10 then syphontimer = 600*10 end
                    QBCore.Functions.Progressbar('syphon_gas', 'Syphonning '..syphonstring..'L of Gas', syphontimer, false, true, { -- Name | Label | Time | useWhileDead | canCancel
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }, {animDict = Config.StealAnimDict, anim = Config.StealAnim, flags = 1,}, {}, {}, 
                    function() -- Play When Done
                        StopAnimTask(PlayerPedId(), Config.StealAnimDict, Config.StealAnim, 1.0)
                        PoliceAlert(GetEntityCoords(PlayerPedId()))
                        QBCore.Functions.Notify('Successfully Syphoned '..syphonstring..'L from the vehicle!', 'success')
                        SetFuel(vehicle, removeamount)
                        local syphonData = data.itemData
                        local srcPlayerData = QBCore.Functions.GetPlayerData()
                        TriggerServerEvent('cdn-syphoning:info', "add", tonumber(syphon.amount), srcPlayerData, syphonData)
                    end, function() -- Play When Cancel
                        PoliceAlert(GetEntityCoords(PlayerPedId()))
                        StopAnimTask(PlayerPedId(), Config.StealAnimDict, Config.StealAnim, 1.0)
                        QBCore.Functions.Notify('Cancelled.', 'error')
                    end)
                end
            end
        elseif reason == "refuel" then
            if 100 - math.ceil(cargasamount) < Config.SyphonKitCap then
                Maxrefuel = 100 - math.ceil(cargasamount)
                if Maxrefuel > currentsyphonamount then
                    Maxrefuel = currentsyphonamount
                end
            else
                Maxrefuel = currentsyphonamount
            end
            local refuel = exports['qb-input']:ShowInput({
                header = "Select how much gas to refuel.",
                submitText = "Refuel Vehicle",
                inputs = {
                    {
                        type = 'number',
                        isRequired = true,
                        name = 'amount',
                        text = 'Up to ' .. Maxrefuel .. 'L of gas.'
                    }
                }
            })
            if refuel then
                if tonumber(refuel.amount) == 0 then QBCore.Functions.Notify("You have to fuel more than 0L!", 'error') return elseif tonumber(refuel.amount) < 0 then QBCore.Functions.Notify("You can't refuel a negative amount!", 'error') return elseif tonumber(refuel.amount) > 100 then QBCore.Functions.Notify("You can't refuel more than 100L!", 'error') return end
                if tonumber(refuel.amount) > tonumber(currentsyphonamount) then QBCore.Functions.Notify("You don't have enough gas to refuel that much!", 'error') return end
                if tonumber(refuel.amount) + tonumber(cargasamount) > 100 then QBCore.Functions.Notify('The vehicle cannot hold this much gasoline!', 'error') return end
                local refueltimer = 600 * tonumber(refuel.amount) if tonumber(refuel.amount) < 10 then refueltimer = 600*10 end
                QBCore.Functions.Progressbar('refuel_gas', 'Refuelling '..tonumber(refuel.amount)..'L of Gas', refueltimer, false, true, { -- Name | Label | Time | useWhileDead | canCancel
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {animDict = Config.RefuelAnimDict, anim = Config.RefuelAnim, flags = 17,}, {}, {}, 
                function() -- Play When Done
                    StopAnimTask(PlayerPedId(), Config.RefuelAnimDict, Config.RefuelAnim, 1.0)
                    QBCore.Functions.Notify('Successfully put '..tonumber(refuel.amount)..'L into the vehicle!', 'success')
                    SetFuel(vehicle, cargasamount + tonumber(refuel.amount))
                    local syphonData = data.itemData
                    local srcPlayerData = QBCore.Functions.GetPlayerData()
                    TriggerServerEvent('cdn-syphoning:info', "remove", tonumber(refuel.amount), srcPlayerData, syphonData)
                end, function() -- Play When Cancel
                    StopAnimTask(PlayerPedId(), Config.RefuelAnimDict, Config.RefuelAnim, 1.0)
                    QBCore.Functions.Notify('Cancelled.', 'error')
                end)
            end
        end
    else
        QBCore.Functions.Notify('You need something to syphon gas with.', 'error', 7500)
    end
end)

RegisterNetEvent('cdn-syphoning:client:callcops', function(coords)
    local PlayerJob = QBCore.Functions.GetPlayerData().job
    if PlayerJob.name ~= "police" or not PlayerJob.onduty then return end
    local transG = 250
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 648)
    SetBlipColour(blip, 17)
    SetBlipDisplay(blip, 4)
    SetBlipAlpha(blip, transG)
    SetBlipScale(blip, 1.2)
    SetBlipFlashes(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString("(10-90) - Gasoline Theft")
    EndTextCommandSetBlipName(blip)
    while transG ~= 0 do
        Wait(180 * 4)
        transG = transG - 1
        SetBlipAlpha(blip, transG)
        if transG == 0 then
            SetBlipSprite(blip, 2)
            RemoveBlip(blip)
            return
        end
    end
end)