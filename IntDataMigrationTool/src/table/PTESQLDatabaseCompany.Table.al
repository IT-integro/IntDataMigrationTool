table 99003 "PTE SQL Database Company"
{
    Caption = 'SQL Database Company';
    DrillDownPageID = "PTE SQL Database Companies";
    LookupPageID = "PTE SQL Database Companies";
    fields
    {
        field(1; "SQL Database Code"; Code[20])
        {
            Caption = 'SQL Database Code';
            TableRelation = "PTE SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Name"; Text[150])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
        field(10; "SQL Name"; Text[150])
        {
            Caption = 'SQL Name';
            DataClassification = ToBeClassified;
        }

    }

    keys
    {
        key(Key1; "SQL Database Code", "Name")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

