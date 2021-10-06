unit CandidateFinder;

interface
uses
IsotopeTable,
MassSpectrum,
System.Classes,
System.SysUtils;

const
  c_AssumeMissingThresh = 0.002;

type

TIsoMatch = class
  public
    FPeakIndex: Integer;
    FDistance: Double;
end;

TIso = class
  public
    FIsoMatches: TList;
    constructor Create;
    destructor Destroy; override;
end;

TCandidate = class
  private
    FThreshMercy: Boolean;
    FIsoMercy: Boolean;
    FKey: String;
    FIsos: TList;
    function getNumIsos: Integer;
    function getIsoMatches(Index: Integer): TList;
    function getKey: String;
  public
    property Key: String read getKey;
    property NumIsos: Integer read getNumIsos;
    property IsoMatches[Index: Integer]: TList read GetIsoMatches;
    constructor Create;
    destructor Destroy; override;
end;

TCandidateFinder = class
  private
    FCandidates: TList;
    function GetSize: Integer;
    function GetCandidate(Index: Integer): TCandidate;
  public
    property Candidates[Index: Integer]: TCandidate read GetCandidate;//Client responsible for deallocation
    property Size: Integer read GetSize;
    constructor Create(Isos: TIsotopeTable; Peaks: TMassSpectrum; Thresh: Double);
    destructor Destroy; override;
end;

implementation

constructor TIso.Create;
begin
  FIsoMatches := TList.Create;
end;

destructor TIso.Destroy;
begin
  if Assigned(FIsoMatches) then
  begin
    while FIsoMatches.Count > 0 do
    begin
      TIsoMatch(FIsoMatches[FIsoMatches.Count - 1]).Free;
      FIsoMatches.Delete(FIsoMatches.Count - 1);
    end;


    FIsoMatches.Free;
  end;

  inherited;
end;

function TCandidate.getNumIsos: Integer;
begin
  Result := FIsos.Count;
end;

function TCandidate.getIsoMatches(Index: Integer): TList;
var
  i: Integer;

begin
  Result := TList.Create;
  for i := 0 to TIso(FIsos[Index]).FIsoMatches.Count - 1 do
  begin
    Result.Add(TIsoMatch(TIso(FIsos[Index]).FIsoMatches[i]));
  end;

end;

function TCandidate.getKey: String;
begin
  Result := FKey;
end;

constructor TCandidate.Create;
begin
  FIsos := TList.Create;
  FThreshMercy := False;
  FIsoMercy := False;
end;

destructor TCandidate.Destroy;
begin
  if Assigned(FIsos) then
  begin
    while FIsos.Count > 0 do
    begin
      TIso(FIsos[FIsos.Count - 1]).Free;
      FIsos.Delete(FIsos.Count - 1);
    end;


    FIsos.Free;
  end;

  inherited;
end;

function TCandidateFinder.GetSize:Integer;
begin
  Result := FCandidates.Count;
end;

function TCandidateFinder.GetCandidate(Index: Integer): TCandidate;
var
  i, j: Integer;
  oldIso, newIso: TIso;
  oldIsoMatch, newIsoMatch: TIsoMatch;

begin
  Result := TCandidate.Create;
  Result.FKey := TCandidate(FCandidates[Index]).FKey;
  Result.FThreshMercy := TCandidate(FCandidates[Index]).FThreshMercy;
  Result.FIsoMercy := TCandidate(FCandidates[Index]).FIsoMercy;
  for i := 0 to TCandidate(FCandidates[Index]).FIsos.Count - 1 do
  begin
    oldIso := (TCandidate(FCandidates[Index]).FIsos[i]);
    newIso := TIso.Create;
    for j := 0 to oldIso.FIsoMatches.Count - 1 do
    begin
      oldIsoMatch := TIsoMatch(oldIso.FIsoMatches[j]);
      newIsoMatch := TIsoMatch.Create;
      newIsoMatch.FPeakIndex := oldIsoMatch.FPeakIndex;
      newIsoMatch.FDistance := oldIsoMatch.FDistance;
      newIso.FIsoMatches.Add(newIsoMatch);
    end;
    Result.FIsos.Add(newIso);
  end;

end;

constructor TCandidateFinder.Create(Isos: TIsotopeTable; Peaks: TMassSpectrum; Thresh: Double);
var
  i, j, peakIndex: Integer;
  candidate: TCandidate;
  iso: TIso;
  isoMatch: TIsoMatch;
  importantIsos: Boolean;

begin
  FCandidates := TList.Create;

  for i := 0 to Isos.Size - 1 do
  begin
    candidate := TCandidate.Create;
    candidate.FKey := Isos.Element[i];
    importantIsos := True;
    for j := 0 to Isos.NumIsos[i] - 1 do
    begin
      iso := TIso.Create;
      for peakIndex := 0 to Peaks.Size - 1 do
      begin
        if (Peaks.Masses[peakIndex] > Isos.Isotopes[i, j] - Thresh) and (Peaks.Masses[peakIndex] < Isos.Isotopes[i, j] + Thresh) then
        begin
          isoMatch := TIsoMatch.Create;
          isoMatch.FDistance := Abs(Peaks.Masses[peakIndex] - Isos.Isotopes[i, j]);
          isoMatch.FPeakIndex := peakIndex;
          iso.FIsoMatches.Add(isoMatch);
        end;
      end;

      if iso.FIsoMatches.Count > 0 then
      begin
        if Isos.Abundances[i, j] < c_AssumeMissingThresh then
        begin
          isoMatch := TIsoMatch.Create;
          isoMatch.FDistance := -1;
          isoMatch.FPeakIndex := -1;
          iso.FIsoMatches.Add(isoMatch);
          candidate.FThreshMercy := True;
        end;
        candidate.FIsos.Add(iso);
      end
      else
      begin
        if j <= 2 then
        begin
          importantIsos := False;
          iso.Free;
        end
        else
        begin
          isoMatch := TIsoMatch.Create;
          isoMatch.FDistance := -1;
          isoMatch.FPeakIndex := -1;
          iso.FIsoMatches.Add(isoMatch);
          candidate.FIsoMercy := True;
          candidate.FIsos.Add(iso);
        end;
      end;

    end;

    if importantIsos then
    begin
      FCandidates.Add(candidate);
    end
    else
    begin
      candidate.Free;
    end;

  end;
end;

destructor TCandidateFinder.Destroy;
begin
      if Assigned(FCandidates) then
  begin
    while FCandidates.Count > 0 do
    begin
      TCandidate(FCandidates[FCandidates.Count - 1]).Free;
      FCandidates.Delete(FCandidates.Count - 1);
    end;
  end;

  FCandidates.Free;
  inherited;
end;

end.
