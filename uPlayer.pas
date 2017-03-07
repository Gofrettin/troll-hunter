unit uPlayer;

interface

type
  TPlayer = class(TObject)
  private
    FX: Byte;
    FY: Byte;
    FLX: Byte;
    FLY: Byte;
    FTurn: Word;
    FLife: Word;
    FMaxLife: Word;
    FLook: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    property X: Byte read FX write FX;
    property Y: Byte read FY write FY;
    property LX: Byte read FLX write FLX;
    property LY: Byte read FLY write FLY;
    property Turn: Word read FTurn write FTurn;
    property Life: Word read FLife write FLife;
    property MaxLife: Word read FMaxLife write FMaxLife;
    property Look: Boolean read FLook write FLook;
    procedure Move(AX, AY: ShortInt);
    procedure Wait;
    procedure AddTurn;
    function GetRadius: Byte;
    function SaveCharacterDump(AReason: string): string;
  end;

var
  Player: TPlayer = nil;

implementation

uses Classes, SysUtils, Dialogs, Math, uCommon, uMap;

{ TPlayer }

procedure TPlayer.AddTurn;
begin
  Turn := Turn + 1;
end;

constructor TPlayer.Create;
begin
  Turn := 0;
  Look := False;
end;

destructor TPlayer.Destroy;
begin

  inherited;
end;

function TPlayer.GetRadius: Byte;
begin
  Result := 7;
end;

procedure TPlayer.Move(AX, AY: ShortInt);
var
  FX, FY: Byte;
begin
  if Look then
  begin
    if Map.InMap(LX + AX, LY + AY)
      and Map.InView(LX + AX, LY + AY)
      and not Map.GetFog(LX + AX, LY + AY) then
    begin
      LX := Clamp(LX + AX, 0, High(Byte));
      LY := Clamp(LY + AY, 0, High(Byte));
    end;
  end else begin
    FX := Clamp(X + AX, 0, High(Byte));
    FY := Clamp(Y + AY, 0, High(Byte));
    AddTurn;
    if (Map.GetTileEnum(FX, FY, Map.Deep) in StopTiles) then Exit;
    X := FX;
    Y := FY;
  end;
end;

function TPlayer.SaveCharacterDump(AReason: string): string;
var
  I: Byte;
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SL.LoadFromFile(CharacterDumpFileName);
    for I := 0 to SL.Count - 1 do
    begin
      SL[I] := StringReplace(SL[I], '{date-time}', GetDateTime, [rfReplaceAll]);
      SL[I] := StringReplace(SL[I], '{reason}', AReason, [rfReplaceAll]);
//      SL[I] := StringReplace(SL[I], '{screenshot}', , [rfReplaceAll]);
//      SL[I] := StringReplace(SL[I], '{messages}', , [rfReplaceAll]);
//      SL[I] := StringReplace(SL[I], '{inventory}', , [rfReplaceAll]);
    end;
    SL.SaveToFile(StringReplace(CharacterDumpFileName, 'trollhunter', GetDateTime('-', '-'), [rfReplaceAll]));
  finally
    SL.Free;
  end;
end;

procedure TPlayer.Wait;
begin
  Move(0, 0);
end;

initialization
  Player := TPlayer.Create;
  Player.MaxLife := 100;
  Player.Life := Player.MaxLife;

finalization
  Player.Free;
  Player := nil;

end.
