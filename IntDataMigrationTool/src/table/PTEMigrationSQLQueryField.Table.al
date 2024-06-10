table 99016 "PTE Migration SQL Query Field"
{
    Caption = 'Migration SQL Query Field';
    LookupPageId = "PTE Migration SQL Query Fields";
    DrillDownPageId = "PTE Migration SQL Query Fields";
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
        field(4; "Source SQL Field Name"; Text[150])
        {
            Caption = 'Source SQL Field Name';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(20; "Target SQL Table Name"; Text[250])
        {
            Caption = 'Target SQL Table Name';
            DataClassification = ToBeClassified;
        }
        field(30; "Target SQL Field Name"; Text[150])
        {
            Caption = 'Target SQL Field Name';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(40; "Constant"; Boolean)
        {
            Caption = 'Constant';
        }
    }

    keys
    {
        key(Key1; "Migration Code", "Query No.", "Source SQL Table Name", "Source SQL Field Name", "Target SQL Table Name", "Target SQL Field Name")
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
    begin
        PTEMigrSQLQueryFieldOpt.SetRange("Migration Code", "Migration Code");
        PTEMigrSQLQueryFieldOpt.SetRange("Query No.", "Query No.");
        PTEMigrSQLQueryFieldOpt.SetRange("Source SQL Table Name", "Source SQL Table Name");
        PTEMigrSQLQueryFieldOpt.SetRange("Source SQL Field Name", "Source SQL Field Name");
        PTEMigrSQLQueryFieldOpt.SetRange("Target SQL Table Name", "Target SQL Table Name");
        PTEMigrSQLQueryFieldOpt.SetRange("Target SQL Field Name", "Target SQL Field Name");
        PTEMigrSQLQueryFieldOpt.DeleteAll();
    end;
}

