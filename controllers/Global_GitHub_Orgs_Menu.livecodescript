script "Global | GitHub | Orgs | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | GitHub | Orgs | Menu
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
   return displayView
end menu_Target


--> Global | GitHub | Orgs | Menu
-
on menu_DisplayOrgsData displayView
   put the displayed_OrgsData of displayView into orgsData
   --
   display_Data orgsData, "Orgs Data", "Github"
end menu_DisplayOrgsData

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
