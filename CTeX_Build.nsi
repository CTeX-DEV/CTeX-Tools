
!include "LogicLib.nsh"
!include "Sections.nsh"
!include "FileFunc.nsh"

Name "CTeX Build"
OutFile "CTeX_Build.exe"
RequestExecutionLevel user

ShowInstDetails show

!include "MUI2.nsh"

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL


!define PROGRAM "$PROGRAMFILES\NSIS\makensis.exe"
!define OPTIONS "/INPUTCHARSET UTF8 /OUTPUTCHARSET UTF8 /V4"
!define Make "${PROGRAM} ${OPTIONS}"
!define INI_File "$EXEDIR\libs\CTeX_Build.ini"
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
Var BUILD_ALL

Section
	Call ReadBuildNumber
	Call WriteBuildNumber
SectionEnd

Section "Build Repair" Sec_Repair
	${Build} "$EXEDIR\CTeX_Repair.nsi"
SectionEnd

Section "Build Update" Sec_Update
	${Build} "$EXEDIR\CTeX_Update.nsi"
SectionEnd

Section "Build Basic Version" Sec_Basic
	${Build} "$EXEDIR\CTeX_Setup.nsi"
SectionEnd

Section /o "Build Full Version" Sec_Full
	${Build} "$EXEDIR\CTeX_Full.nsi"
SectionEnd

Section "Increment build number"
	${IfNot} ${Errors}
		Call ReadBuildNumber
		Call UpdateBuildNumber
		Call WriteBuildNumber
	${EndIf}
SectionEnd

Function .onInit
	${GetParameters} $R0
	${GetOptions} $R0 "/BUILD_ALL=" $BUILD_ALL
	
	${If} $BUILD_ALL != ""
		!insertmacro SelectSection ${Sec_Repair}
		!insertmacro SelectSection ${Sec_Update}
		!insertmacro SelectSection ${Sec_Basic}
		!insertmacro SelectSection ${Sec_Full}
	${EndIf}
FunctionEnd

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
	FileOpen $0 "$EXEDIR\libs\CTeX_Build.nsh" "w"
	FileWrite $0 '!define BUILD_NUMBER "$Build_Number"$\r$\n'
	FileClose $0
FunctionEnd
