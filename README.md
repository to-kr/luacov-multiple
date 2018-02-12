luacov-multiple
================

LuaCov is a simple coverage analyzer for Lua scripts. The `luacov-multiple`
contains reports
* cobertura [dtd-04](https://github.com/cobertura/web/blob/master/htdocs/xml/coverage-04.dtd)
* html

with possibility to generate multiple reports at once.

## Installation

`[sudo] luarocks install luacov-multiple`

## Usage

 * Set specific multiple params in configuration file
 * Run tests with enabled [LuaCov](https://github.com/keplerproject/luacov)
 
 ## Specific configuration

The configuration file may contain a specific params:
```
local configuration = {
	-- standard luacov configuration keys and values here
    runreport = true,
    reportfile = 'output/coverage/report/luacov.report.out',

    -- multiple settings
    reporter = "multiple",

    multiple = {
        reporters = {"default", "multiple.cobertura", "multiple.html"},
        cobertura = {
            reportfile = 'output/coverage/report/cobertura.xml'
        },
        html = {
            reportfile = 'output/coverage/report/index.html'
        }
    }
}
return configuration
```