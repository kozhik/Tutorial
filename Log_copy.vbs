'On Error Resume Next
imputFile="input_data.csv"
Dim MyArray
	
Set WshShell = WScript.CreateObject("WScript.Shell")
	filename =  WshShell.CurrentDirectory & "\" & imputFile
	Set objFSO=CreateObject("Scripting.FileSystemObject")
		If objFSO.FileExists(filename) Then
		Set objFile=objFSO.OpenTextFile(filename,1)
			Do Until objFile.AtEndOfStream 
			strEntry=objFile.ReadLine
			vArray = Split(strEntry,";")
		
				Set FTP_objFSO=CreateObject("Scripting.FileSystemObject")
				If not FTP_objFSO.FileExists(WshShell.CurrentDirectory & "\" & "ftptemp.txt") Then 
				Call ftp_temp(vArray(2))
				end if				


			if UBound(vArray) = 3 then 
			Call folder_create (vArray(0), vArray(1), vArray(3), vArray(2))   
			else 
			M = 0
			Call folder_create (vArray(0), vArray(1), M, vArray(2)) 
 			end if
			Loop	
		end if		
objFile.Close

Set fso = CreateObject("Scripting.FileSystemObject")
Set aFile = fso.GetFile(WshShell.CurrentDirectory & "\" & "ftptemp.txt")
aFile.Delete
Set aFile = fso.GetFile(WshShell.CurrentDirectory & "\" & "FTP_TEMP.scr")
aFile.Delete

Sub folder_create(NES, WorkName, OSS, OSS1)

temp = RIGHT(NES,3)
Tmp = Left(NES, Len(NES) - 3)
if 	Tmp ="MSS" then
	Tmp = Replace(Tmp,"SS","SC-S")
	Fold140 = "\\10.44.1.140\NEs\MSC-S\"
	NES140 = Tmp & temp
end if

if 	Tmp ="TSS" then
	Tmp = Replace(Tmp,"SS","SC-S")
	Fold140 = "\\10.44.1.140\NEs\TSC-S\"
	if temp = "001" then
	 temp ="001_Kyiv"
	end if
	NES140 = Tmp & temp
end if

if 	Tmp ="TSC" then
	Fold140 = "\\10.44.1.140\NEs\TSC\"
	temp = Replace(temp,"00","0")
	NES140 = Tmp & temp
end if 

if 	Tmp ="HLR" then
	Fold140 = "\\10.44.1.140\NEs\HLR\"
	if temp = "010" then
	 temp ="10"
	end if
	if temp = "011" then
	 temp ="11"
	end if
	temp = Replace(temp,"00","0")
	NES140 = Tmp & temp
end if 

if 	Tmp ="MGW" then
	Fold140 = "\\10.44.1.140\NEs\M-MGW\"
	Tmp = Replace(Tmp,"M","M-M")
	NES140 = Tmp & temp
end if 

if 	Tmp ="TMGW" then
	Fold140 = "\\10.44.1.140\NEs\T-MGW\"
	Tmp = Replace(Tmp,"TM","T-M")
	NES140 = Tmp & temp
end if 

if 	Tmp ="BSC" then
	Fold140 = "\\10.44.1.140\NEs\BSC\"
	Set objRegExp = CreateObject("VBScript.RegExp")
	objRegExp.Global = True
	objRegExp.Pattern = "^0"
 	temp = objRegExp.Replace(temp, "")
	if temp = "94" then
	 temp ="94_Cherkassy"
	end if
	if temp = "34" then
	 temp ="34_Chernigov"
	end if
	if temp = "75" then
	 temp ="75_Zhitomir"
	end if
	NES140 = Tmp & temp
end if 


d = date
d = mid(d,9,2) & mid(d,4,2) & mid(d,1,2)

Set objFSO=CreateObject("Scripting.FileSystemObject")
If objFSO.FolderExists(Fold140) Then
		Set WshShell = WScript.CreateObject("WScript.Shell")
		Set objFolder=objFSO.GetFolder(Fold140)
		Set subFolder = objFolder.SubFolders
	end if	
	For Each folder In subFolder
			    If  InStr(1,folder,NES140,vbTextCompare) <> 0 Then 
				If objFSO.FolderExists(folder & "\log_files\2012\" & d & "_" & WorkName &"_" & NES) Then
					'Check for folder, that we will create, exists already, if exists - just write it in log
					log_line = "Error of create. Folder " & WorkName & " already exists. Full path is: " & folder & "\log_files\2012\" & d & "_" & WorkName &"_" & NES
				Else	
				Set newFold = objFSO.CreateFolder(folder & "\log_files\2012\" & d & "_" & WorkName &"_" & NES)
				Set FSO=CreateObject("Scripting.FileSystemObject")
				if objFSO.FolderExists("C:\Logs\" & NES) then 
				Set file  = FSO.GetFolder("C:\Logs\" & NES) 
				file.copy(newFold)
			'	FSO.DeleteFolder("C:\Logs\" & NES) 
				end if
				end if
     				dim Log
				logfile="log.txt"
				log =  WshShell.CurrentDirectory & "\" & logfile
					Set log_objFSO=CreateObject("Scripting.FileSystemObject")
					If log_objFSO.FileExists(log) Then 
						Const ForAppending=8
						Set log_objFile=objFSO.OpenTextFile(log,ForAppending)
						log_objFile.WriteLine newFold
						log_objFile.WriteLine log_line
						log_objFile.Close
					Else
						Set log_objFile=log_objFSO.CreateTextFile(log,TRUE)
						log_objFile.WriteLine newFold
						log_objFile.WriteLine log_line
						log_objFile.Close
					End If				

			     End If

	      Next

	if len(OSS) > 1 Then 
	Call ftp(OSS, NES140, newFold, NES, OSS1)
        end if 
end Sub

sub ftp_temp(OSS)

set FSO = CreateObject("Scripting.FileSystemObject") 
Set WshShell = CreateObject("WScript.Shell")
fileFTP = WshShell.CurrentDirectory
Set cScript = fso.CreateTextFile (fileFTP & "\FTP_TEMP.scr")
Set datafile = CreateObject("Scripting.FileSystemObject") 
Set objFile1 = datafile.OpenTextFile(WshShell.CurrentDirectory & "\Data.txt", 1) 
Dim arrFileLines() 
i = 0 
Do Until objFile1.AtEndOfStream 
Redim Preserve arrFileLines(i) 
arrFileLines(i) = objFile1.ReadLine 
i = i + 1 
Loop 
objFile1.Close 

if OSS = "OSS1" then
OSS = "10.44.1.20"
end if

if OSS = "OSS2" then
OSS = "10.44.1.73"
end if

if OSS = "OSS3" then
OSS = "10.44.1.126"
end if


cScript.WriteLine "Open " & OSS
cScript.WriteLine arrFileLines(0)
cScript.WriteLine arrFileLines(1)
cScript.WriteLine "cd /var/opt/ericsson/nms_smo_srv/smo_file_store/Software/AXE/"
cScript.WriteLine "lcd " & fileFTP
cScript.WriteLine "ls /var/opt/ericsson/nms_smo_srv/smo_file_store/Software/AXE/ ftptemp.txt"
cScript.WriteLine "by"                
cScript.Close     

WSHshell.Run "c:\WINDOWS\system32\" & "\FTP.ExE -s:" & fileFTP & "\FTP_TEMP.scr", 3 

WScript.sleep 5000 
end Sub

Sub ftp(OSS, NES140, newFold, NES, OSS1)

' NEs name for OSS start

NE = Left(NES, Len(NES) - 3)
nom= Right(NES,3)
NEOss = NE & int(nom)
' NEs name for OSS end


Dim WshShell, objFSO, objFile 
Set WshShell = WScript.CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject") 
filename= WshShell.CurrentDirectory & "\ftptemp.txt" 
Set objFil = objFSO.OpenTextFile(filename,1) 
Dim String1, String2
Do While objFil.AtEndOfStream<>True
			strEntry=objFil.ReadLine
 if Instr(1,strEntry,OSS,1)<> 0 then 
        
 strEntry = mid(strEntry, 58)
	set FSO = CreateObject("Scripting.FileSystemObject") 
	Set WshShell = CreateObject("WScript.Shell")
	fileFTP = WshShell.CurrentDirectory
	
	Set datafile = CreateObject("Scripting.FileSystemObject") 
	Set objFile = datafile.OpenTextFile(WshShell.CurrentDirectory & "\Data.txt", 1) 
	'Dim arrFileLines() 
	i = 0 
	Do Until objFile.AtEndOfStream 
	Redim Preserve arrFileLines(i) 
	arrFileLines(i) = objFile.ReadLine 
	i = i + 1 
	Loop 
	objFile.Close 
ip= mid(arrFileLines(0),5)

if OSS1 = "OSS1" then
OSS1 = "10.44.1.20"
end if

if OSS1 = "OSS2" then
OSS1 = "10.44.1.73"
end if

if OSS1= "OSS3" then
OSS1 = "10.44.1.126"
end if
 
Set WshShell = CreateObject("WScript.Shell") 
'msgbox "cmd /K ncftpget -u "& arrFileLines(1)& " -p "& arrFileLines(2) & " -R " & arrFileLines(0) & " " & newFold &" /var/opt/ericsson/nms_smo_srv/smo_file_store/Software/AXE" & strEntry & "/LOG/" & NEOss &"/*"
WshShell.Run "cmd /K ncftpget -u "& arrFileLines(0)& " -p "& arrFileLines(1) & " -R " & OSS1 & " " & newFold &" /var/opt/ericsson/nms_smo_srv/smo_file_store/Software/AXE" & strEntry & "/LOG/" & NEOss &"/*" , 3

   
	end if
Loop 
end sub

