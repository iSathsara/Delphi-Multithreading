object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Multi Read Exclusive Write'
  ClientHeight = 433
  ClientWidth = 345
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 15
  object lblThreadInfo: TLabel
    Left = 16
    Top = 16
    Width = 60
    Height = 15
    Caption = 'Thread Info'
  end
  object shpReadThreadStatus: TShape
    Left = 103
    Top = 39
    Width = 33
    Height = 11
    Brush.Color = clSilver
    Shape = stRoundRect
  end
  object shpWriteThreadStatus: TShape
    Left = 290
    Top = 39
    Width = 33
    Height = 11
    Brush.Color = clSilver
    Shape = stRoundRect
  end
  object Label1: TLabel
    Left = 16
    Top = 35
    Width = 81
    Height = 15
    Caption = 'ReaderThread : '
  end
  object Label2: TLabel
    Left = 207
    Top = 35
    Width = 77
    Height = 15
    Caption = 'WriterThread : '
  end
  object btnRandomize: TButton
    Left = 208
    Top = 8
    Width = 115
    Height = 25
    Caption = 'Randomize'
    Enabled = False
    TabOrder = 0
    OnClick = btnRandomizeClick
  end
  object ListBox1: TListBox
    Left = 16
    Top = 56
    Width = 307
    Height = 329
    Columns = 3
    ItemHeight = 15
    TabOrder = 1
  end
  object btnStart: TButton
    Left = 32
    Top = 400
    Width = 129
    Height = 25
    Caption = 'S T A R T'
    TabOrder = 2
    OnClick = btnStartClick
  end
  object btnStop: TButton
    Left = 184
    Top = 400
    Width = 121
    Height = 25
    Caption = 'S T O P'
    Enabled = False
    TabOrder = 3
    OnClick = btnStopClick
  end
  object Timer: TTimer
    Enabled = False
    OnTimer = TimerTimer
    Left = 56
    Top = 112
  end
end
