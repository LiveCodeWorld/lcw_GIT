script "lib_GithubUrl"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_GithubUrl
type: library
version: 0.1


--> Display
-
function stack_IsLoaded stackName, pWhich
   -- pWhich defaults to "application"
   get revLoadedStacks (pWhich)
   return stackName is among the lines of it
end stack_IsLoaded

command display_GithubStack
   lcw_AnswerStack "Choose a stack..."
   put the result into sPath
   --
   ghurl_GoRaw sPath
end display_GithubStack

command ghurl_Go stackName
   if exists (stack stackName) then
      put the effective filename of stack stackName into sPath
      delete stack stackName
   else
      return "Error, stack does nto exists:" && stackName
   end if
   
   -- put stack_IsLoaded (sName, pWhich) -- a check
   
   -- put ghurl_UrlFromShortFile (shortFile, pProjectName) into gURL
   -- go to stack url gURL
   -- return the result
end ghurl_Go

getprop ghurl_StackUrl [pOrgName]
   put the effective filename of the defaultstack into sPath
   if sPath is empty then return empty
   --
   put ghurl_FromPath (sPath, pOrgName) into ghURL
   return ghURL
end ghurl_StackUrl

command ghurl_GoController sName
   if there is a stack sName then
      if the platform is web then
         go to stack sName
         return the result
      else
         # Remove from Memory
         delete stack sName
         --
         put ghurl_ControllerURL (sName) into ghURL
         go to stack url ghURL
         put the result into goResult
         return goResult
      end if
   else
      go to stack url ghurl_ControllerURL (sName)
      put the result into goResult
      -- tsneterr: HTTP response code 404 returned from server
      return goResult
   end if
end ghurl_GoController


--> Props
-
getprop ghurl_ControllerUrl
   breakpoint -- use "ghurl_UrlFromShortFile" ???
   
   put the fileName of the defaultstack into sFile
   if sFile is empty then return empty
   set the itemdelimiter to slash
   put item -1 of sFile into shortFile
   
   put ghurl_ConstructUrl (shortFile, "lcw_Controllers", "stacks", pOrgName) into sURL
   return sURL
end ghurl_ControllerUrl

getprop ghurl_DepUrls
   breakpoint 
   put the env_PathArray of the target into dArray
   put ghurl_ListRawUrls (dArray) into ghURLs -- change raw
   return ghURLs
end ghurl_DepUrls

getprop init_Url 
   put the project_Name of the target into pName
   put "init.livecodescript" into shortFile
   return ghurl_UrlFromShortFile (shortFile, pName)
end init_Url

getprop ghurl_Url [pShortFilePath]
   if pShortFilePath is empty then
      put "index.html" into pShortFilePath
   end if
   put the project_Name of the target into pName
   return ghurl_UrlFromShortFile (pShortFilePath, pName)
end ghurl_Url

function ghurl_FromPath sPath, pOrgName
   put env_RelativePath (sPath) into envPath
   put ghurl_UrlFromEnvPath (envPath, pOrgName) into ghURL
   return ghURL
end ghurl_FromPath

function ghurl_UrlFromEnvPath envPath, pOrgName
   put ghurl_BaseUrl (pOrgName) into gURL
   put envPath after gURL
   return gURL
end ghurl_UrlFromEnvPath

function ghurl_UrlFromShortFile shortFile, projectName
   put "https://livecodeworld.github.io/" into gURL
   put projectName & slash after gURL
   put shortFile after gURL
   return gURL
end ghurl_UrlFromShortFile

function ghurl_ConstructUrl shortFile, projectName, folderName, pOrgName
   -- https://livecodeworld.github.io/lcw_Controllers/stacks/hello.livecodescript
   put env_ConstructProjectPath (projectName, folderName, shortFile) into envPath
   put ghurl_UrlFromEnvPath (envPath, pOrgName) into sURL
   return sURL
end ghurl_ConstructUrl


--> Working on
-
command github_Go stackName, pRepoName
   if exists (stack stackName) is false then
      return "Error, stack does not exist:" && stackName
   end if
   
   put the filename of stack stackName into sPath
   if sPath is empty then
      return "Error, stack does not have a path:" && stackName
   end if
   
   ghurl_GoRaw sPath, pRepoName
   get the filename of stack stackName
   return the result
end github_Go

function ghurl_ControllerURL sName, pOrgName
   -- put "https://" & pOrgName & ".github.io/lcw_Controllers/" into sURL
   
   set the itemdelimiter to "."
   put tolower (item 1 of sName) & ".livecodescript" into shortFile
   put ghurl_ConstructUrl (shortFile, "lcw_Controllers", "stacks", pOrgName) into sURL
   return sURL
end ghurl_ControllerURL

private function _ProjectUrl projectName, pOrgName
   put ghurl_BaseUrl (pOrgName) into gURL
   put projectName & slash after gURL
   return gURL
end _ProjectUrl

function ghurl_UrlFromShortFile shortFile, projectName, pOrgName
   put _ProjectUrl (projectName, pOrgName) into gURL
   put shortFile after gURL
   return gURL
end ghurl_UrlFromShortFile

function ghurl_BaseUrl pOrgName
   if pOrgName is empty then put "livecodeworld" into pOrgName
   return "https://" & pOrgName & ".github.io/"
