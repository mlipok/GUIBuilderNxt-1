#Region ; View

#Region ; options

Opt("WinTitleMatchMode", 4) ; advanced

Opt("GuiResizeMode", $GUI_DOCKALL) ; controls will never move when window is resized

Opt("PixelCoordMode", 0)

Opt("CaretCoordMode", 1)

Opt("MouseCoordMode", 0)

Opt("GUIOnEventMode", 1)

#EndRegion

#Region ; main form

Const $main_width  = 400
Const $main_height = 350
Const $main_left   = (@DesktopWidth  / 2) - ($main_width  / 2)
Const $main_top    = (@DesktopHeight / 2) - ($main_height / 2)

Const $main = GuiCreate($program_name & " - Form (" & $main_width & ", " & $main_height & ')', $main_width, $main_height, $main_left, $main_top, BitOR($WS_SIZEBOX, $WS_SYSMENU), $WS_EX_ACCEPTFILES)

GUISetOnEvent($GUI_EVENT_CLOSE,         _exit_script,            $main)
GUISetOnEvent($GUI_EVENT_RESIZED,       _window_resize,          $main)
GUISetOnEvent($GUI_EVENT_DROPPED,       _drag_file,              $main)
GUISetOnEvent($GUI_EVENT_PRIMARYDOWN,   _mouse_primary_down,     $main)
GUISetOnEvent($GUI_EVENT_PRIMARYUP,     _mouse_primary_up,       $main)
GUISetOnEvent($GUI_EVENT_SECONDARYUP,   _mouse_secondary_up,     $main)
GUISetOnEvent($GUI_EVENT_SECONDARYDOWN, _mouse_secondary_down,   $main)
GUISetOnEvent($GUI_EVENT_MOUSEMOVE,     _mouse_move,             $main)

GUISetFont(10, -1, -1, "Segoe UI")

#EndRegion

#Region ; background

Const $background = GUICtrlCreatePic($blank_bmp, 0, 0, 0, 0) ; used to show a grid

GUICtrlSetState($background, $GUI_DROPACCEPTED + $GUI_DISABLE)

Const $background_contextmenu       = GUICtrlCreateContextMenu(GUICtrlCreateDummy())
Const $background_contextmenu_paste = GUICtrlCreateMenuItem("Paste", $background_contextmenu)

GUICtrlSetOnEvent($background_contextmenu_paste, _paste_ctrl)

#EndRegion

#Region ; overlay

Const $overlay = GUICtrlCreateLabel('', -1, -1, 1, 1, $SS_BLACKFRAME, $WS_EX_TOPMOST)

Const $overlay_contextmenu        = GUICtrlCreateContextMenu(GUICtrlCreateDummy())
Const $overlay_contextmenu_copy   = GUICtrlCreateMenuItem("Copy",       $overlay_contextmenu)
Const $overlay_contextmenu_delete = GUICtrlCreateMenuItem("Delete",     $overlay_contextmenu)

GUICtrlSetOnEvent($overlay_contextmenu_copy,   _copy_ctrl)
GUICtrlSetOnEvent($overlay_contextmenu_delete, _delete_selected_controls)

#EndRegion

#Region ; grippies

Const $grippy_size = 5
  
Const $NorthWest_Grippy = GuiCtrlCreateLabel('', -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, $SS_BLACKRECT, $WS_EX_TOPMOST)
Const $North_Grippy     = GuiCtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, $SS_BLACKRECT, $WS_EX_TOPMOST)
Const $NorthEast_Grippy = GuiCtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, $SS_BLACKRECT, $WS_EX_TOPMOST)
Const $West_Grippy      = GuiCtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, $SS_BLACKRECT, $WS_EX_TOPMOST)
Const $East_Grippy      = GuiCtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, $SS_BLACKRECT, $WS_EX_TOPMOST)
Const $SouthWest_Grippy = GuiCtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, $SS_BLACKRECT, $WS_EX_TOPMOST)
Const $South_Grippy     = GuiCtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, $SS_BLACKRECT, $WS_EX_TOPMOST)
Const $SouthEast_Grippy = GuiCtrlCreateLabel("", -$grippy_size, -$grippy_size, $grippy_size, $grippy_size, $SS_BLACKRECT, $WS_EX_TOPMOST)

