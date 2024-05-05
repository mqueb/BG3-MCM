-- (FROM OLD MARKDOWN NOTES) The blueprint will be validated in the following ways:

-- - Check if each setting has a `Name`, `Type`, `Default`, and `Description` key;
-- - Check if the `Type` key is one of the supported types (`int`, `float`, `checkbox`, `text`, `enum`, `slider`, `radio`);
-- - Check if the `Default` key is of the correct type according to the `Type` key;
-- - Check if the `Options` key is present for `enum`, `radio`types;
-- - Check if the `Options` key is an array of strings for `enum` and `radio` types;
-- - Check if the `Min` and `Max` keys are present for `slider` type;
-- - Check if the `Min` and `Max` keys are numbers for `slider` type;
-- - Check if the `Min` key is less than the `Max` key for `slider`, `drag` types;
-- - Check if ID is unique for each setting across the blueprint.

TestSuite.RegisterTests("DataPreprocessing", {
    -- Blueprint structure validation
    "TestSanitizeBlueprintWithSchemaVersion",
    "TestSanitizeBlueprintWithoutSchemaVersion",
    "TestBlueprintShouldntHaveSections",
    "TestBlueprintShouldntHaveTabsAndSettings",
    "TestBlueprintShouldHaveTabsOrSettings",
    "TestBlueprintShouldHaveSettingsAtSomeLevel",

    --- Blueprint integrity validation
    -- IDs
    "TestUniqueTabIds",
    "TestUniqueSectionIds",
    "TestUniqueSettingIds",
    -- ...

    --- Setting definition validation
    -- Type
    -- "TestValidateSettingType",
    -- Default values
    -- "TestBlueprintDefaultForIntShouldBeNumber",
    -- "TestBlueprintDefaultForFloatShouldBeNumber",
    -- "TestBlueprintDefaultForEnumShouldBeOneOfTheOptions",
    -- "TestBlueprintDefaultForRadioShouldBeOneOfTheOptions",
    -- "TestBlueprintDefaultForCheckboxShouldBeBoolean",
    -- "TestBlueprintDefaultForNumberShouldBeNumber",
    -- "TestBlueprintDefaultForStringShouldBeString",
    -- "TestBlueprintDefaultForColorShouldBeString",
    -- "TestBlueprintDefaultForSliderIntShouldBeInteger",
    -- "TestBlueprintDefaultForSliderFloatShouldBeNumber",
    -- "TestBlueprintDefaultForDragIntShouldBeInteger",
    -- "TestBlueprintDefaultForDragFloatShouldBeNumber",
    -- "TestBlueprintDefaultForSliderShouldBeBetweenMinAndMax",
    -- "TestBlueprintDefaultForDragShouldBeBetweenMinAndMax",
    -- -- Options
    "BlueprintShouldHaveOptionsForEnum",
    "BlueprintShouldHaveOptionsForRadio",
    "BlueprintOptionsForEnumShouldHaveAChoicesArrayOfStrings",
    "BlueprintOptionsForRadioShouldHaveAChoicesArrayOfStrings",
    "BlueprintShouldHaveMinAndMaxForSlider",
    "BlueprintMinAndMaxForSliderShouldBeNumbers",
    "BlueprintMinShouldBeLessThanMaxForSlider",

    --- Broader blueprint integration tests?
    -- "TestSanitizeBlueprints",
    -- "TestValidateSettings",
    -- "TestHasSchemaVersionsEntry",
    -- "TestHasSectionsEntry",
    -- "TestPreprocessData"
})

function TestSanitizeBlueprintWithSchemaVersion()
    local blueprint = Blueprint:New({
        SchemaVersion = 1,
        Tabs = {
            {
                TabId = "tab-1",
            },
            {
                TabId = "tab-2",
            },
            {
                TabId = "tab-3",
            },
        }
    })
    local modGUID = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)

    TestSuite.AssertNotNil(sanitizedBlueprint)
end

function TestSanitizeBlueprintWithoutSchemaVersion()
    local blueprint = Blueprint:New({
    })
    local modGUID = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)

    TestSuite.AssertNil(sanitizedBlueprint)
end

function TestBlueprintShouldntHaveSections()
    local blueprint = Blueprint:New({
        SchemaVersion = 1,
        Settings = {}
    })
    local modGUID = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)

    TestSuite.AssertNil(sanitizedBlueprint)
end

