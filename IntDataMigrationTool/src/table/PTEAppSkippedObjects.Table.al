table 99034 "PTE App Skipped Objects"
{
    Caption = 'App. Skipped Objects';
    DataClassification = ToBeClassified;

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
        field(6; "Name"; Text[250])
        {
            Caption = 'Name';
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
        field(40; "Application ID"; Text[40])
        {
            Caption = 'Application ID';
            DataClassification = ToBeClassified;
        }
        field(50; "Application Name"; Text[250])
        {
            Caption = 'Application Name';
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
}
