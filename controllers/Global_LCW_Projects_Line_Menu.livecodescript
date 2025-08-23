script "Global | LCW | Projects | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | LCW | Projects | Line | Menu
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
   pass menu_Target
end menu_Target

getprop menu_CheckTarget [displayView]
  return true
end menu_CheckTarget

on mDoubleUp_LcwProjects treeField, projectName
   if the optionKey is down then breakpoint
   --
   if exists (stack projectName) then
      put the name of stack projectName into sObject
      --
      display_GitStatus sObject
   else
      put env_ConstructProjectFolder (projectName) into gitCheckoutFolder
      display_GitFolderStatus gitCheckoutFolder
   end if
end mDoubleUp_LcwProjects


--> Global | LCW | Projects | Line | Menu
-
on menu_DisplayRepoData dView
   put the selectd_Line of dView into projectName
   --
   display_GithubRepo projectName
end menu_DisplayRepoData

on _
end _

on submenu_Dev
   return menu_DevTitle ("Global | LCW | Projects | Line | Menu")
end submenu_Dev
