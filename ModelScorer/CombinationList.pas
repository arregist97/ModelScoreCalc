unit CombinationList;

interface

uses
CandidateFinder,
System.Classes;

type

TComb = class
  public
    FMatches: TList;
    function Copy: TComb;
    constructor Create;
    destructor Destroy; override;
end;

TCombinationList = class
  private
    FCombs: TList;
    function IterateCombs(Candidate: TCandidate; Curr: Integer): TList;
    function getSize: Integer;
    function Copy(Index: Integer): TComb;
    function SimpleCopy(Index: Integer): TComb;
  public
    property Size: Integer read getSize;
    property Combinations[Index: Integer]: TComb read Copy;//Client responsible for deallocation
    property SimplifiedCombinations[Index: Integer]: TComb read SimpleCopy;//Client responsible for deallocation
    constructor Create(Candidate: TCandidate);
    destructor Destroy; override;
end;

implementation

function TComb.Copy: TComb;
var
  i: Integer;
  oldMatch, newMatch: TIsoMatch;

begin
  Result := TComb.Create;
  for i := 0 to FMatches.Count - 1 do
  begin
    oldMatch := TIsoMatch(FMatches[i]);
    newMatch := TIsoMatch.Create;
    newMatch.FPeakIndex := oldMatch.FPeakIndex;
    newMatch.FDistance := oldMatch.FDistance;
    Result.FMatches.Add(newMatch);
  end;
end;

constructor TComb.Create;
begin
  FMatches := TList.Create;
end;

destructor TComb.Destroy;
begin
  if Assigned(FMatches) then
  begin
    while FMatches.Count > 0 do
    begin
      TIsoMatch(FMatches[FMatches.Count - 1]).Free;
      FMatches.Delete(FMatches.Count - 1);
    end;


    FMatches.Free;
  end;
  inherited;
end;

function TCombinationList.IterateCombs(Candidate: TCandidate; Curr: Integer): TList;
var
  i, j: Integer;
  comb: TComb;
  combs: TList;
  tempIsoMatch, newIsoMatch: TIsoMatch;

begin
  Result := TList.Create;
  if Curr = Candidate.NumIsos - 1 then
  begin
    for i := 0 to Candidate.IsoMatches[Curr].Count - 1 do
    begin
      comb := TComb.Create;
      tempIsoMatch := TIsoMatch(Candidate.IsoMatches[Curr][i]);
      newIsoMatch := TIsoMatch.Create;
      newIsoMatch.FPeakIndex := tempIsoMatch.FPeakIndex;
      newIsoMatch.FDistance := tempIsoMatch.FDistance;
      comb.FMatches.Add(newIsoMatch);
      Result.Add(comb);
    end;
  end
  else
  begin
    for i := 0 to Candidate.IsoMatches[Curr].Count - 1 do
    begin
      combs := IterateCombs(Candidate, Curr + 1);
      for j := 0 to combs.Count - 1 do
      begin
        tempIsoMatch := TIsoMatch(Candidate.IsoMatches[Curr][i]);
        newIsoMatch := TIsoMatch.Create;
        newIsoMatch.FPeakIndex := tempIsoMatch.FPeakIndex;
        newIsoMatch.FDistance := tempIsoMatch.FDistance;
        TComb(combs[j]).FMatches.Insert(0, newIsoMatch);
        Result.Add(TComb(combs[j]));
      end;
    end;
  end;

end;

function TCombinationList.getSize: Integer;
begin
  Result := FCombs.Count;
end;

function TCombinationList.Copy(Index: Integer): TComb;
var
  i: Integer;
  oldMatch, newMatch: TIsoMatch;


begin
  Result := TComb.Create;
  for i := 0 to TComb(FCombs[Index]).FMatches.Count - 1 do
  begin
    oldMatch := (TComb(FCombs[Index]).FMatches[i]);
    newMatch := TIsoMatch.Create;
    newMatch.FPeakIndex := oldMatch.FPeakIndex;
    newMatch.FDistance := oldMatch.FDistance;
    Result.FMatches.Add(newMatch);
  end;
end;

function TCombinationList.SimpleCopy(Index: Integer): TComb;
var
  i: Integer;
  oldMatch, newMatch: TIsoMatch;


begin
  Result := TComb.Create;
  for i := 0 to TComb(FCombs[Index]).FMatches.Count - 1 do
  begin
    oldMatch := (TComb(FCombs[Index]).FMatches[i]);
    if oldMatch.FPeakIndex <> -1 then
    begin
      newMatch := TIsoMatch.Create;
      newMatch.FPeakIndex := oldMatch.FPeakIndex;
      newMatch.FDistance := oldMatch.FDistance;
      Result.FMatches.Add(newMatch);
    end;
  end;
end;

constructor TCombinationList.Create(Candidate: TCandidate);
var
  i, j: Integer;
  localList: TList;
  k: Integer;
  comb: TComb;

begin
  FCombs := IterateCombs(Candidate, 0);

end;


destructor TCombinationList.Destroy;
begin
  if Assigned(FCombs) then
  begin
    while FCombs.Count > 0 do
    begin
      TComb(FCombs[FCombs.Count - 1]).Free;
      FCombs.Delete(FCombs.Count - 1);
    end;


    FCombs.Free;
  end;
  inherited;
end;

end.
