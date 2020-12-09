local dayofyear = os.date("*t").yday

if dayofyear >= 79 and dayofyear < 172 then
	season = "spring"
elseif dayofyear < 266 then
	season = "summer"
elseif dayofyear < 355 then
	season = "autumn"
else
	season = "winter"
end
