unit CoreUtility;

{----------------}
interface

uses
  ActiveX,
  Classes,
  Controls,          { TWinControl }
  Graphics,          { TBitmap,TColor,TIcon }
  MMsystem,          { timeGetTime }
  Windows;           { DWORD,MessageBeep,TPoint,TRect }


type
  TAxisExtents = record
    OriginValue, EndValue: double;
  end ;

type TTopSpeedTime = record                                { from UTILITY }
                       day: Word;
                       minute: Word;
                       millisec: Word;
                     end;   { TTopSpeedTime }

const DaysInCentury: Cardinal = (366 * 4) + (365 * 96); { 4 leap years, and 96 regular years }
      SecondsPerDay: Double = 86400.0;
      SecondsPerHour: Cardinal = 3600;
      MinutesPerHour: Cardinal = 60;
      MinutesPerDay: Cardinal = 1440;

      CR = #13;
      LF = #10;

      SAssignError = 'Cannot assign a %s to a %s';
      SListIndexError = 'List index out of bounds (%d)';
      SListCountError = 'List count out of bounds (%d)';

function ColorToString (Color: TColor): String;
function StringToColor (Color: String): TColor;

procedure WaitXmillisecs(MillisecsToWait: DWORD);
procedure SetWaitActive(State: BOOLEAN);
procedure WaitWithMessagePump(hWnd:HWND;MillisecsToWait:DWORD);

  { Sleeps the calling thread until at least MillisecsToWait milliseconds have elapsed }
function HourMinSecsStr (MilliSecs: DWORD): String;
function ElapsedTimeInMillisecs (const FirstReading,SecondReading: DWORD): DWORD;
  { figures the difference between the two readings (from timeGetTime), }
  { taking into account the wraparound that occurs every 50 days }

function RdStr (FromFile: Integer; MaxChars: Word): String;

function MinOfInt(Int1, Int2: LongInt): LongInt;
function MaxOfInt(Int1, Int2: LongInt): LongInt;

function MinOfDouble(Double1, Double2: Double): Double;
function MaxOfDouble(Double1, Double2: Double): Double;

function Distance(Pt1, Pt2: TPoint): Double;

procedure GetWinPlacement(hWnd: HWND; var Placement: TWindowPlacement);
  { calls Windows GetWindowPlacement after setting TWindowPlacement.length properly }

procedure SetNormalWindowPosition(hWnd: HWND; Placement: TWindowPlacement);
  { Sets the NormalPosition record for window hWnd, leaving everything else the same }

function DiskFreeSpaceInMB(Disk: string): Integer;
function DriveSpecified (Path: String): Boolean;
  { returns TRUE if a drive location has been specified in the path }
function IsRelativePath (Path: String): Boolean;
  { returns TRUE if a directory has been specified, but no drive }
procedure ForceFileExtension (const Ext: String;
                              var FileName: String);
  { if FileName does not contain an extension, appends Ext to FileName }
  { if FileName _does_ contain an extension, and it is not the desired one, }
  {                        strips the incorrect extension, then appends Ext }
function StripExtension (const FileName: String): String;
function ForceBackslash (const Path: String): String;

function IsAlpha (const Ch: Char): Boolean;
function IsLowerCase (const Ch: Char): Boolean;
function IsUpperCase (const Ch: Char): Boolean;
function IsDigit (const Ch: Char): Boolean;
function LowCase (const Ch: Char): Char;

function HexCharOf(Num: Byte): Char;
function ValueOfHexDigit (Ch: Char): Byte;
  { raises EConvertError is invalid hex char entered }
  { does not consider the minus sign valid }
function HexStrToCard(Str: String): Cardinal;

procedure DeleteSpaces (var Src: String);
  {  Deletes _all_ spaces from Src (a Pascal string). }
  { Superseded by TrimTrailing(). Will fail if string longer than 255 characters }

procedure DeleteSpaceChars (var Src: array OF Char);
  {  Deletes _all_ spaces from Src (a null-terminated string). }
  { Will fail if string longer than 255 characters }

function FormatNoSpaces (const FormatStr: String;
                         const Args: array OF const): String;
  { Same as SYSUTIL.Format, except leading and trailing spaces are removed. }

procedure GetHeadAndTail (StringToSplit,Separator: String; var Head,Tail: String);
  {  Splits a string into Head and Tail components split by a Separator string }
  { (which may be a single character). }

function TrimTrailingChars (const S: String; const Ch: Char): String;
  {  Removes trailing characters of any variety from a string; }
  { however, use Trim() for trailing spaces. }

function Item (const S,Sep: String; ItemNo: Integer): String;
  {  Returns the nth Item, where items are separated by Sep strings/chars. }

{  The following functions convert back  }
{ and forth between degrees and radians. }
function Degrees (const RadianAngle: Double): Double;
function Radians (const DegreeAngle: Double): Double;

{  The following function determines whether the contents of Str1, a non- }
{ null-terminated character array, are equal to Str2, a Pascal-style string. }
{ This function is necessary because some old SIMS Modula-2 code stored }
{ strings in arrays of Char without leaving room for a null-terminator. }
function ArrayEqualsString (Str1: array of Char; Str2: String): Boolean;


{  This is another take on the string-to-Cardinal conversion function, this  }
{ based on the algorithm in ISO.mod, and implemented with the Val function   }
{ available in Pascal, and the exception classes built into Delphi. Not sure }
{ which is better. }
function StringToWord (Str: String; var Recognized: Boolean): Word;
function StringToDouble (Str: String; var Recognized: Boolean): Double;

function StripZerosFromExponent (NumericString: String): String;
{  Converts a floating-point string formatted using the %E or %G formats }
{ from something like "123E+006" to "123E6" }

function FormatDouble (Value: Double; FormatString: String): String;

Function FormatForSignificantDigits ( InVal : Double ; Precision, MaxDigitsBefore, MaxDigitsAfter : Integer ) : String ;
{ Formats a floating point number, presenting a required number of significant digits
  MaxDigitsBefore: can be used to resrict the length of the string. If the number of
                   digits required before the decimal place exceeds this value, the string
                   is formatted in scientific notation
  MaxDigitsAfter: can be used to resrict the length of the string. If the number of
                  digits required after the decimal place exceeds this value, the string
                  is formatted in scientific notation}

function TopSpeedTime (const Time: TDateTime): TTopSpeedTime;
function DateTime (const Time: TTopSpeedTime): TDateTime;

{ following function extract information from Borland TDateTime type }
{<<these could really be improved, and they have not been rigorously tested }
function Century (const Time: TDateTime): Word;
{ returns 18 for 1800s, 19 for 1900s, and so on }
function Year (const Time: TDateTime): Word;
{ returns a value beteeen 0 and 99 }
function Month (const Time: TDateTime): Word;
{ returns a value beteeen 1 and 12 }
function DayOfMonth (const Time: TDateTime): Word;
{ returns a value beteeen 1 and 31 }
function HourOfDay (const Time: TDateTime): Word;
{ returns a value beteeen 0 ( midnight to 1 am) and 23 (11 pm to before midnight) }
function Minute (const Time: TDateTime): Word;
{ returns a value between 0 and 59 }
function Second (const Time: TDateTime): Word;
{ returns a value between 0 and 59 }
procedure DisplayWinErrorInfo;

