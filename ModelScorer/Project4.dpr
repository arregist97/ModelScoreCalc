program Project4;

uses
  Vcl.Forms,
  ModelScorer in 'ModelScorer.pas' {Form4},
  ModelScoresCalc in 'ModelScoresCalc.pas',
  BUFFER in 'BUFFER.PAS',
  CsvSpectrum in 'CsvSpectrum.pas',
  SearchGrid in 'SearchGrid.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm4, Form4);
  Application.Run;
end.
