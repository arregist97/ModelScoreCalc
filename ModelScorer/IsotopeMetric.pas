unit IsotopeMetric;

interface
uses
CandidateFinder,
CombinationList,
IsotopeTable,
MassSpectrum,
System.Classes;

const
  c_MeanIsoDistWeight = 1.0;
  c_StdDevIsoDistWeight = 1.0;

type

TEleMetric = class
  public
    FKey: String;
    FDistMetric: Double;
    FAbundMetric: Double;
    FBestComb: TComb;
    Destructor Destroy; override;
end;

TIsotopeMetric = class
  private
    function CheckAbundanceOrder(Comb: TComb; Peaks: TMassSpectrum): Boolean;
    function CombDistMean(Comb: TComb): Double;
    function CalcDistScore(Comb: TComb): Double;
    function CalcChannelSum(Comb: TComb; Peaks: TMassSpectrum): Double;
    function CalcPeakAbund(Comb: TComb; Peaks: TMassSpectrum; Sum: Double; Index: Integer): Double;
    function GetEleIndex(Key: String; IsoTable: TIsotopeTable): Integer;
    function CalcAbundScore(Comb: TComb; Peaks: TMassSpectrum; ElementKey: String; IsoTable: TIsotopeTable): Double;
  public
    FElements: TList;
    constructor Create(Peaks: TMassSpectrum; CandidateList: TCandidateFinder; IsoTable: TIsotopeTable);
    destructor Destroy; override;
end;

implementation

destructor TEleMetric.Destroy;
begin
  FBestComb.Free;
  inherited;
end;

function TIsotopeMetric.CheckAbundanceOrder(Comb: TComb; Peaks: TMassSpectrum): Boolean;
var
  i: Integer;
  currIntensity, maxIntensity: Double;

begin
  Result := True;
  for i := 0 to Comb.FMatches.Count - 1 do
  begin
    currIntensity := Peaks.Intensities[TIsoMatch(Comb.FMatches[i]).FPeakIndex];
    if i > 0 then
    begin
      if maxIntensity < currIntensity then
      begin
        Result := False;
        break;
      end;

    end;
    maxIntensity := currIntensity;
  end;
end;

function TIsotopeMetric.CombDistMean(Comb: TComb): Double;
var
  i: Integer;
  cumulative: Double;

begin
  cumulative := 0;
  for i := 0 to Comb.FMatches.Count - 1 do
  begin
    cumulative := cumulative + TIsoMatch(Comb.FMatches[i]).FDistance;
  end;
  Result := cumulative / Comb.FMatches.Count;
end;


function TIsotopeMetric.CalcDistScore(Comb: TComb): Double;
var
  mean, cumulative, stdDev: Double;
  i: Integer;

begin
  cumulative := 0;
  mean := CombDistMean(Comb);
  for i := 0 to Comb.FMatches.Count - 1 do
  begin
    cumulative := cumulative + Sqr((TIsoMatch(Comb.FMatches[i]).FDistance - mean));
  end;
  stdDev := Sqrt(cumulative / Comb.FMatches.Count);

  Result := c_MeanIsoDistWeight * mean + c_StdDevIsoDistWeight * stdDev;
end;

function TIsotopeMetric.CalcChannelSum(Comb: TComb; Peaks: TMassSpectrum): Double;
var
  i: Integer;
  cumulative: Double;

begin
  cumulative := 0;
  for i := 0 to Comb.FMatches.Count - 1 do
  begin
    cumulative := cumulative + Peaks.Intensities[TIsoMatch(Comb.FMatches[i]).FPeakIndex];
  end;

  Result := cumulative;

end;

function TIsotopeMetric.CalcPeakAbund(Comb: TComb; Peaks: TMassSpectrum; Sum: Double; Index: Integer): Double;

begin
  Result := Peaks.Intensities[TIsoMatch(Comb.FMatches[Index]).FPeakIndex] / Sum;
end;

function TIsotopeMetric.GetEleIndex(Key: String; IsoTable: TIsotopeTable): Integer;
var
  i: Integer;
  found : Boolean;

begin
  found := False;
  for i := 0 to IsoTable.Size - 1 do
  begin
    if Key = IsoTable.Element[i] then
    begin
      Result := i;
      found := True;
    end;

  end;

  if not found then
  begin
    Result := -1;
  end;

end;

function TIsotopeMetric.CalcAbundScore(Comb: TComb; Peaks: TMassSpectrum; ElementKey: String; IsoTable: TIsotopeTable): Double;
var
  peakAbund, channelSum, dist, cumulative: Double;
  i, eleIndex: Integer;
begin
  cumulative := 0;
  channelSum := CalcChannelSum(Comb, Peaks);
  eleIndex := GetEleIndex(ElementKey, IsoTable);
  for i := 0 to Comb.FMatches.Count - 1 do
  begin
    peakAbund := CalcPeakAbund(Comb, Peaks, channelSum, i);
    dist := Sqr(peakAbund - IsoTable.Abundances[eleIndex, i]);
    cumulative := cumulative + dist;
  end;

  Result := Sqrt(cumulative);
end;

constructor TIsotopeMetric.Create(Peaks: TMassSpectrum; CandidateList: TCandidateFinder; IsoTable: TIsotopeTable);
var
  candidate: TCandidate;
  comboList: TCombinationList;
  combo, secondCombo: TComb;
  i, j, bestIndex: Integer;
  distMetric, abundMetric: Double;
  metricObject: TEleMetric;
  matchFound: Boolean;

begin
  FElements := TList.Create;
  for i := 0 to candidateList.Size - 1 do
  begin
    matchFound := False;
    metricObject := TEleMetric.Create;
    candidate := TCandidate(candidateList.Candidates[i]);
    metricObject.FKey := candidate.Key;
    comboList := TCombinationList.Create(candidate);
    for j := 0 to comboList.Size - 1 do
    begin
      combo := TComb(comboList.SimplifiedCombinations[j]);
      if CheckAbundanceOrder(combo, Peaks) then
      begin
        distMetric := CalcDistScore(combo);

        if combo.FMatches.Count = 1 then
        begin
          abundMetric := -10;
        end
        else
        begin
          abundMetric := CalcAbundScore(combo, Peaks, metricObject.FKey, IsoTable);
        end;

        if (not matchFound) then
        begin
          if (combo.FMatches.Count > 1) and (abundMetric < 0.3) then
          begin
            metricObject.FDistMetric := distMetric;
            metricObject.FAbundMetric := abundMetric;
            bestIndex := j;
            matchFound := True;
          end;

        end
        else
        begin
          if metricObject.FDistMetric > distMetric then
          begin
            if (combo.FMatches.Count > 1) and (abundMetric < 0.3) then
            begin
              metricObject.FDistMetric := distMetric;
              metricObject.FAbundMetric := abundMetric;
              bestIndex := j;
            end;
          end;

        end;

      end;
      combo.Free;
    end;
    if matchFound then
    begin
      metricObject.FBestComb := TComb(comboList.Combinations[bestIndex]);
      FElements.Add(metricObject);
    end;
    candidate.Free;
    comboList.Free;
  end;

end;

destructor TIsotopeMetric.Destroy;
begin
  if Assigned(FElements) then
  begin
    while FElements.Count > 0 do
    begin
      TEleMetric(FElements[FElements.Count - 1]).Free;
      FElements.Delete(FElements.Count - 1);
    end;
  end;
  FElements.Free;
  inherited;
end;

end.
