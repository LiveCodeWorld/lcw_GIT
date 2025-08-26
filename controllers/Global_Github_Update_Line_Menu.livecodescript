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
on doubleClick_Message dView, projectName
   if the optionKey is "Down" then breakpoint
   --
   if env_ProjectIsActive (projectName) is false then
      project_Start projectName
      display_Environment true
   end if
   --
   display_Project projectName
   display_GitProjectStatus projectName
   menu_Xterm dView
end doubleClick_Message


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
   put _ProjectFolder (dView) into projectFolder
   --
   put project_PathFromFolder (projectFolder) into projectHomePath
   return projectHomePath
end _HomeStackPath

private function _ProjectFolder dView
   put _ProjectName (dView) into projectName
   put the project_Folder of stack projectName into gitFolder
   return gitFolder
end _ProjectFolder

private function _ProjectName dView
   put the index_View of dView into indexView
   put the selected_Line of indexView into projectName
   return projectName
end _ProjectName


--> Global | Github | Update | Line | Menu
-
on menu_GitStatus dView
   put _ProjectFolder (dView) into gitFolder
   --
   display_GitFolderStatus gitFolder
end menu_GitStatus

on menu_AddEeverything dView
   put _ProjectFolder (dView) into gitFolder
   --
   git_AddEverything gitFolder
end menu_AddEeverything

private on _
end _

on menu_Xterm dView
   put _ProjectFolder (dView) into gitFolder
   --
   put xterm_FindView() into xtermBrowser
   display_XtermAtFolder gitFolder, "git status", xtermBrowser
end menu_Xterm

on menu_AddToGithub dView
   put _ProjectName (dView) into projectName
   put _ProjectFolder (dView) into sFolder
   --
   put "cd" && kwote (sFolder, "'") into someShell
   put ";" && merge ("gh repo create LiveCodeWorld/[[projectName]] --public --source=. --push") after someShell
   --
   put xterm_FindView() into xtermBrowser
   display_Xterm someShell, xtermBrowser
end menu_AddToGithub

private on ___
end ___

on menu_RevealGitFolder dView
   put _ProjectName (dView) into projectName
   --
   put git_InvisibleFolder (projectName) into invisibleGolder
   -- put git_FindDotGitFolder (someFile) into invisibleGolder
   finder_Reveal invisibleGolder
end menu_RevealGitFolder

getprop disabled_RevealGitFolder [dView]
   put _ProjectName (dView) into projectName
   put git_InvisibleFolder (projectName) into invisibleGolder
   return invisibleGolder is empty
end disabled_RevealGitFolder

private on __
end __

on menu_DisplayProject dView
   put _ProjectName (dView) into projectName
   --
   display_Project projectName
end menu_DisplayProject

on menu_DisplayProjectArray dView
   put _ProjectName (dView) into projectName
      --
   display_ProjectArray projectName, false
end menu_DisplayProjectArray

on submenu_Dev
   return  "Global | Github | Update | Line | Dev | Menu"
end submenu_Dev
