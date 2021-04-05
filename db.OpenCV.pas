unit db.OpenCV;
{
  功能：在 Delphi 中，以不封装的模式调用 OpenCV C++ Class Dll
  作者：dbyoung@sina.com
  时间：2021-04-01
}

interface

uses Winapi.Windows, System.SysUtils;

const
  c_BuildInfo: PChar   = '?getBuildInformation@cv@@YAABV?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@XZ';
  c_imread: PChar      = '?imread@cv@@YA?AVMat@1@ABV?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@H@Z';
  c_imshow: PChar      = '?imshow@cv@@YAXABV?$basic_string@DU?$char_traits@D@std@@V?$allocator@D@2@@std@@ABV_InputArray@1@@Z';
  c_InputArray: PChar  = '??0_InputArray@cv@@QAE@ABVMat@1@@Z';
  c_cvIplImage: PChar  = '?cvIplImage@@YA?AU_IplImage@@ABVMat@cv@@@Z';
  c_cvShowImage: PChar = 'cvShowImage';

type
  int = Integer;

  { C++ std::string 类 }
  PVCString = ^TVCString;

  TVCString = record
    strMem: PDWORD;    // 字符串指针
    R1, R2, R3: DWORD; // 未知
    len: DWORD;        // 字符串长度
    R4: DWORD;         // 定值 = $0000002F
  end;

  { opencv cvArr class 类 }
  PcvArr = ^cvArr;
  cvArr  = Pointer;

  { opencv mat class 类 }
  PMat = ^TMat;
  TMat = Pointer;

  { opencv InputArray class 类 }
  PInputArray = ^TInputArray;
  TInputArray = Pointer;

  { imread open type }
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

  P_IplROI      = ^_IplROI;
  P_IplTileInfo = ^_IplTileInfo;
  PIplImage     = ^IplImage;

  _IplROI = record
    coi: int;
    xOffset: int;
    yOffset: int;
    width: int;
    height: int;
  end;

  _IplTileInfo = record

  end;

  { CvArr -> CvMat -> IplImage }

  IplImage = record
    nSize: int;                             // sizeof(IplImage)
    ID: int;                                // version (=0)
    nChannels: int;                         // Most of OpenCV functions support 1,2,3 or 4 channels
    alphaChannel: int;                      // Ignored by OpenCV
    depth: int;                             // Pixel depth in bits: IPL_DEPTH_8U, IPL_DEPTH_8S, IPL_DEPTH_16S, IPL_DEPTH_32S, IPL_DEPTH_32F and IPL_DEPTH_64F are supported.
    colorModel: array [0 .. 3] of AnsiChar; // char [4];     // Ignored by OpenCV
    channelSeq: array [0 .. 3] of AnsiChar; // char [4];     // ditto
    dataOrder: int;                         // 0 - interleaved color channels, 1 - separate color channels.     // cvCreateImage can only create interleaved images
    origin: int;                            // 0 - top-left origin,     // 1 - bottom-left origin (Windows bitmaps style).
    align: int;                             // Alignment of image rows (4 or 8).     // OpenCV ignores it and uses widthStep instead.
    width: int;                             // Image width in pixels.
    height: int;                            // Image height in pixels.
    roi: P_IplROI;                          // Image ROI. If NULL, the whole image is selected.
    maskROI: PIplImage;                     // Must be NULL.
    imageId: Pointer;                       // "           "
    tileInfo: P_IplTileInfo;                // "           "
    imageSize: int;                         // Image data size in bytes   (==image->height*image->widthStep in case of interleaved data)
    imageData: Pointer;                     // Pointer to aligned image data.
    widthStep: int;                         // Size of aligned image row in bytes.
    BorderMode: array [0 .. 3] of int;      // int  [4];     // Ignored by OpenCV.
    BorderConst: array [0 .. 3] of int;     // int  [4];    // Ditto.
    imageDataOrigin: Pointer;               // Pointer to very origin of image data
  end;

type
  TOpenCV = class(TObject)
  private
    FhCoreDLL     : HMODULE;
    FhImgcodecsDLL: HMODULE;
    FhHighguiDLL  : HMODULE;
    FcvClassObj   : Pointer;
    FimgMat       : TMat;
    FbUseCppShow  : Boolean;
  public
    function BuildInfo: String;
    procedure imread(const FileName: string; const flags: Integer = -1);
    procedure imshow(const strTitle: string = 'Delphi OpenCV Image Show');
    procedure imshowC(const strTitle: string = 'Delphi OpenCV Image Show');
    procedure imshowCpp(const strTitle: string = 'Delphi OpenCV Image Show');
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ Delphi String 转换为 C++ std::string }
function VCString(const strFileName: string): PVCString;
var
  vcs: AnsiString;
