local reporter = require("luacov.reporter")
local lfs = require("lfs")
local lustache = require("lustache")
local tools = require("luacov.multiple.tools")

local templateFile = require('luacov.multiple.templatefile')
local templatePackage = require('luacov.multiple.templatepackage')
local css = require('luacov.multiple.templatecss')

local ReporterBase = reporter.ReporterBase


-- ReporterBase provide
--  write(str) - write string to output file
--  config()   - return configuration table

local HtmlReporter = setmetatable({}, ReporterBase) do
HtmlReporter.__index = HtmlReporter

function HtmlReporter:new(conf)
	local confOver = conf.multiple.html and conf.multiple.html or {}
	confOver.reportfile = confOver.reportfile and confOver.reportfile or 'luacov_html/index.html'

	local config = {}
	for k, v in pairs(conf) do
		config[k] = confOver[k] and confOver[k] or v
	end

	local o, err = ReporterBase.new(self, config)
	if not o then
		return nil, err
	end

	o.reportDir = string.gsub(config.reportfile, "(.*[/\\])(.*)", "%1")

	return o
end

function HtmlReporter:on_start()
	self.data = {
		coverage = {
			timestamp = os.time() * 1000,
			sources = {},
			packages = {}
		}
	}

	self.summaries = {}
end

function HtmlReporter:on_new_file(filename)
	-- class_name:   "test/package/file.lua" -> "file.lua"
	-- package_name: "test/package/file.lua" -> "test/package"
	local package_name, class_name = filename:match("^(.*)/([^/]+)")
	class_name = class_name or ""
	package_name = package_name or filename

	local package
	for _, p in pairs(self.data.coverage.packages) do
		if p.name == package_name then
			package = p
			break
		end
	end
	-- create package if we weren't able to find it
	if not package then
		package = {
			name = package_name,
			report = package_name:gsub("^/", "") .. "/index",
			["rate"] = 0,
			["hits"] = 0,
			["miss"] = 0,
			["rateFormatted"] = "0",
			["rateTo100Formatted"] = "100",
			["status"] = "",
				classes = {},
		}
		table.insert(self.data.coverage.packages, package)
	end

	local class = {
		name = class_name,
		filename = filename,
		report = class_name,
		["rate"] = 0,
		["rateFormatted"] = "0",
		["rateTo100Formatted"] = "100",
		["status"] = "",
		lines = {},
	}
	table.insert(package.classes, class)

	self.current_package = package
	self.current_class = class
end

function HtmlReporter:on_empty_line(filename, lineno, line) -- luacheck: no unused args
	table.insert(self.current_class.lines, { number = lineno, hits='-', hitsText=' ', line = tools.rtrim(line) })
end

function HtmlReporter:on_mis_line(filename, lineno, line) -- luacheck: no unused args
	table.insert(self.current_class.lines, { number = lineno, hits = 0, hitsText=' ', line = tools.rtrim(line) })
end

function HtmlReporter:on_hit_line(filename, lineno, line, hits) -- luacheck: no unused args
	table.insert(self.current_class.lines, { number = lineno, hits = hits, hitsText =  hits .. 'x', line = tools.rtrim(line) })
end

--- Handle when a file has been completely parsed from start to end
-- @param filename
-- @param hits
-- @param miss
function HtmlReporter:on_end_file(filename, hits, miss)
	self.current_package["hits"] = self.current_package["hits"] + hits
	self.current_package["miss"] = self.current_package["miss"] + miss
	self.current_package["rate"] =
		self.current_package["hits"] / (self.current_package["hits"] + self.current_package["miss"])
	self.current_package["rateFormatted"] = tonumber(string.format("%.2f", self.current_package["rate"] * 100))
	self.current_package["rateTo100Formatted"] = tonumber(string.format("%.2f", 100 - self.current_package["rate"] * 100))
	self.current_package["status"] = tools.status(self.current_package["rate"])

	self.current_class["hits"] = hits
	self.current_class["miss"] = miss
	self.current_class["rate"] = hits / (hits + miss)
	self.current_class["rateFormatted"] = tonumber(string.format("%.2f", self.current_class["rate"] * 100))
	self.current_class["rateTo100Formatted"] = tonumber(string.format("%.2f", 100 - self.current_class["rate"] * 100))
	self.current_class["status"] = tools.status(self.current_class["rate"])

	self.summaries[filename] = {
		hits = hits,
		miss = miss,
	}
	-- create dirs
	local dir = self.reportDir:gsub('[/\\]$', '')
	local packageParts = tools.packageParts(self.current_package.name)
	for _, part in pairs(packageParts) do
		lfs.mkdir(dir .. part.path)
	end
	-- write html file
	local out, err = io.open(self.reportDir .. filename .. '.html', "w")
	if not out then return nil, err end
	out:write(lustache:render(templateFile, {
		css = css,
		filename = filename,
		basename = filename:gsub("(.*/)(.*)", "%2"),
		packageParts = packageParts,
		lines = self.current_class.lines,
		path = self.current_package.name,
		link = {
			root = '../' .. packageParts[1].rootLink .. 'index.html',
			package = 'index.html'
		},
		hits = hits,
		miss = miss,
		rate = self.current_class["rate"],
		rateFormatted = self.current_class["rateFormatted"],
		status = self.current_class["status"],
		datetime = os.date("%Y-%m-%d %H:%M:%S", self.data.coverage.timestamp / 1000)
	}))
	out:close()
end

--- Handle when the entire report has been completely parsed
function HtmlReporter:on_end()
	table.sort(self.data.coverage.packages, function(a, b) return a.name < b.name end)
	for _, package in pairs(self.data.coverage.packages) do
		local packageParts = tools.packageParts(package.name)
		table.sort(package.classes, function(a, b) return a.name < b.name end)
		-- write package html file
		local out, err = io.open(self.reportDir .. package.name .. '/index.html', "w")
		if not out then return nil, err end
		out:write(lustache:render(templatePackage, {
			css = css,
			package = {
				hits = package.hits,
				miss= package.miss,
				rate = tonumber(string.format("%.2f", package.rate * 100)),
			},
			packageParts = packageParts,
			classes = package.classes,
			path = package.name,
			link = {
				root = '../' .. packageParts[1].rootLink .. 'index.html',
				package = 'index.html'
			},
			status = package.status,
			datetime = os.date("%Y-%m-%d %H:%M:%S", self.data.coverage.timestamp / 1000)
		}))
		out:close()
	end

	-- calculate the total line rate
	local total_hits = 0
	local total_miss = 0
	for _,summary in pairs(self.summaries) do
		total_hits = total_hits + summary.hits
		total_miss = total_miss + summary.miss
	end
	local total_rate = (total_hits / (total_hits + total_miss))

	-- write main html file
	local out, err = io.open(self.reportDir .. 'index.html', "w")
	if not out then return nil, err end
	out:write(lustache:render(templatePackage, {
		css = css,
		package = {
			hits = total_hits,
			miss= total_miss,
			rate = tonumber(string.format("%.2f", total_rate * 100)),
		},
		packageParts = {},
		classes = self.data.coverage.packages,
		link = {
			root = 'index.html',
			package = 'index.html'
		},
		status = tools.status(total_rate),
		datetime = os.date("%Y-%m-%d %H:%M:%S", self.data.coverage.timestamp / 1000)
	}))
	out:close()
end

end

local outputReporter = {

	HtmlReporter = HtmlReporter,

	report = function ()
		return reporter.report(HtmlReporter)
	end
}

return outputReporter
