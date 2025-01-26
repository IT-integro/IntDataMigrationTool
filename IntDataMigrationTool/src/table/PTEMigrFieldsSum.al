table 99037 "PTE Migr. Field Sum"
{
    Caption = 'PTE Migration Field Sum';
    DataClassification = SystemMetadata;
    LookupPageId = "PTE Migr. Field Sum";
    DrillDownPageId = "PTE Migr. Field Sum";

    fields
    {
        field(1; "Migration Code"; Code[20])
        {
            Caption = 'Migration Code';
        }
        field(2; "No Of Rec. Entry No"; Integer)
        {
            Caption = 'No Of Rec. Entry No';
        }
        field(3; "Entry No"; Integer)
        {
            Caption = 'Entry No';
        }
        field(19; "Source SQL Database Code"; Code[20])
        {
            Caption = 'Source SQL Database Code';
            TableRelation = "PTE SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(20; "Source Table Name"; Text[150])
        {
            Caption = 'Source Table Name';
            DataClassification = ToBeClassified;
        }
        field(21; "Source SQL Table Name"; Text[150])
        {
            Caption = 'Source SQL Table Name';
            DataClassification = ToBeClassified;
        }
        field(22; "Source Field Name"; Text[150])
        {
            Caption = 'Source Field Name';
            DataClassification = ToBeClassified;
        }
        field(23; "Source SQL Field Name"; Text[150])
        {
            Caption = 'Source SQL Field Name';
            DataClassification = ToBeClassified;
        }
        field(29; "Target SQL Database Code"; Code[20])
        {
            Caption = 'Target SQL Database Code';
            TableRelation = "PTE SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(30; "Target Table Name"; Text[150])
        {
            Caption = 'Target Table Name';
            DataClassification = ToBeClassified;
        }
        field(31; "Target SQL Table Name"; Text[150])
        {
            Caption = 'Target SQL Table Name';
            DataClassification = ToBeClassified;
        }
        field(32; "Target Field Name"; Text[150])
        {
            Caption = 'Target Field Name';
            DataClassification = ToBeClassified;
        }
        field(33; "Target SQL Field Name"; Text[150])
        {
            Caption = 'Target SQL Field Name';
            DataClassification = ToBeClassified;
        }
        field(40; "Source Sum Value"; Decimal)
        {
            Caption = 'Source Sum Value';
            DataClassification = ToBeClassified;
        }
        field(50; "Target Sum Value"; Decimal)
        {
            Caption = 'Target Sum Value';
            DataClassification = ToBeClassified;
        }
        field(60; Difference; Decimal)
        {
            Caption = 'Difference';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Migration Code", "No Of Rec. Entry No", "Entry No")
        {
            Clustered = true;
        }
    }
}