function GetMetafileFromParentControl(ParentControl: TWinControl;
                                      ReferenceCanvas: TCanvas;
                                      IncludeParent: Boolean): TMetafile;

function GetLeadingZeroIntString(i: Integer; const MinWidth: Integer): String;
{Guarantees MinWidth with leading zeroes}

function AnsiToUnicode(S: string; var NewSize: Integer): PWideChar;

function GetVariantFromBytes(BytesSrc: Pointer; Size: Integer): Variant;

//Functions Added for WinQuad.  PM 2/98

function TimeFromTicks(Start,Stop: Integer): Double; //Converts 55mSec clock ticks to seconds, from the old Utility module  PM 2/98

procedure IncrementFileName(var Name: String);
{ This procedure does the following:
       Temp08, Temp09, Temp10, Temp11, etc.
  It also does the following;
       Temp8, Temp9, Temq0, Temq1, etc.  This may be good or bad, depending on your outlook.  PM 5/98
}

//Functions Added by PM 8/98, written by D.Martel

Function  IsNumber ( ch : CHAR ) : BOOLEAN ;
Function  CaseOnlyDifference  ( Str1, Str2 : String ) : BOOLEAN ;

function SetTAxisExtents(o, e: double): TAxisExtents ;

//AF functions to convert from unix to PC byte order, mimic socket functions
function  ntohs(i:Word):Word;
function ntohl(i:Cardinal): Cardinal;
procedure SwapWords(buf:PWord; nPoints:Cardinal);
procedure SwapDWords(buf:PLongWord; nPoints:Cardinal);

procedure ProcessMessages;


function FirstFileFound(DirPath:TStringList;const LookInCD:Boolean; var FileName:String):Boolean;
function DriveType (Path: String): Integer;
function IsDriveCDRom(Path: String):Boolean;
function GetCDLabel(const WhichDrive: string; var CDLabel:String): Boolean;

function  IsMetafile(aCanvas:TCanvas):Boolean;
function GetBuildInfo(var ver:array of Word; fileName: string = ''): Boolean;

function StringToWideString(const s: AnsiString; codePage: Word): WideString;
function DrawTextAnsiMultibyte(hDC: HDC; lpString: PAnsiChar; nCount: Integer;
  var lpRect: TRect; uFormat: UINT): Integer;
function IsSingleByteStr(const aStr: AnsiString): Boolean;
function ValidHexString (Str: String): Boolean;

var gbPrinting:Boolean;//AF quick  and dirty way;

{----------------}
implementation

uses Messages,     { WM_ERASEBKGND, WM_PAINT }
     Dialogs,      { ShowMessage }
     SysUtils,     { EConvertError,Format,StrToFloat,StrToInt }
     math,         { log10 }
     Variants;

const dbD_to_R = Pi / 180.0;

var
gWaitActive: BOOLEAN = TRUE;

{ locally override StrLen():Cardinal symbol so that we can do integer math }
function StrLen(str : PChar) : Integer;
begin
  Result := SysUtils.StrLen(str);
end;

{----------------------------------------------}
function MinOfInt(Int1, Int2: LongInt): LongInt;
begin
  if Int1 <= Int2 then Result:= Int1
  else Result:= Int2;
end;

{----------------------------------------------}
function MaxOfInt(Int1, Int2: LongInt): LongInt;
begin
  if Int1 >= Int2 then Result:= Int1
  else Result:= Int2;
end;

{-----------------------------------------------------}
function MinOfDouble(Double1, Double2: Double): Double;
begin
  if Double1 <= Double2 then Result:= Double1
  else Result:= Double2;
end;

{-----------------------------------------------------}
function MaxOfDouble(Double1, Double2: Double): Double;
begin
  if Double1 >= Double2 then Result:= Double1
  else Result:= Double2;
end;

{------------------------------------------}
function Distance(Pt1, Pt2: TPoint): Double;
begin
  Result:= Sqrt( Sqr(Pt2.X-Pt1.X) + Sqr(Pt2.Y-Pt1.Y) );
end;

{----------------------------------------------}
procedure GetWinPlacement(hWnd: HWND; var Placement: TWindowPlacement);
begin
  Placement.length:= SizeOf(TWindowPlacement);
  GetWindowPlacement(hWnd, @Placement);
end;  { GetWinPlacement }

{----------------------------------------------}
procedure SetNormalWindowPosition(hWnd: HWND; Placement: TWindowPlacement);
  { Sets the NormalPosition record for window hWnd, leaving everything else the same }
var
  CurrentWindowPlacement: TWindowPlacement;
begin
  // this code comes straight from TWinControl.SetBounds (Controls.PAS)
  // and should probably be proceduralized there instead of here....
  CurrentWindowPlacement.length:= SizeOf(TWindowPlacement);
  GetWindowPlacement(hWnd, @CurrentWindowPlacement);
  CurrentWindowPlacement.rcNormalPosition:= Placement.rcNormalPosition;
  SetWindowPlacement(hWnd, @CurrentWindowPlacement);
end;  { SetNormalWindowPosition }

{------------------------------------------------}
function DiskFreeSpaceInMB(Disk: string): Integer;
// Delphi's DiskFree()does not handle UNC names (e.g. "\\dragon\tfs\")
const MEGA_BYTES = 1024 * 1024;
var
  SectorsPerCluster, BytesPerSector, FreeClusters, TotalClusters: DWORD;
  MBytePerCluster: Double;
begin
  if GetDiskFreeSpace(PChar(Disk), SectorsPerCluster, BytesPerSector,
                      FreeClusters, TotalClusters) then
  begin
    MBytePerCluster:= (SectorsPerCluster * BytesPerSector) / MEGA_BYTES;
    Result:= Trunc(MBytePerCluster * FreeClusters);
  end
  else
    Result:= -1;
end; { DiskFreeSpaceInMB }

