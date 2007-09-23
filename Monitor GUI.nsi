OutFile "GUI.exe"
Caption "ERFM (Beta) Monitor"
Icon "Monitor.ico"
XPStyle On
BrandingText /TRIMRIGHT "ERFM"
VIAddVersionKey /LANG=1033-ENGLISH "LegalCopyright" "See www.emptosoft.plus.com/licences"
VIAddVersionKey /LANG=1033-ENGLISH "ProductName" "Emptosoft Render Farm Manager (Beta)"
VIAddVersionKey /LANG=1033-ENGLISH "CompanyName" "Emptosoft"
VIAddVersionKey /LANG=1033-ENGLISH "FileDescription" "Emptosoft Render Farm Manager Monitor GUI (Version 0.4 - Beta)"
VIAddVersionKey /LANG=1033-ENGLISH "FileVersion" "0.4"
VIProductVersion "0.4.0.0"
Var TempData
Var HWND
Var Param
Page custom Prepare End ""
!include "FileFunc.nsh"
!insertmacro GetParameters

InstallColors 2C85C6 FFFFFF
AutoCloseWindow True

Function .onInit
   SetShellVarContext All
   InitPluginsDir
   ${GetParameters} $Param
   StrCmp $Param "" 0 End
   MessageBox MB_OK "This program cannot be run directly by a user."
   Quit
End:
FunctionEnd

Function Prepare
   File /oname=$PluginsDir\Page.emp  "MGUI.emp"
   ReadINIStr $TempData $Param "Temp" "Title"
   WriteINIStr "$PluginsDir\Page.emp" "Settings" "Title" "$TempData"
   WriteINIStr $Param "Temp" "Done" "0"
   WriteINIStr $Param "Temp" "Close" "0"
   InstallOptionsEx::initDialog /NOUNLOAD $PLUGINSDIR\Page.emp
   Pop $HWND
   WriteINIStr $Param "Temp" "HWND" "$HWND"
   WriteINIStr $Param "Temp" "Done" "1"
   InstallOptionsEx::show
   WriteINIStr $Param "Temp" "Close" "1"
   Quit
FunctionEnd

Function End
   WriteINIStr $Param "Temp" "Close" "1"
   Quit
FunctionEnd

Section -VOID
SectionEnd