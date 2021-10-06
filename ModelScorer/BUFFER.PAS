////////////////////////////////////////////////////////////////////////////////
//  Project: WinCadence
//  Module:  BUFFER.PAS
//
//  This unit holds the generic class TDataBuffer from which the classes
//  TLongIntBuffer, TWordBuffer and TByteBuffer derive.
//  Usage of these types instead of pointers is encouraged because
//  any module at any time can test the size of the buffer to prevent
//  pointer errors.
//
//  Copyright 1996 Physical Electronics
////////////////////////////////////////////////////////////////////////////////
unit Buffer;

////////////////////////////////////////////////////////////////////////////////
interface

uses
  SysUtils,
  Windows;

type

  EDataBufferException = class(Exception);

//------------------------------------------------------------------------------
//  TDataBuffer
//  Abstract base class for all the other buffers
//------------------------------------------------------------------------------
  TDataBuffer = class(TObject)
  private
    FData: Pointer;
    FSize: Cardinal; //in units of ItemSize bytes (ie NumBytes=FSize*ItemSize)
    FOffset: Cardinal;
    FValid: Cardinal;//in units of ItemSize bytes (ie NumBytes=FValid*ItemSize)
    //
    procedure CheckIndex(index: Cardinal);
    function  GetItemSize: Cardinal; virtual; //in units of bytes
    function  GetValid: Cardinal;
    function  GetOffset: Cardinal;
  public
    // CREATE/DESTROY
    constructor Create(size: Cardinal); virtual;
    destructor  Destroy; override;
    // COMMANDS
    procedure Clear;
    procedure Resize(size: Cardinal);
    function  Append(source: TDataBuffer; max: Cardinal): Cardinal;
    procedure Copy(source: TDataBuffer);
    procedure ExtractBinary(var binaryBuffer; bufSize: Cardinal);
    procedure InsertBinary(var binaryBuffer; bufSize: Cardinal);
    procedure ExtractAnsiString(var text: AnsiString);
    procedure InsertAnsiString(text: AnsiString);
    // PROPERTIES
    property  Size: Cardinal read FSize write Resize;
    property  ItemSize: Cardinal read GetItemSize;
    property  Valid: Cardinal read GetValid write FValid;
    property  Offset: Cardinal read GetOffset write FOffset;
  end; // TDataBuffer


//------------------------------------------------------------------------------
//  TLongIntBuffer
//------------------------------------------------------------------------------
  TLongIntBuffer = class(TDataBuffer)
  private
    function  GetData: PLongInt;
    function  GetItem(index: Cardinal): LongInt;
    procedure PutItem(index: Cardinal; value: LongInt);
    function  GetItemSize: Cardinal; override;
  public
    property  Buffer: PLongInt read GetData;
    property  Data[index: Cardinal]: LongInt read GetItem write PutItem; default;
  end; // TLongIntBuffer


//------------------------------------------------------------------------------
//  TSmallIntBuffer
//------------------------------------------------------------------------------
  PSmallInt = ^SmallInt;
  TSmallIntBuffer = class(TDataBuffer)
  private
    function  GetData: PSmallInt;
    function  GetItem(index: Cardinal): SmallInt;
    procedure PutItem(index: Cardinal; value: SmallInt);
    function  GetItemSize: Cardinal; override;
  public
    property  Buffer: PSmallInt read GetData;
    property  Data[index: Cardinal]: SmallInt read GetItem write PutItem; default;
  end; // TSmallIntBuffer


//------------------------------------------------------------------------------
//  TULongBuffer
//------------------------------------------------------------------------------
  TULongBuffer = class(TDataBuffer)
  private
    function  GetData: PULong;
    function  GetItem(index: Cardinal): ULong;
    procedure PutItem(index: Cardinal; value: ULong);
    function  GetItemSize: Cardinal; override;
  public
    property  Buffer: PULong read GetData;
    property  Data[index: Cardinal]: ULong read GetItem write PutItem; default;
  end; // TULongBuffer


//------------------------------------------------------------------------------
//  TCardinalBuffer
//------------------------------------------------------------------------------
  PCardinal = ^Cardinal;
  TCardinalBuffer = class(TDataBuffer)
  private
    function  GetData: PCardinal;
    function  GetItem(index: Cardinal): Cardinal;
    procedure PutItem(index: Cardinal; value: Cardinal);
    function  GetItemSize: Cardinal; override;
  public
    property  Buffer: PCardinal read GetData;
    property  Data[index: Cardinal]: Cardinal read GetItem write PutItem; default;
  end; // TCardinalBuffer


