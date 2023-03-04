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


--> Global | GIT | Status | Menu
-
on submenu_Init
   return "Global | GIT | Init | Menu"
end submenu_Init

on _
end _

on insert_GitBasics
   return "Global | GIT | Basics | Menu"
end insert_GitBasics

on _
end _

on menu_RefreshDisplay displayView
   put the title_Text of displayView into projectName
   --
   display_GitRefreshProjectName projectName
end menu_RefreshDisplay

on submenu_Dev
   return menu_Create ("Global | GIT | Dev | Menu")
end submenu_Dev
