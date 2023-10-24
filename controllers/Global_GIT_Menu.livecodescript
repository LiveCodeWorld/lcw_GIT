script "Global | GIT | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Menu
type: controller
version: 0.2

/*As the general git menu, this probably should not have a scriptObject as the menu_Target
becasue it will be displayed by the standard project menu interface.
Change to indexView or make it clever.*/


--> Menu | Init
-
local LocalArray

on menu_Init
   put scriptEditor_Object() into sObject
   put sObject into LocalArray ["sObject"]
end menu_Init

getprop menu_Target [tObject]
   -- not called on submenus :(
   put LocalArray ["sObject"] into sObject
   return sObject
end menu_Target

getprop disabled_Dev
   -- utility that displays "Dev | Menu" only when the optionKey is down
   if the optionKey is "Down" then
      return false
   else
      return "delete"
   end if
end disabled_Dev

getprop disabled_GitStatus [scriptObject]
   if env_ProjectIsActive ("lcw_GIT") is true then
      return false
   else
      return "delete"
   end if 
end disabled_GitStatus

getprop disabled_LoadGit
   if env_ProjectIsActive ("lcw_GIT") is true then
      return "delete"
   else
      return false
   end if 
end disabled_LoadGit


--> Global | GIT | Menu
-
on menu_DisplayGitStatus scriptObject
   put LocalArray ["sObject"] into scriptObject
   --
   display_GitStatus scriptObject
end menu_DisplayGitStatus

on menu_DisplayGistScripts
   display_Gists "Gist Scripts"
end menu_DisplayGistScripts

on _
end _

on submenu_Dev
   return menu_DevTitle ("Global | GIT | Menu")
end submenu_Dev
