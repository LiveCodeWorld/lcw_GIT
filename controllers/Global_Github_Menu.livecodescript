script "Global | Github | Menu"
--> MetaData
-
license: GPLv3
name: Global | Github | Menu
type: controller
version: 0.1


--> Menu | Init
-
/* mTarget should already be set by set the menu_Target of displayView to projectName */

local LocalArray


--> Global | Github | Menu
-
on menu_LaunchGithub
   github_Launch
end menu_LaunchGithub

on _
end _

on subMenu_Dev
   return "Dev | Menu"
end subMenu_Dev


--> Dev | Menu
-
on menu_ColourMe displayView
   put env_ListLocalProjects() into localProjects
   put github_ListMissingLocalRepos() into missingRepoNames
   --
   lock screen
   set the coloured_Lines ["dark green"] of displayView to localProjects
   set the coloured_Lines ["orange"] of displayView to missingRepoNames
   unlock screen
end menu_ColourMe

on menu_DisplayGithubOrgArray
   put github_FetchOrgRepoAray() into reposArray
   --
   display_Array reposArray, "github_FetchOrgRepoAray()"
end menu_DisplayGithubOrgArray