function TestBlueprintShouldHaveTabsOrSettings()
    local blueprintWithTabs = Blueprint:New({
        SchemaVersion = 1,
        Tabs = {
            {
                TabId = "tab-1",
            },
            {
                TabId = "tab-2",
            },
            {
                TabId = "tab-3",
            },
        },
    })
    local modGUID = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint1 = DataPreprocessing:SanitizeBlueprint(blueprintWithTabs, modGUID)

    local blueprintWithSettings = Blueprint:New({
        SchemaVersion = 1,
        Settings = {
            {
                Id = "setting-1",
            },
            {
                Id = "setting-2",
            },
            {
                Id = "setting-3",
            },

        }
    })

    local modGUID2 = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint2 = DataPreprocessing:SanitizeBlueprint(blueprintWithSettings, modGUID2)


    TestSuite.AssertTrue(sanitizedBlueprint1 ~= nil and sanitizedBlueprint2 ~= nil)
end

function TestBlueprintShouldntHaveTabsAndSettings()
    local blueprint = Blueprint:New({
        SchemaVersion = 1,
        Tabs = {
            TabId = "tab-1",
        },
        Settings = {
            SettingId = "setting-1",
        }
    })
    local modGUID = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)

    TestSuite.AssertNil(sanitizedBlueprint)
end

function TestBlueprintShouldHaveSettingsAtSomeLevel()
    local allSettingsRootLevel = TestConstants.Blueprints.SettingsRootLevel:GetAllSettings()
    local allSettingsTabLevel = TestConstants.Blueprints.SettingsTabLevel:GetAllSettings()
    local allSettingsSectionLevel = TestConstants.Blueprints.SettingsSectionLevel:GetAllSettings()

    TestSuite.AssertTrue(next(allSettingsRootLevel) ~= nil)
    TestSuite.AssertTrue(next(allSettingsTabLevel) ~= nil)
    TestSuite.AssertTrue(next(allSettingsSectionLevel) ~= nil)
end
function TestUniqueTabIds()
    local blueprint = Blueprint:New({
        SchemaVersion = 1,
        Tabs = {
            {
                TabId = "tab-1",
            },
            {
                TabId = "tab-2",
            },
            {
                TabId = "tab-1",
            },
        }
    })
    local modGUID = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)

    TestSuite.AssertNil(sanitizedBlueprint)
end

function TestUniqueSectionIds()
    local blueprint = Blueprint:New({
        SchemaVersion = 1,
        Tabs = {
            {
                TabId = "tab-1",
                Sections = {
                    {
                        SectionId = "section-1",
                    },
                    {
                        SectionId = "section-2",
                    },
                    {
                        SectionId = "section-1",
                    },
                }
            }
        }
    })
    local modGUID = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)

    TestSuite.AssertNil(sanitizedBlueprint)
end

function TestUniqueSettingIds()
    -- local blueprint = Blueprint:New({
    --     SchemaVersion = 1,
    --     Tabs = {
    --         {
    --             TabId = "tab-1",
    --             Sections = {
    --                 {
    --                     SectionId = "section-1",
    --                     Settings = {
    --                         {
    --                             SettingId = "setting-1",
    --                         },
    --                         {
    --                             SettingId = "setting-2",
    --                         },
    --                         {
    --                             SettingId = "setting-1",
    --                         },
    --                     }
    --                 }
    --             }
    --         }
    --     }
    -- }
    local blueprint = Blueprint:New({
        SchemaVersion = 1,
        Settings = {
            {
                Id = "setting-1",
            },
            {
                Id = "setting-2",
            },
            {
                Id = "setting-1",
            },
        }
    })
    local modGUID = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)

    TestSuite.AssertNil(sanitizedBlueprint)
end

function TestValidateSettingType()
    local blueprint = TestConstants.Blueprints.SettingsRootLevel
    blueprint.Settings[1].Type = "invalid"
    TestSuite.Not(TestSuite.AssertContains)(TestConstants.validTypes, blueprint.Settings[1].Type)

    local modGUID = TestConstants.ModuleUUIDs[1]
    local sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)
    TestSuite.AssertNil(sanitizedBlueprint)

    ---

    blueprint = TestConstants.Blueprints.SettingsTabLevel
    blueprint.Tabs[1].Settings[1].Type = "invalid"
    TestSuite.Not(TestSuite.AssertContains)(TestConstants.validTypes, blueprint.Tabs[1].Settings[1].Type)

    sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)
    TestSuite.AssertNil(sanitizedBlueprint)

    ---

    blueprint = TestConstants.Blueprints.SettingsSectionLevel
    blueprint.Tabs[1].Sections[1].Settings[1].Type = "invalid"
    TestSuite.Not(TestSuite.AssertContains)(TestConstants.validTypes, blueprint.Tabs[1].Sections[1].Settings[1].Type)

    sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)
    TestSuite.AssertNil(sanitizedBlueprint)
end

