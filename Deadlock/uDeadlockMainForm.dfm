object Form6: TForm6
  Left = 0
  Top = 0
  Caption = 'DeadLock '
  ClientHeight = 321
  ClientWidth = 367
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
    Left = 24
    Top = 24
    Width = 196
    Height = 15
    Caption = 'Seperate Thread  / Deadlock situation'
  end
  object ShpStatus: TShape
    Left = 256
    Top = 104
    Width = 73
    Height = 81
    Shape = stCircle
    Visible = False
  end
  object ListBx: TListBox
    Left = 24
    Top = 56
    Width = 196
    Height = 201
    ItemHeight = 15
    TabOrder = 0
  end
end
