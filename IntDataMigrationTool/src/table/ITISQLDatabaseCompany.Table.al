table 99003 "ITI SQL Database Company"
{
    Caption = 'SQL Database Company';
    DrillDownPageID = "ITI SQL Database Companies";
    LookupPageID = "ITI SQL Database Companies";
    fields
    {
        field(1; "SQL Database Code"; Code[20])
        {
            Caption = 'SQL Database Code';
            TableRelation = "ITI SQL Database".Code;
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

