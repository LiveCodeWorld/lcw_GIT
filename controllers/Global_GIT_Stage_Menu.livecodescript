script "Global | GIT | Stage | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Stage | Menu
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
   put the footer_View of tObject into footerView
   return footerView
end menu_Target

getprop menu_CheckTarget [footerView]
   return exists (footerView)
end menu_CheckTarget

function _GitFolder footerView
   put _SettingsModel (footerView) into sModel
   return sModel ["gitFolder"]
end _GitFolder

private function _SettingsModel footerView
   put the data_View of footerView into dView
   put the git_SettingsModel of dView into sModel
   return sModel
end _SettingsModel

command _Refresh footerView, gitFolder
   display_GitFolderStatus gitFolder, footerView
end _Refresh

getprop disabled_StageForCommit [footerView]
   get _TopItem (footerView)
   if it = "Changes not staged for commit:" then
      return false
   else
      return "delete"
   end if
end disabled_StageForCommit

getprop disabled_CommitChanges [footerView]
   get _TopItem (footerView)
   if it = "Changes to be committed:" then
      return false
   else
      return true
   end if
end disabled_CommitChanges

private function _TopItem footerView
   put _SettingsModel (footerView) into sModel
   return sModel ["topKey"]
end _TopItem

getprop menu_ItemArray
   put "cog" into mItemArray ["menu_CommitChanges"]
   put "cog" into mItemArray ["menu_StageForCommit"]
   return mItemArray
end menu_ItemArray


--> Global | GIT | Stage | Menu
-
on menu_StageForCommit footerView
   put _GitFolder (footerView) into gitFolder
   --
   git_StageForCommit gitFolder
   --
   _Refresh footerView, gitFolder
end menu_StageForCommit

on menu_CommitChanges footerView
   put _GitFolder (footerView) into gitFolder
   --
   put lcw_Ask ("Comment on this change...") into sComment
   git_Commit sComment, gitFolder
   --
   _Refresh footerView, gitFolder
end menu_CommitChanges
