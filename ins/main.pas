unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FileCtrl, Buttons,Registry, ExtCtrls;

type
  TmainForm = class(TForm)
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Label2: TLabel;
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    SpeedButton3: TSpeedButton;
    Timer1: TTimer;
    procedure DirectoryListBox1Change(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  mainForm: TmainForm;
  unins:boolean;
  apppath:string;
implementation

{$R *.dfm}

procedure TmainForm.DirectoryListBox1Change(Sender: TObject);
begin
  Label1.Caption:='请选择安装路径：'+DirectoryListBox1.Directory+'\Adsafe\';
end;

procedure TmainForm.SpeedButton2Click(Sender: TObject);
begin
  Self.Close;
end;

procedure TmainForm.SpeedButton1Click(Sender: TObject);
var
resfile:TResourceStream;
begin
  if Label1.Caption='请选择安装路径：' then
  begin
    showmessage('请选择安装路径！');
    Exit;
  end;
  if not DirectoryExists(DirectoryListBox1.Directory+'\Adsafe\') then
    ForceDirectories(DirectoryListBox1.Directory+'\Adsafe\');
  resfile:=TResourceStream.Create(HInstance,'dllma','exefile');
  if not fileexists(DirectoryListBox1.Directory+'\Adsafe\'+'dllma.exe') then
    resfile.SaveToFile(DirectoryListBox1.Directory+'\Adsafe\'+'dllma.exe');
  resfile.Free;
  WinExec(pchar(DirectoryListBox1.Directory+'\Adsafe\'+'dllma.exe /install -s -q -y'), SW_Hide);
  showmessage('安装完成！请退出！');
end;

procedure TmainForm.SpeedButton3Click(Sender: TObject);
var
reg :TRegistry;
begin
  try
    reg := TRegistry.Create;
    with reg do
    begin
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('SYSTEM\CurrentControlSet\Services\Adsafe', False) then
      begin
        //apppath:=ExtractFilePath(ReadString('ImagePath'));
        apppath:=ReadString('ImagePath');
        WinExec(pchar(apppath+' /uninstall'), SW_Hide);
        sleep(3000);
        unins:=true;
      end
      else
        showmessage('没有安装该软件！');
      CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

procedure TmainForm.Timer1Timer(Sender: TObject);
begin
  if unins then
  begin
    Deletefile(apppath);
    RemoveDirectory(PChar(ExtractFilePath(apppath)));
    if not DirectoryExists(ExtractFilePath(apppath)) then
    begin
      unins:=false;
      showmessage('卸载完成！请退出！');
    end;
  end;
end;

end.
