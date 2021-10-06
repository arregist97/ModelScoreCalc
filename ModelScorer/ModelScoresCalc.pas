unit ModelScoresCalc;

interface

uses
  Buffer,
  System.Classes,
  CsvSpectrum,
  FeatureCalculator,
  FeatureTable;

type
  TModelScoresCalc = class
    private
      FCsvSpectrum: TCsvSpectrum;
      FFeatureCalc: TFeatureCalculator;
      FBaseSlope: Double;
      FBaseOffset: Double;

      procedure WriteFeatures(FeatTable: TFeatureTable; FeatWriter: Integer);
      procedure CalcScore;
      procedure GetAveragedScoresFromResultFiles(var ScoresDoubleBuffer: TDoubleBuffer);

    public
      constructor Create;
      destructor Destroy; override;
      procedure SetFilepaths(FragLoc, RangeLoc, IsoLoc, CsvLoc: String);
      function CalcModelScores(const Slopes,Offsets: TDoubleBuffer): TDoubleBuffer;

      property BaseSlope: Double read FBaseSlope;
      property BaseOffset: Double read FBaseOffset;
  end;

implementation

uses
  FileRoutines,
  MassSpectrum,
  System.SysUtils;

function fnGradientBoostedPredictor(mPtr, dPtr, rPtr: PAnsiChar): Double; cdecl; external
'GradientBoostedPredictor.dll' name 'fnGradientBoostedPredictor'; //Using Double

const
  c_ModelPath: AnsiString =  'C:/Users/arreg/Documents/optimizer_models/model#';
  c_ResultPath: AnsiString = 'C:/Users/arreg/Documents/optimizer_data/DllModelOutput_';
  c_FeatPath: AnsiString =   'C:/Users/arreg/Documents/optimizer_data/DllModelInput';
  c_FeatLoc =                'C:\Users\arreg\Documents\optimizer_data\DllModelInput';
  c_ResultsLoc =             'C:\Users\arreg\Documents\optimizer_data\DllModelOutput_';

////////////////////////////////////////////////////////////////////////////////
constructor TModelScoresCalc.Create;
begin
  FFeatureCalc := nil;
  FCsvSpectrum := nil;
  FBaseSlope := 0;
  FBaseOffset := 0;
end;

////////////////////////////////////////////////////////////////////////////////
destructor TModelScoresCalc.Destroy;
begin
  inherited;
  //Add destruction below
  FCsvSpectrum.Free;
end;

////////////////////////////////////////////////////////////////////////////////
procedure TModelScoresCalc.SetFilepaths(FragLoc, RangeLoc, IsoLoc, CsvLoc: String);
begin
  FFeatureCalc.Free;
  FFeatureCalc := TFeatureCalculator.Create(FragLoc, RangeLoc, IsoLoc);

  FCsvSpectrum.Free;
  FCsvSpectrum := TCsvSpectrum.Create(CsvLoc);
  FBaseSlope := FCsvSpectrum.MassOverTime;
  FBaseOffset := FCsvSpectrum.MassOffset;
end;

////////////////////////////////////////////////////////////////////////////////
procedure TModelScoresCalc.WriteFeatures(FeatTable: TFeatureTable; FeatWriter: Integer);
var
  i, check: Integer;
  buffer: AnsiString;

begin
  buffer := '0';

  for i := 0 to featTable.NumFragSplits - 1 do
  begin
    buffer := buffer + #9 + Format('%d',[featTable.Matches[i]]) + #9 +
    Format('%.9f',[featTable.PropMatches[i]]) + #9 +
    Format('%.9f',[featTable.AvgLowerDiffs[i]]) + #9 +
    Format('%.9f',[featTable.AvgHigherDiffs[i]]);
  end;

  for i := 0 to featTable.NumNpzSplits - 1 do
  begin
    buffer := buffer + #9 + Format('%d',[featTable.NpzMatches[i]]) + #9 +
    Format('%.9f',[featTable.PropNpzMatches[i]]) + #9 +
    Format('%.9f',[featTable.AvgNpzDiffs[i]]);
  end;


  buffer := buffer + #9 + Format('%d',[featTable.TwoElems]) + #9 +
  Format('%.9f',[featTable.AvgTwoDist]) + #9 +
  Format('%.9f',[featTable.AvgTwoAbundSep]) + #9 +
  Format('%d',[featTable.ThreeElems]) + #9 +
  Format('%.9f',[featTable.AvgThreeDist]) + #9 +
  Format('%.9f',[featTable.AvgThreeAbundSep]) + #13#10;

  check := FileWrite(FeatWriter, buffer[1], Length(buffer));

  if check = -1 then
  begin
    raise Exception.Create('Could not transfer feature data.');
  end;
