Dim I, I2, oSession, oSearcher, oSearchResult, oUpdate, oUpdatesToDownload, oUpdatesToInstall, oDownloader, oInstaller, oInstallationResult
Dim iMaxUpdates
Dim oFileSystem, oLog
dim oWinFolder
Dim blNoUpdates, qVal, oRunLog

blNoUpdates = False




iMaxUpdates=30

' ~~~ ---------------------------------------------
' ~~~ Create objects
' ~~~ ---------------------------------------------
Set oSession       = CreateObject("Microsoft.Update.Session")
Set oSearcher      = oSession.CreateupdateSearcher()

Set oFileSystem = CreateObject("Scripting.FileSystemObject")
Set oWinFolder = oFileSystem.GetSpecialFolder (0)
Set oLog = oWinFolder.CreateTextFile("SCTWindowsUpdates.log", True)
Set oRunLog = oFileSystem.OpenTextFile("C:\Logs\WindowsUpdates-All.log", 8, True)

Public Function DoWindowsUpdates

On Error Resume Next

    ' ~~~ ---------------------------------------------
    ' ~~~ Search for updates
    ' ~~~ ---------------------------------------------
    oLog.WriteLine FormatDateTime (Now) & " Searching for updates..." & vbCRLF
    oLog.WriteLine FormatDateTime (Now) & " List of applicable items on the machine:"
    
    I2=0
    For I = 0 To oSearchResult.Updates.Count-1
        Set oUpdate = oSearchResult.Updates.Item(I)
        I2=I2+1
        oLog.WriteLine I + 1 & "> " & oUpdate.Title
        oRunLog.WriteLine Now() & " - " & I + 1 & " > " & oUpdate.Title
    Next
    
    If I2 = 0 Then
        oLog.WriteLine FormatDateTime (Now) & " There are no applicable updates."
                blNoUpdates = True
        Exit Function
    Else
        oRunLog.WriteLine Now() & " - Applicable updates: " & I2
    End If
    
    ' ~~~ ---------------------------------------------
    ' ~~~ Create collection of upates to download
    ' ~~~ ---------------------------------------------
    oLog.WriteLine vbCRLF & FormatDateTime (Now) & " Creating collection of updates to download:"
    Set oUpdatesToDownload = CreateObject("Microsoft.Update.UpdateColl")
    
        Dim iUpdatesCount
        iUpdatesCount=oSearchResult.Updates.Count
        if iUpdatesCount > iMaxUpdates then 
        iUpdatesCount=iMaxUpdates
        oRunLog.WriteLine Now() & " - Too many updates. To limit trustedinstaller overhead, reducing to " & iMaxUpdates
        End if

    For I = 0 to iUpdatesCount-1
        Set oUpdate = oSearchResult.Updates.Item(I)
        oLog.WriteLine I + 1 & "> adding: " & oUpdate.Title 
        oRunLog.WriteLine I + 1 & "> adding: " & oUpdate.Title 
        oUpdatesToDownload.Add(oUpdate)
    Next
    
    ' ~~~ ---------------------------------------------
    ' ~~~ Download updates
    ' ~~~ ---------------------------------------------
    oLog.WriteLine vbCRLF & FormatDateTime (Now) & " Downloading updates..."
    
    Set oDownloader = oSession.CreateUpdateDownloader() 
    oDownloader.Updates = oUpdatesToDownload
    oDownloader.Download()
    
    ' ~~~ ---------------------------------------------
    ' ~~~ Create a collection of downloaded updates to install
    ' ~~~ ---------------------------------------------
    oLog.WriteLine  vbCRLF & FormatDateTime (Now) & " Creating collection of downloaded updates to install:" 
    Set oUpdatesToInstall = CreateObject("Microsoft.Update.UpdateColl")
    
    For I = 0 To iUpdatesCount-1
        Set oUpdate = oSearchResult.Updates.Item(I)
        oLog.WriteLine I + 1 & "> adding:  " & oUpdate.Title 
        oUpdatesToInstall.Add(oUpdate)    
    Next
    
    ' ~~~ ---------------------------------------------
    ' ~~~ Install updates
    ' ~~~ ---------------------------------------------
    oLog.WriteLine FormatDateTime (Now) & " Installing updates..."
    Set oInstaller = oSession.CreateUpdateInstaller()
    oInstaller.Updates = oUpdatesToInstall
    oInstaller.ForceQuiet = true
    Set oInstallationResult = oInstaller.Install()
    
    ' ~~~ ---------------------------------------------
    ' ~~~ Output results of install
    ' ~~~ ---------------------------------------------
    oLog.WriteLine FormatDateTime (Now) & " Installation Result: " & oInstallationResult.ResultCode 
    oLog.WriteLine FormatDateTime (Now) & " Reboot Required: " & oInstallationResult.RebootRequired & vbCRLF 
    oLog.WriteLine FormatDateTime (Now) & " Listing of updates installed and individual installation results:" 
    
    For I = 0 to oUpdatesToInstall.Count - 1
        oLog.WriteLine I + 1 & "> " & oUpdatesToInstall.Item(i).Title & ": " & oInstallationResult.GetUpdateResult(i).ResultCode
    Next
    
End Function


On Error Resume Next

oRunLog.WriteLine Now() & " - Start: Windows Updates All script starting."

oLog.WriteLine FormatDateTime (Now) & " Downloading and Installing All Available Software Updates"
Set oSearchResult  = oSearcher.Search("IsAssigned=1 and IsHidden=0 and IsInstalled=0 and Type='Software'")
Call DoWindowsUpdates
oLog.WriteLine vbCRLF & vbCRLF

oLog.WriteLine FormatDateTime (Now) & " Updates Complete"

oLog.Close

If blNoUpdates = True Then
    oRunLog.WriteLine Now() & " - No Updates Found."
    qVal = 99
Else
    oRunLog.WriteLine Now() & " - Updates found and installed.  See %WinDir%\WindowsUpdate.log for details."
    qVal = 98
End If

oRunLog.WriteLine Now() & " - End: Windows Updates All script Complete."
If qVal = 0 Then WScript.Quit(Err.Number)
WScript.Quit(qVal)