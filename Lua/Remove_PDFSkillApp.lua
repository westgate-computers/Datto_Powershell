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
    * Please use the repository Issues page: https://github.com/westgate-computers/Datto_Powershell/issues

    CHANGES
    * Last Updated: 2025-03-28
    * Created Script
    * Added logMessage(bool,string) function for logging
]]

-- - - - - - - - - - - - - - - - - - - - - - - -
-- C O N S T A N T S
-- - - - - - - - - - - - - - - - - - - - - - - -

local userProfilePath = "C:\\users"
local removeTarget = "pdfskills"
local executionSummary = ""

-- - - - - - - - - - - - - - - - - - - - - - - -
-- F U N C T I O N S
-- - - - - - - - - - - - - - - - - - - - - - - -

-- Function to assist with logging, appends logs to executionSummary variable
-- PARAMETERS:
-- bool: isError - control error or regular log message, true for error false for normal log
-- string: logMessage - The message to be logged.
local function logMessage(isError, logMessage)
    if isError == true then
        hunt.error(logMessage)
    else
        hunt.log(logMessage)
    end
    executionSummary = executionSummary .. logMessage
end

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
        logMessage(true, "Path does not exist at" .. path)
        return
    end
    local command = 'rmdir /s /q "' .. path .. '"'
    local result = hunt.env.run_powershell(command)
    if result then
        logMessage(false, "SUCCESS: Folder removed: " .. path)
    else
        logMessage(true, "FAILED: Folder not removed: " .. path)
    end
end

-- - - - - - - - - - - - - - - - - - - - - - - -
-- M A I N
-- - - - - - - - - - - - - - - - - - - - - - - -

-- Iterate over each user's AppData/Local directory and remove pdfskills directory 
local profiles = getUserProfiles(userProfilePath)
for _, profile in ipairs(profiles) do
    local fullPath = userProfilePath .. "\\" .. profile .. "\\appdata\\local\\" .. removeTarget
    deleteFolder(fullPath)
end

hunt.summary(executionSummary)