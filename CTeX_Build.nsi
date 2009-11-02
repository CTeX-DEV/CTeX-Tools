
!include "LogicLib.nsh"
!include "Sections.nsh"

Name "CTeX Build"
OutFile "CTeX_Build.exe"

ShowInstDetails show

!include "MUI2.nsh"

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL


!define Make "$PROGRAMFILES\NSIS\makensis.exe"
!define INI_File "$EXEDIR\CTeX_Build.ini"
!define INI_Sec "CTeX"
!define INI_Key "BuildNumber"

!macro _Build NAME
	nsExec::ExecToLog '"${Make}" ${NAME}'
	Pop $0
	${If} $0 != 0
		Abort
	${EndIf}
!macroend
!define Build "!insertmacro _Build"

Var Build_Number

Section
	Call ReadBuildNumber
	Call WriteBuildNumber
SectionEnd

Section "Build Repair" Sec_Repair
	${Build} "CTeX_Repair.nsi"
SectionEnd

Section "Build Update" Sec_Update
	${Build} "CTeX_Update.nsi"
SectionEnd

Section "Build Basic Version" Sec_Basic
	${Build} "CTeX_Setup.nsi"
SectionEnd

Section /o "Build Full Version" Sec_Full
	${Build} "CTeX_Full.nsi"
SectionEnd

Section "Increment build number"
	${IfNot} ${Errors}
		Call ReadBuildNumber
		Call UpdateBuildNumber
		Call WriteBuildNumber
	${EndIf}
SectionEnd

Function .onSelChange
	${If} ${SectionIsSelected} ${Sec_Update}
	${OrIf} ${SectionIsSelected} ${Sec_Basic}
	${OrIf} ${SectionIsSelected} ${Sec_Full}
		!insertmacro SelectSection ${Sec_Repair}
	${EndIf}
FunctionEnd

Function ReadBuildNumber
	ReadINIStr $Build_Number "${INI_File}" "${INI_Sec}" "${INI_Key}"
	${If} $Build_Number == ""
		StrCpy $Build_Number "0"
	${EndIf}
FunctionEnd

Function UpdateBuildNumber
	IntOp $Build_Number $Build_Number + 1
	WriteINIStr "${INI_File}" "${INI_Sec}" "${INI_Key}" $Build_Number
FunctionEnd

Function WriteBuildNumber
	FileOpen $0 "$EXEDIR\CTeX_Build.nsh" "w"
	FileWrite $0 '!define BUILD_NUMBER "$Build_Number"$\r$\n'
	FileClose $0
FunctionEnd
