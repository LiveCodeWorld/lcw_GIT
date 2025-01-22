script "model_GitMenu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: model_GitMenu
type: model
version: 0.1

/*
This model is for multiple menus sharing information about the current giFolder's project.
*/

--> Variables
-
local LocalArray


--> Working on
-
function git_GetMenuModel someKey
   return LocalArray [someKey]
end git_GetMenuModel

command git_ClearMenuModel dView
   delete variable LocalArray
   if exists (dView) is true then
      set the git_SettingsModel of dView to empty
   end if
end git_ClearMenuModel


--> GIT | Menu | Model | List
-
function github_ListOrgs pForce
   put _ListOrgs() into orgNames
   if pForce is true or orgNames is empty then
      git_InitOrgModel
      put _ListOrgs() into orgNames
   end if
   return orgNames
end github_ListOrgs

private function _ListOrgs
   put LocalArray ["orgsData"] into orgsData
   put github_ConstructOrgIndex (orgsData) into orgNames
   return orgNames
end _ListOrgs

function github_FindOrgArray orgName, orgsData
   repeat with itemNum = 1 to item 2 of the extents of orgsData
      put orgsData [itemNum] into orgArray
      put orgArray ["login"] into testName
      if testName = orgName then
         return orgArray
      end if
   end repeat
   return empty
end github_FindOrgArray

function github_ConstructOrgIndex orgsData
   -- LocalArray [orgsData][1][login]
   repeat with itemNum = 1 to item 2 of the extents of orgsData
      put orgsData [itemNum]["login"] into orgName
      put orgName & CR after orgNames
   end repeat
   delete char -1 of orgNames
   return orgNames
end github_ConstructOrgIndex

function github_OrgsData pForce
   put LocalArray ["orgsData"] into orgsData
   if pForce is true or orgsData is not an array then
      git_InitOrgModel
      put LocalArray ["orgsData"] into orgsData
   end if
   return orgsData
end github_OrgsData

function github_ListProjects pOrgName, pForce
   if pOrgName is empty then put "LivecodeWorld" into pOrgName
   
   put LocalArray ["Org"][pOrgName]["repoIndex"] into projectNames
   if pForce is true or projectNames is empty then
      git_InitOrgModel
      put LocalArray ["Org"][pOrgName]["repoIndex"] into projectNames
   end if
   return projectNames
end github_ListProjects


--> GIT | Menu | Model | Functions
-
function github_LivecodeWorldProjectExists repoName
   put LocalArray ["Org"][orgName]["repoIndex"] into repoIndex
   
   put github_ListOrgProjects() into lcwRepoNames
   put lcwRepoNames into LocalArray ["lcwRepoNames"]
   put projectName is among the lines of LocalArray ["lcwRepoNames"] into someBoolean
   return someBoolean
end github_LivecodeWorldProjectExists

function github_ListOrgProjects pOrgName
   if pOrgName is empty then put "LivecodeWorld" into pOrgName
   --
   put LocalArray ["Org"][pOrgName]["repoIndex"] into repoIndex
   if repoIndex is empty then
      git_InitOrgModel pOrgName
      put LocalArray ["Org"][pOrgName]["repoIndex"] into repoIndex
   end if
   --
   return repoIndex
end github_ListOrgProjects


--> GIT | Menu | Model
-
command git_InitMenuModel dView, projectName
   git_InitGlobalModel
   set the git_InitSettingsModel of dView to projectName
end git_InitMenuModel

command git_InitGlobalModel
   put lcw_ListMyGithubOrgs() into orgsData
   put orgsData into LocalArray ["orgsData"]
end git_InitGlobalModel

command git_InitOrgModel orgName
   put github_FetchOrgRepoAray (orgName) into orgRepoAray
   --
   put orgRepoAray into LocalArray ["Org"][orgName]["orgRepoAray"]
   put github_ListRepos (orgRepoAray) into LocalArray ["Org"][orgName]["repoIndex"]
end git_InitOrgModel

setprop git_InitSettingsModel projectName
   put the display_View of the target into dView
   if exists (dView) is false then return empty
   --
   put git_ConstructMenuModel (dView, projectName) into cArray
   set the git_SettingsModel of dView to cArray
   return cArray
end git_InitSettingsModel

function git_ConstructMenuModel dView, projectName, pOrgName
   if exists (stack projectName) is false then
      breakpoint
      return empty
   end if
   
   # Default Org
   if pOrgName is empty then put "LivecodeWorld" into pOrgName
   put pOrgName into cArray ["orgName"]
   
   # Basics
   put dView into cArray ["dView"]
   put projectName into cArray ["projectName"]
   
   # Folders
   put the git_Folder of stack projectName into gitFolder
   put the project_Folder of stack projectName into cArray ["projectFolder"]
   put gitFolder into cArray ["gitFolder"]
   
   # Essentials
   put git_LocalIgnoreFile (gitFolder) into ignoreFile
   put git_GetRemoteAddress (gitFolder) into cArray ["gitRemoteAddress"]
   put ignoreFile into cArray ["ignoreFile"]
   put there is a file ignoreFile into cArray ["localIgnoreExists"]
   
   return cArray
end git_ConstructMenuModel
