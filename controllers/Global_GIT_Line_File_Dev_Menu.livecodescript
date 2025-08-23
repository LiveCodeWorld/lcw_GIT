script "Global | GIT | Line | File | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Line | File | Dev | Menu
type: controller
author: David Bovill
version: 0.2

/*

*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target


--> Global | GIT | Line | File | Dev | Menu
-
on menu_RecentGitFile displayView
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_RecentGitFile

private on _
end _

on menu_Revert displayView
   menu_Edit "Global | GIT | Line | File | Dev | Menu"
end menu_Revert

