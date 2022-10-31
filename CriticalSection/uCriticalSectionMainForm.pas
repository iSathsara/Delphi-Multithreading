unit uCriticalSectionMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, SyncObjs;

                          // use to define private messages.
                          // usually, WM_APP + x
const WM_UPDATE_PROCESS = WM_APP + 100;

type
  TSeperateThread = class(TTHread)
  private
    FFileName   : String;

    procedure LoadFile;
  public
    procedure Execute(); override;
  end;

type
  TForm4 = class(TForm)
    lblDescription: TLabel;
    ProgressBar: TProgressBar;
    lblPercentage: TLabel;
    btnStart: TButton;
    btnStop: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
  private
    { Private declarations }
    FProgress: Integer;
    TMyThread : TSeperateThread;
    FCriticalSection : TCriticalSection;  // comes from SyncObjs

    procedure WindowsMsgUpdateProgress(var AMessage: TMessage); message WM_UPDATE_PROCESS;
    procedure DoTerminate(Sender: TObject);
  public
    { Public declarations }
    procedure UpdateProgress(AProgress: Integer);
  end;

var
  Form4: TForm4;

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
  for I := 1 to 100 do Begin

    // break loop if thread is broken
    if Self.Terminated then Break;

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

    CloseFile(TxtFile);
    Form4.UpdateProgress(I);
  End;
end;

procedure TSeperateThread.LoadFile;
begin
  FFileName := ExpandFileName(GetCurrentDir + '\..\..\..\') + 'Data.txt';
end;
{______________________________________________________________________________}
{______________________________________________________________________________}
procedure TForm4.btnStartClick(Sender: TObject);
begin
  btnStart.Enabled := False;
  btnStop.Enabled := true;
  ProgressBar.State := pbsNormal;

  TMyThread := TSeperateThread.Create(True);
  TMyThread.OnTerminate := DoTerminate;
  TMyThread.Start;
end;

procedure TForm4.btnStopClick(Sender: TObject);
begin
  if TMyThread <> nil then
    TMyThread.Terminate;
end;

procedure TForm4.DoTerminate(Sender: TObject);
begin
  TMyThread := NIL;
  ProgressBar.State := pbsError;
  btnStart.Enabled := True;
  btnStop.Enabled := False;
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  FCriticalSection := TCriticalSection.Create;
end;

procedure TForm4.FormDestroy(Sender: TObject);
begin
  if FCriticalSection <> NIL then FCriticalSection.Free;
end;

// this method calls in Thread
procedure TForm4.UpdateProgress(AProgress: Integer);
begin
  // critical section to update progress & post in message queue
  FCriticalSection.Enter;
  FProgress := AProgress;
  FCriticalSection.Leave;

  // post a message in the message queue, associated with the thread
  PostMessage(Handle, WM_UPDATE_PROCESS, 0, 0);
end;

procedure TForm4.WindowsMsgUpdateProgress(var AMessage: TMessage);
var
  AProgress: Integer;
begin
  // critical section use to update the progress
  FCriticalSection.Enter;
  AProgress := FProgress;
  FCriticalSection.Leave;

  ProgressBar.Position := AProgress;
  lblPercentage.Caption := 'Completion ' + (AProgress.ToString) + '%';
end;

end.
