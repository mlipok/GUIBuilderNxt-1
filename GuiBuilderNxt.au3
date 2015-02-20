#Region ; GUIBuilderNxt

#Region ; AutoIt3Wrapper

#AutoIt3Wrapper_Version=B
#AutoIt3Wrapper_Run_AU3Check=n
#AutoIt3Wrapper_AU3Check_Parameters=-w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7 -d

#EndRegion

#Region ; pragma

#pragma compile(UPX, False)

#pragma compile(Icon, "D:\Programming\AutoIt\My Scripts\GUIBuilderNxt\resources\icons\GUIBuilderNxt.ico")

#EndRegion

#Region ; globals
 
Const $program_name = "GUIBuilderNxt"
Const $program_version = "Prototype 1.0"

Global $right_click = False

Global $win_client_size[2]

Const $user32_dll = DllOpen("User32.dll")

Const $grid_ticks = 10

Const $default = 0, $draw = 1, $init_move = 2, $move = 3, $init_selection = 4, $selection = 5, _ 
      $resize_nw = 6, $resize_n = 7, $resize_ne = 8, $resize_e = 9, $resize_se = 10, $resize_s = 11, $resize_sw = 12, $resize_w = 13

Global $mode = $default

; Cursor Consts - added by: Jaberwacky
Const $ARROW = 2, $CROSS = 3, $SIZE_ALL = 9, $SIZENESW = 10, $SIZENS = 11, $SIZENWSE = 12, $SIZEWS = 13

Global $mControls[]

$mControls.SelectedCount = 0

$mControls.ControlCount = 0

$mControls.ControlCountInc = _control_count_inc
$mControls.ControlCountDec = _control_count_dec

$mControls.ButtonCount   = 0
$mControls.GroupCount    = 0
$mControls.CheckboxCount = 0
$mControls.RadioCount    = 0
$mControls.EditCount     = 0
$mControls.InputCount    = 0
$mControls.LabelCount    = 0
$mControls.ListCount     = 0
$mControls.ComboCount    = 0
$mControls.DateCount     = 0
$mControls.SliderCount   = 0
$mControls.TabCount      = 0
$mControls.TreeViewCount = 0
$mControls.UpdownCount   = 0
$mControls.ProgressCount = 0
$mControls.PicCount      = 0
$mControls.AviCount      = 0
$mControls.IconCount     = 0

Global $mMouse[]

; added by: TheSaint (most are my own, others just not declared)
Global $AgdInfile, $AgdOutFile, $gdtitle, $lfld, $mygui
Global $setting_snap_grid, $setting_paste_pos, $setting_show_control, $setting_show_hidden

Const $blank_bmp      = @ScriptDir & "\resources\blank.bmp"
Const $background_bmp = @ScriptDir & "\resources\background.bmp"
Const $sampleavi      = @ScriptDir & "\resources\sampleAVI.avi"
Const $samplebmp      = @ScriptDir & "\resources\SampleImage.bmp"
Const $guibuilder_ini = @ScriptDir & "\ini\GUIBuilderNxt.ini"
; END ADD

#EndRegion

#Region ; includes

#include <Array.au3>

#include <AVIConstants.au3>

#include <ButtonConstants.au3>

#include <Constants.au3>

#include <FileConstants.au3>

#include <FontConstants.au3>

#include <GuiConstantsEx.au3>

#include <GuiTab.au3>

#include <Misc.au3>

#include <MsgBoxConstants.au3>

#include <StringConstants.au3>

#include <StaticConstants.au3>

#include <WinAPI.au3>

#include <WinAPIMisc.au3>

#include <WinAPIGDI.au3>

#include <WindowsConstants.au3>

#include "UDFs\StringSize.au3"

#include "UDFs\MouseOnEvent.au3"

#include "GUIBuilderNxt - View.au3"

#EndRegion

#region ; main

$win_client_size = WinGetClientSize($main)

_set_accelerators()

_check_command_line()

_get_script_title()

_initialize_settings()

_MouseSetOnEvent($MOUSE_PRIMARYDBLCLK_EVENT, _mouse_primary_dblclk, $main)

GuiSetState(@SW_SHOWNORMAL, $toolbar)

GuiSetState(@SW_SHOWNORMAL, $main)

Do
  Sleep(100)
Until False

#endregion

#Region ; functions

Func _exit_script()
  If $mControls.ControlCount > 0 Then
    ; mod by: TheSaint
    Switch MsgBox($MB_SYSTEMMODAL + $MB_YESNOCANCEL, "Quit?", "Do you want to save the GUI?")
      Case $IDYES
        _code_generation()

      Case $IDCANCEL
        Return
    EndSwitch
  EndIf
  
  __MouseSetOnEvent_OnExitFunc()
  
  GuiDelete($toolbar)

  GuiDelete($main)

  Exit
EndFunc

#Region ; mouse management

Func _mouse_move()    
	Switch $mode
    Case $move 
      Local Const $mouse_pos = _mouse_snap_pos()
          
      Local Const $delta_x = $mMouse.X - $mouse_pos[0]
      
      Local Const $delta_y = $mMouse.Y - $mouse_pos[1]
      
      $mMouse.X = $mouse_pos[0]
      
      $mMouse.Y = $mouse_pos[1]
      
      Local $tooltip, $selected_ctrl
			
			Local Const $count = $mControls.SelectedCount
      
      For $i = 1 To $count
        $selected_ctrl = $mControls["Selected" & $i]
        
        _change_ctrl_size_pos($selected_ctrl, $selected_ctrl.Left - $delta_x, $selected_ctrl.Top - $delta_y, $selected_ctrl.Width, $selected_ctrl.Height)
				
				$mControls["Selected" & $i] = $selected_ctrl
				
				_update_control($selected_ctrl)
			
        $tooltip &= $selected_ctrl.Name & ": X:" & $selected_ctrl.Left & ", Y:" & $selected_ctrl.Top & ", W:" & $selected_ctrl.Width & ", H:" & $selected_ctrl.Height & @CRLF
      Next
			
      ToolTip(StringTrimRight($tooltip, 2))
      
    Case $init_selection            
      Local Const $mRect = _rect_from_points($mMouse.X, $mMouse.Y, MouseGetPos(0), MouseGetPos(1))
  
      _display_selection_rect($mRect)
			
			Local Const $count = $mControls.ControlCount
  
			For $i = 1 To $count
				_add_remove_selected_control($i, $mRect)
      Next
   
    Case $resize_nw
      _handle_nw_grippy()
    
    Case $resize_n
      _handle_n_grippy()
    
    Case $resize_ne
      _handle_ne_grippy()
    
    Case $resize_w
      _handle_w_grippy()
    
    Case $resize_e
      _handle_e_grippy()
    
    Case $resize_sw
      _handle_sw_grippy()
    
    Case $resize_s    
      _handle_s_grippy()
      
    Case $resize_se          
      _handle_se_grippy()
  EndSwitch
EndFunc

Func _mouse_primary_down()   
	Switch $mode 
		Case $draw      
      GUICtrlSetState($default_cursor, $GUI_CHECKED)
			
			Local Const $mCtrl = _create_ctrl()
			
			_add_to_selected($mCtrl)
			
			_show_grippies($mCtrl)
      
      Switch $mCtrl.Type
        Case "Combo", "UpDown", "Checkbox", "Radio"
          Local Const $pos = ControlGetPos($main, '', $East_Grippy)
          
          $mode = $resize_e
          
        Case Else
          Local Const $pos = ControlGetPos($main, '', $SouthEast_Grippy)
  
          $mode = $resize_se
      EndSwitch
      
      _move_mouse_to_grippy($pos[0], $pos[1])
			
			_set_current_mouse_pos()
      
    Case $selection
      Local Const $ctrl_hwnd = GuiGetCursorInfo($main)[4]
    
      Select
        Case $ctrl_hwnd = $background
          _reset_to_default()
          
        Case $ctrl_hwnd <> $overlay      
          ;_hide_selected_controls()
          
          _display_selected_tooltip()
          
          _set_current_mouse_pos()

          GUISetCursor($SIZE_ALL, 1, $main)
          
					_hide_grippies()
					
          $mode = $move
      EndSelect
    
    Case $default
      Local Const $ctrl_hwnd = GuiGetCursorInfo($main)[4]
    
      Select          
        Case $ctrl_hwnd = $background             
          _reset_to_default()
          
          _set_current_mouse_pos()
          
          $mode = $init_selection
          
        Case $ctrl_hwnd <> $overlay
					Local Const $mCtrl = _control_map_from_hwnd($ctrl_hwnd)
					
					If @error Then
						Return
					EndIf
					
          Switch _IsPressed("11") ; ctrl							
            Case True ; multiple select 
              Switch _group_select($mCtrl)
                Case True         
									_set_current_mouse_pos()

									GUISetCursor($SIZE_ALL, 1, $main)
									
									_hide_grippies()
							
									$mode = $move
									
                  Return
              EndSwitch														
							
							_add_to_selected($mCtrl, False)

							_set_current_mouse_pos()

							GUISetCursor($SIZE_ALL, 1, $main)  
							
							_hide_grippies()
							
							$mode = $move
              
            Case False ; single select   														
							_add_to_selected($mCtrl)			
							
							_set_current_mouse_pos()

							GUISetCursor($SIZE_ALL, 1, $main)
							
							_hide_grippies()
							
							$mode = $move
					EndSwitch
			EndSelect
  EndSwitch
EndFunc

