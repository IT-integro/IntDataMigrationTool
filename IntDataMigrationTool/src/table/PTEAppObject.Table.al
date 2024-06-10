table 99012 "PTE App. Object"
{
    Caption = 'Application Object';
    DrillDownPageID = "PTE App. Objects";
    LookupPageID = "PTE App. Objects";
    fields
    {
        field(1; "SQL Database Code"; Code[20])
        {
            Caption = 'SQL Database Code';
            TableRelation = "PTE SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(2; "ID"; Integer)
        {
            Caption = 'ID';
            DataClassification = ToBeClassified;
        }
        field(3; "Type"; Enum "PTE Object Type")
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
        PTEGetMetadata: Codeunit "PTE Get Metadata";
    begin
        PTEGetMetadata.DownloadObject(Rec);
    end;
}

