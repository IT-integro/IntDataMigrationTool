table 99017 "ITI Migration SQL Query Table"
{
    Caption = 'Migration SQL Query Table';
    LookupPageId = "ITI Migration SQL Query Tables";
    DrillDownPageId = "ITI Migration SQL Query Tables";
    fields
    {
        field(1; "Migration Code"; Code[20])
        {
            Caption = 'Migration Code';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(2; "Query No."; Integer)
        {
            Caption = 'Query No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(3; "Source SQL Table Name"; Text[250])
        {
            Caption = 'Source SQL Table Name';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(20; "Target SQL Table Name"; Text[250])
        {
            Caption = 'Target SQL Table Name';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Migration Code", "Query No.", "Source SQL Table Name", "Target SQL Table Name")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ITIMigrSQLQueryFieldOpt: record "ITI Migr. SQL Query Field Opt.";
        ITIMigrationSQLQueryField: Record "ITI Migration SQL Query Field";
    begin
        ITIMigrationSQLQueryField.SetRange("Migration Code", "Migration Code");
        ITIMigrationSQLQueryField.SetRange("Query No.", "Query No.");
        ITIMigrationSQLQueryField.SetRange("Source SQL Table Name", "Source SQL Table Name");
        ITIMigrationSQLQueryField.SetRange("Target SQL Table Name", "Target SQL Table Name");
        ITIMigrationSQLQueryField.DeleteAll();

        ITIMigrSQLQueryFieldOpt.SetRange("Migration Code", "Migration Code");
        ITIMigrSQLQueryFieldOpt.SetRange("Query No.", "Query No.");
        ITIMigrSQLQueryFieldOpt.SetRange("Source SQL Table Name", "Source SQL Table Name");
        ITIMigrSQLQueryFieldOpt.SetRange("Target SQL Table Name", "Target SQL Table Name");
        ITIMigrSQLQueryFieldOpt.DeleteAll();
    end;
}

