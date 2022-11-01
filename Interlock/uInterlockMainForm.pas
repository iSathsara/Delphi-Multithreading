{
  Ref: Microsoft Doc

  Interlocked functions provide a simple mechanism for synchronizing access to variable
  that is shared by multiple threads.
  They also perform operations on variables (read / writes) in an atomic manner

  'Atomic Operation' --> Simple Reads & Writes to properly-aligned to 32 bit variables
}
unit uInterlockMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, SyncObjs, ExtCtrls;

type
  TSeperateThread = class(TThread)
  private
    FFIleName : String;

    procedure LoadFile;
  public
    procedure Execute; override;
  end;

type
  TForm5 = class(TForm)
    lblDescription: TLabel;
    ProgressBar: TProgressBar;
    lblPercentage: TLabel;
    btnStart: TButton;
    btnStop: TButton;
    TimerInterlock: TTimer;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure TimerInterlockTimer(Sender: TObject);
  private
    { Private declarations }
    TMyThread : TSeperateThread;
    FProgress : Integer;

    procedure DoTerminate(Sender : TObject);
  public
    { Public declarations }
    procedure UpdateProgress(AProgress : Integer);
  end;

var
  Form5: TForm5;

implementation

{$R *.dfm}

{ TSeperateThread }

// This method will automatically called when Thread is starting...
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
    Form5.UpdateProgress(I)
  End;
end;

procedure TSeperateThread.LoadFile;
begin
  FFileName := ExpandFileName(GetCurrentDir + '\..\..\..\') + 'Data.txt';
end;

{______________________________________________________________________________}
{______________________________________________________________________________}


{ TForm1 }

procedure TForm5.btnStartClick(Sender: TObject);
begin
  btnStart.Enabled := False;
  btnStop.Enabled := True;
  ProgressBar.State := pbsNormal;

  TMyThread := TSeperateThread.Create(True);
  TMyThread.OnTerminate := Self.DoTerminate;
  TMyThread.Start;
end;

procedure TForm5.btnStopClick(Sender: TObject);
begin
  if TMyThread <> NIL then
    TMyThread.Terminate;
end;

// this method is automatically called when Thread is terminating
procedure TForm5.DoTerminate(Sender: TObject);
begin
  TMyThread := NIL;
  ProgressBar.State := pbsError;
  btnStart.Enabled := True;
  btnStop.Enabled := False;
end;

procedure TForm5.UpdateProgress(AProgress: Integer);
begin
  // sets 32 bit variable to the specified value, as an atomic operation
  InterlockedExchange(FProgress, AProgress);
end;

// GUI update
procedure TForm5.TimerInterlockTimer(Sender: TObject);
var
  Perc: String;
begin
  Perc := InterlockedExchangeAdd(FProgress, 0).ToString;
                          // adds two variables together and stores the result in one variable
  ProgressBar.Position := InterlockedExchangeAdd(FProgress, 0);
  lblPercentage.Caption := 'Completion ' + Perc + '%';
end;

end.
