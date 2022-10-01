program SingleThread;

uses
  Vcl.Forms,
  uMainForm in 'uMainForm.pas' {FrmSingleThread};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmSingleThread, FrmSingleThread);
  Application.Run;
end.
