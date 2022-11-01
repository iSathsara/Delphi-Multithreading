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
  // create critical section
  FMessageQueue.FCriticalSec := TCriticalSection.Create;
end;

destructor TSeperateThread.Destroy;
begin
  // release critical section
  FMessageQueue.FCriticalSec.Free;
  inherited;
end;

procedure TSeperateThread.Execute;
begin

end;



procedure TForm6.FormCreate(Sender: TObject);
var I : Integer;
begin

  for I := 0 to THREAD_COUNT - 1 do Begin
    ListBx.Items.Add('0');
    // populate listbox with thread
    TMyThread[I] := TSeperateThread.Create(Self, I);
  End;

  // execute each thread
  for I := 0 to THREAD_COUNT - 1 do
    TMyThread[I].Start;

end;

procedure TForm6.FormDestroy(Sender: TObject);
var I : Integer;
begin
  // terminate all threads
  for I := 0 to THREAD_COUNT -1  do Begin
    TMyThread[I].Terminate;
    TMyThread[I].WaitFor;
  End;

  // release threads
  for I := 0 to THREAD_COUNT - 1 do
    TMyThread[I].Free;

end;

end.


