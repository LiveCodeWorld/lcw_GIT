script "Global | GitHub | Orgs | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | GitHub | Orgs | Menu
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
   return displayView
end menu_Target


--> Global | GitHub | Orgs | Menu
-
on menu_LivecodeWorldRepos
   display_GithubOrgRepos
end menu_LivecodeWorldRepos

on menu_MyGithubOrgs
   display_GithubOrgs
end menu_MyGithubOrgs

on _
end _

-- on menu_GithubProjects
   display_GithubProjects
end menu_GithubProjects

on menu_DisplayOrgData dView
   put the view_Data of dView into indexArray
   put the displayed_Array of dView into nameArray
   --
   display_Data indexArray, "indexArray", "Github Orgs"
   display_Data nameArray, "nameArray", "Github Orgs"
end menu_DisplayOrgData

on menu_Refresh
   display_GithubOrgs
end menu_Refresh

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on _Experiment displayView
   put displayView
end _Experiment
