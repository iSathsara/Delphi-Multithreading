unit uArchitectedForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,System.SyncObjs, System.Math;

const
  COUNT_READERS = 10;
  READER_DATA_SIZE = 100;

type
  TForm5 = class;
  TSharedData = class;
  TReaderData = class;

  {____________________________________________________________________________}
  ISharedDataAccess = interface
    function  GetElement( AIndex : Integer ) : Real;
    function  GetCount() : Integer;
  end;

  ISharedReadDataAccess = interface(ISharedDataAccess)
    property Count: Integer read GetCount;
    property Items[AIndex: integer]: real read GetElement; default;
  end;

  ISharedWriteDataAccess = interface(ISharedDataAccess)
    procedure SetElement(AIndex: Integer; AValue: Real);
    property Count: Integer read GetCount;
    property Items[AIndex: integer]: real read GetElement write SetElement;
  end;
  {____________________________________________________________________________}

  TSharedDataAccess = class(TInterfacedObject, ISharedDataAccess)
  private
    FOwner: TSharedData;
  protected
    function  GetElement( AIndex : Integer ) : Real;
    function  GetCount() : Integer;

  protected
    constructor Create(AOwner: TSharedData);
  end;

  TSharedReadDataAccess = class(TSharedDataAccess, ISharedReadDataAccess)
  protected
    constructor Create(AOwner: TSharedData);
  public
    destructor Destroy(); override;
  end;

  TSharedWriteDataAccess = class(TSharedDataAccess, ISharedWriteDataAccess)
  protected
    constructor Create(AOwner: TSharedData);
    procedure SetElement(AIndex: Integer; AValue: Real);
  public
    destructor Destroy(); override;
  end;

  TSharedData = class
  protected
    FGlobalLock: TMultiReadExclusiveWriteSynchronizer;
    FData      : array [0..9999] of real;

  public
    function GetRead(): ISharedReadDataAccess;
    function GetWrite(): ISharedWriteDataAccess;

  public
    constructor Create();
    destructor Destroy(); override;
  end;
  {____________________________________________________________________________}
  {____________________________________________________________________________}

  IReaderDataAccess = interface
    function  GetElement( AIndex : Integer ) : Real;
    procedure SetElement( AIndex : Integer; AValue : Real );
    function  GetCount() : Integer;

    property Count : Integer read GetCount;
    property Items[ AIndex : Integer ] : Real read GetElement write SetElement; default;
  end;

  TReaderDataAccess = class(TInterfacedObject, IReaderDataAccess)
  private
    FOwner: TReaderData;

  protected
    function  GetElement( AIndex : Integer ) : Real;
    procedure SetElement( AIndex : Integer; AValue : Real );
    function  GetCount() : Integer;

    constructor Create(AOwner: TReaderData);
    destructor Destroy(); override;
  end;

  TReaderData = class
  protected
    FCriticalSection: TCriticalSection;
    FData : array[ 0..READER_DATA_SIZE - 1 ] of Real;

  public
    function GetLock(): IReaderDataAccess;

    constructor Create();
    destructor Destroy(); override;
  end;
  {____________________________________________________________________________}
  {____________________________________________________________________________}

  { THREADS }

  TReaderThread = class(TThread)
  protected
    FOwner: TForm5;
    FIndex: Integer;
    FReaderData: TReaderData;

  protected
    procedure Execute(); override;
    procedure ProcessData();

  public
    constructor Create(AOwner: TForm5; AIndex: Integer);
    destructor Destroy(); override;
  end;

  TWriterThread = class(TThread)
  protected
    FOwner: TForm5;
    FEvent: TEvent;

  protected
    procedure Execute(); override;
    procedure ProcessData();

  public
    procedure Terminate();
    procedure WakeUp();

    constructor Create(AOwner: TForm5);
    destructor Destroy(); override;
  end;



  TForm5 = class(TForm)
    lblThreadInfo: TLabel;
    btnRandomize: TButton;
    shpWriteThreadStatus: TShape;
    Label2: TLabel;
    shpReadThreadStatus: TShape;
    Label1: TLabel;
    ListBox1: TListBox;
    Timer: TTimer;
    btnStart: TButton;
    btnStop: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

{$R *.dfm}

{______________________________________________________________________________}
{______________________________________________________________________________}
{______________________________________________________________________________}

{ TSharedDataAccess }

constructor TSharedDataAccess.Create(AOwner: TSharedData);
begin
  inherited Create;
  FOwner:= AOwner;
end;

function TSharedDataAccess.GetCount: Integer;
begin
  Result:= Length(FOwner.FData);
end;

function TSharedDataAccess.GetElement(AIndex: Integer): Real;
begin
  Result:= FOwner.FData[AIndex];
end;
{______________________________________________________________________________}
{______________________________________________________________________________}

{ TSharedReadDataAccess }

constructor TSharedReadDataAccess.Create(AOwner: TSharedData);
begin
  inherited;
  FOwner.FGlobalLock.BeginRead();
end;

destructor TSharedReadDataAccess.Destroy;
begin
  FOwner.FGlobalLock.EndRead();
  inherited;
end;
{______________________________________________________________________________}
{______________________________________________________________________________}

{ TSharedWriteDataAccess }

constructor TSharedWriteDataAccess.Create(AOwner: TSharedData);
begin
  inherited;
  FOwner.FGlobalLock.BeginWrite();
end;

destructor TSharedWriteDataAccess.Destroy;
begin
  FOwner.FGlobalLock.EndWrite();
  inherited;
end;

procedure TSharedWriteDataAccess.SetElement(AIndex: Integer; AValue: Real);
begin
  FOwner.FData[AIndex]:= AValue;
end;
{______________________________________________________________________________}
{______________________________________________________________________________}

{ TSharedData }

constructor TSharedData.Create;
begin
  inherited;
  FGlobalLock:= TMultiReadExclusiveWriteSynchronizer.Create();
end;

destructor TSharedData.Destroy;
begin
  FGlobalLock.Free();
  inherited;
end;

function TSharedData.GetRead: ISharedReadDataAccess;
begin

end;

function TSharedData.GetWrite: ISharedWriteDataAccess;
begin

end;

end.
