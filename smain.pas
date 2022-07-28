unit smain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  ExtCtrls,TLHelp32;

type
  TAdsafe = class(TService)
    Timer1: TTimer;
    procedure ServiceCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  Adsafe: TAdsafe;
  addin,doing,stopall:boolean;
  apppath,ossyspath:string;
implementation


{$R *.DFM}

procedure FindAProcess(const AFilename: string; const PathMatch: Boolean; var ProcessID: DWORD);   
var   
  lppe: TProcessEntry32;   
  SsHandle: Thandle;   
  FoundAProc, FoundOK: boolean;   
begin   
  ProcessID :=0;   
  SsHandle := CreateToolHelp32SnapShot(TH32CS_SnapProcess, 0);   
  FoundAProc := Process32First(Sshandle, lppe);   
  while FoundAProc do   
  begin   
    if PathMatch then   
      FoundOK := AnsiStricomp(lppe.szExefile, PChar(AFilename)) = 0   
    else   
      FoundOK := AnsiStricomp(PChar(ExtractFilename(lppe.szExefile)), PChar(ExtractFilename(AFilename))) = 0;   
    if FoundOK then   
    begin   
      ProcessID := lppe.th32ProcessID;   
      break;   
    end;   
    FoundAProc := Process32Next(SsHandle, lppe);   
  end;   
  CloseHandle(SsHandle);   
end;   
   
function EnabledDebugPrivilege(const bEnabled: Boolean): Boolean;   
var   
  hToken: THandle;   
  tp: TOKEN_PRIVILEGES;   
  a: DWORD;   
const   
  SE_DEBUG_NAME = 'SeDebugPrivilege';   
begin   
  Result := False;   
  if (OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES, hToken)) then   
  begin   
    tp.PrivilegeCount := 1;   
    LookupPrivilegeValue(nil, SE_DEBUG_NAME, tp.Privileges[0].Luid);   
    if bEnabled then   
      tp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED   
    else   
      tp.Privileges[0].Attributes := 0;   
    a := 0;   
    AdjustTokenPrivileges(hToken, False, tp, SizeOf(tp), nil, a);   
    Result := GetLastError = ERROR_SUCCESS;   
    CloseHandle(hToken);   
  end;   
end;   
   
function AttachToProcess(const HostFile, GuestFile: string; const PID: DWORD = 0): DWORD;   
var   
  hRemoteProcess: THandle;   
  dwRemoteProcessId: DWORD;   
  cb: DWORD;   
  pszLibFileRemote: Pointer;   
  iReturnCode: Boolean;   
  TempVar: DWORD;   
  pfnStartAddr: TFNThreadStartRoutine;   
  pszLibAFilename: PwideChar;   
begin   
  Result := 0;   
  EnabledDebugPrivilege(True);   
  Getmem(pszLibAFilename, Length(GuestFile) * 2 + 1);   
  StringToWideChar(GuestFile, pszLibAFilename, Length(GuestFile) * 2 + 1);   
  if PID > 0 then   
     dwRemoteProcessID := PID   
  else   
     FindAProcess(HostFile, False, dwRemoteProcessID);   
  hRemoteProcess := OpenProcess(PROCESS_CREATE_THREAD + {允许远程创建线程}   
      PROCESS_VM_OPERATION + {允许远程VM操作}   
      PROCESS_VM_WRITE, {允许远程VM写}   
      FALSE, dwRemoteProcessId);   
  cb := (1 + lstrlenW(pszLibAFilename)) * sizeof(WCHAR);   
  pszLibFileRemote := PWIDESTRING(VirtualAllocEx(hRemoteProcess, nil, cb, MEM_COMMIT, PAGE_READWRITE));   
  TempVar := 0;   
  iReturnCode := WriteProcessMemory(hRemoteProcess, pszLibFileRemote, pszLibAFilename, cb, TempVar);   
  if iReturnCode then   
  begin   
    pfnStartAddr := GetProcAddress(GetModuleHandle('Kernel32'), 'LoadLibraryW');   
    TempVar := 0;   
    Result := CreateRemoteThread(hRemoteProcess, nil, 0, pfnStartAddr, pszLibFileRemote, 0, TempVar);   
  end;   
  Freemem(pszLibAFilename);   
end;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  Adsafe.Controller(CtrlCode);
end;

function TAdsafe.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

function   FindProcess(AFileName:   string):   boolean;
var
hSnapshot:   THandle;//用于获得进程列表
lppe:   TProcessEntry32;//用于查找进程
Found:   Boolean;//用于判断进程遍历是否完成
begin
Result   :=False;
hSnapshot   :=   CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,   0);//获得系统进程列表
lppe.dwSize   :=   SizeOf(TProcessEntry32);//在调用Process32First   API之前，需要初始化lppe记录的大小
Found   :=   Process32First(hSnapshot,   lppe);//将进程列表的第一个进程信息读入ppe记录中
while   Found   do
begin
if   ((UpperCase(ExtractFileName(lppe.szExeFile))=UpperCase(AFileName))   or   (UpperCase(lppe.szExeFile   )=UpperCase(AFileName)))   then
begin
Result   :=True;
end;
Found   :=   Process32Next(hSnapshot,   lppe);//将进程列表的下一个进程信息读入lppe记录中
end;
end;

procedure TAdsafe.ServiceCreate(Sender: TObject);
begin
  if not doing then
  begin
    doing:=true;
    if fileexists(apppath+'Adsafe.dll') then
    begin
      if FindProcess('BarClientView.exe') then
      begin
        if not addin then
        begin
          addin:=true;
          sleep(100);
          AttachToProcess('BarClientView.exe', apppath+'Adsafe.dll');
        end;
      end
      else
      begin
        addin:=false;
      end;
    end;
    doing:=false;
  end;
end;

procedure TAdsafe.Timer1Timer(Sender: TObject);
begin
  if not doing then
  begin
    doing:=true;
    if fileexists(apppath+'Adsafe.dll') then
    begin
      if FindProcess('BarClientView.exe') then
      begin
        if not addin then
        begin
          addin:=true;
          sleep(100);
          AttachToProcess('BarClientView.exe', apppath+'Adsafe.dll');
        end;
      end
      else
      begin
        addin:=false;
      end;
    end;
    doing:=false;
  end;
end;

end.