//------------------------------------------------------------------------------
//  TWordBuffer
//------------------------------------------------------------------------------
  TWordBuffer = class(TDataBuffer)
  private
    function  GetData: PWord;
    function  GetItem(index: Cardinal): Word;
    procedure PutItem(index: Cardinal; value: Word);
    function  GetItemSize: Cardinal; override;
  public
    property  Buffer: PWord read GetData;
    property  Data[index: Cardinal]: Word read GetItem write PutItem; default;
  end; // TWordBufferr


//------------------------------------------------------------------------------
//  TByteBuffer
//------------------------------------------------------------------------------
  TByteBuffer = class(TDataBuffer)
  private
    function  GetData: PByte;
    function  GetItem(index: Cardinal): Byte;
    procedure PutItem(index: Cardinal; value: Byte);
    function  GetItemSize: Cardinal; override;
  public
    property  Buffer: PByte read GetData;
    property  Data[index: Cardinal]: Byte read GetItem write PutItem; default;
  end; // TByteBuffer


//------------------------------------------------------------------------------
//  TDoubleBuffer
//------------------------------------------------------------------------------
  TDoubleBuffer = class(TDataBuffer)
  private
    function  GetData: PDouble;
    function  GetItem(index: Cardinal): double;
    procedure PutItem(index: Cardinal; value: double);
    function  GetItemSize: Cardinal; override;
  public    // Public declarations
    procedure SearchForMaxValue(  var MaxValue: Double;
                                  var MaxValueIndex: Integer;
                                   SearchLoIndex: Integer = 0;
                                   SearchHiIndex: Integer = 0);
    property  Buffer: PDouble read GetData;
    property  Data[index: Cardinal]: double read GetItem write PutItem; default;
  end; // TDoubleBuffer


//------------------------------------------------------------------------------
//  TSingleBuffer
//------------------------------------------------------------------------------
  TSingleBuffer = class(TDataBuffer)
  private
    function  GetData: PSingle;
    function  GetItem(index: Cardinal): Single;
    procedure PutItem(index: Cardinal; value: Single);
    function  GetItemSize: Cardinal; override;
  public    // Public declarations
    property  Buffer: PSingle read GetData;
    property  Data[index: Cardinal]: Single read GetItem write PutItem; default;
  end; // TSingleBuffer


//------------------------------------------------------------------------------
//  TDataMatrix
//------------------------------------------------------------------------------
  TDataMatrix = class(TObject)
  private
    FData: Pointer;
    FxSize: Cardinal;
    FySize: Cardinal;
    procedure CheckIndex(xIndex,yIndex: Cardinal);
    function  GetPointer(xIndex,yIndex: Cardinal): Pointer;
    function  GetItemSize: Cardinal; virtual;
  public
    // CONSTRUCTOR/DESTRUCTOR
    constructor Create(xSize,ySize: Cardinal); virtual;
    destructor  Destroy; override;
    // DATA
    procedure Clear;
    procedure Resize(xSize: Cardinal; ySize: Cardinal); virtual;
    // PROPERTIES
    property  xSize: Cardinal read FxSize;
    property  ySize: Cardinal read FySize;
    property  ItemSize: Cardinal read GetItemSize;
  end; // TDataMatrix


//------------------------------------------------------------------------------
//  TDoubleMatrix
//------------------------------------------------------------------------------
  TDoubleMatrix = class(TDataMatrix)
  private
    function  GetData: PDouble;
    function  GetItem(xIndex,yIndex: Cardinal): double;
    procedure PutItem(xIndex,yIndex: Cardinal; value: double);
    function  GetItemSize: cardinal; override;
  public
    property  Buffer: PDouble read GetData;
    property  Data[x,y: Cardinal]: double read GetItem write PutItem; default;
  end; // TDoubleMatrix


////////////////////////////////////////////////////////////////////////////////
implementation


////////////////////////////////////////////////////////////////////////////////
//  TDATABUFFER
////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
//  CREATE
//------------------------------------------------------------------------------
constructor TDataBuffer.Create(size: Cardinal);
begin
  inherited Create;
  FData:=nil;
  Resize(size);
  FSize:=size;
  FValid:=0;
  FOffset:=0;
end;