{----------------------------------------------}
function DriveSpecified (Path: String): Boolean;
begin
  Result:= (Path[2] = ':') or                       { "C:\FOO.BAR" }
           ((Path[1] = '\') and (Path[2] = '\'));   { "\\NETDRIVE\FOO.BAR " }
end;   { DriveSpecified }

{----------------------------------------------}
function DriveType (Path: String): Integer;
begin
   if not DriveSpecified(Path) then
    Result :=1
   else
    Result := GetDriveType(PChar(Copy(Path,1,2)));
end;   { DriveSpecified }

function IsDriveCDRom(Path: String):Boolean;
begin
      Result := (DriveType(Path) = DRIVE_CDROM);
end;

{----------------------------------------------}
function IsRelativePath (Path: String): Boolean;
begin
  if (Length(ExtractFileDir(Path)) = 0)
    then Result:= TRUE
    else Result:= not DriveSpecified(Path);
end;   { IsRelativePath }

{----------------------------------------------}
procedure ForceFileExtension (const Ext: String;
                              var FileName: String);
begin
  FileName := ChangeFileExt(FileName, Ext);
end;   { ForceFileExtension }

{-------------------------------------------------------}
function StripExtension (const FileName: String): String;
begin
  Result := ChangeFileExt(FileName, '');
end;   { StripExtension }

{---------------------------------------------------}
function ForceBackslash (const Path: String): String;
begin
  Result:= ExtractFilePath(Path);
  if (Result[Length(Result)] <> '\')
    then Result:= Result + '\';
end;   { ForceBackslash }

{--------------------------------------------------------------------------------}
procedure GetHeadAndTail (StringToSplit,Separator: String; var Head,Tail: String);
  var SepPos: Integer;
begin
  SepPos:= Pos(Separator,StringToSplit);
  while (SepPos = 1) do begin
    Delete(StringToSplit,1,1);
    SepPos:= Pos(Separator,StringToSplit);
  end;
  if (SepPos = 0)
    then begin
           Head:= StringToSplit;
           Tail:= '';
         end    { separator not present in string; Head=string, Tail=empty }
    else begin
           Head:= Copy(StringToSplit,1,SepPos-1);
           Tail:= Copy(StringToSplit,SepPos+1,Length(StringToSplit));
         end;   { separator found in string; split it in two }
end;   { GetHeadAndTail }

{------------------------------------------------------------}
function Item (const S,Sep: String; ItemNo: Integer): String;
  var I: Integer;
      Head,StringToSearch: String;
begin
  StringToSearch:= S;
  I:= -1;
  repeat
    Inc(I);
    GetHeadAndTail(StringToSearch,Sep,Head,StringToSearch);
  until ((I = ItemNo) or (StringToSearch = ''));
  if (I = ItemNo)
    then Result:= Head
    else Result:= '';
end;   { Item }

{-------------------------------------------------------------------}
function TrimTrailingChars (const S: String; const Ch: Char): String;
  var I: Integer;
begin
  I:= Length(S);
  while ((I > 0) and (S[I] = Ch))
    do Dec(I);
  Result:= Copy(S,1,I);
end;   { TrimTrailingChars }

{---------------------------------------------------}
function Degrees (const RadianAngle: Double): Double;
begin
  Result:= (RadianAngle / dbD_to_R);
end;   { Degrees }

{---------------------------------------------------}
function Radians (const DegreeAngle: Double): Double;
begin
  Result:= (DegreeAngle * dbD_to_R);
end;   { Radians }

{-----------------------------------------}
function IsDigit (const Ch: Char): Boolean;
begin
  Result:= CharInSet(Ch, ['0','1','2','3','4','5','6','7','8','9']);
end;   { IsDigit }

{-----------------------------------------}
function IsAlpha (const Ch: Char): Boolean;
begin
  Result:= ((Ord(Ch) >= Ord('A')) and (Ord(Ch) <= Ord('Z')) or
            (Ord(Ch) >= Ord('a')) and (Ord(Ch) <= Ord('z')))
end;   { IsDigit }

{---------------------------------------------}
function IsLowerCase (const Ch: Char): Boolean;
begin
  Result:= (Ord(Ch) >= Ord('a')) and (Ord(Ch) <= Ord('z'));
end;   { IsLowerCase }

{---------------------------------------------}
function IsUpperCase (const Ch: Char): Boolean;
begin
  Result:= (Ord(Ch) >= Ord('A')) and (Ord(Ch) <= Ord('Z'));
end;   { IsUpperCase }

{--------------------------------------}
function LowCase (const Ch: Char): Char;
begin
  if (not IsAlpha(Ch))
    then Result:= Ch
    else Result:= Chr(Ord(UpCase(Ch)) + 32);
end;   { LowCase }

{----------------------------------}
function HexCharOf(Num: Byte): Char;
begin
  if Num <= 9 then
    Result:= Chr(Ord('0') + Num)
  else
    Result:= Chr(Ord('A') + Num - 10);
end; { HexCharOf }

{----------------------------------------}
function ValueOfHexDigit (Ch: Char): Byte;
begin
  { we do not allow for minus sign, since this routine }
  { only used to obtain a cardinal number }
  if not (CharInSet(Ch, ['0'..'9','a'..'f','A'..'F']))
    then raise EConvertError.Create('Invalid hexadecimal digit: ValueOfHexDigit');

  Result:= Ord(ch) - Ord('0');
  if Result > 9 then
    Result:= 10 + Ord(ch) - Ord('A');
end; { ValueOfHexDigit }

{--------------------------------------------}
function HexStrToCard (Str: String): Cardinal;
  var NextDigit: Byte;
      TrimStr: String;
      Ch,Len,MulFactor: Cardinal;
begin
  TrimStr:= Trim(Str);
  Len:= Length(TrimStr);
  if (Len = 0)
    then raise EConvertError.Create('String contains no hexdecimal characters: HexStrToCard')
    else begin
           Result:= 0;
           MulFactor:= 1;
           for Ch:= Len downto 1
             do begin
                  NextDigit:= ValueOfHexDigit(TrimStr[Ch]);    { EConvertError not handled here }
                  Result:= Result + (MulFactor * NextDigit);
                  MulFactor:= MulFactor * 16;
                end;   { try to convert each character in string }
         end;   { check for null string before converting }
end; { HexStrToCard }

{----------------------------------------------------------------------}
function ArrayEqualsString (Str1: array of Char; Str2: String): Boolean;
  var Ch: Cardinal;
begin
  Result:= TRUE;
  if (Length(Str2) <> HIGH(Str1)+1)
    then Result:= FALSE
    else for Ch:= 0 to HIGH(Str1)
           do if (Str1[Ch] = Str2[Ch+1])   { Pascal-style strings are indexed from 1 }
                then Continue
                else begin
                       Result:= FALSE;
                       Break;
                     end;   { stop as soon as we find a differing character }
end;   { ArrayEqualsString }

{-----------------------------------------------}
function FormatNoSpaces (const FormatStr: String;
                         const Args: array of const): String;
  var Original: String;
      Copy,Index: Integer;
      ResultStr: array [0..255] of Char;
begin
  Original:= Format(FormatStr,Args);
  Index:= 1;
  while (Original[Index] = ' ')
    do Inc(Index);
  for Copy:= Index to Length(Original)
    do ResultStr[Copy-Index]:= Original[Copy];
  ResultStr[Length(Original)]:= Char(0);   { no leading spaces }
  while (TRUE)
    do if (ResultStr[StrLen(ResultStr)-1] = ' ')
         then ResultStr[StrLen(ResultStr)-1]:= Char(0)
         else Break;
  Result:= StrPas(ResultStr);
end;   { FormatNoSpaces }

{------------------------------------------------------------------}
function FormatDouble (Value: Double; FormatString: String): String;
begin
  Result:= FormatNoSpaces(FormatString,[Value]);
  Result:= StripZerosFromExponent(Result);
end;   { FormatDouble }

{---------------------------------------}
Function FormatForSignificantDigits ( InVal : Double ; Precision, MaxDigitsBefore, MaxDigitsAfter : Integer ) : String ;

Var OutStr       : String  ;
    LogVal       : Double  ;
    Order, Ind   : Integer ;
    Negative     : Boolean ;
    Rounded      : Double ;

{
  Function Log10 ( InVal : Double ) : Double ;
  CONST  ln10 = 2.30258509299404568402 ;
         LogOfE = 1.0/ln10 ;
  Begin
      Log10 := LogOfE * ln ( InVal ) ;
  End ;
}

Begin
    If InVal = 0.0 Then Begin
      Result := '0.' ;
      For Ind := 1 To Precision Do Result := Result + '0' ;
      Exit ;
    End ;

    Negative := InVal < 0.0 ;
    InVal := ABS ( InVal ) ;
    LogVal := Log10 ( InVal ) ;
    Order := Trunc ( LogVal ) ;

    OutStr := FloatToStrF ( InVal, ffExponent, Precision, 1 ) ;
    Rounded := StrToFloat ( OutStr ) ;

    If LogVal < 0.0 Then
      Begin
        If ABS(Order) <= (MaxDigitsAfter - Precision) Then Begin
          OutStr := FloatToStrF ( InVal, ffFixed, Precision, MaxDigitsAfter ) ;
          Delete ( OutStr, (ABS(Order) + Precision + 3), 255 ) ;
        End ;
      End
    Else
      Begin
        LogVal := Log10 ( Rounded ) ;
        Order := Trunc ( LogVal ) ;

        If ((Order+1) <= MaxDigitsBefore) Then
          Begin
            If (Order + 1 - Precision) >= 0 Then
              OutStr := IntToStr( Round(Rounded) )
            Else
              OutStr := FloatToStrF ( Rounded, ffFixed, Precision, (Precision -(Order+1)) ) ;
          End
        Else
          Begin
            {Will stick with the default exponential format}
          End ;



      End ;

    If Negative Then
      Result := '-' + OutStr
    Else
      Result := OutStr ;

End ;

{---------------------------------------}
procedure DeleteSpaces (var Src: String);
  var I,J: Integer;
      strTemp: array [0..255] of Char;
begin
  J:= 0;
  for I:= 1 to Length(Src)
    do if (Src[I] <> ' ')
         then begin
                strTemp[J]:= Src[I];
                Inc(J);
              end;   { copy non-space characters }
  strTemp[J]:= Char(0);
  Src:= StrPas(strTemp);
end;   { DeleteSpaces }

{-------------------------------------------------}
procedure DeleteSpaceChars (var Src: array of Char);
  var I,J: Integer;
      Dest: array [0..255] of Char;
begin
  J:= 0;
  for I:= 0 to StrLen(@Src)-1
    do if (Src[I] <> ' ')
         then begin
                Dest[J]:= Src[I];
                Inc(J);
              end;   { copy non-space characters }
  Dest[J]:= Char(0);
  StrCopy(@Src,Dest);
end;   { DeleteSpaceChars }

{--------------------------------------------------------------}
function StripZerosFromExponent (NumericString: String): String;
  var Ch,StartOfExponent: Integer;
begin
  StartOfExponent:= Pos('E',NumericString);
  if (StartOfExponent = 0)
    then StartOfExponent:= Pos('e',NumericString);
  if (StartOfExponent = 0)
    then begin
           Result:= NumericString;
           Exit;
         end;   { no exponent }
  Ch:= (StartOfExponent + 1);
  if ((NumericString[Ch] = '+') or (NumericString[Ch] = '-'))
    then Inc(Ch);
  Result:= Copy(NumericString,1,Ch-1);
  while ((Ch < Length(NumericString)) and (NumericString[Ch] = '0'))
    do Inc(Ch);
  Result:= Result + Copy(NumericString,Ch,Length(NumericString));
end;   { Strip ZerosFromExponent }

{-----------------------------------------------------------------}
function StringToWord (Str: String; var Recognized: Boolean): Word;
  var Value: LongInt;
      ErrPos: Integer;
begin
  Result:= 0;
  Recognized:= TRUE;

  try
    Val(Str,Value,ErrPos);
    if ((Value > 0) and (Value <= High(Word)))
      then Result:= Value;
  except
    on ERangeError
      do Recognized:= FALSE;
    on EConvertError
      do Recognized:= FALSE;
  end;   { exception block }
end;   { StringToWord }

{---------------------------------------------------------------------}
function StringToDouble (Str: String; var Recognized: Boolean): Double;
  var Value: Double;
      ErrPos: Integer;
begin
  Result:= 0;
  Recognized:= TRUE;
  try
    Val(Str,Value,ErrPos);
    Result:= Value;
  except
    on ERangeError
      do Recognized:= FALSE;
    on EConvertError
      do Recognized:= FALSE;
    else
      raise;
  end;   { exception block }
end;   { StringToDouble }

(*
{----------------------------------------}
procedure BitmapToIcon (aBitmap: TBitmap);
{This code takes a bitmap, and converts it into an icon.

aBitmap is the bitmap you want to convert.
andBitmap is the mask bitmap, which is created in the function.
anIcon is the Icon and bitmap is a WinTypes.TBitmap, dwCount1/2 are word. }
  var aIcon: TIcon;
      PixelX,PixelY: Integer;
      andBitmap: TBitmap;
begin
  andBitmap:= TBitmap.Create;
  andBitmap.Monochrome:= TRUE;
  andBitmap.Height:= aBitmap.Height;
  andBitmap.Width:= aBitmap.Width;
  transColor:= aBitmap.Canvas.Pixels[0,aBitmap.Height];

  for PixelX:= 0 to aBitmap.Width
    do begin
         for PixelY:= 0 to aBitmap.Height
           do begin
                if (aBitmap.Canvas.Pixels[PixelX,PixelY] = transColor)
                  then andBitmap.Canvas.Pixels[PixelX,PixelY]:= clWhite
                  else andBitmap.Canvas.Pixels[PixelX,PixelY]:= clBlack;
              end;   { for each vertical line }
       end;   { for each horizontal pixel }

  GetObject(andBitmap.Handle,sizeOf(bitmap),@bitmap);
  dwCount2:= bitmap.bmHeight * bitmap.bmPlanes * bitmap.bmWidthBytes;
  GetMem(pAndBits,dwCount2);
  GetBitmapBits(andBitmap.Handle,dwCount2,pAndBits);

  GetObject(aBitmap.Handle,sizeOf(bitmap),@bitmap);
  dwCount1:= bitmap.bmHeight * bitmap.bmPlanes * bitmap.bmWidthBytes;
  GetMem(pXorBits,dwCount1);
  GetBitmapBits(aBitmap.Handle,dwCount1,pXorBits);

  aIcon:= TIcon.Create;
  aIcon.Handle:= CreateIcon(hInstance,
                            aBitmap.Height,aBitmap.Width,
                            bitmap.bmPlanes,bitmap.bmBitsPixel,
                            pAndBits,pXorBits);

  if (pAndBits <> NIL)
    then FreeMem(pAndBits,dwCount2);
  if (pXorBits <> NIL)
    then FreeMem(pXorBits,dwCount1);
  if (andBitmap <> NIL)
    then andBitmap.free;
end;   { BitmapToIcon }
*)


{-----------------------------------------------------------}
function TopSpeedTime (const Time: TDateTime): TTopSpeedTime;
var
  Year, Month, Day: Word;
  Seconds: Cardinal;
begin
  try
    DecodeDate(Time, Year, Month, Day);
    Result.Day:= ((Year-1900) shl 9) + (Month shl 5) + Day;
    Seconds:= Trunc(Frac(Time) * 86400.0);   { 86,400 = secs per day }
    Result.Minute:= (Seconds div 60);
    Dec(Seconds,(Result.Minute * 60));
    Result.Millisec:= Seconds * 1000;
  except
    { prevent mysterious EIntOverflow error }
  end;   { try-except block }
end;   { TopSpeedTime }

{-------------------------------------------------------}
function DateTime (const Time: TTopSpeedTime): TDateTime;
var
  Year, Month, Day: Word;
  Date: TDateTime;
begin
  Year:= (Time.Day shr 9) + 1900;
  Month:= (Time.Day and $01E0) shr 5;
  Day:= Time.Day and $001F;
  if (Month <= 0) or (Month > 12) then
    Month:= 1;
  if (Day <= 0) or (Day >= 31) then
    Day:= 1;
  try
    Date:= EncodeDate(Year, Month, Day);
    with Time do
      Result:= Date + ((Millisec div 1000) + (Minute * 60.00)) / 86400.0;
  except
    Result:= 0;
  end;
end;   { DateTime }

{---------------------------------------------------------}
function RdStr (FromFile: Integer; MaxChars: Word): String;
var
  nextCh: AnsiChar;
  charsRead: Integer;
  numberRead: Integer;
  resultAnsiStr: AnsiString;
begin
  Result := '';
  resultAnsiStr := '';
  charsRead := 0;
  try
    repeat
      // Check for a buffer overflow.
      if (charsRead >= MaxChars) then // If max number chars have been read
        break; // Break from the loop.

      // Read a character from the file.
      numberRead := FileRead(FromFile, nextCh, SizeOf(nextCh));

      // Check for a valid read.
      if (numberRead = SizeOf(AnsiChar)) then
      begin
        // If not a line feed character, save the character in the Ansi string.
        if (NextCh <> LF) then
        begin
          resultAnsiStr := resultAnsiStr + nextCh;
          Inc(charsRead);
        end
        else  // Line feed character found.
        begin
          // If the previous character was a CR, delete it from the Ansi string.
          if resultAnsiStr[length(resultAnsiStr)] = CR then
            Delete(resultAnsiStr, length(resultAnsiStr), 1);

          // Break from the loop.
          break;
        end;
      end;
    until (FALSE);

  except
    on EInOutError do
      // this will happen on EOF, but that's OK
  end;

  // Set the return value.
  Result := String(resultAnsiStr);
end;

procedure SetWaitActive(State: BOOLEAN);
// Set the Active Wait State for the WaitXmillisecs function.  Turning this
// state to off allows certain wait to be avoided when the machine is not
// in offline operation.
begin
  gWaitActive := State;
end;

{------------------------------------------------}
procedure WaitXmillisecs (MillisecsToWait: DWORD);
  var Status: DWORD;
      hWait: THandle;
begin

  if (gWaitActive = FALSE) then
    exit;

  hWait:= CreateEvent(NIL,TRUE,FALSE,NIL);
  Status:= WaitForSingleObject(hWait,MillisecsToWait);

  { the following case statement shows the possible return values }
  { it looks like WAIT_TIMEOUT is normal termination, }
  {               WAIT_ABANDONED indicates a thread problem }
  {           and WAIT_OBJECT_0 is impossible, since we aren't waiting on an object }
  { if we don't make any progress on the access violation, we might want to }
  { determine that we are getting WAIT_TIMEOUT values }
  case Status of
    WAIT_TIMEOUT: { The time-out interval elapsed, and the object's state is nonsignaled. };
    WAIT_ABANDONED: { The specified object is a mutex object that was not released }
                    { by the thread that owned the mutex object before the owning }
                    { thread terminated. Ownership of the mutex object is granted }
                    { to the calling thread, and the mutex is set to nonsignaled. };
    WAIT_OBJECT_0:  { The state of the specified object is signaled. };
  end;   { case statement }

  CloseHandle(hWait);
end;   { WaitXmillisecs }

procedure WaitWithMessagePump(hWnd:HWND; MillisecsToWait:DWORD);
var currTime:DWORD;
    mess:MSG;
begin
      currTime := timeGetTime;
      while (timeGetTime < currTime + MillisecsToWait) do
      begin
          if (PeekMessage(mess,hWnd,0,0,PM_NOREMOVE )) then
          begin
                GetMessage(mess, hWnd,0,0);
                DispatchMessage(mess);
          end;
      end;
end;
procedure ProcessMessages;
var mess:MSG;
begin
        while (PeekMessage(mess,0,0,0,PM_NOREMOVE )) do
             begin
                GetMessage(mess, 0,0,0);
                DispatchMessage(mess);
             end;
end;

{---------------------------------------------}
function Century (const Time: TDateTime): Word;
  var NumDaysSince_12_30_1899: Double;
begin
  NumDaysSince_12_30_1899:= Int(Time);

  Result:= 18;   { there's two possible dates in the 19th century }
  repeat
    Inc(Result);
    if (NumDaysSince_12_30_1899 < DaysInCentury)
      then Exit;
    NumDaysSince_12_30_1899:= NumDaysSince_12_30_1899 - DaysInCentury;
  until (FALSE);
end;   { Century }

{------------------------------------------}
function Year (const Time: TDateTime): Word;
  var NumDays: Cardinal;
begin
  Result:= 99;
  if (Int(Time) < 2.0)
    then Exit;               { either 12/30/1899 or 12/31/1899 }

  NumDays:= Trunc(Int(Time) - 2.0);  { use int arithmetic to speed this up }
  repeat
    Result:= (Result + 1) mod 100;
    if (Result = 0)          { a 00 year }
      then if (NumDays < 365)
             then Exit       { num days in 00 year}
             else NumDays:= NumDays - 365
      else if (NumDays < 366)
             then Exit       { leap year!!! }
             else NumDays:= NumDays - 366;

    Result:= (Result + 1) mod 100;
    if (NumDays < 365)
      then Exit
      else NumDays:= NumDays - 365;
    Result:= (Result + 1) mod 100;
    if (NumDays < 365)
      then Exit
      else NumDays:= NumDays - 365;
    Result:= (Result + 1) mod 100;
    if (NumDays < 365)
      then Exit
      else NumDays:= NumDays - 365;
  until (FALSE);
end;   { Year }

{-------------------------------------------}
function Month (const Time: TDateTime): Word;
  var TheYear,NumDays: Cardinal;
begin
  Result:= 12;
  if (Int(Time) < 2.0)
    then Exit;               { either 12/30/1899 or 12/31/1899 }

  TheYear:= 99;
  NumDays:= Trunc(Int(Time) - 2.0);  { use int arithmetic to speed this up }
  repeat
    TheYear:= (TheYear + 1) mod 100;
    if (TheYear = 0)         { a 00 year }
      then if (NumDays < 365)
             then Break      { num days in 00 year}
             else NumDays:= NumDays - 365
      else if (NumDays < 366)
             then Break      { leap year!!! }
             else NumDays:= NumDays - 366;

    TheYear:= (TheYear + 1) mod 100;
    if (NumDays < 365)
      then Break
      else NumDays:= NumDays - 365;
    TheYear:= (TheYear + 1) mod 100;
    if (NumDays < 365)
      then Break
      else NumDays:= NumDays - 365;
    TheYear:= (TheYear + 1) mod 100;
    if (NumDays < 365)
      then Break
      else NumDays:= NumDays - 365;
  until (FALSE);

  Result:= 1;
  if (NumDays > 31)
    then Dec(NumDays,31)
    else Exit;   { January }

  Inc(Result);
  if (TheYear <> 0) and ((TheYear mod 4) = 0)
    then if (NumDays > 29)
           then Dec(NumDays,29)
           else Exit    { leap-year February }
    else if (NumDays > 28)
           then Dec(NumDays,28)
           else Exit;   { normal February }

  Inc(Result);
  if (NumDays > 31)
    then Dec(NumDays,31)
    else Exit;   { March }

  Inc(Result);
  if (NumDays > 30)
    then Dec(NumDays,30)
    else Exit;   { April }

  Inc(Result);
  if (NumDays > 31)
    then Dec(NumDays,31)
    else Exit;   { May }

  Inc(Result);
  if (NumDays > 30)
    then Dec(NumDays,30)
    else Exit;   { June }

  Inc(Result);
  if (NumDays > 31)
    then Dec(NumDays,31)
    else Exit;   { July }

  Inc(Result);
  if (NumDays > 31)
    then Dec(NumDays,31)
    else Exit;   { August }

  Inc(Result);
  if (NumDays > 30)
    then Dec(NumDays,30)
    else Exit;   { September }

  Inc(Result);
  if (NumDays > 31)
    then Dec(NumDays,31)
    else Exit;   { October }

  if (NumDays <= 30)
    then Result:= 11   { November }
    else Result:= 12;  { December }
end;   { Month }

{------------------------------------------------}
function DayOfMonth (const Time: TDateTime): Word;
  var M: Integer;
      TheMonth,TheYear,NumDays: Cardinal;
begin
  Result:= 30;
  if (Int(Time) < 1.0)
    then Exit;
  Result:= 31;
  if (Int(Time) < 2.0)
    then Exit;

  TheYear:= 99;
  NumDays:= Trunc(Int(Time) - 2.0);  { use int arithmetic to speed this up }
  repeat
    TheYear:= (TheYear + 1) mod 100;
    if (TheYear = 0)         { a 00 year }
      then if (NumDays < 365)
             then Break      { num days in 00 year}
             else NumDays:= NumDays - 365
      else if (NumDays < 366)
             then Break      { leap year!!! }
             else NumDays:= NumDays - 366;

    TheYear:= (TheYear + 1) mod 100;
    if (NumDays < 365)
      then Break
      else NumDays:= NumDays - 365;
    TheYear:= (TheYear + 1) mod 100;
    if (NumDays < 365)
      then Break
      else NumDays:= NumDays - 365;
    TheYear:= (TheYear + 1) mod 100;
    if (NumDays < 365)
      then Break
      else NumDays:= NumDays - 365;
  until (FALSE);

  TheMonth:= Month(Time);
  for M:= 1 to TheMonth-1
    do case M of
          2: if (TheYear <> 0) and ((TheYear mod 4) = 0)
               then Dec(NumDays,29)
               else Dec(NumDays,28);
          1,3,5,7,8,10,12:
             Dec(NumDays,31);
          4,6,9,11:
             Dec(NumDays,30);
       end;   { case statement }

  Result:= (NumDays + 1);
end;   { DayOfMonth }

{-----------------------------------------------}
function HourOfDay (const Time: TDateTime): Word;
begin
  Result:= Trunc(Frac(Time) * SecondsPerDay) div SecondsPerHour;
end;   { HourOfDay }

{--------------------------------------------}
function Minute (const Time: TDateTime): Word;
begin
  Result:= Trunc(Frac(Time) * SecondsPerDay) mod MinutesPerHour;
end;   { Minute }

{--------------------------------------------}
function Second (const Time: TDateTime): Word;
begin
  Result:= Trunc(Frac(Time) * SecondsPerDay) mod 60;
end;   { Second }

{-------------------------------------------------}
function HourMinSecsStr (MilliSecs: DWORD): String;
  var Secs: Cardinal;
begin
  Result:= '';
  Secs:= (MilliSecs div 1000);
  if (Secs >= SecondsPerHour)
    then begin
           Result:= Format('%2d:',[Secs div SecondsPerHour]);
           Secs:= (Secs mod SecondsPerHour);
         end;   { append hours }
  if (Secs > 60)
    then begin
           Result:= Result + Format('%.2d:',[Secs div 60]);
           Secs:= (Secs mod 60);
         end    { append minites }
    else Result:= Result + '00:';
  if (Secs > 0)
    then Result:= Result + Format('%.2d',[Secs])
    else Result:= Result + '00';
end;   { HourMinSecsStr }

{----------------------------}
procedure DisplayWinErrorInfo;
  var lpMsgBuf: PChar;
begin
  FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM,
                NIL,GetLastError,LANG_NEUTRAL + (SUBLANG_DEFAULT shl 10),
                @lpMsgBuf,0,NIL);
  ShowMessage(Format('Error #%d means',[Error]) + #13 + #10 + StrPas(lpMsgBuf));
end;   { DisplayWinErrorInfo }

{---------------------------------------------}
function ColorToString (Color: TColor): String;
begin
  case Color of
    clBlack: Result:= 'Black';
   clMaroon: Result:= 'Maroon';
    clGreen: Result:= 'Green';
    clOlive: Result:= 'Olive';
     clNavy: Result:= 'Navy';
   clPurple: Result:= 'Purple';
     clTeal: Result:= 'Teal';
     clGray: Result:= 'Gray';
   clSilver: Result:= 'Silver';
      clRed: Result:= 'Red';
     clLime: Result:= 'Lime';
   clYellow: Result:= 'Yellow';
     clBlue: Result:= 'Blue';
  clFuchsia: Result:= 'Fuchsia';
     clAqua: Result:= 'Aqua';
    clWhite: Result:= 'White';
       else  Result:= Format('%8x',[Color]);
  end;   { case statement }
end;   { ColorToString }

{---------------------------------------------}
function StringToColor (Color: String): TColor;
begin
  if (Color = 'Black')
    then Result:= clBlack
  else if (Color = 'Maroon')
    then Result:= clMaroon
  else if (Color = 'Green')
    then Result:= clGreen
  else if (Color = 'Olive')
    then Result:= clOlive
  else if (Color = 'Navy')
    then Result:= clNavy
  else if (Color = 'Purple')
    then Result:= clPurple
  else if (Color = 'Teal')
    then Result:= clTeal
  else if (Color = 'Gray')
    then Result:= clGray
  else if (Color = 'Silver')
    then Result:= clSilver
  else if (Color = 'Red')
    then Result:= clRed
  else if (Color = 'Lime')
    then Result:= clLime
  else if (Color = 'Yellow')
    then Result:= clYellow
  else if (Color = 'Blue')
    then Result:= clBlue
  else if (Color = 'Fuchsia')
    then Result:= clFuchsia
  else if (Color = 'Aqua')
    then Result:= clAqua
  else if (Color = 'White')
    then Result:= clWhite
    else Result:= TColor(StrToInt(Color));
end;   { StringToColor }

{---------------------------------------------------------------}
function GetMetafileFromParentControl(ParentControl: TWinControl;
                                      ReferenceCanvas: TCanvas;
                                      IncludeParent: Boolean): TMetafile;
var
  DCToDraw: HDC;
  MetafileCanvas: TMetafileCanvas;
  { sub-routine }
  procedure DrawHandle(Handle: HWND);
  var
    R: TRect;
    Child: HWND;
    SavedIndexOuter, SavedIndexInner, I: Integer;
  begin
    if IsWindowVisible(Handle) then
    begin
      SavedIndexOuter:= SaveDC(DCToDraw);

      Windows.GetClientRect(Handle, R);
      MapWindowPoints(Handle, ParentControl.Handle, R, 2);
      with R do
      begin
        SetWindowOrgEx(DCToDraw, -Left, -Top, nil);
        IntersectClipRect(DCToDraw, 0, 0, Right - Left, Bottom - Top);
      end; { with }
      //SendMessage(Handle, WM_ERASEBKGND, DCToDraw, 0);
      if IncludeParent or (Handle <> ParentControl.Handle) then
        SendMessage(Handle, WM_PAINT, longint(DCToDraw), 0)
      else
      begin
        for I:= 0 to ParentControl.ControlCount-1 do
        begin
          if (ParentControl.Controls[I] is TWinControl) then
          begin
            with TWinControl(ParentControl.Controls[I]) do
              if Visible then PaintTo(DCToDraw, Left, Top);
          end
          else
          begin
            with ParentControl.Controls[I] do
            begin
              SavedIndexInner:= SaveDC(DCToDraw);
              MoveWindowOrg(DCToDraw, Left, Top);
              IntersectClipRect(DCToDraw, 0, 0, Width, Height);
              Perform(WM_PAINT, DCToDraw, 0);
              RestoreDC(DCToDraw, SavedIndexInner);
            end; { with }
          end;
        end; { for }
      end; { if..else }

      Child := GetWindow(Handle, GW_CHILD);
      if Child <> 0 then
      begin
        Child := GetWindow(Child, GW_HWNDLAST);
        while Child <> 0 do
        begin
          DrawHandle(Child);
          Child := GetWindow(Child, GW_HWNDPREV);
        end; { while }
      end; { if }

      RestoreDC(DCToDraw, SavedIndexOuter);
    end; { if IsWindowVisible }
  end; { DrawHandle }
begin { GetMetafileFromParentControl }
  Result:= TMetafile.Create;
  with ParentControl.ClientRect do
  begin
    Result.Width:= Right - Left;
    Result.Height:= Bottom - Top;
  end;

  MetafileCanvas:= TMetafileCanvas.Create(Result, ReferenceCanvas.Handle);
  try
    DCToDraw:= MetafileCanvas.Handle;
    try
      { Paint into the metafile }
      DrawHandle(ParentControl.Handle);
    except
      Result.Free;
      Result:= nil;
      raise;
    end; { try-except for DrawHandle }
  finally
    MetafileCanvas.Free;
  end; { try-finally for MetafileCanvas }
end; { GetMetafileFromParentControl }

{ This function returns the size of the allocated string in NewSize. }
{ You have to free up this memory yourself. }
{-----------------------------------------------------------------}
function AnsiToUnicode(S: string; var NewSize: Integer): PWideChar;
begin
  Result := PWideChar(S);
end;

{ This function returns a variant from a byte array. }
function GetVariantFromBytes(BytesSrc: Pointer; Size: Integer): Variant;
var BytesDst: PByte;
begin
  Result:= VarArrayCreate([0, Size-1], varByte);
  BytesDst:= VarArrayLock(Result);
  try
    CopyMemory(BytesDst, BytesSrc, Size);
  finally
    VarArrayUnlock(Result);
  end;
end;

{---------------------------------------}
{Guarantees MinWidth with leading zeroes}
function GetLeadingZeroIntString(i: Integer; const MinWidth: Integer): String;
var Str: String;
begin
  Str:=IntToStr(i);
  Trim(Str);
  while Length(Str) < MinWidth do begin
    Insert('0',Str,1);
  end;
  Result:= Str;
end; {GetLeadingZeroIntString}

function TimeFromTicks(Start,Stop: Integer): Double; //Converts 55mSec clock ticks to seconds, from the old Utility module  PM 2/98
const
  TimeConst = 0.05492549;
var
  time: Double;
begin
  time:= TimeConst*(Stop-Start);
  if time <= -TimeConst then begin time:= time + 86400. end; (*seconds/day*)
  Result:=time;
end;


function IncChar(InChar: char; var Carry: Boolean): char;
  (* goes with IncrmentFileName *)
begin (* IncChar *)
  Carry:= FALSE;
  case InChar of
    '0'..'8','A'..'Y','a'..'y': inc(InChar);
    'Z': InChar:= '0';
    'z': InChar:='0';
    '9': begin
      Carry:= True; InChar:='0';
    end;
    {
    //CHR(00H)..CHR(2FH): InChar:= '0';
    #0..#57: InChar:='0';
    //CHR(3AH)..CHR(40H): InChar:= 'A';
    #72..#100: begin InChar:='A'; end;
    CHR(5BH)..CHR(60H): InChar:= 'a';
    }
  else
    Carry:= True; InChar:= '0';
  end; (* CASE *);
  Result:=InChar;
end;

//------------------------------------------------------------------------------
//  IncrementFileName
//------------------------------------------------------------------------------
procedure IncrementFileName(var Name: String);
var
  Idx: CARDINAL;
  Carry: BOOLEAN;
begin (* IncName *)
  if Name='' then begin
    Name:='Temp000';
  end else begin
    try
      Idx:= Length(Name);
      Name[Idx]:=IncChar(Name[Idx],Carry);
      while Carry and (Idx>0) do begin
        dec(Idx);
        Name[Idx]:= IncChar(Name[Idx],Carry);
      end; // while
      if Carry then begin
        Name:=Name+'0';
      end;
    except
      Name:='Temp000';
    end;
  end;  //if Name=''
end;


{******************************************************************}
Function IsNumber ( ch: CHAR ) : BOOLEAN ;
BEGIN
    Result := ( (ch >= '0') AND (ch <= '9') );
END ;

{******************************************************************}
Function CaseOnlyDifference(Str1,Str2: String ): BOOLEAN;
BEGIN
    Result := UpperCase(Str1) = UpperCase(Str2) ;
END ;

{-------------------------------------------------------------------------------}
function ElapsedTimeInMillisecs (const FirstReading,SecondReading: DWORD): DWORD;
begin
  if (SecondReading >= FirstReading) then
    Result:= (SecondReading - FirstReading)
  else  { the system clock wraps around every 2^32 millisecs = 49.7 days }
    Result:= (High(DWORD) - FirstReading) + SecondReading;
end;   { ElapsedTimeInMillisecs }

{-------------------------------------------------------------------------------}
function SetTAxisExtents(o, e: double): TAxisExtents ;
begin
  with Result do
  begin
    OriginValue:= o;
    EndValue:= e;
  end ;
end ;

function  ntohs(i:Word):Word;
begin
   Result :=(i shr 8 and $FF) or (i shl 8 and $FF00);
end;

function ntohl(i:Cardinal): Cardinal;
begin
    Result :=(i shr 24 and $FF) or ( i shr 8 and $ff00) or (i shl 8  and $ff0000) or  (i shl 24 and $ff000000)
end;

procedure SwapWords(buf:PWord; nPoints:Cardinal);
var p:PWord;
    i:Integer;
begin
   p:= buf;
   for i:=0 to npoints -1 do
   begin
      p^ := ntohs(p^);
      Inc(p);
   end;
end;

procedure SwapDWords(buf:PLongWord; nPoints:Cardinal);
var p:PLongWord;
    i:Integer;
begin
   p:= buf;
   for i:=0 to npoints -1 do
   begin
      p^ := ntohl(p^);
      Inc(p);
   end;
end;

function  IsMetafile(aCanvas:TCanvas):Boolean;
begin
     {res:= GetObjectType(aCanvas.Handle) ;
     if(Res <>0) and ((Res=OBJ_METADC) or (Res=OBJ_ENHMETADC)) then
            Result:=TRUE
     else
     Result:= FALSE; }
     result:= gBPrinting;
end;

function GetCDLabel(const WhichDrive: string; var CDLabel:String): Boolean;
var
  VolumeName    : array[0..255] of char;
  FileSystemType   : array[0..255] of char;
  SerialNum    : DWORD;
  MaxFilenameLength   : DWORD;
  Flags     : DWORD;
begin
  Result := FALSE;
  CDLabel :='';
  if (GetVolumeInformation(PChar(WhichDrive),
                           VolumeName,
                           256,
                           @SerialNum,
                           MaxFilenameLength,
                           Flags,
                           FileSystemType,
                           256)) then
  begin
      Result := TRUE;
      CDLabel := VolumeName;
  end;
end;

function FirstFileFound(DirPath:TStringList;const LookInCD:Boolean; var FileName:String):Boolean;
var i:Integer;
begin
      Result := FALSE;
      if (DriveSpecified(Filename)) then
            Result := TRUE
      else
      for i:=0 to DirPath.Count -1 do
      begin
          FileName := DirPath[i]+FileName;
          if IsDriveCDROM(FileName) and not LookInCD then
             Result := FALSE
          else
          if FileExists(FileName) then
          begin
                Result := TRUE;
                Exit;
          end;
      end;
end;
function GetBuildInfo(var ver:array of Word; fileName: string = ''): Boolean;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
begin
  Result := True;
  if fileName = '' then
    fileName := ParamStr(0);
  VerInfoSize := GetFileVersionInfoSize(PChar(fileName), Dummy);
  if VerInfoSize = 0 then
  begin
    Result := False;
    Exit;
  end;
  GetMem(VerInfo, VerInfoSize);
  try
    GetFileVersionInfo(PChar(fileName), 0, VerInfoSize, VerInfo);
    VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);

    with VerValue^ do
    begin
      Ver[0] := dwFileVersionMS shr 16;
      Ver[1] := dwFileVersionMS and $FFFF;
      Ver[2] := dwFileVersionLS shr 16;
      Ver[3] := dwFileVersionLS and $FFFF;
    end;
  finally
    FreeMem(VerInfo, VerInfoSize);
  end;
end;

function StringToWideString(const s: AnsiString; codePage: Word): WideString;
{Run the MultiByteToWideChar function once with a 0 to get the required size,
grab the result and feed it into it again for the real deal.
(If length param is zero, the MultiByteToWideChar function returns the required
buffer size, in wide characters, and makes no use of the lpWideCharStr buffer.)}
var
  l: integer;
begin
  if s = '' then
    Result := ''
  else
  begin
    //Run the MultiByteToWideChar function once with a 0 to get the required size
    l := MultiByteToWideChar(codePage, MB_PRECOMPOSED, PAnsiChar(@s[1]), - 1, nil, 0);
    SetLength(Result, l - 1);
    if l > 1 then //Call it again with the proper length
      MultiByteToWideChar(CodePage, MB_PRECOMPOSED, PAnsiChar(@s[1]),
        - 1, PWideChar(@Result[1]), l - 1);
  end;
end;

function DrawTextAnsiMultibyte(hDC: HDC; lpString: PAnsiChar; nCount: Integer;
  var lpRect: TRect; uFormat: UINT): Integer;
var
  wdStr: WideString;
  codePage: UINT;
begin
  codePage := GetACP;
  wdStr := StringToWideString(lpString,codePage);
  Result := DrawTextW(hDC,@wdStr[1],Length(wdStr),lpRect,uFormat);
end;

function IsSingleByteStr(const aStr: AnsiString): Boolean;
//Examine an ANSI string and ensure it is SingleByte (not MultiByte).
var
  sLen: Integer;
  i: Integer;
begin
  Result := False;
  sLen := Length(aStr);
  i := 0;
  while i < sLen do
  begin
    if (ByteType(aStr,i) <> mbSingleByte) then
      Exit;
    inc(i);
  end;
  Result := True;
end;

//------------------------------------------------------------------------------
function ValidHexString (Str: String): Boolean;
//Returns TRUE if Str contains 1 or more valid hexadecimal characters (spaces
//and control characters are ignored, as is a leading '$'), otherwise FALSE.
//This method is useful if the client wishes to avoid raising an EConvertError
//in a subsequent call such as StrToInt.
var
  ix: Integer;
begin
  Result := False;
  Trim(Str);//remove spaces and control chars
  if Length(Str) = 0 then
    Exit;
  ix := 1;
  //ignore leading '$' if necessary
  if (Str[1] = '$') then
  begin
    if Length(Str) = 1 then //check length again
      Exit;
    inc(ix);//skip $
  end;
  while ix <= Length(Str) do
  begin
    if not (CharInSet(Str[ix], ['0'..'9','a'..'f','A'..'F'])) then
      Exit;
    inc(ix);
  end;
  Result := True;
end;


{----------------}
initialization
 gBPrinting:= FALSE;
end.
