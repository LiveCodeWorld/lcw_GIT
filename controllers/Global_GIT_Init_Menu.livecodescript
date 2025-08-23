script "Global | GIT | Init | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Init | Menu
type: controller
version: 0.3

/*
This menu is for project displays. Typically an index_View with then menu_Target set to the project_Name.
*/

--> Menu | Init
-
local LocalArray

getprop menu_Target [tObject]
   _InitLocalArray tObject
   -- put LocalArray ["projectName"] into projectName
   put the title_Text of tObject into projectName
   return projectName
end menu_Target

private command _InitLocalArray tObject
   put the display_View of tObject into dView
   put the git_SettingsModel of dView into LocalArray
end _InitLocalArray

getprop disabled_CreateGithubProject
   if LocalArray ["gitFolder"] is empty then return true
   if LocalArray ["gitHubRepoExists"] is true then
      return true
   else
      return false
   end if
end disabled_CreateGithubProject

getprop disabled_DisplayGithubInfo
   if LocalArray ["gitHubRepoExists"] then
      return false
   else
      return true
   end if
end disabled_DisplayGithubInfo


--> Events
-
on mouseDoubleUp_GitHub indexView, lcwRepoName
   github_Launch lcwRepoName
end mouseDoubleUp_GitHub


--> Working on
-
private command _AskSetGitRemote projectName
   put LocalArray ["gitFolder"] into gitFolder
   put _AskRemote (gitFolder) into remoteURL
   --
   put "git remote set-url origin" && remoteURL into someShell
   git_ExecuteShell someShell, gitFolder
   if the result is not empty then
      put the result
      breakpoint
   end if
   --
   display_GitProjectStatus projectName
end _AskSetGitRemote

private function _AskRemote gitFolder
   get git_GetRemote (gitFolder)
   put line 1 of it into oldRemote
   -- origin	https://github.com/LiveCodeWorld/lcw_Learn.git (fetch)
   delete word 1 of it
   delete word -1 of it
   put word 1 to -1 of it into oldRemote
   --
   set the itemdelimiter to slash
   put item -1 of oldRemote into shortFile
   put "https://github.com/LiveCodeWorld/" & shortFile into newRemoteURL
   --
   put lcw_Ask("Provide Github. https url:", newRemoteURL) into remoteURL
   return remoteURL
end _AskRemote


--> Global | GIT | Init | Menu
-
on menu_IgnoreDsStore dView
   get git_GetGlobalIgnoreDSStore()
   if it is true then
      lcw_AnswerWarning "Git is set to ignore DSStore fiels globally!"
   else
      lcw_Answer "Do you want to set git to ignore DSStore globally", dView
      git_SetGlobalIgnoreDSStore
   end if
end menu_IgnoreDsStore

on menu_InitialiseGit projectName
   put LocalArray ["projectName"] into projectName
   --
   git_AskInit projectName
end menu_InitialiseGit

getprop disabled_InitialiseGit [repoName]
   -- put LocalArray ["projectName"] into repoName
   return git_GetInit (repoName)
end disabled_InitialiseGit

private command _
end _

on menu_CreateGithubProject projectName
   put LocalArray ["orgName"] into orgName
   put LocalArray ["gitFolder"] into gitFolder
   --
   put github_ListOrgProjects (orgName) into lcwRepoNames
   
   -- let's check to see if GitHub repo exists (Should be disabled)
   if projectName is among the lines of lcwRepoNames then
      answer warning "LiveCodeWorld repository already exists!"
      exit to top
   end if
   
   -- check to see if remote address already exists
   put git_GetRemoteAddress (gitFolder) into oldRemoteAddress
   if oldRemoteAddress begins with "git@github.com:LiveCodeWorld/" then
      -- not sure what to do???
      put oldRemoteAddress
      answer warning "LiveCodeWorld repository is already linked but remote repo does not exist! Unlink it first?"
      exit to top
   end if
   
   -- let's create it
   put lcw_Ask ("Give the new repo a name..", projectName) into repoName
   put lcw_Ask ("Give repo a description...", "A project to interact with git and Github.") into repoDescription
   
   github_CreateProject repoName, gitFolder, repoDescription
   put the result into githubProjectArray
   -- 
   put githubProjectArray ["ssh_url"] into remoteSshUrl
   --
   put remoteSshUrl
   --
   display_GitProjectStatus projectName
end menu_CreateGithubProject

on menu_LaunchGithubProject projectName
   put the github_LaunchURL of stack projectName into someURL
   launch url someURL
end menu_LaunchGithubProject

on menu_DisplayGithubOrg
   put LocalArray ["orgName"] into orgName
   --
   display_GithubProjects orgName
end menu_DisplayGithubOrg

private command __
end __

on menu_DisplayGithubInfo
   put LocalArray ["gitRemoteAddress"] into gitRemoteAddress
   --
   put github_FindRepoName (gitRemoteAddress) into repoName
   display_GitHubInfo repoName
end menu_DisplayGithubInfo

on menu_DisplayGitRemote
   put LocalArray ["gitFolder"] into gitFolder
   --
   put git_GetRemote (gitFolder)
end menu_DisplayGitRemote

getprop disabled_SetGitRemote [projectName]
   get git_GetRemote (gitFolder)
   if it contains "git@" then
      return true
   else
      return false
   end if
end disabled_SetGitRemote

getprop disabled_AddGitRemote [projectName]
   get git_GetRemote (gitFolder)
   if it is empty then
      return false
   else
      return true
   end if
end disabled_AddGitRemote

getprop disabled_FixGitRemote
   put LocalArray ["gitFolder"] into gitFolder
   get git_GetRemote (gitFolder)
   if it begins with "origin	git@" then
      return false
   else
      return true
   end if
end disabled_FixGitRemote

on menu_FixGitRemote projectName
   _AskSetGitRemote projectName
end menu_FixGitRemote

on menu_SetGitRemote projectName
   _AskSetGitRemote projectName
end menu_SetGitRemote

on menu_AddGitRemote projectName
   put LocalArray ["gitFolder"] into gitFolder
   --
   put _AskRemote (gitFolder) into remoteURL
   --
   put "git remote add origin" && remoteURL into someShell
   --
   git_ExecuteShell someShell, gitFolder
   if the result is not empty then breakpoint
   --
   display_GitProjectStatus projectName
end menu_AddGitRemote

private command ___
end ___

on menu_FirstPush projectName
   breakpoint
   -- For a project which has never been pushed to GitHub
   -- Remote must have been set up
   put LocalArray ["gitFolder"] into gitFolder
   --
   git_FirstPush gitFolder
   if the result is not empty then
      put the result
   end if
   --
   display_GitProjectStatus projectName
end menu_FirstPush

on menu_GithubAuth
   put "gh auth login" into someShell
   --
   -- put shell (someShell)
   terminal_PasteInNewTab someShell
end menu_GithubAuth

on menu_InstallGithubTool
   -- https://github.com/cli/cli#installation
   put "brew install gh" into someShell
   --
   -- put shell (someShell)
   terminal_PasteInNewTab someShell
end menu_InstallGithubTool
