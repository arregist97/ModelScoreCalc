 unit FeatureCalculator;

interface

uses
CandidateFinder,
CombinationList,
CoreUtility,
CsvSpectrum,
FileRoutines,
FeatureTable,
FragmentTable,
IsotopeMetric,
IsotopeTable,
MassSpectrum,
NpzRanges,
System.Classes,
System.Math,
System.SysUtils;

const
  c_NumFragMassRanges = 4;
  c_NumNpzMassRanges = 8;
  c_FragMassRanges: Array[0..3] of Double = (40, 100, 150, 235.043933);
  c_NpzMassRanges: Array[0..7] of Integer = (50, 100, 200, 300, 400, 500, 600, 717);
  c_PpmFrags: Array[0..3] of Boolean = (True, False, True, True);
  c_NPZ_Edge = 717;
  c_Thresh = 0.1;
  c_IsoMatchThresh = 0.007;

type

TMatch = class
  public
    FMass: Double;
    FFragment: Double;
    FDiff: Double;
end;

TDist = class
  public
    FDist: Double;
end;

TFeatureCalculator = class
private
  FLowerThresh: TList;
  FHigherThresh: TList;
  FFeatures: TFeatureTable;
  FFrags: TFragmentTable;
  FRanges: TNpzRanges;
  FIsoTable: TIsotopeTable;
  procedure ClearThreshes;
  function GetClosest(I: Integer; Mass: Double): Integer;
  function IsFindable(Floor, Ceiling: Integer): Boolean;
  procedure CalcFragMatches(Peaks: TMassSpectrum; Threshes: Array of Double; ppm: Boolean);
  function GetDistMean(List:  TList): Double;
  function GetPpm(Mass, Frag: Double): Double;
  procedure CalcFragStats(SplitIndex: Integer; Peaks: TMassSpectrum; ppm: Boolean);
  procedure SplitFrags(Peaks: TMassSpectrum);
  function GetDistanceNPZ(Masses: TNominalMassSpectrum; ShowCorrectValues, Proportions: Boolean; MassThresh: Integer):TList;
  procedure CalcNpzStats(SplitIndex: Integer; Peaks: TNominalMassSpectrum);
  procedure SplitNpz(Peaks: TMassSpectrum);
  procedure CalcIsoStats(Peaks: TMassSpectrum);
  function GetFeatures(MS: TMassSpectrum):TFeatureTable;
public
  FIsotopeStringList: TStringList;
  property Feature[MS: TMassSpectrum]: TFeatureTable read GetFeatures;
  constructor Create(FragLoc, RangeLoc, IsoLoc: String);
  destructor Destroy; override;

end;

implementation

procedure TFeatureCalculator.ClearThreshes;

begin
  if Assigned(FHigherThresh) then
  begin
    while FHigherThresh.Count > 0 do
    begin
      TMatch(FHigherThresh[FHigherThresh.Count - 1]).Free;
      FHigherThresh.Delete(FHigherThresh.Count - 1);
    end;
    FHigherThresh.Clear;
    FLowerThresh.Clear;
  end;
end;

function TFeatureCalculator.GetClosest(I: Integer; Mass: Double): Integer;
(*
 * Recursively checks that the closest fragment to a peak is selected.
 *
 * Arguments ------
 * i: index in fragment list to start checking
 * frags: list of mass fragments
 * mass: mass of peak being matched
 *)

var
  d: Double;

begin
  d := Abs(FFrags.Masses[I] - Mass);
  if (FFrags.Size > I + 1) and (d > Abs(FFrags.Masses[I + 1] - Mass)) then
    I := GetClosest(I + 1, Mass)
  else
    if (I - 1 >= 0) and (d > Abs(FFrags.Masses[I - 1] - Mass)) then
      I := GetClosest(I - 1, Mass);

  Result := I;
end;

function TFeatureCalculator.IsFindable(Floor, Ceiling: Integer): Boolean;

begin
  if (Abs(Floor - Ceiling) <= 1) then
    Result := False
  else
    Result := True;

end;

function TFeatureCalculator.GetPpm(Mass, Frag: Double): Double;
var
  ppm: Double;

begin
  ppm := 1000000 * ABS(Frag - Mass);
  if Mass <> 0 then
    ppm := ppm / Mass;
  Result := ppm;
end;

procedure TFeatureCalculator.CalcFragMatches(Peaks: TMassSpectrum; Threshes: Array of Double; ppm: Boolean);
{*
 * Matches known compound/element masses to peaks in a given spectrum for
 * each threshold in the list of passed threshold.
 *
 * Returns the list of masses matched, list of fragments matched to those
 * masses for each threshold, and the list of distances between the
 * masses and the matched fragments.
 *
 * Arguments -------
 * masses: list of masses for a spectrum
 * frags: fragment list
 * threshes: list of thresholds to use to check if a fragment is close
 *   enough to a peak to call it a match.
 * ab: whether to use absolute value for calculated distances, affects
 *   the average distance per spectrum.
 *
 *}
