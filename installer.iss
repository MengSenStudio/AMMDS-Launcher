; ------------------------------------
; AMMDS Installer Script (v2)
; ------------------------------------
[Languages]
Name: "chs"; MessagesFile: "Languages\ChineseSimplified.isl"
Name: "cht"; MessagesFile: "Languages\ChineseTraditional.isl"
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "ja"; MessagesFile: "Languages\Japanese.isl"
Name: "ko"; MessagesFile: "Languages\Korean.isl"

[Setup]
AppId=AMMDS
AppName=AMMDS
AppVersion=2.0.0
AppPublisher=新疆萌森软件开发工作室
DefaultDirName={autopf}\ammds
DefaultGroupName=ammds
DisableProgramGroupPage=yes
OutputBaseFilename=ammds-setup
SetupIconFile=icon.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
OutputDir=dist
UninstallDisplayName=AMMDS
UninstallDisplayIcon={app}\icon.ico
AppSupportURL=https://ammds.lifebus.top
AppUpdatesURL=https://ammds.lifebus.top
AppPublisherURL=https://ammds.lifebus.top
LanguageDetectionMethod=uilanguage

; 以管理员方式安装
PrivilegesRequired=admin

ArchitecturesInstallIn64BitMode=x64compatible

; ------------------------------------
; 安装文件
; ------------------------------------
[Files]
Source: "dist\AMMDS-Launcher.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "dist\ammds.exe"; DestDir: "{app}"; Flags: ignoreversion
; AWT/Java2D 运行库：必须与 ammds.exe 同目录
Source: "dist\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "dist\lib\*"; DestDir: "{app}\lib"; Flags: ignoreversion recursesubdirs
Source: "dist\icon.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "dist\logo.ico"; DestDir: "{app}"; Flags: ignoreversion

; ------------------------------------
; 卸载后清理 AwtSupport 创建的空目录
; ------------------------------------
[UninstallDelete]
Type: dirifempty; Name: "{app}\conf\fonts"
Type: dirifempty; Name: "{app}\conf"
Type: dirifempty; Name: "{app}\lib"
Type: dirifempty; Name: "{app}"

; ------------------------------------
; 用户可选功能
; ------------------------------------
[Tasks]
Name: "deletedata"; Description: "{cm:DeleteData}"; Flags: unchecked
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; Flags: unchecked
Name: "startmenu"; Description: "{cm:CreateStartMenuIcon}"; Flags: unchecked

; ------------------------------------
; 快捷方式
; ------------------------------------
[Icons]
Name: "{group}\AMMDS"; Filename: "{app}\AMMDS-Launcher.exe"; IconFilename: "{app}\icon.ico"; Tasks: startmenu
Name: "{commondesktop}\AMMDS"; Filename: "{app}\AMMDS-Launcher.exe"; IconFilename: "{app}\logo.ico"; Tasks: desktopicon

; ------------------------------------
; 安装完成界面执行
; ------------------------------------
[Run]
Filename: "{app}\AMMDS-Launcher.exe"; Description: "{cm:LaunchApp}"; Flags: nowait postinstall skipifsilent
Filename: "https://ammds.lifebus.top/"; Description: "{cm:OpenDocs}"; Flags: shellexec postinstall skipifsilent

[UninstallRun]
Filename: "{app}\AMMDS-Launcher.exe"; Parameters: "--uninstall"; Flags: runhidden waituntilterminated skipifdoesntexist; RunOnceId: stopApp
Filename: "cmd.exe"; Parameters: "/C taskkill /F /IM AMMDS-Launcher.exe"; Flags: runhidden; RunOnceId: killLauncher
Filename: "cmd.exe"; Parameters: "/C taskkill /F /IM ammds.exe"; Flags: runhidden; RunOnceId: killAMMDS

; ------------------------------------
; 多语言文案
; ------------------------------------
[CustomMessages]
chs.CreateDesktopIcon=创建桌面图标
chs.CreateStartMenuIcon=创建开始菜单项
chs.DeleteData=删除数据目录（v1 与 v2 数据不兼容，删除后不可恢复）
chs.ConfirmDeleteData=是否同时删除 AMMDS 数据目录？选择“是”将删除本地数据和日志，且不可恢复。
chs.LaunchApp=启动 AMMDS
chs.OpenDocs=打开官方文档

cht.CreateDesktopIcon=建立桌面圖示
cht.CreateStartMenuIcon=建立開始功能表項目
cht.DeleteData=刪除資料目錄（v1 與 v2 資料不相容，刪除後無法復原）
cht.ConfirmDeleteData=是否同時刪除 AMMDS 資料目錄？選擇「是」將刪除本機資料與日誌，且無法復原。
cht.LaunchApp=啟動 AMMDS
cht.OpenDocs=開啟官方文件

en.CreateDesktopIcon=Create a desktop icon
en.CreateStartMenuIcon=Create a Start Menu entry
en.DeleteData=Delete the data directory (v1/v2 data are incompatible; this cannot be undone)
en.ConfirmDeleteData=Also delete the AMMDS data directory? Choosing Yes removes local data and logs permanently.
en.LaunchApp=Launch AMMDS
en.OpenDocs=Open documentation

ja.CreateDesktopIcon=デスクトップにアイコンを作成
ja.CreateStartMenuIcon=スタートメニューに項目を作成
ja.DeleteData=データディレクトリを削除（v1 と v2 のデータは互換性がなく、元に戻せません）
ja.ConfirmDeleteData=AMMDS のデータディレクトリも削除しますか？“はい”を選ぶとローカルデータとログが完全に削除されます。
ja.LaunchApp=AMMDS を起動
ja.OpenDocs=公式ドキュメントを開く

