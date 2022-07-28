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
  hRemoteProcess := OpenProcess(PROCESS_CREATE_THREAD + {����Զ�̴����߳�}   
      PROCESS_VM_OPERATION + {����Զ��VM����}   
      PROCESS_VM_WRITE, {����Զ��VMд}   
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
hSnapshot:   THandle;//���ڻ�ý����б�
lppe:   TProcessEntry32;//���ڲ��ҽ���
Found:   Boolean;//�����жϽ��̱����Ƿ����
begin
Result   :=False;
hSnapshot   :=   CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,   0);//���ϵͳ�����б�
lppe.dwSize   :=   SizeOf(TProcessEntry32);//�ڵ���Process32First   API֮ǰ����Ҫ��ʼ��lppe��¼�Ĵ�С
Found   :=   Process32First(hSnapshot,   lppe);//�������б�ĵ�һ��������Ϣ����ppe��¼��
while   Found   do
begin
if   ((UpperCase(ExtractFileName(lppe.szExeFile))=UpperCase(AFileName))   or   (UpperCase(lppe.szExeFile   )=UpperCase(AFileName)))   then
begin
Result   :=True;
end;
Found   :=   Process32Next(hSnapshot,   lppe);//�������б����һ��������Ϣ����lppe��¼��
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
