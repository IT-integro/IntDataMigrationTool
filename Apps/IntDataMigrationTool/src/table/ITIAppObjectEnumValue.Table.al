table 99002 "ITI App. Object Enum Value"
{
    Caption = 'Application Object Enum Value';
    DrillDownPageID = "ITI App. Object Enum Values";
    LookupPageID = "ITI App. Object Enum Values";
    fields
    {
        field(1; "SQL Database Code"; Code[20])
        {
            Caption = 'SQL Database Code';
            TableRelation = "ITI SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Enum ID"; Integer)
        {
            Caption = 'Enum ID';
            TableRelation = "ITI App. Object Enum".ID;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(3; Ordinal; Integer)
        {
            Caption = 'Ordinal';
            DataClassification = ToBeClassified;
        }
        field(4; Name; Text[250])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "SQL Database Code", "Enum ID", Ordinal)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }


}

