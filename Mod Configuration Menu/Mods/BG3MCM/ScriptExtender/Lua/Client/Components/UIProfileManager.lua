UIProfileManager = {}

function UIProfileManager:FindProfileIndex(profile)
    for i, name in ipairs(MCMAPI:GetProfiles().Profiles) do
        if name == profile then
            return i
        end
    end
    return nil
end

--- Create widgets for managing profiles (selecting, creating, deleting)
function UIProfileManager:CreateProfileCollapsingHeader()
    local getDeleteProfileButtonLabel = function(profile)
        if profile == "Default" then
            return "Cannot delete the default profile."
        else
            return "Delete profile '" .. profile .. "'"
        end
    end

    local profiles = MCMAPI:GetProfiles()
    local currentProfile = MCMAPI:GetCurrentProfile()
    local profileIndex = UIProfileManager:FindProfileIndex(currentProfile) - 1

    local profileCollapsingHeader = MCM_WINDOW:AddCollapsingHeader("Profile management")
    local profileCombo = profileCollapsingHeader:AddCombo("Select profile")

    profileCombo.Options = profiles.Profiles
    profileCombo.SelectedIndex = profileIndex or 1

    profileCollapsingHeader:AddSeparator()
    profileCollapsingHeader:AddText("Create a new profile")
    local newProfileName = profileCollapsingHeader:AddInputText("")
    local profileButton = profileCollapsingHeader:AddButton("Create")
    profileButton.SameLine = true

    local deleteProfileButton = profileCollapsingHeader:AddButton(getDeleteProfileButtonLabel(MCMAPI:GetCurrentProfile()))
    self:SetupDeleteProfileButton(deleteProfileButton, profileCombo, getDeleteProfileButtonLabel)

    self:SetupCreateProfileButton(profileButton, newProfileName, profileCombo, getDeleteProfileButtonLabel,
        deleteProfileButton)

    self:SetupProfileComboOnChange(profileCombo, getDeleteProfileButtonLabel, deleteProfileButton)
    -- TODO: refresh the settings UI when creating profiles
end

function UIProfileManager:SetupDeleteProfileButton(deleteProfileButton, profileCombo, getDeleteProfileButtonLabel)
    deleteProfileButton.OnClick = function()
        local currentProfile = MCMAPI:GetCurrentProfile()
        if currentProfile ~= "Default" then
            MCMAPI:DeleteProfile(currentProfile)
            profileCombo.Options = MCMAPI:GetProfiles().Profiles
            MCMAPI:SetProfile("Default")
            profileCombo.SelectedIndex = UIProfileManager:FindProfileIndex(MCMAPI:GetCurrentProfile()) - 1
            deleteProfileButton.Label = getDeleteProfileButtonLabel(MCMAPI:GetCurrentProfile())
        else
            MCMWarn(0, "Cannot delete the default profile.")
        end
    end
end

function UIProfileManager:SetupCreateProfileButton(profileButton, newProfileName, profileCombo,
                                                   getDeleteProfileButtonLabel,
                                                   deleteProfileButton)
    profileButton.OnClick = function()
        if newProfileName.Text ~= "" then
            MCMAPI:CreateProfile(newProfileName.Text)
            MCMAPI:SetProfile(newProfileName.Text)
            newProfileName.Text = ""
            profileCombo.Options = MCMAPI:GetProfiles().Profiles
            profileCombo.SelectedIndex = UIProfileManager:FindProfileIndex(MCMAPI:GetCurrentProfile()) - 1
            deleteProfileButton.Label = getDeleteProfileButtonLabel(MCMAPI:GetCurrentProfile())
        end
    end
end

function UIProfileManager:SetupProfileComboOnChange(profileCombo, getDeleteProfileButtonLabel, deleteProfileButton)
    profileCombo.OnChange = function(inputChange)
        local selectedIndex = inputChange.SelectedIndex + 1
        local selectedProfile = inputChange.Options[selectedIndex]

        -- Handle the placeholder option (this isn't used anymore)
        if selectedProfile == "Select a setting profile" then
            MCMWarn(1, "Please select a valid profile.")
            -- Reset the combo box to the current profile
            MCMAPI:GetCurrentProfile()
            profileCombo.SelectedIndex = UIProfileManager:FindProfileIndex(MCMAPI:GetCurrentProfile()) - 1
            return
        end

        MCMAPI:SetProfile(selectedProfile)

        if deleteProfileButton then
            deleteProfileButton.Label = getDeleteProfileButtonLabel(selectedProfile)
        end
    end
end
