-------------------------------------------------------
--[[
This function allows you to access and read data from the warptorio internal global table.
You can use this to access things like gwarptorio.Research["boiler-water"].
]]

local function gwarptorio(k) return remote.call("warptorio","getglobal",k) end


-------------------------------------------------------
--[[
Some helper functions to make code easier
]]

local util = require("util")
local mod_gui = require("mod-gui")
local function istable(x) return type(x)=="table" end
local function printx(m) for k,v in pairs(game.players)do v.print(m) end end
local function isvalid(v) return (v and v.valid) end
local function new(x,a,b,c,d,e,f,g) local t,v=setmetatable({},x),rawget(x,"__init") if(v)then v(t,a,b,c,d,e,f,g) end return t end


-------------------------------------------------------
--[[
PlanetControl()
A helper function to be used with autoplace_controls.
And ONLY in autoplace_controls, don't use this anywhere else.

Call: PlanetControl(frequency=1, size=1, richness=1)
Uses:
PlanetControl(1,1,1)*0.5 = PlanetControl(0.5,0.5,0.5)
PlanetControl(1,1,1)+2 = PlanetControl(3,3,3)
PlanetControl(1,2,3)*PlanetControl(1,2,3) = PlanetControl(1,4,9)
PlanetControl(3,2,1)+PlanetControl(1,2,3) = PlanetControl(4,4,4)

]]

local czMeta={}
function czMeta.__init(t,f,z,r) t.size=z or 1 t.frequency=f or 1 t.richness=r or 1 end
function czMeta.__mul(a,b) local t=setmetatable({},czMeta) if(istable(b))then for k,v in pairs(a)do t[k]=v*(b[k] or 1) end else for k,v in pairs(a)do t[k]=v*b end end return t end
function czMeta.__add(a,b) local t=setmetatable({},czMeta) if(istable(b))then for k,v in pairs(a)do t[k]=v+(b[k] or 0) end else for k,v in pairs(a)do t[k]=v+b end end return t end
local function PlanetControl(f,z,r) return new(czMeta,f,z,r) end



-------------------------------------------------------
--[[
Here is the actual planet table
]]

local planetTable={
	key="swamp",
	zone=22,
	rng=settings.startup["warptorio_planetpack_swamp"].value,
	name="A Swamp Planet",
	desc="The platform lands with an unusual squish, and in the distance only for a moment, you could have sworn you just saw a disgruntled ogre.",
	orig_mul=true,
	gen={
		starting_area=0.75,
		water=0.5,
		default_enable_all_autoplace_controls=true,
		autoplace_controls={
			["crude-oil"]=PlanetControl(3,2,1),
		},
		autoplace_settings={
			decorative={ treat_missing_as_default=true, settings={} },
			entity={ treat_missing_as_default=true, settings={} },
			tile={
				treat_missing_as_default=true, settings={
					["dirt-1"]={frequency=2,size=1},
					["dirt-2"]={frequency=2,size=1},
					["grass-1"]={frequency=3,size=1},
					["grass-2"]={frequency=3,size=1},
					["grass-3"]={frequency=3,size=1},
					["water"] = {frequency=1,size=0.2},
					["deepwater"] = {frequency=1,size=0.2},
					["deepwater-green"] = {frequency=3,size=0.25},
					["water-green"] = {frequency=3,size=0.25},
				},
			},
		},
		property_expression_names={
			["tile:deepwater-green:probability"]=0.175,
			["tile:water-green:probability"]=0.175,
		},
	},
}



-------------------------------------------------------
--[[
This table contains a list of all the resources detected by warptorio.
ResourceList={"iron-ore","copper-ore","uranium"} and all other mod resources.
PlanetList={"normal","average","dwarf","rich"...} and all other planets in the list so far

These variables can be used in the dynamic generation event (fgen)
]]

local ResourceList={} --remote.call("warptorio","getresources") -- This will be picked up in the event on_init
local PlanetList={} --remote.call("warptorio","getplanets") -- This will be set in the on_init event




-------------------------------------------------------
--[[
Surface Map Generation event

Some dynamic changes to the planet generation table, or scripted changes, or both?

Update the planet table then send the new table to warptorio
]]


local fgenEvent=script.generate_event_name()
script.on_event(fgenEvent,function(event)
	if(event.key~="swamp")then return end

	for _,ore in pairs(ResourceList)do
		if(ore~="crude-oil")then
			planetTable.gen.autoplace_controls[ore]=PlanetControl(1,1,1)*(math.random(30,75)/100)
		end
	end
	remote.call("warptorio", "updateplanet", event.key, planetTable )
end)



-------------------------------------------------------
--[[
Surface Spawn Event
Make some final changes to the physical surface after it is spawned
]]

local spawnEvent=script.generate_event_name()
script.on_event(spawnEvent,function(event)
	local f=game.surfaces[event.surface]
	f.daytime=0.25
	f.freeze_daytime=1
end)



-------------------------------------------------------
--[[
Register the planet with warptorio
]]

local function RegisterPlanets()
	ResourceList=remote.call("warptorio","getresources")
	PlanetList=remote.call("warptorio","getplanets")

	remote.call("warptorio","addplanet",{planet_table=planetTable, fgen_event=fgenEvent, spawn_event=spawnEvent})
end

script.on_init(RegisterPlanets)
script.on_load(RegisterPlanets)

