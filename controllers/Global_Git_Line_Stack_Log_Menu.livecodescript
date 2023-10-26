script "Global | Git | Line | Stack | Log | Menu"
--> MetaData
-
license: GPLv3
name: Global | Git | Line | Stack | Log | Menu
type: controller
author: David Bovill
version: 0.2


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into dView
   put the git_SettingsModel of dView into LocalArray
   
   put the hilited_Lines of dView into lineNum
   put the log_Array of dView into logArray
   put logArray [lineNum]["commitHash"] into commitHash
   put commitHash into LocalArray ["commitHash"]
   
   return dView
end menu_Target

private function _LocalValue someKey
   return LocalArray [someKey]
end _LocalValue

private function _getSelectedCommitHash
   return LocalArray ["commitHash"]
end _getSelectedCommitHash

private function _indexView
   return LocalArray ["indexView"]
end _indexView

getprop stack_Hashs [mTarget]
   put the filename of mTarget into sFile -- was "the stack_RelativeFile"
   return git_R (sFile, pMaxNum)everseFileHashes (sFile)
end stack_Hashs

getprop back_Hashs [mTarget]
   put the filename of mTarget into sFile -- was "the stack_RelativeFile"
   return git_ReverseFileHashes (sFile)
end back_Hashs

getprop back_Nums
   return "0,-,1,2,3,4,5,6,7,8,9"
end back_Nums


--> Global | Git | Line | Stack | Log | Menu
-
on menu_DisplayStackRevision stackObject
   put _getSelectedCommitHash() into commitHash
   
   git_DisplayTempStackRevision stackObject, commitHash
   
   -- here we should display some info about the closed stack
end menu_DisplayStackRevision

on _
end _

on menu_RevertStack stackObject
   put _getSelectedCommitHash() into commitHash
   
   breakpoint
   git_RevertStack stackObject, commitHash
end menu_RevertStack

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on _DisplayCommitInfo stackObject
   put _getSelectedCommitHash() into commitHash
   put LocalArray ["gitCheckoutFolder"] into gitCheckoutFolder
   
   put git_HashInfo (commitHash, gitCheckoutFolder) into hashInfo   
   put "git show" && kwote (commitHash) into someShell
   display_Text hashInfo, someShell
end _DisplayCommitInfo

on _StackData stackObject
   put _getSelectedCommitHash() into commitHash
   
   put git_GetStackData (stackObject, commitHash) into stackData
   
   put the git_StackTreeish [commitHash] of stackObject into treeish
   put "git show" && kwote (treeish) into someShell
   put someShell & comma & "git_GetStackData ()" into someTitle
   display_Text stackData, someTitle
end _StackData

on _ListCommitInfo stackObject
   put _getSelectedCommitHash() into commitHash
   put LocalArray ["gitCheckoutFolder"] into gitCheckoutFolder
   
   put git_List (commitHash, gitCheckoutFolder) into logText
   
   put "git ls-tree" && commitHash into someShell
   display_Index logText, someShell
end _ListCommitInfo

on _StackHashLog stackObject
   -- a log of all the previous commits of a version specified by commitHash
   put _getSelectedCommitHash() into commitHash
   
   put the git_StackHashLog [commitHash] of stackObject into logText
   
   put "the git_StackHashLog [" & commitHash & "] of" && stackObject into someTitle
   display_Index logText, someTitle
end _StackHashLog

on _
end _

on _DiffStackBinaries stackObject
   -- put the tree_SelectedLink of treeField into commitHash
   -- put the displayed_Object of treeField into stackObject
   put _getSelectedCommitHash() into commitHash
   
   breakpoint
   
   put the effective filename of stackObject into stackPath   
   git_ExportFileRevision stackPath, commitHash
   put the result into toFile
   
   diff_Files thisFile, toFile
end _DiffStackBinaries

