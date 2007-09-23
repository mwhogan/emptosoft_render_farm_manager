OutFile "Job Generator.exe"
Caption "ERFM (Beta) Job Generator"
Icon "RFM.ico"
XPStyle On
BrandingText /TRIMRIGHT "ERFM"
VIAddVersionKey /LANG=1033-ENGLISH "LegalCopyright" "See www.emptosoft.plus.com/licences"
VIAddVersionKey /LANG=1033-ENGLISH "ProductName" "Emptosoft Render Farm Manager (Beta)"
VIAddVersionKey /LANG=1033-ENGLISH "CompanyName" "Emptosoft"
VIAddVersionKey /LANG=1033-ENGLISH "FileDescription" "Emptosoft Render Farm Manager Job Generator (Version 0.4 - Beta)"
VIAddVersionKey /LANG=1033-ENGLISH "FileVersion" "0.4"
VIProductVersion "0.4.0.0"
Var TGD
Var Total
Var Start
Var Sleep
Var FileData
Var TempData
Var TempData1
Var TempData2
Var TotalLines
Var SearchLine
Var SearchFrame
Var Percent
Var PercentDone
Var ScriptOpen
Var FramesinLine
Var JLLoc
Var Name
Var Finish
Var JSNum
Var Run
Var OutputLoc
Var ScriptStart
Var InitanimData
Var Priority
DetailsButtonText "Show log..."
SubCaption 3 ": Closing..."
SubCaption 4 ": Closing..."
Page custom Prepare Set ": Options (Page 1 of 2)"
Page custom Prepare2 Set2 ": Options (Page 2 of 2)"
Page instfiles
!include "defines.nsh"
!include "TextFunc.nsh"
!insertmacro LineSum
!include "WordFunc.nsh"
!insertmacro WordFind
!insertmacro WordFind2X
!insertmacro StrFilter
InstallColors 2C85C6 FFFFFF
AutoCloseWindow True

Function .onInit
   SetShellVarContext All
   InitPluginsDir
FunctionEnd

Function Prepare
   ReadINIStr $JLLoc $APPDATA\Emptosoft\Settings.emp "Rendering Tool for Terragen Network Version T2TP Beta" "JLLoc"
   StrCmp $JLLoc "" CreateJL Window
CreateJL:
   MessageBox MB_OK|MB_ICONEXCLAMATION "The job list cannot be found. Please select a location for the job list. Remember that the job list must be in a location that can be accessed by the other computers on your network."
   Dialogs::Save "Emptosoft Settings File|*.emp" "" "Job List Location..." "" ${VAR_R0}
   StrCmp $R0 "0" Quit
   StrCpy $JLLoc "$R0.emp"
   WriteINIStr $APPDATA\Emptosoft\Settings.emp "Rendering Tool for Terragen Network Version T2TP Beta" "JLLoc" "$JLLoc"
   Goto Window
Quit:
   Quit
Window:
   File /oname=$PLUGINSDIR\GUI.ini GUI1.ini
   InstallOptions::initDialog /NOUNLOAD $PLUGINSDIR\GUI.ini
   InstallOptions::show /NOUNLOAD $PLUGINSDIR\GUI.ini
FunctionEnd

Function Set
   Pop $TempData
   StrCmp $TempData Error Quit
   StrCmp $TempData Cancel Quit
   StrCmp $TempData Back Quit
   Goto OK
Quit:
   Quit
OK:
   ReadINIStr $TGD $PluginsDir\GUI.ini "Field 3" State
   ReadINIStr $OutputLoc $PluginsDir\GUI.ini "Field 5" State
   ReadINIStr $Start $PluginsDir\GUI.ini "Field 7" State
   ReadINIStr $Total $PluginsDir\GUI.ini "Field 10" State
   StrCmp $Total "" TGD-Check Delete
TGD-Check:
   IfFileExists "$TGD" Delete
   MessageBox MB_OK|MB_ICONEXCLAMATION "No file can be found at the location you have specified."
   Delete $PluginsDir\GUI.ini
   Quit
Delete:
   Delete $PluginsDir\GUI.ini
FunctionEnd

Function Prepare2
   File /oname=$PLUGINSDIR\GUI2.ini GUI2.ini
   InstallOptions::initDialog /NOUNLOAD $PLUGINSDIR\GUI2.ini
   InstallOptions::show $PLUGINSDIR\GUI2.ini
FunctionEnd

