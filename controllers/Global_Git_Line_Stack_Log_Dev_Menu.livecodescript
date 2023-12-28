script "Global | Git | Line | Stack | Log | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Git | Line | Stack | Log | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this developer menu.
Full help text should be provided on the linked wiki.

Consider improving by creating with same menu_Target as no-developer menu is is based on.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget

private function _LocalValue someKey
   return LocalArray [someKey]
end _LocalValue

private function _indexView
   return LocalArray ["indexView"]
end _indexView

getprop stack_Hashs [mTarget]
   put the filename of mTarget into sFile -- was "the stack_RelativeFile"
   return git_ReverseFileHashes (sFile)
end stack_Hashs

getprop back_Hashs [mTarget]
   put the filename of mTarget into sFile -- was "the stack_RelativeFile"
   return git_ReverseFileHashes (sFile)
end back_Hashs

getprop back_Nums
   return "0,-,1,2,3,4,5,6,7,8,9"
end back_Nums


--> Global | Git | Line | Stack | Log | Dev | Menu
-
on menu_DisplayCommitInfo stackObject
   put _getSelectedCommitHash() into commitHash
   put LocalArray ["gitCheckoutFolder"] into gitCheckoutFolder
   
   put git_HashInfo (commitHash, gitCheckoutFolder) into hashInfo   
   put "git show" && kwote (commitHash) into someShell
   display_Text hashInfo, someShell
end menu_DisplayCommitInfo

on menu_StackData stackObject
   put _getSelectedCommitHash() into commitHash
   
   put git_GetStackData (stackObject, commitHash) into stackData
   
   put the git_StackTreeish [commitHash] of stackObject into treeish
   put "git show" && kwote (treeish) into someShell
   put someShell & comma & "git_GetStackData ()" into someTitle
   display_Text stackData, someTitle
end menu_StackData

on menu_ListCommitInfo stackObject
   put _getSelectedCommitHash() into commitHash
   put LocalArray ["gitCheckoutFolder"] into gitCheckoutFolder
   
   put git_List (commitHash, gitCheckoutFolder) into logText
   
   put "git ls-tree" && commitHash into someShell
   display_Index logText, someShell
end menu_ListCommitInfo

on menu_StackHashLog stackObject
   -- a log of all the previous commits of a version specified by commitHash
   put _getSelectedCommitHash() into commitHash
   
   put the git_StackHashLog [commitHash] of stackObject into logText
   
   put "the git_StackHashLog [" & commitHash & "] of" && stackObject into someTitle
   display_Index logText, someTitle
end menu_StackHashLog

on _
end _

on menu_DiffStackBinaries stackObject
   -- put the tree_SelectedLink of treeField into commitHash
   -- put the displayed_Object of treeField into stackObject
   put _getSelectedCommitHash() into commitHash
   
   breakpoint
   
   put the effective filename of stackObject into stackPath   
   git_ExportFileRevision stackPath, commitHash
   put the result into toFile
   
   diff_Files thisFile, toFile
end menu_DiffStackBinaries
