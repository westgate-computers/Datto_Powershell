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


-- - - - - - - - - - - - - - - - - - - - - - - -
-- M A I N
-- - - - - - - - - - - - - - - - - - - - - - - -

-- Main script execution here

-- Print starting message
hunt.log("Starting Remove_ScreenConnectClient script execution")

-- Stop ScreenConnect services
local stopServiceResult = hunt.env.run_powershell(stopServicesCommand)
print("Stopped ScreenConnect services")

-- Remove ScreenConnect client directory using os.execute and rmdir
local removeProgramFilesResult = hunt.env.run_powershell('rm -Recurse -Force ' .. programFilesPath)
print("Removed ScreenConnect client in Program Files (x86)")

-- Remove ScreenConnect Data Directory
local removeDataDirectoryResult = hunt.env.run_powershell('rm -Recurse -Force ' .. programDataPath)
print("Removed ScreenConnect Data Directory")

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
    hunt.summary(executionSummary)
end