var
  i, j: Integer;
  notFound: Boolean;
  floor, ceiling, num: Integer;
  dist: Double;
  match: TMatch;
  maxFrags: Double;


begin
  ClearThreshes;

  maxFrags := FFrags.Max + Threshes[1];

  for i := 0 to Peaks.Size - 1 do
  begin
    if (Peaks.Masses[i] < MaxFrags) then
    begin
      notFound := True;
      j := FFrags.Size div 2;
      floor := 0;
      ceiling := FFrags.Size - 1;

      while notFound do
      begin
        dist := FFrags.Masses[j] - Peaks.Masses[i];

        if (ABS(dist) < MaxValue(Threshes)) then
        begin
          notFound := False;
          j := GetClosest(j, Peaks.Masses[i]);
          dist := FFrags.Masses[j] - Peaks.Masses[i];
          match := TMatch.Create;
          match.FMass := Peaks.Masses[i];
          match.FFragment := FFrags.Masses[j];
          if not ppm then
            match.FDiff := ABS(dist)
          else
            match.FDiff := GetPpm(Peaks.Masses[i], FFrags.Masses[j]);

          if ABS(dist) < Threshes[1] then
          begin
            FHigherThresh.Add(match);

            if ABS(dist) < Threshes[0] then
            begin
              FLowerThresh.Add(match);
            end;
          end;


        end
        else
          if (dist > 0) then
          begin
            notFound := IsFindable(floor, ceiling);
            ceiling := j;
            num := Abs(floor - j);
            if Not(num = 1) then
              j := j - (num div 2)
            else
              j := j - 1;

          end
          else
          begin
            notFound := IsFindable(floor, ceiling);
            floor := j;
            num := Abs(ceiling - j);
            if Not(num = 1) then
              j := j + (num div 2)
            else
              j := j + 1;
          end;
      end;
    end;

  end;

end;


function TFeatureCalculator.GetDistMean(List:  TList): Double;

var
  i: Integer;
  cumulative: Double;

begin
  cumulative := 0;
  for i := 0 to List.Count - 1 do
    cumulative := cumulative + TMatch(List[i]).FDiff;
  Result := cumulative / List.Count;
end;

procedure TFeatureCalculator.CalcFragStats(SplitIndex: Integer; Peaks: TMassSpectrum; ppm: Boolean);
(*
 * function TCalibrationOptimizer.which asseses the calibration of a spectrum.
 * If augment is True slope_val and offset_val are treated as proportions
 * of slope/offset to augment original values with. Otherwise the values
 * are treated a the new values for slope and offset.
 *
 * Returns a proportion of matched peaks, as well as the avg distance from
 * fragment for a thrshold of .003 and .007 amu. If num_peaks is true also
 * returns the number of matched peaks.
 *
 * Arguments -------
 * row: row corresponding to spectra
 * frags: pd.Series of fragments
 * slope_val: either a proportion of slope to augment slope with or a new value
 * for slope.
 * offset_val: either a proportion of offset to augment offset with or a new
 * value for offset.
 * ranges: array of ranges of npz.
 * augment: whether to treat slope_val/offset_val as a proportion or value
 * num_peaks: if true also returns the number of peaks of matched per spectrum
 * ranges: String, list of tuples representing No Peak Zones.
 *)

var
  i: Integer;
  matchesPossible : Integer;
  prop, lowDist, HighDist: Double;
  threshes: Array of Double;


begin
 (*
  *Move this to where TMassSpectrums are created.
  *slope := Row.FMassOverTime + SlopeVal * Row.FMassOverTime;
  *offset := Row.FMassOffset + OffsetVal * Row.FMassOffset;
  *)

  SetLength(threshes, 2);
  threshes[0] := 0.003;
  threshes[1] := 0.007;

  CalcFragMatches(Peaks, threshes, ppm);

  matchesPossible := 0;
  for i := 0 to Peaks.Size - 1 do
  begin
    if (Peaks.Masses[i] < 236) then
      Inc(matchesPossible);
  end;

  prop := FLowerThresh.Count / (matchesPossible + 0.01);
  lowDist := 0;
  highDist := 0;

  if(FLowerThresh.Count) > 0 then
    lowDist := GetDistMean(FLowerThresh);
  if(FHigherThresh.Count) > 0 then
    HighDist := GetDistMean(FHigherThresh);

  FFeatures.Matches[SplitIndex] := FLowerThresh.Count;
  FFeatures.PropMatches[SplitIndex] := prop;
  FFeatures.AvgLowerDiffs[SplitIndex] := lowDist;
  FFeatures.AvgHigherDiffs[SplitIndex] := highDist;

 end;

