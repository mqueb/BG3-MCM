-- "Give someone state and they'll have a bug one day, but teach them how to represent state in two separate locations that have to be kept in sync and they'll have bugs for a lifetime."
-- -ryg

UIProfileManager = {}

function UIProfileManager:FindProfileIndex(profile)
    for i, name in ipairs(MCMAPI:GetProfiles().Profiles) do
        if name == profile then
            return i
        end
    end
    return nil
end

local function getDeleteProfileButtonLabel(profile)
    if profile == "Default" then
        return "Cannot delete the default profile."
    else
        return "Delete profile '" .. profile .. "'"
    end
end

--- Create widgets for managing profiles (selecting, creating, deleting)
function UIProfileManager:CreateProfileCollapsingHeader()

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
    self:SetupDeleteProfileButton(deleteProfileButton, profileCombo)

    self:SetupCreateProfileButton(profileButton, newProfileName, profileCombo,
        deleteProfileButton)

    self:SetupProfileComboOnChange(profileCombo, deleteProfileButton)
    -- TODO: refresh the settings UI when creating profiles
end

function UIProfileManager:UpdateDeleteProfileButton(deleteProfileButton, profile)
    if deleteProfileButton == nil then
        return
    end

    local newLabel = getDeleteProfileButtonLabel(MCMAPI:GetCurrentProfile())
    deleteProfileButton.Label = newLabel

    if profile == "Default" then
        deleteProfileButton.Visible = false
    else
        deleteProfileButton.Visible = true
    end
end

function UIProfileManager:SetupDeleteProfileButton(deleteProfileButton, profileCombo)
    deleteProfileButton.OnClick = function()
        local currentProfile = MCMAPI:GetCurrentProfile()
        if currentProfile ~= "Default" then
            MCMAPI:DeleteProfile(currentProfile)
            profileCombo.Options = MCMAPI:GetProfiles().Profiles
            MCMAPI:SetProfile("Default")
            profileCombo.SelectedIndex = UIProfileManager:FindProfileIndex(MCMAPI:GetCurrentProfile()) - 1
            self:UpdateDeleteProfileButton(deleteProfileButton, MCMAPI:GetCurrentProfile())

            -- TODO: handle the response from the server
            Ext.Net.PostMessageToServer(Channels.MCM_CLIENT_REQUEST_DELETE_PROFILE, Ext.Json.Stringify({
                profileName = currentProfile
            }))
        else
            MCMWarn(0, "Cannot delete the default profile.")
        end
    end
end

function UIProfileManager:SetupCreateProfileButton(profileButton, newProfileName, profileCombo,
                                                   deleteProfileButton)
    profileButton.OnClick = function()
        if newProfileName.Text ~= "" then
            MCMAPI:CreateProfile(newProfileName.Text)
            MCMAPI:SetProfile(newProfileName.Text)

            -- TODO: handle the response from the server
            Ext.Net.PostMessageToServer(Channels.MCM_CLIENT_REQUEST_CREATE_PROFILE, Ext.Json.Stringify({
                profileName = newProfileName.Text
            }))

            newProfileName.Text = ""
            profileCombo.Options = MCMAPI:GetProfiles().Profiles
            profileCombo.SelectedIndex = UIProfileManager:FindProfileIndex(MCMAPI:GetCurrentProfile()) - 1
            self:UpdateDeleteProfileButton(deleteProfileButton, MCMAPI:GetCurrentProfile())
        end
    end
end

function UIProfileManager:SetupProfileComboOnChange(profileCombo, deleteProfileButton)
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

        -- TODO: handle the response from the server
        Ext.Net.PostMessageToServer(Channels.MCM_CLIENT_REQUEST_SET_PROFILE, Ext.Json.Stringify({
            profileName = selectedProfile
        }))

        self:UpdateDeleteProfileButton(deleteProfileButton, selectedProfile)
    end
end
