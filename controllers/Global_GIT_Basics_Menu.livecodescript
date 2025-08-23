script "Global | GIT | Basics | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Basics | Menu
type: controller
version: 0.4

/*
Here we look to place the most immportant tools for git.
that allow access to other tools and are not too slow to draw the menus necessary.
*/


--> Menu | Props
-
local LocalArray

getprop menu_Target [tObject]
   _InitLocalArray tObject
   return LocalArray ["gitFolder"]
end menu_Target

private command _InitLocalArray tObject
   put the display_View of tObject into dView
   put the git_SettingsModel of dView into LocalArray
   put dView into LocalArray ["displayView"]
   --
   put the title_Text of tObject into repoName
   put repoName into LocalArray ["projectName"]
   return dView
end _InitLocalArray

private function _LocalValue someKey
   return LocalArray [someKey]
end _LocalValue


--> Working on
-
-- getprop disabled_AddAllUntracked
if _LocalValue ("gitFolder") is empty then return true
put _FilesToAdd() into untrackedFiles
if untrackedFiles is empty then
   return true
else
   return false
end if
end disabled_AddAllUntracked

-- getprop disabled_StageThenCommit
if _LocalValue ("gitFolder") is empty then return true
if _FilesToAdd() is not empty then return true

if _FilesToStageAndCommit() then
   return false
else
   return true
end if
end disabled_StageThenCommit

private function _FilesToAdd
   put _StatusArray() into statusArray
   put statusArray ["Untracked files:"]["files"] into untrackedFileList
   return untrackedFileList
end _FilesToAdd

private function _StatusArray
   put _LocalValue ("statusArray") into statusArray
   if statusArray is empty then
      put _LocalValue ("displayView") into displayView
      put the displayed_Array of displayView into statusArray
      put statusArray into LocalArray ["statusArray"]
   end if
   return statusArray
end _StatusArray

getprop gitDocumentation_Params
   return the hkey_CaseConditions ["M menu_GitDocumentation"] of me
end gitDocumentation_Params

-- getprop disabled_Pull
return _LocalValue ("gitRemoteAddress") is empty
end disabled_Pull

--  getprop disabled_PushCurrentBranch
return _LocalValue ("gitRemoteAddress") is empty
end disabled_PushCurrentBranch

getprop disabled_PushCurrentBranch [gitFolder]
   put _StatusArray() into statusArray
   put statusArray ["Branch"] into branchArray
   put "(use 'git push' to publish your local commits)" into pushLine
   replace "'" with quote in pushLine
   put the keys of branchArray into branchKeys
   if pushLine is among the lines of branchKeys then
      return false
   else
      return true
   end if
end disabled_PushCurrentBranch

getprop disabled_RefreshGitStatus
   if _LocalValue ("gitFolder") is empty then
      return true
   end if
   
   put _LocalValue ("projectName") into projectName
   if _ExistsGitStatusDisplay (projectName) then
      return false
   else
      return "delete"
   end if
end disabled_RefreshGitStatus

getprop disabled_DisplayGitStatus
   if _LocalValue ("gitFolder") is empty then
      return true
   end if
   
   put _LocalValue ("projectName") into projectName
   if _ExistsGitStatusDisplay (projectName) then
      return "delete"
   else
      return false
   end if
end disabled_DisplayGitStatus


--> Global | GIT | Basics | Menu
-
on menu_DisplayGitStatus gitFolder
   stack_SaveEdited "all"
   display_GitFolderStatus gitFolder
end menu_DisplayGitStatus

on menu_SaveAndRefresh
   stack_SaveEdited "all"
   _RefreshGitStatus
end menu_SaveAndRefresh

on menu_AddAllUntracked gitFolder
   /*
   -- dig into this. "git add --update" does not seem to do anything useful.
   git_AddChanged
   */
   set the cursor to watch
   git_AddEverything gitFolder
   put the result into shellResult
   if shellResult is not empty then
      lcw_Notify shellResult
   end if
   _RefreshGitStatus
end menu_AddAllUntracked

on menu_StageThenCommit gitFolder
   put lcw_Ask ("Comment on this change...") into someComment
   git_AddAndCommit someComment, gitFolder
   _RefreshGitStatus
end menu_StageThenCommit

on menu_TrackCommmitAndPush
   put _LocalValue ("projectName") into projectName
   put the name of stack projectName into homeStack
   ask_PushGithub homeStack
end menu_TrackCommmitAndPush

on menu_Pull gitFolder   
   -- TO PULL A new BRANCH FROM A REMOTE REPOSITORY
   -- put merge("git pull origin [[remoteBranch]]:[[newLocalBranch]]") into someShell
   -- put "git pull" into someShell
   -- put "git pull origin master" into someShell
   
   put git_CurrentBranchName (gitFolder) into currentBranchName
   put "git pull origin" && kwote (currentBranchName) into someShell
   put git_ExecuteShellCommand (someShell, gitFolder) into shellResult
   
   # Display
   display_GitPullResult shellResult, someShell
end menu_Pull

on menu_PushCurrentBranch gitFolder
   -- TO push THE new BRANCH TO A REMOTE REPOSITORY
   set the cursor to watch
   --
   display_GitPushCurrentBranch gitFolder
end menu_PushCurrentBranch

on _
end _

on menu_DisplayLocalConfig gitFolder
   display_GitLocalConfig gitFolder
end menu_DisplayLocalConfig

on menu_LaunchGithubProject
   put _LocalValue ("projectName") into projectName
   --
   put the github_LaunchURL of stack projectName into someURL
   launch url someURL
end menu_LaunchGithubProject

on menu_GitDocumentation gitFolder, menuChoice
   switch menuChoice
      case "Crash course"
         launch url "http://git.or.cz/course/svn.html"
         break
      case "Git Wiki"
         launch url "http://git.or.cz/gitwiki/GitDocumentation"
         break
      case "Git User manual"
         launch url "http://www.kernel.org/pub/software/scm/git/docs/user-manual.html"
         break
   end switch
end menu_GitDocumentation


--> Private
-
private function _FilesToStageAndCommit
   put _LocalValue ("statusArray") into statusArray
   --
   put statusArray ["Changes not staged for commit:"] into notStagedArray
   put statusArray ["Changes to be committed:"] into toCommitArray
   switch
      case notStagedArray is not empty
      case toCommitArray is not empty
         return true
      default
         return false
   end switch
end _FilesToStageAndCommit

private function _ExistsGitStatusDisplay
   put _LocalValue ("displayView") into displayView
   return exists (displayView)
end _ExistsGitStatusDisplay

private command _RefreshGitStatus
   put _LocalValue ("projectName") into projectName
   display_GitRefreshProjectName projectName
end _RefreshGitStatus
