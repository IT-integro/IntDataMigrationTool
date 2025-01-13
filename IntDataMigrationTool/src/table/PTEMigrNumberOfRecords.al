table 99036 "PTE Migr. Number Of Records"
{
    Caption = 'PTE Migration Number Of Records';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Migration Code"; Code[20])
        {
            Caption = 'Migration Code';
        }
        field(2; "Entry No"; Integer)
        {
            Caption = 'Migration Code';
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
        field(40; "Number of source records"; Integer)
        {
            Caption = 'Number of source records';
            DataClassification = ToBeClassified;
        }
        field(50; "Number of target records"; Integer)
        {
            Caption = 'Number of target records';
            DataClassification = ToBeClassified;
        }
        field(60; Difference; Integer)
        {
            Caption = 'Difference';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Migration Code", "Entry No")
        {
            Clustered = true;
        }
    }
}
