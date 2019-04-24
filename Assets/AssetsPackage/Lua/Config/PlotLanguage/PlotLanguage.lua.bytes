local PlotLanguage = {
    GetConfigTbl = function(path)
        return require(path)
    end,

    GetString = function(tableName, id)
        local tbl = ConfigUtil.GetConfigTbl("Config.PlotLanguage." .. tableName)
        if tbl then
            return tbl[id]
        end
        return ''
    end,
}

return PlotLanguage