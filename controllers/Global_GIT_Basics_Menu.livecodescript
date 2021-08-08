script "Global | GIT | Basics | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Basics | Menu
type: controller
version: 0.3

/*
*/


--> Where?
-
private function _FilesToCommit
   put git_LocalArray ("statusArray") into statusArray
   put statusArray ["Changes not staged for commit:"]["modified"] into modifiedFiles
   return modifiedFiles
end _FilesToCommit

private function _IsGitStatusDisplay
   put git_LocalArray ("displayView") into displayView
   put git_LocalArray ("projectName") into projectName
   return _ExistsGitStatusDisplay (projectName)
end _IsGitStatusDisplay


--> Menu | Props
-
local LocalArray

getprop menu_Target [tObject]
   put git_LocalArray ("gitFolder") into gitFolder
   return gitFolder
end menu_Target

getprop gitDocumentation_Params
   return the hkey_CaseConditions ["M menu_GitDocumentation"] of me
end gitDocumentation_Params

getprop disabled_PushCurrentBranch
   put git_LocalArray ("statusArray") into statusArray
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
   if git_LocalArray ("gitIsActive") is false then
      return true
   end if
   
   put git_LocalArray ("projectName") into projectName
   if _ExistsGitStatusDisplay (projectName) then
      return false
   else
      return "delete"
   end if
end disabled_RefreshGitStatus

getprop disabled_DisplayGitStatus
   if git_LocalArray ("gitIsActive") is false then
      return true
   end if
   
   put git_LocalArray ("projectName") into projectName
   if _ExistsGitStatusDisplay (projectName) then
      return "delete"
   else
      return false
   end if
end disabled_DisplayGitStatus

getprop disabled_Pull
   return git_LocalArray ("_RemoteIsBad")
end disabled_Pull

getprop disabled_PushCurrentBranch
   return git_LocalArray ("_RemoteIsBad")
end disabled_PushCurrentBranch

getprop disabled_AddAllUntracked
   if git_LocalArray ("gitIsActive") is false then return true
   put _FilesToAdd() into untrackedFiles
   if untrackedFiles is empty then
      return true
   else
      return false
   end if
end disabled_AddAllUntracked

getprop disabled_StageThenCommit
   if git_LocalArray ("gitIsActive") is false then return true
   if _FilesToAdd() is not empty then return true
   
   if _FilesToStageAndCommit() then
      return false
   else
      return true
   end if
end disabled_StageThenCommit


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

on _AddAllUntracked gitFolder
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
end _AddAllUntracked

on _StageThenCommit gitFolder
   put lcw_Ask ("Comment on this change...") into someComment
   git_CommitChanges someComment, gitFolder
   _RefreshGitStatus
end _StageThenCommit

on menu_TrackCommmitAndPush
   put git_LocalArray ("projectName") into projectName
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
   display_Lines shellResult, someShell
   put the result into indexView
   set the title_Menu of indexView to "Global | Git | Pull | Menu"
   set the line_Menu of indexView to "Global | Git | Pull | Line | Menu"
   -- set the displayed_ScriptObject of indexView to empty
   set the displayed_GitCheckoutFolder of indexView to gitFolder
   set the displayed_GitBranch of indexView to currentBranchName
   
   _RefreshGitStatus
   
   /*
   stack_RevertLoaded
   put the result into displayView
   set the menu_Title of displayView to "Global | Git | Pull | Menu"
   */
end menu_Pull

on menu_PushCurrentBranch gitFolder
   -- TO push THE new BRANCH TO A REMOTE REPOSITORY
   set the cursor to watch
   --
   display_GitPushCurrentBranch gitFolder
end menu_PushCurrentBranch

on _
end _

on menu_LaunchGithubProject
   put git_LocalArray ("projectName") into projectName
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
   put git_LocalArray ("statusArray") into statusArray
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

private function _FilesToAdd
   put git_LocalArray ("statusArray") into statusArray
   put statusArray ["Untracked files:"]["files"] into untrackedFileList
   return untrackedFileList
end _FilesToAdd

private function _ExistsGitStatusDisplay
   put git_LocalArray ("displayView") into displayView
   return exists (displayView)
end _ExistsGitStatusDisplay

private command _RefreshGitStatus
   put git_LocalArray ("projectName") into projectName
   display_GitRefreshProjectName projectName
end _RefreshGitStatus
