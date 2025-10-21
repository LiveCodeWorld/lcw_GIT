script "Global | GIT | Line | File | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Line | File | Menu
type: controller
version: 0.2


--> Variables
-
local LocalArray


--> Events
-
on mDoubleUp_DisplayGitFile treeView, shortFile
   doubleClick_Tree treeView, shortFile
end mDoubleUp_DisplayGitFile

on footer_HiliteChange footerView, iName, iNum
   if the optionKey is "down" then breakpoint
end footer_HiliteChange

on doubleClick_Tree treeView, shortFileOrFolder
   -- was "mDoubleUp_DisplayGitFile"
   if the optionkey is "Down" then breakpoint
   
   put the selected_Path of treeView into sPath
   --
   put the data_View of treeView into dView
   put the git_SettingsModel of dView into cArray
   --
   put cArray ["gitFolder"] into gitFolder
   --
   put "(use 'git push' to publish your local commits)" into pushLine
   replace "'" with quote in pushLine
   --
   text_AddTrailing gitFolder, slash
   put gitFolder & shortFileOrFolder into fileOrFolder
   get item 1 of sPath
   
   breakpoint
   switch
      case it = "Changes not staged for commit:"
         if the shiftKey is "Down" then
            git_StageCommitTracked gitFolder
            --
            set the expanded_Paths [true] of treeView to "Branch"
         end if
         break
      case it = "Changes to be committed:"
         if the shiftKey is "Down" then
            git_StageCommitTracked gitFolder
         end if
         break
      case it = "Untracked files:"
         if the shiftKey is "Down" then
            set the cursor to watch
            git_AddEverything gitFolder
            put the result into shellResult
            if shellResult is not empty then
               lcw_Notify shellResult
            end if
            
            put git_FetchStatusArray (gitFolder) into statusArray
            --
            lock screen
            set the displayed_Data of displayView to statusArray
            
            get "Changes not staged for commit:,Changes to be committed:" 
            -- display_GitFolderStatus gitFolder, it
            set the expanded_Paths [true] of treeView to it
            unlock screen
         end if
         break
      case shortFileOrFolder = pushLine
         display_GitPushCurrentBranch gitFolder
         --
         put the title_Text of treeView into projectName
         put display_FindView ("Environment", "Not Up-to-Date") into dView
         if exists (dView) then
            set the deleted_Line of dView to projectName
         end if
         break
      case there is a stack fileOrFolder
         if the scriptonly of stack fileOrFolder is true then
            edit the script of stack fileOrFolder
         else
            go to stack fileOrFolder
         end if
         break
      case there is a folder fileOrFolder
         finder_Reveal fileOrFolder
         break
      case there is a file fileOrFolder
         atom_DisplayFile fileOrFolder 
         break
   end switch
end doubleClick_Tree


--> Menu | Props
-
getprop menu_IconArray [sView]
   local fData
   put the name of me into mController
   put the tree_Data of sView into tData
   put the keys of tData into tKeys
   --
   if tKeys contains "Untracked" then
      iconData_Add fData, "menu_AddAllUntracked", mController, "Phosphor/file plus"
   end if
   --
   if tKeys is not "Branch" then
      iconData_Add fData, "menu_StageThenCommit", mController, "tabler/file check", "Stage"
   end if
   --
   if tKeys = "Branch" then
      put the name of stack "Global | Git | Basics | Menu" into  mController
      iconData_Add fData, "menu_PushCurrentBranch", mController, "goal 24", "Push"
   end if
   --
   iconData_Add fData, "menu_RefreshGitStatus", mController, "Phosphor/list checks", "Status"
   iconData_Add fData, "menu_ShowXterm", mController, "Fontawesome/code", "Xterm"
   --
   return fData
end menu_IconArray

getprop menu_Target [tObject]
   put the data_View of tObject into dView
   if exists (dView) is false then return empty
   put the tree_View of dView into treeView
   put _GitSettingsModel (tObject) into LocalArray
   -- 
   get the selected_Path of tObject
   put item 1 of it into LocalArray ["topKey"]
   put item -1 of it into LocalArray ["sLeaf"]
   --
   return treeView
end menu_Target

getprop disabled_Branch [treeView]
   if LocalArray ["topKey"] = "Branch" then
      return false
   else
      return "delete"
   end if
end disabled_Branch

getprop disabled_StageThenCommit [treeView]
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

getprop disabled_StackHistory [dView]
   put LocalArray ["sLeaf"] into sLeaf
   --
   set the itemdelimiter to "."
   switch item -1 of sLeaf
      case "livecode"
      case "livecodescript"
         return false
      default
         return true
   end switch 
