object mainForm: TmainForm
  Left = 438
  Top = 327
  Width = 500
  Height = 331
  Caption = #23433#35013
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 473
    Height = 41
    AutoSize = False
    Caption = #35831#36873#25321#23433#35013#36335#24452#65306
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object SpeedButton1: TSpeedButton
    Left = 96
    Top = 264
    Width = 73
    Height = 25
    Caption = #21516#24847
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    OnClick = SpeedButton1Click
  end
  object SpeedButton2: TSpeedButton
    Left = 200
    Top = 264
    Width = 73
    Height = 25
    Caption = #36864#20986
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    OnClick = SpeedButton2Click
  end
  object Label2: TLabel
    Left = 16
    Top = 224
    Width = 240
    Height = 13
    Caption = #35831#21247#23558#26412#36719#20214#29992#20110#38750#27861#29992#36884#65292#21542#21017#21518#26524#33258#36127#65281
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object SpeedButton3: TSpeedButton
    Left = 304
    Top = 264
    Width = 73
    Height = 25
    Caption = #21368#36733
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    OnClick = SpeedButton3Click
  end
  object DirectoryListBox1: TDirectoryListBox
    Left = 16
    Top = 80
    Width = 465
    Height = 137
    ItemHeight = 16
    TabOrder = 0
    OnChange = DirectoryListBox1Change
  end
  object DriveComboBox1: TDriveComboBox
    Left = 16
    Top = 56
    Width = 465
    Height = 19
    DirList = DirectoryListBox1
    TabOrder = 1
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 400
    Top = 240
  end
end