GuiCtrlSetCursor($NorthWest_Grippy, $SIZENWSE)
GuiCtrlSetCursor($North_Grippy,     $SIZENS)
GuiCtrlSetCursor($NorthEast_Grippy, $SIZENESW)
GuiCtrlSetCursor($East_Grippy,      $SIZEWS)
GuiCtrlSetCursor($SouthEast_Grippy, $SIZENWSE)
GuiCtrlSetCursor($South_Grippy,     $SIZENS)
GuiCtrlSetCursor($SouthWest_Grippy, $SIZENESW)
GuiCtrlSetCursor($West_Grippy,      $SIZEWS)

GUICtrlSetOnEvent($NorthWest_Grippy, _set_resize_mode)
GUICtrlSetOnEvent($North_Grippy,     _set_resize_mode)
GUICtrlSetOnEvent($NorthEast_Grippy, _set_resize_mode)
GUICtrlSetOnEvent($West_Grippy,      _set_resize_mode)
GUICtrlSetOnEvent($East_Grippy,      _set_resize_mode)
GUICtrlSetOnEvent($SouthWest_Grippy, _set_resize_mode)
GUICtrlSetOnEvent($South_Grippy,     _set_resize_mode)
GUICtrlSetOnEvent($SouthEast_Grippy, _set_resize_mode)

#EndRegion

#Region ; toolbar form

Const $toolbar_width  = 215
Const $toolbar_height = 480
Const $toolbar_left   = $main_left - ($toolbar_width + 5)
Const $toolbar_top    = $main_top + 5

Const $toolbar = GuiCreate("Choose Control Type", $toolbar_width, $toolbar_height, $toolbar_left, $toolbar_top, $WS_EX_MDICHILD, -1, $main)

#Region ; menu items

Const $menu_file            = GUICtrlCreateMenu    ("File")
Const $menu_save_definition = GUICtrlCreateMenuitem("Save", $menu_file) ; Roy add-on
Const $menu_load_definition = GUICtrlCreateMenuitem("Load", $menu_file) ; Roy add-on
GUICtrlCreateMenuitem("",     $menu_file) ; Roy add-on
Const $menu_exit            = GUICtrlCreateMenuitem("Exit", $menu_file)

GUICtrlSetOnEvent($menu_save_definition, _save_gui_definition)
GUICtrlSetOnEvent($menu_load_definition, _load_gui_definition)
GUICtrlSetOnEvent($menu_exit,            _exit_script)

Const $menu_edit  = GUICtrlCreateMenu    ("Edit")
Const $menu_vals  = GUICtrlCreateMenuitem("Vals",                $menu_edit) ; added by: TheSaint
Const $menu_wipe  = GUICtrlCreateMenuitem("Clear All Controls",  $menu_edit)
Const $menu_about = GUICtrlCreateMenuitem("About",               $menu_edit) ; added by: TheSaint

GUICtrlSetState($menu_wipe, $GUI_DISABLE)

GUICtrlSetOnEvent($menu_vals,  _menu_vals)
GUICtrlSetOnEvent($menu_wipe,  _wipe_current_gui)
GUICtrlSetOnEvent($menu_about, _menu_about)

Const $menu_settings    = GUICtrlCreateMenu    ("Settings")
Const $menu_show_grid   = GUICtrlCreateMenuItem("Show grid",                $menu_settings)
Const $menu_grid_snap   = GUICtrlCreateMenuItem("Snap to grid",             $menu_settings)
Const $menu_paste_pos   = GUICtrlCreateMenuItem("Paste at mouse position",  $menu_settings)
Const $menu_show_ctrl   = GUICtrlCreateMenuItem("Show control when moving", $menu_settings)
Const $menu_show_hidden = GUICtrlCreateMenuItem("Show hidden controls",     $menu_settings)

GUICtrlSetOnEvent($menu_show_grid,   _showgrid)
GUICtrlSetOnEvent($menu_grid_snap,   _gridsnap)
GUICtrlSetOnEvent($menu_paste_pos,   _pastepos)
GUICtrlSetOnEvent($menu_show_ctrl,   _show_control)
GUICtrlSetOnEvent($menu_show_hidden, _menu_show_hidden)

GUICtrlSetState($menu_show_grid,   $GUI_CHECKED)
GUICtrlSetState($menu_grid_snap,   $GUI_CHECKED)
GUICtrlSetState($menu_paste_pos,   $GUI_CHECKED)
GUICtrlSetState($menu_show_ctrl,   $GUI_CHECKED)
GUICtrlSetState($menu_show_hidden, $GUI_UNCHECKED)

#EndRegion

#Region ; control creation

Const $iconset = @ScriptDir & "\resources\Icons\" ; Added by: TheSaint

Const $contype_btn_w = 40
Const $contype_btn_h = 40

