script "Global | GIT | Settings | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | GIT | Settings | Menu
type: controller
version: 0.2


--> Menu | Init
-
local LocalArray

getprop menu_Target [tObject]
   _InitLocalArray tObject
   return LocalArray ["gitFolder"]
end menu_Target

private command _InitLocalArray tObject
   put the display_View of tObject into dView
   put the git_SettingsModel of dView into LocalArray
   return dView
end _InitLocalArray

private function _LocalValue someKey
   return LocalArray [someKey]
end _LocalValue

getprop documentation_Params
   return the hkey_CaseConditions ["M menu_Documentation"] of me
end documentation_Params

getprop disabled_CreateLocalGitIgnoreFile [projectFolder]
   return _LocalValue ("localIgnoreExists")
end disabled_CreateLocalGitIgnoreFile

getprop disabled_EditLocalGitIgnoreFile [projectFolder]
   return _LocalValue ("localIgnoreExists") is false
end disabled_EditLocalGitIgnoreFile

getprop disabled_CreateGlobalGitIgnoreFile [projectFolder]
   put git_GlobalIgnoreFile (projectFolder) into ignoreFile
   put there is a file ignoreFile into gIgnoreExists
   return gIgnoreExists
end disabled_CreateGlobalGitIgnoreFile

getprop overwriteIgnoreFile_Params [projectFolder]
   return "Global,Local"
end overwriteIgnoreFile_Params

getprop testIgnoreFile_Params [projectFolder]
   return "Global,Local"
end testIgnoreFile_Params

getprop disabled_FixRemote
   if _LocalValue ("gitHubRepoExists") is false then return true
   
   put _LocalValue ("gitRemoteAddress") into gitRemoteAddress
   if gitRemoteAddress is empty then
      return false
   else
      return "true"
   end if
end disabled_FixRemote

getprop disabled_DisplayRemote
   if _LocalValue ("gitFolder") is not empty then
      return false
   else
      return "delete"
   end if
end disabled_DisplayRemote

getprop setRemote_Params
   return github_ListOrgs()
end setRemote_Params

function text_LineEndingPlatform someText
   if someText contains CRLF then
      return "Windows"
   else if someText contains LF then
      return "Unix"
   else if someText contains CR then
      return "Mac"
   else
      return empty
   end if
end text_LineEndingPlatform


--> Working on
-
private function _AskRemote gitFolder, pOrgName
   if pOrgName is empty then put "LiveCodeWorld" into pOrgName
   --
   put _GetOldRemoteShortFile (gitFolder) into shortFile
   put merge ("https://github.com/[[pOrgName]]/") & shortFile into newRemoteURL
   --
   put lcw_Ask("Provide Github. https url:", newRemoteURL) into remoteURL
   return remoteURL
end _AskRemote

private function _GetOldRemoteShortFile gitFolder
   get git_GetRemote (gitFolder)
   put line 1 of it into oldRemote
   -- origin	https://github.com/LiveCodeWorld/lcw_Learn.git (fetch)
   delete word 1 of it
   delete word -1 of it
   put word 1 to -1 of it into oldRemote
   --
   set the itemdelimiter to slash
   put item -1 of oldRemote into shortFile
   return shortFile
end _GetOldRemoteShortFile


--> Global | GIT | Settings | Menu
-
on menu_Documentation projectFolder, whichDoc
   switch whichDoc
      case "Git Ignore"
         launch url "https://docs.github.com/en/free-pro-team@latest/github/using-git/ignoring-files"
         break
      case "Git Config"
         break
   end switch
end menu_Documentation

on menu_SetRemote projectFolder, orgNamme
   put _AskRemote (projectFolder) into remoteURL
   --
   put "git remote set-url origin" && remoteURL into someShell
   git_ExecuteShell someShell, projectFolder
   if the result is not empty then
      put the result
   end if
   --
   display_GitFolderStatus projectFolder
   display_GitLocalConfig projectFolder
end menu_SetRemote

on menu_DisplayLocalConfig projectFolder
   display_GitLocalConfig projectFolder
end menu_DisplayLocalConfig

on menu_DisplayGlobalConfig
   display_GitConfig
end menu_DisplayGlobalConfig

on _
end _

on menu_CreateLocalGitIgnoreFile projectFolder
   put git_LocalIgnoreFile (projectFolder) into ignoreFile
   lcw_Answer "Create and edit new local .ignore file in the local project directory?"
   --
   git_CreateLocalIgnoreFile projectFolder
   put the result into shellResult
   return ignoreFile
end menu_CreateLocalGitIgnoreFile

