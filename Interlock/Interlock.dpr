program Interlock;

uses
  Vcl.Forms,
  uInterlockMainForm in 'uInterlockMainForm.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm5, Form5);
  Application.Run;
end.
