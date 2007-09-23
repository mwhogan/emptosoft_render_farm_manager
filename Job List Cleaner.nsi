OutFile "Job List Cleaner.exe"
Caption "ERFM (Beta) Job List Cleaner"
Icon "RFM.ico"
XPStyle On
BrandingText /TRIMRIGHT "ERFM"
VIAddVersionKey /LANG=1033-ENGLISH "LegalCopyright" "See www.emptosoft.plus.com/licences"
VIAddVersionKey /LANG=1033-ENGLISH "ProductName" "Emptosoft Render Farm Manager (Beta)"
VIAddVersionKey /LANG=1033-ENGLISH "CompanyName" "Emptosoft"
VIAddVersionKey /LANG=1033-ENGLISH "FileDescription" "Emptosoft Render Farm Manager Job List Cleaner (Version 0.4 - Beta)"
VIAddVersionKey /LANG=1033-ENGLISH "FileVersion" "0.4"
VIProductVersion "0.4.0.0"
Var TempData
Var JLLoc
Var Name
Var JobNum
Var JobsCleaned
Var Last
DetailsButtonText "Show log..."
SubCaption 3 ": Closing..."
SubCaption 4 ": Closing..."
Page instfiles
!include "defines.nsh"
InstallColors 2C85C6 FFFFFF

Function .onInit
   SetShellVarContext All
   InitPluginsDir
   MessageBox MB_YESNO|MB_ICONQUESTION "Are you sure you want to clean the job list? WARNING: All of the details for completed jobs will be deleted." IDNO Quit
   ReadINIStr $JLLoc $APPDATA\Emptosoft\Settings.emp "Rendering Tool for Terragen Network Version T2TP Beta" "JLLoc"
   StrCmp $JLLoc "" NoJL
   Goto JobSearchLoop0
NoJL:
   MessageBox MB_OK|MB_ICONINFORMATION "Please specify the location of the Job List file."
   Dialogs::Open "Emptosoft Settings File|*.emp" "" "Job list Location..." "" ${VAR_R0}
   StrCpy $JLLoc $R0
   StrCmp $JLLoc "0" Quit
   WriteINIStr $APPDATA\Emptosoft\Settings.emp "Rendering Tool for Terragen Network Version T2TP Beta" "JLLoc" "$JLLoc"
   Goto JobSearchLoop0
JobSearchLoop0:
   ReadINIStr $Last $JLLoc Status Last
   StrCmp $Last "" Invalid
   StrCpy $JobNum "1"
   nxs::Show /NOUNLOAD "Deleting unneeded job list data..." /top "Searching for completed jobs..." /sub "Carrying out calculations..." /h 0 /pos 0 /max 100 /can 0 /end
   Goto JobSearchLoop
Invalid:
   MessageBox MB_OK "The Job List you have specified is not a valid Job List. It may not be a Job List, it may have been corrupted, or it may have been made by an old version of the Job List Generator."
   Quit
JobSearchLoop:
   nxs::Update /NOUNLOAD /sub "Checking status of job $JobNum..." /pos 0 /end
   ReadINIStr $TempData $JLLoc Status $JobNum
   StrCmp $TempData "Done" Delete
   StrCmp $JobNum $Last End Add
Delete:
   ReadINIStr $Name $JLLoc "Name" $JobNum
   nxs::Update /NOUNLOAD /sub "Deleting data for job $JobNum ($TempData)..." /pos 0 /end
   DeleteINISec $JLLoc "Job $JobNum"
   DeleteINISec $JLLoc "TFJ $JobNum"
   DeleteINISec $JLLoc "ST $JobNum"
   DeleteINIStr $JLLoc "World" $JobNum
   DeleteINIStr $JLLoc "Terrain" $JobNum
   DeleteINIStr $JLLoc "Script" $JobNum
   DeleteINIStr $JLLoc "Sleep" $JobNum
   DeleteINIStr $JLLoc "Finish" $JobNum
   DeleteINIStr $JLLoc "Priority" $JobNum
   DeleteINIStr $JLLoc "Run" $JobNum
   DeleteINIStr $JLLoc "OutputLoc" $JobNum
   DeleteINIStr $JLLoc "Total" $JobNum
   DeleteINIStr $JLLoc "Start" $JobNum
   DeleteINIStr $JLLoc "Change" $JobNum
   nxs::Update /NOUNLOAD /sub "Data for job $JobNum ($Name) deleted..." /pos 100 /end
   WriteINIStr $JLLoc Status $JobNum Deleted
   StrCmp $JobsCleaned "" First-Job
   StrCpy $JobsCleaned "$JobsCleaned, $Name ($JobNum)"
   Goto Add
First-Job:
   StrCpy $JobsCleaned "$Name ($JobNum)"
   Goto Add
Add:
   IntOp $JobNum $JobNum + 1
   Goto JobSearchLoop
End:
   nxs::Destroy
   StrCmp $JobsCleaned "" 0 JobsCleaned
   MessageBox MB_OK|MB_ICONINFORMATION "No completed jobs with data could be found."
   Quit
JobsCleaned:
   MessageBox MB_OK|MB_ICONINFORMATION "All of the data for the completed jobs in the job list ($JobsCleaned) has been deleted."
   Quit
Quit:
   Quit
FunctionEnd

Section -VOID
SectionEnd

Function .onGUIEnd
FunctionEnd