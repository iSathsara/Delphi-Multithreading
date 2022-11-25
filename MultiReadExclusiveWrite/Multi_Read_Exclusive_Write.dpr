program Multi_Read_Exclusive_Write;

uses
  Vcl.Forms,
  uMultiReadExclusiveWriteForm in 'uMultiReadExclusiveWriteForm.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
