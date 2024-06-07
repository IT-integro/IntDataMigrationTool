table 99009 "ITI SQL Database Table Field"
{
    Caption = 'SQL Database Table Field';
    DrillDownPageID = "ITI SQL Database Table Fields";
    LookupPageID = "ITI SQL Database Table Fields";
    fields
    {
        field(1; "SQL Database Code"; Code[20])
        {
            Caption = 'SQL Database Code';
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
        field(50; "Column Name"; Text[128])
        {
            Caption = 'Column Name';
            DataClassification = ToBeClassified;
        }
        field(60; "Ordinal Position"; Integer)
        {
            Caption = 'Ordinal Position';
            DataClassification = ToBeClassified;
        }
        field(70; "Data Type"; Text[128])
        {
            Caption = 'Data Type';
            DataClassification = ToBeClassified;
        }
        field(80; "Character Maximum Length"; Integer)
        {
            Caption = 'Character Maximum Length';
            DataClassification = ToBeClassified;
        }
        field(90; "Character Octet Lenght"; Integer)
        {
            Caption = 'Character Octet Lenght';
            DataClassification = ToBeClassified;
        }
        field(100; "Allow Nulls"; Boolean)
        {
            Caption = 'Allow Nulls';
            DataClassification = ToBeClassified;
        }
        field(110; "Column Default"; Text[150])
        {
            Caption = 'Column Default';
            DataClassification = ToBeClassified;
        }
        field(120; "Autoincrement"; Boolean)
        {
            Caption = 'Autoincrement';
            DataClassification = ToBeClassified;
        }
        field(130; "Collation Name"; text[150])
        {
            Caption = 'Collation Name';
            DataClassification = ToBeClassified;
        }
        field(140; "Character Set Name"; text[250])
        {
            Caption = 'Character Set Name';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "SQL Database Code", "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "SQL Database Code", "Table Name", "Column Name")
        {

        }
        key(Key3; "SQL Database Code", "Table Name", "Column Name", "Allow Nulls", "Column Default")
        {

        }

    }

    fieldgroups
    {
    }
}

