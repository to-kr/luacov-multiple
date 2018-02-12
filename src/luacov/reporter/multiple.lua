local luacov = require("luacov.runner")

local MultipleReporter = {}

function MultipleReporter.report()
    local configuration = luacov.load_config()
    local reporters = {"default"}

    if configuration.multiple and configuration.multiple.reporters then
        reporters = configuration.multiple.reporters
    end

    for _, name in ipairs(reporters) do
        local reporter = require("luacov.reporter." .. name)
        local reporterClassName = name:gsub("^multiple.", ""):gsub("^%l", string.upper) .. 'Reporter'
        if not reporter[reporterClassName] then
            print('The "' .. name .. '" reporter is not compatible with "multiple" reporter.')
            os.exit(1)
        end

        local rep, err = reporter[reporterClassName]:new(configuration)
        if not rep then
            print(err)
            print("Run your Lua program with -lluacov and then rerun luacov.")
            os.exit(1)
        end

        rep:run()
        rep:close()
    end

    if configuration.deletestats then
       os.remove(configuration.statsfile)
    end
end

return MultipleReporter
