OutFile "Monitor.exe"
Caption "ERFM (Beta) Monitor"
Icon "Monitor.ico"
XPStyle On
BrandingText /TRIMRIGHT "ERFM"
VIAddVersionKey /LANG=1033-ENGLISH "LegalCopyright" "See www.emptosoft.plus.com/licences"
VIAddVersionKey /LANG=1033-ENGLISH "ProductName" "Emptosoft Render Farm Manager (Beta)"
VIAddVersionKey /LANG=1033-ENGLISH "CompanyName" "Emptosoft"
VIAddVersionKey /LANG=1033-ENGLISH "FileDescription" "Emptosoft Render Farm Manager Monitor setup and background process (Version 0.4 - Beta)"
VIAddVersionKey /LANG=1033-ENGLISH "FileVersion" "0.4"
VIProductVersion "0.4.0.0"
Var JobName
Var JLLoc
Var JobNum
Var TempData
Var TempData1
Var Total
Var Start
Var Sleep
Var Percent
Var PercentDone
Var FramesDone
Var SearchFrame
Var FramesRendering
Var OutputLoc
Var Status
Var SearchFrame4
Var Priority
Var Last
Var ListData
Var ListData1
Var First
Var ButtonSave
Var ActiveJobLast
Var Eject
Var Verify
Var HWND
Var Field1
Var Field2
Var Field3
Var Field4
Var Field5
Var Field6
Var Field7
Var Field8
Var Field9
Var Field10
Var Field11
Var Field12
Var Field13
Var Field14
Var Field15
Var FramesNSY
Var TempJN
Var LoopSleep
Var FrameSleep
Var FrameSleepPercent
Var RTotal
Var PercentNSY
Var PercentRendering
Var ActiveJob
Var FirstRun
Var CFC
Var CCache
Var AvgNum
Var AvgTotal
Var Avg
Var AvgRaw
Var OD1
Var OD2
Var OD3
Var OD7
Var OT1
Var OT2
Var OT3
Var Waste
Var VerF
Var EJob
Var EFra
Page custom Prepare Read ": Options (1/2)"
Page custom Prepare2 Read2 ": Options (2/2)"
Page custom Monitor End ""
!include "FileFunc.nsh"
!insertmacro GetParameters
!insertmacro GetTime
!include "WordFunc.nsh"
!insertmacro WordFind
!insertmacro WordFind2X
!include "defines.nsh"
!include "WinMessages.nsh"
InstallColors 2C85C6 FFFFFF
AutoCloseWindow True

Function .onInit
   SetShellVarContext All
   InitPluginsDir
   Delete $Temp\Temp.emp
FunctionEnd

Function Prepare
   File /oname=$PluginsDir\Page.emp "Monitor.emp"
   ${GetParameters} $JobNum
   ReadINIStr $JLLoc $APPDATA\Emptosoft\Settings.emp "Rendering Tool for Terragen Network Version T2TP Beta" "JLLoc"
   ReadINIStr $Last $JLLoc "Status" "Last"
   StrCmp $Last "" NoJL
   Goto Param-Read
NoJL:
   MessageBox MB_OK|MB_ICONINFORMATION "Please specify the location of the Job List file."
   Dialogs::Open "Emptosoft Settings File|*.emp" "" "Job list Location..." "" ${VAR_R0}
   StrCpy $JLLoc $R0
   StrCmp $JLLoc "0" Quit
   WriteINIStr $APPDATA\Emptosoft\Settings.emp "Rendering Tool for Terragen Network Version T2TP Beta" "JLLoc" "$JLLoc"
   Goto Param-Read
Quit:
   Quit
Param-Read:
   StrCmp $JobNum "" JobData Parameter
Parameter:
   IntCmp $JobNum $Last 0 0 NotFound
   ReadINIStr $JobName $JLLoc "Name" "$JobNum"
   ReadINIStr $TempData $JLLoc "Status" "$JobNum"
   StrCmp $TempData "Done" Done
   WriteINIStr "$PluginsDir\Page.emp" "Field 3" "State" "$JobNum. $JobName"
   WriteINIStr "$PluginsDir\Page.emp" "Field 3" "Flags" "Disabled"
   Goto JobData
NotFound:
   MessageBox MB_OK|MB_ICONEXCLAMATION "Job number $JobNum could not be found because there are only $Last jobs in the job list."
   Quit
Done:
   MessageBox MB_OK|MB_ICONEXCLAMATION "$JobName has already been completed."
   Quit
JobData:
   StrCpy $ListData "Jobs in job list:"
   StrCpy $ListData1 ""
   StrCpy $First "1"
   StrCpy $TempJN 1
   Goto JobDataLoop
JobDataLoop:
   ReadINIStr $TempData $JLLoc "Name" "$TempJN"
   ReadINIStr $TempData1 $JLLoc "Status" "$TempJN"
   StrCpy $ListData "$ListData\r\n$TempJN. $TempData: $TempData1"
   StrCmp $TempData1 "Done" JobDataLoop2
   StrCmp $TempData1 "Deleted" JobDataLoop2
   StrCmp $First "1" JDL-First
   StrCpy $ListData1 "$ListData1|$TempJN. $TempData"
   Goto JobDataLoop2
