﻿script "Global | GIT | Line | File | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Line | File | Menu
type: controller
version: 0.2


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into dView
   put the git_SettingsModel of dView into LocalArray
   
   get the hilited_Element of tObject
   put item 1 of it into LocalArray ["topKey"]
   
   return dView
end menu_Target

getprop disabled_Branch [arrayView]
   if LocalArray ["topKey"] = "Branch" then
      return false
   else
      return "delete"
   end if
end disabled_Branch

getprop disabled_StageThenCommit [arrayView]
   put LocalArray ["displayedArray"] into displayedArray
   put displayedArray ["Changes to be committed:"] into cArray
   put displayedArray ["Changes not staged for commit:"] into nsArray
   union cArray with nsArray
   if cArray is empty then return "delete"
   
   return false
   
   -- not sure of logic yet
   put LocalArray ["topKey"] into topKey
   if topKey = "Branch" or topKey = "Changes to be committed:" then
      return false
   else
      return "delete"
   end if
end disabled_StageThenCommit

getprop disabled_AddUntrackedFile [arrayView]
   put the hilited_Element of arrayView into pathItems
   
   put LocalArray ["topKey"] into topKey
   
   put the number of items of pathItems into pathNum
   --  if topKey is among the items of "Untracked files:" and pathNum > 2 then
   if topKey is among the items of "Untracked files:,Changes not staged for commit:" and pathNum > 2 then
      return false
   else
      return "delete"
   end if
end disabled_AddUntrackedFile

getprop disabled_AddAllUntracked [arrayView]
   put the hilited_Element of arrayView into pathItems
   put LocalArray ["topKey"] into topKey
   put LocalArray ["displayedArray"] into displayedArray
   
   put keys (displayedArray) into topKeys
   if "Untracked files:" is not among the lines of topKeys then
      return true
   end if
   
   put the number of items of pathItems into pathNum
   -- if topKey = "Untracked files:" and the number of items of pathItems < 3 then
   if topKey is among the items of "Untracked files:,Changes not staged for commit:" and pathNum <3 then
      return false
   else
      return "delete"
   end if
end disabled_AddAllUntracked

getprop disabled_StashChanges
   if LocalArray ["topKey"] = "Changes to be committed:" then
      return false
   else
      return "delete"
   end if
end disabled_StashChanges

getprop disabled_StageAllChanges
   if LocalArray ["topKey"] = "Changes not staged for commit:" then
      return false
   else
      return "delete"
   end if
end disabled_StageAllChanges

getprop disabled_GoToStack [arrayView]
   put _getFile (arrayView) into someFile
   if exists (stack someFile) is true then
      return false
   else
      return "delete"
   end if
end disabled_GoToStack

getprop disabled_EditFile [arrayView]
   put _getFile (arrayView) into someFile
   switch
      case there is a stack someFile
         if the scriptonly of stack someFile is true then
            return false
         else
            return true
         end if
      case there is a file someFile
         return false
      default
         return true
   end switch
end disabled_EditFile

private function _GetFile displayView
   -- Untracked files:,files,controllers/Global_GIT_Menu.livecodescript,
   put the hilited_Element of displayView into pathItems
   get item 3 to -1 of pathItems
   put word 1 of it into relativePath
   put LocalArray ["gitFolder"] into gitCheckoutFolder  
   -- put LocalArray ["gitCheckoutFolder"] into gitCheckoutFolder  
   put gitCheckoutFolder & relativePath into someFile
   return someFile
end _GetFile

private command _RefreshGitFolderStatus
   put LocalArray ["displayView"] into displayView
   put LocalArray ["gitFolder"] into gitFolder
   display_GitFolderStatus gitFolder, displayView
end _RefreshGitFolderStatus


--> Global | GIT | Line | File | Menu
-
on menu_StackHistory dView
   put _getFile (dView) into stackPath
   if exists (stack stackPath)  is false then
      put stackPath
      lcw_AnswerWarning "Stack does not exist!", dView
   end if
   --
   put the name of stack stackPath into scriptObject
   --
   display_StackHistory scriptObject
end menu_StackHistory

private command _1
end _1

on menu_StageThenCommit arrayView
   put lcw_Ask ("Comment on this change...") into someComment
   put LocalArray ["gitCheckoutFolder"] into gitCheckoutFolder
   
   git_CommitChanges someComment, gitCheckoutFolder
   put the result into shellResult
   
   display_Lines shellResult, "git_CommitChanges"
   _RefreshGitFolderStatus
end menu_StageThenCommit

private command _2
end _2

on menu_AddUntrackedFile displayView
   put _GetFile (displayView) into someFile
   --
   git_AddFile someFile 
   -- 
   _RefreshGitFolderStatus
end menu_AddUntrackedFile

on menu_AddAllUntracked arrayView
   put LocalArray ["gitCheckoutFolder"] into gitCheckoutFolder
   set the cursor to watch
   
   git_AddEverything gitCheckoutFolder  
   put the result into shellResult
   
   if shellResult is not empty then
      lcw_Notify shellResult
   end if
   _RefreshGitFolderStatus
end menu_AddAllUntracked

private command ___
end ___

on menu_SaveAndRefresh
   stack_SaveEdited "all"
   --
   _RefreshGitFolderStatus
end menu_SaveAndRefresh

on menu_GoToStack arrayView
   put _getFile (arrayView) into someFile
   go to stack someFile
end menu_GoToStack

on menu_EditFile arrayView
   put _getFile (arrayView) into someFile
   atom_DisplayFile someFile
end menu_EditFile

on menu_DeleteFile dView
   put _getFile (dView) into someFile
   if there is a file someFile then
      set the itemdelimiter to slash
      put item -1 of someFile into shortFile
      --
      lcw_Answer "Delete file [[shortFile]]", dView, shortFile
      --
      revDeleteFile someFile
      --
      _RefreshGitFolderStatus
   else
      breakpoint
      finder_RevealFileOrFolder someFile
   end if
end menu_DeleteFile

private command ____
end ____

on menu_StageAllChanges
   -- git_AddChanged
   put lcw_Ask ("Comment on this change...") into someComment
   --
   put LocalArray ["gitFolder"] into gitFolder  
   git_CommitChanges someComment, gitFolder
   --
   _RefreshGitFolderStatus
end menu_StageAllChanges

on submenu_Branch
   return "Global | GIT | Branch | Menu"
end submenu_Branch

private command _5
end _5

on submenu_Dev
   return menu_DevTitle ("Global | GIT | Line | File | Menu")
end submenu_Dev

