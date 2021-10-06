unit FeatureTable;

interface

uses
System.Classes;

type

TFragStats = class
  public
    FMatches: Integer;
    FPropMatches: Double;
    FAvgLowerDiff: Double;
    FAvgHigherDiff: Double;
end;

TNpzStats = class
  public
    FNpzMatches: Integer;
    FPropNpzMatches: Double;
    FAvgNpzDiff: Double;
end;

TIsoStats =  class
  public
    FTwoElems: Integer;
    FAvgTwoDist: Double;
    FAvgTwoAbundSep: Double;
    FThreeElems: Integer;
    FAvgThreeDist: Double;
    FAvgThreeAbundSep: Double;
end;

TFeatureTable = class
  private
    FFragSplits: TList;
    FNpzSplits: TList;
    FIsoStats: TIsoStats;
    function GetMatches(Index: Integer): Integer;
    function GetMatchProp(Index: Integer): Double;
    function GetAvgLowerDiff(Index: Integer): Double;
    function GetAvgHigherDiff(Index: Integer): Double;
    function GetNpzMatches(Index: Integer): Integer;
    function GetNpzMatchProp(Index: Integer): Double;
    function GetAvgNpzDiff(Index: Integer): Double;
    function GetTwoElems: Integer;
    function GetTwoDist: Double;
    function GetTwoAbundSep: Double;
    function GetThreeElems: Integer;
    function GetThreeDist: Double;
    function GetThreeAbundSep: Double;
    function GetNumFragSplits: Integer;
    function GetNumNpzSplits: Integer;
    procedure SetMatches(Index: Integer; Value: Integer);
    procedure SetMatchProp(Index: Integer; Value: Double);
    procedure SetAvgLowerDiff(Index: Integer; Value: Double);
    procedure SetAvgHigherDiff(Index: Integer; Value: Double);
    procedure SetNpzMatches(Index: Integer; Value: Integer);
    procedure SetNpzMatchProp(Index: Integer; Value: Double);
    procedure SetAvgNpzDiff(Index: Integer; Value: Double);
    procedure SetTwoElems(Value: Integer);
    procedure SetTwoDist(Value: Double);
    procedure SetTwoAbundSep(Value: Double);
    procedure SetThreeElems(Value: Integer);
    procedure SetThreeDist(Value: Double);
    procedure SetThreeAbundSep(Value: Double);

  public
    property Matches[Index: Integer]: Integer read GetMatches write SetMatches;
    property PropMatches[Index: Integer]: Double read GetMatchProp write SetMatchProp;
    property AvgLowerDiffs[Index: Integer]: Double read GetAvgLowerDiff write SetAvgLowerDiff;
    property AvgHigherDiffs[Index: Integer]: Double read GetAvgHigherDiff write SetAvgHigherDiff;
    property NpzMatches[Index: Integer]: Integer read GetNpzMatches write SetNpzMatches;
    property PropNpzMatches[Index: Integer]: Double read GetNpzMatchProp write SetNpzMatchProp;
    property AvgNpzDiffs[Index: Integer]: Double read GetAvgNpzDiff write SetAvgNpzDiff;
    property TwoElems: Integer read GetTwoElems write SetTwoElems;
    property AvgTwoDist: Double read GetTwoDist write SetTwoDist;
    property AvgTwoAbundSep: Double read GetTwoAbundSep write SetTwoAbundSep;
    property ThreeElems: Integer read GetThreeElems write SetThreeElems;
    property AvgThreeDist: Double read GetThreeDist write SetThreeDist;
    property AvgThreeAbundSep: Double read GetThreeAbundSep write SetThreeAbundSep;
    property NumFragSplits: Integer read getNumFragSplits;
    property NumNpzSplits: Integer read getNumNpzSplits;
    function Copy: TFeatureTable;
    constructor Create(NumFragSplits, NumNpzSplits: Integer);
    destructor Destroy; override;

end;



implementation

function TFeatureTable.GetMatches;
begin
  Result := TFragStats(FFragSplits[Index]).FMatches;
end;

function TFeatureTable.GetMatchProp;
begin
  Result := TFragStats(FFragSplits[Index]).FPropMatches;
end;

function TFeatureTable.GetAvgLowerDiff;
begin
  Result := TFragStats(FFragSplits[Index]).FAvgLowerDiff;
end;

function TFeatureTable.GetAvgHigherDiff;
begin
  Result := TFragStats(FFragSplits[Index]).FAvgHigherDiff;
end;

function TFeatureTable.GetNpzMatches;
begin
  Result := TNpzStats(FNpzSplits[Index]).FNpzMatches;
end;

function TFeatureTable.GetNpzMatchProp;
begin
  Result := TNpzStats(FNpzSplits[Index]).FPropNpzMatches;
end;

function TFeatureTable.GetAvgNpzDiff;
begin
  Result := TNpzStats(FNpzSplits[Index]).FAvgNpzDiff;
end;

function TFeatureTable.GetTwoElems: Integer;
begin
  Result := FIsoStats.FTwoElems;
end;

function TFeatureTable.GetTwoDist: Double;
begin
  Result := FIsoStats.FAvgTwoDist;
end;

function TFeatureTable.GetTwoAbundSep: Double;
begin
  Result := FIsoStats.FAvgTwoAbundSep;
end;

function TFeatureTable.GetThreeElems: Integer;
begin
  Result := FIsoStats.FThreeElems;
end;

function TFeatureTable.GetThreeDist: Double;
begin
  Result := FIsoStats.FAvgThreeDist;
end;

function TFeatureTable.GetThreeAbundSep: Double;
begin
  Result := FIsoStats.FAvgThreeAbundSep;
end;