//------------------------------------------------------------------------------
//  DESTROY
//------------------------------------------------------------------------------
destructor TDataBuffer.Destroy;
begin
  Resize(0);
  inherited Destroy;
end;


//------------------------------------------------------------------------------
//  GETITEMSIZE
//------------------------------------------------------------------------------
function TDataBuffer.GetItemSize: Cardinal;
begin
  raise EDataBufferException.Create(Classname+'GetItemSize: Abstract class');
end;


//------------------------------------------------------------------------------
//  GETVALID
//------------------------------------------------------------------------------
function TDataBuffer.GetValid: Cardinal;
begin
  if (FValid>FSize) then FValid:=FSize;
  Result:=FValid;
end;


//------------------------------------------------------------------------------
//  GETOFFSET
//------------------------------------------------------------------------------
function TDataBuffer.GetOffset: Cardinal;
begin
  if (FOffset>FValid) then FOffset:=FValid;
  Result:=FOffset;
end;


//------------------------------------------------------------------------------
//  RESIZE
//------------------------------------------------------------------------------
procedure TDataBuffer.Resize(size: Cardinal);
begin
  if (size=FSize) then Exit;
  ReAllocMem(FData, size*ItemSize);
  FSize:=size;
end;


//------------------------------------------------------------------------------
//  CHECKINDEX
//------------------------------------------------------------------------------
procedure TDataBuffer.CheckIndex(index: Cardinal);
begin
  if (index>=FSize) then
    raise EDataBufferException.Create(Classname+'CheckIndex: Out of range');
end;


//------------------------------------------------------------------------------
//  CLEAR
//------------------------------------------------------------------------------
procedure TDataBuffer.Clear;
begin
  if Assigned(FData) then begin
    FillChar(FData^, FSize*ItemSize, 0);
  end;
  FOffset:=0;
  FValid:=0;
end;


//------------------------------------------------------------------------------
//  INSERTBINARY
//  Inserts data from a buffer at the current valid boundary.
//  Increases valid afterwards
//------------------------------------------------------------------------------
procedure TDataBuffer.InsertBinary(var binaryBuffer; bufSize: Cardinal);
var
  bufItems: Cardinal;
  ptr: PByte;
begin
  if ((bufSize mod ItemSize)<>0) then
    raise EDataBufferException.Create(Classname+'.InsertBinary: Item size mismatch');
  bufItems:=bufSize div ItemSize;
  if (bufItems+Valid>Size) then
    raise EDataBufferException.Create(Classname+'.InsertBinary: Overflow');
  ptr := FData;
  inc(ptr,Valid);
  Move(binaryBuffer, ptr^, bufSize);
  Inc(FValid, bufItems);
end;


//------------------------------------------------------------------------------
//  EXTRACTBINARY
//------------------------------------------------------------------------------
procedure TDataBuffer.ExtractBinary(var binaryBuffer; bufSize: Cardinal);
var
  bufItems: Cardinal;
  ptr: PByte;
begin
  if ((bufSize mod ItemSize)<>0) then
    raise EDataBufferException.Create(Classname+'.ExtractBinary: Item size mismatch');
  bufItems:=bufSize div ItemSize;
  if (Offset>bufItems+Valid) then
    raise EDataBufferException.Create(Classname+'.ExtractBinary: Overflow');
  ptr := FData;
  inc(ptr,Offset);
  Move(ptr^, binaryBuffer, bufSize);    //
  Inc(FOffset, bufItems);
end;


//------------------------------------------------------------------------------
//  INSERTSTRING
//------------------------------------------------------------------------------
procedure TDataBuffer.InsertAnsiString(text: AnsiString);
var
  bufItems: Cardinal;
  ptr: PByte;
begin
  if (ItemSize<>1) then
    raise EDataBufferException.Create(Classname+'.InsertString: Item size mismatch');
  bufItems:=Length(text)+1;
  if (bufItems+Valid>Size) then
    raise EDataBufferException.Create(Classname+'.InsertString: Overflow');
  ptr := FData;
  inc(ptr,Valid);
  Move(PAnsiChar(text)^, ptr^, bufItems);
  Inc(FValid, bufItems);
end;


//------------------------------------------------------------------------------
//  EXTRACTSTRING
//------------------------------------------------------------------------------
procedure TDataBuffer.ExtractAnsiString(var text: AnsiString);
var
  ptr: PAnsiChar;
  bytePtr: PByte;
  textLength: Cardinal;
