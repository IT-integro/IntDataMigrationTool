table 99007 "ITI Migration SQL Query"
{
    Caption = 'Migration SQL Query';
    LookupPageId = "ITI Migration SQL Queries";
    DrillDownPageId = "ITI Migration SQL Queries";
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
            CalcFormula = exist("ITI Migr. Background Session" where("Migration Code" = field("Migration Code"), "Query No." = field("Query No."), "Is Active" = const(true)));
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
        ITIMigrationSQLQueryTable: Record "ITI Migration SQL Query Table";
        ITIMigrationSQLQueryField: Record "ITI Migration SQL Query Field";
        ITIMigrSQLQueryFieldOpt: record "ITI Migr. SQL Query Field Opt.";
    begin
        ITIMigrationSQLQueryTable.SetRange("Migration Code", "Migration Code");
        ITIMigrationSQLQueryTable.SetRange("Query No.", "Query No.");
        ITIMigrationSQLQueryTable.DeleteAll();
        ITIMigrationSQLQueryField.SetRange("Migration Code", "Migration Code");
        ITIMigrationSQLQueryField.SetRange("Query No.", "Query No.");
        ITIMigrationSQLQueryField.DeleteAll();
        ITIMigrSQLQueryFieldOpt.SetRange("Migration Code", "Migration Code");
        ITIMigrSQLQueryFieldOpt.SetRange("Query No.", "Query No.");
        ITIMigrSQLQueryFieldOpt.DeleteAll();
    end;

    procedure RunMigration(SkipConfirmation: Boolean)
    var
        ITIRunMigrationSQLQuery: Codeunit "ITI Run Migration SQL Query";
    begin
        if not SkipConfirmation then
            if not confirm(RunConfirmarionMsg) then
                exit;
        ITIRunMigrationSQLQuery.Run(Rec);
        if not SkipConfirmation then
            Message(ConfirmarionMsg);
    end;

    procedure RunMigrationInBackground(SkipConfirmation: Boolean)
    var
        ITIRunMigrSQLQueryBackgr: codeunit "ITI Run Migr.SQL Query Backgr.";
    begin
        if not SkipConfirmation then
            if not confirm(RunConfirmarionMsg) then
                exit;
        ITIRunMigrSQLQueryBackgr.Run(Rec);
    end;

    var
        RunConfirmarionMsg: label 'This operation will delete data in target tables and migrate data from source tables to target tables. Do you want to continue ?';
        ConfirmarionMsg: Label 'Query has been executed successfully';

    procedure GenerateSQLQuery(SkipConfirmation: Boolean; SelectedQuerySourceTableName: Text[150])
    var
        ITIMigrationGenerateQueries: Codeunit "ITI Migration Generate Queries";
    begin
        ITIMigrationGenerateQueries.GenerateQuery(Rec, SkipConfirmation, SelectedQuerySourceTableName);
    end;
}

