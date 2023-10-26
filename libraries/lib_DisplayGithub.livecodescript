script "lib_DisplayGithub"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayGithub
type: library
version: 0.1

/*Some help*/


--> Working on
-
function github_ConstructPageArray readmeMarkdown, pageTitle
   -- fedwiki_ConvertGitHubReadme
   put wiki_Merge ("On this page we describe the [[Github]] project {{githubProjectName}}.") into firstPara
   --
   put pageArray_Construct (pageTitle, firstPara) into pageArray
   pageArray_AddMarkdown pageArray, readmeMarkdown
   pageArray_AddMarkdown pageArray, "# See also"
   pageArray_AddMarkdown pageArray, "- [[Github]]"
   --
   pageArray_CleanJournal pageArray
   return pageArray
end github_ConstructPageArray

command display_GitGlobalConfig 
   # Shell at home
   put "git config --list" into someShell
   put the home folder into sFolder
   put git_ExecuteShellCommand (someShell, sFolder) into configArray
   split configArray using CR and "="
   
   # Display
   display_Tools configArray, "Global Config", "GIT | Settings", "Git"
   put the result into dView
   --
   set the displayed_ConfigArray of dView to configArray
   return dView
end display_GitGlobalConfig

command display_GitLocalConfig gitFolder 
   # Shell local
   put "git config --list" into someShell
   put git_ExecuteShellCommand (someShell, gitFolder) into configArray
   split configArray using CR and "="
   
   # Guess projectName?
   set the itemdelimiter to slash
   put item -1 of gitFolder into projectName
   
   # Display
   display_Tools configArray, projectName, "GIT | Settings", "Local Git Config"
   put the result into dView
   --
   -- set the displayed_ConfigArray of dView to configArray -- already displaying
   
   # Init Menu Model
   git_InitGlobalModel -- probably don;t need to do this again
   set the git_InitSettingsModel of dView to projectName
   --
   return dView
end display_GitLocalConfig

command display_GitHubOrgs
   put github_ListMyOrgs() into orgNames
   --
   display_Tools orgNames, "My", "Github | Orgs", "Github Orgs", "lcw_Github"
   put the result into displayView
   --
   put github_OrgsData (true) into orgsData
   -- put github_ConstructOrgIndex (orgsData) into orgNames
   set the displayed_OrgsData of displayView to orgsData
   --
   return displayView
end display_GitHubOrgs

command display_GitHubInfo repoName
   put github_FetchRepoArray (repoName) into repoArray
   display_Array repoArray
end display_GitHubInfo


--> Display | LCW | Projects
-
command display_GithubOrgRepos pOrgName
   -- Same as "display_GithubProjects" ?
   -- https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-organization-repositories
   if pOrgName is empty then put "LiveCodeWorld" into pOrgName
   
   put github_ListOrgRepos (pOrgName) into repoNames
   sort repoNames
   --
   display_Tools repoNames, pOrgName, "LCW | Projects", "Github Org Repos", "lcw_Github"
   put the result into displayView
   
   # Colout local and missing projects
   lock screen
   put env_ListLocalProjects() into localProjects
   put github_ListMissingLocalRepos() into missingRepoNames
   set the coloured_Lines ["dark green"] of displayView to localProjects
   set the coloured_Lines ["orange"] of displayView to missingRepoNames
   unlock screen
   --
   return displayView
end display_GithubOrgRepos

command display_GithubProjects pOrgName
   if pOrgName is empty then put "LiveCodeWorld" into pOrgName
   --
   put github_ListOrgProjects (pOrgName) into projectNames
   --
   display_Tools projectNames, pOrgName, "LCW | Projects", "Github Projects", "lcw_Github"
   put the result into displayView
   
   # Colout local and missing projects
   lock screen
   put env_ListLocalProjects() into localProjects
   put github_ListMissingLocalRepos() into missingRepoNames
   set the coloured_Lines ["dark green"] of displayView to localProjects
   set the coloured_Lines ["orange"] of displayView to missingRepoNames
   unlock screen
   --
   return displayView
end display_GithubProjects

command display_GitHubProjectInfo orgName, orgsData
   put github_FindOrgArray (orgName, orgsData) into orgArray
   display_Data orgArray, orgName, "Github Org"
   put the result into displayView
   return displayView
end display_GitHubProjectInfo


--> Display | Git | CommitHistory
-
command display_GitCommitHistory gitFolder
   put git_CurrentBranchName (gitFolder) into branchName
   put git_ExecuteShellCommand ("git log", gitFolder) into commitHistory
   --
   display_Tools commitHistory, "git log", "Git | Log", branchName, "lcw_Git"
   put the result into displayView
   return displayView
end display_GitCommitHistory


--> mDoubleUp
-
on mDoubleUp_GITSettings displayView, someLine
   breakpoint
   put the title_Text of displayView into someTitle
end mDoubleUp_GITSettings

on mDoubleUp_GithubOrgs displayView, someLine
   put the displayed_OrgsData of displayView into orgsData
   put the selected_Line of displayView into projectName
   --
   display_GitHubProjectInfo projectName, orgsData
end mDoubleUp_GithubOrgs

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

command mDoubleUp_GitLog dView, someLine
   breakpoint
   put the git_SettingsModel of dView into cArray
   put cArray ["gitFolder"] into gitFolder
   put cArray ["projectName"] into projectName
   
   switch word 1 of someLine
      case "commit"
         put word 2 of someLine into commitHash
         
         put commitHash & ":" & "lcw_GIT.livecode" into treeish
         put git_List (treeish, gitFolder)
         
         exit to top
         lcw_Answer merge ("Do you want to revert to checked out project [[commitHash]]?")
         
         breakpoint
         put "git check()out" && commitHash into someShell
         put git_ExecuteShellCommand (someShell, gitFolder) into shellResult
         --
         display_GitRefreshProjectName projectName
         break
      default
   end switch
end mDoubleUp_GitLog
