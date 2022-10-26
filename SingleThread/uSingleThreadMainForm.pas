{
    What this application does is, reading a large text file.
    This uses a single thread (main thread) for the purpose.
    The application becomes unresponsive when it started, until the process is completed.
}

unit uSingleThreadMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TFrmSingleThread = class(TForm)
    ProgressBar: TProgressBar;
    lblPercentage: TLabel;
    btnStart: TButton;
    btnStop: TButton;
    lblDescription: TLabel;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
  private
    { Private declarations }
    FPercentage : Integer;
    FStopProcess: Boolean;
    FFileName   : String;
  public
    { Public declarations }
    procedure Execute;
    procedure Terminate;
  end;

var
  FrmSingleThread: TFrmSingleThread;

implementation

{$R *.dfm}

{ TFrmSingleThread }

procedure TFrmSingleThread.btnStartClick(Sender: TObject);
begin
  btnStart.Enabled := False;
  btnStop.Enabled  := True;
  FStopProcess:=false;
  lblPercentage.Caption:='';
  ProgressBar.State := pbsNormal;
                                               // this is how to go backward through path
  FFileName := ExpandFileName(GetCurrentDir + '\..\..\..\') + 'Data.txt';
  Execute;
end;

procedure TFrmSingleThread.btnStopClick(Sender: TObject);
begin
  Terminate;
end;

procedure TFrmSingleThread.Execute;
Var
  I: Integer;
  J: Integer;
  TxtFile: TextFile;
  line: String;

begin
  // Progress bar
  for I := 0 to 100 do Begin
    if FStopProcess then exit;

    FPercentage := I;

    if FileExists(FFileName) then Begin
      // assign Data.txt to Delphi file hander file (TxtFile)
      AssignFile(TxtFile, FFileName);
      // Opens a file (assigned by delphi file handler) to read, write, read/write.
      Reset(TxtFile);
    End else Begin
      raise Exception.Create('File does not exist!');
      Exit;
    End;


    // read file lines
    for J := 0 to 1000000 do
      Readln(TxtFile, line);

    // closes a file given by delphi file handler.
    CloseFile(TxtFile);
    ProgressBar.Position := FPercentage;
    lblPercentage.Caption := 'Completion: ' + (FPercentage.ToString + '%');

    Application.ProcessMessages;
  End;
end;

procedure TFrmSingleThread.Terminate;
begin
  FStopProcess := True;
  ProgressBar.State := pbsError;
  btnStop.Enabled := False;
  btnStart.Enabled := True;
end;

end.
