season = {}

season.which = minetest.settings:get("season") or "reallife"

if season.which == "reallife" then
	local dayofyear = os.date("*t").yday
	if dayofyear >= 79 and dayofyear < 172 then
		season.which = "spring"
	elseif dayofyear < 266 then
		season.which = "summer"
	elseif dayofyear < 355 then
		season.which = "autumn"
	else
		season.which = "winter"
	end
end

function season.pick(spring, summer, autumn, winter)
	local t =  {
		spring = spring,
		summer = summer,
		autumn = autumn,
		winter = winter
	}
	return t[season.which]
end
