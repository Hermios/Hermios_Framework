function add_equipment_category(entitytype,categoryname)
	for _,prototype in pairs(data.raw[entitytype]) do
		if not prototype.equipment_grid then
			return
		end
		local equipmentgrid=data.raw["equipment-grid"][prototype.equipment_grid]
		equipmentgrid.equipment_categories=equipmentgrid.equipment_categories or {}
		for _, category in pairs(equipmentgrid.equipment_categories) do
			if category == categoryname then
				found = true
				break
			end
		end
		if not found then
			table.insert(data.raw["equipment-grid"][prototype.equipment_grid].equipment_categories, categoryname)
		end
	end
end

local function get_custom_table(entity,custom_table)
	if entity.object_name=="LuaEntity" then
		if custom_table[entity.name] then
			return custom_table[entity.name],entity.name
		end
		if custom_table[entity.type] then
			return custom_table[entity.type],entity.type
		end
		if entity.train and custom_table["train"] then
			return custom_table["train"],"train"
		end
	elseif entity.object_name=="LuaTrain" and custom_table["train"] then
		return custom_table["train"],"train"
	end
	return custom_table["any"],"any"
end

function get_custom_prototype(entity)
	return get_custom_table(entity,custom_prototypes)
end

function get_custom_gui(entity)
	return get_custom_table(entity,custom_guis)
end

function get_unitid(entity)
	if not entity then
		return
	end
	return 
		(entity.object_name=="LuaTrain" and entity.id) or
		(entity.object_name=="LuaEntity" and entity.unit_number)
end

function init_custom_data()
	for _,entity in pairs(global.custom_entities or {}) do
		custom_prototype=custom_prototypes[entity.prototype_index]
		if type(custom_prototype)=="table" then
			setmetatable(entity,custom_prototype)
			custom_prototype.__index=custom_prototype
		end
	end
end