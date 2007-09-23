OutFile "Client.exe"
Caption "ERFM (Beta) Client"
Icon "E27RFM (Final).ico"
XPStyle On
BrandingText /TRIMRIGHT "ERFM"
VIAddVersionKey /LANG=1033-ENGLISH "LegalCopyright" "See www.emptosoft.plus.com/licences"
VIAddVersionKey /LANG=1033-ENGLISH "ProductName" "Emptosoft Render Farm Manager (Beta)"
VIAddVersionKey /LANG=1033-ENGLISH "CompanyName" "Emptosoft"
VIAddVersionKey /LANG=1033-ENGLISH "FileDescription" "Emptosoft Render Farm Manager Client (Version 0.4 - Beta)"
VIAddVersionKey /LANG=1033-ENGLISH "FileVersion" "0.4"
VIProductVersion "0.4.0.0"
Page instfiles
InstallColors 2C85C6 FFFFFF
!include "defines.nsh"
!include "FileFunc.nsh"
!include "WriteEnvStr.nsh"
!insertmacro GetTime
Var TempData
Var TGLoc
Var TGLocS
Var JLLoc
Var JSNum
Var World
Var Terrain
Var Script
Var Sleep
Var Finish
Var ErrorCode
Var TGErrorFile
Var FrameNum
Var SleepMS
Var Waste
Var T1
Var T2
Var T3
Var T4
Var T5
Var T6
Var D1
Var D2
Var D3
Var D4
Var D5
Var D6
Var OT1
Var OT2
Var OT3
Var OT4
Var OT5
Var OT6
Var OD1
Var OD2
Var OD3
Var OD4
Var OD5
Var OD6
Var OD7
Var OD8
Var FirstRun
Var FNow
Var Name
Var Run
Var Rendering
Var Start
Var Total
Var Percent
Var PercentDone
Var Duration
Var TempData1
Var Leap
Var Priority
Var Last
Var EJob
Var EFra
Var Function
Var OutputLoc
SubCaption 3 ": Rendering..."
SubCaption 4 ": Closing..."
AutoCloseWindow True

Function .onInit
   SetShellVarContext All
   InitPluginsDir
   StrCpy $FNow "0"
   StrCpy $FirstRun "1"
   StrCpy $Rendering "0"
   IfFileExists $APPDATA\Emptosoft\Settings.emp Continue
   CreateDirectory $APPDATA\Emptosoft
   Goto Continue
Continue:
   ClearErrors
   ReadINIStr $TGLoc $APPDATA\Emptosoft\Settings.emp "Rendering Tool for Terragen Network Version T2TP Beta" "TGLoc"
   IfErrors TGLocBox TGLocCheck
TGLocBox:
   MessageBox MB_OK|MB_ICONINFORMATION "Please specify the location of tgdcli.exe."
   Dialogs::Open "tgdcli.exe|tgdcli.exe" "" "Terragen Location..." "" ${VAR_R0}
   StrCpy $TGLoc $R0
   StrCmp $TGLoc "0" Quit
   WriteINIStr $APPDATA\Emptosoft\Settings.emp "Rendering Tool for Terragen Network Version T2TP Beta" "TGLoc" "$TGLoc"
   Goto TGLocCheck
TGLocCheck:
   IfFileExists $TGLoc JobCheck NoTG
NoTG:
MessageBox MB_OK|MB_ICONEXCLAMATION "Terragen cannot be found at the location you specified. Please try again."
Goto TGLocBox
JobCheck:
   StrCpy $TGLocS $TGLoc -10
   ClearErrors
   ReadINIStr $JLLoc $APPDATA\Emptosoft\Settings.emp "Rendering Tool for Terragen Network Version T2TP Beta" "JLLoc"
   IfErrors JobListBox JobLocCheck
JobListBox:
   MessageBox MB_OK|MB_ICONINFORMATION "Please specify the location of the Job List file."
   Dialogs::Open "Emptosoft Settings File|*.emp" "" "Job list Location..." "" ${VAR_R0}
   StrCpy $JLLoc $R0
   StrCmp $JLLoc "0" Quit
   WriteINIStr $APPDATA\Emptosoft\Settings.emp "Rendering Tool for Terragen Network Version T2TP Beta" "JLLoc" "$JLLoc"
   Goto JobLocCheck