ko.CreateDesktopIcon=바탕 화면 아이콘 만들기
ko.CreateStartMenuIcon=시작 메뉴 항목 만들기
ko.DeleteData=데이터 디렉터리 삭제(v1과 v2 데이터는 호환되지 않으며 복구할 수 없습니다)
ko.ConfirmDeleteData=AMMDS 데이터 디렉터리도 삭제하시겠습니까? “예”를 선택하면 로컬 데이터와 로그가 영구 삭제됩니다.
ko.LaunchApp=AMMDS 실행
ko.OpenDocs=공식 문서 열기

; ------------------------------------
; 安装前删除 v1 数据目录
; ------------------------------------
[Code]
var
  DeleteUserDataRequested: Boolean;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: Integer;
  Deleted: Boolean;
begin
  Result := '';

  { 升级安装前先停止可能占用文件的 Launcher / ammds 进程 }
  Exec('cmd.exe', '/C taskkill /F /IM AMMDS-Launcher.exe /IM ammds.exe >NUL 2>&1',
       '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Sleep(1000);

  if not WizardIsTaskSelected('deletedata') then
    Exit;

  { 以启动安装程序的原始用户身份删除其 LOCALAPPDATA\AMMDS，
    避免管理员提权后 LOCALAPPDATA 指向其他账户 }
  Deleted := ExecAsOriginalUser('cmd.exe',
    '/C rmdir /S /Q "%LOCALAPPDATA%\AMMDS"',
    '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  if not Deleted then
    Deleted := Exec('cmd.exe',
      '/C rmdir /S /Q "%LOCALAPPDATA%\AMMDS"',
      '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  if Deleted then
    Log('Original user AMMDS data directory removed.')
  else
    Log('Failed to remove original user AMMDS data directory.');

  { 兼容旧版本可能把数据放在安装目录的情况 }
  DelTree(ExpandConstant('{app}\data'), True, True, True);
  DelTree(ExpandConstant('{app}\db'), True, True, True);
  DelTree(ExpandConstant('{app}\logs'), True, True, True);

  Log('AMMDS data directories removed.');
end;

{ 把 Inno 默认的 unins000.exe 改为可读的 AMMDS-Uninstall.exe，并同步注册表 }
procedure CurStepChanged(CurStep: TSetupStep);
var
  OldExe, NewExe, OldDat, NewDat, OldMsg, NewMsg: String;
  Key, UninstallStr: String;
  Root: Integer;
begin
  if CurStep <> ssPostInstall then
    Exit;

  OldExe := ExpandConstant('{uninstallexe}');
  NewExe := ExpandConstant('{app}\AMMDS-Uninstall.exe');
  if not FileExists(OldExe) then
  begin
    Log('Uninstaller not found at ' + OldExe + ', skip renaming.');
    Exit;
  end;
  if OldExe = NewExe then
    Exit;

  OldDat := ChangeFileExt(OldExe, '.dat');
  NewDat := ChangeFileExt(NewExe, '.dat');
  OldMsg := ChangeFileExt(OldExe, '.msg');
  NewMsg := ChangeFileExt(NewExe, '.msg');

  { 升级安装时清理上一次重命名留下的文件 }
  if FileExists(NewMsg) then
    DeleteFile(NewMsg);
  if FileExists(NewDat) then
    DeleteFile(NewDat);
  if FileExists(NewExe) then
    DeleteFile(NewExe);

  if FileExists(OldMsg) then
    RenameFile(OldMsg, NewMsg);
  if FileExists(OldDat) then
    RenameFile(OldDat, NewDat);

  if not RenameFile(OldExe, NewExe) then
  begin
    Log('Failed to rename uninstaller: ' + OldExe);
    Exit;
  end;

  Key := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\AMMDS_is1';
  if IsAdminInstallMode then
  begin
    if IsWin64 then
      Root := HKLM64
    else
      Root := HKLM;
  end
  else
    Root := HKCU;

  UninstallStr := '"' + NewExe + '"';
  if RegWriteStringValue(Root, Key, 'UninstallString', UninstallStr) then
  begin
    RegWriteStringValue(Root, Key, 'QuietUninstallString', UninstallStr + ' /SILENT');
    Log('Uninstaller renamed to ' + NewExe);
  end
  else
    Log('Failed to update UninstallString registry value.');
end;

{ 卸载时询问是否删除数据目录；/DELETEUSERDATA 供静默卸载使用 }
function HasDeleteDataSwitch: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if Uppercase(ParamStr(I)) = '/DELETEUSERDATA' then
      Result := True;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    if HasDeleteDataSwitch or
       ((not UninstallSilent) and
        (MsgBox(ExpandConstant('{cm:ConfirmDeleteData}'), mbConfirmation,
                MB_YESNO or MB_DEFBUTTON2) = IDYES)) then
    begin
      DeleteUserDataRequested := True;

      DelTree(ExpandConstant('{app}\data'), True, True, True);
      DelTree(ExpandConstant('{app}\db'), True, True, True);
      DelTree(ExpandConstant('{app}\logs'), True, True, True);

      { 管理员提权通常沿用原用户配置文件，直接删除 LOCALAPPDATA\AMMDS }
      DelTree(ExpandConstant('{localappdata}\AMMDS'), True, True, True);
      Log('AMMDS user data deletion requested.');
    end;
  end
  else if (CurUninstallStep = usPostUninstall) and DeleteUserDataRequested then
  begin
    { [UninstallRun] 里的 Launcher --uninstall 可能重新创建 logs，
      因此在卸载收尾阶段再清理一次 }
    DelTree(ExpandConstant('{localappdata}\AMMDS'), True, True, True);
    Log('AMMDS user data cleaned after uninstall.');
  end;
end;
