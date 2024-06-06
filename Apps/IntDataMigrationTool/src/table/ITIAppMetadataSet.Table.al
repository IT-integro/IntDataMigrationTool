table 99028 "ITI App. Metadata Set"
{
    Caption = 'Application Metadata Set';
    DrillDownPageID = "ITI App. Metadata Set List";
    LookupPageID = "ITI App. Metadata Set List";
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(10; "Description"; Text[150])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ITIAppMetadataSetObject: Record "ITI App. Metadata Set Object";
    begin
        ITIAppMetadataSetObject.SetRange("App. Metadata Set Code", Code);
        ITIAppMetadataSetObject.DeleteAll();
    end;

    Procedure ImportMetadataSetFromFile()
    var
        ITIImportMetadataFromFile: Codeunit "ITI Import Metadata From File";
    begin
        ITIImportMetadataFromFile.ImportMetadata(Rec);
    end;
}

