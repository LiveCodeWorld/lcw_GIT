script "Global | GIT | Simple | Object | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | GIT | Simple | Object | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target
   put scriptEditor_Object() into sObject
   return sObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   pass menu_CheckTarget
end menu_CheckTarget

getprop disabled_LaunchGithub [sObject]
   if env_ProjectIsActive ("lcw_GIT") then
      return false
   else
      return "delete"
   end if
end disabled_LaunchGithub


--> Global | GIT | Simple | Object | Menu
-
on menu_LaunchGithub sObject
   put the github_URL of sObject into someURL
   launch url someURL
end menu_LaunchGithub

on menu_DisplayGitStatus sObject
   display_GitStatus sObject
end menu_DisplayGitStatus

on menu_UpdateAndPush sObject
   put lcw_Ask ("Comment on these changes...") into someComment
   set the cursor to watch
   --
   stack_SaveEdited "all"
   --
   put the git_Folder of sObject into gitFolder
   breakpoint
   git_AddEverything gitFolder  
   git_CommitChanges someComment, gitFolder
   --
   display_GitPushCurrentBranch gitFolder
end menu_UpdateAndPush
