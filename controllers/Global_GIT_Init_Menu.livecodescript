script "Global | GIT | Init | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Init | Menu
type: controller
version: 0.3

/*
This menu is for project displays. Typically an ndex_View with then menu_Target set to the project_Name.
*/

--> Menu | Init
-
local LocalArray

getprop menu_Target [tObject]
   put git_LocalArray ("projectName") into projectName
   return projectName
end menu_Target

getprop disabled_InitialiseGit
   if git_LocalArray ("gitIsActive") is true then
      return "delete"
   else
      return false
   end if
end disabled_InitialiseGit

getprop disabled_CreateGithubProject
   if git_LocalArray ("gitIsActive") is false then return true
   if git_LocalArray ("gitHubRepoExists") is true then
      return true
   else
      return false
   end if
end disabled_CreateGithubProject

getprop disabled_DisplayGithubInfo
   if git_LocalArray ("gitHubRepoExists") then
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


--> Global | GIT | Init | Menu
-
on menu_InitialiseGit projectName
   put git_LocalArray ("displayView") into displayView
   put git_LocalArray ("projectFolder") into projectFolder
   --
   put merge ("Are you sure you want to initialise the project '[[projectName]]' with a git repo?") into someQuestion
   lcw_Answer someQuestion, displayView, projectName
   --
   git_InitFolder projectFolder
   put the result into testGitRootFolder
   --
   if testGitRootFolder is not projectFolder then
      breakpoint
   end if
end menu_InitialiseGit

on _
end _

on menu_CreateGithubProject projectName
   put git_LocalArray ("lcwRepoNames") into lcwRepoNames
   put git_LocalArray ("gitFolder") into gitFolder
   
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
end menu_CreateGithubProject

on menu_LaunchGithubProject projectName
   put the github_LaunchURL of stack projectName into someURL
   launch url someURL
end menu_LaunchGithubProject

on menu_DisplayGithubOrg
   put git_LocalArray ("orgName") into orgName
   --
   display_GithubProjects orgName
end menu_DisplayGithubOrg

on menu_DisplayGithubInfo
   put git_LocalArray ("gitRemoteAddress") into gitRemoteAddress
   --
   put github_FindRepoName (gitRemoteAddress) into repoName
   display_GitHubInfo repoName
end menu_DisplayGithubInfo
