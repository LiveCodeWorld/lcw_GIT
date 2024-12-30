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

getprop menu_CheckTarget [sObject]
   put env_ProjectIsActive ("lcw_GIT") into gitIsActive
   return gitIsActive
end menu_CheckTarget

getprop disabled_LaunchGithub [sObject]
   if env_ProjectIsActive ("lcw_GIT") then
      return false
   else
      return "delete"
   end if
end disabled_LaunchGithub

getprop disabled_UpdateAndPush
   -- should check it is on gitHub and needs saving?
   return false
end disabled_UpdateAndPush


--> Global | GIT | Simple | Object | Menu
-
on menu_UpdateAndPush sObject
   ask_PushGithub sObject
end menu_UpdateAndPush

on _
end _

on menu_LaunchGithub sObject
   put the github_URL of sObject into someURL
   launch url someURL
end menu_LaunchGithub

on menu_StackHistory sObject
   display_StackHistory sObject
end menu_StackHistory

on menu_DisplayGitStatus sObject
   display_GitStatus sObject
end menu_DisplayGitStatus
