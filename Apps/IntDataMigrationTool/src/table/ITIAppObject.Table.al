table 99012 "ITI App. Object"
{
    Caption = 'Application Object';
    DrillDownPageID = "ITI App. Objects";
    LookupPageID = "ITI App. Objects";
    fields
    {
        field(1; "SQL Database Code"; Code[20])
        {
            Caption = 'SQL Database Code';
            TableRelation = "ITI SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(2; "ID"; Integer)
        {
            Caption = 'ID';
            DataClassification = ToBeClassified;
        }
        field(3; "Type"; Enum "ITI Object Type")
        {
            Caption = 'Type';
            DataClassification = ToBeClassified;
        }
        field(5; "Source"; Text[250])
        {
            Caption = 'Source';
            DataClassification = ToBeClassified;
        }
        field(10; "Subtype"; Text[250])
        {
            Caption = 'Subtype';
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
    }

    keys
    {
        key(Key1; "SQL Database Code", "ID", "Type", "Source")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    Procedure DownloadMetadata()
    var
        ITIGetMetadata: Codeunit "ITI Get Metadata";
    begin
        ITIGetMetadata.DownloadObject(Rec);
    end;
}