JobLocCheck:
   IfFileExists $JLLoc JLRead NoJL
NoJL:
   MessageBox MB_OK|MB_ICONEXCLAMATION "The job list cannot be found at the location you specified. Please try again."
   Goto JobListBox
JLRead:
   Call FindJob
   StrCpy $FirstRun "0"
   Goto End
Quit:
   Quit
End:
FunctionEnd

Section -Run
   GetDlgItem $TempData $HWNDPARENT 1
   EnableWindow $TempData 1
   IntOp $SleepMS $Sleep * 1000
   SetDetailsPrint Both
   DetailPrint "Creating icon..."
   SetDetailsPrint None
   NotifyIcon::Icon /NOUNLOAD "yit" 103 "Emptosoft Rendering Tool for Terragen Network Version"
   Goto SectionStart
SectionStart:
   StrCmp $FNow "1" FinishNow
   NotifyIcon::Icon /NOUNLOAD "n" "Emptosoft Rendering Tool for Terragen Network Version" "Searching for frames..."
   SetDetailsPrint Both
   DetailPrint "Searching for frames..."
   SetDetailsPrint None
   IntOp $TempData $Total - $Start
   IntOp $Percent $TempData / 100
   StrCmp $FrameNum "" 0 FrameSearchLoop
   IntOp $TempData $Start - 1
   StrCpy $FrameNum "$TempData"
   Goto FrameSearchLoop
FrameSearchLoop:
   IntOp $FrameNum $FrameNum + 1
   IntOp $TempData $FrameNum - $Start
   IntOp $PercentDone $TempData / $Percent
   RealProgress::SetProgress /NOUNLOAD $PercentDone
   ReadINIStr $TempData $JLLoc "Job $JSNum" "$FrameNum"
   StrCmp $TempData "N" Render
   StrCmp $TempData "D" FSLDone
   StrCmp $TempData "R" FSLRendering
   StrCmp $TempData "E" E-Code
   StrCmp $FrameNum $Total NewJob
   Goto FrameSearchLoop
FSLDone:
   SetDetailsPrint Both
   DetailPrint "Frame $FrameNum: Done"
   SetDetailsPrint None
   StrCmp $FrameNum $Total NewJob
   Goto FrameSearchLoop
FSLRendering:
   SetDetailsPrint Both
   DetailPrint "Frame $FrameNum: Rendering"
   SetDetailsPrint None
   StrCmp $FrameNum $Total NewJob
   Goto FrameSearchLoop
E-Code:
   WriteINIStr $JLLoc "Job $JSNum" "$FrameNum" "N"
   SetDetailsPrint Both
   DetailPrint "Another instance of the ERTfTNVC has abandoned a previous frame..."
   DetailPrint "Retrieving data about the frame..."
   SetDetailsPrint None
   StrCpy $EJob $JSNum
   StrCpy $EFra $FrameNum
   ReadINIStr $JSNum $JLLoc "E $EJob : $EFra" "Job"
   ReadINIStr $World $JLLoc "World" "$JSNum"
   ReadINIStr $Terrain $JLLoc "Terrain" "$JSNum"
   ReadINIStr $Script $JLLoc "Script" "$JSNum"
   ReadINIStr $Sleep $JLLoc "Sleep" "$JSNum"
   ReadINIStr $Finish $JLLoc "Finish" "$JSNum"
   ReadINIStr $Name $JLLoc "Name" "$JSNum"
   ReadINIStr $Priority $JLLoc "Priority" "$JSNum"
   ReadINIStr $Run $JLLoc "Run" "$JSNum"
   ReadINIStr $Start $JLLoc "Start" "$JSNum"
   ReadINIStr $Total $JLLoc "Total" "$JSNum"
   ReadINIStr $OutputLoc $JLLoc "OutputLoc" "$JSNum"
   ReadINIStr $FrameNum $JLLoc "E $EJob : $EFra" "Frame"
   DeleteINISec $JLLoc "E $EJob : $EFra"
   SetDetailsPrint Both
   DetailPrint "Going back to $Name, frame $FrameNum..."
   SetDetailsPrint None
   IntOp $FrameNum $FrameNum - 1
   Goto FrameSearchLoop