begin
  vcs            := AnsiString(strFileName);        // 宽字节转换为短字节
  Result         := AllocMem(SizeOf(TVCString));    // 分配内存
  Result^.strMem := AllocMem(Length(vcs));          // 分配字符串内存
  CopyMemory(Result^.strMem, @vcs[1], Length(vcs)); // 复制字符串
  Result^.len := Length(vcs);                       // 字符串长度
  Result^.R4  := $0000002F;                         // 定值
end;

{ TOpenCV }
constructor TOpenCV.Create;
begin
  FbUseCppShow   := True;
  FhCoreDLL      := LoadLibrary('opencv_core452.dll');
  FhImgcodecsDLL := LoadLibrary('opencv_imgcodecs452.dll');
  FhHighguiDLL   := LoadLibrary('opencv_highgui452.dll');
  GetMem(FcvClassObj, 8);
end;

destructor TOpenCV.Destroy;
begin
  FreeLibrary(FhCoreDLL);
  FreeLibrary(FhImgcodecsDLL);
  FreeLibrary(FhHighguiDLL);
  FreeMem(FcvClassObj);
  inherited;
end;

function TOpenCV.BuildInfo: String;
var
  cvBuildInfo: function: PVCString;
  pVer       : PVCString;
  chrVer     : PAnsiChar;
begin
  cvBuildInfo := GetProcAddress(FhCoreDLL, c_BuildInfo);
  if not Assigned(cvBuildInfo) then
    Exit;

  pVer := cvBuildInfo;
  if pVer = nil then
    Exit;

  GetMem(chrVer, pVer^.len);
  try
    CopyMemory(@chrVer[0], pVer^.strMem, pVer^.len);
    Result := StringReplace(String(AnsiString(chrVer)), #$A, #$D#$A, [rfReplaceAll]);
  finally
    FreeMem(chrVer);
  end;
end;

procedure TOpenCV.imread(const FileName: string; const flags: Integer = -1);
var
  cvimread: function(p: Pointer; const FileName: PVCString; flag: Integer): TMat; stdcall;
  pvcs    : PVCString;
begin
  cvimread := GetProcAddress(FhImgcodecsDLL, c_imread);
  if not Assigned(cvimread) then
    Exit;

  pvcs := VCString(FileName);
  try
    FimgMat := cvimread(FcvClassObj, pvcs, flags);
  finally
    FreeMem(pvcs^.strMem);
    FreeMem(pvcs);
  end;
end;

{ 显示图像 }
procedure TOpenCV.imshow(const strTitle: string);
begin
  if not FbUseCppShow then
    imshowC(strTitle)
  else
    imshowCpp(strTitle);
end;

function cvIplImage(const mat: TMat): IplImage; stdcall; external 'opencv_core452.dll' name '?cvIplImage@@YA?AU_IplImage@@ABVMat@cv@@@Z';
procedure cvShowImage(const strTitile: PAnsiChar; const arr: PcvArr); stdcall; external 'opencv_highgui452.dll';

{ C 显示 }
procedure TOpenCV.imshowC(const strTitle: string);
var
  img: IplImage;
begin
  img := cvIplImage(FimgMat);
  cvShowImage(PAnsiChar(AnsiString(strTitle)), @img);
end;

{ C++ 显示 }
procedure TOpenCV.imshowCpp(const strTitle: string);
var
  cvimshow          : procedure(const TitleName: PVCString; mat: TInputArray); stdcall;
  cvInputArrayCreate: function(mat: TMat): TInputArray; stdcall;
  pvcs              : PVCString;
  pIA               : TInputArray;
begin
  cvimshow := GetProcAddress(FhHighguiDLL, c_imshow);
  if not Assigned(cvimshow) then
    Exit;

  cvInputArrayCreate := GetProcAddress(FhCoreDLL, c_InputArray);
  if not Assigned(cvInputArrayCreate) then
    Exit;

  pvcs := VCString(strTitle);
  try
    pIA := cvInputArrayCreate(FimgMat);
    cvimshow(pvcs, pIA);
  finally
    FreeMem(pvcs^.strMem);
    FreeMem(pvcs);
  end;
end;

end.
