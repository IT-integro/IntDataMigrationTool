table 99019 "PTE Migr. Ds. Tbl. Fld. Option"
{
    Caption = 'Migration Dataset Table Field Option';
    LookupPageId = "PTE Migr. Ds. Tbl. Fld. Option";
    DrillDownPageId = "PTE Migr. Ds. Tbl. Fld. Option";
    fields
    {
        field(1; "Migration Dataset Code"; Code[20])
        {
            Caption = 'Migration Dataset Code';
            TableRelation = "PTE Migration Dataset".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Source table name"; Text[150])
        {
            Caption = 'Source table name';
            TableRelation = "PTE Migration Dataset Table"."Source Table Name";
            DataClassification = ToBeClassified;
        }
        field(10; "Source SQL Database Code"; Code[20])
        {
            Caption = 'Source SQL Database Code';
            FieldClass = FlowField;
            CalcFormula = lookup("PTE Migration Dataset"."Source SQL Database Code" where(Code = field("Migration Dataset Code")));
            Editable = false;
        }
        field(30; "Source Field Name"; Text[150])
        {
            Caption = 'Source Field Name';
            ValidateTableRelation = false;
            DataClassification = ToBeClassified;
            TableRelation = "PTE App. Object Table Field".Name where("SQL Database Code" = field("Source SQL Database Code"), "Table Name" = field("Source table name"), "SQL Table Name Excl. C. Name" = filter(<> ''), "SQL Field Name" = filter(<> ''));
        }
        field(40; "Source Option ID"; Integer)
        {
            Caption = 'Source Option ID';
            DataClassification = ToBeClassified;
            trigger OnLookup()
            begin
                GetSourceObjectTableFieldOption();
            end;

            trigger OnValidate()
            begin
                if "Source Field Name" <> '' then
                    ValidateSourceObjectTableFieldOption();
            end;
        }
        field(50; "Source Option Name"; Text[250])
        {
            Caption = 'Source Option Name';
            DataClassification = ToBeClassified;
        }

        field(60; "Target SQL Database Code"; Text[250])
        {
            Caption = 'Target SQL Database Code';
            FieldClass = FlowField;
            CalcFormula = lookup("PTE Migration Dataset"."Target SQL Database Code" where(Code = field("Migration Dataset Code")));
            Editable = false;
        }
        field(70; "Target table name"; Text[150])
        {
            Caption = 'Target table name';
            FieldClass = FlowField;
            CalcFormula = lookup("PTE Migration Dataset Table"."Target Table Name" where("Source Table Name" = field("Source table name")));
            Editable = false;
        }

        field(80; "Target Field name"; Text[150])
        {
            Caption = 'Target Field name';
            FieldClass = FlowField;
            CalcFormula = lookup("PTE Migr. Dataset Table Field"."Target Field name" where("Source Table Name" = field("Source table name"), "Source Field Name" = field("Source Field Name")));
            Editable = false;
        }

        field(90; "Target Option ID"; Integer)
        {
            Caption = 'Target Option ID';
            DataClassification = ToBeClassified;
            trigger OnLookup()
            begin
                GetTargetObjectTableFieldOption();
            end;

            trigger OnValidate()
            begin
                if "Source Field Name" <> '' then
                    ValidateTargetObjectTableFieldOption();
            end;
        }
        field(100; "Target Option Name"; Text[250])
        {
            Caption = 'Target Option Name';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Migration Dataset Code", "Source table name", "Source Field Name", "Source Option ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }


    local procedure ValidateSourceObjectTableFieldOption()
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
    begin
        CalcFields("Source SQL Database Code");
        PTEMigrationDataset.Get("Migration Dataset Code");
        ValidateOptionID(PTEMigrationDataset."Source SQL Database Code", "Source table name", "Source Field Name", "Source Option ID");
    end;

    local procedure ValidateTargetObjectTableFieldOption()
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
        PTEMigrationDatasetTable: record "PTE Migration Dataset Table";
    begin
        CalcFields("Target SQL Database Code", "Target table name", "Target Field name");
        PTEMigrationDataset.Get("Migration Dataset Code");
        PTEMigrationDatasetTable.Get("Migration Dataset Code", "Source table name");
        if "Target table name" = '' then
            "Target table name" := PTEMigrationDatasetTable."Target table name";
        ValidateOptionID(PTEMigrationDataset."Target SQL Database Code", "Target table name", "Target Field Name", "Target Option ID");
    end;

    local procedure ValidateOptionID(SQLDatabaseCode: code[20]; TableName: Text[150]; FieldName: Text[150]; OptionValue: Integer)
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
        PTEAppObjectTblFieldOpt: Record "PTE App. Object Tbl.Field Opt.";
    begin
        PTEAppObjectTblFieldOpt.SetRange("SQL Database Code", SQLDatabaseCode);
        PTEAppObjectTblFieldOpt.SetRange("Table Name", TableName);
        PTEAppObjectTblFieldOpt.SetRange("Field Name", FieldName);
        PTEAppObjectTblFieldOpt.SetRange("Option ID", OptionValue);
        PTEAppObjectTblFieldOpt.FindFirst();

        PTEMigrationDataset.Get("Migration Dataset Code");
        case SQLDatabaseCode of
            PTEMigrationDataset."Source SQL Database Code":
                begin
                    "Source Option ID" := PTEAppObjectTblFieldOpt."Option ID";
                    "Source Option Name" := PTEAppObjectTblFieldOpt.Name;
                end;
            PTEMigrationDataset."Target SQL Database Code":
                begin
                    "Target Option ID" := PTEAppObjectTblFieldOpt."Option ID";
                    "Target Option Name" := PTEAppObjectTblFieldOpt.Name;
                end;
        end;
    end;

    local procedure GetSourceObjectTableFieldOption()
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
    begin
        CalcFields("Source SQL Database Code");
        PTEMigrationDataset.Get("Migration Dataset Code");
        GetObjectTableFieldOption(PTEMigrationDataset."Source SQL Database Code", "Source table name", "Source Field Name");
    end;

    local procedure GetTargetObjectTableFieldOption()
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
        PTEMigrationDatasetTable: Record "PTE Migration Dataset Table";
    begin
        CalcFields("Target SQL Database Code", "Target table name", "Target Field name");
        PTEMigrationDataset.Get("Migration Dataset Code");
        PTEMigrationDatasetTable.Get("Migration Dataset Code", "Source table name");
        "Target table name" := PTEMigrationDatasetTable."Target table name";
        GetObjectTableFieldOption(PTEMigrationDataset."Target SQL Database Code", "Target table name", "Target Field name");
    end;

    local procedure GetObjectTableFieldOption(SQLDatabaseCode: code[20]; TableName: Text[150]; FieldName: Text[150])
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
        PTEAppObjectTblFieldOpt: Record "PTE App. Object Tbl.Field Opt.";
        PagePTEAppObjectTblFieldOpt: page "PTE App. Object Tbl.Field Opt.";
    begin
        PTEAppObjectTblFieldOpt.SetRange("SQL Database Code", SQLDatabaseCode);
        PTEAppObjectTblFieldOpt.SetRange("Table Name", TableName);
        PTEAppObjectTblFieldOpt.SetRange("Field Name", FieldName);
        PagePTEAppObjectTblFieldOpt.LookupMode := true;
        PagePTEAppObjectTblFieldOpt.Editable := false;
        PagePTEAppObjectTblFieldOpt.SetTableView(PTEAppObjectTblFieldOpt);
        if PagePTEAppObjectTblFieldOpt.RunModal() = Action::LookupOK then begin
            PTEMigrationDataset.Get("Migration Dataset Code");
            PagePTEAppObjectTblFieldOpt.GetRecord(PTEAppObjectTblFieldOpt);
            case SQLDatabaseCode of
                PTEMigrationDataset."Source SQL Database Code":
                    begin
                        "Source Option ID" := PTEAppObjectTblFieldOpt."Option ID";
                        "Source Option Name" := PTEAppObjectTblFieldOpt.Name;
                    end;
                PTEMigrationDataset."Target SQL Database Code":
                    begin
                        "Target Option ID" := PTEAppObjectTblFieldOpt."Option ID";
                        "Target Option Name" := PTEAppObjectTblFieldOpt.Name;
                    end;
            end;
        end;
    end;

    trigger OnModify()
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
    begin
        PTEMigrationDataset.Get("Migration Dataset Code");
        PTEMigrationDataset.TestField(Released, false);
    end;

    trigger OnDelete()
    var
        PTEMigrDatasetError: Record "PTE Migr. Dataset Error";
    begin
        PTEMigrDatasetError.SetRange("Migration Dataset Code", "Migration Dataset Code");
        PTEMigrDatasetError.SetRange("Source Table Name", "Source Table Name");
        PTEMigrDatasetError.SetRange("Source Field Name", "Source Field Name");
        PTEMigrDatasetError.SetRange("Source Option Name", "Source Option Name");
        PTEMigrDatasetError.DeleteAll();
    end;
}

