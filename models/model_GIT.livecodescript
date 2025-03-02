﻿script "model_GIT"
--> MetaData
-
license: GPLv3
name: model_GIT
type: model
version: 0.2

/*
*/


--> Working on
-

--> Git | Init
-
function git_GetInit repoName
   -- put the git_Folder of stack projectName into gitFolder
   -- put git_GetCheckoutFolder (repoFolder) into repoRootFolder
   
   put git_InvisibleFolder (repoName) into gitInvisibleFolder
   return gitInvisibleFolder is not empty
end git_GetInit

command git_SetInit repoFolder
   put the defaultfolder into oDefault
   set the defaultfolder to repoFolder
   --
   put git_PathToCommandLine() into gitPath
   put gitPath & "git init" into someShell
   put shell (someShell) into sResult
   --
   set the defaultfolder to oDefault
   return sResult
end git_SetInit

command git_InitFolder gitRootFolder, pDontAdd
   put the defaultfolder into oDefault
   set the defaultfolder to gitRootFolder
   
   git_AddIgnore gitRootFolder
   
   git_SetInit repoFolder
   put the result into shellResult
   lcw_Notify shellResult
   
   get word 1 to 5 of shellResult
   if it is not "Initialized empty Git repository in" and it is not "Reinitialized existing Git repository in" then
      lcw_Notify shellResult
      set the defaultfolder to oDefault
      exit to top
   end  if
   
   if pDontAdd is not true then
      git_AddEverything gitRootFolder
      put the result into shellResult
      if shellResult is not empty then
         lcw_Notify shellResult
         breakpoint
         -- exit to top
      end if
   end if
   
   -- git_SetRootFolder gitRootFolder
   git_AddRootFolderToIndex gitRootFolder
   
   set the defaultfolder to oDefault
   return gitRootFolder
end git_InitFolder

command git_AddIgnore gitRootFolder
   text_AddTrailing gitRootFolder, slash
   put ".DS_Store" into gitIgnoreText
   put gitIgnoreText into url ("file:" & gitRootFolder & ".gitignore")
end git_AddIgnore

command git_RemoveDsStore
   put "find . -name .DS_Store -print0 | xargs -0 git rm -f --ignore-unmatch" into someShell
end git_RemoveDsStore


--> GIT | Folders
-
getprop git_Folder
   put the mainstack_File of the target into somePath
   try
      -- if git is installed
      put git_GetCheckoutFolder (somePath) into repoRootFolder
   catch e
      put git_FindCheckoutFolder (somePath) into repoRootFolder
   end try
   return repoRootFolder
end git_Folder

function git_InvisibleFolder repoName
   put git_ConstructInvisibleFolder (repoName) into gitFolder
   if there is not folder gitFolder then return empty
   return gitFolder
end git_InvisibleFolder

function git_ConstructInvisibleFolder repoName
   put repoName & "/.git/" into rGitPath
   put env_GetRepoFolder (rGitPath) into gitFolder
   return gitFolder
end git_ConstructInvisibleFolder

function git_GetRootFolder
   -- should make optional as git should be accessible using shell without exact path.
   -- used to get "git_CommitHash" for "github_GetPermalink"
   put pref_GetValue ("gitRootFolder") into gitRootFolder
   if gitRootFolder is empty then
      put env_GetRepoFolder() into gitRootFolder
   end if
   return gitRootFolder
end git_GetRootFolder

getprop git_RelativeFolder
   -- relative to GitHub = LivecodeWorld directory (env home)
   put the git_Folder of the target into gitFolder
   --
   put env_GetRepoFolder() into baseFolder
   file_SetRelativePath gitFolder, baseFolder
   return gitFolder
end git_RelativeFolder


--> GIT | Folders | Old
-
function git_FindDotGitFolder someFile
   if someFile is empty then return false
   
   put someFile into folderAbove
   set the itemdelimiter to "/"
   put the directory into oDirectory
   repeat
      delete item -1 of folderAbove
      if folderAbove is empty then exit repeat
      
      set the directory to folderAbove
      put the folders into shortFolders
      if ".git" is among the lines of shortFolders then
         set the directory to oDirectory
         return folderAbove & "/.git"
      end if
   end repeat
   set the directory to oDirectory
   return empty
end git_FindDotGitFolder

