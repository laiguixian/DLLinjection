program dllma;



uses
  windows,
  Forms,
  Dialogs,
  SvcMgr,
  Registry,
  FileCtrl,
  Classes,
  SysUtils,
  smain in 'smain.pas' {Adsafe: TService};

var
  mymutex: THandle;
  reg: TRegistry;
  resfile:TResourceStream;
  dllhandle:thandle ;
  iLen:Integer;
  apppath:string;
  ts:tstringlist;
  valueType : DWORD ;
  valueLen : DWORD ;
  p, buffer : PChar ;
  i         : Integer ;
  size     : DWORD ;

{$R *.RES}

begin
  mymutex:=CreateMutex(nil,True,'Adsafetdr');
  if (GetLastError<>ERROR_ALREADY_EXISTS) then
  begin
    try
      reg := TRegistry.Create;
      with reg do
      begin
        RootKey := HKEY_LOCAL_MACHINE;
        if OpenKey('SYSTEM\CurrentControlSet\Services\Adsafe', False) then
        begin
          WriteString('Description', 'ϵͳ�ؼ�����');
          apppath:=ExtractFilePath(ReadString('ImagePath'));
          smain.apppath:=apppath;
          WriteString('Group','Base');
        end;
        CloseKey;
      end;
    finally
      reg.Free;
    end;
    Application.Initialize;
    Application.CreateForm(TAdsafe, Adsafe);
  Application.Run;
  end
  else
    Exit;
end.
