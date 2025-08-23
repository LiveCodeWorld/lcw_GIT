script "Global | Git | Pull | Menu"
--> MetaData
-
license: GPLv3
name: Global | Git | Pull | Menu
type: controller
version: 0.1


--> Menu | Prpps
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

function git_ParsePullResult pullResult
   -- beware deletions and insertiosn and non-binary things
   put line 1 to 4 of pullResult into pullHeader
   delete line 1 to 4 of pullResult
   put line -1 of pullResult into pullFooter
   delete line -1 of pullResult
   put word 1 of item 1 of pullFooter into changedFileNum
   put word 1 of item 2 of pullFooter into insertionNum
   put word 1 of item 1 of pullFooter into deletionNum
   
   put git_GetRootFolder() into rootFolder
   repeat for each line someLine in pullResult
      -- |  Bin 208584 -> 207138 bytes
      put word - 6 to -1 of someLine into binBit
      put word 1 to -7 of someLine into relativePath
      put rootFolder & relativePath & CR after changedFiles
   end repeat
   delete char -1 of changedFiles
   return changedFiles
end git_ParsePullResult


--> Global | Git | Pull | Menu
-
on menu_RevealProjectFolder gitFolder
   finder_Reveal gitFolder
end menu_RevealProjectFolder

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on _ParsePullResult mTarget
   put the view_Text of mTarget into pullResult
   put git_ParsePullResult (pullResult) into changedFiles
   display_Lines changedFiles, "git pull result"
   put the result into indexView
   set the title_Menu of indexView to "Global | Git | Pull | Menu"
   set the line_Menu of indexView to "Global | Git | Pull | Line | Menu"
end _ParsePullResult