function git_FindCheckoutFolder somePath
   -- slightly faster then "git_GetCheckoutFolder" (2 ticks)
   put git_FindDotGitFolder (somePath) into checkoutFolder
   set the itemdelimiter to slash
   delete item -1 of checkoutFolder
   return checkoutFolder
end git_FindCheckoutFolder

function git_GetCheckoutFolder pFolderOrFile
   -- relies on git installed globallly
   put the defaultFolder into oFolder
   if pFolderOrFile is empty then
      put the defaultFolder into pFolderOrFile
   else
      if there is a file pFolderOrFile then
         set the itemdelimiter to "/"
         delete item -1 of pFolderOrFile
      end if
      set the defaultFolder to pFolderOrFile
   end if
   
   put shell ("git rev-parse --show-cdup") into shellResult
   
   set the itemdelimiter to ":"
   if item 1 of shellResult = "fatal" then
      set the defaultFolder to oFolder
      return empty
   end if
   
   put word 1 to -1 of shellResult into someChars
   put the number of chars of someChars/3 into upCount
   
   set the itemdelimiter to "/"
   put -1 - upCount into minusItem
   put (item 1 to minusItem of pFolderOrFile) into gitRootFolder
   put "/" after gitRootFolder
   
   set the defaultFolder to oFolder
   return gitRootFolder
end git_GetCheckoutFolder


--> Git | Folder
-
command git_SetRootFolder gitRootFolder
   breakpoint -- not meaningful
   folder_Format gitRootFolder
   pref_SetValue "gitRootFolder", gitRootFolder
   return the result
end git_SetRootFolder

command git_AddRootFolderToIndex gitRootFolder, pProjectName
   put git_GetCheckoutFolder (gitRootFolder) into gitRootFolder
   if gitRootFolder is empty then return "Error:  folder is not within a git repository"
   
   if pProjectName is empty then
      set the itemdelimiter to "/"
      put item -1 of gitRootFolder into pProjectName
   end if
   put git_GetProjectArray() into gitProjectArray
   put pProjectName into gitProjectArray [gitRootFolder]["project name"]
   git_SetProjectArray gitProjectArray
   return empty
end git_AddRootFolderToIndex

function git_ListProjectFolders
   put git_GetProjectArray() into gitProjectArray
   put keys(gitProjectArray) into folderIndex
   return folderIndex
end git_ListProjectFolders

command git_RemoveProject gitRootFolder
   put git_GetProjectArray() into gitProjectArray
   delete variable gitProjectArray [gitRootFolder]
   return keys(gitProjectArray)
end git_RemoveProject

getprop git_IsActive
   put the effective filename of the stack_Object of the target into someFile
   put git_GetActiveStatus (someFile) into someBoolean
   return someBoolean
end git_IsActive

function git_GetActiveStatus someFile
   put git_GetCheckoutFolder (someFile) into checkoutFolder -- uses GIT to check things (3 ticks)
   put checkoutFolder is not empty into someBoolean
   return checkoutFolder is not empty
end git_GetActiveStatus


--> Props
-
getprop git_Project
   put the git_Folder of the target into gitRootFolder
   put git_GetProjectArray() into gitProjectArray
   put gitProjectArray [gitRootFolder]["project name"] into projectName
   return projectName
end git_Project


--> Git | Ignore
-
getprop git_IgnoreFile
   -- a project .gitingore file
   put the project_Folder of the target into projectFolder
   put git_LocalIgnoreFile (projectFolder) into localIgnoreFile
   return localIgnoreFile 
end git_IgnoreFile

function git_LocalIgnoreFile projectFolder
   text_AddTrailing projectFolder, slash
   put projectFolder & ".gitignore" into localIgnoreFile
   return localIgnoreFile
end git_LocalIgnoreFile

function git_GlobalIgnoreFile
   put $HOME & "/.gitignore" into ignoreFile
   return ignoreFile
end git_GlobalIgnoreFile

command git_CreateLocalIgnoreFile projectFolder, pIgnoreType
   put git_LocalIgnoreFile (projectFolder) into ignoreFile
   --
   git_CreateIgnoreFile ignoreFile, pIgnoreType
   --
   put the result into shellResult
   return shellResult
end git_CreateLocalIgnoreFile

command git_CreateGlobalIgnoreFile pIgnoreType
   put git_GlobalIgnoreFile() into ignoreFile
   --
   git_CreateIgnoreFile ignoreFile, pIgnoreType
   --
   put the result into shellResult
   return shellResult
