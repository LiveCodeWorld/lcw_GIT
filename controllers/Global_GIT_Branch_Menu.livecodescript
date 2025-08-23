script "Global | GIT | Branch | Menu"
--> MetaData
-
license: GPLv3
name: Global | GIT | Branch | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   _InitLocalArray tObject
   return LocalArray ["gitFolder"]
end menu_Target


--> Private
-
private command _InitLocalArray tObject
   put the display_View of tObject into dView
   put the git_SettingsModel of dView into LocalArray
   return dView
end _InitLocalArray

private function _LocalValue someKey
   return LocalArray [someKey]
end _LocalValue

private command _RefreshGitStatus
   put _LocalValue ("displayView") into displayView
   put _LocalValue ("gitFolder") into gitFolder
   display_GitFolderStatus gitFolder, displayView
end _RefreshGitStatus

private function _GetFile
   put _LocalValue ("displayView") into displayView
   put the selected_Value of displayView into relativeFile
   put _LocalValue ("gitFolder") into gitFolder
   put gitFolder & relativeFile into someFile
   return someFile
end _GetFile

private function _ExecuteGit someShell
   put _LocalValue ("gitFolder") into gitFolder
   put git_ExecuteShellCommand (someShell, gitFolder) into shellResult
   return shellResult
end _ExecuteGit

private function _GetCheckoutFolder
   put _LocalValue ("gitFolder") into gitFolder
   if there is not a folder gitFolder then return empty
   return gitFolder
end _getCheckoutFolder

private function _askForBranchName
   put lcw_Ask ("What's the new branch name?", "test") into branchName
   if git_ValidBranchName (branchName) is false then
      answer warning "Branch name contains invalid characters!"
      exit to top
   end if
   if the number of words of branchName > 1 then put kwote (branchName) into branchName
   return branchName
end _askForBranchName

function git_ValidBranchName branchName
   -- http://stackoverflow.com/questions/3651860/which-characters-are-illegal-within-a-branch-name
   switch
      case branchName begins with "."
      case branchName contains ".."
      case branchName ends with "/"
      case branchName ends with ".lock"
      case branchName contains "\"
         return false
      default
         return true
   end switch
end git_ValidBranchName

getprop local_BranchNames  
   put "git branch" into someShell
   put _executeGit (someShell)  into shellResult
   
   repeat for each line someLine in shellResult
      if word 1 of someLine = "*" then
         put "(" & word 2 to -1 of someLine & CR after branchNames
      else
         put word 1 to -1 of someLine & CR after branchNames
      end if
   end repeat
   delete char -1 of branchNames
   return branchNames
end local_BranchNames

getprop remote_BranchNames
   git_DeconstructBranchNames localBranchNames, remoteBranches, remoteNames, remoteBranchNames, remoteMappings
   -- replace "/" with "\/" in remoteBranchNames
   return remoteNames
end remote_BranchNames

getprop branch_Names
   -- put "git branch" into someShell
   put "git branch -a" into someShell
   put _executeGit (someShell)  into shellResult
   
   repeat for each line someLine in shellResult
      if word 1 of someLine = "*" then
         put "(" & word 2 to -1 of someLine & CR after branchNames
      else
         put word 1 to -1 of someLine & CR after branchNames
      end if
   end repeat
   delete char -1 of branchNames
   return branchNames
end branch_Names

