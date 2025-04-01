table 99015 "PTE App. Object Tbl.Field Opt."
{
    Caption = 'Application Object Table Field Option';
    DrillDownPageID = "PTE App. Object Tbl.Field Opt.";
    LookupPageID = "PTE App. Object Tbl.Field Opt.";
    fields
    {
        field(1; "SQL Database Code"; Code[20])
        {
            Caption = 'SQL Database Code';
            TableRelation = "PTE SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = "PTE App. Object Table"."ID";
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(3; "Field ID"; Integer)
        {
            Caption = 'Field ID';
            TableRelation = "PTE App. Object Table Field"."ID" where("Table ID" = field("Table ID"));
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(4; "Table Name"; Text[150])
        {
            Caption = 'Table Name';
            TableRelation = "PTE App. Object Table"."Name" where("SQL Database Code" = field("SQL Database Code"), "ID" = field("Table ID"));
            Editable = false;
            ValidateTableRelation = true;
        }
        field(5; "Field Name"; Text[150])
        {
            Caption = 'Field Name';
            TableRelation = "PTE App. Object Table Field"."Name" where("SQL Database Code" = field("SQL Database Code"), "Table ID" = field("Table ID"), ID = field("Field ID"));
            Editable = false;
            ValidateTableRelation = true;
        }
        field(30; "Option ID"; Integer)
        {
            Caption = 'Option ID';
            DataClassification = ToBeClassified;
        }
        field(10; Name; Text[250])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "SQL Database Code", "Table ID", "Field ID", "Option ID")
        {
            Clustered = true;
        }
        key(Key3; "SQL Database Code", "Table Name", "Field Name", "Option ID")
        {
            Unique = true;
        }
    }

    fieldgroups
    {
    }
}

