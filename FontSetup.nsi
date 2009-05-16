!include "LogicLib.nsh"
!include "Sections.nsh"
!include "FileFunc.nsh"

!define APP_NAME    "CTeX Font Setup"
!define APP_COMPANY "CTEX.ORG"
!define APP_COPYRIGHT "Copyright (C) 2009 ${APP_COMPANY}"
!define APP_VERSION "1.1"
!define APP_BUILD "${APP_VERSION}.0.0"

Name "${APP_NAME}"
BrandingText "${APP_NAME} ${APP_VERSION} (C) CTEX.ORG"
OutFile "FontSetup.exe"

ShowInstDetails nevershow

SetCompressor /SOLID LZMA

!include "MUI2.nsh"

!define MUI_ICON "FontSetup.ico"

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
Var BreakTTC
Var TFM
Var Type1
Var UPDMAP
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
	ExecWait "${FontsGen} -ttfdir=$0 -destdir=Fonts $Type1 -encoding=UTF8 -ttf=$1 -CJKname=${CJK_NAME} -stemv=50"
	ExecWait "${FontsGen} -ttfdir=$0 -destdir=Fonts $Type1 -encoding=GBK  -ttf=$1 -CJKname=${CJK_NAME} -stemv=50"
	SetDetailsPrint lastused
!macroend
!define Make_Font "!insertmacro _Make_Font"

!macro _Install_FontFiles TYPE CJKNAME
	CreateDirectory "$INSTDIR\fonts\${TYPE}\chinese"
	CopyFiles /SILENT "$TempDir\Fonts\fonts\${TYPE}\chinese\uni${CJK_NAME}" "$INSTDIR\fonts\${TYPE}\chinese"
	CopyFiles /SILENT "$TempDir\Fonts\fonts\${TYPE}\chinese\gbk${CJK_NAME}" "$INSTDIR\fonts\${TYPE}\chinese"
!macroend
!define Install_FontFiles "!insertmacro _Install_FontFiles"

!macro _Install_TFM_Font CJK_NAME
	${Install_FontFiles} "tfm" ${CJK_NAME}
!macroend
!define Install_TFM_Font "!insertmacro _Install_TFM_Font"

!macro _Install_Type1_Font CJK_NAME
	${Install_FontFiles} "afm" ${CJK_NAME}
	${Install_FontFiles} "enc" ${CJK_NAME}
	${Install_FontFiles} "type1" ${CJK_NAME}
	CreateDirectory "$INSTDIR\fonts\map\chinese"
	CopyFiles /SILENT "$TempDir\Fonts\fonts\map\cjk-${CJK_NAME}.map" "$INSTDIR\fonts\map\chinese\cjk-${CJK_NAME}.map"
!macroend
!define Install_Type1_Font "!insertmacro _Install_Type1_Font"

!macro _Install_Font CJK_NAME
	${If} $TFM != ""
		${Install_TFM_Font} ${CJK_NAME}
	${EndIf}
	${If} $Type1 != ""
		${Install_Type1_Font} ${CJK_NAME}
	${EndIf}
	RMDir /r "$TempDir\Fonts"
!macroend
!define Install_Font "!insertmacro _Install_Font"

Section -Init Sec_init
	GetTempFileName $TempDir
	Delete $TempDir
	CreateDirectory $TempDir
	SetOutPath $TempDir
	File "FontSetup\*.*"
SectionEnd

Section "$(BreakTTC)" Sec_BreakTTC
	StrCpy $BreakTTC "1"
SectionEnd

Section "$(TFM)" Sec_TFM
	StrCpy $TFM "1"
SectionEnd

SectionGroup "$(Type1)" Sec_Type1
Section
	StrCpy $Type1 "-Type1"
SectionEnd
Section "$(UPDMAP)" Sec_UPDMAP
	StrCpy $UPDMAP "1"
SectionEnd
SectionGroupEnd

SectionGroup "$(Fonts)" Sec_Fonts

Section "$(SongTi)" Sec_song
	StrCpy $0 $TTF_song 3 -3
	${If} $0 == "ttc"
		StrCpy $9 $TTF_song
		StrCpy $TTF_song "${TTF_FONTS}\simsun.ttf"
		${IfNot} ${FileExists} $TTF_song
			ExecWait 'BREAKTTC.exe "$9"'
			CreateDirectory "${TTF_FONTS}"
			CopyFiles /SILENT "FONT00.TTF" "$TTF_song"
			Delete "*.TTF"
		${EndIf}
	${EndIf}

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

SectionGroupEnd

Section -Finish
	${If} $UPDMAP != ""
		; todo
	${EndIf}
	SetOutPath $INSTDIR
	RMDir /r $TempDir
	${If} $CTEXSETUP == ""
		ExecWait "initexmf.exe --update-fndb --quiet"
		ExecWait "initexmf.exe --mkmaps --quiet"
	${EndIf}