Func _mouse_primary_up()  			
  Switch $mode
		Case $move    			
      _show_grippies($mControls.Selected1)
			
      ToolTip('')
      
      _populate_control_properties_gui($mControls.Selected1)
  
      GUISetCursor($ARROW, 1, $main) 
      
      $mode = $default
      
    Case $init_selection
      _recall_overlay() 
      
      ToolTip('')
      
      If $mControls.SelectedCount > 0 Then        
        $mode = $selection
      Else
        $mode = $default
      EndIf
      
    Case $resize_nw, $resize_n, $resize_ne, $resize_e, $resize_se, $resize_s, $resize_sw, $resize_w
      ToolTip('')
      
      _populate_control_properties_gui($mControls.Selected1)
      
      $mode = $default

      GUISetCursor($ARROW, 0, $main)
  EndSwitch
EndFunc

Func _mouse_primary_dblclk()  
  Local Const $ctrl_hover = GuiGetCursorInfo($main)[4]
	
	Local Const $mCtrl = _control_map_from_hwnd($ctrl_hover)
	
	If @error Then Return
	
	;ConsoleWrite($mCtrl.Type & @CRLF)
	
	_group_select($mCtrl)
          
	_display_selected_tooltip()
EndFunc

Func _mouse_secondary_down()
  Local Const $ctrl_hwnd = GuiGetCursorInfo($main)[4]
  
  $right_click = True
  
  If $ctrl_hwnd <> $background Then
    Local Const $mCtrl = _control_map_from_hwnd($ctrl_hwnd)      
    
    If IsMap($mCtrl) Then
      _dispatch_overlay($mCtrl)
        
      $mControls.Selected1 = $mCtrl
      
      _show_grippies($mControls.Selected1)
    EndIf
  EndIf
EndFunc

Func _mouse_secondary_up()        
  _recall_overlay()
  
  Local Const $ctrl_hwnd = GuiGetCursorInfo($main)[4]
  
  _set_current_mouse_pos()
      
  Switch $ctrl_hwnd
    Case $overlay
      ShowMenu($main, $overlay_contextmenu, $mMouse.X, $mMouse.Y)
      
    Case $background  
    
      ShowMenu($main, $background_contextmenu, $mMouse.X, $mMouse.Y)      
  EndSwitch
EndFunc

Func _mouse_snap_pos()  
  Return _snap_to_grid(GuiGetCursorInfo($main))
EndFunc

Func _snap_to_grid($coords)
  If $setting_snap_grid Then
		$coords[0] = $grid_ticks * Int($coords[0] / $grid_ticks - 0.5) + $grid_ticks

    $coords[1] = $grid_ticks * Int($coords[1] / $grid_ticks - 0.5) + $grid_ticks
  EndIf
	
	Return $coords
EndFunc

Func _set_current_mouse_pos()
  Local Const $mouse_snap_pos = _mouse_snap_pos()
  
  $mMouse.X = $mouse_snap_pos[0]
  
  $mMouse.Y = $mouse_snap_pos[1] 
EndFunc

Func _cursor_out_of_bounds(Const $cursor_pos)
  If $cursor_pos[0] < 0        Or _
     $cursor_pos[1] < 0        Or _
     $cursor_pos[0] > $win_client_size[0] Or _
     $cursor_pos[1] > $win_client_size[1] Then
    Return True
  EndIf

  Return False
EndFunc

#EndRegion

#Region ; control management

Func _control_map_from_hwnd(Const $ctrl_hwnd)
  Local $mcl_ctrl
  
	Local Const $count = $mControls.ControlCount
	
  For $i = 1 To $count
		$mcl_ctrl = $mControls["Control" & $i]
		
    If $ctrl_hwnd = $mcl_ctrl.Hwnd Then      
      ExitLoop
    EndIf
  Next
  
  Return IsMap($mcl_ctrl) ? $mcl_ctrl : SetError(1, 0, False)
EndFunc

Func _reset_to_default()  
  _hide_grippies()
          
  _recall_overlay() 
  
  _remove_all_from_selected()
  
  _clear_control_properties_gui()
  
  $mode = $default
EndFunc

Func _display_selected_tooltip()
  Local $tooltip, $selected_ctrl
	
	Local Const $count = $mControls.SelectedCount
          
  For $i = 1 To $count
    $selected_ctrl = $mControls["Selected" & $i]
    
    $tooltip &= $selected_ctrl.Name & ": X:" & $selected_ctrl.Left & ", Y:" & $selected_ctrl.Top & ", W:" & $selected_ctrl.Width & ", H:" & $selected_ctrl.Height & @CRLF
  Next
  
  ToolTip(StringTrimRight($tooltip, 2))
EndFunc

Func _remove_all_control_maps()
  Local Const $count = $mControls.ControlCount
  
  For $i = 1 To $count
    MapRemove($mControls, "Control" & $i)
		
		$mControls["ControlCountDec"]()
  Next
EndFunc

Func _remove_from_control_map(Const $mCtrl)
	Local Const $count = $mControls.ControlCount
  
  For $i = 1 To $count
		If $mCtrl.Hwnd = $mControls["Control" & $i].Hwnd Then
			MapRemove($mControls, "Control" & $i)
		
			ExitLoop
		EndIf
  Next
  
  _consolidate_controls($mControls.ControlCount)
  
  $mControls["ControlCountDec"]()
EndFunc

Func _wipe_current_gui()
  Switch @GUI_CtrlId
    Case $menu_wipe
      Switch MsgBox($MB_SYSTEMMODAL + $MB_YESNO + $MB_ICONWARNING, "Alert", "Are You Sure?  This action can not be undone.")
        Case $IDNO
          Return
      EndSwitch
  EndSwitch
  
  GUICtrlSetState($menu_wipe, $GUI_DISABLE)
	
	Local $mcl_element
	
	Local Const $count = $mControls.ControlCount

  For $i = 1 To $count
		$mcl_element = $mControls["Control" & $i]
		
    If $mcl_element.Type = "UpDown" Then
      GUICtrlDelete($mcl_element.Hwnd1)

      GUICtrlDelete($mcl_element.Hwnd2)
    Else
      GUICtrlDelete($mcl_element.Hwnd)
    EndIf
  Next

  _remove_all_control_maps()

  _reset_to_default()
  
  $mControls.ButtonCount   = 0
  $mControls.GroupCount    = 0
  $mControls.CheckboxCount = 0
  $mControls.RadioCount    = 0
  $mControls.EditCount     = 0
  $mControls.InputCount    = 0
  $mControls.LabelCount    = 0
  $mControls.ListCount     = 0
  $mControls.ComboCount    = 0
  $mControls.DateCount     = 0
  $mControls.SliderCount   = 0
  $mControls.TabCount      = 0
  $mControls.TreeViewCount = 0
  $mControls.UpdownCount   = 0
  $mControls.ProgressCount = 0
  $mControls.PicCount      = 0
  $mControls.AviCount      = 0
  $mControls.IconCount     = 0
EndFunc

Func _update_control(Const $mCtrl)
	Local Const $count = $mControls.ControlCount
	
	For $i = 1 To $count
		If $mCtrl.Hwnd = $mControls["Control" & $i].Hwnd Then
			$mControls["Control" & $i] = $mCtrl
			
			ExitLoop
		EndIf
	Next
EndFunc

Func _consolidate_controls(Const $count)
  ; inefficient; but works
  
  For $j = $count To 1 Step -1
    If Not IsMap($mControls["Control" & ($j - 1)]) Then
      $mControls["Control" & ($j - 1)] = $mControls["Control" & $j]
      
      MapRemove($mControls, $mControls["Control" & $j])
      
      Return _consolidate_controls($count - 1)
    EndIf
  Next
  
  Return $count
EndFunc

Func _delete_ctrl(Const $mCtrl)
  $mControls[$mCtrl.Type & "Count"] -= 1
  
  GUICtrlDelete($mCtrl.Hwnd)
  
  _remove_from_control_map($mCtrl)
  
  _remove_from_selected($mCtrl)
EndFunc

Func _delete_selected_controls()	
  Local Const $sel_count = $mControls.SelectedCount
  
  Switch $sel_count >= 1
    Case True
      _clear_control_properties_gui()
      
      Local $mCtrl
      
      For $i = $sel_count To 1 Step -1
        $mCtrl = $mControls["Selected" & $i]
        
        _delete_ctrl($mCtrl)
      Next
        
      _hide_grippies()
              
      _recall_overlay() 
      
      Return True
  EndSwitch
EndFunc

Func _copy_ctrl()   
	Local Const $sel_count = $mControls.SelectedCount

  Switch $sel_count >= 1
		Case True			
			_remove_all_from_clipboard()
			
			For $i = 1 To $sel_count
				$mControls["Clipboard" & $i] = $mControls["Selected" & $i]
				
				$mControls.ClipboardCount += 1
			Next
      
      Local Const $clip_count = $mControls.ClipboardCount
      
      Local $left[$clip_count], $top[$clip_count]
      
      For $i = 1 To $clip_count
        $left[$i - 1] = Abs($mControls.Clipboard1.Left - $mControls["Clipboard" & $i].Left)
        
        $top[$i - 1] = Abs($mControls.Clipboard1.Top - $mControls["Clipboard" & $i].Top)
      Next
      
      For $i = 1 To $clip_count
        $mControls["Clipboard" & $i].Left = $left[$i - 1]
        
        $mControls["Clipboard" & $i].Top = $top[$i - 1]
      Next
  EndSwitch
EndFunc