on menu_EditLocalGitIgnoreFile projectFolder
   put git_LocalIgnoreFile (projectFolder) into ignoreFile
   atom_DisplayFile ignoreFile
end menu_EditLocalGitIgnoreFile

on _
end _

on menu_CreateGlobalGitIgnoreFile projectFolder
   put git_GlobalIgnoreFile() into ignoreFile
   answer "Create and edit new global .ignore file in the $HOME directory?" with "Cancel" and "OK"
   if it is "Cancel" then exit to top
   --
   git_CreateGlobalIgnoreFile projectFolder
   put the result into ignoreFile
end menu_CreateGlobalGitIgnoreFile

on menu_EditGlobalGitIgnoreFile
   put git_GlobalIgnoreFile() into ignoreFile
   if there is not a file ignoreFile then
      answer "Create and edit new global .ignore file in the $HOME directory?" with "Cancel" and "OK"
      if it is "Cancel" then exit to top
      git_CreateIgnoreFile true, pIgnoreType
   end if
   
   display_TextFile ignoreFile, "Git Ignore Files"
   atom_Edit ignoreFile
end menu_EditGlobalGitIgnoreFile

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on _DisplayGitRemote projectFolder
   put git_GetRemoteAddress (projectFolder) into remoteAddress
   --
   put remoteAddress
   /*
   put LocalArray ["projectName"] into projectName
   put merge ("Edit the remote address for repo [[projectName]]...") into someQuestion
   put lcw_Ask (someQuestion, remoteAddress)
   */
end _DisplayGitRemote

on _ConfigureGitLogin
   put user_GetLogin() into userName
   put lcw_Ask("GIT user name...", userName) into userName
   --
   put "git config --global user.name" && kwote(userName) into someShell
   put git_ExecuteShellCommand (someShell) into shellResult
   --
   display_Text shellResult, "git config --list"
end _ConfigureGitLogin

on _ConfigureGitEmail
   put user_GetEmail() into userEmail
   put lcw_Ask("GIT user email...", userEmail) into userEmail
   --
   put "git config --global user.email" && kwote(userEmail) into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   --
   display_Text shellResult, "git config --list"
end _ConfigureGitEmail

on _IgnoreWhiteSpace
   get git_ExecuteShellCommand("git config --global apply.whitespace nowarn")
   if it is not empty then lcw_Notify it, true
   --
   put git_ExecuteShellCommand ("git config --list") into shellResult
   display_Text shellResult, "git config --list"
end _IgnoreWhiteSpace

on _
end _

on _AddGitIgnore
   breakpoint
   -- git add .gitignore
end _AddGitIgnore

on _FixRemote gitFolder
   breakpoint
   put _LocalValue ("projectName") into projectName
   put _LocalValue ("gitFolder") into gitFolder
   put _LocalValue ("gitRemoteAddress") into gitRemoteAddress
   --
   put merge ("git@github.com:LiveCodeWorld/[[projectName]].git") into newRemoteAddress
   put lcw_Ask ("Enter git remote address...", newRemoteAddress)into gitRemoteAddress
   --
   -- git_SetRemoteOrigin gitRemoteAddress, gitFolder
   git_AddFolderToRemote gitFolder, gitRemoteAddress
   put the result into shellResult
   --
   put shellResult
   --
   return shellResult
end _FixRemote

on _DisplayRemote
   put _LocalValue ("gitFolder") into gitFolder
   --
   put git_GetRemoteAddress (gitFolder)
end _DisplayRemote

on _OverwriteIgnoreFile gitFolder, menuChoice
   set the cursor to watch
   switch menuChoice
      case "Global"
         git_CreateIgnoreFile true
         put the result into ignoreFile
         break
      case "Local"
         git_CreateIgnoreFile
         put the result into ignoreFile
         break
   end switch
   display_TextFile ignoreFile, "Git Ignore Files"
   git_RefreshDisplay
end _OverwriteIgnoreFile

on _TestIgnoreFile gitFolder, menuChoice
   switch menuChoice
      case "Global"
         put git_GlobalIgnoreFile() into ignoreFile
         break
      case "Local"
         break
         put git_GlobalIgnoreFile() into ignoreFile
   end switch
   
   put url ("binfile:" & ignoreFile) into ignoreText
   put text_LineEndingPlatform (ignoreText) into somePlatform
   lcw_Notify somePlatform, true
end _TestIgnoreFile

on _FixGitIgnoreFile
   put git_GlobalIgnoreFile() into ignoreFile
   
   put "binfile:" & ignoreFile into someUrl
   put url someUrl into ignoreText
   replace CR with empty in ignoreText
   put ignoreText into url someUrl
end _FixGitIgnoreFile
