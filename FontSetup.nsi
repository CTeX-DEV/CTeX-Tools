!include "LogicLib.nsh"
!include "Sections.nsh"
!include "FileFunc.nsh"
!include "StrFunc.nsh"

${StrStr}

!define APP_NAME    "CTeX FontSetup"
!define APP_COMPANY "CTEX.ORG"
!define APP_COPYRIGHT "Copyright (C) 2009 ${APP_COMPANY}"
!define APP_VERSION "1.2.1"
!define APP_BUILD "${APP_VERSION}.0"

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
!define UPDMAP_CFG "$INSTDIR\miktex\config\updmap.cfg"
!define CTeXFonts "$TempDir\CTeXFonts.exe"

Var CTEXSETUP
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
	${If} $TFM != ""
	${OrIf} $Type1 != ""
		DetailPrint "Processing: $TTF_${CJK_NAME}"
		${GetParent} "$TTF_${CJK_NAME}" $0
		${GetFileName} "$TTF_${CJK_NAME}" $1
		SetDetailsPrint none
		nsExec::Exec "${CTeXFonts} -ttfdir=$0 -destdir=$INSTDIR $Type1 -encoding=UTF8 -ttf=$1 -CJKname=${CJK_NAME}"
		nsExec::Exec "${CTeXFonts} -ttfdir=$0 -destdir=$INSTDIR $Type1 -encoding=GBK  -ttf=$1 -CJKname=${CJK_NAME}"
		SetDetailsPrint both
	${EndIf}
!macroend
!define Make_Font "!insertmacro _Make_Font"

Section -Init Sec_init
	Call SectionInit

	GetTempFileName $TempDir
	Delete $TempDir
	CreateDirectory $TempDir
	SetOutPath $TempDir
	File FontSetup\BREAKTTC.EXE
	File FontSetup\CTeXFonts.exe
	File FontSetup\ttf2tfm.exe
	File FontSetup\ttf2pt1.exe
	File FontSetup\freetype6.dll
	File FontSetup\zlib1.dll
	File FontSetup\UGBK.sfd
	File FontSetup\Unicode.sfd
	File FontSetup\cugbk0.map
SectionEnd

Section "$(BreakTTC)" Sec_BreakTTC
	StrCpy $0 $TTF_song 3 -3
	${If} $0 == "ttc"
		StrCpy $9 $TTF_song
		StrCpy $TTF_song "${TTF_FONTS}\simsun.ttf"
		${IfNot} ${FileExists} $TTF_song
			nsExec::Exec 'BREAKTTC.exe "$9"'
			CreateDirectory "${TTF_FONTS}"
			CopyFiles /SILENT "FONT00.TTF" "$TTF_song"
			Delete "*.TTF"
		${EndIf}
	${EndIf}
SectionEnd

Section "$(TFM)" Sec_TFM
SectionEnd

Section /o "$(Type1)" Sec_Type1
SectionEnd

SectionGroup /e "$(UPDMAP)" Sec_UPDMAP
Section -RemoveAll
	${If} ${FileExists} ${UPDMAP_CFG}
		FileOpen $0 "${UPDMAP_CFG}" "r"
		FileOpen $1 "${UPDMAP_CFG}.new" "w"
		${Do}
			FileRead $0 $9
			${If} $9 == ""
				${ExitDo}
			${EndIf}
			StrCpy $8 $9 15
			${If} $8 == "# For CJK fonts"
				${Continue}
			${EndIf}
			${StrStr} $8 $9 "cjk-"
			${If} $8 != ""
				StrCpy $7 $8 12
				${If} $7 == "cjk-song.map"
					${Continue}
				${EndIf}
				StrCpy $7 $8 11
				${If} $7 == "cjk-hei.map"
				${OrIf} $7 == "cjk-kai.map"
				${OrIf} $7 == "cjk-you.map"
					${Continue}
				${EndIf}
				StrCpy $7 $8 10
				${If} $7 == "cjk-fs.map"
				${OrIf} $7 == "cjk-li.map"
					${Continue}
				${EndIf}
				StrCpy $7 $8 11
				${If} $7 == "cjk-ttf.map"
					${Continue}
				${EndIf}
			${EndIf}
			FileWrite $1 "$9"
		${Loop}
		FileClose $1
		FileClose $0
		Delete "${UPDMAP_CFG}"
		Rename "${UPDMAP_CFG}.new" "${UPDMAP_CFG}"
	${EndIf}