Func _paste_ctrl()  	
	Local Const $clipboard_count = $mControls.ClipboardCount
			
  Switch $clipboard_count >= 1
		Case True       
			Switch $right_click 
				Case False        
					_set_current_mouse_pos()
				
				Case True        
					$right_click = False
			EndSwitch
	
			Local $clipboard
			
      Local Const $mouse_pos = _mouse_snap_pos()
			
			For $i = 1 To $clipboard_count			
				$clipboard = $mControls["Clipboard" & $i]
				
				$clipboard.Left = $mouse_pos[0] + $clipboard.Left
				
				$clipboard.Top = $mouse_pos[1] + $clipboard.Top
      
				_create_ctrl($clipboard)
			Next
  EndSwitch
EndFunc

Func _remove_all_from_clipboard()
  Local Const $count = $mControls.ClipboardCount
  
  For $i = 1 To $count
    MapRemove($mControls, "Clipboard" & $i)
  Next
  
  $mControls.ClipboardCount = 0
	
  Return True
EndFunc

Func _control_count_inc()
	$mControls.ControlCount += 1
	
  If $mControls.ControlCount = 1 Then
    GUICtrlSetState($menu_wipe, $GUI_ENABLE)
  EndIf
EndFunc

Func _control_count_dec()
	$mControls.ControlCount -= 1
	
  If $mControls.ControlCount = 0 Then
    GUICtrlSetState($menu_wipe, $GUI_DISABLE)
  EndIf
EndFunc

#Region ; creation

