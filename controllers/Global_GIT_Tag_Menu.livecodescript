script "Global | GIT | Tag | Menu"
--> MetaData
-
license: GPLv3
name: Global_GIT_Tag_Menu
type: controller
version: 0.1

--> Vairables
-
local LocalArray

--> Menu | Prpps
-
getprop menu_Target [tObject]
   _InitLocalArray tObject
   return LocalArray ["gitFolder"]
end menu_Target

getprop showTaggedFiles_Params
   return LocalArray ["tagNames"]
end showTaggedFiles_Params

getprop disabled_ShowTaggedFiles [arrayView]
   put LocalArray ["tagNames"] into tagNames
   if tagNames is empty then
      return true
   else
      return false
   end if
end disabled_ShowTaggedFiles


--> Private
-
private command _InitLocalArray tObject
   put the display_View of tObject into dView
   put the git_SettingsModel of dView into LocalArray
   put git_ExecuteShellCommand ("git tag -l", gitFolder) into LocalArray ["tagNames"]
   return dView
end _InitLocalArray

private function _LocalValue someKey
   return LocalArray [someKey]
end _LocalValue


--> Global | GIT | Tag | Menu
-
on menu_AddTag gitFolder
   put lcw_Ask ("What do you want to call this tag...") into tagName
   put lcw_Ask ("Describe this tag...") into tagMessage
   
   put "git tag -a" && kwote (tagName) into someShell
   put space & "-m" && kwote (tagMessage) after someShell
   
   put git_ExecuteShellCommand (someShell, gitFolder) into shellResult
   
   if shellResult is not empty then
      beep
      lcw_Notify shellResult
   end if
end menu_AddTag

on _
end _

on menu_ShowTaggedFiles gitFolder, tagName   
   put "git show" && kwote (tagName) into someShell
   put "git ls-files" into someShell
   
   put git_ExecuteShellCommand (someShell, gitFolder) into shellResult
   display_Lines shellResult, someShell
end menu_ShowTaggedFiles
