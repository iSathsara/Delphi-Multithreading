{
    What this application does is, reading a large text file.
    This uses a dedicated thread (not main thread) for the purpose.
    It sync (Synchronize method) with the Main thread which runs the main application.
    Continuous sync is necessary to get Messages from Windows

    ** You will have a Memory Leak error if you try to Close the application before stop the thread.
       Because the thread is not terminated & still in the memory!
}

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
  protected
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
  // Global variable.
  // possible to access thru both Class & Thread
  Form3: TForm3;

implementation

{$R *.dfm}

{ TSeperateThread }

// Thread.Start calls this method automatically.
// No need of calling forcly
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

    // sync
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

  // This method is called by Synchronize() method.
  // So the thread (seperate) has to wait until following operations are completed which cause for Thread suspend
  // The problem is, if following operations takes long time, thread has to be suspended for long time.
  Form3.ProgressBar.Position:=FPercentage;
  Form3.lblPercentage.Caption:= 'Completion: ' + (FPercentage.ToString + '%');
end;

procedure TForm3.btnStartClick(Sender: TObject);
begin
  btnStart.Enabled := False;
  btnStop.Enabled := true;
  ProgressBar.State := pbsNormal;

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
  ProgressBar.State := pbsError;
end;

procedure TForm3.DoTerminateThread(Sender: TObject);
begin
  TMyThread := nil;
  btnStart.Enabled := True;
  btnStop.Enabled := False;
end;

end.