Func _create_ctrl(Const $mCtrl = '')  
  Local $mNewControl[]

  Switch IsMap($mCtrl)
    Case True      
      $mNewControl = $mCtrl
    
      $mControls.CurrentType = $mNewControl.Type
    
    Case False
      Local $cursor_pos = _mouse_snap_pos()
  
      ; control will be inserted at current mouse position UNLESS out-of-bounds mouse
      Switch $setting_paste_pos
        Case True          
          If _cursor_out_of_bounds($cursor_pos) Then
            ContinueCase
          EndIf

        Case False
          $cursor_pos[0] = 0
          $cursor_pos[1] = 0
      EndSwitch
    
      $mNewControl.HwndCount     = 1
      $mNewControl.Type          = $mControls.CurrentType
      $mNewControl.Left          = $cursor_pos[0]
      $mNewControl.Top           = $cursor_pos[1]
      $mNewControl.Width         = 1
      $mNewControl.Height        = 1
      $mNewControl.Visible       = True
      $mNewControl.OnTop         = False  
      $mNewControl.DropAccepted  = False  
      $mNewControl.Focus         = False  
      $mNewControl.DefButton     = False  
  EndSwitch
	
  $mControls["ControlCountInc"]()
	
	$mControls[$mNewControl.Type & "Count"] += 1
	
	$mNewControl.Name = $mNewControl.Type & $mControls[$mNewControl.Type & "Count"]
  
	Switch $mNewControl.Type
    Case "Button"   
      $mNewControl.Hwnd = GuiCtrlCreateButton($mNewControl.Name, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)
      
			_set_button_styles($mNewControl)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
			
    Case "Group"      
      $mNewControl.Hwnd = GuiCtrlCreateGroup($mNewControl.Name, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
      
    Case "Checkbox"      
      $mNewControl.Height = 20
      
      $mNewControl.Hwnd = GuiCtrlCreateCheckbox($mNewControl.Name, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
      
    Case "Radio"      
      $mNewControl.Height = 20

      $mNewControl.Hwnd = GuiCtrlCreateRadio($mNewControl.Name, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
      
    Case "Edit"    
      $mNewControl.Hwnd = GuiCtrlCreateEdit('', $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)
      
      GUICtrlSetState($mNewControl.Hwnd, $GUI_DISABLE)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
			
			Return $mNewControl
      
    Case "Input"      
      $mNewControl.Hwnd = GuiCtrlCreateInput($mNewControl.Name, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)
      
      GUICtrlSetState($mNewControl.Hwnd, $GUI_DISABLE)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
      
    Case "Label"     
      $mNewControl.Hwnd = GuiCtrlCreateLabel($mNewControl.Name, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
      
    Case "List"      
      $mNewControl.Hwnd = GuiCtrlCreateList($mNewControl.Name, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)
      
      GUICtrlSetState($mNewControl.Hwnd, $GUI_DISABLE)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
      
    Case "Combo"      
      $mNewControl.Height = 20

      $mNewControl.Hwnd = GuiCtrlCreateCombo('', $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
			
			_WinAPI_RedrawWindow($main)
      
    Case "Date"      
      $mNewControl.Hwnd = GuiCtrlCreateDate('', $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
			
			Return $mNewControl
      
    Case "Slider"   
      $mNewControl.Hwnd = _GuiCtrlCreateSlider($mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height, $mNewControl.Height)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
			
			Return $mNewControl
      
    Case "Tab"      
      $mNewControl.HwndCount = 2
			
      $mNewControl.GUI = GuiCreate("", 150, 150, $mNewControl.Left, $mNewControl.Top, $WS_POPUP, $WS_EX_MDICHILD, $main)
      
      GuiSwitch($mNewControl.GUI)

      $mNewControl.Hwnd = _GUICtrlTab_Create($mNewControl.GUI, 0, 0, 150, 150)
      
      _GUICtrlTab_InsertItem($mNewControl.Hwnd, 0, "Tab1")
      
      GuiSetState(@SW_SHOWNORMAL, $mNewControl.GUI)

      GuiSwitch($main)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
			
			Return $mNewControl
      
    Case "TreeView"      
      $mNewControl.Hwnd = GUICtrlCreateTreeView($mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)

      GUICtrlCreateTreeViewItem($mNewControl.Name, $mNewControl.Hwnd)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
      
    Case "Updown"      
      If $mNewControl.Width = 1 Then
          $mNewControl.Width = 100
      EndIf

      $mNewControl.HwndCount = 2
      
      $mNewControl.Height = 25
      
      $mNewControl.Hwnd1 = GuiCtrlCreateInput($mNewControl.Name, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)

      $mNewControl.Hwnd2 = GuiCtrlCreateUpdown($mNewControl.Hwnd1)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
      
    Case "Progress"      
      $mNewControl.Hwnd = GuiCtrlCreateProgress($mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)

      GUICtrlSetData($mNewControl.Hwnd, 100)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
			
			Return $mNewControl
      
    Case "Pic"      
      $mNewControl.Hwnd = GuiCtrlCreatePic($samplebmp, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
			
			Return $mNewControl
      
    Case "Avi"            
      $mNewControl.Hwnd = GuiCtrlCreateAvi($sampleavi, 0, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height, $ACS_AUTOPLAY)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
			
			Return $mNewControl

    Case "Icon"                  
      $mNewControl.Hwnd = GuiCtrlCreateIcon($iconset, 0, $mNewControl.Left, $mNewControl.Top, $mNewControl.Width, $mNewControl.Height)
			
			$mControls["Control" & $mControls.ControlCount] = $mNewControl
			
			Return $mNewControl
	EndSwitch
	
  Switch IsMap($mCtrl)		
		Case True
			GUICtrlSetData($mNewControl.Hwnd, $mNewControl.Text)
			
		Case False 
			$mNewControl.Text = $mNewControl.Name
	EndSwitch
  
  Return $mNewControl
EndFunc

Func _GuiCtrlCreateSlider(Const $left, Const $top, Const $width, Const $height, $style)
  Local Const $ref = GuiCtrlCreateSlider($left, $top, $width, $height)

  If $style <= 0 Then
    $style = 0x50020001 ; the default style
  EndIf

  GuiCtrlSetStyle($ref, BitOr($style, 0x040)) ; TBS_FIXEDLENGTH

  Local $size =  $height - 20

  If $width - 20 < $size Then
    $size = $width - 20
  EndIf

  GuiCtrlSendMsg($ref, 27 + 0x0400, $size, 0) ; TBS_SETTHUMBLENGTH

  Return $ref
EndFunc

Func _createAnotherTab(Const $left, Const $top, Const $width, Const $height)
  Local Const $style = 0x56000000;WS_CHILD + WS_VISIBLE + WS_CLIPSIBLINGS + WS_CLIPCHILDREN

  ; I'm not sure why the -10 is needed, but it seems to calculate the right x, y coords
  Local Const $tabCtrlWin = GuiCreate("", $width, $height, $left, $top, $style, -1, $main)

  GuiCtrlCreateTab(0, 0, $width, $height)
  ;_GUICtrlTab_Create($tabCtrlWin, 10, 25, $width, $height)

  GuiSetState(@SW_SHOWNORMAL, $tabCtrlWin)

  GuiSwitch($main)

  Return $tabCtrlWin
EndFunc

Func _createAnotherTabItem(Const $tabHandle, Const $text)
  ; it would be better to explicitly use the handle of the parent GUI, but this the above function seems to work
  ;GuiSwitch($tabHandle)

  ;Local Const $item = GuiCtrlCreateTabItem($text)
  Local Const $item = _GUICtrlTab_InsertItem($tabHandle, 0, $text)

  If $text = "" Then
    GuiSwitch($main) ; remember null text denotes "closing" tabitem
  EndIf

  Return $item
EndFunc

Func _control_type()    
  $mControls.CurrentType = GUICtrlRead(@GUI_CtrlId, 1)

  $mode = $draw
EndFunc

#Region ; styles

Func _set_button_styles(ByRef $mCtrl)
	$mCtrl.StyleTabStop = True
	
	$mCtrl.ExStyleWindowEdge = True
	
  Switch $mCtrl.StyleTop
    Case True
			GUICtrlSetState($mCtrl.Hwnd, $BS_TOP)
			
		Case Else
			$mCtrl.StyleTop = False
	EndSwitch
EndFunc

#EndRegion

#EndRegion

#Region ; control properties window

Func _populate_control_properties_gui(Const $mCtrl)   
  GUICtrlSetData($h_form_text, $mCtrl.Text)
  
  GUICtrlSetData($h_form_name, $mCtrl.Name)
  
  GUICtrlSetData($h_form_left,   $mCtrl.Left)
  GUICtrlSetData($h_form_top,    $mCtrl.Top)
  GUICtrlSetData($h_form_width,  $mCtrl.Width)
  GUICtrlSetData($h_form_height, $mCtrl.Height)
  
	Switch $mControls.Selected1.Type
    Case "Edit", "Group", "Date"
      GUICtrlSetState($h_form_fittowidth, $GUI_DISABLE + $GUI_HIDE)
			
		Case Else
      GUICtrlSetState($h_form_fittowidth, $GUI_ENABLE + $GUI_SHOW)
	EndSwitch
	
  Switch $mCtrl.Visible
    Case True
      GUICtrlSetState($h_form_visible, $GUI_CHECKED)
      
    Case False
      GUICtrlSetState($h_form_visible, $GUI_UNCHECKED)
  EndSwitch
  
  Switch $mCtrl.OnTop
    Case True
      GUICtrlSetState($h_form_ontop, $GUI_CHECKED)
  
    Case False
      GUICtrlSetState($h_form_ontop, $GUI_UNCHECKED)
	EndSwitch
  
  Switch $mCtrl.StyleTop
    Case True
      GUICtrlSetState($h_form_style_top, $GUI_CHECKED)
  
    Case False
      GUICtrlSetState($h_form_style_top, $GUI_UNCHECKED)
	EndSwitch
EndFunc

Func _clear_control_properties_gui()    
  GUICtrlSetData($h_form_text, '')
  
  GUICtrlSetData($h_form_name, '')
  
  GUICtrlSetData($h_form_left,   '')
  GUICtrlSetData($h_form_top,    '')
  GUICtrlSetData($h_form_width,  '')
  GUICtrlSetData($h_form_height, '')
  
  GUICtrlSetState($h_form_visible, $GUI_UNCHECKED)
  
  GUICtrlSetState($h_form_ontop, $GUI_UNCHECKED)
	
  GUICtrlSetState($h_form_style_top, $GUI_UNCHECKED)
EndFunc

Func _ctrl_fit_to_width()
  Local $n
  
  Switch $mControls.Selected1.Type
    Case "Input"
      $n = _StringSize($mControls.Selected1.Text, 10) + 10
      
    Case "Button", "Checkbox"
      $n = _StringSize($mControls.Selected1.Text, 10) + 16
    
    Case "Radio"
      $n = _StringSize($mControls.Selected1.Text, 10) + 18
      
    Case "Combo"
      $n = _StringSize($mControls.Selected1.Text, 10) + 30
      
    Case "Label"
      $n = _StringSize($mControls.Selected1.Text, 10)
      
    Case "Edit", "Group", "Date"
      Return
      
    Case Else
      Return
  EndSwitch
  
  Local Const $new_width = Ceiling($n / $grid_ticks) * $grid_ticks
  
  GUICtrlSetPos($mControls.Selected1.Hwnd, $mControls.Selected1.Left, $mControls.Selected1.Top, $new_width, $mControls.Selected1.Height)
  
  $mControls.Selected1.Width = $new_width
	
  _update_control($mControls.Selected1)
      
	_show_grippies($mControls.Selected1)
  
  GUICtrlSetData($h_form_width, $new_width)
EndFunc

Func _ctrl_change_text()
  Local Const $new_text = GUICtrlRead(@GUI_CtrlId)
  
  If $mControls.Selected1.Type = "Combo" Then
    GUICtrlSetData($mControls.Selected1.Hwnd, $new_text, $new_text)
  Else
    GUICtrlSetData($mControls.Selected1.Hwnd, $new_text)
  EndIf
  
  $mControls.Selected1.Text = $new_text
	
  $mControls.Control1.Text = $new_text
EndFunc

Func _ctrl_change_name()
  Local Const $new_name = GUICtrlRead(@GUI_CtrlId)
  
  $mControls.Selected1.Name = $new_name
	
  $mControls.Control1.Name = $new_name
EndFunc

Func _ctrl_change_left()  
  Local Const $new_left = GUICtrlRead(@GUI_CtrlId)
  
  GUICtrlSetPos($mControls.Selected1.Hwnd, $new_left, $mControls.Selected1.Top, $mControls.Selected1.Width, $mControls.Selected1.Height)    
  
  $mControls.Selected1.Left = $new_left
	
  $mControls.Control1.Left = $new_left
      
	_show_grippies($mControls.Selected1)
EndFunc

Func _ctrl_change_top()  
  Local Const $new_top = GUICtrlRead(@GUI_CtrlId)
  
  GUICtrlSetPos($mControls.Selected1.Hwnd, $mControls.Selected1.Left, $new_top, $mControls.Selected1.Width, $mControls.Selected1.Height)
  
  $mControls.Selected1.Top = $new_top
	
  $mControls.Control1.Top = $new_top
      
	_show_grippies($mControls.Selected1)
EndFunc

Func _ctrl_change_width()    
  Local Const $new_width = GUICtrlRead(@GUI_CtrlId)
  
  GUICtrlSetPos($mControls.Selected1.Hwnd, $mControls.Selected1.Left, $mControls.Selected1.Top, $new_width, $mControls.Selected1.Height)
  
  $mControls.Selected1.Width = $new_width
	
  $mControls.Control1.Width = $new_width
      
	_show_grippies($mControls.Selected1)
EndFunc

Func _ctrl_change_height()  
  Local Const $new_height = GUICtrlRead(@GUI_CtrlId)
  
  GUICtrlSetPos($mControls.Selected1.Hwnd, $mControls.Selected1.Left, $mControls.Selected1.Top, $mControls.Selected1.Width, $new_height)
  
  $mControls.Selected1.Height = $new_height
	
  $mControls.Control1.Height = $new_height
      
	_show_grippies($mControls.Selected1)
EndFunc

#region ; States

Func _ctrl_change_visible()
  Local Const $ctrl_state = GUICtrlRead(@GUI_CtrlId)
  
  Select
    Case BitAND($ctrl_state, $GUI_CHECKED) = $GUI_CHECKED
      GUICtrlSetState($mControls.Selected1.Hwnd, $GUI_SHOW)
      
      $mControls.Selected1.Visible = True
			
      $mControls.Control1.Visible = True
      
      _show_grippies($mControls.Selected1)
      
    Case BitAND($ctrl_state, $GUI_UNCHECKED) = $GUI_UNCHECKED
      GUICtrlSetState($mControls.Selected1.Hwnd, $GUI_HIDE)
      
      $mControls.Selected1.Visible = False
			
      $mControls.Control1.Visible = False
      
      _hide_grippies()
  EndSelect
EndFunc

Func _ctrl_change_ontop()  
  Switch $mControls.Selected1.OnTop
    Case True      
      $mControls.Selected1.OnTop = False
			
      $mControls.Control1.OnTop = False
      
    Case False                  
      $mControls.Selected1.OnTop = True
			
      $mControls.Control1.OnTop = True
  EndSwitch
EndFunc

Func _ctrl_change_dropaccepted()
  Switch $mControls.Selected1.OnTop
    Case True      
      $mControls.Selected1.DropAccepted = False
			
      $mControls.Control1.DropAccepted = False
      
    Case False                  
      $mControls.Selected1.DropAccepted = True
			
      $mControls.Control1.DropAccepted = True
  EndSwitch
EndFunc

#EndRegion

#Region ; styles

Func _ctrl_change_style_top()	
	Local Const $mPrevious = $mControls.Selected1
			
	_delete_ctrl($mPrevious)
	
	$mControls.Selected1 = _create_ctrl($mControls.Selected1)
	
	Switch $mPrevious
		Case True      			
      $mControls.Selected1.StyleTop = False
			
      $mControls.Control1.StyleTop = False
      
    Case False, ''			
      $mControls.Selected1.StyleTop = True
			
      $mControls.Control1.StyleTop = True
	EndSwitch
	
	$mControls.Control1 = $mControls.Selected1
EndFunc

#endregion

#endregion

#Region ; selection

Func _control_intersection(Const $mCtrl, Const $mRect)
  If __WinAPI_PtInRectEx($mCtrl.Left, $mCtrl.Top, $mRect.Left, $mRect.Top, $mRect.Width, $mRect.Height) Then
    Return True
  EndIf
  
  Return False
EndFunc

Func _group_select(Const $mCtrl)                
  If $mCtrl.Type = "Group" Then
    _select_control_group($mCtrl)
		
    _set_current_mouse_pos()
    
    _hide_grippies()
		
		$mode = $move
    
    Return True
  EndIf
  
  Return False
EndFunc

Func _select_control_group(Const $mGroup)  
  Local $mGroupRect[]
  
  $mGroupRect.Left   = $mGroup.Left  
  $mGroupRect.Top    = $mGroup.Top  
  $mGroupRect.Width  = $mGroup.Width  
  $mGroupRect.Height = $mGroup.Height
  
  Local $mCtrl
	
	Local Const $count = $mControls.ControlCount
  
  For $i = 1 To $count 
    $mCtrl = $mControls["Control" & $i]
    
    If _control_intersection($mCtrl, $mGroupRect) Then
      _add_to_selected($mCtrl, False)  
    EndIf
  Next
EndFunc

Func _add_to_selected(Const $mCtrl, Const $overwrite = True)	
	If Not IsMap($mCtrl) Then		
		Return
	EndIf
	
	Switch $overwrite
		Case True      
			_remove_all_from_selected()
			
		Case False
			Switch _in_selected($mCtrl)
				Case True
					Return SetError(1, 0, False)
			EndSwitch
	EndSwitch

	$mControls.SelectedCount += 1
			
	$mControls["Selected" & $mControls.SelectedCount] = $mCtrl
	
  Return True
EndFunc

Func _add_remove_selected_control(Const $i, Const $mRect)
	Local Const $mCtrl = $mControls["Control" & $i]
	
	Switch _control_intersection($mCtrl, $mRect)
		Case True
			Switch _add_to_selected($mCtrl, False)
				Case True
					_populate_control_properties_gui($mCtrl)

					_display_selected_tooltip()
			EndSwitch            
		
		Case False
			Switch _remove_from_selected($mCtrl)
				Case True                
					Local Const $sel_count = $mControls.SelectedCount
					
					Switch $sel_count >= 1
						Case True
							_populate_control_properties_gui($mControls["Selected" & $sel_count])
							
						Case False
							_clear_control_properties_gui()
					EndSwitch

					_display_selected_tooltip()
			EndSwitch
	EndSwitch
EndFunc

Func _remove_all_from_selected()
  Local Const $count = $mControls.SelectedCount
  
  For $i = 1 To $count
    MapRemove($mControls, "Selected" & $i)
  Next
  
  $mControls.SelectedCount = 0
	
  Return True
EndFunc

Func _remove_from_selected(Const $mCtrl)
	If Not IsMap($mCtrl) Then		
		Return
	EndIf
	
  Switch _in_selected($mCtrl)
    Case False
      Return SetError(1, 0, False)
  EndSwitch
  
  Local Const $count = $mControls.SelectedCount
  
  For $i = 1 To $count
    Switch $mCtrl.Hwnd
      Case $mControls["Selected" & $i].Hwnd
        MapRemove($mControls, "Selected" & $i)
  
        _consolidate_selected($count)
      
        ExitLoop
    EndSwitch
  Next
  
  $mControls.SelectedCount -= 1
        
  Return True
EndFunc

Func _consolidate_selected(Const $count)
  ; inefficient; but works
  
  For $j = $count To 1 Step -1
    If Not IsMap($mControls["Selected" & ($j - 1)]) Then
      $mControls["Selected" & ($j - 1)] = $mControls["Selected" & $j]
      
      MapRemove($mControls, $mControls["Selected" & $j])
      
      Return _consolidate_selected($count - 1)
    EndIf
  Next
  
  Return $count
EndFunc

Func _in_selected(Const $mCtrl)
	Local Const $count = $mControls.SelectedCount
	
  For $i = 1 To $count
    If $mControls["Selected" & $i].Hwnd = $mCtrl.Hwnd Then
      Return True
    EndIf
  Next 
  
  Return False
EndFunc

Func _display_selection_rect(Const $mRect)      
  GUICtrlSetPos($overlay, $mRect.Left, $mRect.Top, $mRect.Width, $mRect.Height)     
      
  ;ToolTip($mRect.Left & ", " & $mRect.Top & ", " & $mRect.Width & ", " & $mRect.Height)
EndFunc

Func _hide_selected_controls()
	Local Const $count = $mControls.SelectedCount
	
  For $i = 1 To $count 
    If Not $setting_show_control Then
      GUICtrlSetState($mControls["Selected" & $i].Hwnd, $GUI_HIDE)
    EndIf
  Next
EndFunc

Func _show_selected_controls()
	Local Const $count = $mControls.SelectedCount
	
	For $i = 1 To $count
		If Not $setting_show_control Then
			GUICtrlSetState($mControls["Selected" & $i].Hwnd, $GUI_SHOW)
		EndIf
	Next
EndFunc

#EndRegion

#Region ; moving & resizing

Func _change_ctrl_size_pos(ByRef $mCtrl, Const $left, Const $top, Const $width, Const $height)  
  If $width < 1 Or $height < 1 Then
    Return
  EndIf

  GUICtrlSetPos($mCtrl.Hwnd, $left, $top, $width, $height)
  
  $mCtrl.Left   = $left
  $mCtrl.Top    = $top
  $mCtrl.Width  = $width
  $mCtrl.Height = $height
EndFunc

#region ; grippies

Func _set_resize_mode() 
  Switch @GUI_CtrlId
    Case $SouthEast_Grippy
      $mode = $resize_se
  
    Case $NorthWest_Grippy
      $mode = $resize_nw
        
    Case $North_Grippy
      $mode = $resize_n
        
    Case $NorthEast_Grippy
      $mode = $resize_ne
        
    Case $East_Grippy
      $mode = $resize_e
        
    Case $SouthEast_Grippy
      $mode = $resize_se
        
    Case $South_Grippy
      $mode = $resize_s
        
    Case $SouthWest_Grippy       
      $mode = $resize_sw
        
    Case $West_Grippy
      $mode = $resize_w
  EndSwitch

  _hide_selected_controls()
EndFunc

Func _handle_grippy(ByRef $mCtrl, Const $left, Const $top, Const $right, Const $bottom)
  _set_current_mouse_pos()  
  
  Switch $mCtrl.Type
    Case "Slider"
      GuiCtrlSendMsg($mCtrl.Hwnd, 27 + 0x0400, $mCtrl.Height - 20, 0) ; TBS_SETTHUMBLENGTH
      
    Case "Tab"
      WinMove($mCtrl.GUI, '', Default, Default, $mMouse.X, $mMouse.Y)   
  EndSwitch               

  _change_ctrl_size_pos($mCtrl, $left, $top, $right, $bottom)
      
  $mControls.Selected1 = $mCtrl
	
	_update_control($mCtrl)

  _show_grippies($mCtrl)
  
  ToolTip("( X:" & $mControls.Selected1.Left & ", Y:" & $mControls.Selected1.Top & ", W:" & $mControls.Selected1.Width & ", H:" & $mControls.Selected1.Height & ")")
EndFunc

Func _handle_nw_grippy()  
  Local $mCtrl = $mControls.Selected1

  Local Const $right = ($mCtrl.Width + $mCtrl.Left) - $mMouse.X

  Local Const $bottom = ($mCtrl.Height + $mCtrl.Top) - $mMouse.Y
	
	_handle_grippy($mCtrl, $mMouse.X, $mMouse.Y, $right, $bottom)
EndFunc

Func _handle_n_grippy()
  Local $mCtrl = $mControls.Selected1

  Local Const $bottom = ($mCtrl.Top + $mCtrl.Height) - $mMouse.Y

  _handle_grippy($mCtrl, $mCtrl.Left, $mMouse.Y, $mCtrl.Width, $bottom)
EndFunc

Func _handle_ne_grippy()
  Local $mCtrl = $mControls.Selected1

  Local Const $bottom = ($mCtrl.Top + $mCtrl.Height) - $mMouse.Y
  
  _handle_grippy($mCtrl, $mCtrl.Left, $mMouse.Y, $mMouse.X - $mCtrl.Left, $bottom)
EndFunc

Func _handle_w_grippy()
  Local $mCtrl = $mControls.Selected1

  Local Const $right = $mCtrl.Left + $mCtrl.Width

  _handle_grippy($mCtrl, $mMouse.X, $mCtrl.Top, $right - $mMouse.X, $mCtrl.Height)
EndFunc

Func _handle_e_grippy()
  Local $mCtrl = $mControls.Selected1

  _handle_grippy($mCtrl, $mCtrl.Left, $mCtrl.Top, $mMouse.X - $mCtrl.Left, $mCtrl.Height)
EndFunc

Func _handle_sw_grippy()
  Local $mCtrl = $mControls.Selected1

  Local Const $right = ($mCtrl.Left + $mCtrl.Width) - $mMouse.X

  _handle_grippy($mCtrl, $mMouse.X, $mCtrl.Top, $right, $mMouse.Y - $mCtrl.Top)
EndFunc

Func _handle_s_grippy()
  Local $mCtrl = $mControls.Selected1

  _handle_grippy($mCtrl, $mCtrl.Left, $mCtrl.Top, $mCtrl.Width, $mMouse.Y - $mCtrl.Top)
EndFunc

Func _handle_se_grippy()  	
  Local $mCtrl = $mControls.Selected1
	
  _handle_grippy($mCtrl, $mCtrl.Left, $mCtrl.Top, $mMouse.X - $mCtrl.Left, $mMouse.Y - $mCtrl.Top)
EndFunc

Func _show_grippies(Const $mCtrl)  
  If Not IsMap($mCtrl) Then
    Return
  EndIf
  
  Local Const $l = $mCtrl.Left
  Local Const $t = $mCtrl.Top
  Local Const $w = $mCtrl.Width
  Local Const $h = $mCtrl.Height  
  
  Local Const $nw_left = $l - $grippy_size
  Local Const $nw_top  = $t - $grippy_size
  Local Const $n_left  = $l + ($w - $grippy_size) / 2
  Local Const $n_top   = $nw_top
  Local Const $ne_left = $l + $w
  Local Const $ne_top  = $nw_top
  Local Const $e_left  = $ne_left
  Local Const $e_top   = $t + ($h - $grippy_size) / 2
  Local Const $se_left = $ne_left
  Local Const $se_top  = $t + $h
  Local Const $s_left  = $n_left
  Local Const $s_top   = $se_top
  Local Const $sw_left = $nw_left
  Local Const $sw_top  = $se_top
  Local Const $w_left  = $nw_left
  Local Const $w_top   = $e_top
  
  Switch $mCtrl.Type
    Case "Combo", "Checkbox", "Radio"
      GuiCtrlSetPos($East_Grippy , $e_left  , $e_top  , $grippy_size , $grippy_size)
      GuiCtrlSetPos($West_Grippy , $w_left  , $w_top  , $grippy_size , $grippy_size)
    
    Case Else
      GuiCtrlSetPos($NorthWest_Grippy , $nw_left , $nw_top , $grippy_size , $grippy_size)
      GuiCtrlSetPos($North_Grippy     , $n_left  , $n_top  , $grippy_size , $grippy_size)
      GuiCtrlSetPos($NorthEast_Grippy , $ne_left , $ne_top , $grippy_size , $grippy_size)
      GuiCtrlSetPos($East_Grippy      , $e_left  , $e_top  , $grippy_size , $grippy_size)
      GuiCtrlSetPos($SouthEast_Grippy , $se_left , $se_top , $grippy_size , $grippy_size)
      GuiCtrlSetPos($South_Grippy     , $s_left  , $s_top  , $grippy_size , $grippy_size)
      GuiCtrlSetPos($SouthWest_Grippy , $sw_left , $sw_top , $grippy_size , $grippy_size)
      GuiCtrlSetPos($West_Grippy      , $w_left  , $w_top  , $grippy_size , $grippy_size)
  EndSwitch
EndFunc

Func _hide_grippies()
  GuiCtrlSetPos($NorthWest_Grippy , -$grippy_size , -$grippy_size , $grippy_size , $grippy_size)
  GuiCtrlSetPos($North_Grippy     , -$grippy_size , -$grippy_size , $grippy_size , $grippy_size)
  GuiCtrlSetPos($NorthEast_Grippy , -$grippy_size , -$grippy_size , $grippy_size , $grippy_size)
  GuiCtrlSetPos($East_Grippy      , -$grippy_size , -$grippy_size , $grippy_size , $grippy_size)
  GuiCtrlSetPos($SouthEast_Grippy , -$grippy_size , -$grippy_size , $grippy_size , $grippy_size)
  GuiCtrlSetPos($South_Grippy     , -$grippy_size , -$grippy_size , $grippy_size , $grippy_size)
  GuiCtrlSetPos($SouthWest_Grippy , -$grippy_size , -$grippy_size , $grippy_size , $grippy_size)
  GuiCtrlSetPos($West_Grippy      , -$grippy_size , -$grippy_size , $grippy_size , $grippy_size)
EndFunc

Func _move_mouse_to_grippy(Const $x, Const $y)
  Local Const $mouse_coord_mode = Opt("MouseCoordMode", 2)
  
  MouseMove(Int($x + ($grippy_size / 2)), Int($y + ($grippy_size / 2)), 0)
  
  Opt("MouseCoordMode", $mouse_coord_mode)
EndFunc

#EndRegion

#EndRegion

#Region ; overlay management

Func _dispatch_overlay(Const $control)    
  GUICtrlSetPos($overlay, $control.Left, $control.Top, $control.Width, $control.Height)
  
  GUICtrlSetState($overlay, $GUI_ONTOP)
EndFunc

Func _recall_overlay()  
  GUICtrlSetPos($overlay, -1, -1, 1, 1)
EndFunc

#EndRegion

#EndRegion

#Region ; rectangle management

Func __WinAPI_IsRectEmpty(Const $tRECT)
  ; Author.........: Yashied
  ; Modified.......: jpm, jaberwacky

	Local Const $aRet = DllCall($user32_dll, "bool", "IsRectEmpty", "struct*", $tRECT)[0]
  
  Return @error ? SetError(@error, @extended, False) : $aRet
EndFunc

Func __WinAPI_CreateRect(Const $left, Const $top, Const $right, Const $bottom)
  ; Author.........: Yashied
  ; Modified.......: Jaberwacky

	Local Static $tRECT = DllStructCreate($tagRECT)
  
  With $tRECT
    .Left   = $left
    .Top    = $top
    .Right  = $right
    .Bottom = $bottom
  EndWith
  
	Return $tRECT
EndFunc

Func __WinAPI_CreatePoint(Const $x, Const $y)
  ; Author.........: Yashied
  ; Modified.......: Jaberwacky

	Local Static $tPOINT = DllStructCreate($tagPOINT)
  
  With $tPOINT
    .X = $x
    .Y = $y
  EndWith 

	Return $tPOINT
EndFunc

Func __WinAPI_PtInRectEx(Const $x, Const $y, Const $left, Const $top, Const $width, Const $height)  
  ; Author.........: Yashied
  ; Modified.......: JPM, Jaberwacky
  
  Local Const $right = $left + $width
  
  Local Const $bottom = $top + $height
  
	Local Const $tRECT = __WinAPI_CreateRect($left, $top, $right, $bottom)
  
	Local Const $tPOINT = __WinAPI_CreatePoint($x, $y)
  
	Local Const $aRet = DllCall($user32_dll, "bool", "PtInRect", "struct*", $tRECT, "struct", $tPOINT)[0]
  
  Return @error ? SetError(@error, @extended, False) : $aRet
EndFunc

Func _rect_from_points(Const $a1, Const $a2, Const $b1, Const $b2)
  Local $mRect[]
  
  $mRect.Left = ($a1 < $b1) ? $a1 : $b1
  
  $mRect.Top = ($a2 < $b2) ? $a2 : $b2
  
  $mRect.Width = ($b1 > $a1) ? ($b1 - $mRect.Left) : ($a1 - $mRect.Left)
  
  $mRect.Height = ($b2 > $a2) ? ($b2 - $mRect.Top) : ($a2 - $mRect.Top)
  
  Return $mRect
EndFunc

#EndRegion

#Region ; menu bar items

Func _initialize_settings()
  Switch IniRead($guibuilder_ini, "Settings", "ShowGrid", 1)
    Case 1
      GUICtrlSetState($menu_show_grid, $GUI_CHECKED)

      GUICtrlSetImage($background, $background_bmp)

    Case 0
      GUICtrlSetState($menu_show_grid, $GUI_UNCHECKED)

      GUICtrlSetImage($background, $blank_bmp)
  EndSwitch

  Switch IniRead($guibuilder_ini, "Settings", "PastePos", 1)
    Case 1
      GUICtrlSetState($menu_paste_pos, $GUI_CHECKED)

      $setting_paste_pos = True

    Case 0
      GUICtrlSetState($menu_paste_pos, $GUI_UNCHECKED)

      $setting_paste_pos = False
  EndSwitch

  Switch IniRead($guibuilder_ini, "Settings", "GridSnap", 1)
    Case 1
      GUICtrlSetState($menu_grid_snap, $GUI_CHECKED)

      $setting_snap_grid = True

    Case 0
      GUICtrlSetState($menu_grid_snap, $GUI_UNCHECKED)

      $setting_snap_grid = False
  EndSwitch

  Switch IniRead($guibuilder_ini, "Settings", "ShowControl", 1)
    Case 1
      GUICtrlSetState($menu_show_ctrl, $GUI_CHECKED)

      $setting_show_control = True

    Case 0
      GUICtrlSetState($menu_show_ctrl, $GUI_UNCHECKED)

      $setting_show_control = False
  EndSwitch

  Switch IniRead($guibuilder_ini, "Settings", "ShowHidden", 1)
    Case 1
      GUICtrlSetState($menu_show_hidden, $GUI_CHECKED)

      $setting_show_hidden = True

    Case 0
      GUICtrlSetState($menu_show_hidden, $GUI_UNCHECKED)

      $setting_show_hidden = False
  EndSwitch
EndFunc

Func ShowMenu(Const $hWnd, Const $context, Const $x, Const $y) ; Show a menu in a given GUI window which belongs to a given GUI ctrl
  ; taken from the helpfile
  
	Local Const $hMenu = GUICtrlGetHandle($context)
  
  DllCall($user32_dll, "int", "TrackPopupMenuEx", "hwnd", $hMenu, "int", 0, "int", $mMouse.X, "int", $mMouse.Y, "hwnd", $hWnd, "ptr", 0)
EndFunc

Func _showgrid()
  Local Const $show_grid_data = GuiCtrlRead($menu_show_grid)

  Select
    Case BitAnd($show_grid_data, $GUI_CHECKED) = $GUI_CHECKED
      GUICtrlSetState($menu_show_grid, $GUI_UNCHECKED)

      GUICtrlSetImage($background, $blank_bmp)

      IniWrite($guibuilder_ini, "Settings", "ShowGrid", 0)

    Case BitAnd($show_grid_data, $GUI_UNCHECKED) = $GUI_UNCHECKED
      GUICtrlSetState($menu_show_grid, $GUI_CHECKED)

      GUICtrlSetImage($background, $background_bmp) ; added by: TheSaint

      IniWrite($guibuilder_ini, "Settings", "ShowGrid", 1)
  EndSelect
EndFunc

Func _pastepos()
  If BitAnd(GuiCtrlRead($menu_paste_pos), $GUI_CHECKED) = $GUI_CHECKED Then
    GUICtrlSetState($menu_paste_pos, $GUI_UNCHECKED)

    IniWrite($guibuilder_ini, "Settings", "PastePos", 0)
  Else
    GUICtrlSetState($menu_paste_pos, $GUI_CHECKED)

    IniWrite($guibuilder_ini, "Settings", "PastePos", 1)
  EndIf

  $setting_paste_pos = Not $setting_paste_pos
EndFunc

Func _gridsnap()
  If BitAnd(GuiCtrlRead($menu_grid_snap), $GUI_CHECKED) = $GUI_CHECKED Then
    GUICtrlSetState($menu_grid_snap, $GUI_UNCHECKED)

    IniWrite($guibuilder_ini, "Settings", "GridSnap", 0)
  Else
    GUICtrlSetState($menu_grid_snap, $GUI_CHECKED)

    IniWrite($guibuilder_ini, "Settings", "GridSnap", 1)
  EndIf

  $setting_snap_grid = Not $setting_snap_grid
EndFunc

Func _show_control()
  Switch BitAnd(GuiCtrlRead($menu_show_ctrl), $GUI_CHECKED) = $GUI_CHECKED
    Case True
      GUICtrlSetState($menu_show_ctrl, $GUI_UNCHECKED)

      IniWrite($guibuilder_ini, "Settings", "ShowControl", 0)

      $setting_show_control = False

    Case False
      GUICtrlSetState($menu_show_ctrl, $GUI_CHECKED)

      IniWrite($guibuilder_ini, "Settings", "ShowControl", 1)

      $setting_show_control = True
  EndSwitch
EndFunc

Func _menu_about()
  MsgBox($MB_ICONINFORMATION, "About " & $program_name, $program_version & " - created by CyberSlug, "              & @CRLF & _
                              "and modified by Roy, TheSaint, and Jaberwacky!"            & @CRLF & @CRLF & _
                              "Program Information"                                       & @CRLF & _
                              "When you exit " & $program_name & ", you will be prompted" & @CRLF & _
                              "to save what you may have created. If you select"          & @CRLF & _
                              "'Yes' then up to three options become available -"         & @CRLF & _
                              "1) Pasted into Scite if it's open, or use a dialog to"     & @CRLF & _
                              "2) Save to a script (.au3) file, or if that's cancelled"   & @CRLF & _
                              "3) Copied to the clipboard automatically!")
EndFunc

Func _menu_vals()
	Local Const $ctrl_count = $mControls.ControlCount
	
  Local $values = "Total Of Controls = " & $ctrl_count & @CRLF & @CRLF
	
	Local $mCtrl
	
  For $i = 1 To $ctrl_count
		$mCtrl = $mControls["Control" & $i]
		
    $values &= "Handle = " & Hex($mCtrl.Hwnd) & @CRLF & _
               "Type   = " & $mCtrl.Type      & @CRLF & _
               "Name   = " & $mCtrl.Name      & @CRLF & @CRLF
  Next

  MsgBox($MB_ICONINFORMATION, "Current Code Values", $values)
EndFunc

Func _menu_show_hidden()
  Switch BitAnd(GuiCtrlRead($menu_show_hidden), $GUI_CHECKED) = $GUI_CHECKED
    Case True
      GUICtrlSetState($menu_show_hidden, $GUI_UNCHECKED)

      IniWrite($guibuilder_ini, "Settings", "ShowHidden", 0)

      $setting_show_hidden = False
  
      Local $ctrl
      
      For $i = 1 To $mControls.ControlCount  
        $ctrl = $mControls["Control" & $i]
        
        If Not $ctrl.Visible Then        
          GUICtrlSetState($ctrl.Hwnd, $GUI_HIDE)
        EndIf
      Next
      
      _recall_overlay()
      
      _hide_grippies()

    Case False
      GUICtrlSetState($menu_show_hidden, $GUI_CHECKED)

      IniWrite($guibuilder_ini, "Settings", "ShowHidden", 1)

      $setting_show_hidden = True
  
      Local $ctrl
      
      For $i = 1 To $mControls.ControlCount  
        $ctrl = $mControls["Control" & $i]
        
        If Not $ctrl.Visible Then        
          GUICtrlSetState($ctrl.Hwnd, $GUI_SHOW)
        EndIf
      Next
  EndSwitch
EndFunc

#endregion

#Region ; code generation

Func _code_generation()
  Local $_controls

  ; Mod by: TheSaint
  Local $includes = "#include <Constants.au3>"        & @CRLF & _
                    "#include <GUIConstantsEx.au3>"   & @CRLF & _
                    "#include <Misc.au3>"             & @CRLF & _
                    "#include <WindowsConstants.au3>"

  For $i = 1 To $mControls.ControlCount
    $_controls &= _generate_controls($i)

    $includes &= _generate_includes($i, $includes)
  Next

  Local Const $w = $win_client_size[0]

  Local Const $h = $win_client_size[1]

  ; Mod by TheSaint
  Local Const $code = _
    "; Script generated by " & $program_name & " " & $program_version                                                                                            & @CRLF & @CRLF &               _
    $includes                                                                                                                                                    & @CRLF & @CRLF &               _
    "Global $MainStyle = BitOR($WS_OVERLAPPED, $WS_CAPTION, $WS_SYSMENU, $WS_VISIBLE, $WS_CLIPSIBLINGS, $WS_MINIMIZEBOX)"                                        & @CRLF & @CRLF &               _
    "Global $hMain = GuiCreate(" & $gdtitle & ", " & $w & ", " & $h & ", -1, -1, $MainStyle)"                                                                    & @CRLF & @CRLF &               _
    $_controls                                                                                                                                                   & @CRLF &                       _
    "GuiSetState(@SW_SHOWNORMAL)"                                                                                                                                & @CRLF & @CRLF &               _
    "Do"                                                                                                                                                         & @CRLF & @TAB &                _
    "Switch GuiGetMsg()"                                                                                                                                         & @CRLF & @TAB & @TAB &         _
    "Case $GUI_EVENT_CLOSE"                                                                                                                                      & @CRLF & @TAB & @TAB & @TAB  & _
    "ExitLoop"                                                                                                                                                   & @CRLF & @CRLF & @TAB & @TAB & _
    "Case Else"                                                                                                                                                  & @CRLF & @TAB & @TAB & @TAB  & _
    ";"                                                                                                                                                          & @CRLF & @TAB &                _
    "EndSwitch"                                                                                                                                                  & @CRLF &                       _
    "Until False"

  _copy_code_to_output($code)
EndFunc

Func _generate_controls(Const $i)
	Local $mCtrl = $mControls["Control" & $i]
	
  Local Const $ctrl_pos = ControlGetPos($main, '', $mCtrl.Hwnd)

  Local Const $ltwh = $ctrl_pos[0] & ", " & $ctrl_pos[1] & ", " & $ctrl_pos[2] & ", " & $ctrl_pos[3]

  ; The general template is GUICtrlCreateXXX( "text", left, top [, width [, height [, style [, exStyle]]] )
  ; but some controls do not use this.... Avi, Icon, Menu, Menuitem, Progress, Tabitem, Treeviewitem, updown
  Local $mControls
  
  Switch StringStripWS($mCtrl.Name, $STR_STRIPALL) <> ''
    Case True
      $mControls = "Global $" & $mCtrl.Type & '_' & $i & " = "
  EndSwitch
  
  $mControls &= "GuiCtrlCreate" & $mCtrl.Type
  
  Switch $mCtrl.Type
    Case "Progress", "Slider", "TreeView" ; no text field
      $mControls &= '(' & $ltwh & ")" & @CRLF

    Case "Icon" ; extra iconid [set to zero]
      $mControls &= '("' & $mCtrl.Text & '", 0, ' & $ltwh & ")" & @CRLF

    Case Else
      $mControls &= '("' & $mCtrl.Text & '", ' & $ltwh & ")" & @CRLF
  EndSwitch

  Return $mControls
EndFunc

Func _generate_includes(Const $i, Const $includes)	
  Switch $mControls["Control" & $i].Type
    Case "Button", "Checkbox", "Group", "Radio"
      If Not StringInStr($includes, "<ButtonConstants.au3>") Then
        Return @CRLF & "#include <ButtonConstants.au3>"
      EndIf

    Case "Combo"
      If Not StringInStr($includes, "<ComboConstants.au3>") Then
        Return @CRLF & "#include <ComboConstants.au3>"
      EndIf

    Case "Date"
      If Not StringInStr($includes, "<DateTimeConstants.au3>") Then
        Return @CRLF & "#include <DateTimeConstants.au3>"
      EndIf

    Case "Edit", "Input"
      If Not StringInStr($includes, "<EditConstants.au3>") Then
        Return @CRLF & "#include <EditConstants.au3>"
      EndIf

    Case "Icon", "Label", "Pic"
      If Not StringInStr($includes, "<StaticConstants.au3>") Then
        Return @CRLF & "#include <StaticConstants.au3>"
      EndIf

    Case "List"
      If Not StringInStr($includes, "<ListBoxConstants.au3>") Then
        Return @CRLF & "#include <ListBoxConstants.au3>"
      EndIf

    Case "Progress"
      If Not StringInStr($includes, "<ProgressConstants.au3>") Then
        Return @CRLF & "#include <ProgressConstants.au3>"
      EndIf

    Case "Slider"
      If Not StringInStr($includes, "<SliderConstants.au3>") Then
        Return @CRLF & "#include <SliderConstants.au3>"
      EndIf

    Case "TreeView"
      If Not StringInStr($includes, "<TreeViewConstants.au3>") Then
        Return @CRLF & "#include <TreeViewConstants.au3>"
      EndIf
  EndSwitch

  Return ""
EndFunc

Func _copy_code_to_output(Const $code)
  ; mod by: TheSaint
  Switch StringInStr($CmdLineRaw, "/StdOut")
    Case True
      ConsoleWrite("#region ; --- " & $program_name & " generated code Start ---"  & @CRLF & _
                   StringReplace($code, @CRLF, @LF)                                & @CRLF & _
                   "#endregion ; --- " & $program_name & " generated code End ---" & @CRLF)

    Case False
      If $mygui = "" Then
        $mygui = "MyGUI.au3"
      EndIf

      Local Const $destination = FileSaveDialog("Save GUI to file?", "", "AutoIt (*.au3)", BitOR($FD_FILEMUSTEXIST, $FD_PATHMUSTEXIST, $FD_PROMPTOVERWRITE), $mygui)

      If @error = 1 Or Not $destination Then
        ClipPut($code)

        SplashTextOn("Done", @CRLF & "Script copied to clipboard!", 200, 100)
      Else
        FileDelete($destination)

        FileWrite($destination, $code)

        SplashTextOn("Done", @CRLF & "Saved to file!", 200, 100)
      EndIf

      Sleep(1000)

      SplashOff()
  EndSwitch
  ; END of modification by TheSaint
EndFunc

#EndRegion

#Region ; definitions added by: Roy

; Gui definition saved to Ini Files with .agd file ext, with following structure:
; [Main]             - Main section
; guiwidth=w         - Gui Width ($w)
; guiheigth=w        - Gui Heigth ($h)
; Left=n             - Left ($p[0])
; Top=n              - Top ($p[1])
; Width=n            - Width ($p[2])
; Height=n           - Height ($p[3])
; numctrls=n         - total number of controls

; then 1 section for each control
; [Control_n]       - where n is a counter starting from 1
; Type=text         - the control type
; Name=text         - the control Name ($master_ctrl_list[$i][1])
; Text=text         - the control text (see code)
; Left=n            - Left ($p[0])
; Top=n             - Top ($p[1])
; Width=n           - Width ($p[2])
; Height=n          - Height ($p[3])

Func _save_gui_definition()
  If $AgdOutFile = "" Then
    ; added by: TheSaint
    If $lfld = "" Then
      $lfld = IniRead($guibuilder_ini, "Save Folder", "Last", "")
    EndIf

    If Not FileExists($lfld) Then
      $lfld = ""
    EndIf

    If $lfld = "" Then
      $lfld = @MyDocumentsDir
    EndIf

    $AgdOutFile = FileSaveDialog("Save GUI Definition to file?", $lfld, "AutoIt Gui Definitions (*.agd)", BitOR($FD_PATHMUSTEXIST, $FD_PROMPTOVERWRITE), StringReplace($gdtitle, '"', ""))

    If @error = 1 Or $AgdOutFile = "" Then
      SplashTextOn("Save GUI Definition to file", "Definition not saved!", 200, 80)

      Sleep(1000)

      SplashOff()

      Return
    Else
      ; added by: TheSaint
      $lfld = StringInStr($AgdOutFile, "\", 0, -1)

      $lfld = StringLeft($AgdOutFile, $lfld - 1)

      IniWrite($guibuilder_ini, "Save Folder", "Last", $lfld)

      If StringRight($AgdOutFile, 4) <> ".agd" Then
        $AgdOutFile = $AgdOutFile & ".agd"
      EndIf

      $mygui = StringReplace($AgdOutFile, $lfld & "\", "")

      $mygui = StringReplace($mygui, ".agd", "")

      $gdtitle = '"' & $mygui & '"'

      $mygui = $mygui & ".au3"
    EndIf
  EndIf

  FileDelete($AgdOutFile)

  If @error Then
    SplashTextOn("Save GUI Definition to file", "Definition not saved!", 200, 80)

    Sleep(1000)

    SplashOff()

    Return
  EndIf

  Local Const $p = WinGetPos($main)

  IniWrite($AgdOutFile, "Main", "guiwidth",  $win_client_size[0])
  IniWrite($AgdOutFile, "Main", "guiheight", $win_client_size[1])
  IniWrite($AgdOutFile, "Main", "Left",      $p[0])
  IniWrite($AgdOutFile, "Main", "Top",       $p[1])
  IniWrite($AgdOutFile, "Main", "Width",     $p[2])
  IniWrite($AgdOutFile, "Main", "Height",    $p[3])
	
	Local Const $ctrl_count = $mControls.ControlCount
	
  IniWrite($AgdOutFile, "Main", "numctrls",  $ctrl_count)

  For $i = 1 To $ctrl_count
    Local $Key = "Control_" & $i
		
		Local $mCtrl = $mControls["Control" & $i]

    Local $handle = $mCtrl.Hwnd

    Local $pos = ControlGetPos($main, "", $handle)

    Local $text = ControlGetText($main, "", $handle)

    If @error Then
      $text = $master_ctrl_list[$i].Name
    EndIf

    IniWrite($AgdOutFile, $Key, "Type",         $mCtrl.Type)
    IniWrite($AgdOutFile, $Key, "Name",         $mCtrl.Name)
    IniWrite($AgdOutFile, $Key, "Text",         $text)
    IniWrite($AgdOutFile, $Key, "Visible",      $mCtrl.Visible)
    IniWrite($AgdOutFile, $Key, "OnTop",        $mCtrl.OnTop)
    IniWrite($AgdOutFile, $Key, "DropAccepted", $mCtrl.DropAccepted)
    IniWrite($AgdOutFile, $Key, "Text",         $text)
    IniWrite($AgdOutFile, $Key, "Left",         $pos[0])
    IniWrite($AgdOutFile, $Key, "Top",          $pos[1])
    IniWrite($AgdOutFile, $Key, "Width",        $pos[2])
    IniWrite($AgdOutFile, $Key, "Height",       $pos[3])
  Next

  SplashTextOn("Save GUI Definition to file", "Saved to " & @CRLF & $AgdOutFile, 500, 100)

  Sleep(1000)

  SplashOff()
EndFunc

Func _drag_file()
  _load_gui_definition(@GUI_DragFile)
EndFunc

Func _load_gui_definition($AgdInfile = '')
  If $mControls.ControlCount > 0 Then
    Switch MsgBox($MB_ICONWARNING + $MB_YESNO, "Load Gui Definition from file", "Loading a Gui Definition will clear existing controls." & @CRLF & "Are you sure?" & @CRLF)
      Case $IDNO
        Return
    EndSwitch
  EndIf
  
  Switch $AgdInfile
    Case ''
      ; added by: TheSaint
      $lfld = IniRead($guibuilder_ini, "Save Folder", "Last", "")

      If $lfld = "" Then
        $lfld = @MyDocumentsDir
      EndIf

      If Not $CmdLine[0] Then ; mod by: TheSaint
        $AgdInfile = FileOpenDialog("Load GUI Definition from file?", $lfld, "AutoIt Gui Definitions (*.agd)", $FD_FILEMUSTEXIST)

        If @error Then
          Return
        EndIf
      EndIf
  EndSwitch

  $AgdOutFile = $AgdInfile
        
  Local Const $w = IniRead($AgdInfile, "Main", "guiwidth", -1)

  If $w = -1 Then
    MsgBox($MB_ICONERROR, "Load Gui Error", "Error loading gui definition.")

    Return
  EndIf

  _wipe_current_gui()
  
  WinMove($main, "", IniRead($AgdInfile, "Main", "Left",   -1), _ 
                     IniRead($AgdInfile, "Main", "Top",    -1), _ 
                     IniRead($AgdInfile, "Main", "Width",  -1), _ 
                     IniRead($AgdInfile, "Main", "Height", -1))

  Local Const $numCtrls = IniRead($AgdInfile, "Main", "numctrls", -1)
  
  Local $control[], $key

  For $i = 1 To $numCtrls
    $key = "Control_" & $i
  
    $control.HwndCount = 1
    $control.Type      = IniRead($AgdInfile, $key, "Type",    -1)
    $control.Name      = IniRead($AgdInfile, $key, "Name",    -1)
    $control.Text      = IniRead($AgdInfile, $key, "Text",    -1)
    $control.Visible   = IniRead($AgdInfile, $key, "Visible", 1)
    $control.OnTop     = IniRead($AgdInfile, $key, "OnTop",   0)
    $control.Left      = IniRead($AgdInfile, $key, "Left",   -1)
    $control.Top       = IniRead($AgdInfile, $key, "Top",    -1)
    $control.Width     = IniRead($AgdInfile, $key, "Width",  -1)
    $control.Height    = IniRead($AgdInfile, $key, "Height", -1)
		
		_create_ctrl($control)
  Next

  $mControls.Selected1 = Null

  SplashTextOn("Load GUI Definition from file", "Loaded from " & @CRLF & $AgdInfile, 500, 100)

  Sleep(1000)

  SplashOff()
EndFunc

#EndRegion

#Region ; added by: TheSaint

Func _check_command_line()
  If $CmdLine[0] > 0 Then
    If StringRight($CmdLine[1], 4) = ".agd" Then
      $AgdInfile = FileGetLongName($CmdLine[1])

      _load_gui_definition()
    EndIf
  EndIf
EndFunc

Func _get_script_title()
  If $AgdInfile = "" Then
    $gdtitle = WinGetTitle("classname=SciTEWindow", "")
  Else
    $gdtitle = $AgdOutFile
  EndIf

  If $gdtitle <> "" Then
    Local $gdvar = StringSplit($gdtitle, "\")

    $lfld = StringLeft($gdtitle, StringInStr($gdtitle, $gdvar[$gdvar[0]]) - 2)

    $gdtitle = $gdvar[$gdvar[0]]

    If $AgdInfile = "" Then
      $gdvar = StringInStr($gdtitle, ".au3")
    Else
      $gdvar = StringInStr($gdtitle, ".agd")
    EndIf

    $gdtitle = StringLeft($gdtitle, $gdvar - 1)
  Else
    $gdtitle = "MyGUI"
  EndIf

  $mygui = $gdtitle & ".au3"

  $gdtitle = '"' & $gdtitle & '"'
EndFunc

#EndRegion
