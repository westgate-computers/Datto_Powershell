#################### Updated_Visual_Studio17 ########################
# Description: Updates Visual Studio 2017, assumes default install  #
# location for Visual Studio 2017 Community. 

#####################################################################
# Author: Walker Chesley                                            #
# Change List: List your changes here:                              #
# 09/07/2023 - Created Script                                       #

#####################################################################

# pulled from: https://stackoverflow.com/questions/48901633/how-to-update-visual-studio-2017-using-command-line
& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" update --passive --norestart --installpath "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community"