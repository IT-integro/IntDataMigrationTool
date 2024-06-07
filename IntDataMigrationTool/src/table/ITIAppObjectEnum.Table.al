table 99001 "ITI App. Object Enum"
{
    Caption = 'Application Object Enum';
    DrillDownPageID = "ITI App. Object Enums";
    LookupPageID = "ITI App. Object Enums";
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
        field(10; Name; Text[150])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
        field(20; Extensible; Boolean)
        {
            Caption = 'Extensible';
            DataClassification = ToBeClassified;
        }
        field(30; AssignmentCompatibility; Text[150])
        {
            Caption = 'AssignmentCompatibility';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "SQL Database Code", "ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ITIAppObjectEnumValue: record "ITI App. Object Enum Value";

    begin
        ITIAppObjectEnumValue.SetRange("SQL Database Code", "SQL Database Code");
        ITIAppObjectEnumValue.SetRange("Enum ID", ID);
        ITIAppObjectEnumValue.DeleteAll();
    end;
}

