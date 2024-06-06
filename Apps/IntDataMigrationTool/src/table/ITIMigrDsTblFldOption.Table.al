table 99019 "ITI Migr. Ds. Tbl. Fld. Option"
{
    Caption = 'Migration Dataset Table Field Option';
    LookupPageId = "ITI Migr. Ds. Tbl. Fld. Option";
    DrillDownPageId = "ITI Migr. Ds. Tbl. Fld. Option";
    fields
    {
        field(1; "Migration Dataset Code"; Code[20])
        {
            Caption = 'Migration Dataset Code';
            TableRelation = "ITI Migration Dataset".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Source table name"; Text[150])
        {
            Caption = 'Source table name';
            TableRelation = "ITI Migration Dataset Table"."Source Table Name";
            DataClassification = ToBeClassified;
        }
        field(10; "Source SQL Database Code"; Code[20])
        {
            Caption = 'Source SQL Database Code';
            FieldClass = FlowField;
            CalcFormula = lookup("ITI Migration Dataset"."Source SQL Database Code" where(Code = field("Migration Dataset Code")));
            Editable = false;
        }
        field(30; "Source Field Name"; Text[150])
        {
            Caption = 'Source Field Name';
            ValidateTableRelation = false;
            DataClassification = ToBeClassified;
            TableRelation = "ITI App. Object Table Field".Name where("SQL Database Code" = field("Source SQL Database Code"), "Table Name" = field("Source table name"), "SQL Table Name Excl. C. Name" = filter(<> ''), "SQL Field Name" = filter(<> ''));
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
            CalcFormula = lookup("ITI Migration Dataset"."Target SQL Database Code" where(Code = field("Migration Dataset Code")));
            Editable = false;
        }
        field(70; "Target table name"; Text[150])
        {
            Caption = 'Target table name';
            FieldClass = FlowField;
            CalcFormula = lookup("ITI Migration Dataset Table"."Target Table Name" where("Source Table Name" = field("Source table name")));
            Editable = false;
        }

        field(80; "Target Field name"; Text[150])
        {
            Caption = 'Target Field name';
            FieldClass = FlowField;
            CalcFormula = lookup("ITI Migr. Dataset Table Field"."Target Field name" where("Source Table Name" = field("Source table name"), "Source Field Name" = field("Source Field Name")));
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
        ITIMigrationDataset: Record "ITI Migration Dataset";
    begin
        CalcFields("Source SQL Database Code");
        ITIMigrationDataset.Get("Migration Dataset Code");
        ValidateOptionID(ITIMigrationDataset."Source SQL Database Code", "Source table name", "Source Field Name", "Source Option ID");
    end;

    local procedure ValidateTargetObjectTableFieldOption()
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
        ITIMigrationDatasetTable: record "ITI Migration Dataset Table";
    begin
        CalcFields("Target SQL Database Code", "Target table name", "Target Field name");
        ITIMigrationDataset.Get("Migration Dataset Code");
        ITIMigrationDatasetTable.Get("Migration Dataset Code", "Source table name");
        if "Target table name" = '' then
            "Target table name" := ITIMigrationDatasetTable."Target table name";
        ValidateOptionID(ITIMigrationDataset."Target SQL Database Code", "Target table name", "Target Field Name", "Target Option ID");
    end;

    local procedure ValidateOptionID(SQLDatabaseCode: code[20]; TableName: Text[150]; FieldName: Text[150]; OptionValue: Integer)
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
        ITIAppObjectTblFieldOpt: Record "ITI App. Object Tbl.Field Opt.";
    begin
        ITIAppObjectTblFieldOpt.SetRange("SQL Database Code", SQLDatabaseCode);
        ITIAppObjectTblFieldOpt.SetRange("Table Name", TableName);
        ITIAppObjectTblFieldOpt.SetRange("Field Name", FieldName);
        ITIAppObjectTblFieldOpt.SetRange("Option ID", OptionValue);
        ITIAppObjectTblFieldOpt.FindFirst();

        ITIMigrationDataset.Get("Migration Dataset Code");
        case SQLDatabaseCode of
            ITIMigrationDataset."Source SQL Database Code":
                begin
                    "Source Option ID" := ITIAppObjectTblFieldOpt."Option ID";
                    "Source Option Name" := ITIAppObjectTblFieldOpt.Name;
                end;
            ITIMigrationDataset."Target SQL Database Code":
                begin
                    "Target Option ID" := ITIAppObjectTblFieldOpt."Option ID";
                    "Target Option Name" := ITIAppObjectTblFieldOpt.Name;
                end;
        end;
    end;

    local procedure GetSourceObjectTableFieldOption()
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
    begin
        CalcFields("Source SQL Database Code");
        ITIMigrationDataset.Get("Migration Dataset Code");
        GetObjectTableFieldOption(ITIMigrationDataset."Source SQL Database Code", "Source table name", "Source Field Name");
    end;

    local procedure GetTargetObjectTableFieldOption()
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
        ITIMigrationDatasetTable: Record "ITI Migration Dataset Table";
    begin
        CalcFields("Target SQL Database Code", "Target table name", "Target Field name");
        ITIMigrationDataset.Get("Migration Dataset Code");
        ITIMigrationDatasetTable.Get("Migration Dataset Code", "Source table name");
        "Target table name" := ITIMigrationDatasetTable."Target table name";
        GetObjectTableFieldOption(ITIMigrationDataset."Target SQL Database Code", "Target table name", "Target Field name");
    end;

    local procedure GetObjectTableFieldOption(SQLDatabaseCode: code[20]; TableName: Text[150]; FieldName: Text[150])
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
        ITIAppObjectTblFieldOpt: Record "ITI App. Object Tbl.Field Opt.";
        PageITIAppObjectTblFieldOpt: page "ITI App. Object Tbl.Field Opt.";
    begin
        ITIAppObjectTblFieldOpt.SetRange("SQL Database Code", SQLDatabaseCode);
        ITIAppObjectTblFieldOpt.SetRange("Table Name", TableName);
        ITIAppObjectTblFieldOpt.SetRange("Field Name", FieldName);
        PageITIAppObjectTblFieldOpt.LookupMode := true;
        PageITIAppObjectTblFieldOpt.Editable := false;
        PageITIAppObjectTblFieldOpt.SetTableView(ITIAppObjectTblFieldOpt);
        if PageITIAppObjectTblFieldOpt.RunModal() = Action::LookupOK then begin
            ITIMigrationDataset.Get("Migration Dataset Code");
            PageITIAppObjectTblFieldOpt.GetRecord(ITIAppObjectTblFieldOpt);
            case SQLDatabaseCode of
                ITIMigrationDataset."Source SQL Database Code":
                    begin
                        "Source Option ID" := ITIAppObjectTblFieldOpt."Option ID";
                        "Source Option Name" := ITIAppObjectTblFieldOpt.Name;
                    end;
                ITIMigrationDataset."Target SQL Database Code":
                    begin
                        "Target Option ID" := ITIAppObjectTblFieldOpt."Option ID";
                        "Target Option Name" := ITIAppObjectTblFieldOpt.Name;
                    end;
            end;
        end;
    end;

    trigger OnModify()
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
    begin
        ITIMigrationDataset.Get("Migration Dataset Code");
        ITIMigrationDataset.TestField(Released, false);
    end;

    trigger OnDelete()
    var
        ITIMigrDatasetError: Record "ITI Migr. Dataset Error";
    begin
        ITIMigrDatasetError.SetRange("Migration Dataset Code", "Migration Dataset Code");
        ITIMigrDatasetError.SetRange("Source Table Name", "Source Table Name");
        ITIMigrDatasetError.SetRange("Source Field Name", "Source Field Name");
        ITIMigrDatasetError.SetRange("Source Option Name", "Source Option Name");
        ITIMigrDatasetError.DeleteAll();
    end;
}