NewJob:
   SetDetailsPrint Both
   DetailPrint "Job done..."
   DetailPrint "Finding new job..."
   SetDetailsPrint None
   WriteINIStr $JLLoc "Status" "$JSNum" "Done"
   StrCpy $FrameNum ""
   Call FindJob
   Goto SectionStart
Render:
   WriteINIStr $JLLoc "Job $JSNum" "$FrameNum" "R"
   WriteINIStr $JLLoc "Change" "$JSNum" "1"
   SetDetailsPrint Both
   DetailPrint "Frame $FrameNum: Not Started Yet"
   DetailPrint "Rendering frame $FrameNum..."
   SetDetailsPrint None
   StrCpy $R0 $FrameNum
   StrCpy $R1 $Name
   NotifyIcon::Icon /NOUNLOAD "n" "Emptosoft Rendering Tool for Terragen Network Version" "Rendering frame $R0 from $R1..."
   Push "TERRAGEN_PATH"
   Push "$TGLocS"
   Call WriteEnvStr
   FileWrite $TempData '"$TGLoc" "$World" -hide -exit -r -f $R0'
   FileClose $TempData
   ${GetTime} "" "L" $D1 $D2 $D3 $Waste $T1 $T2 $T3
   StrCpy $Function "Start"
   StrCpy $D6 "0"
   Call SubTime
   SetDetailsPrint Both
   DetailPrint "Started rendering at $T1:$T2:$T3 ($D1/$D2/$D3)..."
   DetailPrint "Rendering frame $FrameNum from $Name..."
   SetDetailsPrint None
   StrCpy $Rendering "1"
   StrCmp $OutputLoc "" 0 OutputLoc
   ExecPri::ExecWait '"$TGLoc" -p "$World" -hide -exit -r -f $R0' "$Priority"
   Goto Render2
OutputLoc:
   ExecPri::ExecWait '"$TGLoc" -p "$World" -o "$OutputLoc" -hide -exit -r -f $R0' "$Priority"
   Goto Render2
Render2:
   Pop $TempData
   SetDetailsPrint Both
   DetailPrint "Carrying out calculations..."
   SetDetailsPrint None
   WriteINIStr $JLLoc "Job $JSNum" "$FrameNum" "D"
   DeleteINIStr $JLLoc "ST $JSNum" "$FrameNum"
   WriteINIStr $JLLoc "Change" "$JSNum" "1"
   StrCpy $Rendering "0"
   ${GetTime} "" "L" $D4 $D5 $D6 $Waste $T4 $T5 $T6
   StrCpy $Function "Sub"
   Call SubTime
   SetDetailsPrint Both
   DetailPrint "Frame $R0 successully rendered..."
   DetailPrint "  Details:"
   DetailPrint "  ·Completed at: $T4:$T5:$T6 ($D4/$D5/$D6)..."
   DetailPrint "  ·Duration of render: $Duration..."
   SetDetailsPrint None
   NotifyIcon::Icon /NOUNLOAD "n" "Emptosoft Rendering Tool for Terragen Network Version" "Frame $R0 from $R1 rendered..."
   SetDetailsPrint Both
   DetailPrint "Sleeping for $Sleep seconds..."
   SetDetailsPrint None
   Sleep $SleepMS
   StrCmp $FrameNum $Total NewJob
   Goto SectionStart
FinishNow:
   SetDetailsPrint Both
   DetailPrint "No further available jobs can be found. The ERTfTNV will now use the 'On finish' instructions from the last job."
   DetailPrint "These instructions were: $Finish."
   SetDetailsPrint None
   NotifyIcon::Icon "r"
   StrCmp $Finish "Shutdown" Shutdown
   StrCmp $Finish "Run" Run
   StrCmp $Finish "Box" Box
   StrCmp $Finish "Nothing" Quit
   MessageBox MB_OK|MB_ICONEXCLAMATION "The job settings file seems to have been written using a newer version of the ERTfTNV. The finish command '$Finish' cannot be handled by this version. Click on 'OK' to close the program."
   Quit
Quit:
   Quit
