script "Global | GIT | Status | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | GIT | Status | Menu
type: controllers
version: 0.3


--> Menu | Props
-
local LocalArray

getprop menu_Target [tObject]
   put the data_View of tObject into dView
   put the git_SettingsModel of dView into sModel
   put sModel into LocalArray ["sModel"]
   return dView
end menu_Target

private function _GitFolder dView
   put LocalArray ["sModel"]["gitFolder"] into gitFolder
   return gitFolder
end _GitFolder

private command _Refresh dView
   put the title_Text of dView into projectName
   display_GitRefreshProjectName projectName
end _Refresh

getprop disabled_RemoveLockFiles dView
   put _GitFolder (dView) into gitFolder
   if git_LockFileExists (gitFolder) then
      return false
   else
      return true
   end if
end disabled_RemoveLockFiles


--> Global | GIT | Status | Menu
-
on menu_RemoveLockFiles dView
   put _GitFolder (dView) into gitFolder
   --
   git_ClearLocks gitFolder
end menu_RemoveLockFiles

on menu_UpdateViewOfRemote dView
   -- Update your local view of the remote
   put _GitFolder (dView) into gitFolder
   --
   get git_UpdateViewOfRemote (gitFolder)
   put it & CR&CR & git_ShortBranchStatus (gitFolder)
   --
   _Refresh dView
end menu_UpdateViewOfRemote

on menu_ForceLocal dView
   -- Update your local view of the remote
   put _GitFolder (dView) into gitFolder
   --
   put "push --force-with-lease origin $(git rev-parse --abbrev-ref HEAD)" into gitBit
   put git_ExecuteBit (gitBit, gitFolder)
   _Refresh dView
end menu_ForceLocal

on menu_SwitchToMaster dView
   put _GitFolder (dView) into gitFolder
   --
   git_CheckoutMaster gitFolder
   put the result
   _Refresh dView
end menu_SwitchToMaster

on menu_CheckLockFiles dView
   put _GitFolder (dView) into gitFolder
   --
   if git_ActiveProcess() then
      lcw_AnswerWarning "Active git command in progress..", dView
   end if
   if git_OpInProgress (gitFolder) is true then
      lcw_AnswerWarning "Op in progress..", dView
   end if
   if git_LockFileExists (gitFolder) then
      lcw_Answer "Lockfile exists!"
   else
      lcw_Answer "All Clear!"
   end if
end menu_CheckLockFiles

on submenu_Init
   return "Global | GIT | Init | Menu"
end submenu_Init

on _
end _

on insert_GitBasics
   return "Global | GIT | Basics | Menu"
end insert_GitBasics

on __
end __

on menu_RefreshDisplay dView
   _Refresh dView
end menu_RefreshDisplay

on menu_OpenInTerminal dView
   put _GitFolder (dView) into gitFolder
   --
   put "cd" && kwote (gitFolder, "'") &CR& "git status" into someShell
   terminal_DoShell someShell, true
end menu_OpenInTerminal

on ___
end ___

on submenu_Dev
   return "Global | GIT | Status | Dev | Menu"
end submenu_Dev

