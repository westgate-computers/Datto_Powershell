--[[
    name: Remove_ScreenConnectClient
    filetype: Datto ERD Extension, formerly Infocyte
    type: response
    description: |  
        Remove all instances of ScreenConnect Client 
    author: Walker Chesley
    created: 2025-03-28
    updated: 2025-03-28

    GLOBAL VARIABLES
    * Variable Name: 
        * variable description
        * variable type
        * default (true or false)
        * required (true or false)

    USAGE
    * Run as response in Datto ERD for ScreenConnect alerts

    VERSION
    * 1.0

    BUGS, COMMENTS, SUGGESTIONS
    * Send to Walker Chesley, chesley.walker@gmail.com

    CHANGES
    * Created 
        
    ADDITIONAL SOFTWARE NEEDED FOR THIS SCRIPT
    * none
]]

-- - - - - - - - - - - - - - - - - - - - - - - -
-- C O N S T A N T S
-- - - - - - - - - - - - - - - - - - - - - - - -

-- Define script constants here
local executionSummary = ""
local stopServicesCommand = 'Get-Service -Name ScreenConnect* | Stop-Service -Force'
local programFilesPath = '"C:\\Program Files (x86)\\ScreenConnect*"'
local programDataPath = '"C:\\ProgramData\\ScreenConnect*"'

-- - - - - - - - - - - - - - - - - - - - - - - -
-- F U N C T I O N S
-- - - - - - - - - - - - - - - - - - - - - - - -

-----  FUNCTION  ---------------------------------------------------------------
--         NAME:  logMessage
--      PURPOSE:  Datto EDR Logging helper
--  DESCRIPTION:  if message is error, log it. Else append logMessage to executionSummary
--   PARAMETERS:  
--          isError: <bool>: true for error, false for summary logs
--       logMessage: <string> Message to be logged.
--      RETURNS:  nil
--------------------------------------------------------------------------------
local function logMessage(isError, logMessage)
    if isError == true then
        hunt.error(logMessage)
    else
        hunt.log(logMessage)
        executionSummary = executionSummary .. logMessage
    end
end

-----  FUNCTION  ---------------------------------------------------------------
--         NAME:  iterateUsersAppData
--      PURPOSE:  Iterate through user profiles and check for AppData\Local\Apps
--  DESCRIPTION:  This function checks each user profile for the existence of the Apps directory in AppData\Local.
--   PARAMETERS:  None
--      RETURNS:  results: <table>: A table containing paths to the Apps directories found.
--------------------------------------------------------------------------------
local function iterateUsersAppData()
    -- Get all users profiles via Datto EDR: 
    local users = hunt.fs.ls("C:\\Users")
    -- table to hold results: 
    local results = {}
    -- Iterate over each user profile
    for _, user in ipairs(users) do
        if user:type() == "dir" then  -- Ensure it's a directory
            local appdata_path = user:path() .. "\\AppData\\Local\\Apps\\2.0"

            -- Check if the "Apps" directory exists
            if hunt.fs.exists(appdata_path) then
                table.insert(results, appdata_path)  -- Store the valid path
                hunt.env.run_powershell('rm -Recurse -Force ' .. appdata_path)  -- Remove the directory
                hunt.log(f"Found Apps folder: {appdata_path}")
            end
        end
    end
        -- Output Results
    if #results > 0 then
        hunt.log(f"Found 'Apps' directories in {#results} user(s).")
    else
        hunt.log("No 'Apps' directories found.")
    end

    return results  -- Return results for further processing if needed
end

-- - - - - - - - - - - - - - - - - - - - - - - -
-- M A I N
-- - - - - - - - - - - - - - - - - - - - - - - -

-- Main script execution here

-- Print starting message
hunt.log("Starting Remove_ScreenConnectClient script execution")

-- Stop ScreenConnect services
local stopServiceResult = hunt.env.run_powershell(stopServicesCommand)
huht.log("Stopped ScreenConnect services")

-- Remove ScreenConnect client directory using os.execute and rmdir
local removeProgramFilesResult = hunt.env.run_powershell('rm -Recurse -Force ' .. programFilesPath)
huht.log("Removed ScreenConnect client in Program Files (x86)")

-- Remove ScreenConnect Data Directory
local removeDataDirectoryResult = hunt.env.run_powershell('rm -Recurse -Force ' .. programDataPath)
huht.log("Removed ScreenConnect Data Directory")

if stopServiceResult then
    logMessage(false, stopServiceResult)
end
if removeDataDirectoryResult then
    logMessage(false, removeDataDirectoryResult)
end
if removeProgramFilesResult then
    logMessage(false, removeProgramFilesResult)
end

if not executionSummary or executionSummary == "" then
    hunt.summary("ERROR: Failed to remove ScreenConnectClient")
else
    iterateUsersAppData()
    hunt.summary(executionSummary)
end