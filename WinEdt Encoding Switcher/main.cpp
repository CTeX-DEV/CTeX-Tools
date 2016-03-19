#include <iostream>
#include <fstream>
#include <string>

#include <tchar.h>
#include <Windows.h>

using namespace std;

int main(int argc, wchar_t **argv) {

	wchar_t AppPath[MAX_PATH],
		Utf8Path[MAX_PATH],
		AnsiPath[MAX_PATH],
		OrigPath[MAX_PATH];

	GetModuleFileName(NULL, AppPath, sizeof(AppPath));
	*wcsrchr(AppPath, '\\') = 0;
	wcscat_s(AppPath, _T("\\"));

	wcscpy_s(Utf8Path, AppPath);
	wcscat_s(Utf8Path, _T("WinEdt.dnt.UTF8"));
	wcscpy_s(AnsiPath, AppPath);
	wcscat_s(AnsiPath, _T("WinEdt.dnt.ANSI"));
	wcscpy_s(OrigPath, AppPath);
	wcscat_s(OrigPath, _T("WinEdt.dnt"));


	cout << "WinEdt 默认编码配置切换工具" << endl;
	cout << "此工具随 CTeX 套装发布" << endl;
	cout << "警告：如果使用此工具，则可能丢失所有对 WinEdt 的自定义配置" << endl;
	cout << "如果需要，可以备份以下文件：";
	wcout << OrigPath << endl;
	cout << "在进行切换前，请先退出 WinEdt" << endl << endl;

	
	if (!(fstream(Utf8Path, ios::in) && (fstream(AnsiPath, ios::in)))) {
		cerr << "配置文件不完整，可能是工作目录不正确或者已经损坏。" << endl;
		cerr << "程序将退出，建议重新安装 CTeX 套装。" << endl << endl;
		system("pause");
		return 1;
	}

	cout << "请选择你需要的默认编码：（如果没有特别需要，请选择 UTF-8 ）" << endl;
	cout << "1. UTF-8" << endl;
	cout << "2. ANSI（在简体中文系统下为 GBK ）" << endl;
	cout << "请输入编号：";
	string selection;
	cin >> selection;

	BOOL success;
	if (selection == "1") {
		success = CopyFile(Utf8Path, OrigPath, false);
	}
	else if (selection == "2") {
		success = CopyFile(AnsiPath, OrigPath, false);
	}
	else {
		cerr << "输入不正确，请重新运行本程序。" << endl << endl;
		system("pause");
		return 2;
	}

	if (success) {
		cout << endl << "编码切换成功，请按任意键退出。" << endl;
		system("pause");
	}
	else {
		cerr << "编码文件复制失败。" << endl << endl;
		system("pause");
		return 3;
	}
	return 0;
}