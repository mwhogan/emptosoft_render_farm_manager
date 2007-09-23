# Emptosoft Render Farm Manager (for Terragen 2 Technology Preview) v0.4 (Beta)
(Based on the Emptosoft Rendering Tool for Terragen Network Version v1.3)

## Build instructions
Compilation requires NSIS. I am not sure if it will compile with the latest version, as I haven't been keeping track of the development of NSIS.

## Minimum requirements
The ability to run Terragen 2 Technology Preview.

## Help

Basic instructions for rendering an animation:
1. Run the Job Generator on a computer connected to your network (preferably a main sort of computer, or a server).
2. Select a location to save the job list to. The other computers on your network should be able to edit the job list, so save it in a location like 'Shared Documents'.
3. Enter the details you are asked for - the location of the TGD file (the TGD file must be in a location that can be accessed by all of the computers on your network, and you must enter the location in a network format, e.g. "\\NetworkComputer1\SharedDocs\Test.tgd" rather than "C:\Documents and Settings\All Users\Shared Documents\Test.tgd"), the frames you want the render to start and stop at, the number of seconds you want to let the computers rest for between rendering each frame, the function you would like the client programs to carry out when the job is finished, the name of the job and its priority. If you are looking for the fastest renders possible, set the sleep time to "0" and the priority to "realtime". Subjecting computers to long periods of time with these settings, however, is unadvisable.
4. When you have generated the job list, run the Client program on each machine on your network. (You can put the Client program in the same location as the job list, and it on all of the computers from there, so you don't need multiple copies of the client program).
5. Select the locations of Terragen (tgdcli.exe) and the Job List.
6. Sit back and let the Client programs render your animation(s). You can run the Monitor at this point to check on the rendering progress and obtain data such as the average frame rendering time.
7. The function you have chosen for the Client programs to do when they have finished a job will only be run if there are no nore jobs. If there are more jobs, the next job(s) will be run. Only when there are no remaining jobs, will the finish function of the last job be run.

Notes:
1. The next time you run the Client programs and the Job Generator you will not be asked details about the locations of Terragen or the Job list, unless one or both cannot be found.
2. This program is a beta and has undergone minimal testing. You use it at your own risk. I cannot accept any responsibility for damage caused by the use of this program.
3. Keep all of the executable files in the same folder for the best operation.

Beta status:
- These programs are still in beta testing. They are based on thoroughly tested software but, as you should be able to see, some of the features in the old software have been disabled, because they need modification. Most features should still work. A full list of the features not yet modified will be made available soon.
- If Client.exe fails to work, try Diagnostic Mode Client.exe.
- Detailed Mode Client.exe provides detailed feedback directly from T2TP. Unfortunately, at the moment, the feedback doesn't seem to appear in a logical place or in a logical order.

## Change log

### Emptosoft Render Farm Manager.

v0.4 (23/09/07):
- Renamed from Emptosoft Rendering Tool for Terragen 2 Technology Preview to Emptosoft Render Farm Manager.
- Improved icons.
- Changed license.

v0.3 (05/05/07):
- Added -p to command line (contrary to the documentation, you do appear to need it).
- Added the 'Detailed Mode' Client, which should display everything from tgdcli.exe.

v0.2 (01/05/07):
- Added custom output file name option (see -o in T2TP command line documentation). If you don't need it, leave it blank.

v0.1 (27/04/07):
- Split from the Emptosoft Rendering Tool for Terragen Network Version (ERTfTNV) v1.3 (designed for the old Terragen - v0.9).
- The client now works, and I have managed to keep the priority system working.

### Emptosoft Rendering Tool for Terragen Network Version

v1.3:
- A lot of changes. Huge improvements to the monitor.

v1.2.1 (??/06/06):
- User is now asked if they want to close Terragen if it is running when they clock the close button on the Client.
- If the user chooses to close Terragen, another instance of the Client is made to come back and render the abandoned frame.
- The frame searching methods have also been improved so that Error 1F is not possible.

v1.2 (01/06/06):
- Improved job storage, with the Job List Generator creating jobs faster, overruns prevented in the monitor, and overruns less likely in the client program.
- A few old dialog boxes have been updated.
- Integrated with Emptosoft Program Management System.

v1.1 (01/06/06):
- Monitor program detatched from job generator.
- Banners removed.
- When a job is generated, the priority with which Terragen is run can be chosen.
- Fixed a grammatical error that appeared in the message box of the job list cleaner when some old jobs had had data deleted.
- The function that calculates the duration of the render of a frame has been rebuilt so that it is more accurate and can cope with renders that span two or more days.
- Last portable version.
- Cannot be updated.

v1.0 (19/03/06):
- Everything is new.