function TFeatureTable.GetNumFragSplits: Integer;
begin
  Result := FFragSplits.Count;
end;

function TFeatureTable.GetNumNpzSplits: Integer;
begin
  Result := FNpzSplits.Count;
end;

procedure TFeatureTable.SetMatches(Index: Integer; Value: Integer);
begin
  TFragStats(FFragSplits[Index]).FMatches := Value;
end;

procedure TFeatureTable.SetMatchProp(Index: Integer; Value: Double);
begin
  TFragStats(FFragSplits[Index]).FPropMatches := Value;
end;

procedure TFeatureTable.SetAvgLowerDiff(Index: Integer; Value: Double);
begin
  TFragStats(FFragSplits[Index]).FAvgLowerDiff := Value;
end;

procedure TFeatureTable.SetAvgHigherDiff(Index: Integer; Value: Double);
begin
  TFragStats(FFragSplits[Index]).FAvgHigherDiff := Value;
end;

procedure TFeatureTable.SetNpzMatches(Index: Integer; Value: Integer);
begin
  TNpzStats(FNpzSplits[Index]).FNpzMatches := Value;
end;

procedure TFeatureTable.SetNpzMatchProp(Index: Integer; Value: Double);
begin
  TNpzStats(FNpzSplits[Index]).FPropNpzMatches := Value;
end;

procedure TFeatureTable.SetAvgNpzDiff(Index: Integer; Value: Double);
begin
  TNpzStats(FNpzSplits[Index]).FAvgNpzDiff := Value;
end;

procedure TFeatureTable.SetTwoElems(Value: Integer);
begin
  FIsoStats.FTwoElems := Value;
end;

procedure TFeatureTable.SetTwoDist(Value: Double);
begin
  FIsoStats.FAvgTwoDist := Value;
end;

procedure TFeatureTable.SetTwoAbundSep(Value: Double);
begin
  FIsoStats.FAvgTwoAbundSep := Value;
end;

procedure TFeatureTable.SetThreeElems(Value: Integer);
begin
  FIsoStats.FThreeElems := Value;
end;

procedure TFeatureTable.SetThreeDist(Value: Double);
begin
  FIsoStats.FAvgThreeDist := Value;
end;

procedure TFeatureTable.SetThreeAbundSep(Value: Double);
begin
  FIsoStats.FAvgThreeAbundSep := Value;
end;

function TFeatureTable.Copy: TFeatureTable;
var
  i, j: Integer;

begin
  Result := TFeatureTable.Create(FFragSplits.Count, FNpzSplits.Count);
  for i := 0 to Result.FFragSplits.Count - 1 do
  begin
    TFragStats(Result.FFragSplits[i]).FMatches := TFragStats(FFragSplits[i]).FMatches;
    TFragStats(Result.FFragSplits[i]).FPropMatches := TFragStats(FFragSplits[i]).FPropMatches;
    TFragStats(Result.FFragSplits[i]).FAvgLowerDiff := TFragStats(FFragSplits[i]).FAvgLowerDiff;
    TFragStats(Result.FFragSplits[i]).FAvgHigherDiff := TFragStats(FFragSplits[i]).FAvgHigherDiff;
  end;

  for i := 0 to Result.FNpzSplits.Count - 1 do
  begin
    TNpzStats(Result.FNpzSplits[i]).FNpzMatches := TNpzStats(FNpzSplits[i]).FNpzMatches;
    TNpzStats(Result.FNpzSplits[i]).FPropNpzMatches := TNpzStats(FNpzSplits[i]).FPropNpzMatches;
    TNpzStats(Result.FNpzSplits[i]).FAvgNpzDiff := TNpzStats(FNpzSplits[i]).FAvgNpzDiff;
  end;

  Result.FIsoStats := TIsoStats.Create;
  Result.FIsoStats.FTwoElems := FIsoStats.FTwoElems;
  Result.FIsoStats.FAvgTwoDist := FIsoStats.FAvgTwoDist;
  Result.FIsoStats.FAvgTwoAbundSep := FIsoStats.FAvgTwoAbundSep;
  Result.FIsoStats.FThreeElems := FIsoStats.FThreeElems;
  Result.FIsoStats.FAvgThreeDist := FIsoStats.FAvgThreeDist;
  Result.FIsoStats.FAvgThreeAbundSep := FIsoStats.FAvgThreeAbundSep;

end;

constructor TFeatureTable.Create(NumFragSplits, NumNpzSplits: Integer);
var
  i: Integer;
  fragStats: TFragStats;
  npzStats: TNpzStats;

begin
  FFragSplits := TList.Create;
  FNpzSplits := TList.Create;
  FIsoStats := TIsoStats.Create;

  for i := 0 to NumFragSplits - 1 do
  begin
    fragStats := TFragStats.Create;
    FFragSplits.Add(fragStats);
  end;

  for i := 0 to NumNpzSplits - 1 do
  begin
    npzStats := TNpzStats.Create;
    FNpzSplits.Add(npzStats);
  end;

end;

destructor TFeatureTable.Destroy;
begin
  if Assigned(FFragSplits) then
  begin
    while FFragSplits.Count > 0 do
    begin
      TFragStats(FFragSplits[FFragSplits.Count - 1]).Free;
      FFragSplits.Delete(FFragSplits.Count - 1);
    end;
  end;

  if Assigned(FNpzSplits) then
  begin
    while FNpzSplits.Count > 0 do
    begin
      TNpzStats(FNpzSplits[FNpzSplits.Count - 1]).Free;
      FNpzSplits.Delete(FNpzSplits.Count - 1);
    end;
  end;

  FFragSplits.Free;
  FNpzSplits.Free;
  FIsoStats.Free;

  inherited;
end;

end.