procedure TFeatureCalculator.SplitFrags(Peaks: TMassSpectrum);
var
  i: Integer;
  split: TMassSpectrum;
  lowerSplitBound : Double;

begin
  lowerSplitBound := 0;
  for i := 0 to c_NumFragMassRanges - 1 do
  begin
    split := TMassSpectrum.Create(Peaks, lowerSplitBound, c_FragMassRanges[i]);
    CalcFragStats(i, split, c_PpmFrags[i]);
    split.free;
    lowerSplitBound := c_FragMassRanges[i];
  end;


end;

function TFeatureCalculator.GetDistanceNPZ(Masses: TNominalMassSpectrum; ShowCorrectValues, Proportions: Boolean; MassThresh: Integer):TList;
(*
 * Returns list of how how far into the No Peak Zone the given masses are.
 *
 * Arguments: -------
 * masses: list of peak masses
 * ranges: list of tuples representing 'No Peak Zones'
 * show_correct_peaks: whether, if a peak is not in the 'No Peak Zone',
 * to show how far into the 'correct zone' it is.
 * proportions: boolean, whether to show distance into zone by proportion
 * instead of distance.
 * mass_thresh: how far up the amu scale to find the distance into NPZ,
 * default 800
 *)

var
  dists: TList;
  mass, val, rangeSize: Double;
  truncd: Integer;
  zone: TRange;
  myDist: TDist;
  i: Integer;

begin
  dists := TList.Create();
  //for mass in Masses do
  for i := 0 to Masses.Size - 1 do
  begin
    mass := Masses.Masses[i];
    if mass <= MassThresh then
    begin
      truncd := Trunc(mass);
      zone := FRanges.Ranges[truncd];
      val := Min(Abs(mass - zone.FLow), Abs(mass - zone.FHigh));

      if Not(Proportions) then
      begin
        if (zone.FLow < mass) and (mass < zone.FHigh) then
        begin
          myDist := TDist.Create();
          myDist.FDist := val;
          dists.Add(myDist);
        end
        else
        begin
          if ShowCorrectValues then
          begin
            myDist := TDist.Create();
            myDist.FDist := val * -1;
            dists.Add(myDist);
          end
          else
          begin
            myDist := TDist.Create();
            myDist.FDist := 0;
            dists.Add(myDist);
          end;

        end;
      end
      else
      begin
        rangeSize := zone.FHigh - zone.FLow;
        if (zone.FLow < mass) and (mass < zone.FHigh) then
        begin
          myDist := TDist.Create();
          myDist.FDist := val / rangeSize;
          dists.Add(myDist);
        end
        else
        begin
          myDist := TDist.Create();
          myDist.FDist := 0;
          dists.Add(myDist);
        end;
      end;

    end;

  end;

  Result := dists;

end;

procedure TFeatureCalculator.CalcNpzStats(SplitIndex: Integer; Peaks: TNominalMassSpectrum);
  (*
 * Returns list of all peaks with distance / proportion into the No Peak Zone
 * above the given threshold, thresh as well as the mean distance into the
 * No Peak Zone.
 *
 * Arguments -------
 * masses: list of peak mass values.
 * ranges: list of tuples representing no peak zones.
 * thresh: threshold beyond which peaks in the No Peak Zone are suspicious.
 *)

var
  i, j: Integer;
  susses, susPeaks: TList;
  cumulative: Double;
  peak: TPeak;

begin
  susPeaks := TList.Create();

  susses := GetDistanceNpz(Peaks, False, False, c_NPZ_Edge);

  j := 0;
  cumulative := 0;

  if susses.Count > 0 then
  begin
    for i := 0 to Peaks.Size - 1 do
    begin
      if Peaks.Masses[i] < c_NPZ_Edge then
      begin
        if TDist(susses[j]).FDist > c_Thresh then
        begin
          peak := TPeak.Create();
          peak.FMass := Peaks.Masses[i];
          peak.FIntensity := Peaks.Intensities[i];
          susPeaks.Add(peak);
        end;

        cumulative := cumulative + TDist(susses[j]).FDist;

        Inc(j);
      end;

    end;
  end;


  FFeatures.NpzMatches[SplitIndex] := suspeaks.Count;
  if Peaks.Size = 0 then
  begin
    FFeatures.PropNpzMatches[SplitIndex] := 0;
  end
  else
  begin
    FFeatures.PropNpzMatches[SplitIndex] := suspeaks.Count / (Peaks.Size + 0.001);
  end;
  if susses.count = 0 then
  begin
    FFeatures.AvgNpzDiffs[SplitIndex] := 0
  end
  else
  begin
    FFeatures.AvgNpzDiffs[SplitIndex] := cumulative / (susses.count + 0.001);
  end;

  if Assigned(susses) then
  begin
    while susses.Count > 0 do
    begin
      TDist(susses[susses.Count - 1]).Free;
      susses.Delete(susses.Count - 1);
    end;


    susses.Free;
  end;

  if Assigned(susPeaks) then
  begin
    while susPeaks.Count > 0 do
    begin
      TPeak(susPeaks[susPeaks.Count - 1]).Free;
      susPeaks.Delete(susPeaks.Count - 1);
    end;


    susPeaks.Free;
  end;

