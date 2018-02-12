local reporter = require("luacov.reporter")
local tools = require("luacov.multiple.tools")

local ReporterBase = reporter.ReporterBase

-- ReporterBase provide
--  write(str) - write string to output file
--  config()   - return configuration table

local CoberturaReporter = setmetatable({}, ReporterBase) do
CoberturaReporter.__index = CoberturaReporter

function CoberturaReporter:new(conf)
	local confOver = conf.multiple.cobertura and conf.multiple.cobertura or {}

	local config = {}
	for k, v in pairs(conf) do
		config[k] = confOver[k] and confOver[k] or v
	end

	local o, err = ReporterBase.new(self, config)
	if not o then
		return nil, err
	end

	return o
end

function CoberturaReporter:on_start()
	self.cobertura = {
		coverage = {
			["line-rate"] = 0,
			["branch-rate"] = 0,
			["lines-covered"] = 0,
			["lines-valid"] = 0,
			["branches-covered"] = 0,
			["branches-valid"] = 0,
			complexity = 0,
			version = "1.9",
			timestamp = os.time() * 1000,
			sources = {},
			packages = {}
		}
	}

	self.summaries = {}
end

function CoberturaReporter:on_new_file(filename)
	-- "test/package/file.lua" -> "file.lua"
	local class_name = filename:gsub("^.*/", "")
	-- "test/package/file.lua" -> "test/package"
	local package_name = filename:gsub(filename:gsub("^.*/", ""), ""):gsub("/$", "")

	local package
	for _,p in pairs(self.cobertura.coverage.packages) do
		if p.package.name == package_name then
			package = p.package
			break
		end
	end
	-- create package if we weren't able to find it
	if not package then
		package = {
			name = package_name,
			["line-rate"] = 0,
			["branch-rate"] = 0,
			complexity = 0,
			classes = {},
		}
		table.insert(self.cobertura.coverage.packages, { package = package })
	end


	local class = {
		name = class_name,
		filename = filename,
		["line-rate"] = 0,
		["branch-rate"] = 0,
		complexity = 0,
		methods = {},
		lines = {},
	}
	table.insert(package.classes, { class = class })

	self.current_package = package
	self.current_class = class
end

function CoberturaReporter:on_empty_line(filename, lineno, line) -- luacheck: no unused args
end

function CoberturaReporter:on_mis_line(filename, lineno, line) -- luacheck: no unused args
	table.insert(self.current_class.lines, { line = { number = lineno, hits = 0, branch = false } })
end

function CoberturaReporter:on_hit_line(filename, lineno, line, hits) -- luacheck: no unused args
	table.insert(self.current_class.lines, { line = { number = lineno, hits = hits, branch = false } })
end

--- Handle when a file has been completely parsed from start to end
-- @param filename
-- @param hits
-- @param miss
function CoberturaReporter:on_end_file(filename, hits, miss)
	self.current_class["line-rate"] = hits / (hits + miss)
	self.summaries[filename] = {
		hits = hits,
		miss = miss,
	}
end

--- Handle when the entire report has been completely parsed
function CoberturaReporter:on_end()
	-- calculate the line rate for each package
	for _,p in pairs(self.cobertura.coverage.packages) do
		local line_rate = 0
		local package = p.package
		for _,c in pairs(package.classes) do
			local class = c.class
			line_rate = line_rate + class["line-rate"]
		end
		package["line-rate"] = line_rate / #package.classes
	end

	-- calculate the total line rate
	local total_hits = 0
	local total_miss = 0
	for _,summary in pairs(self.summaries) do
		total_hits = total_hits + summary.hits
		total_miss = total_miss + summary.miss
	end
	self.cobertura.coverage["line-rate"] = (total_hits / (total_hits + total_miss))
	self.cobertura.coverage["lines-covered"] = total_hits
	self.cobertura.coverage["lines-valid"] = total_hits + total_miss

	local xml = tools.toxml(self.cobertura, "")
	self:write('<?xml version="1.0" ?>\n')
	self:write('<!DOCTYPE coverage SYSTEM "http://cobertura.sourceforge.net/xml/coverage-04.dtd"> \n')
	self:write(xml)
end

end

local outputReporter = {

	CoberturaReporter = CoberturaReporter,

	report = function ()
		return reporter.report(CoberturaReporter)
	end
}

return outputReporter
