object FrmSingleThread: TFrmSingleThread
  Left = 0
  Top = 0
  Caption = 'Single Thread'
  ClientHeight = 307
  ClientWidth = 583
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 15
  object lblPercentage: TLabel
    Left = 452
    Top = 104
    Width = 77
    Height = 15
    Alignment = taRightJustify
    Caption = 'lblPercentage'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblDescription: TLabel
    Left = 56
    Top = 43
    Width = 203
    Height = 15
    Caption = 'Read file in MainThread / SingleThread'
  end
  object ProgressBar: TProgressBar
    Left = 56
    Top = 64
    Width = 473
    Height = 25
    Smooth = True
    TabOrder = 0
    StyleName = 'Windows'
  end
  object btnStart: TButton
    Left = 96
    Top = 184
    Width = 145
    Height = 33
    Caption = 'S T A R T'
    TabOrder = 1
    OnClick = btnStartClick
  end
  object btnStop: TButton
    Left = 344
    Top = 184
    Width = 145
    Height = 33
    Caption = 'S T O P'
    TabOrder = 2
    OnClick = btnStopClick
  end
end