end disabled_StackHistory

getprop disabled_AddUntrackedFile [treeView]
   put the selected_Path of treeView into pathItems
   put LocalArray ["topKey"] into topKey
   put the number of items of pathItems into pathNum
   if topKey is among the items of "Untracked files:" and pathNum > 2 then
      return false
   else
      return "delete"
   end if
end disabled_AddUntrackedFile

getprop disabled_AddAllUntracked [treeView]
   put the selected_Path of treeView into pathItems
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

getprop disabled_GoToStack [treeView]
   put _getFile (treeView) into someFile
   if exists (stack someFile) is true then
      return false
   else
      return "delete"
   end if
end disabled_GoToStack

getprop disabled_EditFile [treeView]
   put _getFile (treeView) into someFile
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

private function _GitSettingsModel sView
   put the data_View of sView into dView
   --
   put the git_SettingsModel of dView into LocalArray
   return LocalArray
end _GitSettingsModel

private function _GetFile sView
   -- Untracked files:,files,controllers/Global_GIT_Menu.livecodescript,
   put the tree_View of sView into treeView
   put the selected_Path of treeView into pathItems
   get item 3 to -1 of pathItems
   put word 1 of it into relativePath
   
   
   put _GitFolder (sView)into gitFolder  
   
   put gitFolder & relativePath into someFile
   return someFile
end _GetFile

private function _GitFolder sView
   put _GitSettingsModel (sView) into LocalArray
   return LocalArray ["gitFolder"]
end _GitFolder

private command _Refresh sView
   put the tree_View of sView into treeView
   --
   put _GitFolder (sView) into gitFolder
   put git_FetchStatusArray (gitFolder) into statusArray
   -- set the displayed_Data of treeView to statusArray
   set the displayed_Array ["Branch"] of treeView to statusArray
   --
   _RefreshFooter sView
end _Refresh

private command _RefreshFooter sView
   put the footer_View of sView into footerView
   --
   dispatch "Refresh" to footerView
end _RefreshFooter


--> Global | GIT | Line | File | Menu
-
on menu_ShowXterm mTarget
   set the dataView_Terminal of mTarget to empty
end menu_ShowXterm

on menu_RefreshGitStatus sView
   stack_SaveEdited "all"
   _Refresh sView
end menu_RefreshGitStatus

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

private command _
end _

on menu_StageThenCommit sView
   put "Minor changes" into sComment
   put lcw_Ask ("Comment on this change...", sComment, sView) into sComment
   
   # Commit
   put _GitFolder (sView) into gitFolder
   git_StageCommitTracked gitFolder, sComment
   put the result into sResult
   
   if the shiftkey is "Down" then
      display_Lines sResult, "git_Commit"
   end if
   --
   _Refresh sView
end menu_StageThenCommit

private command __
end __

on menu_AddUntrackedFile sView
   put _GetFile (sView) into someFile
   --
   git_AddFile someFile 
   -- 
   _Refresh sView
end menu_AddUntrackedFile

private function _GitFolder sView
   put LocalArray ["gitFolder"] into gitFolder
   
end _GitFolder

on menu_AddAllUntracked sView
   put _GitFolder (sView) into gitFolder
   set the cursor to watch
   
   git_AddEverything gitFolder  
   put the result into shellResult
   
   if shellResult is not empty then
      lcw_Notify shellResult
   end if
   _Refresh sView
end menu_AddAllUntracked

private command ___
end ___

on menu_SaveAndRefresh sView
   stack_SaveEdited "all"
   --
   _Refresh sView
end menu_SaveAndRefresh

on menu_GoToStack treeView
   put _getFile (treeView) into someFile
   go to stack someFile
end menu_GoToStack

on menu_EditFile treeView
   put _getFile (treeView) into someFile
   atom_DisplayFile someFile
end menu_EditFile

on menu_DeleteFile sView
   put _GetFile (sView) into someFile
   if there is a file someFile then
      set the itemdelimiter to slash
      put item -1 of someFile into shortFile
      --
      lcw_Answer "Delete file [[shortFile]]", sView, shortFile
      --
      revDeleteFile someFile
      --
      _Refresh sView
   else
      breakpoint
      finder_RevealFileOrFolder someFile
   end if
end menu_DeleteFile

private command ____
end ____

on submenu_Stage
   return "Global | GIT | Stage | Menu"
end submenu_Stage

on submenu_Branch
   return "Global | GIT | Branch | Menu"
end submenu_Branch

on submenu_Dev
   return "Global | GIT | Line | File | Dev | Menu"
end submenu_Dev

