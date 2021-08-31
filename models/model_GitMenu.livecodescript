script "model_GitMenu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_GitMenu
type: model
version: 0.1

/*
This model is for multiple menus sharing information about the current giFolder's project.
*/

--> Variables
-
local LocalArray


--> Display | Events
-
command display_GitCommitHistory gitFolder
   put git_CurrentBranchName (gitFolder) into branchName
   put git_ExecuteShellCommand ("git log", gitFolder) into commitHistory
   --
   display_Lines commitHistory, "git log", "mDoubleUp_GitLog", branchName
   put the result into indexView
   --
   set the title_Menu of indexView to "Global | Git | Log | Menu"
   set the line_Menu of indexView to "Global | Git | Line | Log | Menu"
end display_GitCommitHistory

command mDoubleUp_GitLog indexView, someLine
   put git_LocalArray ("gitFolder") into gitFolder
   
   switch word 1 of someLine
      case "commit"
         put word 2 of someLine into commitHash
         
         put commitHash & ":" & "lcw_GIT.livecode" into treeish
         put git_List (treeish, gitFolder)
         
         exit to top
         lcw_Answer merge ("Do you want to revert to checked out project [[commitHash]]?")
         
         breakpoint
         put "git checkout" && commitHash into someShell
         put git_ExecuteShellCommand (someShell, gitFolder) into shellResult
         --
         put git_LocalArray ("projectName") into projectName
         display_GitRefreshProjectName projectName
         break
      default
   end switch
end mDoubleUp_GitLog


--> GIT | Menu | Model
-
function git_LocalArray someKey
   return LocalArray [someKey]
end git_LocalArray

command git_ClearMenuModel dView
   delete variable LocalArray
   if exists (dView) is true then
      set the git_SettingsModel of dView to empty
   end if
end git_ClearMenuModel


--> GIT | Menu | Model
-
command git_InitMenuModel dView, projectName
   git_InitGlobalModel projectName, dView
   set the git_InitSettingsModel of dView to projectName
end git_InitMenuModel

command git_InitGlobalModel projectName
   put github_ListOrgRepos() into LocalArray ["lcwRepoNames"]
   put github_LivecodeWorldProjectExists (projectName) into LocalArray ["gitHubRepoExists"]
end git_InitGlobalModel

setprop git_InitSettingsModel projectName
   put the display_View of the target into dView
   if exists (dView) is false then return empty
   --
   put git_ConstructMenuModel (projectName, dView, pOrgName) into cArray
   set the git_SettingsModel of dView to cArray
   return cArray
end git_InitSettingsModel

function git_ConstructMenuModel projectName, dView, pOrgName
   if exists (stack projectName) is false then return empty
   -- put env_ConstructProjectFolder (projectName) into projectFolder 
   
   # Default Org
   if pOrgName is empty then put "LivecodeWorld" into pOrgName
   put pOrgName into cArray ["orgName"]
   
   # Assumes project projectName is open
   put the project_Folder of stack projectName into gitFolder
   put the git_Folder of stack projectName into gitFolder
   -- put the displayed_GitCheckoutFolder of dView into gitFolder
   
   # Basics
   put dView into cArray ["dView"]
   put projectName into cArray ["projectName"]
   put gitFolder into cArray ["gitFolder"]
   
   # Essentials
   put git_LocalIgnoreFile (projectFolder) into ignoreFile
   put git_GetRemoteAddress (gitFolder) into cArray ["gitRemoteAddress"]
   put ignoreFile into cArray ["ignoreFile"]
   put there is a file ignoreFile into cArray ["localIgnoreExists"]
   
   # Checked and not needed
   -- put git_GetStatusArray (gitFolder) into cArray ["statusArray"]
   -- put the displayed_ScriptObject of dView into cArray ["scriptObject"]
   -- put git_GetActiveStatus (gitFolder) into cArray ["gitIsActive"]
   -- put _RemoteIsBad() into cArray ["_RemoteIsBad"]
   
   return cArray
end git_ConstructMenuModel


--> Private
-
