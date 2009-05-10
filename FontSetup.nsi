!include "LogicLib.nsh"
!include "Sections.nsh"
!include "FileFunc.nsh"

Name "CTeX Font Setup"
OutFile "FontSetup.exe"

ShowInstDetails nevershow

SetCompressor /SOLID LZMA

!include "MUI2.nsh"

!insertmacro MUI_PAGE_DIRECTORY
!define MUI_PAGE_CUSTOMFUNCTION_PRE PageComponentsPre
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL

!define TTF_FONTS "$INSTDIR\fonts\truetype\chinese"
!define FontsGen "$TempDir\FontsGen.exe"

Var CTEXSETUP
Var TempDir
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
	DetailPrint "Processing: $TTF_${CJK_NAME}"
	${GetParent} "$TTF_${CJK_NAME}" $0
	${GetFileName} "$TTF_${CJK_NAME}" $1
	SetDetailsPrint none
	ExecWait "${FontsGen} -ttfdir=$0 -destdir=Fonts -Type1 -encoding=UTF8 -ttf=$1 -CJKname=${CJK_NAME} -stemv=50"
	ExecWait "${FontsGen} -ttfdir=$0 -destdir=Fonts -Type1 -encoding=GBK  -ttf=$1 -CJKname=${CJK_NAME} -stemv=50"
	SetDetailsPrint lastused
!macroend
!define Make_Font "!insertmacro _Make_Font"

!macro _Install_FontFiles TYPE CJKNAME
	CreateDirectory "$INSTDIR\fonts\${TYPE}\chinese"
	CopyFiles /SILENT "$TempDir\Fonts\fonts\${TYPE}\chinese\uni${CJK_NAME}" "$INSTDIR\fonts\${TYPE}\chinese"
	CopyFiles /SILENT "$TempDir\Fonts\fonts\${TYPE}\chinese\gbk${CJK_NAME}" "$INSTDIR\fonts\${TYPE}\chinese"
!macroend
!define Install_FontFiles "!insertmacro _Install_FontFiles"

!macro _Install_Font CJK_NAME
	${Install_FontFiles} "tfm" ${CJK_NAME}
	${Install_FontFiles} "afm" ${CJK_NAME}
	${Install_FontFiles} "enc" ${CJK_NAME}
	${Install_FontFiles} "type1" ${CJK_NAME}
	CreateDirectory "$INSTDIR\fonts\map\chinese"
	CopyFiles /SILENT "$TempDir\Fonts\fonts\map\cjk-${CJK_NAME}.map" "$INSTDIR\fonts\map\chinese\cjk-${CJK_NAME}.map"
	CopyFiles /SILENT "$TempDir\Fonts\fonts\map\cjk-${CJK_NAME}-ttf.map" "$INSTDIR\fonts\map\chinese\cjk-${CJK_NAME}-ttf.map"
	RMDir /r "$TempDir\Fonts"
!macroend
!define Install_Font "!insertmacro _Install_Font"

Section -Init
	GetTempFileName $TempDir
	Delete $TempDir
	CreateDirectory $TempDir
	SetOutPath $TempDir
	File "FontSetup\*.*"
SectionEnd

Section "$(SongTi)" Sec_song
	${Make_Font} "song"
	${Install_Font} "song"
SectionEnd

Section "$(FangSong)" Sec_fs
	${Make_Font} "fs"
	${Install_Font} "fs"
SectionEnd

Section "$(HeiTi)" Sec_hei
	${Make_Font} "hei"
	${Install_Font} "hei"
SectionEnd

Section "$(KaiTi)" Sec_kai
	${Make_Font} "kai"
	${Install_Font} "kai"
SectionEnd

Section "$(LiShu)" Sec_li
	${Make_Font} "li"
	${Install_Font} "li"
SectionEnd

Section "$(YouYuan)" Sec_you
	${Make_Font} "you"
	${Install_Font} "you"
SectionEnd

Section -Finish
	SetOutPath $INSTDIR
	RMDir /r $TempDir
	${If} $CTEXSETUP == ""
		ExecWait "initexmf.exe --update-fndb --quiet"
		ExecWait "initexmf.exe --mkmaps --quiet"
	${EndIf}
SectionEnd

Function .onInit
	${GetParameters} $R0
	${GetOptions} $R0 "/CTEXSETUP" $CTEXSETUP
	${GetOptions} $R0 "/LANG=" $0
	${If} $0 != ""
		StrCpy $LANGUAGE $0
	${Else}
		!insertmacro MUI_LANGDLL_DISPLAY
	${EndIf}

	ReadRegStr $0 HKLM "Software\CTeX" "Install"
	${If} $0 == ""
		StrCpy $0 "C:\CTEX"
	${EndIf}
	StrCpy $INSTDIR "$0\CTeX"
	
	SectionSetSize ${Sec_song} 35000
	SectionSetSize ${Sec_fs} 35000
	SectionSetSize ${Sec_hei} 35000
	SectionSetSize ${Sec_kai} 35000
	SectionSetSize ${Sec_li} 35000
	SectionSetSize ${Sec_you} 35000
FunctionEnd

Function PageComponentsPre
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

LangString SongTi ${LANG_SIMPCHINESE} "ËÎÌå"
LangString SongTi ${LANG_ENGLISH} "Song Ti"
LangString FangSong ${LANG_SIMPCHINESE} "·ÂËÎ"
LangString FangSong ${LANG_ENGLISH} "Fang Song"
LangString HeiTi ${LANG_SIMPCHINESE} "ºÚÌå"
LangString HeiTi ${LANG_ENGLISH} "Hei Ti"
LangString KaiTi ${LANG_SIMPCHINESE} "¿¬Ìå"
LangString KaiTi ${LANG_ENGLISH} "Kai Ti"
LangString LiShu ${LANG_SIMPCHINESE} "Á¥Êé"
LangString LiShu ${LANG_ENGLISH} "Li Shu"
LangString YouYuan ${LANG_SIMPCHINESE} "Ó×Ô²"
LangString YouYuan ${LANG_ENGLISH} "You Yuan"