end ghurl_BaseUrl


--> Github | Url
-
function ghurl_BaseUrl pOrgName
   if pOrgName is empty then 
      put "LiveCodeWorld" into pOrgName
   end if
   return "https://github.com/" & pOrgName & "/"
end ghurl_BaseUrl

function ghurl_FetchController sName
   put ghurl_ControllerURL (sName) into ghURL
   get url ghURL
   return it
end ghurl_FetchController

function ghurl_ControllerFromShortFile shortFile
   get "https://livecodeworld.github.io/lcw_Controllers/stacks/"
   return it & shortFile
end ghurl_ControllerFromShortFile


--> Ghurl | Raw
-
command ghurl_GoRaw sPath, pOrgName
   if the platform is "web" then return "Error"
   
   if there is a stack sPath then
      if the platform is web then
         # Go locally
         go to stack sPath
         return the result
      else
         # Remove from memory
         delete stack sPath
         
         # Go
         put ghurl_RawFromPath (sPath, pOrgName) into ghURL
         go to stack url ghURL
         return the result
      end if
   else
      put ghurl_RawFromPath (sPath, pOrgName) into ghURL
      go to stack url ghURL
      return the result
   end if
end ghurl_GoRaw

function ghurl_RawFromPath sPath, pOrgName
   -- https://github.com/LiveCodeWorld/lcw_Wiki/raw/refs/heads/master/modules/View_Wiki_Panel/View_Wiki_Panel.livecode
   if the platform is "web" then return "Error"
   
   put ghurl_BaseUrl (pOrgName) into ghBaseURL
   put env_RelativePath (sPath) into relPath
   put ghurl_RawUrl (pName, relPath, ghBaseURL) into ghURL
   return ghURL
end ghurl_RawFromPath

function env_RelativePath sPath, pRoot
   if pRoot is empty then
      put env_GetRepoFolder() into pRoot
   end if
   
   if sPath begins with pRoot then
      set the itemdelimiter to slash
      put the number of items of pRoot + 1 into rootNum
      put item rootNum to -1 of sPath into relPath
      return relPath
   else
      return empty
   end if
end env_RelativePath

-- function env_RelativePath sPath
   put env_GetRepoFolder() into repoFolder
   set the itemdelimiter to slash
   put the number of items of repoFolder + 1 into pNum
   put item pNum of sPath into pName
   put item (pNum+1) to -1 of sPath into rGitPath
   return rGitPath
end env_RelativePath

function ghurl_ListRawUrls dArray
   put ghurl_BaseUrl() into ghBaseURL
   --
   set the itemdelimiter to slash
   repeat for each key sName in dArray
      put dArray [sName] into envPath
      put item 1 of envPath into pName
      put item 2 to -1 of envPath into rPath
      put ghurl_RawUrl (pName, rPath, ghBaseURL) into ghURL
      put ghURL & CR after ghURLs
   end repeat
   delete char -1 of ghURLs
   return ghURLs
end ghurl_ListRawUrls

function ghurl_RawUrl projectName, rGitPath, ghBaseURL
   put ghBaseURL & projectName into ghURL
   put "/raw/refs/heads/master/" after ghURL
   put rGitPath after ghURL
   return ghURL
end ghurl_RawUrl

function ghurl_RawControllerUrl shortFile
   -- No CORS
   put "lcw_Controllers" into pName
   --
   put ghurl_BaseUrl() into ghBaseURL
   put "stacks/" & shortFile into rGitPath
   put ghurl_RawUrl (pName, rGitPath, ghBaseURL) into ghURL
   --
   return ghURL
end ghurl_RawControllerUrl


--> Deps
-
function env_ConstructProjectPath projectName, folderName, shortFile
   put projectName & "/" & folderName & "/" & shortFile into envPath
   return envPath
end env_ConstructProjectPath

function env_GetRepoFolder
   put env_GetLcwFolder() into pLcwFolder
   --
   set the itemdelimiter to slash
   delete item -1 of pLcwFolder
   return pLcwFolder
end env_GetRepoFolder

function env_GetLcwFolder
   if exists (stack "LCW") is false then
      put the filename of me into sPath
      return env_FolderFromPath (sPath)
   else
      get the filename of stack "LCW"
      set the itemdelimiter to slash
      put item 1 to -2 of it & slash into lcwFolder
      return lcwFolder
   end if
end env_GetLcwFolder

function env_RelativeFolder sPath, pRootPath
   if pRootPath is empty then
      put env_GetRepoFolder() into pRootPath
   else
      text_AddTrailing pRootPath, slash
   end if
   
   if sPath begins with pRootPath then
      put the number of chars of pRootPath into endNum
      return char (endNum + 1) to -1 of sPath
   else
      return empty
   end if
end env_RelativeFolder

function env_FolderFromPath sPath, pRootName
   -- works for any stack within the LiveCodeWorld repo
   if pRootName is empty then put "LivecodeWorld" into pRootName
   
   set the itemdelimiter to slash
   put itemOffset (pRootName, sPath) into itemNum
   if itemNum = 0 then return empty
   put item 1 to itemNum of sPath & slash into envFolder
   return envFolder
end env_FolderFromPath
