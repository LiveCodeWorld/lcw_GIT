script "Global | GitHub | Orgs | Line | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | GitHub | Orgs | Line | Menu
type: controller
version: 0.2

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

on mDoubleUp_GithubOrgs dView, orgName
   -- put the selected_Line of dView into orgName
   put the displayed_Array of dView into nameArray
   put nameArray [orgName] into orgData
   --
   -- display_GitHubProjectInfo orgName, orgData
   display_GithubOrgRepos orgName
end mDoubleUp_GithubOrgs


--> Global | GitHub | Orgs | Line | Menu
-
on menu_DisplayOrgData dView
   put the displayed_Array of dView into nameArray
   put the selected_Line of dView into orgName
   put nameArray [orgName] into orgData
   --
   display_GitHubProjectInfo orgName, orgData
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