SectionEnd
Section "$(UPDMAP_TTF)" Sec_UPDMAP_TTF
	${GetParent} "${UPDMAP_CFG}" $R0
	CreateDirectory "$R0"
	FileOpen $0 "${UPDMAP_CFG}" a
	FileSeek $0 0 END
	FileWrite $0 "# For CJK fonts$\r$\n"
	FileWrite $0 "Map cjk-ttf.map$\r$\n"
	FileClose $0
SectionEnd
Section /o "$(UPDMAP_Type1)" Sec_UPDMAP_Type1
	${GetParent} "${UPDMAP_CFG}" $R0
	CreateDirectory "$R0"
	FileOpen $0 "${UPDMAP_CFG}" a
	FileSeek $0 0 END
	FileWrite $0 "# For CJK fonts$\r$\n"
	FileWrite $0 "Map cjk-song.map$\r$\n"
	FileWrite $0 "Map cjk-fs.map$\r$\n"
	FileWrite $0 "Map cjk-hei.map$\r$\n"
	FileWrite $0 "Map cjk-kai.map$\r$\n"
	FileWrite $0 "Map cjk-li.map$\r$\n"
	FileWrite $0 "Map cjk-you.map$\r$\n"
	FileClose $0
SectionEnd
SectionGroupEnd

SectionGroup "$(Fonts)" Sec_Fonts

Section "$(SongTi)" Sec_song
	${Make_Font} "song"
SectionEnd

Section "$(FangSong)" Sec_fs
	${Make_Font} "fs"
SectionEnd

Section "$(HeiTi)" Sec_hei
	${Make_Font} "hei"
SectionEnd

Section "$(KaiTi)" Sec_kai
	${Make_Font} "kai"
SectionEnd

Section "$(LiShu)" Sec_li
	${Make_Font} "li"
SectionEnd

Section "$(YouYuan)" Sec_you
	${Make_Font} "you"
SectionEnd

SectionGroupEnd

Section -Finish
	SetOutPath $INSTDIR
	RMDir /r $TempDir
	${If} $CTEXSETUP == ""
		DetailPrint "Update MiKTeX file name database"
		nsExec::Exec "initexmf.exe --update-fndb --quiet"
		DetailPrint "Update MiKTeX updmap database"
		nsExec::Exec "initexmf.exe --mkmaps --quiet"
	${EndIf}
SectionEnd

; Modern install component descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${Sec_BreakTTC} $(Desc_BreakTTC)
	!insertmacro MUI_DESCRIPTION_TEXT ${Sec_TFM} $(Desc_TFM)
	!insertmacro MUI_DESCRIPTION_TEXT ${Sec_Type1} $(Desc_Type1)
	!insertmacro MUI_DESCRIPTION_TEXT ${Sec_UPDMAP} $(Desc_UPDMAP)
	!insertmacro MUI_DESCRIPTION_TEXT ${Sec_UPDMAP_TTF} $(UPDMAP_TTF)
	!insertmacro MUI_DESCRIPTION_TEXT ${Sec_UPDMAP_Type1} $(UPDMAP_Type1)
	!insertmacro MUI_DESCRIPTION_TEXT ${Sec_Fonts} $(Desc_Fonts)
	!insertmacro MUI_DESCRIPTION_TEXT ${Sec_song} $(SongTi)
	!insertmacro MUI_DESCRIPTION_TEXT ${Sec_fs} $(FangSong)
	!insertmacro MUI_DESCRIPTION_TEXT ${Sec_hei} $(HeiTi)
	!insertmacro MUI_DESCRIPTION_TEXT ${Sec_kai} $(KaiTi)
	!insertmacro MUI_DESCRIPTION_TEXT ${Sec_li} $(LiShu)
	!insertmacro MUI_DESCRIPTION_TEXT ${Sec_you} $(YouYuan)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

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

	StrCPy $UPDMAP ${Sec_UPDMAP_TTF}
	
	Call .onSelChange
	
	${If} ${Silent}
		Call PageComponentsPre
	${EndIf}
