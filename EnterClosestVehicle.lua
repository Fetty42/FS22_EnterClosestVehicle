-- Author: Fetty42
-- Date: 16.04.2022
-- Version: 1.0.0.0

dbPrintfOn = false

function dbPrintf(...)
	if dbPrintfOn then
    	print(string.format(...))
	end
end


EnterClosestVehicle = {};
-- EnterClosestVehicle.events = {}


function EnterClosestVehicle:loadMap(name)
	dbPrintf("EnterClosestVehicle:loadMap");

	if g_currentMission:getIsClient() then
		-- EnterClosestVehicle.events = {}
		Player.registerActionEvents = Utils.appendedFunction(Player.registerActionEvents, EnterClosestVehicle.registerActionEvents);
		-- Player.removeActionEvents = Utils.appendedFunction(Player.removeActionEvents, EnterClosestVehicle.removeActionEventsPlayer);
		Enterable.onRegisterActionEvents = Utils.appendedFunction(Enterable.onRegisterActionEvents, EnterClosestVehicle.registerActionEvents);
	end;
end;

function EnterClosestVehicle:registerActionEvents()
	dbPrintf("EnterClosestVehicle:registerActionEventsPlayer");
	if self.isClient then --isOwner
		-- g_inputBinding:removeActionEvent(EnterClosestVehicle.events[1]);
		-- EnterClosestVehicle.events = {};

		-- local result, actionEventId = g_inputBinding:registerActionEvent('ENTER_CLOSEST_VEHICLE',self, EnterClosestVehicle.EnterClosestVehicle ,false ,true ,false ,true)
		local result, actionEventId = g_inputBinding:registerActionEvent('ENTER_CLOSEST_VEHICLE',InputBinding.NO_EVENT_TARGET, EnterClosestVehicle.EnterClosestVehicle ,false ,true ,false ,true)
		-- local _, eventId = g_inputBinding:registerActionEvent(InputAction.AXIS_ROTATE_HANDTOOL, self, self.onInputRotate, false, false, true, true) -- (triggerUp, triggerDown, triggerAlways, startActive, callbackState, bool?)
		-- _, inputRegisterEntry.eventId = g_inputBinding:registerActionEvent(actionId, self, inputRegisterEntry.callback, inputRegisterEntry.triggerUp, inputRegisterEntry.triggerDown, inputRegisterEntry.triggerAlways, startActive, inputRegisterEntry.callbackState, true)

		dbPrintf("Result=%s | actionEventId=%s | self.isClient=%s", result, actionEventId, self.isClient)
		if result and actionEventId then
			dbPrintf("Action event inserted successfully")
			g_inputBinding:setActionEventTextVisibility(actionEventId, true)
			g_inputBinding:setActionEventActive(actionEventId, true)
			g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_LOW) -- GS_PRIO_VERY_HIGH, GS_PRIO_HIGH, GS_PRIO_LOW, GS_PRIO_VERY_LOW
			-- table.insert(EnterClosestVehicle.events, actionEventId);
		end
	end
end;

-- Wechsel in das am nächsten stehende Fahrzeug
function EnterClosestVehicle:EnterClosestVehicle(actionName, keyStatus, arg3, arg4, arg5)
	dbPrintf("EnterClosestVehicle:EnterClosestVehicle");
	local closestVehicle = EnterClosestVehicle:GetClosestVehicle();
	if closestVehicle ~= nil then
		g_currentMission:requestToEnterVehicle(closestVehicle);
	end;
end;


function EnterClosestVehicle:GetClosestVehicle()
	dbPrintf("EnterClosestVehicle:GetClosestVehicle");

    if g_currentMission.player == nil and g_currentMission.controlledVehicle == nil then
		-- dbPrintf("  No player or controlled vehicle!");
		return;
    end;

    local function getPlayerOrVehiclePosition()
        if g_currentMission.controlledVehicle ~= nil then
            if g_currentMission.controlledVehicle.steeringAxleNode ~= nil then
                return getWorldTranslation(g_currentMission.controlledVehicle.steeringAxleNode);
            end;
        else
            return g_currentMission.player:getPositionData();
        end;
    end;

    local x_pos_player, y_pos_player, z_pos_player = getPlayerOrVehiclePosition()
    if x_pos_player == nil or z_pos_player == nil then
		-- dbPrintf("  No player or controlled vehicle position!");
		return;
    end;
	   
	-- Fahrzeuge durchlaufen
	local curVehicle = g_currentMission.controlledVehicle;
	local allVehicles = g_currentMission.vehicles;
	local closestVehicle =  nil;
	local closestVehicleDistance = 0;
	for key, vehicle in ipairs(allVehicles) do

		-- dbPrintf("** DebugUtil.printTableRecursively(vehicle,'.',0,1) **")
		-- DebugUtil.printTableRecursively(vehicle,".",0,1)
		-- dbPrintf("** End DebugUtil.printTableRecursively() **")
		
		-- dbPrintf("  key=" .. key .. " | FullName=" .. vehicle:getFullName());
        
		if not vehicle.isDeleted and vehicle.spec_aiVehicle ~= nil --[[and vehicle.spec_locomotive == nil]]  and vehicle ~= curVehicle and vehicle.getIsTabbable~=nil and vehicle:getIsTabbable() then
			-- dbPrintf("  key=" .. key .. " | FullName=" .. vehicle:getFullName());
            if vehicle.steeringAxleNode ~= nil then
				local x_pos_vecicle, y_pos_vecicle, z_pos_vecicle = getWorldTranslation(vehicle.steeringAxleNode);
				local distanceBetweenPlayerAndVehicle = math.sqrt(math.pow((x_pos_player - x_pos_vecicle), 2) + math.pow((z_pos_player - z_pos_vecicle), 2)); -- Algoritm from AnimalsHUD
				-- dbPrintf("  Distance=" .. tostring(distanceBetweenPlayerAndVehicle));

				if closestVehicleDistance == 0 or distanceBetweenPlayerAndVehicle < closestVehicleDistance then
					-- dbPrintf("  new closest vehicle found!")
					closestVehicle = vehicle;
					closestVehicleDistance = distanceBetweenPlayerAndVehicle;
				end;
            end;
		end;
	end;
	return closestVehicle;
end;


-- function EnterClosestVehicle:update(dt) end;
-- function EnterClosestVehicle:onLoad(savegame)end;
-- function EnterClosestVehicle:onUpdate(dt)end;
-- function EnterClosestVehicle:deleteMap()end;
-- function EnterClosestVehicle:keyEvent(unicode, sym, modifier, isDown)end;
-- function EnterClosestVehicle:mouseEvent(posX, posY, isDown, isUp, button)end;
-- function EnterClosestVehicle:draw()end;


addModEventListener(EnterClosestVehicle);