JDL-First:
   StrCpy $ListData1 "$TempJN. $TempData"
   StrCpy $First "$TempJN. $TempData"
   Goto JobDataLoop2
JobDataLoop2:
   StrCmp $TempJN $Last WriteJobData
   IntOp $TempJN $TempJN + 1
   Goto JobDataLoop
WriteJobData:
   StrCpy $ListData1 "$ListData1|Follow the active job"
   WriteINIStr "$PluginsDir\Page.emp" "Field 7" "State" "$ListData"
   WriteINIStr "$PluginsDir\Page.emp" "Field 3" "ListItems" "$ListData1"
   ReadINIStr $TempData "$PluginsDir\Page.emp" "Field 3" "State"
   StrCmp $TempData "" 0 WriteJobData2
   WriteINIStr "$PluginsDir\Page.emp" "Field 3" "State" "$First"
   Goto WriteJobData2
WriteJobData2:
   StrCmp $ListData1 "|Follow the active job" 0 ShowPage
   WriteINIStr "$PluginsDir\Page.emp" "Field 3" "Flags" "Disabled"
   WriteINIStr "$PluginsDir\Page.emp" "Field 3" "ListItems" "No jobs available"
   WriteINIStr "$PluginsDir\Page.emp" "Field 3" "State" "No jobs available"
   WriteINIStr "$PluginsDir\Page.emp" "Field 5" "Flags" "Disabled"
   WriteINIStr "$PluginsDir\Page.emp" "Field 5" "ValidateText" "There are no jobs available for monitoring."
   WriteINIStr "$PluginsDir\Page.emp" "Field 5" "MinLen" "1"
   WriteINIStr "$PluginsDir\Page.emp" "Field 6" "Flags" "Disabled"
   Goto ShowPage
ShowPage:
   StrCpy $ActiveJobLast "0"
   StrCpy $First "0"
   StrCpy $R0 ""
   InstallOptions::Dialog /NOUNLOAD $PLUGINSDIR\Page.emp
FunctionEnd

Function Read
   ReadINIStr $TempData "$PluginsDir\Page.emp" "Settings" "State"
   StrCmp $TempData "0" Read
   StrCmp $TempData "3" 0 Abort
   ReadINIStr $TempData "$PluginsDir\Page.emp" "Field 3" "State"
   ReadINIStr $TempData1 "$PluginsDir\Page.emp" "Field 6" "HWND"
   StrCmp $TempData "Follow the active job" 0 Check-Enable
   StrCpy $ActiveJobLast "1"
   ReadINIStr $ButtonSave "$PluginsDir\Page.emp" "Field 6" "State"
   StrCmp $ButtonSave "0" Disable
   Goto Disable
Disable:
   Goto Abort
Check-Enable:
   StrCmp $ActiveJobLast "1" Enable
   Goto Abort
Enable:
   StrCmp $ButtonSave "0" Abort
   StrCpy $ActiveJobLast "0"
   Goto Abort
Abort:
   Abort
Read:
   ReadINIStr $TempData "$PluginsDir\Page.emp" "Field 3" "State"
   StrCmp $TempData "Follow the active job" Active
   ${WordFind} $TempData "." "+1}" $JobName
   ${WordFind} $TempData "." "+1{" $JobNum
   ${WordFind} $JobName " " "+1}" $JobName
   Goto Read2
Active:
   StrCpy $JobName $TempData
   Goto Read2
Read2:
   ReadINIStr $Eject "$PluginsDir\Page.emp" "Field 5" "State"
   StrCmp $Eject "" EjectOff
   IntCmp $Eject "0" EjectOff EjectOff
   IntCmp $Eject "1" WarnEject Read3 Read3
EjectOff:
   StrCpy $Eject "Off"
   Goto Read3
WarnEject:
   MessageBox MB_YESNO|MB_ICONQUESTION "WARNING: You have stated that you would like any frames taking longer than the average rendering time to be considered as having failed to render, so that another client program is sent back to try to render the frame. This means that approximately half of all frames would be considered to have failed to render, and many frames will therefore be rendered twice, wasting processing time. Are you sure you want to continue? (If you click no, the number of times the average rendering time a frame is allowed to render for before it is considered to have failed will be increased to two)." IDNO WarnEject2
   Goto Read3
WarnEject2:
   StrCpy $Eject "2"
   Goto Read3
Read3:
   ReadINIStr $Verify "$PluginsDir\Page.emp" "Field 6" "State"
FunctionEnd

Function Prepare2
   File /oname=$PluginsDir\Page2.emp "Monitor2.emp"
   InstallOptions::Dialog /NOUNLOAD $PLUGINSDIR\Page2.emp
FunctionEnd

Function Read2
   ReadINIStr $TempData "$PluginsDir\Page2.emp" "Field 3" "State"
   StrCmp $TempData 0 NoPercent
   IntCmp $TempData 100 Read2 Read2
   MessageBox MB_OK|MB_ICONINFORMATION "This program can not run at over 100% of its maximum recommended speed. The speed setting has been decreased to 100%."
   StrCpy $TempData "100"
   Goto Read2
