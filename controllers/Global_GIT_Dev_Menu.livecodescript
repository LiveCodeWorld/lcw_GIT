script "Global | GIT | Dev | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | GIT | Dev | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   _InitLocalArray tObject
   return LocalArray ["gitFolder"]
end menu_Target

private command _InitLocalArray tObject
   put the display_View of tObject into dView
   put the git_SettingsModel of dView into LocalArray
   return dView
end _InitLocalArray

getprop disabled_Branch [gitFolder]
   if there is a folder gitFolder then
      return false
   else
      return true
   end if
end disabled_Branch


--> Global | GIT | Dev | Menu
-
on submenu_Branch
   return "Global | GIT | Branch | Menu"
end submenu_Branch

on submenu_Stash
   return "Global | GIT | Stash | Menu"
end submenu_Stash

on submenu_Tag
   return "Global | GIT | Tag | Menu"
end submenu_Tag

on _
end _

on submenu_Git
   return "Global | GIT | Menu"
end submenu_Git

-- on submenu_GitFiles
return "Global | GIT | Files | Menu"
end submenu_GitFiles

on submenu_GitProjects
   return "Global | GIT | Folder | Menu"
end submenu_GitProjects

-- on submenu_GitSettings
return "Global | GIT | Settings | Menu"
end submenu_GitSettings

on _
end _

on submenu_GitScript
   return "Global | GIT | Script | Menu"
end submenu_GitScript

on submenu_Gist
   return "Global | Gist | Menu"
end submenu_Gist

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on _CompactGit
   put "git gc" into someShell
   put git_ExecuteShellCommand (someShell) into shellResult
   lcw_Notify shellResult, true
end _CompactGit

on _DisplayStatusReport gitFolder
   git_DisplayStatusLines gitFolder
end _DisplayStatusReport

on _DisplayCommitHistory gitFolder
   display_GitCommitHistory gitFolder
end _DisplayCommitHistory

on _ListTrackedFiles gitFolder
   -- lists all of the already committed files being tracked by your git repo.
   -- https://stackoverflow.com/questions/8533202/list-files-in-local-git-repo
   
   put "git ls-tree --full-tree -r HEAD" into someShell
   put shell_ExecuteAtRoot (someShell, gitFolder) into shellResult
   --
   display_Index shellResult, "git ls-tree"
end _ListTrackedFiles

on _ListCommits gitFolder
   put git_ListCommitHashes (gitFolder)
end _ListCommits

on _DisplayGitProjectArray
   put git_GetProjectArray() into gitProjectArray
   display_Array gitProjectArray
end _DisplayGitProjectArray
