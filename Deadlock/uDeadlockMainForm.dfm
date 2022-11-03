object Form6: TForm6
  Left = 0
  Top = 0
  Caption = 'DeadLock '
  ClientHeight = 321
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 15
  object lblDescription: TLabel
    Left = 24
    Top = 24
    Width = 196
    Height = 15
    Caption = 'Seperate Thread  / Deadlock situation'
  end
  object ShpStatus: TShape
    Left = 280
    Top = 8
    Width = 33
    Height = 49
    Shape = stCircle
    Visible = False
  end
  object ShpAllThreadsStarted: TShape
    Left = 240
    Top = 82
    Width = 33
    Height = 14
    Brush.Color = clSilver
    Shape = stRoundRect
  end
  object lblThreadRunning: TLabel
    Left = 240
    Top = 102
    Width = 41
    Height = 14
    Caption = 'Threads'
  end
  object lblCriticalSec: TLabel
    Left = 240
    Top = 178
    Width = 30
    Height = 15
    Caption = 'Locks'
  end
  object ShpCriticalSec: TShape
    Left = 240
    Top = 162
    Width = 33
    Height = 15
    Brush.Color = clSilver
    Shape = stRoundRect
  end
  object ListBx: TListBox
    Left = 24
    Top = 56
    Width = 196
    Height = 201
    ItemHeight = 15
    TabOrder = 0
  end
  object btnExecute: TButton
    Left = 24
    Top = 280
    Width = 97
    Height = 25
    Caption = 'Run'
    TabOrder = 1
    OnClick = btnExecuteClick
  end
  object btnStop: TButton
    Left = 136
    Top = 280
    Width = 84
    Height = 25
    Caption = 'Stop'
    Enabled = False
    TabOrder = 2
    OnClick = btnStopClick
  end
end
