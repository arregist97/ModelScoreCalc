unit FragmentTable;

interface

uses
CoreUtility,
FileRoutines,
System.Classes,
System.SysUtils;

type

TRow = class
  public
    FMass: Double;
    FSpeciesStr: String;
    FIsotopeStr: String;
    FCeaStr: String;
    constructor Create(Mass: Double; Species, Isotope, Cea: String);
end;

TFragmentTable = class
  private
    FRows: TList;
    FSize: Integer;
    function GetSize: Integer;
    function GetMass(Index: Integer): Double;
    function GetSpecies(Index: Integer): String;
    function GetIsotope(Index: Integer): String;
    function GetCea(Index: Integer): String;
    function GetMax: Double;
  public
    property Size: Integer read GetSize;
    property Masses[Index: Integer]: Double read GetMass;
    property Species[Index: Integer]: String read GetSpecies;
    property Isotopes[Index: Integer]: String read GetIsotope;
    property Ceas[Index: Integer]: String read GetCea;
    property Max: Double read GetMax;
    constructor Create(Loc: String);
    destructor Destroy; override;
end;

implementation

constructor TRow.Create(Mass: Double; Species, Isotope, Cea: String);

begin
  FMass := Mass;
  FSpeciesStr := Species;
  FIsotopeStr := Isotope;
  FCeaStr := Cea;
end;

function TFragmentTable.GetSize;
begin
  Result := FRows.Count;
end;

function TFragmentTable.GetMass(Index: Integer): Double;
begin
  Result := TRow(FRows[index]).FMass;
end;

function TFragmentTable.GetSpecies(Index: Integer): String;
begin
  Result := TRow(FRows[index]).FSpeciesStr;
end;

function TFragmentTable.GetIsotope(Index: Integer): String;
begin
  Result := TRow(FRows[index]).FIsotopeStr;
end;

function TFragmentTable.GetCea(Index: Integer): String;
begin
  Result := TRow(FRows[index]).FCeaStr;
end;

function TFragmentTable.GetMax: Double;
var
i: Integer;
max: Double;

begin
  max := -1;
  for i := 0 to FRows.Count - 1 do
  begin
    if TRow(FRows[i]).FMass >= max then
    begin
      max := TRow(FRows[i]).FMass
    end;
  end;
  Result := max;
end;

constructor TFragmentTable.Create(Loc: String);
(*
 * Read in fragment table and return the fragment masses.
 *)

var
  mass: Double;
  massStr, speciesStr, isotopeStr, ceaStr: String;
  ascSpecFile: Integer;
  lineStr: WideString;
  row: TRow;


begin
  FRows := TList.Create;
  ascSpecFile:= FileOpen(Loc, fmOpenRead);
  repeat
    lineStr:= ReadHeaderLine(ascSpecFile);
    if (lineStr <> '') then
    begin
      massStr:= Item(lineStr,',',0);
      speciesStr := Item(lineStr,',',1);
      isotopeStr := Item(lineStr,',',2);
      ceaStr := Item(lineStr,',',3);
      massStr := RemoveString(massStr, '"');
      speciesStr := RemoveString(speciesStr, '"');
      isotopeStr := RemoveString(isotopeStr, '"');
      mass := StrToFloat(massStr);
      row := TRow.Create(mass, speciesStr, isotopeStr, ceaStr);
      FRows.add(row);

    end;
  until (lineStr = '');
  FileClose(ascSpecFile);

end;

destructor TFragmentTable.Destroy;
begin

  if Assigned(FRows) then
  begin
    while FRows.Count > 0 do
    begin
      TRow(FRows[FRows.Count - 1]).Free;
      FRows.Delete(FRows.Count - 1);
    end;


    FRows.Free;
  end;

  inherited;
end;

end.
