table 99029 "ITI App. Metadata Set Object"
{
    Caption = 'Application Metadata Set Objects';
    DrillDownPageID = "ITI App. Metadata Set Objects";
    LookupPageID = "ITI App. Metadata Set Objects";
    fields
    {
        field(1; "App. Metadata Set Code"; Code[20])
        {
            Caption = 'Set Code';
            DataClassification = ToBeClassified;
        }
        field(2; "Object ID"; Integer)
        {
            Caption = 'Object ID';
            DataClassification = ToBeClassified;
        }
        field(3; "Object Type"; Enum "ITI Object Type")
        {
            Caption = 'Object Type';
            DataClassification = ToBeClassified;
        }
        field(10; "Object Subtype"; Text[250])
        {
            Caption = 'Object Subtype';
            DataClassification = ToBeClassified;
        }
        field(15; "Object Description"; Text[200])
        {
            Caption = 'Object Description';
            DataClassification = ToBeClassified;
        }
        field(20; "Runtime Package ID"; Text[40])
        {
            Caption = 'Runtime Package ID';
            DataClassification = ToBeClassified;
        }
        field(30; "Package ID"; Text[40])
        {
            Caption = 'Package ID';
            DataClassification = ToBeClassified;
        }
        field(40; "Metadata"; Blob)
        {
            Caption = 'Metadata';
            DataClassification = ToBeClassified;
        }
        field(50; "Data Per Company"; Boolean)
        {
            Caption = 'Data Per Company';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "App. Metadata Set Code", "Object ID", "Object Type")
        {
            Clustered = true;
        }
    }

    procedure DownloadMetadata()
    var
        InStream: InStream;
        Filename: Text;
    begin
        CalcFields(Metadata);
        Metadata.CreateInStream(InStream, TEXTENCODING::UTF8);
        Filename := 'Metadata-' + "App. Metadata Set Code" + '_' + Format("Object Type") + '-' + Format("Object ID", 0, 9) + '.xml';
        Filename := DELCHR(Filename, '=', DELCHR(Filename, '=', 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-.'));
        DownloadFromStream(InStream, '', '', '', Filename);
    end;

    procedure GetMetadataText(): BigText
    var
        ObjectMetadata: BigText;
        Character: Text;
        TempChar: Char;
        InStream: InStream;
        EmptyQueryStringErr: Label 'Empty Object metadata in Application Metadata Set:%1, Object Type:%2, Object ID:%3', Comment = '%1 = Application Metadata Set Code, %2 = Object Type, %3=Object ID';
    begin
        Rec.CalcFields(Metadata);
        if rec.Metadata.HasValue() then begin
            Rec.Metadata.CreateInStream(InStream, TEXTENCODING::UTF8);

            while not (InStream.EOS) do begin
                InStream.ReadText(Character, 1);
                if Character <> '' then begin
                    Evaluate(TempChar, Character);
                    if (TempChar <> 10) and (TempChar <> 13) then
                        ObjectMetadata.AddText(Character);
                end;
            end;
            //Message(FORMAT(ObjectMetadata));
            //ObjectMetadata.Read(InStream);
            exit(ObjectMetadata);
        end else
            Error(EmptyQueryStringErr, Rec."App. Metadata Set Code", Rec."Object Type", Rec."Object ID");
    end;
}

