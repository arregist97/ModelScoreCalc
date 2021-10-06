 unit CsvSpectrum;

interface

uses
CoreUtility,
FileRoutines,
System.Classes,
System.SysUtils;

type

TRow = class
  public
    FChannel: Double;
    FCount: Double;
    constructor Create(Count: Double; Channel: Double);
end;

TCsvSpectrum = class
  private
    FMassOverTime: Double;
    FMassOffset: Double;
    FRows: TList;
    FSpecBinSize: Double;
    FStartFlightTime: Double;
    function GetSize: Integer;
    function GetCount(Index: Integer): Double;
    function GetChannel(Index: Integer): Double;
  public
    property MassOverTime: Double read FMassOverTime;
    property MassOffset: Double read FMassOffset;
    property SpecBinSize: Double read FSpecBinSize;
    property StartFlightTime: Double read FStartFlightTime;
    property Size: Integer read GetSize;
    property Counts[Index: Integer]: Double read GetCount;
    property Channels[Index: Integer]: Double read GetChannel;
    constructor Create(Loc: String);
    destructor Destroy; override;
end;

implementation

constructor TRow.Create(Count: Double; Channel: Double);
begin
  FChannel := Channel;
  FCount := Count;
end;

function TCsvSpectrum.GetSize;
begin
  Result := FRows.Count;
end;

function TCsvSpectrum.GetCount(Index: Integer): Double;
begin
  Result := TRow(FRows[Index]).FCount;
end;

function TCsvSpectrum.GetChannel(Index: Integer): Double;
begin
  Result := TRow(FRows[Index]).FChannel;
end;

constructor TCsvSpectrum.Create(Loc: String);
var
  chanStr, countsStr: String;
  ascSpecFile: Integer;
  lineStr: WideString;
  header: Boolean;
  row: TRow;


begin
  FRows := TList.Create;
  ascSpecFile:= FileOpen(Loc, fmOpenRead);
  repeat
    lineStr:= ReadHeaderLine(ascSpecFile);
    if (lineStr <> '') then
    begin
      if lineStr = 'SOFH' then
        header := True
      else
      begin
        if header then
        begin
          if lineStr = 'EOFH' then
            header := False
          else
          begin
            chanStr:= Item(lineStr,':',0);
            if chanStr = 'Mass/Time' then
            begin
              countsStr := Item(lineStr,':',1);
              FMassOverTime := StrToFloat(countsStr);
            end
            else
            begin
              if chanStr = 'MassOffset' then
              begin
                countsStr := Item(lineStr,':',1);
                FMassOffset := StrToFloat(countsStr);
              end
              else
              begin
                if chanStr = 'SpecBinSize' then
                begin
                  countsStr := Item(lineStr,':',1);
                  FSpecBinSize := StrToFloat(countsStr);
                end
                else
                begin
                  if chanStr = 'StartFlightTime' then
                  begin
                    countsStr := Item(lineStr,':',1);
                    FStartFlightTime := StrToFloat(countsStr);
                  end;

                end;

              end;

            end;

          end;

        end
        else
        begin
          chanStr:= Item(lineStr,',',0);
          countsStr:= Item(lineStr, ',',1);
          row := TRow.Create(StrToFloat(countsStr), StrToFloat(chanStr));
          FRows.Add(row);
        end;

      end;

    end;


  until (lineStr = '');

  FileClose(ascSpecFile);


end;

destructor TCsvSpectrum.Destroy;
begin

  if Assigned(FRows) then
  begin
    while FRows.Count > 0 do
    begin
      TRow(FRows[FRows.Count - 1]).Free;
      FRows.Delete(FRows.Count - 1);
    end;


    FRows.Free;
  end;

  inherited;
end;

end.