begin
  if (ItemSize<>1) then
    raise EDataBufferException.Create(Classname+'.ExtractString: Item size mismatch');
  bytePtr := FData;
  inc(bytePtr,Offset);
  ptr := PAnsiChar(bytePtr);
  textLength:=StrLen(ptr)+1;           // Get text length
  if (textLength>Valid-Offset) then    // Check length (\0 pos) against buffer size
    raise EDataBufferException.Create(Classname+'.ExtractString: Overflow');
  text:=StrPas(ptr);                   // Copy characters into dest string
  Inc(FOffset, textLength);            // Increment buffer offset
end;


//------------------------------------------------------------------------------
//  APPEND
//  Appends the data from source.Buffer+source.Offset to Buffer+Valid, but
//  'max' items at the most
//
//  RETURNS
//    Number of items copied
//------------------------------------------------------------------------------
function TDataBuffer.Append(source: TDataBuffer; max: Cardinal): Cardinal;
var
  pSource,pDest: Pointer;
  toCopy: Cardinal;
  bytePtr: PByte;
begin
  if (source.ItemSize<>ItemSize) then
    raise EDataBufferException.Create(Classname+'.Append: Incompatible buffers');
  if (source.Valid-source.Offset+Valid>max) then begin
    toCopy:=max;
  end else begin
    toCopy:=source.Valid-source.Offset;
  end;
  if (toCopy>Size-Valid) then
    raise EDataBufferException.Create(Classname+'.Append: Overflow');
  bytePtr := FData;
  inc(bytePtr,source.Offset*source.ItemSize);
  pSource := bytePtr;
  bytePtr := FData;
  inc(bytePtr,Valid*ItemSize);
  pDest := bytePtr;
  Move(pSource^, pDest^, toCopy*ItemSize);
  Valid:=Valid+toCopy;
  source.Offset:=source.Offset+toCopy;
  Result:=toCopy;
end;


//------------------------------------------------------------------------------
//  COPY
//  Copies the data from source.Buffer to Buffer up to the valid flag.
//  Resizes the buffer if necessary to 'valid' and copies the 'valid'
//  info. Resets the offset.
//------------------------------------------------------------------------------
procedure TDataBuffer.Copy(source: TDataBuffer);
begin
  if (source.ItemSize<>ItemSize) then
    raise EDataBufferException.Create(Classname+'.Append: Incompatible buffers');
  if (source.Valid>Size) then Resize(source.Valid);
  Move(source.FData^, FData^, source.Valid);
  FValid:=source.Valid;
  FOffset:=0;
end;


////////////////////////////////////////////////////////////////////////////////
//  TLongIntBuffer
////////////////////////////////////////////////////////////////////////////////

function TLongIntBuffer.GetItemSize: Cardinal;
begin
  Result:=sizeof(LongInt);
end;

function TLongIntBuffer.GetData: PLongInt;
begin
   GetData:=FData;
end;

function TLongIntBuffer.GetItem(index: Cardinal): LongInt;
var
  longIntPtr: PLongInt;
begin
  checkIndex(Index);
  longIntPtr := FData;
  inc(longIntPtr,index);
  GetItem := longIntPtr^;
end;

procedure TLongIntBuffer.PutItem(index: Cardinal; value: LongInt);
var
  longIntPtr: PLongInt;
begin
  checkIndex(Index);
  longIntPtr := FData;
  inc(longIntPtr,index);
  longIntPtr^ := value;
end;


/////////////////  TSmallIntBuffer  /////////////////////////////////////////////

function TSmallIntBuffer.GetItemSize: Cardinal;
begin
  Result:=sizeof(SmallInt);
end;

function TSmallIntBuffer.GetData: PSmallInt;
begin
   GetData:=FData;
end;

function TSmallIntBuffer.GetItem(index: Cardinal): SmallInt;
var
  smallIntPtr: PSmallInt;
begin
  checkIndex(Index);
  smallIntPtr := FData;
  inc(smallIntPtr,index);
  GetItem := smallIntPtr^;
end;

procedure TSmallIntBuffer.PutItem(index: Cardinal; value: SmallInt);
var
  smallIntPtr: PSmallInt;
begin
  checkIndex(Index);
  smallIntPtr := FData;
  inc(smallIntPtr,index);
  smallIntPtr^ := value;
end;