Box:
   MessageBox MB_OK|MB_ICONINFORMATION "The Emptosoft Rendering Tool for Terragen Network Version has finished rendering all of the frames from your job(s). Click 'OK' to close the program."
   Quit
Shutdown:
  ShutDown::ShutDown /FORCE
  Quit
Run:
   Exec $Run
   Quit
SectionEnd

Function .onGUIEnd
   NotifyIcon::Icon /NOUNLOAD "r"
   RealProgress::Unload
   StrCmp $Rendering "1" 0 End
   DeleteINIStr $JLLoc "TfJ $JSNum" "$FrameNum"
   DeleteINIStr $JLLoc "ST $JSNum" "$FrameNum"
   MessageBox MB_YESNO|MB_ICONQUESTION "Would you like to close Terragen as well?" IDYES Close-Terragen
   WriteINIStr $JLLoc "Job $JSNum" "$FrameNum" "D"
   WriteINIStr $JLLoc "Change" "$JSNum" "1"
   Goto End
Close-Terragen:
   nsProcess::_KillProcess "tgdcli.exe"
   Pop $TempData
   StrCmp $TempData "603" Not-Running
   StrCmp $TempData "0" Frame-Check
   MessageBox MB_OK|MB_ICONEXCLAMATION "Terragen could not be closed"
   Quit
Frame-Check:
   MessageBox MB_OK|MB_ICONINFORMATION "This program will now spend some time making sure that another instance of the ERTfTNV Client returns to complete your abandoned frame. This should take no more than a few minutes, unless you have a very slow connection to the Job List. You will be notified by another dialog box like this one when the process is complete."
   WriteINIStr $JLLoc "Job $JSNum" "$FrameNum" "N"
   WriteINIStr $JLLoc "Change" "$JSNum" "1"
   StrCpy $EJob $JSNum
   StrCpy $EFra $FrameNum
   ReadINIStr $TempData $JLLoc "Status" "$JSNum"
   WriteINIStr $JLLoc "Status" "$JSNum" "Rendering"
   StrCmp $TempData "Done" Job-Add Frame-Add
Frame-Loop:
   ReadINIStr $TempData $JLLoc "Job $JSNum" "$FrameNum"
   StrCmp $TempData "N" Frame-Loop2
   StrCmp $TempData "E" Frame-Loop3 Frame-Add
Frame-Loop2:
   WriteINIStr $JLLoc "Job $JSNum" "$FrameNum" "E"
   WriteINIStr $JLLoc "E $JSNum : $FrameNum" "Job" "$EJob"
   WriteINIStr $JLLoc "E $JSNum : $FrameNum" "Frame" "$EFra"
   Goto End-E
Frame-Loop3:
   ReadINIStr $TempData $JLLoc "E $JSNum : $FrameNum" "Job"
   IntCmp $EJob $TempData 0 Frame-Loop2 End-E
   ReadINIStr $TempData $JLLoc "E $JSNum : $FrameNum" "Frame"
   IntCmp $EFra $TempData End-E Frame-Loop2 End-E
End-E:
   MessageBox MB_OK|MB_ICONINFORMATION "The data about the abandoned frame has been successfully recorded in the Job list. If there are any ERTfTNV client programs using this job list, they should go back to render the abandoned frame. If not, the next time and ERTfTNV client program is run the abandoned frame will be rendered."
   Quit
Frame-Add:
   StrCmp $FrameNum $Total Job-Add
   IntOp $FrameNum $FrameNum + 1
   Goto Frame-Loop
Job-Loop:
   ReadINIStr $TempData $JLLoc "Status" "$JSNum"
   StrCmp $TempData "Rendering" Job-Found
   StrCmp $TempData "Not Started Yet" Job-Found
   Goto Job-Add
Job-Found:
   StrCpy $FrameNum "1"
   Goto Frame-Loop
Job-Add:
   StrCmp $JSNum $Last No-Jobs
   IntOp $JSNum $JSNum + 1
   Goto Job-Loop
No-Jobs:
   MessageBox MB_OK|MB_ICONEXCLAMATION "There are no jobs in progress, and therefore no active ERTfTNV Client programs. The next time a client program is run on the job list located at $JLLoc, your abandoned frame will be rendered."
   Quit
