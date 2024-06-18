script "Global | Github | Update | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Github | Update | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- put display_MenuTarget (tObject) into dView
   put the display_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Github | Update | Menu
-
on menu_AutoCommit dView
   env_CommitAndPushEverything dView
end menu_AutoCommit

private on _
end _

on menu_RecentExports mTarget
   put 60 * 60 into howLong
   display_RecentExports howLong
end menu_RecentExports

on menu_SaveEditedStacks
   stack_SaveEdited "all"
end menu_SaveEditedStacks

private on __
end __

on menu_DisplayEnvironment
   display_Environment
end menu_DisplayEnvironment

on submenu_Dev
   return menu_DevTitle ("Global | Github | Update | Menu")
end submenu_Dev