NoPercent:
   MessageBox MB_OK|MB_ICONINFORMATION "If this program worked at 0% of its total potential speed, it would never do anything. The speed setting has been increased to 1% - the slowest allowed speed with a rest of 1 second between monitoring each frame."
   StrCpy $TempData "1"
   Goto Read2
Read2:
   StrCpy $FrameSleepPercent $TempData
   IntOp $TempData $TempData * 10
   IntOp $FrameSleep 1010 - $TempData
   ReadINIStr $LoopSleep "$PluginsDir\Page2.emp" "Field 6" "State"
   ReadINIStr $CFC "$PluginsDir\Page2.emp" "Field 8" "State"
FunctionEnd

Function Monitor
   HideWindow
   StrCmp $JobName "Follow the active job" Active
   WriteINIStr "$Temp\Temp.emp" "Temp" "Title" "Monitor for $JobName"
   StrCpy $ActiveJob "0"
   Goto ExecGUI
Active:
   WriteINIStr "$Temp\Temp.emp" "Temp" "Title" "Monitor - following the active job"
   StrCpy $ActiveJob "1"
   Goto ExecGUI
ExecGUI:
   Exec '"$ExeDir\GUI.exe" $Temp\Temp.emp'
   Goto GUIInitLoop
GUIInitLoop:
   Sleep 10
   ReadINIStr $TempData "$Temp\Temp.emp" "Temp" "Done"
   StrCmp $TempData "1" 0 GUIInitLoop
   StrCmp $JobName "Follow the active job" 0 GetHWND
   Call GetActiveJob
   Goto GetHWND
GetHWND:
   StrCpy $FirstRun "1"
   ReadINIStr $HWND "$Temp\Temp.emp" "Temp" "HWND"
   GetDlgItem $Field1 $HWND 1200
   GetDlgItem $Field2 $HWND 1201
   GetDlgItem $Field3 $HWND 1202
   GetDlgItem $Field4 $HWND 1203
   GetDlgItem $Field5 $HWND 1204
   GetDlgItem $Field6 $HWND 1205
   GetDlgItem $Field7 $HWND 1206
   GetDlgItem $Field8 $HWND 1207
   GetDlgItem $Field9 $HWND 1208
   GetDlgItem $Field10 $HWND 1209
   GetDlgItem $Field11 $HWND 1210
   GetDlgItem $Field12 $HWND 1211
   GetDlgItem $Field13 $HWND 1212
   GetDlgItem $Field14 $HWND 1213
   GetDlgItem $Field15 $HWND 1214
   SendMessage $Field2 ${WM_SETTEXT} 0 "STR:Job name: $JobName" $0
   SendMessage $Field3 ${WM_SETTEXT} 0 "STR:Job number: $JobNum" $0
   SendMessage $Field14 ${WM_SETTEXT} 0 "STR:Monitor speed: $FrameSleepPercent%" $0
   SendMessage $Field15 ${WM_SETTEXT} 0 "STR:Rest per loop: $LoopSleeps" $0
   ReadINIStr $Total $JLLoc "Total" "$JobNum"
   ReadINIStr $Start $JLLoc "Start" "$JobNum"
   SendMessage $Field9 ${WM_SETTEXT} 0 "STR:Rendering from frame $Start to frame $Total." $0
   ReadINIStr $Sleep $JLLoc "Sleep" "$JobNum"
   SendMessage $Field10 ${WM_SETTEXT} 0 "STR:Sleep time: $Sleeps" $0
   ReadINIStr $Priority $JLLoc "Priority" "$JobNum"
   SendMessage $Field11 ${WM_SETTEXT} 0 "STR:Priotiry: $Priority" $0
   ReadINIStr $Status $JLLoc "Status" "$JobNum"
   SendMessage $Field12 ${WM_SETTEXT} 0 "STR:Status: $Status" $0
   StrCmp $Status "Rendering" Job-Rendering
   StrCmp $Status "Error" Error4E
   StrCmp $Status "" Error4R
   StrCmp $ActiveJob "1" Status-GUI
   StrCmp $Status "Done" Frame-Verifier
   Goto Status-GUI
Status-GUI:
   IntOp $TempData $Total - $Start
   SendMessage $Field6 ${WM_SETTEXT} 0 "STR:Not started yet: $TempData (100%)" $0
   SendMessage $Field4 ${WM_SETTEXT} 0 "STR:Done: 0 (0%)" $0
   SendMessage $Field5 ${WM_SETTEXT} 0 "STR:Rendering: 0 (0%)" $0
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:Waiting for job to start..." $0
   Goto Status-Loop
Status-Loop:
   ReadINIStr $Status $JLLoc "Status" "$JobNum"
   SendMessage $Field12 ${WM_SETTEXT} 0 "STR:Status: $Status" $0
   StrCmp $Status "Not Started Yet" 0 Job-Rendering
   Call CheckClose
   Sleep 100
   Goto Status-Loop
Error4E:
   MessageBox MB_OK|MB_ICONEXCLAMATION "One of the computers on the network has identified an error with the job. This may be due to incorrectly entered script, terrain and world file locations. If this error persists, please contact Emptosoft, quoting the error code 4E."
   Quit
