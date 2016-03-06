#include <iostream>
#include <fstream>
#include <string>

#include <tchar.h>
#include <Windows.h>
#include <ShlObj.h>

using namespace std;

int _tmain(int argc, _TCHAR **argv) {

	TCHAR AppDataPath[MAX_PATH];
	SHGetFolderPath(NULL, CSIDL_APPDATA, NULL, NULL, AppDataPath);
	wcscat_s(AppDataPath, _T("\\WinEdt Team\\WinEdt 9\\"));


	cout << "WinEdt 默认编码配置切换工具" << endl;
	cout << "此工具随 CTeX 套装发布" << endl;
	cout << "警告：如果使用此工具，则会丢失所有对 WinEdt 的自定义配置" << endl;
	cout << "如果需要，可以备份以下目录内的文件：";
	wcout << AppDataPath << endl << endl;

	wstring origName(_T("WinEdt.dnt")),
		ansiName(_T("ANSI.dnt")),
		utf8Name(_T("UTF8.dnt"));
	fstream origFile(origName, ios::in),
			ansiFile(ansiName, ios::in),
			utf8File(utf8Name, ios::in);
	
	if (!(utf8File && ansiFile)) {
		cerr << "配置文件不完整，可能是工作目录不正确或者已经损坏。" << endl;
		cerr << "程序将退出，建议重新安装 CTeX 套装。" << endl << endl;
		system("pause");
		return 1;
	}

	cout << "请选择你需要的默认编码：（如果没有特别需要，请选择 UTF-8 ）" << endl;
	cout << "1. UTF-8" << endl;
	cout << "2. ANSI" << endl;
	cout << "请输入编号：";
	string selection;
	cin >> selection;
	BOOL success;
	if (selection == "1") {
		success = CopyFile((LPCWSTR)utf8Name.c_str(), (LPCWSTR)origName.c_str(), false);
	}
	else if (selection == "2") {
		success = CopyFile((LPCWSTR)ansiName.c_str(), (LPCWSTR)origName.c_str(), false);
	}
	else {
		cerr << "输入不正确，请重新运行本程序。" << endl << endl;
		system("pause");
		return 2;
	}
	if (success) {
		TCHAR FilePath[MAX_PATH];
		WIN32_FIND_DATA FindFileData;
		HANDLE hListFile;

		wcscpy_s(FilePath, AppDataPath);
		wcscat_s(FilePath, _T("*.*"));
		hListFile = FindFirstFile(FilePath, &FindFileData);
		if (hListFile != INVALID_HANDLE_VALUE)
		{
			do {
				TCHAR FullPath[MAX_PATH];
				wcscpy_s(FullPath, AppDataPath);
				wcscat_s(FullPath, FindFileData.cFileName);
				DeleteFile(FullPath);
			} while (FindNextFile(hListFile, &FindFileData));
		}
		system("pause");
	}
	else {
		cerr << "编码文件复制失败。" << endl << endl;
		system("pause");
		return 3;
	}
	return 0;
}