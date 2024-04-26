---@class CheckboxIMGUIWidget: IMGUIWidget
CheckboxIMGUIWidget = _Class:Create("CheckboxIMGUIWidget", IMGUIWidget)

---@return any widget
function CheckboxIMGUIWidget:CreateWidget(group, setting, settingValue, modGUID)
    local checkbox = group:AddCheckbox(setting.Name, settingValue)
    checkbox.OnChange = function(value)
        IMGUILayer:SetConfigValue(setting.Id, value.Checked, modGUID)
    end
    return checkbox
end
