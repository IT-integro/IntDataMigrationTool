table 99017 "PTE Migration SQL Query Table"
{
    Caption = 'Migration SQL Query Table';
    LookupPageId = "PTE Migration SQL Query Tables";
    DrillDownPageId = "PTE Migration SQL Query Tables";
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
        PTEMigrSQLQueryFieldOpt: record "PTE Migr. SQL Query Field Opt.";
        PTEMigrationSQLQueryField: Record "PTE Migration SQL Query Field";
    begin
        PTEMigrationSQLQueryField.SetRange("Migration Code", "Migration Code");
        PTEMigrationSQLQueryField.SetRange("Query No.", "Query No.");
        PTEMigrationSQLQueryField.SetRange("Source SQL Table Name", "Source SQL Table Name");
        PTEMigrationSQLQueryField.SetRange("Target SQL Table Name", "Target SQL Table Name");
        PTEMigrationSQLQueryField.DeleteAll();

        PTEMigrSQLQueryFieldOpt.SetRange("Migration Code", "Migration Code");
        PTEMigrSQLQueryFieldOpt.SetRange("Query No.", "Query No.");
        PTEMigrSQLQueryFieldOpt.SetRange("Source SQL Table Name", "Source SQL Table Name");
        PTEMigrSQLQueryFieldOpt.SetRange("Target SQL Table Name", "Target SQL Table Name");
        PTEMigrSQLQueryFieldOpt.DeleteAll();
    end;
}

