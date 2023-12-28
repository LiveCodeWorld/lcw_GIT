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
   -- put the git_SettingsModel of dView into LocalArray
   return dView
end menu_Target

private function _GetStackObject dView
   put the displayed_Object of dView into stackObject
   return stackObject
end _GetStackObject

private function _GetSelectedCommitHash dView
   put the hilited_Lines of dView into lineNum
   put the log_Array of dView into logArray
   --
   put logArray [lineNum]["commitHash"] into commitHash
   put commitHash into LocalArray ["commitHash"]
   
   return LocalArray ["commitHash"]
end _GetSelectedCommitHash


--> Global | Git | Line | Stack | Log | Menu
-
on menu_DisplayStackRevision dView
   put _GetStackObject(dView) into stackObject
   put _GetSelectedCommitHash (dView) into commitHash
   --
   display_GitStackRevision stackObject, commitHash
end menu_DisplayStackRevision

on _
end _

on menu_RevertStack stackObject
   put _GetStackObject(dView) into stackObject
   put _getSelectedCommitHash() into commitHash
   
   breakpoint
   git_RevertStack stackObject, commitHash
end menu_RevertStack

on _
end _

on submenu_Dev
   return menu_DevTitle ("Global | Git | Line | Stack | Log | Menu")
end submenu_Dev