end;

procedure TFeatureCalculator.SplitNpz(Peaks: TMassSpectrum);
var
  i: Integer;
  split: TNominalMassSpectrum;
  lowerSplitBound : Double;

begin
  lowerSplitBound := 0;
  for i := 0 to c_NumNpzMassRanges - 1 do
  begin
    split := TNominalMassSpectrum.Create(Peaks, lowerSplitBound, c_NpzMassRanges[i]);
    CalcNpzStats(i, split);
    split.free;
    lowerSplitBound := c_NpzMassRanges[i];
  end;


end;



procedure TFeatureCalculator.CalcIsoStats(Peaks: TMassSpectrum);
var
  candidateList: TCandidateFinder;
  isoMetrics: TIsotopeMetric;
  i, twoElems, threeElems: Integer;
  totalTwoDists, totalThreeDists, totalTwoAbunds, totalThreeAbunds: Double;
  element: TEleMetric;

begin
  candidateList := TCandidateFinder.Create(FIsoTable, Peaks, c_IsoMatchThresh);
  isoMetrics := TIsotopeMetric.Create(Peaks, candidateList, FIsoTable);
  twoElems := 0;
  threeElems := 0;
  totalTwoDists := 0;
  totalThreeDists := 0;
  totalTwoAbunds := 0;
  totalThreeAbunds := 0;
  FreeAndNil(FIsotopeStringList); //Set dealloc and set to nil as a precaution
  FIsotopeStringList := TStringList.Create;
  for i := 0 to isoMetrics.FElements.Count - 1 do
  begin
    element := TEleMetric(isoMetrics.FElements[i]);
    if element.FBestComb.FMatches.Count = 2 then
    begin
      Inc(twoElems);
      totalTwoDists := totalTwoDists + element.FDistMetric;
      totalTwoAbunds := totalTwoAbunds + element.FAbundMetric;
      FIsotopeStringList.Add(element.FKey);
    end
    else
    begin
      if element.FBestComb.FMatches.Count > 2 then
      begin
        Inc(threeElems);
        totalThreeDists := totalThreeDists + element.FDistMetric;
        totalThreeAbunds := totalThreeAbunds + element.FAbundMetric;
        FIsotopeStringList.Add(element.FKey);
      end;

    end;

  end;

  if threeElems > 0 then
  begin
    FFeatures.ThreeElems := threeElems;
    FFeatures.AvgThreeDist := totalThreeDists / threeElems;
    FFeatures.AvgThreeAbundSep := totalThreeAbunds / threeElems;
  end
  else
  begin
    FFeatures.ThreeElems := 0;
    FFeatures.AvgThreeDist := 0;
    FFeatures.AvgThreeAbundSep := 0;
  end;

  if twoElems > 0 then
  begin
    FFeatures.TwoElems := twoElems;
    FFeatures.AvgTwoDist := totalTwoDists / twoElems;
    FFeatures.AvgTwoAbundSep := totalTwoAbunds / twoElems;
  end
  else
  begin
    FFeatures.TwoElems := 0;
    FFeatures.AvgTwoDist := 0;
    FFeatures.AvgTwoAbundSep := 0;
  end;

  candidateList.Free;
  isoMetrics.Free;

end;

function TFeatureCalculator.GetFeatures(MS: TMassSpectrum): TFeatureTable;
begin
  FFeatures.Free;
  FFeatures := TFeatureTable.Create(c_NumFragMassRanges, c_NumNpzMassRanges);

  SplitFrags(MS);

  SplitNpz(MS);

  CalcIsoStats(MS);

  Result := FFeatures.Copy;


end;

constructor TFeatureCalculator.Create(FragLoc, RangeLoc, IsoLoc: String);

begin

  FFrags := TFragmentTable.Create(FragLoc);
  FRanges := TNpzRanges.Create(RangeLoc);
  FIsoTable := TIsotopeTable.Create(IsoLoc);
  FLowerThresh := TList.Create;
  FHigherThresh := TList.Create;
  FIsotopeStringList := nil;
end;

Destructor TFeatureCalculator.Destroy;
begin

  FFeatures.Free;
  FFrags.Free;
  FRanges.Free;
  FIsoTable.Free;

  ClearThreshes;

  FHigherThresh.Free;
  FLowerThresh.Free;

  inherited;
end;


end.
