---@class FloatIMGUIWidget: IMGUIWidget
FloatIMGUIWidget = _Class:Create("FloatIMGUIWidget", IMGUIWidget)

---@return boolean
function FloatIMGUIWidget:CreateWidget(group, setting, settingValue, modGUID)
    local inputScalar = group:AddInputScalar(setting.Name, settingValue)
    inputScalar.OnChange = function(value)
        IMGUILayer:SetConfigValue(setting.Id, value.Value[1], modGUID)
    end
    return inputScalar
end
