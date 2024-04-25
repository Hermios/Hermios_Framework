require "__HermiosLibs__.lua-libs"
require "__HermiosLibs__.factorio-libs"
require "__HermiosLibs__.train-libs"
require "runtime-stage-libs"

global.custom_entities=global.custom_entities or {}
custom_prototypes={}
list_events={on_init={},on_load={},on_removed={},on_built={},on_configuration_changed={}}

--Initial loading scripts
for eventname,_ in pairs(defines.events) do
	list_events[eventname]={}
	script.on_event(defines.events[eventname], function(event)
		if game.get_player(1) then
			if eventname=="on_tick" and game.get_player(1).mod_settings[modname.."check_delay"] and event.tick%game.players[1].mod_settings[modname.."_check_delay"].value>0 then
				return
			end
			if technology and not game.get_player(1).force.technologies[technology].researched then
				return
			end
		end
		for _,f in pairs(list_events[eventname]) do
			f(event)
		end
	end)
end
for eventName,called_function in pairs(custom_events or {}) do
	script.on_event(eventName,function(event)
		if technology and not game.players[1].force.technologies[technology].researched then
			return
		end
		if called_function then called_function(event) end
	end)
end

script.on_init(function()
	init_custom_data()
	for _,f in pairs(list_events.on_init) do
		f()
	end
end)

script.on_load(function()
	init_custom_data()
	for _,f in pairs(list_events.on_load) do
		f()
	end
end)

---------------------------------------------------
-- On entity built
---------------------------------------------------
table.insert(list_events.on_robot_built_entity,function (event)
	for _,f in pairs(list_events.on_built) do
		f(event.created_entity)
	end
end)

table.insert(list_events.on_built_entity,function (event)
	for _,f in pairs(list_events.on_built) do
		f(event.created_entity)
	end
end)

table.insert(list_events.on_built,function (entity)
	on_built(entity)
end)
---------------------------------------------------
-- On entity removed
---------------------------------------------------
table.insert(list_events.on_robot_pre_mined,function (event)
	for _,f in pairs(list_events.on_removed) do
		f(event.entity)
	end
end)

table.insert(list_events.on_entity_died,function (event)
	for _,f in pairs(list_events.on_removed) do
		f(event.entity)
	end
end)

table.insert(list_events.on_pre_player_mined_item,function (event)
	for _,f in pairs(list_events.on_removed) do
		f(event.entity)
	end
end)

table.insert(list_events.on_removed,function(entity)
	custom_entity=global.custom_entities[entity.unit_number]
	if custom_entity then
		if custom_entity.on_removed then
			custom_entity:on_removed()
		end
		global.custom_entities[entity.unit_number]=nil
	end
end)

---------------------------------------------------
-- Train
---------------------------------------------------
table.insert(list_events.on_train_created,function (event)
	if event.old_train_id_1 then global.custom_entities[event.old_train_id_1]=nil end
    if event.old_train_id_2 then global.custom_entities[event.old_train_id_2]=nil end
	on_built(event.train)
	for _,locomotive in pairs(event.train.locomotives.front_movers) do
        on_built(locomotive)
    end
    for _,locomotive in pairs(event.train.locomotives.back_movers) do
        on_built(locomotive)
    end
end)

---------------------------------------------------
-- global functions
---------------------------------------------------
function on_built(entity)
	if not entity.valid then
		return
	end
	local custom_prototype,index=get_custom_prototype(entity)
	if index=="train" and entity.object_name=="LuaEntity" then
		entity=entity.train
	end
	if custom_prototype then
		local custom_entity=
			(type(custom_prototype)=="table" and custom_prototype.new and custom_prototype:new(entity)) or
			{entity=entity}
		global.custom_entities[get_unitid(custom_entity.entity)]=custom_entity
		if type(custom_prototype)=="table" then
			custom_entity.prototype_index=index
			setmetatable(custom_entity, custom_prototype)
			custom_prototype.__index=custom_prototype
			end
		if custom_entity.on_built then
			custom_entity:on_built()
		end
	end
end