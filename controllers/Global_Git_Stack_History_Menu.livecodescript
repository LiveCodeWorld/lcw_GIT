script "Global | Git | Stack | History | Menu"
--> MetaData
-
license: GPLv3
name: Global_Git_Stack_History_Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into dView
   put the displayed_Object of dView into scriptObject
   breakpoint
   return dView
end menu_Target

getprop menu_CheckTarget [scriptObject]
   if exists (scriptObject) is false then return false
   put the stack_Object of scriptObject into stackObject
   put the filename of stackObject into someFile
   return there is a file someFile
end menu_CheckTarget


--> Global | Git | Stack | History | Menu
-
on menu_StackHistory scriptObject
   display_StackHistory scriptObject
end menu_StackHistory

on menu_DisplayGitStatus
   display_GitStatus
end menu_DisplayGitStatus

on _
end _

on menu_SetLineMenu scriptObject
   put menu_GetTopTargetObject() into tObject
   put the index_View of tObject into indexView
   set the line_Menu of indexView to "Global | Git | Line | Stack | Log | Menu"
   --  edit the script of the behavior of indexView
end menu_SetLineMenu
