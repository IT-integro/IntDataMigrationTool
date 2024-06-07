table 99006 "ITI Migration"
{
    Caption = 'Migration';
    LookupPageId = "ITI Migrations";
    DrillDownPageId = "ITI Migrations";
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(2; "Migration Dataset Code"; Code[20])
        {
            Caption = 'Migration Dataset Code';
            DataClassification = ToBeClassified;
            TableRelation = "ITI Migration Dataset".Code;
            ValidateTableRelation = true;
            trigger OnValidate()
            var
                ITIMigrationDataset: Record "ITI Migration Dataset";
            begin
                if "Migration Dataset Code" = '' then begin
                    "Source SQL Database Code" := '';
                    "Target SQL Database Code" := '';
                end else begin
                    ITIMigrationDataset.Get("Migration Dataset Code");
                    "Source SQL Database Code" := ITIMigrationDataset."Source SQL Database Code";
                    "Target SQL Database Code" := ITIMigrationDataset."Target SQL Database Code";
                end;
            end;
        }
        field(10; "Source SQL Database Code"; Code[20])
        {
            Caption = 'Source SQL Database Code';
            TableRelation = "ITI SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(20; "Source Company Name"; Text[150])
        {
            Caption = 'Source Company Name';
            TableRelation = "ITI SQL Database Company".Name where("SQL Database Code" = field("Source SQL Database Code"));
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(30; "Target SQL Database Code"; Code[20])
        {
            Caption = 'Target SQL Database Code';
            TableRelation = "ITI SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(40; "Target Company Name"; Text[150])
        {
            Caption = 'Target Company Name';
            TableRelation = "ITI SQL Database Company".Name where("SQL Database Code" = field("Target SQL Database Code"));
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(45; "Do Not Use Transaction"; Boolean)
        {
            Caption = 'Do Not Use Transaction';
            DataClassification = ToBeClassified;
        }
        field(50; "Generated Queries"; Boolean)
        {
            Caption = 'Generated Queries';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(60; "Executed"; Boolean)
        {
            Caption = 'Executed';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(70; "Execute On"; Enum "ITI Execute Target Database")
        {
            Caption = 'Execute On';
            DataClassification = ToBeClassified;
        }
        field(200; "Linked Server Query"; Blob)
        {
            Caption = 'Linked Server Query';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ITIMigrationSQLQuery: Record "ITI Migration SQL Query";
        ITIMigrationSQLQueryTable: Record "ITI Migration SQL Query Table";
        ITIMigrationSQLQueryField: Record "ITI Migration SQL Query Field";
        ITIMigrSQLQueryFieldOpt: record "ITI Migr. SQL Query Field Opt.";
    begin
        ITIMigrationSQLQuery.SetRange("Migration Code", Code);
        ITIMigrationSQLQuery.DeleteAll();
        ITIMigrationSQLQueryTable.SetRange("Migration Code", Code);
        ITIMigrationSQLQueryTable.DeleteAll();
        ITIMigrationSQLQueryField.SetRange("Migration Code", Code);
        ITIMigrationSQLQueryField.DeleteAll();
        ITIMigrSQLQueryFieldOpt.SetRange("Migration Code", Code);
        ITIMigrSQLQueryFieldOpt.DeleteAll();
    end;

    procedure GenerateSQLQueries(SkipConfirmation: Boolean; SelectedQuerySourceTableName: Text[150])
    var
        ITIMigrationGenerateQueries: Codeunit "ITI Migration Generate Queries";
    begin
        ITIMigrationGenerateQueries.GenerateQueries(Rec, SkipConfirmation, SelectedQuerySourceTableName);
    end;

    procedure RunMigration(SkipConfirmation: Boolean)
    var
        ITIRunMigration: Codeunit "ITI Run Migration";
    begin
        ITIRunMigration.RunMigration(Rec, SkipConfirmation);
    end;
}

