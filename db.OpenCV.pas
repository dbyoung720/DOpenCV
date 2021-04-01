unit db.OpenCV;

interface

uses Winapi.Windows;

type
  PVCString = ^TVCString;

  TVCString = record
    strMem: PDWORD;    // �ַ���ָ��
    R1, R2, R3: DWORD; // δ֪
    len: DWORD;        // �ַ�������
    R4: DWORD;         // ��ֵ = $0000002F
  end;

  TMat = Pointer;

  ImreadModes = (                    //
    IMREAD_UNCHANGED = -1,           // !< If set, return the loaded image as is (with alpha channel, otherwise it gets cropped). Ignore EXIF orientation.
    IMREAD_GRAYSCALE = 0,            // !< If set, always convert image to the single channel grayscale image (codec internal conversion).
    IMREAD_COLOR = 1,                // !< If set, always convert image to the 3 channel BGR color image.
    IMREAD_ANYDEPTH = 2,             // !< If set, return 16-bit/32-bit image when the input has the corresponding depth, otherwise convert it to 8-bit.
    IMREAD_ANYCOLOR = 4,             // !< If set, the image is read in any possible color format.
    IMREAD_LOAD_GDAL = 8,            // !< If set, use the gdal driver for loading the image.
    IMREAD_REDUCED_GRAYSCALE_2 = 16, // !< If set, always convert image to the single channel grayscale image and the image size reduced 1/2.
    IMREAD_REDUCED_COLOR_2 = 17,     // !< If set, always convert image to the 3 channel BGR color image and the image size reduced 1/2.
    IMREAD_REDUCED_GRAYSCALE_4 = 32, // !< If set, always convert image to the single channel grayscale image and the image size reduced 1/4.
    IMREAD_REDUCED_COLOR_4 = 33,     // !< If set, always convert image to the 3 channel BGR color image and the image size reduced 1/4.
    IMREAD_REDUCED_GRAYSCALE_8 = 64, // !< If set, always convert image to the single channel grayscale image and the image size reduced 1/8.
    IMREAD_REDUCED_COLOR_8 = 65,     // !< If set, always convert image to the 3 channel BGR color image and the image size reduced 1/8.
    IMREAD_IGNORE_ORIENTATION = 128  // !< If set, do not rotate the image according to EXIF's orientation flag.
    );

//function CreateMat(): Pointer; stdcall; external 'opencv_core452.dll' name '??0Mat@cv@@QAE@XZ';
function imread(const FileName: PVCString; flags: Integer): TMat; pascal; external 'opencv_imgcodecs452.dll' name '?imread@cv@@YA?AVMat@1@ABV?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@H@Z';

{ Delphi String ת��Ϊ C++ String }
function VCString(const strFileName: string): PVCString;

implementation

{ Delphi String ת��Ϊ C++ String }
function VCString(const strFileName: string): PVCString;
var
  vcs: AnsiString;
begin
  vcs            := AnsiString(strFileName);        // ���ֽ�ת��Ϊ���ֽ�
  Result         := AllocMem(SizeOf(TVCString));    // �����ڴ�
  Result^.strMem := AllocMem(Length(vcs));          // �����ַ����ڴ�
  CopyMemory(Result^.strMem, @vcs[1], Length(vcs)); // �����ַ���
  Result^.len := Length(vcs);                       // �ַ�������
  Result^.R4  := $0000002F;                         // ��ֵ
end;

end.