Function Set2
   Pop $TempData
   StrCmp $TempData Error Quit
   StrCmp $TempData Cancel Quit
   StrCmp $TempData Back Quit
   ReadINIStr $Sleep $PluginsDir\GUI2.ini "Field 3" State
   ReadINIStr $Finish $PluginsDir\GUI2.ini "Field 5" State
   ReadINIStr $Name $PluginsDir\GUI2.ini "Field 7" State
   ReadINIStr $Priority $PluginsDir\GUI2.ini "Field 9" State
   StrCmp $Finish "Nothing" Nothing
   StrCmp $Finish "Shutdown" SD
   StrCmp $Finish "Run a program" Run
   StrCmp $Finish "Display a dialog box" Box
   Goto Quit
    Nothing:
       Goto Delete
    SD:
       Goto Delete
    Run:
       StrCpy $Finish "Run"
       MessageBox MB_OK|MB_ICONINFORMATION "Please enter the location of the program you want to run."
       Dialogs::Open "Programs|*.exe" "" "Program Location..." "" ${VAR_R0}
       StrCmp $R0 "0" Quit
       StrCpy $Run $R0
       Goto Delete
    Box:
       StrCpy $Finish "Box"
       Goto Delete
Quit:
   Quit
Delete:
   Delete $PluginsDir\GUI2.ini
   StrCmp $Total "" F-Write
   IntCmp $Start $Total F-Write F-Write 0
   StrCmp $Total "1" Is
   StrCmp $Total "0" Is2
   StrCpy $TempData "are only $Total frames"
   Goto OverBox
Is:
   StrCpy $TempData "is only 1 frame"
   Goto OverBox
Is2:
   StrCpy $TempData "are no frames"
   Goto OverBox
OverBox:
   MessageBox MB_OK "You can't start rendering on frame $Start when there $TempData in the animation!"
   Quit
F-Write:
Call Write
FunctionEnd

Function Write
   Goto Found-Initanim2
   nxs::Show /NOUNLOAD "Reading data from the script..." /top "Analysing tgd file..." /sub "Locating output location(s)" /h 0 /pos 0 /max 100 /can 0 /end
   FileOpen $ScriptOpen $Script "r"
   Goto Script-Read-Loop
Script-Read-Loop:
   FileRead $ScriptOpen $InitanimData
   StrCpy $TempData $InitanimData 8
   StrCmp $TempData "Initanim" Found-Initanim
   ${WordFind} "$InitanimData" "initanim" "*" $TempData
   StrCmp $TempData "1" Found-Initanim
   Goto Script-Read-Loop
Found-Initanim:
   nxs::Update /NOUNLOAD /sub "Processing data..." /pos 100 /end
   ${WordFind} "$InitanimData" "," "-1" $TempData
   ${StrFilter} "$TempData" "" "" "0123456789" $TempData1
   StrCmp $TempData1 "" Found-Initanim2
   StrCpy $TempData1 "2"
   StrLen $TempData2 $Initanimdata
   Goto Script-Start-Loop
Script-Start-Loop:
   StrCpy $TempData $InitanimData "" -$TempData1
   StrCmp $TempData " " Script-Start-Sort
   StrCmp $TempData "," Script-Start-Sort
   IntCmp $TempData2 $TempData1 Script-Start-Error 0 Script-Start-Error
   IntOp $TempData1 $TempData1 + 1
   Goto Script-Start-Loop
Script-Start-Sort:
   StrCpy $TempData $TempData "" 1
   ${StrFilter} "$TempData" "" "" "0123456789" $TempData1
   StrCmp $TempData1 "" Found-Initanim2
   Goto Script-Start-Error
Script-Start-Error:
   MessageBox MB_OK "An error has occured while trying to detect the frame that your script starts on. This may be because you are trying to use an invalid Terragen animation script, or because the script you are trying to use is in a format that has not been anticipated by the creator of this program. This error may have been caused by 'initanim' occuring in a comment in your script. If this is the case, please remove 'initanim' from the comment or move the real 'initanim' command closer to the start of the script. If this is not the case, please post the entire 'Initanim' line from your script on the Emptosoft website, quoting the error code '3F', so that future versions of the ERTfT can be programmed to recognise the format you are using."
   Quit
Found-Initanim2:
   StrCpy $ScriptStart "1"
   IntCmp $Start $ScriptStart 0 Error3S 0
   StrCmp $Total "" 0 Write-Frames
   nxs::Update /NOUNLOAD /sub "Locating 'end_frame'..." /h 0 /pos 0 /max 100 /can 0 /end
   StrCpy $SearchLine "0"
   IntOp $SearchFrame $ScriptStart - 1
   StrCpy $PercentDone "0"
   ${LineSum} "$Script" $TotalLines
   IntOp $Percent $TotalLines / 100
   FileOpen $ScriptOpen $Script r
   Goto CounterLoop
CounterLoop:
   nxs::Update /NOUNLOAD /sub "Searching line $SearchLine, $SearchFrame frames found..." /pos $PercentDone /end
   FileRead $ScriptOpen $FileData
   ${WordFind} "$FileData" "frend" "*" $FramesinLine
   IntOp $SearchFrame $SearchFrame + $FramesinLine
   StrCmp $SearchLine $TotalLines CountProcess
   IntOp $SearchLine $SearchLine + 1
   IntOp $PercentDone $SearchLine / $Percent
   Goto CounterLoop
CountProcess:
   FileClose $ScriptOpen
   StrCpy $Total $SearchFrame
   StrCmp $Total "0" NoFrames
   IntCmp $Start $Total 0 0 Error3T
   IntCmp $ScriptStart $Total 0 0 Error3S
   nxs::Destroy /NOUNLOAD
   Goto Write-Frames
