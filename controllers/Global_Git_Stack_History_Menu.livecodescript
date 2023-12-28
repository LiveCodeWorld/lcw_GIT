script "Global | Git | Stack | History | Menu"
--> MetaData
-
license: GPLv3
name: Global | Git | Stack | History | Menu
type: controller
version: 0.2


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into dView
   put the displayed_Object of dView into scriptObject
   return scriptObject
end menu_Target


--> Global | Git | Stack | History | Menu
-
on menu_StackHistory scriptObject
   display_StackHistory scriptObject
end menu_StackHistory

on menu_FileHistory scriptObject
   put the effective filename of scriptObject into someFile
   put the stack_File of scriptObject into someFile
   display_GitFileHistory someFile
end menu_FileHistory

private on _
end _

on menu_DisplayGitStatus
   display_GitStatus
end menu_DisplayGitStatus