/////////////////  TULongBuffer  ///////////////////////////////////////////////

function TULongBuffer.GetItemSize: Cardinal;
begin
  Result:=sizeof(ULong);
end;

function TULongBuffer.GetData: PULong;
begin
   GetData:=FData;
end;

function TULongBuffer.GetItem(index: Cardinal): ULong;
var
  ulongPtr: PULong;
begin
  checkIndex(Index);
  ulongPtr := FData;
  inc(ulongPtr,index);
  GetItem := ulongPtr^;
end;

procedure TULongBuffer.PutItem(index: Cardinal; value: ULong);
var
  ulongPtr: PULong;
begin
  checkIndex(Index);
  ulongPtr := FData;
  inc(ulongPtr,index);
  ulongPtr^ := value;
end;


/////////////////  TCardinalBuffer  ///////////////////////////////////////////////

function TCardinalBuffer.GetItemSize: Cardinal;
begin
  Result:=sizeof(Cardinal);
end;

function TCardinalBuffer.GetData: PCardinal;
begin
   GetData:=FData;
end;

function TCardinalBuffer.GetItem(index: Cardinal): Cardinal;
var
  cardPtr: PCardinal;
begin
  checkIndex(Index);
  cardPtr := FData;
  inc(cardPtr,index);
  GetItem := cardPtr^;
end;

procedure TCardinalBuffer.PutItem(index: Cardinal; value: Cardinal);
var
  cardPtr: PCardinal;
begin
  checkIndex(Index);
  cardPtr := FData;
  inc(cardPtr,index);
  cardPtr^ := value;
end;


/////////////////  TWordBuffer  ////////////////////////////////////////////////

function TWordBuffer.GetItemSize: Cardinal;
begin
  Result:=sizeof(Word);
end;

function TWordBuffer.GetData: PWord;
begin
   GetData:=FData;
end;

function TWordBuffer.GetItem(index: Cardinal): Word;
var
  wordPtr: PWord;
begin
  checkIndex(Index);
  wordPtr := FData;
  inc(wordPtr,index);
  GetItem := wordPtr^;
end;

procedure TWordBuffer.PutItem(index: Cardinal; value: Word);
var
  wordPtr: PWord;
begin
  checkIndex(index);
  wordPtr := FData;
  inc(wordPtr,index);
  wordPtr^ := value;
end;


////////////////////  TByteBuffer  /////////////////////////////////////////////

function TByteBuffer.GetItemSize: Cardinal;
begin
  Result:=sizeof(Byte);
end;

function TByteBuffer.GetData: PByte;
begin
   GetData:=FData;
end;

function TByteBuffer.GetItem(index: Cardinal): Byte;
var
  bytePtr: PByte;
begin
  checkIndex(Index);
  bytePtr := FData;
  inc(bytePtr,index);
  GetItem := bytePtr^;
end;

procedure TByteBuffer.PutItem(index: Cardinal; value: Byte);
var
  bytePtr: PByte;
begin
  checkIndex(Index);
  bytePtr := FData;
  inc(bytePtr,index);
  bytePtr^ := value;
end;


////////////////////  TDoubleBuffer  ///////////////////////////////////////////

function TDoubleBuffer.GetItemSize: Cardinal;
begin
  Result:=sizeof(Double);
end;

function TDoubleBuffer.GetData: PDouble;
begin
   GetData:=FData;
end;

function TDoubleBuffer.GetItem(index: Cardinal): double;
var
  doublePtr: PDouble;
begin
  checkIndex(Index);
  doublePtr := FData;
  inc(doublePtr,index);
  GetItem := doublePtr^;
end;

procedure TDoubleBuffer.PutItem(index: Cardinal; value: double);
var
  doublePtr: PDouble;
begin
  checkIndex(Index);
  doublePtr := FData;
  inc(doublePtr,index);
  doublePtr^ := value;
end;

procedure TDoubleBuffer.SearchForMaxValue(
                              var MaxValue: Double;
                              var MaxValueIndex: Integer;
                               SearchLoIndex: Integer;
                               SearchHiIndex: Integer);
{Helper method finds MaxValue and MaxValueIndex using an optional search range.
Inputs:
   SearchLoIndex,SearchHiIndex - Optional limits used when searching for MaxValue - default=0 indicates search entire buffer
Outputs:
   MaxValue - the max value found within the search range
   MaxValueIndex - the index into the DoubleBuffer within the search range that holds the max value
}
var
  loSearchIx: Integer;
  hiSearchIx: Integer;
  j: Integer;
