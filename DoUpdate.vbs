On Error Resume Next
WScript.StdOut.Write "*****************************************************************" & vbCrLf
WScript.StdOut.Write "***         Forced install of all pending updates             ***" & vbCrLf
WScript.StdOut.Write "*****************************************************************" & vbCrLf 
WScript.StdOut.Write "**                    How to use this script                   **" & vbCrLf
WScript.StdOut.Write "*****************************************************************" & vbCrLf
WScript.StdOut.Write "** cscript DoUpdate.vbs [/nr]                                  **" & vbCrLf
WScript.StdOut.Write "**                                                             **" & vbCrLf
WScript.StdOut.Write "** [/nr]      Never reboot (default is to reboot if needed)    **" & vbCrLf
WScript.StdOut.Write "*****************************************************************" & vbCrLf
' See if can auto-reboot.
DoReboot = True
if WScript.Arguments.Count <> 0 then
  for i = 0 to WScript.Arguments.Count - 1
    strInput1 = Lcase(Trim(WScript.Arguments(i)))
	
	if (strInput1 = "/nr") then
      DoReboot = False	'Do not reboot even if it is necessary.
    end if	
	
  next
end if
'*******************************************************************
' Create needed objects.
'*******************************************************************
Set updateSession = CreateObject("Microsoft.Update.Session")
Set updateSearcher	 = updateSession.CreateUpdateSearcher()
Set updateDownloader = updateSession.CreateUpdateDownloader()
Set updateInstaller  = updateSession.CreateUpdateInstaller()

Set ComputerStatus 	= CreateObject("Microsoft.Update.SystemInfo")
Set objShell = CreateObject("WScript.Shell")

' Step 1: Verify if there is a pending reboot, if so: reboot right now.
If ComputerStatus.RebootRequired then 
  WScript.StdOut.Write "This computer needs to reboot before start searching for updates." & vbCrLf
  if DoReboot then
    WScript.StdOut.Write "Rebooting in 5 seconds." & vbCrLf
    strErrorCode = objShell.Run("shutdown.exe -r -f -t 05",0,True)
  end if
  WScript.Sleep 3000
  WScript.Quit 1
End if

' Step 2: Search for updates.
WScript.StdOut.Write "Wait while searching updates." & vbCrLf
Set updateSearch = updateSearcher.Search("IsInstalled=0")
If updateSearch.ResultCode <> 2 Then
  WScript.StdOut.Write "Searching has failed with error code: " & updateSearch.ResultCode & vbCrLf
  WScript.Sleep 3000
  WScript.Quit 1
End If
' Step 3: If there are new updates download them all.
If updateSearch.Updates.Count = 0 Then
  WScript.StdOut.Write "No new updates. Finishing in 3 seconds." & vbCrLf
  WScript.Sleep 3000
  WScript.Quit 2
End If

WScript.StdOut.Write "Wait while downloading " & updateSearch.Updates.Count & " update(s)." & vbCrLf

updateDownloader.Updates = updateSearch.Updates
Set downloadResult = updateDownloader.Download()
If downloadResult.ResultCode <> 2 Then
  WScript.StdOut.Write "The download has failed with error code: " & downloadResult.ResultCode & vbCrLf
  WScript.Sleep 3000
  WScript.Quit 1
End If
WScript.StdOut.Write "Download completed." & vbCrLf
' Step 4: Install all downloaded updates.
WScript.StdOut.Write "Installing updates ..." & vbCrLf
updateInstaller.Updates = updateSearch.Updates
Set installationResult = updateInstaller.Install()
If installationResult.ResultCode <> 2 Then
  WScript.StdOut.Write "The installation has failed with error code: " & installationResult.ResultCode & vbCrLf
  WScript.Sleep 3000
  WScript.Quit 1
End If
' Step 5: Reboot if its needed.
If ComputerStatus.RebootRequired then 
  WScript.StdOut.Write "This computer needs to reboot to complete the installation." & vbCrLf
  if DoReboot then
    WScript.StdOut.Write "Rebooting in 5 seconds." & vbCrLf
    strErrorCode = objShell.Run("shutdown.exe -r -f -t 05",0,True)
  end if
  WScript.Sleep 3000
  WScript.Quit 1
  Else
  WScript.StdOut.Write "Script completed." & vbCrLf
  WScript.Sleep 3000
  WScript.Quit 2
End if