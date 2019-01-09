local tools = {}

function tools.rtrim(s)
    return s:gsub("^(.-)%s*$", "%1")
end

function tools.split(s, delimiter)
    local result = {}
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

function tools.packageParts(packageName)
    local parts = tools.split(packageName, '/')
    local count = #parts
    local result = {}
    local i = 1
    local path = ""
    for _, part in pairs(parts) do
        path = (path and path .. '/' or "") .. part
        table.insert(result, {
            name = part,
            path = path,
            rootLink = ("../"):rep(count - i)
        })
        i = i + 1
    end
    return result
end

function tools.status(rate)
    return rate > 0.80 and "high" or (rate < 0.50 and "low" or "medium")
end

function tools.toxml(value, indentation)
	local xml = ""
	local t = type(value)
	if t == "string" then
		xml = xml .. indentation .. "<" .. value .. "/>\n"
	elseif t == "table" then
		for name,data in pairs(value) do
			-- if the table key is numeric it's value is parsed
			if type(name) == "number" then
				xml = xml .. tools.toxml(data, indentation)
			else
				xml = xml .. indentation .. "<" .. name
				if type(data) == "table" then
					local children = {}
					local number_strings = {}
					for k,v in pairs(data) do
						local vtype = type(v)
						local ktype = type(k)
						if vtype == "table" then
							children[k] = v
						elseif ktype == "string" then
							xml = xml .. " " ..k .. '="' .. tostring(v) .. '"'
						elseif ktype == "number" and vtype == "string" then
							table.insert(number_strings, v)
						end
					end

					if next(children) ~= nil or #number_strings > 1 then
						xml = xml .. ">\n"
						indentation = indentation .. "\t"
						xml = xml .. tools.toxml(children, indentation)
						xml = xml .. tools.toxml(number_strings, indentation)
						indentation = indentation:sub(1,#indentation-1)
						xml = xml .. indentation .. "</" .. name .. ">\n"
					else
						if #number_strings == 1 then
							xml = xml .. ">" .. number_strings[1] .. "</" .. name .. ">\n"
						else
							xml = xml .. "/>\n"
						end
					end
				else
					xml = xml .. ">"..data.."</" .. name ..">\n"
				end
			end
		end
	end
	return xml
end

return tools
