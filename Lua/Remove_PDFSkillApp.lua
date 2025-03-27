--[[
    Remove_PDFSkillsApp - Remove PDFSkills application from users profiles

    script_name - Iterate over all users Local AppData directories and remove any 
    PdfSkills directories. PdfSkills is PUA/PUP/Adware. 

    ADDITIONAL SOFTWARE NEEDED FOR THIS SCRIPT
    * none

    USAGE
    * Run as response via Datto EDR
    * Run locally (provided Lua is installed) lua Remove_PDFSkillsApp.lua

    VERSION
    * 1.0

    AUTHOR
    * Walker Chesley

    BUGS, COMMENTS, SUGGESTIONS
    * Send to Walker Chesley, chesley.walker@gmail.com

    CHANGES
    * Last Updated: 2025-03-27
    * Created Script
]]

-- - - - - - - - - - - - - - - - - - - - - - - -
-- C O N S T A N T S
-- - - - - - - - - - - - - - - - - - - - - - - -

local userProfilePath = "C:\\users"
local removeTarget = "pdfskills"

-- - - - - - - - - - - - - - - - - - - - - - - -
-- F U N C T I O N S
-- - - - - - - - - - - - - - - - - - - - - - - -

-- Function to get all directories (user profiles) in C:\Users
local function getUserProfiles(basePath)
    local profiles = {}
    local command = 'dir "' .. basePath .. '" /b /ad'
    local handle = io.popen(command)
    if handle then
        for line in handle:lines() do
            table.insert(profiles, line)
        end
        handle:close()
    end
    return profiles
end

-- Function to delete a folder recursively
local function deleteFolder(path)
    if not hunt.fs.path_exists(path) then
        hunt.error("Path does not exist at" .. path)
        return
    end
    local command = 'rmdir /s /q "' .. path .. '"'
    local result = hunt.env.run_powershell(command)
    if result then
        hunt.log("Folder removed: " .. path)
    else
        hunt.error("Failed to remove folder: " .. path)
    end
end

-- - - - - - - - - - - - - - - - - - - - - - - -
-- M A I N
-- - - - - - - - - - - - - - - - - - - - - - - -

-- Iterate over each user's AppData/Local directory and remove pdfskills directory 
local profiles = getUserProfiles(userProfilePath)
for _, profile in ipairs(profiles) do
    local fullPath = userProfilePath .. "\\" .. profile .. "\\appdata\\" .. removeTarget
    deleteFolder(fullPath)
end

hunt.log("Remove PDFSkills script execution complete")