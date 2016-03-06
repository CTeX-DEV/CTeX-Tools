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


	cout << "WinEdt Ĭ�ϱ��������л�����" << endl;
	cout << "�˹����� CTeX ��װ����" << endl;
	cout << "���棺���ʹ�ô˹��ߣ���ᶪʧ���ж� WinEdt ���Զ�������" << endl;
	cout << "�����Ҫ�����Ա�������Ŀ¼�ڵ��ļ���";
	wcout << AppDataPath << endl << endl;

	wstring origName(_T("WinEdt.dnt")),
		ansiName(_T("ANSI.dnt")),
		utf8Name(_T("UTF8.dnt"));
	fstream origFile(origName, ios::in),
			ansiFile(ansiName, ios::in),
			utf8File(utf8Name, ios::in);
	
	if (!(utf8File && ansiFile)) {
		cerr << "�����ļ��������������ǹ���Ŀ¼����ȷ�����Ѿ��𻵡�" << endl;
		cerr << "�����˳����������°�װ CTeX ��װ��" << endl << endl;
		system("pause");
		return 1;
	}

	cout << "��ѡ������Ҫ��Ĭ�ϱ��룺�����û���ر���Ҫ����ѡ�� UTF-8 ��" << endl;
	cout << "1. UTF-8" << endl;
	cout << "2. ANSI" << endl;
	cout << "�������ţ�";
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
		cerr << "���벻��ȷ�����������б�����" << endl << endl;
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
		cerr << "�����ļ�����ʧ�ܡ�" << endl << endl;
		system("pause");
		return 3;
	}
	return 0;
}