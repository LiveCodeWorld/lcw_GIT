script "model_GitHub"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_GitHub
type: model
version: 0.1


--> Working on
-

--> GH
-
function gh_UrlFromRepo pRepoName
   put gh_FetchRepoArray (pRepoName) into repoArray
   put repoArray ["git_url"] into gitURL
   text_AddTrailing ghURL, slash
   return ghURL
end gh_UrlFromRepo

function gh_ExtractHtmlUrl repoArray
   put repoArray ["html_url"] into githubURL
   return githubURL
end gh_ExtractHtmlUrl

command gh_DeconstructRepoArray repoArray, @remoteAddress, @htmlURL, @cloneURL, @gitURL
   put repoArray ["clone_url"] into cloneURL
   put repoArray ["git_url"] into gitURL
   put repoArray ["html_url"] into htmlURL
   put repoArray ["ssh_url"] into remoteAddress
end gh_DeconstructRepoArray

function gh_FetchRepoArray repoName, pOwner
   if pOwner is empty then put "LiveCodeWorld" into pOwner
   put merge ("/repos/[[pOwner]]/[[repoName]]") into restPath
   --
   put github_RestGet (restPath, repoName) into someJSON
   put json_ToArray (someJSON) into repoArray
   return repoArray
end gh_FetchRepoArray


--> Props
-
getprop github_ModuleUrl
   put the module_Name of the target into moduleName
   if moduleName is empty then return empty
   
   put the project_Name of the target into projectName
   put github_ConstructModuleUrl (moduleName, projectName) into githubURL
   return githubURL
end github_ModuleUrl

getprop github_ProjectURL [repoName]
   put the project_Name of the target into projectName
   if repoName is empty then put "LiveCodeWorld" into repoName
   put merge ("https://github.com/[[repoName]]/[[projectName]]/") into someURL
   return someURL
end github_ProjectURL

getprop github_LaunchURL
   put the stack_Name of the target into stackName
   put github_ConstructLaunchUrl (stackName) into githubURL
   return githubURL
end github_LaunchURL


--> Github | Behavior
-
function github_RawModuleBehaviorUrl shortFile, moduleName, projectName
   -- https://github.com/LiveCodeWorld/lcw_Wiki/raw/refs/heads/master/modules/View_Guide/behaviors/behavior_ViewGuide.livecodescript
   put label_ShortModuleFolderFromName (moduleName) into shortModuleFolder
   put github_ConstructModuleBehaviorUrl(shortFile, shortModuleFolder, projectName) into githubURL
   return githubURL
end github_RawModuleBehaviorUrl

function github_ConstructModuleBehaviorUrl shortFile, shortModuleFolder, projectName
   put github_RawModulesUrl (moduleName, projectName) into githubURL
   put shortModuleFolder & slash after githubURL
   put "behaviors/" & shortFile after githubURL
   return githubURL
end github_ConstructModuleBehaviorUrl

function github_RawModulesUrl moduleName, projectName
   -- https://github.com/LiveCodeWorld/lcw_Wiki/raw/refs/heads/master/modules/View_Guide/behaviors/behavior_ViewGuide.livecodescript
   put "https://github.com/" into githubURL
   put "LiveCodeWorld" into orgName
   --
   put orgName & slash after githubURL
   put projectName & slash after githubURL
   put "raw/refs/heads/master/modules/" after githubURL
   return githubURL
end github_RawModulesUrl

function github_BehaviorUrlFromName bName, stackFileRoot, stackFileArray
   put stackFile_PathFromName (bName, stackFileRoot, stackFileArray) into sPath
   --
   put file_GetShort (sPath) into shortFile
   put env_ProjectNameFromPath (sPath) into projectName
   put env_ModuleNameFromPath (sPath) into shortModuleFolder
   put github_ConstructModuleBehaviorUrl (shortFile, shortModuleFolder, projectName) into githubURL
   return githubURL
end github_BehaviorUrlFromName

function github_ConstructBehaviorUrl shortFile, moduleName, projectName
   -- https://github.com/LiveCodeWorld/lcw_Wiki/blob/master/modules/View_Guide/behaviors/behavior_ViewGuide.livecodescript
   put "https://github.com/" into githubURL
   put "LiveCodeWorld" into orgName
   --
   put orgName & slash after githubURL
   put projectName & slash after githubURL
   put "blob/master/modules/" after githubURL
   
   put label_ShortModuleFolderFromName (moduleName) into shortModuleFolder
   put shortModuleFolder & slash after githubURL
   --
   put shortFile & slash after githubURL
   return githubURL
end github_ConstructBehaviorUrl


--> Old
-
function github_TransportURL shortFile, pRepoName   
   -- need to switch stacks for .lc scripts
   -- https://github.com/LiveCodeWorld/lcw_Controllers
   -- /blob/master/
   -- controllers/ward.lc
   
   put ghurl_BaseUrl (pRepoName) into githubURL
   put "/lcw_Controllers/blob/master/controllers/" & shortFile into relPath
   put relPath after githubURL
   return githubURL
end github_TransportURL

