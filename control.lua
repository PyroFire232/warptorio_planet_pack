-------------------------------------------------------
--[[
Some helper functions for the frequency, size, richness tables
]]

local function PCR(f,z,r) return {frequency=f or 1,size=z or f or 1,richness=r or f or 1} end
local function PCRMul(a,b) if(type(b)=="table")then
	return {frequency=(a.frequency or 1)*(b.frequency or 1),size=(a.size or 1)*(b.size or 1),richness=(a.richness or 1)*(b.richness or 1)} else
	return {frequency=(a.frequency or 1)*(b or 1),size=(a.size or 1)*(b or 1),richness=(a.richness or 1)*(b or 1)}
end end

-------------------------------------------------------
--[[
Here is the actual planet table

Many of the tile lines are commented due to debugging and testing tile autoplacement, and is not yet finished.
]]

local swamp={
	key="swamp",name="A Swamp Planet",zone=22,rng=settings.startup["warptorio_planetpack_swamp"].value,
	desc="The platform lands with an unusual squish, and in the distance only for a moment, you could have sworn you just saw a disgruntled ogre.",
	modifiers={
		{"nauvis",{tiles={"grass","dirt","water"}}},
		--{"tile_nauvis",{"dirt",true}},
		--{"tile_nauvis",{"grass",true}},
		--{"tile_nauvis",{"water",true}},
		{"tile_nauvis",{"dry%-dirt",false}},
		{"tile_mod",{"water%-green",true}},
		{"tile_mod_expr",{"water%-green","probability",nil}},
		{"moisture",0.125},
		{"aux",0.25},
		--{"tile_mod_expr",{"water%-green","probability",1}},
		--{"tile_mod_expr",{"water%-green","coverage",-2}},
		--{"tile_mod_expr",{"water%-green","sharpness",-1}},
		--{"tile_mod_expr",{"water%-green","max_probability",0.8}},
		--{"tile_nauvis_expr",{"grass","probability",0.45}},
		--{"tile_nauvis_expr",{"dirt","probability",0.45}},
		{"water",1},
		{"starting_area",0.5},
		{"resource_set",{["crude-oil"]=PCR(3,2,1),["coal"]=PCR(3,2,1),}},
		{"biters",2},
	},
	required_controls={"coal","crude-oil"},

	fgen_call={"warptorio_planet_pack","fgenSwamp"},
	spawn_call={"warptorio_planet_pack","spawnSwamp"},
}

-------------------------------------------------------
--[[
Surface Map Generation calls

Some dynamic changes to the planet generation table, or scripted changes, or both?
]]

function fgenSwamp(g)
	for _,ore in pairs(remote.call("warptorio","getresources"))do
		if(ore~="crude-oil" and ore~="coal")then
			g.autoplace_controls[ore]=PCRMul(g.autoplace_controls[ore] or PCR(1),math.random(30,75)/100)
		end
	end
	return g
end
function spawnSwamp(f,g,chart)
	f.daytime=0.25
	f.freeze_daytime=1
end

remote.add_interface("warptorio_planet_pack",{
	["fgenSwamp"]=fgenSwamp,
	["spawnSwamp"]=spawnSwamp,
})

-------------------------------------------------------
--[[
Register the planet with warptorio
]]

local function RegisterPlanets()
	remote.call("warptorio","registerplanet",swamp)
	remote.call("warptorio","tiledefault","deepwater-green",false)
	remote.call("warptorio","tiledefault","water-green",false)

end
script.on_init(RegisterPlanets)
script.on_load(RegisterPlanets)