Error4R:
   MessageBox MB_OK|MB_ICONEXCLAMATION "The ERTfTNV Monitor cannot read the job list. This may be because it is at an unavailable network location, or because it has been deleted. If this error persists, please contact Emptosoft, quoting the error code 4R."
   Quit
Job-Rendering:
   StrCpy $FramesDone 0
   IntOp $TempData $Start - 1
   IntOp $RTotal $Total - $TempData
   Goto Pre-Monitor-Loop
Pre-Monitor-Loop:
   StrCpy $SearchFrame "$Start"
   StrCpy $FramesDone "0"
   StrCpy $FramesRendering "0"
   StrCpy $FramesNSY "0"
   StrCpy $AvgNum "0"
   StrCpy $AvgTotal "0"
   Goto Monitor-Loop
Monitor-Loop:
   Call CheckClose
   StrCmp $FirstRun "1" Monitor-Loop1
   StrCmp $CFC "0" Monitor-Loop1
   StrCmp $CCache "1" Monitor-Loop1
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:Checking for changes..." $0
   ReadINIStr $TempData $JLLoc "Change" "$JobNum"
   StrCmp $TempData "0" Extra-Loop3
   WriteINIStr $JLLoc "Change" "$JobNum" "0"
   StrCpy $CCache "1"
   Goto Monitor-Loop1
Monitor-Loop1:
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:Monitoring frame $SearchFrame..." $0
   ReadINIStr $TempData $JLLoc "Job $JobNum" "$SearchFrame"
   StrCmp $TempData "D" Done
   StrCmp $TempData "V" Done
   StrCmp $TempData "R" Rendering
   StrCmp $TempData "N" NotStartedYet
   StrCmp $TempData "E" NotStartedYet Monitor-Loop2
Done:
   IntOp $FramesDone $FramesDone + 1
   Goto Monitor-Loop2
Rendering:
   IntOp $FramesRendering $FramesRendering + 1
   StrCmp $Eject "Off" Monitor-Loop2
   StrCmp $FirstRun "1" Monitor-Loop2
   Push $R0
   ReadINIStr $R0 $JLLoc "ST $JobNum" "$SearchFrame"
   Call GetTimeNow
   IntOp $TempData $TempData - $R0
   IntOp $R0 $AvgRaw * $Eject
   IntCmp $TempData $R0 0 Monitor-Loop2
   Pop $R0
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:Restarting frame $SearchFrame..." $0
   IntOp $FramesRendering $FramesRendering - 1
   IntOp $FramesNSY $FramesNSY + 1
   WriteINIStr $JLLoc "Job $JobNum" "$SearchFrame" "N"
   DeleteINIStr $JLLoc "ST $JobNum" "$SearchFrame"
   Call Write-E
   Goto Monitor-Loop2
NotStartedYet:
   IntOp $FramesNSY $FramesNSY + 1
   Goto Monitor-Loop2
Monitor-Loop2:
   ReadINIStr $TempData $JLLoc "TfJ $JobNum" "$SearchFrame"
   StrCmp $TempData "" Monitor-Loop3
   IntOp $AvgNum $AvgNum + 1
   IntOp $AvgTotal $AvgTotal + $TempData
   Goto Monitor-Loop3
Monitor-Loop3:
   StrCmp $SearchFrame $Total Extra-Loop
   IntOp $SearchFrame $SearchFrame + 1
   Sleep $FrameSleep
   Goto Monitor-Loop
Quit:
   Quit
Extra-Loop:
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:Carrying out calculations..." $0
   IntCmp $RTotal "1000" LPercent 0 LPercent
   StrLen $TempData $RTotal
   StrCpy $TempData1 "1"
   StrCpy $Percent "1"
   Goto ZeroLoop
ZeroLoop:
   StrCpy $Percent "$Percent0"
   StrCmp $TempData $TempData1 Percent
   IntOp $TempData1 $TempData1 + 1
   Goto ZeroLoop
Percent:
   IntCmp $RTotal "1000" LargeNF 0 LargeNF
   StrCpy $TempData1 "$Percent000000"
;or IntOp $TempData1 $Percent * 1000000
   Goto Percent1
LargeNF:
   StrCpy $TempData1 "$Percent00"
;or IntOp $TempData1 $Percent * 100
   Goto Percent1
Percent1:
   IntOp $TempData $TempData1 / $RTotal
   IntOp $PercentDone $FramesDone * $TempData
   IntOp $PercentRendering $FramesRendering * $TempData
   IntOp $PercentNSY $FramesNSY * $TempData
   IntCmp $RTotal "1000" LargeNF2 0 LargeNF2
   StrCpy $TempData1 "10000"
   Goto Percent2
LargeNF2:
   StrCpy $TempData1 "Skip"
   Goto Percent2
