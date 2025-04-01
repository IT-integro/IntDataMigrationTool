table 99001 "PTE App. Object Enum"
{
    Caption = 'Application Object Enum';
    DrillDownPageID = "PTE App. Object Enums";
    LookupPageID = "PTE App. Object Enums";
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
        PTEAppObjectEnumValue: record "PTE App. Object Enum Value";

    begin
        PTEAppObjectEnumValue.SetRange("SQL Database Code", "SQL Database Code");
        PTEAppObjectEnumValue.SetRange("Enum ID", ID);
        PTEAppObjectEnumValue.DeleteAll();
    end;
}