function git_ParseRawDiff rawDiff
   set the itemdelimiter to tab
   put 1 into lineNum
   repeat for each line someLine in rawDiff
      if char 1 of someLine = ":" then
         delete char 1 of someLine
      else
         lcw_Notify someLine, true
         next repeat
      end if
      
      put item 1 of someLine into firstBit
      put item 2 of someLine into srcPath
      put item 3 of someLine into dstPath
      
      put word 1 of firstBit into srcMode
      put word 2 of firstBit into dstMode
      
      put word 3 of firstBit into srcHash
      put word 4 of firstBit into dstHash
      put word 5 of firstBit into status
      
      /*
      -- for datagrid
      put srcMode into dataArray [lineNum]["srcMode"]
      put dstMode into dataArray [lineNum]["dstMode"]
      put srcHash into dataArray [lineNum]["srcHash"]
      put dstHash into dataArray [lineNum]["dstHash"]
      put srcPath into dataArray [lineNum]["srcPath"]
      put dstPath into dataArray [lineNum]["dstPath"]
      put status into dataArray [lineNum]["status"]
      */
      
      put srcMode into dataArray [srcPath]["srcMode"]
      put dstMode into dataArray [srcPath]["dstMode"]
      put srcHash into dataArray [srcPath]["srcHash"]
      put dstHash into dataArray [srcPath]["dstHash"]
      put dstPath into dataArray [srcPath]["dstPath"]
      put status into dataArray [srcPath]["status"]
      
      add 1 to lineNum
   end repeat
   return dataArray
end git_ParseRawDiff

command git_DeconstructBranchNames @localBranchNames, @remoteBranches, @remoteNames, @remoteBranchNames, @remoteMappings
   put "git branch -a" into someShell
   put git_ExecuteShellCommand(someShell) into shellResult
   
   set the itemdelimiter to "/"
   repeat for each line someLine in shellResult
      put char 1 to 2 of someLine into starBit
      put char 3 to -1 of someLine into branchBit
      
      if item 1 of branchBit = "remotes" and the number of items of branchBit > 1 then
         if branchBit contains " -> " then
            put branchBit & CR after remoteMappings
         else
            put branchBit & CR after remoteBranches
            put item 2 of branchBit & CR after remoteNames
            put item 3 of branchBit & CR after remoteBranchNames
         end if
      else
         if word 1 of starBit = "*" then
            put "(" & branchBit & CR after localBranchNames
         else
            put branchBit & CR after localBranchNames
         end if
      end if
   end repeat
   delete char -1 of localBranchNames
   delete char -1 of remoteBranches
   delete char -1 of remoteNames
   delete char -1 of remoteBranchNames
   delete char -1 of remoteMappings
end git_DeconstructBranchNames


--> Global | GIT | Branch | Menu
-
on menu_PushCurrentBranch gitFolder
   display_GitPushCurrentBranch gitFolder
end menu_PushCurrentBranch

on _
end _

on menu_ThisBranch gitFolder
   put git_CurrentBranchName (gitFolder)
end menu_ThisBranch

on menu_Merge gitFolder, localBranchName   
   put "git merge" && localBranchName into someShell
   put _executeGit (someShell)  into shellResult
   
   display_Lines shellResult, someShell
   _refreshGitStatus
end menu_Merge

on menu_MergeWithMaster gitFolder
   put "git merge master" into someShell
   put _executeGit (someShell)  into shellResult
   
   display_Lines shellResult, "git merge master"
   _refreshGitStatus
end menu_MergeWithMaster

on menu_AbortMerge
   -- Stop merge (in case of conflicts)
   put "git merge --abort" into someShell
   put _executeGit (someShell)  into shellResult
   
   display_Lines shellResult, "git merge master"
   _refreshGitStatus
end menu_AbortMerge

on _
end _