Percent2:
   IntOp $PercentDone $PercentDone / $Percent
   StrCpy $TempData $PercentDone
   Call Divide10
   StrCpy $PercentDone $TempData
   IntOp $PercentRendering $PercentRendering / $Percent
   StrCpy $TempData $PercentRendering
   Call Divide10
   StrCpy $PercentRendering $TempData
   IntOp $PercentNSY $PercentNSY / $Percent
   StrCpy $TempData $PercentNSY
   Call Divide10
   StrCpy $PercentNSY $TempData
   Goto Extra-Loop2
LPercent:
   IntOp $PercentDone $FramesDone * 10000
   IntOp $PercentRendering $FramesRendering * 10000
   IntOp $PercentNSY $FramesNSY * 10000
   IntOp $PercentDone $PercentDone / $RTotal
   IntOp $PercentRendering $PercentRendering / $RTotal
   IntOp $PercentNSY $PercentNSY / $RTotal
   StrCpy $TempData $PercentDone "" -1
   StrCpy $TempData1 $PercentDone 1 -2
   IntOp $PercentDone $PercentDone / 100
   StrCmp $Tempdata1 "" LPZ
   IntCmp $TempData "5" 0 LPercent2
   IntCmp $TempData1 "9" LPU
   IntOp $TempData1 $TempData1 + 1
   Goto LPercent2
LPZ:
   StrCpy $TempData1 "0"
   Goto LPercent2
LPU:
   StrCpy $TempData1 "0"
   IntOp $PercentDone $PercentDone + 1
   Goto LPercent2
LPercent2:
   StrCpy $PercentDone "$PercentDone.$TempData1"
   StrCpy $TempData $PercentRendering "" -1
   StrCpy $TempData1 $PercentRendering 1 -2
   IntOp $PercentRendering $PercentRendering / 100
   StrCmp $Tempdata1 "" LP2Z
   IntCmp $TempData "5" 0 LPercent3
   IntCmp $TempData1 "9" LP2U
   IntOp $TempData1 $TempData1 + 1
   Goto LPercent3
LP2Z:
   StrCpy $TempData1 "0"
   Goto LPercent3
LP2U:
   StrCpy $TempData1 "0"
   IntOp $PercentRendering $PercentRendering + 1
   Goto LPercent3
LPercent3:
   StrCpy $PercentRendering "$PercentRendering.$TempData1"
   StrCpy $TempData $PercentNSY "" -1
   StrCpy $TempData1 $PercentNSY 1 -2
   IntOp $PercentNSY $PercentNSY / 100
   StrCmp $Tempdata1 "" LP3Z
   IntCmp $TempData "5" 0 LPercent4
   IntCmp $TempData1 "9" LP3U
   IntOp $TempData1 $TempData1 + 1
   Goto LPercent4
LP3Z:
   StrCpy $TempData1 "0"
   Goto LPercent4
LP3U:
   StrCpy $TempData1 "0"
   IntOp $PercentNSY $PercentNSY + 1
   Goto LPercent4
LPercent4:
   StrCpy $PercentNSY "$PercentNSY.$TempData1"
   Goto Extra-Loop2
Extra-Loop2:
   SendMessage $Field1 "0x402" $PercentDone 0 $0
   SendMessage $Field4 ${WM_SETTEXT} 0 "STR:Done: $FramesDone ($PercentDone%)" $0
   SendMessage $Field5 ${WM_SETTEXT} 0 "STR:Rendering: $FramesRendering ($PercentRendering%)" $0
   SendMessage $Field6 ${WM_SETTEXT} 0 "STR:Not started yet: $FramesNSY ($PercentNSY%)" $0
   Call Average
   SendMessage $Field7 ${WM_SETTEXT} 0 "STR:Average rendering time: $Avg" $0
   SendMessage $Field8 ${WM_SETTEXT} 0 "STR:(Based on $AvgNum frame(s))" $0
   StrCmp $FirstRun "0" Extra-Loop3
   StrCmp $Eject "Off" FirstRun-End
   IntCmp $AvgNum "5" 0 FirstRun-End
   WriteINIStr $JLLoc "Change" "$JobNum" "1"
   Goto Extra-Loop3
FirstRun-End:
   StrCpy $FirstRun "0"
   Goto Extra-Loop3
NextJob:
   Call GetActiveJob
   Goto GetHWND
Extra-Loop3:
   StrCpy $CCache "0"
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:Checking status of job..." $0
   ReadINIStr $Status $JLLoc "Status" "$JobNum"
   StrCmp $Status "" Error4R
   StrCmp $ActiveJob "1" 0 Extra-Loop5
   StrCmp $Status "Done" NextJob
   StrCmp $Status "Error" NextJob
   Goto Extra-Loop4
Extra-Loop5:
   StrCmp $Status "Done" Frame-Verifier
   StrCmp $Status "Error" Error4E
   Goto Extra-Loop4
Extra-Loop4:
   StrCmp $FirstRun "1" FirstRun-End-Loop
   Sleep $FrameSleep
   Call LoopSleep
   Goto Pre-Monitor-Loop
FirstRun-End-Loop:
   StrCpy $FirstRun "0"
   Goto Pre-Monitor-Loop
