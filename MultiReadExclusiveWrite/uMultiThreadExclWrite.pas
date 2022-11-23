unit uMultiThreadExclWrite;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,SyncObjs, System.Math;

const
  COUNT_READERS = 10;
  READER_DATA_SIZE = 100;

type
  TFrmMain = class;

  // record for shared data through APIs.
  TSharedData = record
    FSpecialLock: TMultiReadExclusiveWriteSynchronizer;
    FData : array [0..9999] of Real;
  end;

  // data which is going to Read.
  TReaderData  = record
    FCriticalSection : TCriticalSection;
    FReaderData : array [0..READER_DATA_SIZE - 1] of Real;
  end;

  // Reader Thread
  TReadingThread = class(TThread)
  protected
    FOwner : TFrmMain;
    FReadingData : TReaderData;

    procedure Execute(); override;

  public
    constructor Create(aForm: TFrmMain);
    destructor Destroy(); override;
  end;



  TFrmMain = class(TForm)
    lblDescription: TLabel;
    BtnRandomize: TButton;
    lbResults: TListBox;
    Timer: TTimer;
  private
    { Private declarations }
    FData: TSharedData;
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

{ TReadingThread }

constructor TReadingThread.Create(aForm: TFrmMain);
begin
  inherited Create;
  FOwner:= aForm;
  FReadingData.FCriticalSection:= TCriticalSection.Create;
end;

destructor TReadingThread.Destroy;
begin
  FReadingData.FCriticalSection.Free;
  inherited;
end;

procedure TReadingThread.Execute;
var
  I: Integer;
begin
  while not Terminated do Begin
    Sleep(10);

    FOwner.FData.FSpecialLock.BeginRead();
    FReadingData.FCriticalSection.Enter();

      for I := 0 to Length(FReadingData.FReaderData) - 1 do
        FReadingData.FReaderData[I]:= FOwner.FData.FData[RandomRange(0, Length(FOwner.FData.FData))];

    FReadingData.FCriticalSection.Leave();
    FOwner.FData.FSpecialLock.EndRead();
  End;
end;

end.
