!include "LogicLib.nsh"
!include "Sections.nsh"
!include "FileFunc.nsh"

Name "CTeX Font Setup"
OutFile "FontSetup.exe"

ShowInstDetails nevershow

SetCompressor /SOLID LZMA

!include "MUI2.nsh"

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_RESERVEFILE_LANGDLL

!define TTF_FONTS "$INSTDIR\fonts\truetype\chinese"
!define FontsGen "$WorkDir\FontsGen.exe"

Var WorkDir
Var TTF_song
Var TTF_fs
Var TTF_hei
Var TTF_kai
Var TTF_li
Var TTF_you

!macro _Check_TTF CJK_NAME TTF_NAME
	${If} ${FileExists} "${TTF_FONTS}\${TTF_NAME}"
		StrCpy $TTF_${CJK_NAME} "${TTF_FONTS}\${TTF_NAME}"
	${ElseIf} ${FileExists} "$FONTS\${TTF_NAME}"
		StrCpy $TTF_${CJK_NAME} "$FONTS\${TTF_NAME}"
	${Else}
		StrCpy $TTF_${CJK_NAME} ""
	${EndIf}
	
	${If} $TTF_${CJK_NAME} != ""
		!insertmacro SelectSection ${Sec_${CJK_NAME}}
		!insertmacro ClearSectionFlag ${Sec_${CJK_NAME}} ${SF_RO}
	${Else}
		!insertmacro UnselectSection ${Sec_${CJK_NAME}}
		!insertmacro SetSectionFlag ${Sec_${CJK_NAME}} ${SF_RO}
	${EndIf}
!macroend
!define Check_TTF "!insertmacro _Check_TTF"

!macro _Make_Font CJK_NAME
	DetailPrint "正在处理 $TTF_${CJK_NAME}"
	${GetParent} "$TTF_${CJK_NAME}" $0
	${GetFileName} "$TTF_${CJK_NAME}" $1
	SetDetailsPrint none
	ExecWait "${FontsGen} -ttfdir=$0 -destdir=Fonts -Type1 -encoding=UTF8 -ttf=$1 -CJKname=${CJK_NAME} -stemv=50"
	ExecWait "${FontsGen} -ttfdir=$0 -destdir=Fonts -Type1 -encoding=GBK  -ttf=$1 -CJKname=${CJK_NAME} -stemv=50"
	SetDetailsPrint lastused
!macroend
!define Make_Font "!insertmacro _Make_Font"

!macro _Install_Font CJK_NAME
	CreateDirectory "$INSTDIR\fonts\tfm\chinese"
	CopyFiles /SILENT "$WorkDir\Fonts\fonts\tfm\chinese\uni${CJK_NAME}" "$INSTDIR\fonts\tfm\chinese"
	CopyFiles /SILENT "$WorkDir\Fonts\fonts\tfm\chinese\gbk${CJK_NAME}" "$INSTDIR\fonts\tfm\chinese"
	CreateDirectory "$INSTDIR\fonts\afm\chinese"
	CopyFiles /SILENT "$WorkDir\Fonts\fonts\afm\chinese\uni${CJK_NAME}" "$INSTDIR\fonts\afm\chinese"
	CopyFiles /SILENT "$WorkDir\Fonts\fonts\afm\chinese\gbk${CJK_NAME}" "$INSTDIR\fonts\afm\chinese"
	CreateDirectory "$INSTDIR\fonts\enc\chinese"
	CopyFiles /SILENT "$WorkDir\Fonts\fonts\enc\chinese\uni${CJK_NAME}" "$INSTDIR\fonts\enc\chinese"
	CopyFiles /SILENT "$WorkDir\Fonts\fonts\enc\chinese\gbk${CJK_NAME}" "$INSTDIR\fonts\enc\chinese"
	CreateDirectory "$INSTDIR\fonts\type1\chinese"
	CopyFiles /SILENT "$WorkDir\Fonts\fonts\type1\chinese\uni${CJK_NAME}" "$INSTDIR\fonts\type1\chinese"
	CopyFiles /SILENT "$WorkDir\Fonts\fonts\type1\chinese\gbk${CJK_NAME}" "$INSTDIR\fonts\type1\chinese"
	CreateDirectory "$INSTDIR\fonts\map\chinese"
	CopyFiles /SILENT "$WorkDir\Fonts\fonts\map\cjk.map" "$INSTDIR\fonts\map\chinese\cjk-${CJK_NAME}.map"
	CopyFiles /SILENT "$WorkDir\Fonts\fonts\map\cjk_ttf.map" "$INSTDIR\fonts\map\chinese\cjk-${CJK_NAME}-ttf.map"
	RMDir /r "$WorkDir\Fonts"
!macroend
!define Install_Font "!insertmacro _Install_Font"

Section -Init
	StrCpy $WorkDir "$INSTDIR\fontsetup.tmp"
	CreateDirectory $WorkDir
	SetOutPath $WorkDir
	File "FontSetup\*.*"
SectionEnd

Section "宋体" Sec_song
	${Make_Font} "song"
	${Install_Font} "song"
SectionEnd

Section "仿宋" Sec_fs
	${Make_Font} "fs"
	${Install_Font} "fs"
SectionEnd

Section "黑体" Sec_hei
	${Make_Font} "hei"
	${Install_Font} "hei"
SectionEnd

Section "楷体" Sec_kai
	${Make_Font} "kai"
	${Install_Font} "kai"
SectionEnd

Section "隶书" Sec_li
	${Make_Font} "li"
	${Install_Font} "li"
SectionEnd

Section "幼圆" Sec_you
	${Make_Font} "you"
	${Install_Font} "you"
SectionEnd

Section -Finish
	RMDir /r $WorkDir
SectionEnd

Function .onInit
	${If} ${FileExists} "$EXEDIR\FontSetup.ini"
		ReadINIStr $0 "$EXEDIR\FontSetup.ini" "CTeX" "Install"
	${Else}
		ReadRegStr $0 HKLM "Software\CTeX" "Install"
	${EndIf}
	${If} $0 == ""
		StrCpy $0 "C:\CTEX"
	${EndIf}
	StrCpy $INSTDIR "$0\CTeX"

	${Check_TTF} "song" "simsun.ttf"
	${If} $TTF_song == ""
		${Check_TTF} "song" "simsun.ttc"
	${EndIf}
	${Check_TTF} "fs" "simfang.ttf"
	${Check_TTF} "hei" "simhei.ttf"
	${Check_TTF} "kai" "simkai.ttf"
	${Check_TTF} "li" "simli.ttf"
	${Check_TTF} "you" "simyou.ttf"
FunctionEnd

