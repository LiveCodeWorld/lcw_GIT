script "Global | GIT | Status | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | GIT | Status | Menu
type: controllers
version: 0.3


--> Menu | Props
-
local LocalArray

on menu_Init tObject   
   put the display_View of tObject into displayView
   put the title_Text of displayView into projectName
   --
   git_InitMenuModel displayView, projectName
end menu_Init


--> Global | GIT | Status | Menu
-
on submenu_Init
   return "Global | GIT | Init | Menu"
end submenu_Init

on submenu_Settings
   return "Global | GIT | Settings | Menu"
end submenu_Settings

on _
end _

on insert_GitBasics
   return "Global | GIT | Basics | Menu"
end insert_GitBasics

on _
end _

on menu_RefreshDisplay
   put git_LocalArray (projectName) into projectName
   --
   display_GitRefreshProjectName projectName
end menu_RefreshDisplay

on submenu_Dev
   return menu_Create ("Global | GIT | Dev | Menu")
end submenu_Dev
