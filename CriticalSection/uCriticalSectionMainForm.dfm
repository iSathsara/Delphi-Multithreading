object Form4: TForm4
  Left = 0
  Top = 0
  Caption = 'Critical Section'
  ClientHeight = 307
  ClientWidth = 583
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 15
  object lblDescription: TLabel
    Left = 56
    Top = 43
    Width = 174
    Height = 15
    Caption = 'Seperate Thread / Critical Section'
  end
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
    Enabled = False
    TabOrder = 2
    OnClick = btnStopClick
  end
end
