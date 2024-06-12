RequireFiles("Shared/Helpers/Validators/", {
    "CheckboxValidator",
    "EnumValidator",
    "FloatValidator",
    "IntValidator",
    "RadioValidator",
    "SliderIntValidator",
    "SliderFloatValidator",
    "DragIntValidator",
    "DragFloatValidator",
    "TextValidator",
    "ListValidator",
    "ColorValidator",
    "KeybindingValidator",
})

-- Validator functions for different setting types
SettingValidators = {
    ["int"] = function(setting, value)
        return IntValidator.Validate(setting, value)
    end,
    ["float"] = function(setting, value)
        return FloatValidator.Validate(setting, value)
    end,
    ["checkbox"] = function(setting, value)
        return CheckboxValidator.Validate(setting, value)
    end,
    ["text"] = function(setting, value)
        return TextValidator.Validate(setting, value)
    end,
    ["list"] = function(setting, value)
        return ListValidator.Validate(setting, value)
    end,
    ["enum"] = function(setting, value)
        return EnumValidator.Validate(setting, value)
    end,
    ["slider_int"] = function(setting, value)
        return SliderIntValidator.Validate(setting, value)
    end,
    ["slider_float"] = function(setting, value)
        return SliderFloatValidator.Validate(setting, value)
    end,
    ["drag_int"] = function(setting, value)
        return DragIntValidator.Validate(setting, value)
    end,
    ["drag_float"] = function(setting, value)
        return DragFloatValidator.Validate(setting, value)
    end,
    ["radio"] = function(setting, value)
        return RadioValidator.Validate(setting, value)
    end,
    ["color_picker"] = function(setting, value)
        return ColorValidator.Validate(setting, value)
    end,
    ["color_edit"] = function(setting, value)
        return ColorValidator.Validate(setting, value)
    end,
    ["keybinding"] = function(setting, value)
        return KeybindingValidator.Validate(setting, value)
    end,
}

return SettingValidators
