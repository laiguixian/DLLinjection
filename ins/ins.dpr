program ins;



{$R 'res\ins.res' 'res\ins.rc'}

uses
  Forms,
  main in 'main.pas' {mainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TmainForm, mainForm);
  Application.Run;
end.
