unit uMultiReadExclusiveWriteForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, System.SyncObjs, System.Math;

const
  COUNT_READERS = 10;
  READER_DATA_SIZE = 100;

type
  TfrmMain = class;

  // Shared data record
  TSharedData = record
    FGlobalLock: TMultiReadExclusiveWriteSynchronizer;
    FData      : array[ 0..9999 ] of Real;
  end;

  // Reader data record
  TReaderData = record
    FCriticalSection : TCriticalSection;
    FReaderData      : array[ 0..READER_DATA_SIZE - 1 ] of Real;
  end;

  // Reader Thread
  TReaderThread = class(TThread)
  protected
    FOwner : TFrmMain;
    FData  : TReaderData;

    procedure Execute(); override;

  public
    constructor Create(aOwner: TfrmMain);
    destructor Destroy(); override;
  end;

  // Writer Thread
  TWriterThread = class(TThread)
  protected
    FOwner      : TfrmMain;
    FStartEvent : TEvent;

    procedure Execute(); override;

  public
    procedure Terminate();
    procedure WakeUp();

    constructor Create(aOwner: TfrmMain);
    destructor Destroy(); override;
  end;

  TfrmMain = class(TForm)
    lblThreadInfo: TLabel;
    btnRandomize: TButton;
    ListBox1: TListBox;
    btnStart: TButton;
    btnStop: TButton;
    Timer: TTimer;
    shpReadThreadStatus: TShape;
    shpWriteThreadStatus: TShape;
    Label1: TLabel;
    Label2: TLabel;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure btnRandomizeClick(Sender: TObject);
  private
    { Private declarations }
    FSharedData   : TSharedData;
    FReaders      : array [0..COUNT_READERS - 1] of TReaderThread;
    FWriter       : TWriterThread;
    FDisplayIndex : Integer;
  public
    { Public declarations }
    procedure CheckStatus;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.btnRandomizeClick(Sender: TObject);
begin
  FWriter.WakeUp();
end;

procedure TfrmMain.btnStartClick(Sender: TObject);
Var
  I : Integer;
begin
  // Global sync lock
  FSharedData.FGlobalLock:= TMultiReadExclusiveWriteSynchronizer.Create;

  // create MULTIPLE reader threads
  for I := 0 to (COUNT_READERS - 1) do
    FReaders[I]:= TReaderThread.Create(Self);

  // create SINGLE writer thread
  FWriter:= TWriterThread.Create(Self);

  Timer.Enabled:= True;

  if Timer.Enabled then
    btnRandomize.Enabled:= True;

  CheckStatus;

  btnStart.Enabled:= False;
  btnStop.Enabled:= True;
end;

procedure TfrmMain.btnStopClick(Sender: TObject);
Var
  I : Integer;
begin
  // release writer
  FWriter.Terminate();
  FWriter.WaitFor();
  FWriter.Free();

  // release readers
  for I := 0 to COUNT_READERS - 1 do Begin
    FReaders[I].Terminate();
    FReaders[I].WaitFor();
    FReaders[I].Free();
  End;

  // release globle lock
  FSharedData.FGlobalLock.Free;
  Timer.Enabled:= False;
  ListBox1.Items.Clear;

  CheckStatus;

  btnStop.Enabled:= False;
  btnStart.Enabled:= True;
  btnRandomize.Enabled:= False;
end;


procedure TfrmMain.CheckStatus;
var
  Count: Integer;
  I: Integer;
begin
  Count:= 0;

  // check reader threads
  for I := 0 to COUNT_READERS - 1 do Begin
    if not FReaders[I].Terminated then
      Inc(Count);
  End;

  if Count = COUNT_READERS then
    shpReadThreadStatus.Brush.Color:= clLime
  else
    shpReadThreadStatus.Brush.Color:= clRed;

  if not FWriter.Terminated then
    shpWriteThreadStatus.Brush.Color:= clLime
  else
    shpWriteThreadStatus.Brush.Color:= clRed;

end;

procedure TfrmMain.TimerTimer(Sender: TObject);
Var
  AData : array[ 0..READER_DATA_SIZE - 1 ] of Real;
  I : Integer;
begin
  // Form's --> ReaderData's --> CriticalSection
  FReaders[FDisplayIndex].FData.FCriticalSection.Enter();

        // Form's ReaderThread List[] --> ReaderData's --> FData[0]
                                                          // move to temporary list
  Move( FReaders[ FDisplayIndex ].FData.FReaderData[ 0 ], AData[ 0 ], SizeOf( AData ));
  FReaders[FDisplayIndex].FData.FCriticalSection.Leave();

  // -----------------------------------------------------------------

  lblThreadInfo.Caption := 'Data on Thread #' + IntToStr(FDisplayIndex);

  ListBox1.Items.BeginUpdate();
  ListBox1.Items.Clear();
  for I := 0 to READER_DATA_SIZE - 1 do
    ListBox1.Items.Add( FloatToStr( AData[ I ] ));
  ListBox1.Items.EndUpdate();

  // -----------------------------------------------------------------

  Inc( FDisplayIndex );
  if( FDisplayIndex >= Length( FReaders ) ) then
    FDisplayIndex := 0;

end;

{______________________________________________________________________________}

{ TReaderThread }

constructor TReaderThread.Create(aOwner: TfrmMain);
begin
            // create NOT suspended thread (start immideately after create)
  inherited Create(False);
  FOwner:= aOwner;

  // create critical section
  FData.FCriticalSection:= TCriticalSection.Create;
end;

destructor TReaderThread.Destroy;
begin
  // free critical section
  FData.FCriticalSection.Free;
  inherited;
end;

procedure TReaderThread.Execute;
Var
  I : Integer;
begin

  while not Terminated do Begin
    Sleep(10);
                                   // Request permission to read data from Global lock
                                   // Ensure that no other threads are writing on this Global lock.
    FOwner.FSharedData.FGlobalLock.BeginRead();
    FData.FCriticalSection.Enter();

    for I := 0 to Length(FData.FReaderData) - 1 do
      FData.FReaderData[I]:= FOwner.FSharedData.FData[ RandomRange( 0, Length(FOwner.FSharedData.FData )) ];

    FData.FCriticalSection.Leave();
                                   // mark as Read complete
    FOwner.FSharedData.FGlobalLock.EndRead();
  End;

end;

{______________________________________________________________________________}

{ TWriterThread }

constructor TWriterThread.Create(aOwner: TfrmMain);
begin
  inherited Create(False);
  FOwner:= aOwner;
  // create start event
  FStartEvent:= TEvent.Create(NIL, False, False, '');
end;

destructor TWriterThread.Destroy;
begin
  FStartEvent.Free;
  inherited;
end;

procedure TWriterThread.Execute;
Var
  I : Integer;
begin

  while not Terminated do Begin
    FStartEvent.WaitFor(INFINITE);
                                   // Request permission to write in Globle lock
    FOwner.FSharedData.FGlobalLock.BeginWrite();
    FOwner.shpWriteThreadStatus.Brush.Color:= clYellow;

    for I := 0 to Length(FOwner.FSharedData.FData) - 1 do
      FOwner.FSharedData.FData[I]:= RandomRange(-1000, 1000);

                                   // mark as Write Complete
    FOwner.FSharedData.FGlobalLock.EndWrite();
  End;
  FOwner.shpWriteThreadStatus.Brush.Color:= clGreen;

end;

procedure TWriterThread.Terminate;
begin
  inherited Terminate();
  FStartEvent.SetEvent;
end;

procedure TWriterThread.WakeUp;
begin
  FStartEvent.SetEvent;
end;

end.
