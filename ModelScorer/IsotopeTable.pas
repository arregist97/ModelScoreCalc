unit IsotopeTable;

interface
uses
CoreUtility,
FileRoutines,
System.Classes,
System.SysUtils;

type

TIsotope = class
  public
    FSpot: Double;
    FFreq: Double;
end;

TIsoRow = class
  public
    FElement: String;
    FIsotopes: TList;
    procedure Place(iso: TIsotope);
    constructor Create(Name: String);
    destructor Destroy; override;
end;

TIsotopeTable = class
  private
    FRows: TList;
    function GetIsos(EIndex, IIndex: Integer): Double;
    function GetAbunds(EIndex, IIndex: Integer): Double;
    function GetNumIsos(Index: Integer): Integer;
    function GetSize: Integer;
    function GetElement(Index: Integer): String;
  public
    property Element[Index: Integer]: String read GetElement;
    property Size: Integer read GetSize;
    property NumIsos[Index: Integer]: Integer read GetNumIsos;
    property Isotopes[EIndex, IIndex: Integer]: Double read GetIsos;
    property Abundances[EIndex, IIndex: Integer]: Double read GetAbunds;
    constructor Create(loc: String);
    destructor Destroy; override;
end;

implementation

procedure TIsoRow.Place(iso: TIsotope);
var
  i: Integer;
  placed: Boolean;

begin
  i := 0;
  placed := False;
  if FIsotopes.Count = 0 then
  begin
    FIsotopes.Add(iso);
    placed := True;
  end;
  while not placed do
  begin
    if iso.FFreq >= TIsotope(FIsotopes[i]).FFreq then
    begin
      FIsotopes.Insert(i, iso);
      placed := True;
    end
    else
    begin
      if i = FIsotopes.Count - 1 then
      begin
        FIsotopes.Add(iso);
        placed := True;
      end;

    end;

    Inc(i);

  end;

end;

constructor TIsoRow.Create(Name: String);

begin
  FIsotopes := TList.Create;
  FElement := Name;
end;

destructor TIsoRow.Destroy;
begin
  if Assigned(FIsotopes) then
  begin
    while FIsotopes.Count > 0 do
    begin
      TIsotope(FIsotopes[FIsotopes.Count - 1]).Free;
      FIsotopes.Delete(FIsotopes.Count - 1);
    end;
  end;

  FIsotopes.Free;
  inherited;
end;

function TIsotopeTable.GetIsos(EIndex: Integer; IIndex: Integer): Double;
begin
  Result := TIsotope(TIsoRow(FRows[EIndex]).FIsotopes[IIndex]).FSpot;
end;

function TIsotopeTable.GetAbunds(EIndex: Integer; IIndex: Integer): Double;
begin
  Result := TIsotope(TIsoRow(FRows[EIndex]).FIsotopes[IIndex]).FFreq;
end;

function TIsotopeTable.GetNumIsos(Index: Integer): Integer;
begin
  Result := TIsoRow(FRows[Index]).FIsotopes.Count;
end;

function TIsotopeTable.GetSize: Integer;
begin
  Result := FRows.Count;
end;

function TIsotopeTable.GetElement(Index: Integer): String;
begin
  Result := TIsoRow(FRows[Index]).FElement;
end;

constructor TIsotopeTable.Create(loc: String);
var
  ascSpecFile, i: Integer;
  lineStr: WideString;
  pair, spotStr, freqStr, name: String;
  spot, freq: Double;
  row: TIsoRow;
  iso: TIsotope;
  done: Boolean;



begin
  ascSpecFile:= FileOpen(Loc, fmOpenRead);
  FRows := TList.Create();
  repeat
    lineStr:= ReadHeaderLine(ascSpecFile);
    if (lineStr <> '') then
    begin
      name := Item(lineStr,' ', 2);
      row := TIsoRow.Create(name);
      i := 1;
      done := False;
      while not(done) do
      begin
        pair := Item(lineStr,'(', i);
        Inc(i);
        if pair = '' then
          done := True
        else
        begin
          spotStr := Item(pair,',', 0);
          freqStr := Item(Item(pair,',', 1), ')', 0);
          spot := StrToFloat(spotStr);
          freq := StrToFloat(freqStr);
          if freq > 0 then
          begin
            iso := TIsotope.Create;
            iso.FSpot := spot;
            iso.FFreq := freq;
            row.Place(iso);
          end;

        end;


      end;

      if row.FIsotopes.Count >= 2 then
      begin
        FRows.Add(row);
      end
      else
      begin
        row.Free;
      end;

    end;
  until (lineStr = '');
  FileClose(ascSpecFile);


end;

destructor TIsotopeTable.Destroy;
begin
    if Assigned(FRows) then
  begin
    while FRows.Count > 0 do
    begin
      TIsoRow(FRows[FRows.Count - 1]).Free;
      FRows.Delete(FRows.Count - 1);
    end;
  end;

  FRows.Free;
  inherited;
end;

end.
