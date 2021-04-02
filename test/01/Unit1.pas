unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    mmo1: TMemo;
    procedure FormShow(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses db.OpenCV;

procedure TForm1.FormShow(Sender: TObject);
var
  ttt: TOpenCV;
begin
  ttt := TOpenCV.Create;
  try
    mmo1.Lines.Add(ttt.BuildInfo);                                                      // OpenCV ±‡“Î∞Ê±æ∫≈
    ttt.imread('C:\Windows\Web\Wallpaper\Windows\img0.jpg', Integer(IMREAD_GRAYSCALE)); // ∂¡»°Õº∆¨
    ttt.imshow;                                                                         // œ‘ æΩÁ√Ê
  finally
    ttt.free;
  end;
end;

end.