FunctionEnd

Function .onSelChange
  !insertmacro StartRadioButtons $UPDMAP
    !insertmacro RadioButton ${Sec_UPDMAP_TTF}
    !insertmacro RadioButton ${Sec_UPDMAP_Type1}
  !insertmacro EndRadioButtons

	SectionSetSize ${Sec_init} 0
	SectionSetSize ${Sec_BreakTTC} 15000
	
	${If} ${SectionIsSelected} ${Sec_Type1}
		!insertmacro SelectSection ${Sec_TFM}
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

Function SectionInit
	${If} ${SectionIsSelected} ${Sec_TFM}
		StrCpy $TFM "1"
	${Else}
		StrCpy $TFM ""
	${EndIf}
	${If} ${SectionIsSelected} ${Sec_Type1}
		StrCpy $Type1 "-Type1"
	${Else}
		StrCpy $Type1 ""
	${EndIf}
FunctionEnd

LangString Desc_BreakTTC ${LANG_SIMPCHINESE} "由于dvips和pdftex不支持TTC格式的TrueType字库，需要从TTC文件中分离出单个的TTF文件。针对Windows XP/Vista/7中的宋体字库。"
LangString Desc_BreakTTC ${LANG_ENGLISH} "Since dvips and pdftex do not support TrueType font in TTC format, it is need to extract single ttf from ttc file. For Song Ti (SimSun) in Windows XP/Vista/7."
LangString Desc_TFM ${LANG_SIMPCHINESE} "生成TFM文件。TFM文件是TeX/LaTeX必须的基本字型文件。"
LangString Desc_TFM ${LANG_ENGLISH} "Generate TFM files. TFM is the basic font file required by TeX/LaTeX."
LangString Desc_Type1 ${LANG_SIMPCHINESE} "生成Type1字库。目前大多数程序都已经支持直接使用TrueType字库，因此建议不使用。"
LangString Desc_Type1 ${LANG_ENGLISH} "Generate Type1 fonts. Since most programs support TrueType directly now, do not recommend."
LangString Desc_UPDMAP ${LANG_SIMPCHINESE} "修改updmap.cfg，指定dvips/pdftex/dvipdfm缺省使用中文TrueType还是Type1字库。"
LangString Desc_UPDMAP ${LANG_ENGLISH} "Modify updmap.cfg, set the default font type (TrueType or Type1) for dvips/pdftex/dvipdfm."
LangString Desc_Fonts ${LANG_SIMPCHINESE} "系统中可供使用的中文字体"
LangString Desc_Fonts ${LANG_ENGLISH} "Available Chinese fonts in the system"

LangString BreakTTC ${LANG_SIMPCHINESE} "从TTC中提取TTF"
LangString BreakTTC ${LANG_ENGLISH} "Extract TTF from TTC"
LangString TFM ${LANG_SIMPCHINESE} "生成TFM文件"
LangString TFM ${LANG_ENGLISH} "Generate TFM files"
LangString Type1 ${LANG_SIMPCHINESE} "生成Type1字库"
LangString Type1 ${LANG_ENGLISH} "Generate Type1 fonts"
LangString UPDMAP ${LANG_SIMPCHINESE} "修改updmap.cfg"
LangString UPDMAP ${LANG_ENGLISH} "Modify updmap.cfg"
LangString UPDMAP_TTF ${LANG_SIMPCHINESE} "使用TrueType字库"
LangString UPDMAP_TTF ${LANG_ENGLISH} "Use TrueType fonts"
LangString UPDMAP_Type1 ${LANG_SIMPCHINESE} "使用Type1字库"
LangString UPDMAP_Type1 ${LANG_ENGLISH} "Use Type1 fonts"
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
