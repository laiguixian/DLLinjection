object Adsafe: TAdsafe
  OldCreateOrder = False
  OnCreate = ServiceCreate
  DisplayName = 'Adsafe'
  Interactive = True
  Left = 192
  Top = 114
  Height = 150
  Width = 215
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 136
    Top = 32
  end
end