Const $default_cursor = GUICtrlCreateRadio('', 5, 5, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
                        GUICtrlSetImage   (-1, $iconset & "\Icon 1.ico")
                        GUICtrlSetTip     (-1, "Cursor")
                        GUICtrlSetState   (-1, $GUI_CHECKED) ; initial selection
                        GUICtrlSetOnEvent (-1, _reset_to_default)

GUICtrlCreateRadio("Tab", 45, 5, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage   (-1, $iconset & "\Icon 2.ico")
GUICtrlSetTip     (-1, "Tab")
GUICtrlSetOnEvent (-1, _control_type)

GUICtrlCreateRadio("Group", 85, 5, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage   (-1, $iconset & "\Icon 3.ico")
GUICtrlSetTip     (-1, "Group")
GUICtrlSetOnEvent (-1, _control_type)

GUICtrlCreateRadio("Button", 125, 5, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 4.ico")
GUICtrlSetTip(-1, "Button")
GUICtrlSetOnEvent(-1, _control_type)

GUICtrlCreateRadio("Checkbox", 165, 5, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 5.ico")
GUICtrlSetTip(-1, "Checkbox")
GUICtrlSetOnEvent(-1, _control_type)

; -----------------------------------------------------------------------------------------------------------

GUICtrlCreateRadio("Radio", 5, 45, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 6.ico")
GUICtrlSetTip(-1, "Radio")
GUICtrlSetOnEvent(-1, _control_type)

GUICtrlCreateRadio("Edit", 45, 45, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 7.ico")
GUICtrlSetTip(-1, "Edit")
GUICtrlSetOnEvent(-1, _control_type)

GUICtrlCreateRadio("Input", 85, 45, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 8.ico")
GUICtrlSetTip(-1, "Input")
GUICtrlSetOnEvent(-1, _control_type)

GUICtrlCreateRadio("Label", 125, 45, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 9.ico")
GUICtrlSetTip(-1, "Label")
GUICtrlSetOnEvent(-1, _control_type)

GUICtrlCreateRadio("UpDown", 165, 45, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 10.ico")
GUICtrlSetTip(-1, "UpDown")
GUICtrlSetOnEvent(-1, _control_type)

; -----------------------------------------------------------------------------------------------------------

GUICtrlCreateRadio("List", 5, 85, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 11.ico")
GUICtrlSetTip(-1, "List")
GUICtrlSetOnEvent(-1, _control_type)

GUICtrlCreateRadio("Combo", 45, 85, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 12.ico")
GUICtrlSetTip(-1, "Combo")
GUICtrlSetOnEvent(-1, _control_type)

GUICtrlCreateRadio("Date", 85, 85, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 13.ico")
GUICtrlSetTip(-1, "Date")
GUICtrlSetOnEvent(-1, _control_type)

GUICtrlCreateRadio("Treeview", 125, 85, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 14.ico")
GUICtrlSetTip(-1, "Treeview")
GUICtrlSetOnEvent(-1, _control_type)

GUICtrlCreateRadio("Progress", 165, 85, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 15.ico")
GUICtrlSetTip(-1, "Progress")
GUICtrlSetOnEvent(-1, _control_type)

; -----------------------------------------------------------------------------------------------------------

GUICtrlCreateRadio("Avi", 5, 125, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 16.ico")
GUICtrlSetTip(-1, "Avi")
GUICtrlSetOnEvent(-1, _control_type)

GUICtrlCreateRadio("Icon", 45, 125, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 17.ico")
GUICtrlSetTip(-1, "Icon")
GUICtrlSetOnEvent(-1, _control_type)

GUICtrlCreateRadio("Pic", 85, 125, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 18.ico")
GUICtrlSetTip(-1, "Pic")
GUICtrlSetOnEvent(-1, _control_type)

GUICtrlCreateRadio("Menu", 125, 125, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 19.ico")
GUICtrlSetTip(-1, "Menu")
GUICtrlSetOnEvent(-1, _control_type)
GUICtrlSetState(-1, $GUI_DISABLE)

GUICtrlCreateRadio("ContextMenu", 165, 125, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 20.ico")
GUICtrlSetTip(-1, "Context Menu")
GUICtrlSetOnEvent(-1, _control_type)
GUICtrlSetState(-1, $GUI_DISABLE)

; -----------------------------------------------------------------------------------------------------------

GUICtrlCreateRadio("Slider", 5, 165, $contype_btn_w, $contype_btn_h, BitOR($BS_PUSHLIKE, $BS_ICON))
GUICtrlSetImage(-1, $iconset & "\Icon 21.ico")
GUICtrlSetTip(-1, "Slider")
GUICtrlSetOnEvent(-1, _control_type)

#EndRegion

#region ; control properties form

GUICtrlCreateTab(5, 215, 200, 215)

#Region ; main

GUICtrlCreateTabItem("Main")

                           GUICtrlCreateLabel("Text:", 10,  248, 25,  15)
Const $h_form_text       = GuiCtrlCreateInput('',      40,  245, 125, 20)

                           GuiCtrlCreateLabel("Name:", 10, 272, 30,  15)
Const $h_form_name       = GuiCtrlCreateInput('',      45, 269, 120, 20)
                         
                           GuiCtrlCreateGroup("Size and Location", 10, 295, 185, 130)                         
                           GuiCtrlCreateLabel("Left:", 15, 315, 25, 20)
Const $h_form_left       = GuiCtrlCreateInput('',      40, 312, 65, 20)
                           GUICtrlCreateUpdown($h_form_left)
                         
                           GuiCtrlCreateLabel("Top:", 15, 345, 25, 20)
Const $h_form_top        = GuiCtrlCreateInput('',     40, 342, 65, 20)
                           GUICtrlCreateUpdown($h_form_top)
                         
                           GUICtrlCreateLabel("Width:", 15, 375, 40, 20)
Const $h_form_width      = GuiCtrlCreateInput('',       50, 372, 65, 20)
                           GUICtrlCreateUpdown($h_form_width)            
Const $h_form_fittowidth = GUICtrlCreateCheckbox("Auto",  125, 375)      

                           GuiCtrlCreateLabel("Height:", 15, 400, 40, 20)
Const $h_form_height     = GuiCtrlCreateInput('',        50, 397, 65, 20)
                           GUICtrlCreateUpdown($h_form_height)

GUICtrlSetOnEvent($h_form_text, _ctrl_change_text)

GUICtrlSetOnEvent($h_form_name, _ctrl_change_name)

GUICtrlSetOnEvent($h_form_left,       _ctrl_change_left)
GUICtrlSetOnEvent($h_form_top,        _ctrl_change_top)
GUICtrlSetOnEvent($h_form_width,      _ctrl_change_width)
GUICtrlSetOnEvent($h_form_fittowidth, _ctrl_fit_to_width)
GUICtrlSetOnEvent($h_form_height,     _ctrl_change_height)

#EndRegion

#Region ; state

GUICtrlCreateTabItem("State")
                         
Const $h_form_visible = GuiCtrlCreateCheckbox("Visible", 10, 240, 60, 20)
                         
Const $h_form_ontop   = GuiCtrlCreateCheckbox("OnTop", 10, 265, 60, 20)

Const $h_form_dropaccepted = GuiCtrlCreateCheckbox("Drop Accepted", 10, 290, 100, 20)

GUICtrlSetOnEvent($h_form_visible, _ctrl_change_visible)

GUICtrlSetOnEvent($h_form_ontop, _ctrl_change_ontop)

GUICtrlSetOnEvent($h_form_dropaccepted, _ctrl_change_dropaccepted)

#EndRegion

#Region ; style

GUICtrlCreateTabItem("Style")

Const $h_form_style_top = GUICtrlCreateCheckbox("Top", 10, 240, -1, 20)

GUICtrlSetOnEvent($h_form_style_top, _ctrl_change_style_top)

#EndRegion

#Region ; exstyle

GUICtrlCreateTabItem("ExStyle")

#EndRegion

GUICtrlCreateTabItem("")

#EndRegion

#EndRegion

#Region ; accelerators

Func _set_accelerators()
  Local Const $accel_delete = GUICtrlCreateDummy()
  Local Const $accel_c      = GUICtrlCreateDummy()
  Local Const $accel_v      = GUICtrlCreateDummy()

  Local Const $accelerators[3][2] = [["{Delete}", $accel_delete] , _ 
                                     ["^c"      , $accel_c]      , _ 
                                     ["^v"      , $accel_v]]

  GUISetAccelerators($accelerators, $main)

  GUICtrlSetOnEvent($accel_delete, _delete_selected_controls)
  GUICtrlSetOnEvent($accel_c,      _copy_ctrl)
  GUICtrlSetOnEvent($accel_v,      _paste_ctrl)
EndFunc

#EndRegion

Func _window_resize()
	$win_client_size = WinGetClientSize($main)
  
  WinSetTitle($main, "", $program_name & " - Form (" & $win_size[0] & ", " & $win_size[1] & ")")
EndFunc