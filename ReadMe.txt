 Prototype for the next version of GUIBuilder
 CyberSlug - 26 Nov 2004

 TINY UPDATES 11 Jan 2004 for compatibility with AutoIt 3.0.103.152

Known bugs:
  Lots of things not implemented yet.... and frames (group controls) are incomplete
  Snap-to grid doesn't quite work correctly if it was previously turned off...
  Because icon controls don't resize, you can drag one off screen....
  ComboBox height resizing does not work
  Numbering of controls is not finalized

 Roy - 20 Jun 2005: added save & load gui defs to ini files with file ext .agd (AutoIt Gui Definition)
    see _SaveGuiDefinition & _LoadGuiDefinition (very beta code)
    Commented Beep function
   Note: Compile with 3.1.1.0
    TO USE IT COMPILE IN THE SAME DIRECTORY OF GUIBUILDER (NEEDS PICS X ICON & PIC)

 TheSaint - 5 July 2005: Added the ability to re-load the (*.agd) settings/template file, from the
 command-line (you can now use - Open With or SendTo, or simply associate that file type with the
 Guibuilder program. I modified some of CyberSlug's code & some of Roy's. I also added the ability
 to store the last used folder location in a .ini file (Gbuild.ini), this entry is the default load
 or save location if the file/entry exists, otherwise it default's to My Documents.
 The default GUI's .au3 filename, is also taken from Roy's template (*.agd) file, if you created one.
 BUG FIX - 31 Aug 2005: Command-line variable updated to ignore value of 1 - discovered this, when
   Guibuilder crashed on me, and I couldn't re-load the saved (*.agd) file, because $CmdLine[0] was
   returning a value of 1!

 TheSaint - 17th December 2006: This file was originally Prototype 0.5, and at some point CyberSlug
 had changed it to 0.6 ... the main difference I could find, was that all the "handle=" & $main, etc
 had been changed to $main, etc (the '"handle=" & ' element being completely removed). I have now
 implemented that change in this file, plus re-worked several other elements. Most notably, the GUI
 gets it's name from the title in SciTe (if you're running it), it also gets the save path from
 that name. There was one other change I found in Prototype 0.6, that reflected newer GUI changes -
 If Not IsDeclared('WS_CLIPSIBLINGS') Then Global $WS_CLIPSIBLINGS = 0x04000000 had been removed,
 and $WS_OVERLAPPEDWINDOW + $WS_VISIBLE + $WS_CLIPSIBLINGS had been changed to the following -
 BitOR($WS_OVERLAPPEDWINDOW, $WS_CLIPSIBLINGS), which I find to be in uncommon use, so I added
 my most commonly preferred version - $WS_OVERLAPPED + $WS_CAPTION + $WS_SYSMENU + $WS_VISIBLE +
 $WS_CLIPSIBLINGS + $WS_MINIMIZEBOX. Due to my changes I have called the program - Prototype 0.7.
 I have also added an 'About' dialog & 'Info' dialog menu items, and finally increased the height
 of the 'Choose Control Type' gui, which had been previously overlooked by both Roy and myself,
 which had meant that the bottom row of buttons was only partially displayed.

 One might wonder at my bothering to do all this, with the advent of KODA. Well I both like and
 dislike elements of KODA, and find the simplicity of GUIBuilder (with the later changes) much
 more pleasing at times. In particular, I dislike the naming and size ranges available in KODA,
 which means I'm forever renaming and changing them to what I want. In particular I like the
 buttons and inputs, etc to start off at 20 high, and have an underslash between control names
 and numbers i.e. $checkbox_1 not $checkbox1. I also prefer to have more screen to play with.

 TheSaint - 8th February 2009: This file is now Prototype 0.8, and is hopefully compatible with
 AutoIt versions 3.2.12.0 -> 3.3.0.0. I've also added some minor improvements, fixes, etc. This
 is just a fairly quick update to make the program useable with the newer GUI includes scenario,
 with no effort to add any new or missing features (they may come later). I've done this update
 for those (like me) who like to create their GUI's simply and quickly, etc. This is not mean't
 to be all things for all scripters, so if you want that, then use KODA instead. This is my
 effort to prevent this once ground-breaking program from slipping into obscurity. I'm forever
 grateful to CyberSlug for providing the original, and to Roy for his later improvements.

 TheSaint - 11th January 2015: This file is now Prototype 0.9, and is hopefully compatible with
 Windows 7 & maybe 8.
 
 Jaberwacky - January 2015: I don't know what version number this should be.  Major structural 
 rearrangements and code refactoring.  Fixed labels displaying "foo" to now display the proper 
 names. Fewer magic numbers.  Less global variables. Converted from HotKeys to Accelerators. 
 Resized the GUI and changed the starting location.
 
 [02/05/2015]
    1) Ability to select and move multiple controls.  
    2) Hold down ctrl while moving a group to move all controls contained within the group.  
    3) Press Esc to exit the control properties window.  mLipok
 
 [02/08/2015]
    1) Worked out a lot of individual and multiple control selection, moving, resize bugs.  
    2) Made some (very) small progress on tab controls.
    3) Fit to width customized to more controls.
    4) Resizing the window will snap to nearest fifth.

 [02/10/2015]
  A
    1) Implemented a method of selecting multiple controls by using a selection rectangle.
    2) Moving the properties window into the toolbar window.
    3) Fixed several bugs here and there.
  B
    1) simplified grippy handlers.
    2) other multiple selection features and bug fixes