on menu_SwitchLocalBranch gitFolder, localBranchName
   /*
   To prepare for working on <branch>, switch to it by updating the index and the files in the working tree, and by pointing HEAD at the branch. 
   Local modifications to the files in the working tree are kept, so that they can be committed to the <branch>.
   
   Switching branches carries uncommitted changes with you. 
   If you don't want to do that, either commit first, run git checkout . to undo them, or run git stash before switching. (You can get your changes back with git stash apply)
   -- http://stackoverflow.com/questions/5531362/why-git-keeps-showing-my-changes-when-i-switch-branches-modified-added-deleted
   */
   
   put _LocalValue ("displayView") into displayView
   lcw_Answer "Sure you want to switch to branch '[[localBranchName]]'?", displayView, localBranchName
   
   put stack_ListEditedNames() into editedStacks
   if editedStacks is not empty then
      answer "The state of your file system will change after executing this command. Do you want to save any stacks you have edited first?" with "Save" and "No"
      if it is "Save" then
         stack_SaveEdited "all"
      end if
   end if
   
   put "git checkout" && kwote(localBranchName) into someShell
   put _executeGit (someShell)  into checkoutResult
   
   -- lcw_Notify checkoutResult
   display_Lines checkoutResult, someShell
   _refreshGitStatus
   
   set the itemdelimiter to ":"
   if item 1 of checkoutResult = "error" then
      put merge ("Failed to change branch. See error...") into someComment
      put checkoutResult
      lcw_AnswerWarning someComment, displayView
   else
      put merge ("Be aware that any open stacks may have changed on your file system due to switching branches. You should revert all open staks to ensure you are working with the new files.") into someComment
      lcw_AnswerWarning someComment, displayView
      -- here we could script reverting the local files
   end if
end menu_SwitchLocalBranch

on _
end _

on menu_CreateNewBranch
   put _AaskForBranchName() into branchName
   breakpoint
   
   put "git branch" && branchName into someShell
   put _executeGit (someShell)  into shellResult
   
   lcw_Notify shellResult, true
end menu_CreateNewBranch

on menu_CreateAndCheckoutNewBranch
   /*
   -- https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging
   $ git checkout -b iss53
   Switched to a new branch "iss53"
   This is shorthand for:
   
   $ git branch iss53
   $ git checkout iss5
   */
   
   put _AskForBranchName() into branchName
   
   put "git checkout -b" && branchName into someShell
   put _executeGit (someShell)  into shellResult
   
   _RefreshGitStatus
   lcw_Notify shellResult, true
end menu_CreateAndCheckoutNewBranch

on _
end _

on menu_DeleteLocalBranch gitFolder, localBranchName
   breakpoint
   put "git branch -d" && kwote (localBranchName) into someShell
   put _executeGit (someShell)  into shellResult
   lcw_Notify shellResult, true
end menu_DeleteLocalBranch

on _
end _

on menu_RemoteBranch gitFolder, remoteBranchName
   breakpoint
   put "git remote show" && remoteBranchName into someShell
   put _executeGit (someShell)  into shellResult
   display_Lines shellResult, someShell
end menu_RemoteBranch

on _
end _

on menu_DiffLocalBranch gitFolder, localBranchName
   display_GitBranchDiff gitFolder, localBranchName
end menu_DiffLocalBranch

on _
end _

on menu_BranchDocumentation gitFolder, whichDoc
   switch whichDoc
      case "Branching in a nutshell"
         put "https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell" into someURL
         break
      case "Move to new branch"
         put "http://stackoverflow.com/questions/1394797/move-existing-uncommited-work-to-a-new-branch-in-git" into someURL
         break
         cae "-"
      case "Resolving conflicts"
         put "https://help.github.com/articles/resolving-a-merge-conflict-from-the-command-line/" into someURL
         break
      case "Simple conflict resolution"
         put "https://githowto.com/resolving_conflicts" into someURL
         break
      case "Visual merge tools"
         put "http://stackoverflow.com/questions/137102/whats-the-best-visual-merge-tool-for-git" into someURL
         break
      case "Cheat sheet"
         put "https://gist.github.com/hofmannsven/6814451" into someURL
         break
   end switch
   
   launch url someURL
end menu_BranchDocumentation

on submenu_Dev
   return "Dev | menu"
end submenu_Dev


--> Dev | menu
-
on _ViewBranches gitFolder, menuChoice 
   switch menuChoice
      case "Local branches"
         put "git branch" into someShell
         break
      case "Local and remote brances"
         put "git branch -a" into someShell
         break
   end switch
   
   put _executeGit (someShell)  into shellResult
   display_Index shellResult
end _ViewBranches
