--[[
Add the probability settings.
This MUST be named warptorio_planetpack_<name of planet>.

Don't forget to add the locale!

]]

data:extend({

	{type="int-setting",name="warptorio_planetpack_swamp",order="abcdefg",
	setting_type="startup",default_value=3,
	minimum_value=0},

})