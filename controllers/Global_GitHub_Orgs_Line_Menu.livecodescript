script "Global | GitHub | Orgs | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | GitHub | Orgs | Line | Menu
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
   put the display_View of tObject into displayView
   --
   return displayView
end menu_Target


--> Global | GitHub | Orgs | Line | Menu
-
on menu_DisplayOrgData displayView
   put the displayed_OrgsData of displayView into orgsData
   put the selected_Line of displayView into orgName
   --
   display_GitHubProjectInfo orgName, orgsData
end menu_DisplayOrgData

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on _Experiment displayView
   put displayView
end _Experiment