function BlueprintShouldHaveOptionsForEnum()
    local blueprint = Blueprint:New({
        SchemaVersion = 1,
        Settings = {
            {
                Id = "setting-enum",
                Type = "enum",
                Default = "option-1"
            }
        }
    })
    local modGUID = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)

    TestSuite.AssertNil(sanitizedBlueprint)
end

function BlueprintShouldHaveOptionsForRadio()
    local blueprint = Blueprint:New({
        BlueprintSchemaVersion = 1,
        Settings = {
            {
                Id = "setting-radio",
                Type = "radio",
                Default = "option-1"
            }
        }
    })
    local modGUID = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)

    TestSuite.AssertNil(sanitizedBlueprint)
end

function BlueprintOptionsForEnumShouldHaveAChoicesArrayOfStrings()
    local blueprint = Blueprint:New({
        SchemaVersion = 1,
        Settings = {
            {
                Id = "setting-enum",
                Type = "enum",
                Options = {
                    1, 2, 3
                },
                Default = "option-1"
            }
        }
    })
    local blueprintWithChoices = Blueprint:New({
        SchemaVersion = 1,
        Settings = {
            {
                Id = "setting-enum",
                Type = "enum",
                Options = {
                    Choices = {
                        1, 2, 3
                    }
                },
                Default = "option-1"
            }
        }
    })
    local modGUID = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)
    local sanitizedBlueprintWithChoices = DataPreprocessing:SanitizeBlueprint(blueprintWithChoices, modGUID)

    TestSuite.AssertNil(sanitizedBlueprint)
    TestSuite.AssertNil(sanitizedBlueprintWithChoices)
end

function OptionsForRadioShouldHaveAChoicesArrayOfStrings()
    local blueprint = Blueprint:New({
        SchemaVersion = 1,
        Settings = {
            {
                Id = "setting-radio",
                Type = "radio",
                Options = {
                    1, 2, 3
                },
                Default = "option-1"
            }
        }
    })
    local blueprintWithChoices = Blueprint:New({
        SchemaVersion = 1,
        Settings = {
            {
                Id = "setting-radio",
                Type = "radio",
                Options = {
                    Choices = {
                        1, 2, 3
                    }
                },
                Default = "option-1"
            }
        }
    })
    local modGUID = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)
    local sanitizedBlueprintWithChoices = DataPreprocessing:SanitizeBlueprint(blueprintWithChoices, modGUID)

    TestSuite.AssertNil(sanitizedBlueprint)
    TestSuite.AssertNil(sanitizedBlueprintWithChoices)
end

function BlueprintShouldHaveMinAndMaxForSlider()
    local blueprint = Blueprint:New({
        SchemaVersion = 1,
        Settings = {
            {
                Id = "setting-slider",
                Type = "slider",
                Default = 50,
                Options = {
                }
            }
        }
    })
    local modGUID = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)

    TestSuite.AssertNil(sanitizedBlueprint)
end

function BlueprintMinAndMaxForSliderShouldBeNumbers()
    local blueprint = Blueprint:New({
        SchemaVersion = 1,
        Settings = {
            {
                Id = "setting-slider",
                Type = "slider",
                Default = 50,
                Options = {
                    Min = "0",
                    Max = "100"
                }
            }
        }
    })
    local modGUID = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)

    TestSuite.AssertNil(sanitizedBlueprint)
end

function BlueprintMinShouldBeLessThanMaxForSlider()
    local blueprint = Blueprint:New({
        SchemaVersion = 1,
        Settings = {
            {
                Id = "setting-slider",
                Type = "slider",
                Default = 50,
                Options = {
                    Min = 100,
                    Max = 0
                }
            }
        }
    })
    local modGUID = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)

    TestSuite.AssertNil(sanitizedBlueprint)
end

function TestBlueprintDefaultForEnumShouldBeOneOfTheOptions()
    local blueprint = Blueprint:New({
        SchemaVersion = 1,
        Settings = {
            {
                SettingId = "setting-1",
                Type = "enum",
                Options = {
                    "option-1",
                    "option-2",
                    "option-3"
                },
                Default = "option-4"
            }
        }
    })
    local modGUID = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)

    TestSuite.AssertNil(sanitizedBlueprint)
end

function TestBlueprintDefaultForRadioShouldBeOneOfTheOptions()
    local blueprint = Blueprint:New({
        SchemaVersion = 1,
        Settings = {
            {
                SettingId = "setting-1",
                Type = "radio",
                Options = {
                    "option-1",
                    "option-2",
                    "option-3"
                },
                Default = "option-4"
            }
        }
    })
    local modGUID = TestConstants.ModuleUUIDs[1]

    local sanitizedBlueprint = DataPreprocessing:SanitizeBlueprint(blueprint, modGUID)

    TestSuite.AssertNil(sanitizedBlueprint)
end

