program SingleThread;

uses
  Vcl.Forms,
  uSingleThreadMainForm in 'uSingleThreadMainForm.pas' {FrmSingleThread};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmSingleThread, FrmSingleThread);
  Application.Run;
end.