Frame-Verifier:
   StrCmp $Verify "0" Verified
   ReadINIStr $OutputLoc $JLLoc "OutputLoc" "$JobNum"
   StrCpy $SearchFrame "$Start"
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:Preparing to verify files..." $0
   StrCpy $VerF "0"
   StrCpy $SearchFrame4 $SearchFrame
   StrLen $TempData $SearchFrame4
   StrCmp $TempData "4" 0 Add
   Goto Frame-Verifier-Loop
Frame-Verifier-Loop:
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:Verifying $OutputLoc$SearchFrame4.bmp" $0
   Call CheckClose
   ReadINIStr $TempData $JLLoc "Job $JobNum" "$SearchFrame"
   StrCmp $TempData "V" Verified-Frame
   IfFileExists $OutputLoc$SearchFrame4.bmp 0 Failed-Frame
   WriteINIStr $JLLoc "Job $JobNum" "$SearchFrame" "V"
   Goto Verified-Frame
Failed-Frame:
   StrCpy $VerF "1"
   Goto Verified-Frame
Verified-Frame:
   StrCmp $SearchFrame $Total Pre-Verified
   IntOp $SearchFrame $SearchFrame + 1
   StrCpy $SearchFrame4 $SearchFrame
   StrLen $TempData $SearchFrame4
   StrCmp $TempData "4" 0 Add
   StrCmp $TempData "1" Cancel-F-V-L
   Goto Frame-Verifier-Loop
Cancel-F-V-L:
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:'Cancel' button pressed. Please see the dialog box, which may have appeared behind this window..." $0
   MessageBox MB_YESNO|MB_ICONQUESTION "Are you sure you want to close the ERTfTNV Monitor?" IDYES Quit
   StrCpy $TempData "0"
   nxs::Destroy /NOUNLOAD
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:Resuming verification..." $0
   Goto Frame-Verifier-Loop
Add:
   StrCpy $SearchFrame4 "0$SearchFrame4"
   StrLen $TempData $SearchFrame4
   StrCmp $TempData "4" 0 Add
   Goto Frame-Verifier-Loop
Pre-Frame-Verifier-Loop:
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:Some frames could not be verified. Verification of unverified frames will begin in 5s..." $0
   Sleep 5000
   Goto Frame-Verifier-Loop
Pre-Verified:
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:All output files have been verified..." $0
Verified:
   StrCmp $VerF "1" Pre-Frame-Verifier-Loop
   MessageBox MB_OK|MB_ICONINFORMATION "Render of $JobName (containing $Total frames - render started with $Start) is complete. The average rendering time was $Avg (based on $AvgNum frames). Click 'OK' to shutdown the monitor."
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:The monitor is now off..." $0
FunctionEnd

Function End
FunctionEnd

Section -VOID
SectionEnd

Function .onGUIEnd
   Delete $Temp\Temp.emp
FunctionEnd

Function LastSymbol
   StrLen $0 $TempData
   StrCmp $0 "1" End
   StrCpy $TempData "$TempData|"
   StrCpy $TempData1 "0"
   Goto NumberLoop
NumberLoop:
   ${WordFind2X} $TempData "$TempData1" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   StrCmp $TempData1 "9" Letters
   IntOp $TempData1 $TempData1 + 1
   Goto NumberLoop
Letters:
   ${WordFind2X} $TempData "a" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "b" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "c" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "d" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "e" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "f" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "g" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "h" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "i" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "j" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "k" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "l" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "m" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "n" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "o" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "p" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "q" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "r" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "s" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "t" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "u" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "v" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "w" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "x" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "y" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   ${WordFind2X} $TempData "z" "|" "-1" $1
   StrLen $0 $1
   StrCmp $0 "1" End
   StrCpy $TempData "0"
   Goto End
End:
   StrCpy $TempData $1
FunctionEnd

Function Divide10
;$TempData = String
;$TempData1 = Number to divide by (must be 10, 100, 1000 etc.)
;$1 = Length truncation
;No error checks
   StrCmp $TempData1 "Skip" End
   StrLen $1 $TempData1
;Work out string truncation
   IntOp $1 $1 - 1
;Truncate String
   StrCpy $2 $TempData "-$1"
;Get rounding digit
   IntOp $1 $1 - 1
;Remove characters after rounding digit
   StrCpy $3 $TempData "-$1"
;Remove characters before rounding digit
   StrLen $4 $3
   IntOp $4 $4 - 1
   StrCpy $3 $3 "" $4
   IntCmp $3 "5" 0 Copy
   IntOp $2 $2 + 1
   Goto Copy
Copy:
   StrCpy $TempData $2
   StrCmp $TempData "" 0 End
   StrCpy $TempData "0"
   Goto End
End:
FunctionEnd

Function Void
   StrLen $4 $TempData
   StrCpy $2 "|"
   StrCpy $5 "$TempData|"
   StrCpy $3 "0"
   Goto NumberLoop
NumberLoop:
   ${WordFind2X} $5 "$3" "$2" "-1" $1
   StrLen $0 $1
   MessageBox MB_OK "NL: 2=$2 3=$3 1=$1 0=$0."
   StrCmp $0 "$TempData1" SingularLoopPrep
   StrCmp $0 $4 ExtraNumberLoop
   IntOp $3 $3 + 1
   Goto NumberLoop
