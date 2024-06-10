table 99006 "PTE Migration"
{
    Caption = 'Migration';
    LookupPageId = "PTE Migrations";
    DrillDownPageId = "PTE Migrations";
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
            TableRelation = "PTE Migration Dataset".Code;
            ValidateTableRelation = true;
            trigger OnValidate()
            var
                PTEMigrationDataset: Record "PTE Migration Dataset";
            begin
                if "Migration Dataset Code" = '' then begin
                    "Source SQL Database Code" := '';
                    "Target SQL Database Code" := '';
                end else begin
                    PTEMigrationDataset.Get("Migration Dataset Code");
                    "Source SQL Database Code" := PTEMigrationDataset."Source SQL Database Code";
                    "Target SQL Database Code" := PTEMigrationDataset."Target SQL Database Code";
                end;
            end;
        }
        field(10; "Source SQL Database Code"; Code[20])
        {
            Caption = 'Source SQL Database Code';
            TableRelation = "PTE SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(20; "Source Company Name"; Text[150])
        {
            Caption = 'Source Company Name';
            TableRelation = "PTE SQL Database Company".Name where("SQL Database Code" = field("Source SQL Database Code"));
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(30; "Target SQL Database Code"; Code[20])
        {
            Caption = 'Target SQL Database Code';
            TableRelation = "PTE SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(40; "Target Company Name"; Text[150])
        {
            Caption = 'Target Company Name';
            TableRelation = "PTE SQL Database Company".Name where("SQL Database Code" = field("Target SQL Database Code"));
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
        field(70; "Execute On"; Enum "PTE Execute Target Database")
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
        PTEMigrationSQLQuery: Record "PTE Migration SQL Query";
        PTEMigrationSQLQueryTable: Record "PTE Migration SQL Query Table";
        PTEMigrationSQLQueryField: Record "PTE Migration SQL Query Field";
        PTEMigrSQLQueryFieldOpt: record "PTE Migr. SQL Query Field Opt.";
    begin
        PTEMigrationSQLQuery.SetRange("Migration Code", Code);
        PTEMigrationSQLQuery.DeleteAll();
        PTEMigrationSQLQueryTable.SetRange("Migration Code", Code);
        PTEMigrationSQLQueryTable.DeleteAll();
        PTEMigrationSQLQueryField.SetRange("Migration Code", Code);
        PTEMigrationSQLQueryField.DeleteAll();
        PTEMigrSQLQueryFieldOpt.SetRange("Migration Code", Code);
        PTEMigrSQLQueryFieldOpt.DeleteAll();
    end;

    procedure GenerateSQLQueries(SkipConfirmation: Boolean; SelectedQuerySourceTableName: Text[150])
    var
        PTEMigrationGenerateQueries: Codeunit "PTE Migration Generate Queries";
    begin
        PTEMigrationGenerateQueries.GenerateQueries(Rec, SkipConfirmation, SelectedQuerySourceTableName);
    end;

    procedure RunMigration(SkipConfirmation: Boolean)
    var
        PTERunMigration: Codeunit "PTE Run Migration";
    begin
        PTERunMigration.RunMigration(Rec, SkipConfirmation);
    end;
}