NoFrames:
   MessageBox MB_OK|MB_ICONEXCLAMATION "No frames could be found in the script!"
   Quit
Error3T:
   nxs::Destroy
   MessageBox MB_OK|MB_ICONEXCLAMATION "The render cannot start on frame $Start if there are only $Total frames in the script. If this error persists, then please contact Emptosoft quoting error code '3T', or get some basic maths lessons."
   Quit
Error3S:
   nxs::Destroy
   MessageBox MB_OK|MB_ICONEXCLAMATION "The script only contains data from frame $ScriptStart onwards. Some of the frames you are trying to render are before this frame. If this error persists, please contact Emptosoft, quoting the error code 3S."
   Quit
Write-Frames:
   MessageBox MB_YESNO|MB_ICONQUESTION "Are you sure you want to write this job to the job list?" IDNO Quit
   nxs::Show /NOUNLOAD "Writing job to job list..." /top "Writing the job to the job list..." /sub "Carrying out calculations..." /h 0 /pos 0 /max 100 /can 0 /end
   StrCpy $JSNum "1"
   Goto Job-Search
Job-Search:
   ReadINIStr $JSNum $JLLoc "Status" "Last"
   StrCmp $JSNum "" 0 Last-Write
   StrCpy $JSNum "0"
   Goto Last-Write
Last-Write:
   IntOp $JSNum $JSNum + 1
   WriteINIStr $JLLoc "Status" "Last" $JSNum
   StrCpy $SearchFrame "$Start"
   StrCpy $PercentDone "0"
   IntOp $Percent $Total - $Start
   IntOp $Percent $Percent / 100
   StrCpy $SearchFrame "$Start"
   Goto NoStart-Write-Loop
NoStart-Write-Loop:
   nxs::Update /NOUNLOAD /sub "Setting status for frame $SearchFrame to 'Not Started Yet'..." /pos $PercentDone /end
   WriteINIStr $JLLoc "Job $JSNum" "$SearchFrame" "N"
   StrCmp $SearchFrame $Total Settings-Write
   IntOp $TempData $SearchFrame - $Start
   IntOp $PercentDone $TempData / $Percent
   IntOp $SearchFrame $SearchFrame + 1
   Goto NoStart-Write-Loop
Settings-Write:
   nxs::Update /NOUNLOAD /sub "Writing settings: TGD File Location..." /pos 0 /end
   WriteINIStr $JLLoc "World" "$JSNum" "$TGD"
   nxs::Update /NOUNLOAD /sub "Writing settings: Sleep time..." /pos 10 /end
   WriteINIStr $JLLoc "Sleep" "$JSNum" "$Sleep"
   nxs::Update /NOUNLOAD /sub "Writing settings: Finish Operation..." /pos 20 /end
   WriteINIStr $JLLoc "Finish" "$JSNum" "$Finish"
   nxs::Update /NOUNLOAD /sub "Writing settings: Job Name..." /pos 30 /end
   WriteINIStr $JLLoc "Name" "$JSNum" "$Name"
   nxs::Update /NOUNLOAD /sub "Writing settings: 'Run Program' Location..." /pos 40 /end
   WriteINIStr $JLLoc "Run" "$JSNum" "$Run"
   nxs::Update /NOUNLOAD /sub "Writing Job Status..." /pos 50 /end
   WriteINIStr $JLLoc "Status" "$JSNum" "Not Started Yet"
   nxs::Update /NOUNLOAD /sub "Writing settings: Output File Name..." /pos 60 /end
   WriteINIStr $JLLoc "OutputLoc" "$JSNum" "$OutputLoc"
   nxs::Update /NOUNLOAD /sub "Writing settings: Location of output files..." /pos 70 /end
   WriteINIStr $JLLoc "OutputLoc" "$JSNum" "$OutputLoc"
   nxs::Update /NOUNLOAD /sub "Writing settings: Terragen priority..." /pos 80 /end
   WriteINIStr $JLLoc "Priority" "$JSNum" "$Priority"
   nxs::Update /NOUNLOAD /sub "Optimisting list for faster performance..." /pos 90 /end
   WriteINIStr $JLLoc "Total" "$JSNum" "$Total"
   WriteINIStr $JLLoc "Start" "$JSNum" "$Start"
   WriteINIStr $JLLoc "Change" "$JSNum" "1"
   FileClose $ScriptOpen
   nxs::Destroy
   MessageBox MB_OK|MB_ICONINFORMATION "Finished writing the settings to $JLLoc."
   MessageBox MB_YESNO|MB_ICONQUESTION "Would you like to run the Monitor?" IDYES Monitor
   Quit
Quit:
   Quit
Monitor:
   Exec '"$ExeDir\Monitor.exe" $JSNum'
   Quit
FunctionEnd

Section -Monitor
SectionEnd

Function .onGUIEnd
FunctionEnd