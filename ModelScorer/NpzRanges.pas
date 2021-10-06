unit NpzRanges;

interface

uses
CoreUtility,
FileRoutines,
System.Classes,
System.SysUtils;

type

TRange = class
  public
    FLow: Double;
    FHigh: Double;
end;

TNpzRanges = class
  private
    FRanges: TList;
    function GetRange(Index: Integer): TRange;
    function GetSize: Integer;
  public
    property Ranges[Index: Integer]: TRange read GetRange;
    property Size: Integer read GetSize;
    constructor Create(Loc: String);
    destructor Destroy; override;
end;


implementation

function TNpzRanges.GetRange(Index: Integer): TRange;
begin
  Result := TRange(FRanges[Index]);
end;

function TNpzRanges.GetSize;
begin
  Result := FRanges.Count;
end;

constructor TNpzRanges.Create(Loc: String);
var
  ascSpecFile: Integer;
  lineStr: WideString;
  rangeStr: String;
  range: TRange;
  firstLine: Boolean;
begin
  FRanges := TList.Create();
  firstLine := True;
  ascSpecFile:= FileOpen(Loc, fmOpenRead);
  repeat
    lineStr:= ReadHeaderLine(ascSpecFile);
    if (lineStr <> '') then
    begin
      if firstLine then
      begin
        firstLine := False;
      end
      else
      begin
        range := TRange.Create;
        rangeStr := Item(lineStr,',',1);
        range.FLow :=  StrToFloat(RemoveString(RemoveString(rangeStr, '['), '"'));
        rangeStr := Item(lineStr, ',',2);
        range.FHigh := StrToFloat(RemoveString(RemoveString(rangeStr, ']'), '"'));
        FRanges.Add(range);
      end;

    end;
  until (lineStr = '');
  FileClose(ascSpecFile);
end;

destructor TNpzRanges.Destroy;
begin

  if Assigned(FRanges) then
  begin
    while FRanges.Count > 0 do
    begin
      TRange(FRanges[FRanges.Count - 1]).Free;
      FRanges.Delete(FRanges.Count - 1);
    end;


    FRanges.Free;
  end;

  inherited;
end;

end.
