table 99020 "PTE Migr. SQL Query Field Opt."
{
    Caption = 'Migration SQL Query Field Option';
    LookupPageId = "PTE Migr. SQL Query Field Opt.";
    DrillDownPageId = "PTE Migr. SQL Query Field Opt.";
    fields
    {
        field(1; "Migration Code"; Code[20])
        {
            Caption = 'Migration Code';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Query No."; Integer)
        {
            Caption = 'Query No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(3; "Source SQL Table Name"; Text[250])
        {
            Caption = 'Source SQL Table Name';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "Source SQL Field Name"; Text[150])
        {
            Caption = 'Source SQL Field Name';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(5; "Source SQL Field Option"; Integer)
        {
            Caption = 'Source SQL Field Option';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(20; "Target SQL Table Name"; Text[250])
        {
            Caption = 'Target SQL Table Name';
            DataClassification = ToBeClassified;
        }
        field(30; "Target SQL Field Name"; Text[150])
        {
            Caption = 'Target SQL Field Name';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(40; "Target SQL Field Option"; Integer)
        {
            Caption = 'Target SQL Field Option';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Migration Code", "Query No.", "Source SQL Table Name", "Source SQL Field Name", "Source SQL Field Option", "Target SQL Table Name", "Target SQL Field Name", "Target SQL Field Option")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

