unit MassSpectrum;

interface
uses
CsvSpectrum,
System.Classes,
System.Math;

type
  TPeak = class
    public
      FMass: Double;
      FIntensity: Double;
  end;

  TMassSpectrum = class
    private
      FPeaks: TList;
      function GetSize: Integer;
      function GetMass(Index: Integer): Double;
      function GetIntensity(Index: Integer): Double;
    public
      property Size: Integer read GetSize;
      property Masses[Index: Integer]: Double read GetMass;
      property Intensities[Index: Integer]: Double read GetIntensity;
      constructor Create(spec: TCsvSpectrum; Slope, Offset: Double); overload;
      constructor Create(Peaks: TMassSpectrum; LowerBound, UpperBound: Double); overload;
      destructor Destroy; override;
  end;

  TNominalMassSpectrum = class(TMassSpectrum)
    public
      function SortPeaks(Peaks: TMassSpectrum; LowerBound, UpperBound: Double): TList;
      constructor Create(Peaks: TMassSpectrum; LowerBound, UpperBound: Double); overload;
  end;

implementation

function TMassSpectrum.GetSize: Integer;
begin
  Result := FPeaks.Count;
end;

function TMassSpectrum.GetMass(Index: Integer): Double;
begin
  Result := TPeak(FPeaks[Index]).FMass;
end;

function TMassSpectrum.GetIntensity(Index: Integer): Double;
begin
  Result := TPeak(FPeaks[Index]).FIntensity;
end;

constructor TMassSpectrum.Create(spec: TCsvSpectrum; Slope, Offset: Double);

var
  i: Integer;
  peak: TPeak;
begin
  FPeaks := TList.Create;
  for i := 0 to spec.Size - 1 do
  begin
    peak := TPeak.Create();
    peak.FMass := Power(((spec.Channels[i] * 0.001 * spec.SpecBinSize + spec.StartFlightTime) * Slope + Offset), 2.0);
    peak.FIntensity := spec.Counts[i];
    FPeaks.Add(peak);
  end;
end;

constructor TMassSpectrum.Create(Peaks: TMassSpectrum; LowerBound, UpperBound: Double);
var
  i: Integer;
  peak: TPeak;

begin
  FPeaks := TList.Create;
  for i := 0 to Peaks.Size - 1 do
  begin
    if (Peaks.Masses[i] >= LowerBound) and (Peaks.Masses[i] < UpperBound) then
    begin
      peak := TPeak.Create();
      peak.FMass := Peaks.Masses[i];
      peak.FIntensity := Peaks.Intensities[i];
      FPeaks.Add(peak);
    end;
  end;


end;

destructor TMassSpectrum.Destroy;
begin

  if Assigned(FPeaks) then
  begin
    while FPeaks.Count > 0 do
    begin
      TPeak(FPeaks[FPeaks.Count - 1]).Free;
      FPeaks.Delete(FPeaks.Count - 1);
    end;


    FPeaks.Free;
  end;

  inherited;
end;

function TNominalMassSpectrum.SortPeaks(Peaks: TMassSpectrum; LowerBound, UpperBound: Double): TList;
var
  i, j: Integer;
  peak: TPeak;
  inserted: Boolean;
  mass: Double;

begin
  Result := TList.Create;
  for i := 0 to Peaks.Size - 1 do
  begin
    mass := Peaks.Masses[i];
    if (Peaks.Masses[i] >= LowerBound) and (Peaks.Masses[i] < UpperBound) then
    begin
      peak := TPeak.Create();
      peak.FMass := Peaks.Masses[i];
      peak.FIntensity := Peaks.Intensities[i];

      j := Result.Count;
      inserted := False;
      if j = 0 then
      begin
        Result.Insert(0, peak);
        inserted := True;
      end;
      while not inserted do
      begin
        Dec(j);
        if peak.FMass > TPeak(Result[j]).FMass then
        begin
          Result.Insert(j + 1, peak);
          inserted := True;
        end
        else
        begin
          if j = 0 then
          begin
            Result.Insert(0, peak);
            inserted := True;
          end;
        end;
      end;

    end;

  end;

end;

constructor TNominalMassSpectrum.Create(Peaks: TMassSpectrum; LowerBound, UpperBound: Double);
var
  i: Integer;
  peak, maxPeak: TPeak;
  sorted: TList;
  currNomMass, maxIndex: Integer;
  maxHeightCurrMass: Double;

begin
  sorted := SortPeaks(Peaks, LowerBound, UpperBound);

  FPeaks := TList.Create;
  currNomMass := 0;
  maxHeightCurrMass := 0;
  maxIndex := sorted.Count;
  for i := 0 to sorted.Count - 1 do
  begin
    peak := TPeak(sorted[i]);
    if Round(peak.FMass) = currNomMass then
    begin
      if peak.FIntensity > maxHeightCurrMass then
      begin
        maxHeightCurrMass := peak.FIntensity;
        maxIndex := i;
      end;

    end
    else
    begin
      if maxHeightCurrMass <> 0 then
      begin
        maxPeak := TPeak.Create;
        maxPeak.FMass := TPeak(sorted[maxIndex]).FMass;
        maxPeak.FIntensity := TPeak(sorted[maxIndex]).FIntensity;
        FPeaks.Add(maxPeak);
      end;

      currNomMass := Round(peak.FMass);
      maxHeightCurrMass := peak.FIntensity;
      maxIndex := i;

    end;

  end;

  if (maxIndex < sorted.Count) then//if the max index is less than count, we need to add the last item (unless there is 0 elements)
  begin
    maxPeak := TPeak.Create;
    maxPeak.FMass := TPeak(sorted[maxIndex]).FMass;
    maxPeak.FIntensity := TPeak(sorted[maxIndex]).FIntensity;
    FPeaks.Add(maxPeak);
  end;


  if Assigned(sorted) then
  begin
    while sorted.Count > 0 do
    begin
      TPeak(sorted[sorted.Count - 1]).Free;
      sorted.Delete(sorted.Count - 1);
    end;


    sorted.Free;
  end;

end;

end.

