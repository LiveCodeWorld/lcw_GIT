script "Global | Github | Update | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Github | Update | Line | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Events
-
on mDoubleUp_GithubUpdate dView, projectName
   if env_ProjectIsActive (projectName) is false then
      project_Start projectName
      display_Environment true
   end if
   display_Project projectName
   --
   menu_Xterm dView
end mDoubleUp_GithubUpdate


--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget

private function _HomeStackPath dView
   -- put _HomeStackPath (dView) into stackPath
   -- display_ModuleTools stackPath
   
   put the selected_Line of dView into projectName
   put env_ProjectFolder (projectName) into projectFolder
   put project_PathFromFolder (projectFolder) into projectHomePath
   return projectHomePath
end _HomeStackPath


--> Global | Github | Update | Line | Menu
-
on menu_GitStatus dView
   put the selected_Line of dView into projectName
   put the project_Folder of stack projectName into gitFolder
   --
   display_GitFolderStatus gitFolder
end menu_GitStatus

on menu_AddEeverything dView
   put the selected_Line of dView into projectName
   put the project_Folder of stack projectName into gitFolder
   --
   git_AddEverything gitFolder
end menu_AddEeverything

on menu_Xterm dView
   put the selected_Line of dView into projectName
   put the project_Folder of stack projectName into gitFolder
   --
   put xterm_FindView() into xtermBrowser
   display_XtermAtFolder gitFolder, "git status", xtermBrowser
end menu_Xterm

on menu_AddToGithub dView
   put the selected_Line of dView into projectName
   put the project_Folder of stack projectName into sFolder
   --
   put "cd" && kwote (sFolder, "'") into someShell
   put ";" && merge ("gh repo create LiveCodeWorld/[[projectName]] --public --source=. --push") after someShell
   --
   put xterm_FindView() into xtermBrowser
   display_Xterm someShell, xtermBrowser
end menu_AddToGithub

private on _
end _

on menu_DisplayProject dView
   put the selected_Line of dView into projectName
   --
   display_Project projectName
end menu_DisplayProject

on menu_DisplayProjectArray dView
   put the selected_Line of dView into projectName
   --
   display_ProjectArray projectName, false
end menu_DisplayProjectArray

on menu_Behavior dView
   put the behavior of dView into bObject
   edit the script of bObject
end menu_Behavior

on menu_ModuleTools dView
   put the view_Name of dView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Github | Update | Line | Menu")
end submenu_Dev
