script "lib_DisplayGithub"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_DisplayGithub
type: library
version: 0.3

/*Some help*/


--> Working on
-
command display_GitHubProjectInfo orgName, pOrgArray
   -- put github_FindOrgArray (orgName, orgsData) into pOrgArray
   display_Data pOrgArray, orgName, "Github Org"
   put the result into displayView
   return displayView
end display_GitHubProjectInfo

command display_GithubApiHelp pBrowserView
   display_Browser "https://docs.github.com/en/rest?apiVersion=2022-11-28", pBrowserView, "Github API"
end display_GithubApiHelp


--> Display | Github
-
command display_GithubOrgs
   -- put lcw_ListMyGithubOrgs() into orgNames
   -- put github_FetchMyOrgsData ("Developer") into rArray
   put gh_FetchMyOrgsData() into indexArray
   put indexArray_List (rArray, "login") into sIndex
   --
   display_IndexArray indexArray, "opn", "Github Orgs", pOrdered, "login"
   put the result into dView
   set the menu_TitleBit ["lib_Github"] of dView to "Github | Orgs"
   return dView
end display_GithubOrgs

command display_GithubShell repoName, pOrgName
   put gh_CreateOrgRepo (repoName, pOrgName) into sShell
   --
   display_Xterm sShell
   return the result
end display_GithubShell

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

command display_GitHubInfo repoName
   put gh_FetchRepoArray (repoName) into repoArray
   display_Array repoArray
end display_GitHubInfo


--> Display | LCW | Projects
-
command display_GithubOrgRepos pOrgName
   -- Same as "display_GithubProjects" ?
   -- https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-organization-repositories
   if pOrgName is empty then put "LiveCodeWorld" into pOrgName
   
   put github_ListOrgRepos (pOrgName) into repoNames
   -- put lcw_ListGithubRepos() into repoNames
   sort repoNames
   --
   display_Tools repoNames, pOrgName, "Github | Projects", "Github Repos", "lcw_Github"
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


--> Deps
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