ExtraNumberLoop:
   IntOp $4 $4 - 1
   StrCpy $2 $1
   StrCpy $5 "|$5"
   ${WordFind2X} $TempData "|" "$3" "-1" $1
SingularLoopPrep:
   StrCpy $TempData $1
   StrCpy $TempData "|$TempData"
   StrCpy $3 "0"
   Goto SingularLoop
SingularLoop:
   ${WordFind2X} $TempData "|" "$3" "+1" $1
   StrLen $0 $1
   MessageBox MB_OK "SL: 2=$2 3=$3 1=$1 0=$0."
   StrCmp $0 "1" End
   IntOp $3 $3 + 1
   Goto SingularLoop
End:
   StrCpy $TempData $1
FunctionEnd

Function GetActiveJob
   Goto Start
Start:
   StrCpy $JobNum "1"
   Goto StatusDetectLoop
StatusDetectLoop:
   ReadINIStr $Status $JLLoc "Status" "$JobNum"
   StrCmp $Status "Rendering" End
   StrCmp $Status "Not Started Yet" End
   IntCmp $JobNum $Last NoJobs
   IntOp $JobNum $JobNum + 1
   Goto StatusDetectLoop
NoJobs:
   SendMessage $Field2 ${WM_SETTEXT} 0 "STR:Job name: None" $0
   SendMessage $Field3 ${WM_SETTEXT} 0 "STR:$Last jobs in list" $0
   SendMessage $Field14 ${WM_SETTEXT} 0 "STR:Monitor speed: $FrameSleepPercent%" $0
   SendMessage $Field15 ${WM_SETTEXT} 0 "STR:Rest per loop: $LoopSleeps" $0
   SendMessage $Field9 ${WM_SETTEXT} 0 "STR:No active jobs" $0
   SendMessage $Field10 ${WM_SETTEXT} 0 "STR:Sleep time: 10s" $0
   SendMessage $Field11 ${WM_SETTEXT} 0 "STR:Priotiry: None" $0
   SendMessage $Field12 ${WM_SETTEXT} 0 "STR:Status: No active jobs" $0
   SendMessage $Field6 ${WM_SETTEXT} 0 "STR:Not started yet: -" $0
   SendMessage $Field4 ${WM_SETTEXT} 0 "STR:Done: -" $0
   SendMessage $Field5 ${WM_SETTEXT} 0 "STR:Rendering: -" $0
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:Waiting for more jobs..." $0
   Goto NoJobLoop
NoJobLoop:
   ReadINIStr $TempData $JLLoc "Status" "Last"
   StrCmp $TempData $Last 0 Start
   Sleep 10000
   Goto NoJobLoop
End:
   ReadINIStr $JobName $JLLoc "Name" "$JobNum"
FunctionEnd

Function CheckClose
   ReadINIStr $TempData "$Temp\Temp.emp" "Temp" "Close"
   StrCmp $TempData "1" 0 End
   Quit
End:
FunctionEnd

Function LoopSleep
   IntCmp $LoopSleep "0" End End
   StrCpy $TempData1 $LoopSleep
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:Sleeping ($TempData1s left until next check)..." $0
   Goto LoopSleepLoop
LoopSleepLoop:
   IntOp $TempData1 $TempData1 - 1
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:Sleeping ($TempData1s left until next check)..." $0
   Sleep 1000
   Call CheckClose
   StrCmp $TempData1 "0" End LoopSleepLoop
End:
FunctionEnd

Function Average
   IntCmp $AvgNum "5" 0 FrameLack
   IntOp $TempData $AvgTotal / $AvgNum
   StrCpy $AvgRaw $TempData
   StrCpy $TempData1 "0"
   Goto Seconds-Loop
Seconds-Loop:
   IntCmp $TempData 60 0 Seconds-Copy
   IntOp $TempData $TempData - 60
   IntOp $TempData1 $TempData1 + 1
   Goto Seconds-Loop
Seconds-Copy:
   StrCpy $Avg "$TempDatas"
   StrCmp $TempData1 "0" End
   StrCpy $TempData $TempData1
   StrCpy $TempData1 "0"
   Goto Minutes-Loop
Minutes-Loop:
   IntCmp $TempData 60 0 Minutes-Copy
   IntOp $TempData $TempData - 60
   IntOp $TempData1 $TempData1 + 1
   Goto Minutes-Loop
Minutes-Copy:
   StrCpy $Avg "$TempDatam $Avg"
   StrCmp $TempData1 "0" End
   StrCpy $TempData $TempData1
   StrCpy $TempData1 "0"
   Goto Hours-Loop
Hours-Loop:
   IntCmp $TempData 24 0 Hours-Copy
   IntOp $TempData $TempData - 24
   IntOp $TempData1 $TempData1 + 1
   Goto Hours-Loop
Hours-Copy:
   StrCpy $Avg "$TempDatah $Avg"
   StrCmp $TempData1 "0" End
   StrCpy $Avg "$Tempdata1d $Avg"
   Goto End
FrameLack:
   StrCpy $Avg "Not yet reliable"
   Goto End
End:
FunctionEnd

