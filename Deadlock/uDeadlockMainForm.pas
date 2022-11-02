unit uDeadlockMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, SyncObjs;

const
  THREAD_COUNT = 10;

type
  TForm6 = class;

  TThreadMessage = record
    FChannelNo     : integer;
    FMessageBuffer : array of Byte;
  end;

  TMessageQueue = record
    FCriticalSec : TCriticalSection;
    FMessages    : array of TThreadMessage;
  end;

  TSeperateThread = class(TThread)
  private
    FOwner    : TForm6;
    FThreadNo : Integer;
    FMessageQueue : TMessageQueue;
  protected
    procedure Execute(); override;
  public
    constructor Create(AOwner: TForm6; AThreadNo : Integer);
    destructor Destroy(); override;
  end;

  TForm6 = class(TForm)
    lblDescription: TLabel;
    ShpStatus: TShape;
    ListBx: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    TMyThread : array [0..THREAD_COUNT-1] of TSeperateThread;
  public
    { Public declarations }
  end;


var
  Form6: TForm6;

implementation

{$R *.dfm}

{ TSeperateThread }

constructor TSeperateThread.Create(AOwner: TForm6; AThreadNo: Integer);
begin
  inherited Create(True);
  FOwner := AOwner;
  FThreadNo := AThreadNo;
  FMessageQueue.FCriticalSec := TCriticalSection.Create;
end;

destructor TSeperateThread.Destroy;
begin
  // release critical section
  FMessageQueue.FCriticalSec.Free;
  inherited;
end;

procedure TSeperateThread.Execute;
Var
  I : Integer;
  ACounter : Integer;
  NextReceiver : Integer;
  Receiver : TSeperateThread;
begin

  while (not Terminated) do Begin

    FMessageQueue.FCriticalSec.Enter();

    if (Random(10) = 1) then Begin
      SetLength(FMessageQueue.FMessages, Length(FMessageQueue.FMessages) + 1);
      while True do begin
        if NextReceiver <> FThreadNo then begin
          NextReceiver := Random(THREAD_COUNT);
          FMessageQueue.FMessages[Length( FMessageQueue.FMessages ) - 1].FChannelNo := NextReceiver;
          break;
        end; end;
    End;

    Sleep(2);

    for I := 0 to (THREAD_COUNT - 1) do Begin
      // Get the current thread as receiver
      Receiver := FOwner.TMyThread[FMessageQueue.FMessages[I].FChannelNo];
      // put receiver thread into critical section
      Receiver.FMessageQueue.FCriticalSec.Enter();
      // Set message Queue length
      SetLength(Receiver.FMessageQueue.FMessages, Length(Receiver.FMessageQueue.FMessages) + 1 );
      // set Message buffer length
      SetLength(Receiver.FMessageQueue.FMessages[Length(Receiver.FMessageQueue.FMessages) - 1].FMessageBuffer, Length(FMessageQueue.FMessages[I].FMessageBuffer));
      // copy one memory portion to another
           // source                                     // destination                                                                  // size
      Move(FMessageQueue.FMessages[I].FMessageBuffer[0], Receiver.FMessageQueue.FMessages[Length(Receiver.FMessageQueue.FMessages) - 1], Length(FMessageQueue.FMessages[I].FMessageBuffer));


      while True do begin
      if (NextReceiver <> FThreadNo) then begin
        NextReceiver := Random(THREAD_COUNT);
        Receiver.FMessageQueue.FMessages[Length( Receiver.FMessageQueue.FMessages ) - 1].FChannelNo := NextReceiver;
        break;
        end;
      end;

      Receiver.FMessageQueue.FCriticalSec.Leave();
    End;

    SetLength(FMessageQueue.FMessages, 0);
    FMessageQueue.FCriticalSec.Leave();

    // sync with main thread
    Synchronize(
       procedure() begin
         FOwner.ListBx.Items[FThreadNo] := IntToStr(ACounter);
       end
    );

    Inc( ACounter );
    Sleep( Random( 30 ) );

  End;


end;

procedure TForm6.FormCreate(Sender: TObject);
var I: Integer;
begin

  // populate listbox & creates multiple threads
  for I := 0 to THREAD_COUNT- 1 do Begin
    ListBx.Items.Add('0');
    TMyThread[I] := TSeperateThread.Create(Self, I);
  End;

  // execute each thread
  for I := 0 to THREAD_COUNT - 1 do
    TMyThread[I].Start();

end;

procedure TForm6.FormDestroy(Sender: TObject);
var I,J : Integer;
begin
  // terminate all threads
  for I := 0 to THREAD_COUNT -1  do Begin
    TMyThread[I].Terminate();
                 // wait for the thread to terminate
    TMyThread[I].WaitFor();
  End;

  // release threads
  for I := 0 to THREAD_COUNT - 1 do
    TMyThread[I].Free;

end;

end.


