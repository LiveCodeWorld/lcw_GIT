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
command git_ClearMenuModel
   delete variable LocalArray
end git_ClearMenuModel

command git_InitMenuModel displayView, projectName
   put the displayed_GitCheckoutFolder of displayView into gitFolder
   if there is not a folder gitFolder then
      put the git_Folder of stack projectName into gitFolder
   end if
   put the displayed_ScriptObject of displayView into scriptObject
   --
   put env_ConstructProjectFolder (projectName) into projectFolder    
   put git_LocalIgnoreFile (projectFolder) into ignoreFile
   --
   put displayView into LocalArray ["displayView"]
   put projectName into LocalArray ["projectName"]
   put scriptObject into LocalArray ["scriptObject"]
   put gitFolder into LocalArray ["gitFolder"]
   --
   put ignoreFile into LocalArray ["ignoreFile"]
   put there is a file ignoreFile into LocalArray ["localIgnoreExists"]
   --
   put git_GetActiveStatus (gitFolder) into LocalArray ["gitIsActive"]
   put git_GetRemoteAddress (gitFolder) into LocalArray ["gitRemoteAddress"]
   --
   put "LivecodeWorld" into LocalArray ["orgName"]
   put github_ListOrgRepos() into LocalArray ["lcwRepoNames"]
   put github_LivecodeWorldProjectExists (projectName) into LocalArray ["gitHubRepoExists"]
   
   put _RemoteIsBad() into LocalArray ["_RemoteIsBad"]
   put _GetStatusArray() into LocalArray ["statusArray"]
end git_InitMenuModel

private function _GetStatusArray
   put LocalArray ["gitFolder"] into gitFolder
   put git_GetStatusArray (gitFolder) into statusArray
   return statusArray
end _GetStatusArray

private function _RemoteIsBad
   put LocalArray ["gitFolder"] into gitFolder
   put LocalArray ["gitRemoteAddress"] into remoteAddress
   --
   switch
      case there is not a folder gitFolder
         return true
      case remoteAddress begins with "git@github.com:LiveCodeWorld/"
         return false
      default
         -- remote address is not a LiveCodeWorld project
         -- disabling for safety (this is not a generic git tool)
         return true
   end switch
end _RemoteIsBad

function git_LocalArray someKey
   return LocalArray [someKey]
end git_LocalArray
