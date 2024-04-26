---@class IntIMGUIWidget: IMGUIWidget
IntIMGUIWidget = _Class:Create("IntIMGUIWidget", IMGUIWidget)

---@return any
function IntIMGUIWidget:CreateWidget(group, setting, settingValue, modGUID)
    local inputInt = group:AddInputInt(setting.Name, settingValue)
    inputInt.OnChange = function(value)
        IMGUILayer:SetConfigValue(setting.Id, value.Value[1], modGUID)
    end
    return inputInt
end