Function GetTimeNow
   ${GetTime} "" "L" $OD1 $OD2 $OD3 $Waste $OT1 $OT2 $OT3
   IntOp $OD3 $OD3 - 2000
   IntOp $TempData $OD3 / 4
   IntOp $OD1 $OD1 + $TempData
   StrCpy $OD7 $OD3
   Goto Leap-Check-Loop
Leap-Check-Loop:
   IntCmp $OD7 2008 Y1L Leap-End
   IntOp $OD7 $OD7 - 4
   Goto Leap-Check-Loop
Y1L:
   IntCmp $OD2 "3" Leap-End 0 Leap-End
   IntOp $OD1 $OD1 - 1
   Goto Leap-End
Leap-End:
   IntOp $OD3 $OD3 * 365
   IntOp $OD1 $OD3 + $OD1
   StrCmp $OD2 "01" Month-End Feb2
Feb2:
   IntOp $OD1 $OD1 + 31
   StrCmp $OD2 "02" Month-End
   Goto Mar2
Mar2:
   IntOp $OD1 $OD1 + 28
   StrCmp $OD2 "03" Month-End
   Goto Apr2
Apr2:
   IntOp $OD1 $OD1 + 31
   StrCmp $OD2 "04" Month-End
   Goto May2
May2:
   IntOp $OD1 $OD1 + 30
   StrCmp $OD2 "05" Month-End
   Goto Jun2
Jun2:
   IntOp $OD1 $OD1 + 31
   StrCmp $OD2 "06" Month-End
   Goto Jul2
Jul2:
   IntOp $OD1 $OD1 + 30
   StrCmp $OD2 "07" Month-End
   Goto Aug2
Aug2:
   IntOp $OD1 $OD1 + 31
   StrCmp $OD2 "08" Month-End
   Goto Sep2
Sep2:
   IntOp $OD1 $OD1 + 31
   StrCmp $OD2 "09" Month-End
   Goto Oct2
Oct2:
   IntOp $OD1 $OD1 + 30
   StrCmp $OD2 "10" Month-End
   Goto Nov2
Nov2:
   IntOp $OD1 $OD1 + 31
   StrCmp $OD2 "11" Month-End
   Goto Dec2
Dec2:
   IntOp $OD1 $OD1 + 30
   Goto Month-End
Month-End:
   IntOp $OD1 $OD1 * 24
   IntOp $OT1 $OT1 + $OD1
   IntOp $OT1 $OT1 * 60
   IntOp $OT2 $OT1 + $OT2
   IntOp $OT2 $OT2 * 60
   IntOp $OT3 $OT2 + $OT3
   StrCpy $TempData $OT3
FunctionEnd

Function Write-E
   StrCpy $EJob $JobNum
   StrCpy $EFra $SearchFrame
   ReadINIStr $TempData $JLLoc "Status" "$JobNum"
   WriteINIStr $JLLoc "Status" "$JobNum" "Rendering"
   StrCmp $TempData "Done" Job-Add Frame-Add
Frame-Loop:
   ReadINIStr $TempData $JLLoc "Job $EJob" "$EFra"
   StrCmp $TempData "N" Frame-Loop2
   StrCmp $TempData "E" Frame-Loop3 Frame-Add
Frame-Loop2:
   WriteINIStr $JLLoc "Job $EJob" "$EFra" "E"
   WriteINIStr $JLLoc "E $EJob : $Efra" "Job" "$JobNum"
   WriteINIStr $JLLoc "E $EJob : $EFra" "Frame" "$SearchFrame"
   Goto End-E
Frame-Loop3:
   ReadINIStr $TempData $JLLoc "E $EJob : $EFra" "Job"
   IntCmp $JobNum $TempData 0 Frame-Loop2 End-E
   ReadINIStr $TempData $JLLoc "E $EJob : $EFra" "Frame"
   IntCmp $SearchFrame $TempData End-E Frame-Loop2 End-E
End-E:
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:Frame $SearchFrame successfully restarted..." $0
   Goto End
Frame-Add:
   StrCmp $EFra $Total Job-Add
   IntOp $EFra $EFra + 1
   Goto Frame-Loop
Job-Loop:
   ReadINIStr $TempData $JLLoc "Status" "$EJob"
   StrCmp $TempData "Rendering" Job-Found
   StrCmp $TempData "Not Started Yet" Job-Found
   Goto Job-Add
Job-Found:
   StrCpy $EFra "1"
   Goto Frame-Loop
Job-Add:
   ReadINIStr $TempData $JLLoc "Status" "Last"
   StrCmp $EJob $TempData No-Jobs
   IntOp $EJob $EJob + 1
   Goto Job-Loop
No-Jobs:
   SendMessage $Field13 ${WM_SETTEXT} 0 "STR:All jobs are finished. Frame $SearchFrame will be rendered the next time a Client program is started..." $0
   Goto End
End:
   WriteINIStr $JLLoc "Change" "$JobNum" "1"
FunctionEnd

;> Set progress bar to 50 SendMessage $Field1 "0x402" 50 0 $0
;> Set text of a label SendMessage $Field10 ${WM_SETTEXT} 0 "STR:Preparation done!" $0