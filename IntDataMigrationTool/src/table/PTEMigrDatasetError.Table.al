table 99025 "PTE Migr. Dataset Error"
{
    Caption = 'PTE Migr. Dataset Errors';
    DrillDownPageId = "PTE Migr. Dataset Errors";
    LookupPageId = "PTE Migr. Dataset Errors";

    fields
    {
        field(1; "Migration Dataset Code"; Code[20])
        {
            Caption = 'Migration Dataset Code';
            TableRelation = "PTE Migration Dataset".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Source Table Name"; Text[150])
        {
            Caption = 'Source Table Name';
            TableRelation = "PTE Migration Dataset Table"."Source Table Name";
            DataClassification = ToBeClassified;
        }
        field(3; "Source Field Name"; Text[150])
        {
            Caption = 'Source Field Name';
            DataClassification = ToBeClassified;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = ToBeClassified;
        }
        field(10; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = ToBeClassified;
        }
        field(20; "Error Type"; Enum "PTE Dataset Error Types")
        {
            DataClassification = ToBeClassified;
            Caption = 'Error Type';
        }
        field(30; "Source Obsolete State"; Text[150])
        {
            DataClassification = ToBeClassified;
            Caption = 'Source Obsolete State';
        }
        field(40; "Source Obsolete Reason"; Text[500])
        {
            DataClassification = ToBeClassified;
            Caption = 'Source Obsolete Reason';
        }
        field(50; "Target Obsolete State"; Text[150])
        {
            DataClassification = ToBeClassified;
            Caption = 'Target Obsolete State';
        }
        field(60; "Target Obsolete Reason"; Text[500])
        {
            DataClassification = ToBeClassified;
            Caption = 'Target Obsolete Reason';
        }
        field(100; "Source Option Name"; Text[250])
        {
            DataClassification = ToBeClassified;
            Caption = 'Source Option Name';
        }
        field(110; Ignore; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Ignore';
        }
    }
    keys
    {
        key(PK; "Migration Dataset Code", "Source Table Name", "Source Field Name", "Line No.")
        {
            Clustered = true;
        }
    }
}
