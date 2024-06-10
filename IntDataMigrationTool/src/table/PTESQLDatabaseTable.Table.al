table 99010 "PTE SQL Database Table"
{
    Caption = 'SQL Database Table';
    DrillDownPageID = "PTE SQL Database Tables";
    LookupPageID = "PTE SQL Database Tables";
    fields
    {
        field(1; "SQL Database Code"; Code[20])
        {
            Caption = 'SQL Database Code';
            TableRelation = "PTE SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
        }
        field(20; "Table Catalog"; Text[128])
        {
            Caption = 'Table Catalog';
            DataClassification = ToBeClassified;
        }
        field(30; "Table Schema"; Text[128])
        {
            Caption = 'Table Schema';
            DataClassification = ToBeClassified;
        }
        field(40; "Table Name"; Text[128])
        {
            Caption = 'Table Name';
            DataClassification = ToBeClassified;
        }
        field(50; "Table Type"; Text[128])
        {
            Caption = 'Table Type';
            DataClassification = ToBeClassified;
        }
        field(60; "Number Of Records"; Integer)
        {
            Caption = 'Number Of Records';
            DataClassification = ToBeClassified;
        }
        field(520; "App ID"; Text[250])
        {
            Caption = 'App ID';
            DataClassification = ToBeClassified;
            TableRelation = "PTE SQL Database Installed App"."ID" WHERE("SQL Database Code" = FIELD("SQL Database Code"));
        }
        field(530; "App Name"; Text[250])
        {
            Caption = 'App Name';
            FieldClass = FlowField;
            CalcFormula = Lookup("PTE SQL Database Installed App".Name WHERE("SQL Database Code" = FIELD("SQL Database Code"), "ID" = field("App ID")));

        }
        field(540; "App Publisher"; Text[250])
        {
            Caption = 'App Publisher';
            CalcFormula = Lookup("PTE SQL Database Installed App".Publisher WHERE("SQL Database Code" = field("SQL Database Code"), "ID" = field("App ID")));
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "SQL Database Code", "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "SQL Database Code", "Table Name", "Table Type")
        {

        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        PTESQLDatabaseTableField: Record "PTE SQL Database Table Field";
    begin
        PTESQLDatabaseTableField.SetRange("SQL Database Code", "SQL Database Code");
        PTESQLDatabaseTableField.SetRange("Table Catalog", "Table Catalog");
        PTESQLDatabaseTableField.SetRange("Table Schema", "Table Schema");
        PTESQLDatabaseTableField.SetRange("Table Name", "Table Name");
        PTESQLDatabaseTableField.DeleteAll();
    end;
}

