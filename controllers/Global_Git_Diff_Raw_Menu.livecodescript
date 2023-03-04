script "Global | Git | Diff | Raw | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Git | Diff | Raw | Line | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   _InitLocalArray tObject
   return LocalArray ["displayView"]
end menu_Target


--> Private
-
private command _InitLocalArray tObject
   put the display_View of tObject into dView
   put the git_SettingsModel of dView into LocalArray
   put the current_BranchName of arrayView into LocalArray ["currentBranchName"]
   put the other_BranchName of arrayView into LocalArray ["otherBranchName"]
   return dView
end _InitLocalArray

private function _LocalValue someKey
   return LocalArray [someKey]
end _LocalValue


--> Global | Git | Diff | Raw | Line | Menu
-
on menu_Test
   breakpoint
end menu_Test


--> Global | Git | Diff | Raw | Menu
-
on menu_RevertOpenStacks arrayView
   put LocalArray ["gitFolder"] into gitFolder
   put revLoadedStacks("all") into loadedStackNames
   
   put the displayed_Array of arrayView into displayedArray
   repeat for each key relativePath in displayedArray
      put gitFolder & relativePath into thisBranchFile
      
      put displayedArray [relativePath]["dstPath"] into otherBranchRelativeFile
      if otherBranchRelativeFile is empty then
         put thisBranchFile into otherBranchFile
      else
         put gitFolder & otherBranchRelativeFile into otherBranchFile
      end if
      
      if there is a stack thisBranchFile then
         put the short name of stack thisBranchFile into thisStackName
         if thisStackName is among the lines of loadedStackNames then
            put thisStackName & CR after stackNamesToRevert
            
            breakpoint
            revert stack thisStackName
         end if
      end if
   end repeat
   delete char -1 of stackNamesToRevert
   
   put stackNamesToRevert
end menu_RevertOpenStacks
