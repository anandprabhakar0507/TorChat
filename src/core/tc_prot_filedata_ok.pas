{ TorChat - TMsgFileDataOk

  Copyright (C) 2012 Bernd Kreuss <prof7bit@gmail.com>

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 3 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
}

unit tc_prot_filedata_ok;

{$mode objfpc}{$H+}

interface

uses
  tc_interface,
  tc_protocol;

type
  { TMsgFileDataOk

  }
  TMsgFileDataOk = class(TMsg)
  strict protected
    FTransferID: String;
    FStartByte: Int64;
    procedure Serialize; override;
    procedure ExecuteWithBuddy; override;
  public
    class function GetCommand: String; override;
    constructor Create(ABuddy: IBuddy; TransferID: String; StartByte: Int64); reintroduce;
    procedure Parse; override;
  end;

implementation
uses
  sysutils,
  tc_misc;

{ TMsgFileDataOk }

class function TMsgFileDataOk.GetCommand: String;
begin
  Result := 'filedata_ok';
end;

constructor TMsgFileDataOk.Create(ABuddy: IBuddy; TransferID: String; StartByte: Int64);
begin
  inherited Create(ABuddy);
  FTransferID := TransferID;
  FStartByte := StartByte;
end;

procedure TMsgFileDataOk.Parse;
begin
  FTransferID := PopFirstWord(FBinaryContent);
  FStartByte := StrToInt64Def(FBinaryContent, 0);
end;

procedure TMsgFileDataOk.Serialize;
begin
  FBinaryContent := SF('%s %d', [FTransferID, FStartByte]);
end;

procedure TMsgFileDataOk.ExecuteWithBuddy;
var
  Transfer: IFileTransfer;
begin
  Transfer := FClient.FindFileTransferSend(FTransferID);
  if Assigned(Transfer) then
    Transfer.ReceivedOk(FStartByte)
  else
    WriteLn('E received "filedata_ok" that does not belong to any running transfer, ignoring.');
end;

begin
  RegisterMessageClass(TMsgFileDataOk);
end.