SectionEnd

Function .onInit
	${GetParameters} $R0
	${GetOptions} $R0 "/CTEXSETUP=" $CTEXSETUP
	${GetOptions} $R0 "/LANG=" $0
	${If} $0 != ""
		StrCpy $LANGUAGE $0
	${Else}
		!insertmacro MUI_LANGDLL_DISPLAY
	${EndIf}

	${If} $CTEXSETUP != ""
		StrCpy $INSTDIR $CTEXSETUP
	${Else}
		ReadRegStr $0 HKLM "Software\CTeX" "Install"
		${If} $0 == ""
			StrCpy $0 "C:\CTEX"
		${EndIf}
		StrCpy $INSTDIR "$0\CTeX"
	${EndIf}

	StrCpy $BreakTTC ""
	StrCpy $TFM ""
	StrCpy $Type1 ""
	StrCPy $UPDMAP ""
	
	!insertmacro UnselectSection ${Sec_Type1}
	
	Call .onSelChange
FunctionEnd

Function .onSelChange
	SectionSetSize ${Sec_init} 0
	
	${If} ${SectionIsSelected} ${Sec_Type1}
		SectionSetSize ${Sec_song} 35000
		SectionSetSize ${Sec_fs} 35000
		SectionSetSize ${Sec_hei} 35000
		SectionSetSize ${Sec_kai} 35000
		SectionSetSize ${Sec_li} 35000
		SectionSetSize ${Sec_you} 35000
	${Else}
		SectionSetSize ${Sec_song} 0
		SectionSetSize ${Sec_fs} 0
		SectionSetSize ${Sec_hei} 0
		SectionSetSize ${Sec_kai} 0
		SectionSetSize ${Sec_li} 0
		SectionSetSize ${Sec_you} 0
	${EndIf}

	${If} ${SectionIsSelected} ${Sec_BreakTTC}
		SectionGetSize ${Sec_song} $0
		IntOp $0 $0 + 15000
		SectionSetSize ${Sec_song} $0
	${EndIf}
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

LangString BreakTTC ${LANG_SIMPCHINESE} "从ttc中提取ttf"
LangString BreakTTC ${LANG_ENGLISH} "Extract ttf from ttc"
LangString TFM ${LANG_SIMPCHINESE} "生成TFM文件"
LangString TFM ${LANG_ENGLISH} "Generate TFM files"
LangString Type1 ${LANG_SIMPCHINESE} "生成Type1字库"
LangString Type1 ${LANG_ENGLISH} "Generate Type1 fonts"
LangString UPDMAP ${LANG_SIMPCHINESE} "修改updmap.cfg"
LangString UPDMAP ${LANG_ENGLISH} "Modify updmap.cfg"
LangString Fonts ${LANG_SIMPCHINESE} "可用字体"
LangString Fonts ${LANG_ENGLISH} "Available Fonts"
LangString SongTi ${LANG_SIMPCHINESE} "宋体"
LangString SongTi ${LANG_ENGLISH} "Song Ti"
LangString FangSong ${LANG_SIMPCHINESE} "仿宋"
LangString FangSong ${LANG_ENGLISH} "Fang Song"
LangString HeiTi ${LANG_SIMPCHINESE} "黑体"
LangString HeiTi ${LANG_ENGLISH} "Hei Ti"
LangString KaiTi ${LANG_SIMPCHINESE} "楷体"
LangString KaiTi ${LANG_ENGLISH} "Kai Ti"
LangString LiShu ${LANG_SIMPCHINESE} "隶书"
LangString LiShu ${LANG_ENGLISH} "Li Shu"
LangString YouYuan ${LANG_SIMPCHINESE} "幼圆"
LangString YouYuan ${LANG_ENGLISH} "You Yuan"

VIAddVersionKey /LANG=${LANG_SIMPCHINESE} "ProductName" "${APP_NAME}"
VIAddVersionKey /LANG=${LANG_SIMPCHINESE} "CompanyName" "${APP_COMPANY}"
VIAddVersionKey /LANG=${LANG_SIMPCHINESE} "FileDescription" "CTeX中文字库安装工具"
VIAddVersionKey /LANG=${LANG_SIMPCHINESE} "FileVersion" "${APP_VERSION}"
VIAddVersionKey /LANG=${LANG_SIMPCHINESE} "LegalCopyright" "${APP_COPYRIGHT}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${APP_NAME}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "${APP_COMPANY}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "CTeX Chinese Font Setup Tool"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${APP_VERSION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "${APP_COPYRIGHT}"
VIProductVersion "${APP_BUILD}"
