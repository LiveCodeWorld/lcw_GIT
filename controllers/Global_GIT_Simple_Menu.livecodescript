script "Global | GIT | Simple | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | GIT | Simple | Menu
type: controller
target: projectName
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
   put the title_Text of displayView into projectName
   --
   put displayView into LocalArray ["displayView"]
   put project_HasGit (projectName) into LocalArray ["gitIsInitialised"]
   return projectName
end menu_Target

getprop menu_CheckTarget [projectName]
   if env_ProjectIsActive (projectName) then
      return true
   else
      return false
   end if
end menu_CheckTarget

function project_HasGit projectName, pRepoFolder
   -- project_GitIsInitialised is hard to spell
   put env_ProjectIsActive (projectName) into gitIsActive
   if gitIsActive is false then return false
   --
   put env_ConstructProjectFolder (projectName, pRepoFolder) into projectFolder
   put git_GetCheckoutFolder (projectFolder) into gitCheckoutFolder
   put there is a folder gitCheckoutFolder into gitIsInitialised
   return gitIsInitialised
end project_HasGit

getprop disabled_GitStatus [projectName]
   if LocalArray ["gitIsInitialised"] then
      return false
   else
      return true
      return "delete"
   end if
end disabled_GitStatus

getprop disabled_InitialiseGit [projectName]
   if LocalArray ["gitIsInitialised"] then
      return "delete"
   else
      return false
   end if
end disabled_InitialiseGit


--> Global | GIT | Simple | Menu
-
on menu_InitialiseGit projectName
   put env_ConstructProjectFolder (projectName) into projectFolder
   --
   git_InitFolder projectFolder
   --
   put git_GetCheckoutFolder (projectFolder) into gitCheckoutFolder
   display_GitFolderStatus gitCheckoutFolder
end menu_InitialiseGit

on menu_GitStatus projectName
   display_GitProjectStatus projectName
end menu_GitStatus

on menu_TrackCommmitAndPush projectName
   put the name of stack projectName into homeStack
   ask_PushGithub homeStack
end menu_TrackCommmitAndPush

on _
end _

on menu_LocalGitConfig projectName
   put the git_Folder of stack projectName into gitFolder
   if there is not a folder gitFolder then
      put LocalArray ["displayView"] into displayView
      lcw_AnswerWarning "Cannot locate git folder!", displayView
   end if
   --
   display_GitLocalConfig gitFolder
end menu_LocalGitConfig

on menu_LaunchGithub projectName
   put env_ConstructProjectFolder (projectName) into projectFolder
   put git_GetRemoteAddress (projectFolder) into remoteAddress
   --
   put github_FindRepoName (remoteAddress) into repoName
   github_Launch repoName
end menu_LaunchGithub
