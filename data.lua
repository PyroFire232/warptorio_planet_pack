--[[
Extend some vanilla factorio tiles for the swamp planet

If you know how to make this work better please post on mod discussion.
Much comments due to debug and testing.
This is not finished: https://forums.factorio.com/viewtopic.php?f=25&t=74615
]]

local noise = require("noise")
local tne=noise.to_noise_expression


local undeepBlueWater  = data.raw["tile"]["deepwater"]
local   deepBlueWater  = data.raw["tile"][    "water"]

local undeepGreenWater = data.raw["tile"][undeepBlueWater.name.."-green"]
local   deepGreenWater = data.raw["tile"][  deepBlueWater.name.."-green"]

undeepGreenWater.transitions_between_transitions = nil
undeepGreenWater.allowed_neighbors = nil
undeepGreenWater.needs_correction = false




--[[
data:extend{
{
    type = "noise-expression",
    name = "straight-basis-noise",
    intended_property = "elevation",
    expression = {
      type = "function-application",
      function_name = "factorio-basis-noise",
      arguments = {
        x = noise.var("x"),
        y = noise.var("y"),
        seed0 = noise.var("map_seed"), -- i.e. map.seed
        seed1 = tne(123), -- Some random number

        input_scale = noise.var("segmentation_multiplier")/20,
        output_scale = 20/noise.var("segmentation_multiplier")
      }
}

}]]


local function water_level_correct(to_be_corrected, map)
  return noise.max(
    map.wlc_elevation_minimum,
    to_be_corrected + map.wlc_elevation_offset
  )
end

local minimal_starting_lake_elevation_expression = noise.define_noise_function( function(x,y,tile,map)
  local starting_lake_distance = noise.distance_from(x, y, noise.var("starting_lake_positions"), 1024)
  local minimal_starting_lake_depth = 8
  local lake_noise = tne{
    type = "function-application",
    function_name = "factorio-basis-noise",
    arguments = {
      x = x,
      y = y,
      seed0 = tne(map.seed),
      seed1 = tne(123),
      input_scale = noise.fraction(1,32),
      output_scale = tne(20)
    }
  }

  local minimal_starting_lake_bottom = lake_noise / 8 - minimal_starting_lake_depth + lake_noise

  return lake_noise/8 --minimal_starting_lake_bottom
end)

local function finish_elevation(elevation, map)
  local elevation = water_level_correct(elevation, map)
  elevation = elevation / map.segmentation_multiplier
  elevation = noise.min(elevation, minimal_starting_lake_elevation_expression)
  return elevation
end




data.raw.tile["deepwater-green"].autoplace={
	probability_expression=noise.define_noise_function(function(x,y,tile,map)
		local swamp_noise=tne{ type="function-application",function_name="factorio-basis-noise",arguments={
			x=x,y=y,seed0=tne(map.seed),seed1=tne(123),
			input_scale=noise.fraction(1,24)-tne(0.25), output_scale=tne(0.5)-tne(0.25)
		}}

		local swamp_noise_max=tne{ type="function-application",function_name="factorio-basis-noise",arguments={
			x=x,y=y,seed0=tne(map.seed),seed1=tne(123),
			input_scale=noise.fraction(1,32)+tne(0.25), output_scale=tne(0.5)+tne(0.25)
		}}

		return noise.min(noise.max(swamp_noise_max,swamp_noise),minimal_starting_lake_elevation_expression)

	end),
}
data.raw.tile["deepwater-green"].probability=0.5


     --[[local scale = 1 / map.segmentation_multiplier
      local octave_count = noise.log2(1+scale)
      local multioctave_noise = {
        type = "function-application",
        function_name = "factorio-multioctave-noise",
        arguments = {
          x = x,
          y = y,
          seed0 = map.seed,
          seed1 = tne(2), -- Some random number
          input_scale = tne(1/120),
          output_scale = scale,
          octaves = octave_count,
          persistence = tne(0.5)
        }
}]]
				--[[ grass1 (-1/0), 5.150004, noise.var("moisture"), -, 0, 1/0, ridge, subtract, 20, *, (-1/0), 1, clamp, 1, *, -1/0, 10.5, noise.var("aux"), 0.5, 0, 1/0, ridge, -, 20, *, -1/0, 
		1, clamp, 1, *, 1/0, clamp, input_scale={ 1, 6, /, noise.octaves(4), output_scale 0.66, persistence=0.7, seed0, noise-layer-name-to-id("grass-1"),
		x={},y={},function_name="factorio-multioctave-noise", +, 0, +]]

		--local elev=noise.ridge(tile.distance* map.segmentation_multiplier,-12,12) / map.segmentation_multiplier
		--local v=noise.max(map.wlc_elevation_minimum, elev+map.wlc_elevation_offset ) -- noise.max(multioctave_noise,minimal_starting_lake_elevation_expression/32)/8 -- --finish_elevation(swamp_noise,map)

-- data.raw.tile["water-green"].autoplace=table.deepcopy(data.raw.tile["grass-1"].autoplace)
