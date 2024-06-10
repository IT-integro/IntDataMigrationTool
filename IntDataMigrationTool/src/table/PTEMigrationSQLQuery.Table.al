table 99007 "PTE Migration SQL Query"
{
    Caption = 'Migration SQL Query';
    LookupPageId = "PTE Migration SQL Queries";
    DrillDownPageId = "PTE Migration SQL Queries";
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
            Caption = 'Query No';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(3; "SourceTableName"; Text[150])
        {
            Caption = 'Migration Code';
            DataClassification = ToBeClassified;
            Editable = false;

        }
        field(10; "Description"; Text[250])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(20; "Query"; Blob)
        {
            Caption = 'Query';
            DataClassification = ToBeClassified;
        }
        field(15; "Modified"; Boolean)
        {
            Caption = 'Modified';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(30; "Executed"; Boolean)
        {
            Caption = 'Executed';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(40; "Running in Background Session"; Boolean)
        {
            Caption = 'Running in Background Session';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("PTE Migr. Background Session" where("Migration Code" = field("Migration Code"), "Query No." = field("Query No."), "Is Active" = const(true)));
        }
    }

    keys
    {
        key(Key1; "Migration Code", "Query No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        PTEMigrationSQLQueryTable: Record "PTE Migration SQL Query Table";
        PTEMigrationSQLQueryField: Record "PTE Migration SQL Query Field";
        PTEMigrSQLQueryFieldOpt: record "PTE Migr. SQL Query Field Opt.";
    begin
        PTEMigrationSQLQueryTable.SetRange("Migration Code", "Migration Code");
        PTEMigrationSQLQueryTable.SetRange("Query No.", "Query No.");
        PTEMigrationSQLQueryTable.DeleteAll();
        PTEMigrationSQLQueryField.SetRange("Migration Code", "Migration Code");
        PTEMigrationSQLQueryField.SetRange("Query No.", "Query No.");
        PTEMigrationSQLQueryField.DeleteAll();
        PTEMigrSQLQueryFieldOpt.SetRange("Migration Code", "Migration Code");
        PTEMigrSQLQueryFieldOpt.SetRange("Query No.", "Query No.");
        PTEMigrSQLQueryFieldOpt.DeleteAll();
    end;

    procedure RunMigration(SkipConfirmation: Boolean)
    var
        PTERunMigrationSQLQuery: Codeunit "PTE Run Migration SQL Query";
    begin
        if not SkipConfirmation then
            if not confirm(RunConfirmarionMsg) then
                exit;
        PTERunMigrationSQLQuery.Run(Rec);
        if not SkipConfirmation then
            Message(ConfirmarionMsg);
    end;

    procedure RunMigrationInBackground(SkipConfirmation: Boolean)
    var
        PTERunMigrSQLQueryBackgr: codeunit "PTE Run Migr.SQL Query Backgr.";
    begin
        if not SkipConfirmation then
            if not confirm(RunConfirmarionMsg) then
                exit;
        PTERunMigrSQLQueryBackgr.Run(Rec);
    end;

    var
        RunConfirmarionMsg: label 'This operation will delete data in target tables and migrate data from source tables to target tables. Do you want to continue ?';
        ConfirmarionMsg: Label 'Query has been executed successfully';

    procedure GenerateSQLQuery(SkipConfirmation: Boolean; SelectedQuerySourceTableName: Text[150])
    var
        PTEMigrationGenerateQueries: Codeunit "PTE Migration Generate Queries";
    begin
        PTEMigrationGenerateQueries.GenerateQuery(Rec, SkipConfirmation, SelectedQuerySourceTableName);
    end;
}

