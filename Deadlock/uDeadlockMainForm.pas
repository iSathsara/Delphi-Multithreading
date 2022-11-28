unit uDeadlockMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, SyncObjs;

const
  THREAD_COUNT = 8;

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
    FOwner      : TForm6;
    FThreadNo   : Integer;
    FMessageQueue : TMessageQueue;
  protected
    procedure Execute(); override;
  public
    constructor Create(AOwner: TForm6; AThreadNo : Integer);
    destructor  Destroy(); override;
  end;

  TForm6 = class(TForm)
    lblDescription: TLabel;
    ShpStatus: TShape;
    ListBx: TListBox;
    ShpAllThreadsStarted: TShape;
    lblThreadRunning: TLabel;
    btnExecute: TButton;
    btnStop: TButton;
    lblCriticalSec: TLabel;
    ShpCriticalSec: TShape;
    procedure btnExecuteClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
  private
    { Private declarations }
    FLocksCount : Integer;
    FThreadCount : Integer;
    FMyThread : array [0..THREAD_COUNT-1] of TSeperateThread;

    procedure StatusUpdate;
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

// Execute procedure describes what should happen when Thread is running...
procedure TSeperateThread.Execute;
var
  I : Integer;
  ACounter : Integer;
  NextReceiverNo : Integer;
  ReceiverThread : TSeperateThread;
begin
            // Execute() responsible for periodically check Terminated value to determine
            // the status of thread..
  while not Terminated do Begin
    // put message queue in critical section
    FMessageQueue.FCriticalSec.Enter();

    {__________________________________________________________________________}
    if Random(10) = 1 then begin
      SetLength(FMessageQueue.FMessages, Length(FMessageQueue.FMessages) + 1);
      while True do begin
        // randomly assing no among thread no
        NextReceiverNo := Random(THREAD_COUNT);
        if NextReceiverNo <> FThreadNo then begin
          // set queue's -> message list item's -> message nnumber
          FMessageQueue.FMessages[Length(FMessageQueue.FMessages)-1].FChannelNo := NextReceiverNo;
          break;
        end;
      end;
    end;

    Sleep(1);
    
    {__________________________________________________________________________}
    for I := 0 to Length(FMessageQueue.FMessages) - 1 do Begin
      // get one by one thread
      ReceiverThread := Form6.FMyThread[FMessageQueue.FMessages[I].FChannelNo]; 

      // put receiver's message queue into critical section
      ReceiverThread.FMessageQueue.FCriticalSec.Enter(); 
      // receiver thread's message queue's length
      SetLength(ReceiverThread.FMessageQueue.FMessages, Length(ReceiverThread.FMessageQueue.FMessages) + 1);
      // set receiver's message beffer's length
      SetLength(ReceiverThread.FMessageQueue.FMessages[Length(ReceiverThread.FMessageQueue.FMessages) - 1].FMessageBuffer, Length( FMessageQueue.FMessages[I].FMessageBuffer ));
      // Copy a section of memory from one place to another
      Move( FMessageQueue.FMessages[ I ].FMessageBuffer[ 0 ], ReceiverThread.FMessageQueue.FMessages[ Length( ReceiverThread.FMessageQueue.FMessages ) - 1 ].FMessageBuffer[ 0 ], Length( FMessageQueue.FMessages[ I ].FMessageBuffer ));  

      While True do begin
        NextReceiverNo := Random(THREAD_COUNT);
        if NextReceiverNo <> FThreadNo then begin
          // set receiver's -> queue's -> message list item's -> message nnumber
          ReceiverThread.FMessageQueue.FMessages[Length(ReceiverThread.FMessageQueue.FMessages)-1].FChannelNo := NextReceiverNo;
          break;
        end;
      end;

      // release receiver's message thread's lock
      ReceiverThread.FMessageQueue.FCriticalSec.Leave();
    End;
    
   {___________________________________________________________________________}
   SetLength(FMessageQueue.FMessages, 0);

   // update form's listbox via sync method
   // communicate between main thread & sub threads
   Synchronize(
     procedure() Begin
       Form6.ListBx.Items[ FThreadNo ] := IntToStr(ACounter);
     End
   ); 
    
   Inc(ACounter);
   Sleep(Random(30));
  End;
end;

procedure TForm6.btnExecuteClick(Sender: TObject);
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

procedure TForm6.btnStopClick(Sender: TObject);
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

  // bugs in locks!
  Self.StatusUpdate;
end;

procedure TForm6.StatusUpdate;
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

      if (FMyThread[I].FMessageQueue.FCriticalSec) <> NIL then
        Inc(FLocksCount)
      else
        Dec(FLocksCount);
    End;

  End;

  // thread status
  if FThreadCount = THREAD_COUNT then Begin
    lblThreadRunning.Caption := 'Threads: All Running';
    ShpAllThreadsStarted.Brush.Color := clLime;
  End else Begin
    lblThreadRunning.Caption := 'Threads: Running error!';
    ShpAllThreadsStarted.Brush.Color := clRed;
  End;

  // locks status
  if FLocksCount = THREAD_COUNT then Begin
//    lblCriticalSec.Caption := 'Locks: All Applied';
//    ShpCriticalSec.Brush.Color := clLime;
  End else Begin
//    lblCriticalSec.Caption := 'Locks: Locks Error!';
//    ShpCriticalSec.Brush.Color := clRed;
  End;


end;

end.


