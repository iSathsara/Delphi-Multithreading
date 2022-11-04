unit uDeadlockFiexedMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, SyncObjs;

const
  THREAD_COUNT = 8;

type
  TForm7 = class;


  TThreadMessage = record
  private
    FChannelNo : Integer;
    FMessageBuffer : array of Byte;
  end;


  TMessageQueue = record
  private
    FCriticalSec : TCriticalSection;
    FMessages : array of TThreadMessage;
  end;


  TSeperateThread = class(TThread)
  private
    FOwner : TForm7;
    FThreadNo : Integer;
    FMessageQueue : TMessageQueue;
  protected
    procedure Execute(); override;
  public
    constructor Create(AOwner : TForm7; AThreadNo : Integer);
    destructor Destroy();
  end;


  TForm7 = class(TForm)
    lblDescription: TLabel;
    ListBx: TListBox;
    ShpAllThreadsStarted: TShape;
    lblThreadRunning: TLabel;
    btnStop: TButton;
    btnExecute: TButton;
    procedure btnExecuteClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
  private
    { Private declarations }
    FThreadCount : Integer;
    FMyThread : array [0..THREAD_COUNT -1] of TSeperateThread;
  public
    { Public declarations }
    procedure StatusUpdate;
  end;

var
  Form7: TForm7;

implementation

{$R *.dfm}

{ TSeperateThread }

{______________________________________________________________________________}
constructor TSeperateThread.Create(AOwner: TForm7; AThreadNo: Integer);
begin
  inherited Create(true);
  FOwner := AOwner;
  FThreadNo := AThreadNo;
  // one critical section for one thread
  FMessageQueue.FCriticalSec := TCriticalSection.Create;
end;

destructor TSeperateThread.Destroy;
begin
  FMessageQueue.FCriticalSec.Free;
  inherited;
end;

procedure TSeperateThread.Execute;
var
  I : Integer;
  ACounter : Integer;
  NextReceiverNo : Integer;
  ReceiverThread : TSeperateThread;
  MessageList : array of TThreadMessage;
begin
  while not Terminated do Begin

    {__________________________________________________________________________}
    FMessageQueue.FCriticalSec.Enter();

        if (Random(10) = 1) then begin
          SetLength(FMessageQueue.FMessages, Length(FMessageQueue.FMessages) + 1);
          while True do begin
            // randomly assing no among thread no
            NextReceiverNo := Random(THREAD_COUNT);
            if (NextReceiverNo <> FThreadNo) then begin
              // set queue's -> message list item's -> message nnumber
              FMessageQueue.FMessages[Length(FMessageQueue.FMessages)-1].FChannelNo := NextReceiverNo;
              break;
            end;
          end;
        end;

        SetLength(MessageList, Length(FMessageQueue.FMessages));
        Move(FMessageQueue.FMessages[0], MessageList[0], Length(FMessageQueue.FMessages));
        SetLength(FMessageQueue.FMessages, 0);

    FMessageQueue.FCriticalSec.Leave();
    {__________________________________________________________________________}

    Sleep(1);

    {__________________________________________________________________________}
    for I := 0 to Length(MessageList) - 1 do Begin

      ReceiverThread := FOwner.FMyThread[ MessageList[I].FChannelNo ];

      // receiver thread's --> queue --> critical section
      ReceiverThread.FMessageQueue.FCriticalSec.Enter();

        SetLength(ReceiverThread.FMessageQueue.FMessages, Length(ReceiverThread.FMessageQueue.FMessages) + 1);
        SetLength(ReceiverThread.FMessageQueue.FMessages[Length(ReceiverThread.FMessageQueue.FMessages) - 1].FMessageBuffer, Length( MessageList[I].FMessageBuffer ));
        // move from temporary list to receiver.
        Move( MessageList[ I ].FMessageBuffer[ 0 ], ReceiverThread.FMessageQueue.FMessages[ Length( ReceiverThread.FMessageQueue.FMessages ) - 1 ].FMessageBuffer[ 0 ], Length( MessageList[I].FMessageBuffer ));

        While True do begin
          NextReceiverNo := Random(THREAD_COUNT);
          if NextReceiverNo <> FThreadNo then begin
            ReceiverThread.FMessageQueue.FMessages[ Length(ReceiverThread.FMessageQueue.FMessages)-1 ].FChannelNo := NextReceiverNo;
            break;
          end;
        end;

      // release receiver thread's queue's critical section
      ReceiverThread.FMessageQueue.FCriticalSec.Leave();
    End;

   // update form's listbox via sync method
   Synchronize(
     procedure() Begin
       Form7.ListBx.Items[ FThreadNo ] := IntToStr(ACounter);
     End
   );

   Inc(ACounter);
   Sleep(Random(30));
  End;
end;

{______________________________________________________________________________}
procedure TForm7.btnExecuteClick(Sender: TObject);
var I : Integer;
begin
  btnExecute.Enabled := False;
  btnStop.Enabled := True;

  // populate list box & create multiple threads for the form
  for I := 0 to THREAD_COUNT - 1 do Begin
    ListBx.Items.Add( '0' );
    FMyThread[I] := TSeperateThread.Create( Self,I );
  End;

  for I := 0 to THREAD_COUNT-1 do Begin
    FMyThread[I].Start;
  End;

  Self.StatusUpdate;
end;

procedure TForm7.btnStopClick(Sender: TObject);
var I : Integer;
begin
  btnStop.Enabled := False;
  btnExecute.Enabled := True;

  // terminate all the threads in the form
  for I := 0 to THREAD_COUNT - 1 do begin
    FMyThread[I].Terminate;
    FMyThread[I].WaitFor;
  end;

  for I := 0 to THREAD_COUNT - 1 do begin
    FMyThread[I].Free;
  end;

  ListBx.Items.Clear;

  Self.StatusUpdate;
end;

procedure TForm7.StatusUpdate;
Var I : Integer;
   Msg: String;
begin
  // thread count & lock count in the form
  for I := 0 to THREAD_COUNT - 1 do Begin

    if FMyThread[I] <> NIL then Begin
      if not FMyThread[I].Terminated then
        Inc(FThreadCount)
      else
        Dec(FThreadCount);

//      if (FMyThread[I].FMessageQueue.FCriticalSec) <> NIL then
//        Inc(FLocksCount)
//      else
//        Dec(FLocksCount);
    End;

  End;

  // thread status
  if FThreadCount = THREAD_COUNT then Begin
    lblThreadRunning.Caption := 'Threads: All Running';
    ShpAllThreadsStarted.Brush.Color := clLime;
  End else Begin
    lblThreadRunning.Caption := 'Threads: ** Error';
    ShpAllThreadsStarted.Brush.Color := clRed;
  End;
end;

end.
