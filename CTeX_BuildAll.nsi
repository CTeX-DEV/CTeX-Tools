
!include "LogicLib.nsh"
!include "Sections.nsh"

Name "CTeX BuildAll"
OutFile "CTeX_BuildAll.exe"

ShowInstDetails show

!include "MUI2.nsh"

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL

Var Options

!macro _Build NAME
	DetailPrint 'Running ${NAME}\CTeX_Build.exe $Options'
	nsExec::ExecToLog '${NAME}\CTeX_Build.exe $Options'
	Pop $0
	${If} $0 != 0
		DetailPrint "Return code: $0"
		DetailPrint "Abort!"
		Abort
	${EndIf}
!macroend
!define Build "!insertmacro _Build"

SectionGroup /e "Options"

Section "Silent"
	StrCpy $Options "$Options /S"
SectionEnd

Section "Build All"
	StrCpy $Options "$Options /BUILD_ALL=yes"
SectionEnd

SectionGroupEnd

SectionGroup /e "Builds"

Section "CTeX 2.8"
	${Build} "CTeX_2.8"
SectionEnd

Section "CTeX 2.9"
	${Build} "CTeX_2.9"
SectionEnd

SectionGroupEnd
