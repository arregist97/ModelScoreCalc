unit ModelScorer;

interface

uses
  Buffer,
  SearchGrid,
  ModelScoresCalc,
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls;

type
  TForm4 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

const
  c_SlopeRange: Array[0..1] of Double = (0.00009, 0.0000001);//min/max distance the modified slopes can be from the base slope
  c_OffsetRange: Array[0..1] of Double = (0.009, 0.000001);//min/max distance the modified offsets can be from the base offset
  c_Mults: Array[0..1] of Integer = (1, -1);//we simulate 4 quardants by mirroring the positive indices
  c_NumSlopes = 20;//half the number of slopes that will be experimented with(due to the mirror)
  c_NumOffsets = 20;//half the number of offsets that will be experimented with(due to the mirror)
  c_numQuadrants = 4;
  c_DataLoc = '\Users\arreg\Documents\optimizer_data\PlotData.csv';

procedure TForm4.Button1Click(Sender: TObject);
var
  fLoc, rLoc, iLoc, csvLoc: String;
  scoresDoubleBuffer, slopesDoubleBuffer, offsetsDoubleBuffer: TDoubleBuffer;
  zoomScoresDoubleBuffer, zoomSlopesDoubleBuffer, zoomOffsetsDoubleBuffer: TDoubleBuffer;
  tempModelScoresCalc: TModelScoresCalc;
  grid, zoomGrid: TSearchGrid;
  i, j: Integer;
  slopeMod, offsetMod: Double;
  slopeMult, offsetMult: Integer;
  arrayIndex: Integer;
  bestScore: Double;
  bestIndex: Integer;
  newOffsetRange, newSlopeRange: Array[0..1] of Double;
  newSlope, newOffset: Double;
  prev: Double;
  prevIndex: Integer;
  buffer: String;
  dataFile: TextFile;
  //BaseSlope, BaseOffset: Double;

begin

  fLoc := 'C:\Users\arreg\Documents\optimizer_data\Fragment Table.csv';
  rLoc := 'C:\Users\arreg\Documents\optimizer_data\saved_ranges.csv';
  iLoc := 'C:\Users\arreg\Documents\optimizer_data\Elements.txt';
  csvLoc := 'C:\Users\arreg\Documents\optimizer_data\zip lock bag-001.csv';
  scoresDoubleBuffer := nil;

  slopesDoubleBuffer  := TDoubleBuffer.Create(c_NumSlopes*c_NumOffsets*c_numQuadrants);

  offsetsDoubleBuffer := TDoubleBuffer.Create(c_NumSlopes*c_NumOffsets*c_numQuadrants);

  grid := TSearchGrid.Create(c_SlopeRange, c_OffsetRange, c_NumSlopes, c_NumOffsets);

  tempModelScoresCalc := TModelScoresCalc.Create;

  tempModelScoresCalc.SetFilepaths(fLoc, rLoc, iLoc, csvLoc);

  arrayIndex := 0;
  for i := 0 to c_NumSlopes - 1 do
  begin
    slopeMod := grid.SlopeAxis[i];
    for slopeMult in c_Mults do
    begin
      slopeMod := slopeMod * slopeMult;
      for j := 0 to c_NumOffsets - 1 do
      begin
        offsetMod := grid.OffsetAxis[j];
        for offsetMult in  c_Mults do
        begin
          offsetMod := offsetMod * offsetMult;

          slopesDoubleBuffer[arrayIndex] := tempModelScoresCalc.BaseSlope + slopeMod * tempModelScoresCalc.BaseSlope;
          offsetsDoubleBuffer[arrayIndex] := tempModelScoresCalc.BaseOffset + offsetMod * tempModelScoresCalc.BaseOffset;
          Inc(arrayIndex);
        end;

      end;

    end;

  end;


  scoresDoubleBuffer := tempModelScoresCalc.CalcModelScores(SlopesDoubleBuffer,OffsetsDoubleBuffer);

  scoresDoubleBuffer.SearchForMaxValue(bestScore, bestIndex);

  newOffsetRange[0] := c_OffsetRange[0] * 0.5;//slightly less outdated calculations
  newOffsetRange[1] := c_OffsetRange[1] * 0.5;
  newSlopeRange[0] := c_SlopeRange[0] * 0.5;
  newSlopeRange[1] := c_SlopeRange[1] * 0.5;
  newSlope := slopesDoubleBuffer[bestIndex];
  newOffset := offsetsDoubleBuffer[bestIndex];
  prev := bestScore;
  prevIndex := bestIndex;
  zoomGrid := TSearchGrid.Create(newSlopeRange, newOffsetRange, c_NumSlopes, c_NumOffsets);

  zoomSlopesDoubleBuffer  := TDoubleBuffer.Create(c_NumSlopes*c_NumOffsets*c_numQuadrants);

  zoomOffsetsDoubleBuffer := TDoubleBuffer.Create(c_NumSlopes*c_NumOffsets*c_numQuadrants);

  arrayIndex := 0;
  for i := 0 to c_NumSlopes - 1 do
  begin
    slopeMod := zoomGrid.SlopeAxis[i];
    for slopeMult in c_Mults do
    begin
      slopeMod := slopeMod * slopeMult;
      for j := 0 to c_NumOffsets - 1 do
      begin
        offsetMod := zoomGrid.OffsetAxis[j];
        for offsetMult in  c_Mults do
        begin
          offsetMod := offsetMod * offsetMult;

          zoomSlopesDoubleBuffer[arrayIndex] := newSlope + slopeMod * newSlope;
          zoomOffsetsDoubleBuffer[arrayIndex] := newOffset + offsetMod * newOffset;
          Inc(arrayIndex);
        end;

      end;

    end;

  end;

  zoomScoresDoubleBuffer := tempModelScoresCalc.CalcModelScores(zoomSlopesDoubleBuffer,zoomOffsetsDoubleBuffer);

  zoomScoresDoubleBuffer.SearchForMaxValue(bestScore, bestIndex);

  if prev > bestScore then
  begin
    bestScore := prev;
    bestIndex := prevIndex;
  end;

   AssignFile(dataFile, c_DataLoc);
   ReWrite(dataFile);
   WriteLn(dataFile, 'MassOverTime,MassOffset,Score');
   try
     for i := 0 to scoresDoubleBuffer.Size - 1 do
     begin
       buffer := FloatToStr(slopesDoubleBuffer[i]) + ',' + FloatToStr(offsetsDoubleBuffer[i]) + ',' + FloatToStr(scoresDoubleBuffer[i]);
       WriteLn(DataFile, buffer);
     end;
     for i := 0 to zoomScoresDoubleBuffer.Size - 1 do
     begin
       buffer := FloatToStr(zoomSlopesDoubleBuffer[i]) + ',' + FloatToStr(zoomOffsetsDoubleBuffer[i]) + ',' + FloatToStr(zoomScoresDoubleBuffer[i]);
       WriteLn(DataFile, buffer);
     end;
   finally
     CloseFile(dataFile);
   end;

  scoresDoubleBuffer.Free;
  slopesDoubleBuffer.Free;
  offsetsDoubleBuffer.Free;
  zoomScoresDoubleBuffer.Free;
  zoomSlopesDoubleBuffer.Free;
  zoomOffsetsDoubleBuffer.Free;
  grid.Free;
  zoomGrid.Free;
  tempModelScoresCalc.Free;





end;

end.
