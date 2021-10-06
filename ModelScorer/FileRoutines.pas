unit FileRoutines;

interface
uses
System.SysUtils;

function RemoveString(BaseStr, RemoveStr : String): String;
function ReadHeaderLine(FromFile: Integer): WideString;

implementation


function RemoveString(BaseStr, RemoveStr: String): String;

var
  i: Integer;

begin
  i := Pos(RemoveStr, BaseStr);
  while i > 0 do
  begin
      Delete(BaseStr, i, 1);
      i := Pos(RemoveStr, BaseStr);
  end;

  Result := BaseStr;
end;

function ReadHeaderLine(FromFile: Integer): WideString;
// Reads from file until end of line or end of file is encountered.
// The input is saved in 'line' and 'ok' is set to 'TRUE' if any characters
// are in 'line' otherwise 'ok' is set to 'FALSE'.
const
  c_Max_String_Chars = 1023;
var
  i: CARDINAL;
  num: LONGINT;
  tempStr: AnsiChar;
  tempLine: Array[0..c_Max_String_Chars] of AnsiChar;
  eofile, ok: Boolean;
begin
  num := 0; //Avoid compiler warning
  try
    // Loop till an EOF or a LF character is detected.
    ok := FALSE;
    i := 0;
    eofile := FALSE;
    while (ok = false) and (eofile = false) do
    begin
      // Read a character from the file.
      try
        num := FileRead(FromFile, tempStr, SizeOf(tempStr));
      except
        on E: Exception do
        begin //Log and swallow
          //TLogger.LogException(Classname,E,'ReadRawHeaderLine ignored this exception');
          num := 0; //Note that this will cause code below to set eofile := TRUE
        end;
      end;

      // Check if we have reached the end of the file.
      if (num = 0) then
      begin
        tempLine[i] := #0;
        eofile := TRUE;
      end
      else
      begin
        // Store the character in the Ansi string.
        tempLine[i] := tempStr;

        // If a LF character is detected, add a #0 terminator
        if (tempLine[i] = #10) then
        begin
          tempLine[i] := #0;

          // If the previous character was a CR, set it to #0 also.
          if (tempLine[i-1] = #13) then
            tempLine[i-1] := #0;

          // Set flag to indicate the LF character was found.
          ok := TRUE;
        end
        else if (i = c_Max_String_Chars) then //if the max line length has been exceeded
        begin
          try //Want raise and log an exception here because this should not happen
            tempLine[i] := #0; //We force the final character to be 0 terminator
            //raise ELogException.Create(Classname,'ReadRawHeaderLine max line length has been exceeded: "' + TLogger.FilterControlCodes(String(tempLine)) + '"');
          except //But now that we've raised and logged it, we swallow the exception and try to continue.
            ok := TRUE; // Set flag as if the LF character was found so we can continue
          end;
        end;
        Inc(i);
      end;
    end;

    // Convert the AnsiString to a WideString.
    Result := String(tempLine);
  except
    on E:Exception do
    begin
      //TLogger.LogException(Classname,E,'ReadRawHeaderLine failed',[]);
      raise;
    end;
  end;
end;
end.