Not-Running:
   WriteINIStr $JLLoc "Job $JSNum" "$FrameNum" "D"
   WriteINIStr $JLLoc "Change" "$JSNum" "1"
   MessageBox MB_OK|MB_ICONINFORMATION "Terragen closed while the previous dialog box was open."
   Goto End
End:
FunctionEnd

Function FindJob
   StrCpy $JSNum "1"
   ReadINIStr $Last $JLLoc "Status" "Last"
   Goto Loop
Loop:
   ClearErrors
   ReadINIStr $TempData $JLLoc "Status" "$JSNum"
   StrCmp $TempData "Rendering" JSRead2
   StrCmp $TempData "Not Started Yet" JSRead
   StrCmp $TempData $Last NoJob
   IntOp $JSNum $JSNum + 1
   Goto Loop
NoJob:
   StrCmp $FirstRun "1" 0 NoJob2
   MessageBox MB_OK|MB_ICONINFORMATION "No available jobs can be found. Please create a new job using the ERTfTNV Job Generator."
   Quit
NoJob2:
   StrCpy $FNow "1"
   Goto End
JSRead:
   WriteINIStr $JLLoc "Status" "$JSNum" "Rendering"
   Goto JSRead2
JSRead2:
   ReadINIStr $World $JLLoc "World" "$JSNum"
   ReadINIStr $Terrain $JLLoc "Terrain" "$JSNum"
   ReadINIStr $Script $JLLoc "Script" "$JSNum"
   ReadINIStr $Sleep $JLLoc "Sleep" "$JSNum"
   ReadINIStr $Finish $JLLoc "Finish" "$JSNum"
   ReadINIStr $Name $JLLoc "Name" "$JSNum"
   ReadINIStr $Priority $JLLoc "Priority" "$JSNum"
   ReadINIStr $Run $JLLoc "Run" "$JSNum"
   ReadINIStr $Start $JLLoc "Start" "$JSNum"
   ReadINIStr $Total $JLLoc "Total" "$JSNum"
   IfFileExists $World 0 Error1W
   Goto End
Error1W:
   StrCpy $TGErrorFile "World"
   StrCpy $ErrorCode "1W"
   Goto ErrorBox1
Error1T:
   StrCpy $TGErrorFile "Terrain"
   StrCpy $ErrorCode "1T"
   Goto ErrorBox1
Error1S:
   StrCpy $TGErrorFile "Script"
   StrCpy $ErrorCode "1S"
   Goto ErrorBox1
ErrorBox1:
   MessageBox MB_OK|MB_ICONEXCLAMATION "The Terragen $TGErrorFile file cannot be found. Please verify that the file exists, and this computer has access to it. If this problem persists, please contact Emptosoft, quoting the error code: $ErrorCode."
   MessageBox MB_YESNO|MB_ICONQUESTION "Would you like to try to read the locations of these files from the Job List and search for them again?" IDYES JSRead2
   MessageBox MB_YESNO|MB_ICONQUESTION "Would you like to set this job's status to 'Error', so that other computers on the network ignore this job?" IDNO Quit
   WriteINIStr $JLLoc "Status" "$JSNum" "Error"
   Quit
Quit:
   Quit
End:
FunctionEnd

Function SubTime
   StrCpy $Leap "0"
   StrCpy $OD1 $D1
   StrCpy $OD2 $D2
   StrCpy $OD3 $D3
   StrCpy $OD4 $D4
   StrCpy $OD5 $D5
   StrCpy $OD6 $D6
   StrCpy $OT1 $T1
   StrCpy $OT2 $T2
   StrCpy $OT3 $T3
   StrCpy $OT4 $T4
   StrCpy $OT5 $T5
   StrCpy $OT6 $T6
   IntOp $OD3 $OD3 - 2000
   IntOp $OD6 $OD6 - 2000
   IntOp $TempData $OD3 / 4
   IntOp $OD1 $OD1 + $TempData
   IntOp $TempData $OD6 / 4
   IntOp $OD4 $OD4 + $TempData
   StrCpy $OD7 $OD3
   StrCpy $OD8 $OD6
