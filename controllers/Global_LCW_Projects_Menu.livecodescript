script "Global | LCW | Projects | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | LCW | Projects | Menu
type: controller
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.

display_Data localProjects, "Local Projects", "LCW"
put the result into displayView
--
repeat for each line projectName in localProjects
   display_Spin projectName, displayView
   put the result into lineNum
   --
   if git_ProjectIsClean (projectName) is true then
      set the line_Colour [lineNum] of displayView to "green"
   else
      set the line_Colour [lineNum] of displayView to "red"
   end if
end repeat
*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into displayView
   return displayView
end menu_Target

getprop menu_CheckTarget [displayView]
   -- use to do initialisation
   put the title_Text of displayView into LocalArray ["titleText"]
   return true
end menu_CheckTarget

getprop checked_GithubProjects
   return _CheckBoolean (the params)
end checked_GithubProjects

getprop checked_NotOnGithub
   return LocalArray ["titleText"] = "Not On Github"
end checked_NotOnGithub

getprop checked_MissingLocalRepos
   return LocalArray ["titleText"] = "Missing Local Repos"
end checked_MissingLocalRepos

getprop checked_LocalProjects
   return _CheckBoolean (the params)
end checked_LocalProjects

private function _CheckBoolean theParams
   put _GetParamTitle (theParams) into someTitle
   put LocalArray ["titleText"] = someTitle into isChecked
   return isChecked
end _CheckBoolean

private command _SetIndex someIndex, theParams, displayView
   put _GetParamTitle (theParams) into someTitle -- "Not on Github"
   set the displayed_Index [someTitle] of displayView to someIndex
end _SetIndex

private function _GetParamTitle theParams
   set the itemdelimiter to "_"
   get item 2 of (word 1 of theParams)
   put text_SplitCaps (it) into paramTitle
   return paramTitle
end _GetParamTitle


--> Global | LCW | Projects | Menu
-
on menu_CreateNewProject
   project_AskCreate
end menu_CreateNewProject

private on _
end _

on menu_LocalProjects displayView
   -- put env_ListLocalProjects() into someIndex
   -- _SetIndex someIndex, the params, displayView
   
   display_Environment
end menu_LocalProjects

on menu_LivecodeWorldOnGithub displayView
   ---put github_ListOrgProjects() into someIndex
   -- _SetIndex someIndex, the params, displayView
   
   display_GithubOrgRepos
end menu_LivecodeWorldOnGithub

private on __
end __

on menu_NotOnGithub displayView
   put github_ListNotOnGithub() into someIndex
   --
   _SetIndex someIndex, the params, displayView
end menu_NotOnGithub

on menu_MissingLocalRepos displayView
   put github_ListMissingLocalRepos() into someIndex
   --
   _SetIndex someIndex, the params, displayView
end menu_MissingLocalRepos

on menu_ExportProjectArrays
   env_ExportMenusAndStackFiles
end menu_ExportProjectArrays

private on ___
end ___

on menu_UserScope dView, keyName
   put github_UserScopeData (keyName) into scopeData
   --
   display_Data scopeData, keyName, "github_UserScopeData()"
end menu_UserScope

getprop userScope_Params
   return github_ListApiKeyNames()
end userScope_Params

on menu_GithubOrgs dView, keyName
   put github_FetchMyOrgsData (keyName) into rData
   display_Data rData, keyName, "github_FetchMyOrgsData()"
end menu_GithubOrgs

getprop githubOrgs_Params
   return github_ListApiKeyNames()
end githubOrgs_Params

on menu_FetchMyOrgsData dView
   put gh_FetchMyOrgsData() into rData
   display_Data rData, "gh_FetchMyOrgsData()", "Github"
end menu_FetchMyOrgsData

on menu_Refresh displayView
   set the title_Text of displayView to "LiveCodeWorld"
   --
   -- display_GithubProjects
   display_GithubOrgRepos
end menu_Refresh
