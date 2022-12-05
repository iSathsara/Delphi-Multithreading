program Architected_MultiThreading;

uses
  Vcl.Forms,
  uArchitectedForm in 'uArchitectedForm.pas' {Form5};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm5, Form5);
  Application.Run;
end.
