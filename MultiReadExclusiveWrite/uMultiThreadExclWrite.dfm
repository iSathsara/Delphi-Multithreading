object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'Multi Read Exclusive Write'
  ClientHeight = 458
  ClientWidth = 382
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 15
  object lblDescription: TLabel
    Left = 16
    Top = 16
    Width = 73
    Height = 15
    Caption = 'lblDescription'
  end
  object BtnRandomize: TButton
    Left = 216
    Top = 12
    Width = 139
    Height = 25
    Caption = 'R A N D O M I Z E'
    TabOrder = 0
  end
  object lbResults: TListBox
    Left = 16
    Top = 56
    Width = 339
    Height = 345
    ItemHeight = 15
    TabOrder = 1
  end
  object Timer: TTimer
    Left = 88
    Top = 208
  end
end