//  FFeatureString := buffer;
end;

////////////////////////////////////////////////////////////////////////////////
procedure TModelScoresCalc.CalcScore();
{Call the dll to have it write the scores for each model to a separate result txt file}
var
  featPtr, modelPtr, resultPtr: PAnsiChar;
  i: Integer;
  tempModelStr, tempResultStr: AnsiString;

begin
  featPtr := Addr(c_FeatPath[1]);

  for i := 0 to 9 do
  begin
    tempModelStr := c_ModelPath + IntToStr(i) + '.txt';//change models
    tempResultStr := c_ResultPath + IntToStr(i) + '.txt';//change result files

    modelPtr := Addr(tempModelStr[1]);
    resultPtr := Addr(tempResultStr[1]);
    fnGradientBoostedPredictor(modelPtr, featPtr, resultPtr);
  end;
end;

////////////////////////////////////////////////////////////////////////////////
function TModelScoresCalc.CalcModelScores(const Slopes, Offsets: TDoubleBuffer): TDoubleBuffer;
{Return the scores corresponding to Slopes & Offsets. The client is responsible
 for freeing the result TDoubleBuffer}
var
  massSpec: TMassSpectrum;
  featureTable: TFeatureTable;
  featFile: Integer;
//  dataFile: TextFile;
  ix: Integer;
begin
  Result := nil;
  if (slopes.Size <= 0) or (slopes.Size <> offsets.Size) or
     (not Assigned(FCsvSpectrum)) or (not Assigned(FFeatureCalc)) then
    Exit;

    featFile := FileCreate(c_FeatLoc);
    if FeatFile = -1 then
    begin
      featFile := FileOpen(c_FeatLoc, fmOpenWrite);
      if FeatFile = -1 then
      begin
        raise Exception.Create('Could not open file' + c_FeatLoc);
      end;
    end;
    try
      for ix := 0 to slopes.Size-1 do
      begin
        massSpec := TMassSpectrum.Create(FCsvSpectrum, Slopes[ix], Offsets[ix]);
        try
          featureTable := FFeatureCalc.Feature[massSpec];
          WriteFeatures(featureTable, featFile);
        finally
          massSpec.Free;
        end;
      end;
    finally
      FileClose(featFile);
    end;

    CalcScore(); //Call the dll to have it write the scores for each model to a separate result txt file

    Result := TDoubleBuffer.Create(Slopes.Size);
    GetAveragedScoresFromResultFiles (Result);
end;

////////////////////////////////////////////////////////////////////////////////
procedure TModelScoresCalc.GetAveragedScoresFromResultFiles(var ScoresDoubleBuffer: TDoubleBuffer);
var
  modelResultFileHandles: Array[0..9] of Integer;
  fileIndex: Integer;
  cumulative: Double;
  lineStr: WideString;
  ix: Integer;
begin
  //open result files
  for fileIndex := 0 to 9 do
    modelResultFileHandles[fileIndex] := FileOpen(c_ResultsLoc + IntToStr(fileIndex) + '.txt', fmOpenRead);

  for ix := 0 to ScoresDoubleBuffer.Size-1 do
  begin
    //add model scores from each result line
    cumulative := 0;
    for fileIndex := 0 to 9 do
    begin
      lineStr := ReadHeaderLine(modelResultFileHandles[fileIndex]);
      if lineStr <> '' then
        cumulative := cumulative + StrToFloat(lineStr)
      else
        raise Exception.Create('Unexpected end of file: ' + c_ResultsLoc + IntToStr(fileIndex) + '.txt');
    end;
    ScoresDoubleBuffer[ix] := cumulative / 10;
  end;

  //close result files
  for fileIndex := 0 to 9 do
    FileClose(modelResultFileHandles[fileIndex]);
end;


end.