Leap-Check-Loop-Y1:
   IntCmp $OD7 2008 Y1L Leap-Check-Loop-Y2
   IntOp $OD7 $OD7 - 4
   Goto Leap-Check-Loop-Y1
Y1L:
   IntCmp $OD2 "3" Leap-Check-Loop-Y2 0 Leap-Check-Loop-Y2
   IntOp $OD1 $OD1 - 1
   Goto Leap-Check-Loop-Y2
Leap-Check-Loop-Y2:
   StrCmp $Function "Start" Leap-End
   IntCmp $OD8 2008 Y2L Leap-End
   IntOp $OD8 $OD8 - 4
   Goto Leap-Check-Loop-Y2
Y2L:
   IntCmp $OD5 "3" Leap-End 0 Leap-End
   IntOp $OD4 $OD4 - 1
   Goto Leap-End
Leap-End:
   StrCmp $Function "Start" Month2
   IntOp $OD6 $OD6 * 365
   IntOp $OD4 $OD6 + $OD4
   StrCmp $OD5 "01" Month2 Feb
Feb:
   IntOp $OD4 $OD4 + 31
   StrCmp $OD5 "02" Month2
   Goto Mar
Mar:
   IntOp $OD4 $OD4 + 28
   StrCmp $OD5 "03" Month2
   Goto Apr
Apr:
   IntOp $OD4 $OD4 + 31
   StrCmp $OD5 "04" Month2
   Goto May
May:
   IntOp $OD4 $OD4 + 30
   StrCmp $OD5 "05" Month2
   Goto Jun
Jun:
   IntOp $OD4 $OD4 + 31
   StrCmp $OD5 "06" Month2
   Goto Jul
Jul:
   IntOp $OD4 $OD4 + 30
   StrCmp $OD5 "07" Month2
   Goto Aug
Aug:
   IntOp $OD4 $OD4 + 31
   StrCmp $OD5 "08" Month2
   Goto Sep
Sep:
   IntOp $OD4 $OD4 + 31
   StrCmp $OD5 "09" Month2
   Goto Oct
Oct:
   IntOp $OD4 $OD4 + 30
   StrCmp $OD5 "10" Month2
   Goto Nov
Nov:
   IntOp $OD4 $OD4 + 31
   StrCmp $OD5 "11" Month2
   Goto Dec
Dec:
   IntOp $OD4 $OD4 + 30
   Goto Month2
Month2:
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
   StrCmp $Function "Start" Start-F
   IntOp $OD4 $OD4 * 24
   IntOp $OT4 $OT4 + $OD4
   IntOp $OD1 $OD1 * 24
   IntOp $OT1 $OT1 + $OD1
   IntOp $OT4 $OT4 * 60
   IntOp $OT5 $OT4 + $OT5
   IntOp $OT1 $OT1 * 60
   IntOp $OT2 $OT1 + $OT2
   IntOp $OT5 $OT5 * 60
   IntOp $OT6 $OT5 + $OT6
   IntOp $OT2 $OT2 * 60
   IntOp $OT3 $OT2 + $OT3
   IntOp $TempData $OT6 - $OT3
   WriteINIStr $JLLoc "TfJ $JSNum" "$FrameNum" "$TempData"
   StrCpy $TempData1 "0"
   Goto Seconds-Loop
Start-F:
   IntOp $OD1 $OD1 * 24
   IntOp $OT1 $OT1 + $OD1
   IntOp $OT1 $OT1 * 60
   IntOp $OT2 $OT1 + $OT2
   IntOp $OT2 $OT2 * 60
   IntOp $OT3 $OT2 + $OT3
   WriteINIStr $JLLoc "ST $JSNum" "$FrameNum" "$OT3"
   Goto End
Seconds-Loop:
   IntCmp $TempData 60 0 Seconds-Copy
   IntOp $TempData $TempData - 60
   IntOp $TempData1 $TempData1 + 1
   Goto Seconds-Loop
Seconds-Copy:
   StrCpy $Duration "$TempDatas"
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
   StrCpy $Duration "$TempDatam $Duration"
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
   StrCpy $Duration "$TempDatah $Duration"
   StrCmp $TempData1 "0" End
   StrCpy $Duration "$Tempdata1d $Duration"
   Goto End
End:
FunctionEnd