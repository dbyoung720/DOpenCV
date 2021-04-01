unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, db.OpenCV;

type
  TForm1 = class(TForm)
    procedure FormShow(Sender: TObject);
  private
    // FMatClassObj: Pointer;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormShow(Sender: TObject);
var
  TTT: PVCString;
  PPP: Pointer;
begin
  TTT := VCString('C:\Windows\Web\Wallpaper\Windows\img0.jpg');
  try
    PPP := imread(TTT, -1);
    if PPP <> nil then
    begin

    end;
  finally
    FreeMem(TTT^.strMem);
    FreeMem(TTT);
  end;
end;

end.