begin
  //Set upper and lower search range
  loSearchIx := 0; //Init search lower limit
  if (SearchLoIndex > 0) and (SearchLoIndex < Size) then //if SearchLoIndex is specified and valid
    loSearchIx := SearchLoIndex; //Override search lower limit
  hiSearchIx := Size-1; //Init search upper limit
  if (SearchHiIndex > LoSearchIx)   and (SearchHiIndex < hiSearchIx) then //if SearchHiIndex is specified and valid
    hiSearchIx := SearchHiIndex; //Override search upper limit

  //Prepare to search the values
  MaxValueIndex := loSearchIx; //Init the MaxValueIndex
  MaxValue := -1e238; //Arbitrary small number

  //Search for MaxValue
  for j:= loSearchIx to hiSearchIx do
  begin
    if (MaxValue < Data[j]) then
    begin //Update MaxValue if necessary
        MaxValueIndex := j;
        MaxValue := Data[j];
    end;
  end;
end;


////////////////////  TSingleBuffer  ///////////////////////////////////////////

function TSingleBuffer.GetItemSize: Cardinal;
begin
  Result:=sizeof(Single);
end;

function TSingleBuffer.GetData: PSingle;
begin
   GetData:=FData;
end;

function TSingleBuffer.GetItem(index: Cardinal): Single;
var
  singlePtr: PSingle;
begin
  checkIndex(Index);
  singlePtr := FData;
  inc(singlePtr,index);
  GetItem := singlePtr^;
end;

procedure TSingleBuffer.PutItem(index: Cardinal; value: Single);
var
  singlePtr: PSingle;
begin
  checkIndex(Index);
  singlePtr := FData;
  inc(singlePtr,index);
  singlePtr^ := value;
end;


/////////////////  TDataMatrix  ////////////////////////////////////////////////

constructor TDataMatrix.Create(xSize,ySize: Cardinal);
begin
  inherited Create;
  FData:=nil;
  Resize(xSize, ySize);
end;

destructor TDataMatrix.Destroy;
begin
  Resize(0, 0);
  inherited Destroy;
end;

function TDataMatrix.GetItemSize: Cardinal;
begin
  raise EDataBufferException.Create(Classname+'GetItemSize: Abstract class');
end;

procedure TDataMatrix.Resize(xSize,ySize: Cardinal);
begin
  if (xSize<>FxSize) or (ySize<>FySize) then begin
    ReAllocMem(FData, xSize*ySize*ItemSize);
    FxSize:=xSize;
    FySize:=ySize;
  end;
  if FxSize*FySize=0 then FData:=nil;
end;

procedure TDataMatrix.CheckIndex(xIndex,yIndex: Cardinal);
begin
  if (xIndex>=FxSize) then begin
    raise EDataBufferException.Create(Classname+'CheckIndex: Out of range');
  end;
  if (yIndex>=FySize) then begin
    raise EDataBufferException.Create(Classname+'CheckIndex: Out of range');
  end;
end;

procedure TDataMatrix.Clear;
var
  p: ^byte;
  i: Cardinal;
begin
  p:=FData;
  for i:=0 to FxSize*FySize*ItemSize-1 do begin
    p^:=0;
    inc(p);
  end;
end;

function TDataMatrix.GetPointer(xIndex,yIndex: Cardinal): Pointer;
var
  bytePtr: PByte;
begin
  checkIndex(xIndex, yIndex);
  bytePtr := FData;
  inc(bytePtr,xIndex*ItemSize+yIndex*ItemSize*FxSize);
  Result := bytePtr;
end;


/////////////////  TDoubleMatrix  //////////////////////////////////////////////

function TDoubleMatrix.GetItemSize: cardinal;
begin
  Result:=sizeof(double);
end;

function TDoubleMatrix.GetItem(xIndex,yIndex: Cardinal): double;
begin
  Result:=PDouble(GetPointer(xIndex, yIndex))^;
end;

procedure TDoubleMatrix.PutItem(xIndex,yIndex: Cardinal; value: double);
begin
  PDouble(GetPointer(xIndex, yIndex))^:=value;
end;

function TDoubleMatrix.GetData: PDouble;
begin
  Result:=FData;
end;


////////////////////////////////////////////////////////////////////////////////
end.
