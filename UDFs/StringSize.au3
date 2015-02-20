#include-once

; #INDEX# ============================================================================================================
; Title .........: _StringSize
; AutoIt Version : v3.2.12.1 or higher
; Language ......: English
; Description ...: Returns size of rectangle required to display string - maximum width can be chosen
; Remarks .......:
; Note ..........:
; Author(s) .....:  Melba23 - thanks to trancexx for the default DC code
; ====================================================================================================================

;#AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6

; #CURRENT# ==========================================================================================================
; _StringSize: Returns size of rectangle required to display string - maximum width can be chosen
; ====================================================================================================================

; #INTERNAL_USE_ONLY#=================================================================================================
; _StringSize_Error_Close: Releases DC and deletes font object after error
; ====================================================================================================================

; #FUNCTION# =========================================================================================================
; Name...........: _StringSize
; Description ...: Returns size of rectangle required to display string - maximum permitted width can be chosen
; Syntax ........: _StringSize($sText[, $iSize[, $iWeight[, $iAttrib[, $sName[, $iWidth]]]]])
; Parameters ....: $sText   - String to display
;                  $iSize   - [optional] Font size in points - (default = 8.5)
;                  $iWeight - [optional] Font weight - (default = 400 = normal)
;                  $iAttrib - [optional] Font attribute (0-Normal (default), 2-Italic, 4-Underline, 8 Strike)
;                             + 1 if tabs are to be expanded before sizing
;                  $sName   - [optional] Font name - (default = Tahoma)
;                  $iWidth  - [optional] Max width for rectangle - (default = 0 => width of original string)
; Requirement(s) : v3.2.12.1 or higher
; Return values .: Success - Returns 4-element array: ($iWidth set // $iWidth not set)
;                  |$array[0] = String reformatted with additonal @CRLF // Original string
;                  |$array[1] = Height of single line in selected font // idem
;                  |$array[2] = Width of rectangle required for reformatted // original string
;                  |$array[3] = Height of rectangle required for reformatted // original string
;                  Failure - Returns 0 and sets @error:
;                  |1 - Incorrect parameter type (@extended = parameter index)
;                  |2 - DLL call error - extended set as follows:
;                       |1 - GetDC failure
;                       |2 - SendMessage failure
;                       |3 - GetDeviceCaps failure
;                       |4 - CreateFont failure
;                       |5 - SelectObject failure
;                       |6 - GetTextExtentPoint32 failure
;                  |3 - Font too large for chosen max width - a word will not fit
; Author ........: Melba23 - thanks to trancexx for the default DC code
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
;=====================================================================================================================
Func _StringSize(Const $stext, Const $isize = 10, Const $iweight = 400, Const $iattrib = 0, Const $sname = "Segoe UI")
  If $stext = '' Then Return 0

	; Get default DC
  Local Const $hdc = DllCall($user32_dll, "handle", "GetDC", "hwnd", 0)[0]

  If @error Or Not $hdc Then 
    Return SetError(1, 1, 0)
  EndIf

  Static $gdi32_dll = DllOpen("gdi32.dll")

  ; Create required font
  Local Const $iInfo = DllCall($gdi32_dll, "int", "GetDeviceCaps", "handle", $hdc, "int", 90)[0] ; $LOGPIXELSY

  If @error Or Not $iInfo Then 
    Return SetError(2, _StringSize_Error_Close(3, $hdc), 0)
  EndIf

  Local Const $hfont = DllCall($gdi32_dll, "handle", "CreateFontW",        _
                                           "int",   -$iInfo * $isize / 72, _
                                           "int",   0,                     _
                                           "int",   0,                     _
                                           "int",   0,                     _
                                           "int",   $iweight,              _
                                           "dword", BitAND($iattrib, 2),   _
                                           "dword", BitAND($iattrib, 4),   _
                                           "dword", BitAND($iattrib, 8),   _
                                           "dword", 0,                     _
                                           "dword", 0,                     _
                                           "dword", 0,                     _
                                           "dword", 5,                     _
                                           "dword", 0,                     _
                                           "wstr", $sname)[0]

  If @error Or Not $hfont Then 
    Return SetError(3, _StringSize_Error_Close(4, $hdc), 0)
  EndIf

	; Select font and store previous font
	Local Const $hPrevFont = DllCall($gdi32_dll, "handle", "SelectObject", "handle", $hdc, "handle", $hfont)[0]

	If @error Or Not $hPrevFont Then 
    Return SetError(4, _StringSize_Error_Close(5, $hdc, $hfont, 0), 0)
  EndIf

	; Declare variables
	; Declare and fill Size structure
	Local Const $tsize = DllStructCreate("long X;long Y")

  DllCall($gdi32_dll, "bool", "GetTextExtentPoint32W", "handle", $hdc, "wstr", $stext, "int", StringLen($stext), "struct*", $tsize)

  If @error Then 
    Return SetError(5, _StringSize_Error_Close(6, $hdc, $hfont, 0), 0)
  EndIf

	; Clear up
	DllCall($gdi32_dll, "handle", "SelectObject", "handle", $hdc, "handle", $hPrevFont)
	DllCall($gdi32_dll, "bool", "DeleteObject", "handle", $hfont)
	DllCall($user32_dll, "int", "ReleaseDC", "hwnd", 0, "handle", $hdc)

	Return $tsize.X
EndFunc

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: _StringSize_Error_Close
; Description ...: Releases DC and deleted font object if required after error
; Syntax ........: _StringSize_Error_Close ($iExtCode, $hDC, $hGUI)
; Parameters ....: $iExtCode   - code to return
;                  $hDC, $hGUI - handles as set in _StringSize function
; Return value ..: $iExtCode as passed
; Author ........: Melba23
; Modified.......:
; Remarks .......: This function is used internally by _StringSize
; ===============================================================================================================================
Func _StringSize_Error_Close(Const $iextcode, Const $hdc = 0, Const $hfont = 0, Const $hlabel = 0)
	If $hfont <> 0 Then 
    DllCall("gdi32.dll", "bool", "DeleteObject", "handle", $hfont)
  EndIf

	If $hdc <> 0 Then 
    DllCall("user32.dll", "int", "ReleaseDC", "hwnd", 0, "handle", $hdc)
  EndIf

	If $hlabel Then 
    GUICtrlDelete($hlabel)
  EndIf

	Return $iextcode
EndFunc
