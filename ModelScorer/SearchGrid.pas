unit SearchGrid;

interface

uses
System.Classes;

type

TSearchGrid = class
  private
    FSlopeAxis: Array of Double;
    FOffsetAxis: Array of Double;
    function GetSlopeValue(Index: Integer): Double;
    function GetOffsetValue(Index: Integer): Double;
    function GetSlopeIndex(Value: Double): Integer;
    function GetOffsetIndex(Value: Double): Integer;
  public
    property SlopeAxis[Index: Integer]: Double read GetSlopeValue;
    property OffsetAxis[Index: Integer]: Double read GetOffsetValue;
    property SlopeIndex[Value: Double]: Integer read GetSlopeIndex;
    property OffsetIndex[Value: Double]: Integer read GetOffsetIndex;
    constructor Create(SlopeRange, OffsetRange: Array of Double; Slopes, Offsets: Integer);
    destructor Destroy; override;
end;

implementation

function TSearchGrid.GetSlopeValue(Index: Integer): Double;
begin
  Result := FSlopeAxis[Index];
end;

function TSearchGrid.GetOffsetValue(Index: Integer): Double;
begin
  Result := FOffsetAxis[Index];
end;

function TSearchGrid.GetSlopeIndex(Value: Double): Integer;
var
  i: Integer;

begin
  for i := 0 to Length(FSlopeAxis) - 1 do
  begin
    if (FSlopeAxis[i] = Value) then
    begin
      Result := i;
    end;
  end;
  Result := -1;
end;

function TSearchGrid.GetOffsetIndex(Value: Double): Integer;
var
  i: Integer;

begin
  for i := 0 to Length(FOffsetAxis) - 1 do
  begin
    if (FOffsetAxis[i] = Value) then
    begin
      Result := i;
    end;
  end;
  Result := -1;
end;

constructor TSearchGrid.Create(SlopeRange, OffsetRange: Array of Double; Slopes, Offsets: Integer);
(*
 * Creates evenly distributed grid values along the given ranges, and provides
 * the desired number of intervals for each axis(Slopes and Offsets).
 *)

var
  i: Integer;
  length, interval, current: Double;


begin
  SetLength(FSlopeAxis, Slopes);
  SetLength(FOffsetAxis, Offsets);
  length := ABS(SlopeRange[1] - SlopeRange[0]);
  if SlopeRange[0] > SlopeRange[1] then
    interval := -length / (Slopes - 1)
  else
    interval := length / (Slopes - 1);
  current := SlopeRange[0];

  for i := 0 to Slopes - 1 do
  begin
    FSlopeAxis[i] := current;
    current := current + interval;
  end;
  length := ABS(OffsetRange[1] - OffsetRange[0]);
  if OffsetRange[0] > OffsetRange[1] then
    interval := -length / (Offsets - 1)
  else
    interval := length / (Offsets - 1);
  current := OffsetRange[0];

  for i := 0 to Offsets - 1 do
  begin
    FOffsetAxis[i] := current;
    current := current + interval;
  end;
end;

destructor TSearchGrid.Destroy;
begin
  inherited;
end;

end.
