---@class SliderIntValidator: Validator
SliderIntValidator = _Class:Create("SliderIntValidator", Validator)

function SliderIntValidator.Validate(config, value)
    local isValueNumber = type(value) == "number"
    local isValueWithinRange = value >= config.Options.Min and value <= config.Options.Max
    return isValueNumber and isValueWithinRange
end
