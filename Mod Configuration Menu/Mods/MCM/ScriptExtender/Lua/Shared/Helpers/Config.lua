Config = VCHelpers.Config:New({
    folderName = "BG3MCM",
    configFilePath = "mod_configuration_menu.json",
    defaultConfig = {
        GENERAL = {
            enabled = true,        -- Toggle the mod on/off
        },
        FEATURES = {               -- Options that can override values set by mod authors?
        },
        DEBUG = {
            level = 0 -- 0 = no debug, 1 = minimal, 2 = verbose debug logs
        },
        onConfigReloaded = {}
    }
})

Config:UpdateCurrentConfig()

Config:AddConfigReloadedCallback(function(configInstance)
  ISFPrinter.DebugLevel = configInstance:GetCurrentDebugLevel()
  ISFPrint(0, "Config reloaded: " .. Ext.Json.Stringify(configInstance:getCfg(), { Beautify = true }))
end)
Config:RegisterReloadConfigCommand("mcm_reload")