command gitHub_GoModule moduleName
   # Save and Remove from memory
   if exists (stack moduleName) then
      # Raw Github url
      put the github_ModuleUrl of stack moduleName into rawURL
      if rawURL is empty then return "Error, cannot locate module:" && moduleName
      
      breakpoint
      save stack moduleName
      set the destroyStack of stack moduleName to true
      set the destroyWindow of stack moduleName to true
      delete stack moduleName
   else
      put "lcw_Lexon" into projectName
      put github_ConstructModuleUrl (moduleName, projectName) into rawURL
   end if
   
   # Go
   go to stack url rawURL
   put the result into goResult
   if goResult is not empty then
      lcw_Notify goResult
   end if
   return goResult
end gitHub_GoModule


--> Github | Go
-
command github_LaunchStack stackName, pRepoName
   if exists (stack stackName) is false then return empty
   --
   put github_GetUrl (stackName, pRepoName) into githubURL
   --
   launch url githubURL
   return githubURL
end github_LaunchStack

command github_LaunchTransport shortFile, pRepoName
   put github_TransportURL (shortFile, pRepoName) into githubURL
   launch url githubURL
end github_LaunchTransport


--> Github | URL
-
command github_Launch repoName, pPath
   put github_URLFromPath (pPath, repoName) into githubURL
   launch url githubURL
end github_Launch

function github_ConstructLaunchUrl stackName, pRepoName
   if exists (stack stackName) is false then return empty
   put the project_Name of stack stackName into repoName
   put github_GetUrl (stackName, pRepoName) into githubURL
   return githubURL
end github_ConstructLaunchUrl

function github_URLFromPath somePath, pRepoName
   -- https://github.com/LiveCodeWorld/lcw_Script
   -- /blob/master/
   -- libraries/lib_Help.livecodescript
   
   put env_GetRepoFolder() into repoFolder
   -- put git_FindCheckoutFolder (somePath) into checkoutFolder
   put git_GetCheckoutFolder(somePath) into checkoutFolder
   if checkoutFolder begins with repoFolder is false then return empty
   
   set the itemdelimiter to slash
   put the number of items of repoFolder + 1 into projectRootNum
   put item projectRootNum of somePath into projectName
   delete item 1 to projectRootNum of somePath
   --
   put ghurl_BaseUrl (pRepoName) & slash into githubURL
   put projectName & "/blob/master/" after githubURL
   put somePath after githubURL
   return githubURL
end github_URLFromPath


--> Github | URL
-
function github_GetHandlerURL sObject, pStartLineNum, pEndLineNum
   -- https://github.com/LiveCodeWorld/lcw_Help/blob/master/lcw_Help/controllers/Global_Hkey_Help_Menu.livecodescript#L100-L107
   
   -- https://github.com/LiveCodeWorld/lcw_Help/blob/master/controllers/Global_Hkey_Help_Menu.livecodescript#L100-L107
   -- https://github.com/LiveCodeWorld/lcw_Help/blob/c12756523cebcb314f79d5eacc1c890a8f85dede/controllers/Global_Hkey_Help_Menu.livecodescript#L100-L107
   
   put the project_Name of sObject into projectName
   put the github_RelativePath of sObject into relPath
   
   -- https://github.com/LiveCodeWorld/lcw_Help/blob/master/controllers/Global_Hkey_Help_Menu.livecodescript
   -- https://github.com/LiveCodeWorld/blob/master/lcw_Help/controllers/Global_Hkey_Help_Menu.livecodescript#L100-L107
   put merge ("https://github.com/LiveCodeWorld/[[projectName]]/blob/master/") & relPath into githubURL
   if pStartLineNum is not empty then
      put "#L" & pStartLineNum after githubURL
      put "-L" & pEndLineNum after githubURL
   end if
   return githubURL
end github_GetHandlerURL

function github_ConstructProjectUrl projectName
   -- https://github.com/LiveCodeWorld/lcw_Caddy/raw/master/lcw_Caddy.livecode
   put merge ("https://github.com/LiveCodeWorld/[[projectName]]/raw/master/[[projectName]].livecode") into someURL
   return someURL
end github_ConstructProjectUrl

function github_ConstructModuleUrl moduleName, projectName
   put "LiveCodeWorld" into orgName
   view_NormalizePiped moduleName
   put _ConstructShortFolder(moduleName) into shortModuleFolder
   put shortModuleFolder & ".livecode" into shortFile
   --
   put "https://github.com/" into githubURL
   --
   put orgName & slash after githubURL
   put projectName & slash after githubURL
   
   put "blob/master/modules/" after githubURL
   --
   put shortModuleFolder & slash after githubURL
   put shortFile & slash after githubURL
   --
   put "?raw=true" after githubURL
   return githubURL
end github_ConstructModuleUrl


--> Github | URL
-
function github_GetUrl stackName, pRepoName
   put the effective filename of stack stackName into stackPath
   put github_URLFromPath (stackPath, pRepoName) into githubURL
   return githubURL
end github_GetUrl

function github_ConstructRepoUrl pRepoName
   if pRepoName is empty then put "LiveCodeWorld" into pRepoName
   return "https://github.com/" & pRepoName
end github_ConstructRepoUrl


--> Private
-
private function _ConstructShortFile moduleName
   put _ConstructShortFolder(moduleName) into shortFolder
   put shortFolder & ".livecode" into shortFile
   return shortFile
end _ConstructShortFile

private function _ConstructShortFolder moduleName
   put moduleName into shortModuleFolder
   replace "|" with "_" in shortModuleFolder
   return shortModuleFolder
end _ConstructShortFolder
