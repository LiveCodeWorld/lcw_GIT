script "lib_GithubUrl"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_GithubUrl
type: library
version: 0.1


--> Props
-


--> Working on
-
-- command ghurl_GoProjectStack sName, pName
if exists (stack stackName) is false then
   return "Error, stack does not exist:" && sName
end if

put stack_ConstructShortFile (sName, pExtension) into shortFile
put ghurl_BaseUrl() into ghBaseURL
put ghurl_RawUrl (pName, rGitPath, ghBaseURL) into ghURL
return ghURL
end ghurl_GoProjectStack


--> Ghurl | Go
-
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

function ghurl_ControllerURL stackName, pOrgName
   -- assume short file is lower case
   -- https://livecodeworld.github.io/lcw_Controllers/stacks/hello.livecodescript   
   if pOrgName is empty then
      put "livecodeworld" into pOrgName
   else
      put tolower (pOrgName) into pOrgName
   end if
   put "https://" & pOrgName & ".github.io/lcw_Controllers/" into sURL
   
   put _RelativePath (stackName) after sURL
   return sURL
end ghurl_ControllerURL
   
function ghurl_RawControllerUrl stackName
   -- No CORS
   put "lcw_Controllers" into pName
   --
   put ghurl_BaseUrl() into ghBaseURL
   put _RelativePath (stackName) into rGitPath
   put ghurl_RawUrl (pName, rGitPath, ghBaseURL) into ghURL
   --
   return ghURL
end ghurl_RawControllerUrl

function _RelativePath sName
   put _ShortFile (sName) into shortFile
   put "stacks/" & shortFile into rGitPath
   return rGitPath
end _RelativePath

function _ShortFile sName
   set the itemdelimiter to "."
   put tolower (item 1 of sName) & ".livecodescript" into shortFile
   return shortFile
end _ShortFile

function ghurl_ListDepUrls dArray
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
end ghurl_ListDepUrls

function ghurl_RawUrl projectName, rGitPath, ghBaseURL
   put ghBaseURL & projectName into ghURL
   put "/raw/refs/heads/master/" after ghURL
   put rGitPath after ghURL
   return ghURL
end ghurl_RawUrl


--> Deps
-