end git_CreateGlobalIgnoreFile

command git_CreateIgnoreFile ignoreFile, pIgnoreType
   -- very old (might be wrong or no longer relevant)
   put "binfile:" & ignoreFile into someUrl
   put ignoreText into url someUrl
   --
   put ignoreFile into bashFile
   shell_BashParamEscape bashFile
   if pIsGlobal is true then
      put "git config --global core.excludesfile" && bashFile into someShell
   else
      put "touch" & bashFile into someShell
   end if
   git_ExecuteShell someShell
   return the result
end git_CreateIgnoreFile

function git_ConstructIgnoreText pIgnoreType
   switch pIgnoreType
      case "LF"
         put "*.gitignore" & LF after ignoreText
         -- put "*.DS_Store" & LF after ignoreText
         -- put "*.svn/*" & LF after ignoreText
         --put "opn_Plugins/opn_Third/*" & lineEnding after ignoreText
         return ignoreText
      default -- case "CR"
         put "*.gitignore" & LF after ignoreText
         put "*.DS_Store" & CR after ignoreText
         put ".svn*" & CR after ignoreText
         put "*.gitignore" & CR after ignoreText
         -- put "opn_Plugins/opn_Third/*" & lineEnding after ignoreText
         return ignoreText
   end switch
end git_ConstructIgnoreText


--> Props
-
getprop git_ShortFolder
   -- could use git_GetProject() for a "name"
   put the git_Folder of the target into gitFolder
   if gitFolder is empty then return empty
   
   set the itemdelimiter to slash
   put item -1 of gitFolder into gitShortFolder
   return gitShortFolder
end git_ShortFolder

getprop git_WithinCheckoutFolder [pDontUseGit]
   -- checks the script file ???
   -- always in git?
   put the script_File of the target into someFile
   if pDontUseGit is true then
      put git_FindDotGitFolder (someFile) into checkoutFolder -- slightly faster (2 ticks)
   else
      put git_GetCheckoutFolder (someFile) into checkoutFolder -- uses GIT to check things (3 ticks)
   end if
   return checkoutFolder is not empty
end git_WithinCheckoutFolder

function git_Version
   git_ExecuteShell "git --version"
   put word 3 of the result into someVersion
   return someVersion
end git_Version


--> Git | Model
-
function git_GetProjectArray
   put lcw_FetchArray ("GitProjectArray.array") into gitProjectArray
   return gitProjectArray
end git_GetProjectArray

command git_SetProjectArray gitProjectArray
   lcw_StoreArray "GitProjectArray.array", gitProjectArray
end git_SetProjectArray

function git_GetProject pGitRootFolder
   if pGitRootFolder is empty then put git_GetRootFolder() into pGitRootFolder
   put git_GetProjectArray() into gitProjectArray
   put gitProjectArray [gitRootFolder]["project name"] into projectName
   return projectName
end git_GetProject

command git_SetProject projectName
   breakpoint
   put git_TranslateProjectName (projectName) into longGitFolder
   git_SetRootFolder longGitFolder
   return longGitFolder
end git_SetProject


--> Git | Files
-
command git_SetRelativePath @fileOrFolder
   if char 1 of fileOrFolder is not "/" then return false
   put git_GetRootFolder() into baseFolder
   file_SetRelativePath fileOrFolder, baseFolder
   shell_BashParamEscape fileOrFolder
   return true
end git_SetRelativePath

command git_SetFullPath @relativeFileOrFolder
   if char 1 of fileOrFolder is "/" then return false
   put git_GetRootFolder() into baseFolder
   put baseFolder & relativeFileOrFolder into relativeFileOrFolder
   return true
end git_SetFullPath

function git_PathToCommandLine
   return empty
   
   put pref_GetValue ("gitPath") into gitPath
   return gitPath
   
   -- put "/opt/local/bin/" into gitPath
   return gitPath
end git_PathToCommandLine


--> Git | Model | Deps
-
function git_TranslateProjectName projectName
   put git_GetProjectArray() into gitProjectArray
   repeat for each key gitFolder in gitProjectArray
      if projectName = gitProjectArray [gitFolder]["project name"] then
         return gitFolder
      end if
   end repeat
   return empty
end git_TranslateProjectName
