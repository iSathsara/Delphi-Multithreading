unit uMultiThreadMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TSeperateThread = class(TThread)
  private
    FPercentage : Integer;
    FFileName   : String;

    procedure LoadFile;
  public
    procedure Execute; override;
    procedure SyncWithMainThread();
  end;

  TForm3 = class(TForm)
    lblDescription: TLabel;
    ProgressBar: TProgressBar;
    lblPercentage: TLabel;
    btnStart: TButton;
    btnStop: TButton;

    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
  private
    { Private declarations }
    TMyThread : TSeperateThread;

    procedure DoTerminateThread(Sender: TObject);
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

{ TSeperateThread }

procedure TSeperateThread.Execute;
Var
  I: Integer;
  J: Integer;
  TxtFile: TextFile;
  line: String;
begin

  // execute Thread. From TThread class
  for I := 1 to 100 do Begin

    // break loop if thread is broken
    if Self.Terminated then Break;

    FPercentage := I;

    // load text file
    LoadFile;
    if FileExists(FFileName) then begin
      AssignFile(TxtFile, FFileName);
      Reset(TxtFile)
    end else
      raise Exception.Create('File can not be loaded!');

    // read file lines
    for J := 0 to 1000000 do
      Readln(TxtFile, line);

    Synchronize(SyncWithMainThread);
    CloseFile(TxtFile);

  End;
end;

procedure TSeperateThread.LoadFile;
begin
  FFileName := ExpandFileName(GetCurrentDir + '\..\..\..\') + 'Data.txt';
end;

procedure TSeperateThread.SyncWithMainThread();
begin
  // progress update should show here

end;

procedure TForm3.btnStartClick(Sender: TObject);
begin
  btnStart.Enabled := False;
  btnStop.Enabled := true;

  TMyThread := TSeperateThread.Create(True);
  TMyThread.FreeOnTerminate:= True;
                           // calls DoTerminate method in Form Class
  TMyThread.OnTerminate := DoTerminateThread;
  TMyThread.Start;
end;

procedure TForm3.btnStopClick(Sender: TObject);
begin
  if TMyThread <> nil then
    TMyThread.Terminate;
end;

procedure TForm3.DoTerminateThread(Sender: TObject);
begin
  TMyThread := nil;
  btnStart.Enabled := True;
  btnStop.Enabled := False;
end;

end.
