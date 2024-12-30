script "Global | GIT | Status | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Status | Dev | Menu
type: controller
author: David Bovill
version: 0.2

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   _InitLocalArray tObject
   put the displayed_Object of tObject into sObject
   return sObject
end menu_Target

private command _InitLocalArray tObject
   put the git_SettingsModel of tObject into LocalArray
   return dView
end _InitLocalArray

private function _LocalValue someKey
   return LocalArray [someKey]
end _LocalValue

getprop some_Names
   return stack_ListNames()
end some_Names

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

getprop back_Nums
   return "1,2,3,4,5,6"
end back_Nums


--> Global | GIT | Status | Dev | Menu
-
on menu_TestGitStatus dView
   put the git_SettingsModel of dView into sModel
   put sModel ["gitFolder"] into gitFolder
   --
   put git_IsUpToDate (gitFolder)
end menu_TestGitStatus

on menu_ShowStackLog scriptObject
   display_StackHistory scriptObject
end menu_ShowStackLog

on menu_StackHistory scriptObject
   display_StackHistory scriptObject
end menu_StackHistory

on _
end _

on menu_SearchCommitHistory
   local pTreeMenuTitle, pTreeLineMenuTitle
   
   put the search_Term of me into searchTerm
   put lcw_Ask("Search log for string...", searchTerm) into searchTerm
   set the search_Term of me to searchTerm
   
   put git_SearchLog (searchTerm) into foundLog
   put git_LogLinkOutline (foundLog) into someOutline
   
   put "git log --pretty=oneline -S:" && kwote(searchTerm) into someTitle
   display_Outline someOutline, someTitle, pTreeMenuTitle, pTreeLineMenuTitle
   put the result into treeView
   put the tree_Field of treeView into treeField
   set the menu_Controller ["Log | Menu"] of treeField to the long id of me
end menu_SearchCommitHistory

on menu_SearchRepository
   local pTreeMenuTitle, pTreeLineMenuTitle
   
   put the search_Term of me into searchTerm
   put lcw_Ask("Search log for string...", searchTerm) into searchTerm
   set the search_Term of me to searchTerm
   
   put git_SearchRepository (searchTerm) into foundLog
   display_Lines foundLog
   put git_LogLinkOutline (foundLog) into someOutline
   put "git grep --text -i" && kwote(searchTerm) into someTitle
   display_Outline someOutline, someTitle, pTreeMenuTitle, pTreeLineMenuTitle
   put the result into treeView
   put the tree_Field of treeView into treeField
   set the menu_Controller ["Grep | Menu"] of treeField to the long id of me
end menu_SearchRepository

getprop search_Term
   return the uOPN ["search_Term"] of me
end search_Term

setprop search_Term searchTerm
   set the uOPN ["search_Term"] of me to searchTerm
end search_Term

on menu_OtherStackLog scriptObject, someName
   put the name of stack someName into stackObject
   display_StackHistory stackObject
end menu_OtherStackLog
