script "Global | GIT | Untracked files | Files | Menu"
--> MetaData
-
license: GPLv3
name: Global_GIT_Untracked Files_Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   _InitLocalArray tObject
   return LocalArray ["gitFolder"]
end menu_Target


--> Private
-
private command _InitLocalArray tObject
   put the display_View of tObject into dView
   put the git_SettingsModel of dView into LocalArray
   return dView
end _InitLocalArray

private function _LocalValue someKey
   return LocalArray [someKey]
end _LocalValue


--> Private
-
private command refreshGitStatus
   put LocalArray ["displayView"] into displayView
   put LocalArray ["gitFolder"] into gitFolder
   display_GitFolderStatus gitFolder, displayView
end refreshGitStatus


--> Global | GIT | Untracked files | Files | Menu
-
on menu_AddAllUntracked gitFolder
   git_AddEverything gitFolder
   put the result into shellResult
   
   if shellResult is not empty then
      lcw_Notify shellResult
   end if
   refreshGitStatus
end menu_AddAllUntracked
