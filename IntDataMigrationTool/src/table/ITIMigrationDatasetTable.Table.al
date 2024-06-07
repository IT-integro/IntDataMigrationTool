table 99004 "ITI Migration Dataset Table"
{
    Caption = 'Migration Dataset Table';
    fields
    {
        field(1; "Migration Dataset Code"; Code[20])
        {
            Caption = 'Migration ataset Code';
            TableRelation = "ITI Migration Dataset".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(10; "Source SQL Database Code"; Code[20])
        {
            Caption = 'Source SQL Database Code';
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
            TableRelation = "ITI Migration Dataset"."Source SQL Database Code" where(Code = FIELD("Migration Dataset Code"));
            Editable = false;
        }

        field(30; "Source Table Name"; Text[150])
        {
            Caption = 'Source Table Name';
            DataClassification = ToBeClassified;
            TableRelation = "ITI App. Object Table".Name where("SQL Database Code" = field("Source SQL Database Code"));
            ValidateTableRelation = false;
            trigger OnLookup()
            begin
                GetSourceObjectTable();
            end;

            trigger OnValidate()
            begin
                if "Source Table Name" <> xRec."Source Table Name" then
                    ValidateSourceTableName("Source table name");
            end;
        }

        field(40; "Target SQL Database Code"; Text[150])
        {
            Caption = 'Target SQL Database Code';
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
            TableRelation = "ITI Migration Dataset"."Target SQL Database Code" where(Code = FIELD("Migration Dataset Code"));
            Editable = false;
        }

        field(60; "Target table name"; Text[150])
        {
            Caption = 'Target Table Name';
            DataClassification = ToBeClassified;
            TableRelation = "ITI App. Object Table".Name where("SQL Database Code" = field("Target SQL Database Code"));
            ValidateTableRelation = false;
            trigger OnLookup()
            begin
                GetTargetObjectTable();
            end;

            trigger OnValidate()
            begin
                if "Target table name" = '' then
                    ClearTableFields(xRec."Target table name")
                else
                    if "Target table name" <> xRec."Target table name" then
                        ValidateTargetTableName("Target table name");
            end;
        }
        field(200; "Number of Errors"; Integer)
        {
            Caption = 'Number of Errors';
            FieldClass = FlowField;
            CalcFormula = count("ITI Migr. Dataset Error" where("Migration Dataset Code" = field("Migration Dataset Code"),
                                                             "Source Table Name" = field("Source table name"),
                                                             "Error Type" = const(Error)));
            Editable = false;
        }
        field(210; "Number of Warnings"; Integer)
        {
            Caption = 'Number of Warnings';
            FieldClass = FlowField;
            CalcFormula = count("ITI Migr. Dataset Error" where("Migration Dataset Code" = field("Migration Dataset Code"),
                                                             "Source Table Name" = field("Source table name"),
                                                             "Error Type" = const(Warning)));
            Editable = false;
        }
        field(220; "Description"; Text[250])
        {
            Caption = 'Description/Notes';
            Editable = true;
            DataClassification = ToBeClassified;
        }
        field(230; "Skip in Mapping"; Boolean)
        {
            Caption = 'Skip in Mapping';

            trigger OnValidate()
            begin
                if Rec."Skip in Mapping" = true then
                    Rec.Validate("Target table name", '');
            end;
        }
    }

    keys
    {
        key(Key1; "Migration Dataset Code", "Source Table Name")
        {
            Clustered = true;
        }
        key(Key2; "Migration Dataset Code", "Target table name")
        {

        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
    begin
        ITIMigrationDataset.Get(Rec."Migration Dataset Code");
        if ITIMigrationDataset.Released then
            Error(CannotModifyAfterReleaseErr);
    end;

    local procedure ValidateSourceTableName(TableName: Text[150])
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
    begin
        ITIMigrationDataset.Get("Migration Dataset Code");
        ValidateTableName(ITIMigrationDataset."Source SQL Database Code", TableName);
    end;

    local procedure ValidateTargetTableName(TableName: Text[150])
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
    begin
        ITIMigrationDataset.Get("Migration Dataset Code");
        ValidateTableName(ITIMigrationDataset."Target SQL Database Code", TableName);
    end;

    local procedure ValidateTableName(SQLDatabaseCode: code[20]; TableName: Text[150])
    var
        ITIAppObjectTable: Record "ITI App. Object Table";
        ITIMigrationDataset: Record "ITI Migration Dataset";
    begin
        ITIMigrationDataset.Get("Migration Dataset Code");
        ITIAppObjectTable.SetRange("SQL Database Code", SQLDatabaseCode);
        ITIAppObjectTable.SetFilter(TableType, '@Normal|''''');
        ITIAppObjectTable.SetRange(Name, TableName);
        if ITIAppObjectTable.FindFirst() then
            case SQLDatabaseCode of
                ITIMigrationDataset."Source SQL Database Code":
                    begin
                        UpdateDatabseCodes();
                        "Source table name" := ITIAppObjectTable.Name;
                        InsertSourceTableFields();
                    end;
                ITIMigrationDataset."Target SQL Database Code":
                    begin
                        UpdateDatabseCodes();
                        "Target table name" := ITIAppObjectTable.Name;
                        AssignTargetTableFields("Target table name");
                    end;
            end;
    end;

    local procedure GetSourceObjectTable()
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
    begin
        ITIMigrationDataset.Get("Migration Dataset Code");
        GetObjectTable(ITIMigrationDataset."Source SQL Database Code");
    end;

    local procedure GetTargetObjectTable()
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
    begin
        ITIMigrationDataset.Get("Migration Dataset Code");
        GetObjectTable(ITIMigrationDataset."Target SQL Database Code");
    end;

    local procedure GetObjectTable(SQLDatabaseCode: code[20]): Record "ITI App. Object Table"
    var
        ITIAppObjectTable: Record "ITI App. Object Table";
        ITIMigrationDataset: Record "ITI Migration Dataset";
        ITIAppObjectTables: Page "ITI App. Object Tables";
    begin
        ITIAppObjectTable.SetRange("SQL Database Code", SQLDatabaseCode);
        ITIAppObjectTable.SetFilter(TableType, '@Normal|''''');
        ITIAppObjectTables.LookupMode := true;
        ITIAppObjectTables.Editable := false;
        ITIAppObjectTables.SetTableView(ITIAppObjectTable);
        if ITIAppObjectTables.RunModal() = Action::LookupOK then begin
            ITIMigrationDataset.Get("Migration Dataset Code");
            ITIAppObjectTables.GetRecord(ITIAppObjectTable);
            case SQLDatabaseCode of
                ITIMigrationDataset."Source SQL Database Code":
                    begin
                        UpdateDatabseCodes();
                        Validate("Source table name", ITIAppObjectTable.Name);
                    end;
                ITIMigrationDataset."Target SQL Database Code":
                    begin
                        UpdateDatabseCodes();
                        Validate("Target table name", ITIAppObjectTable.Name);
                    end;
            end;
        end;
    end;

    local procedure UpdateDatabseCodes()
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
    begin
        ITIMigrationDataset.Get("Migration Dataset Code");
        if "Source SQL Database Code" = '' then
            Validate("Source SQL Database Code", ITIMigrationDataset."Source SQL Database Code");
        if "Target SQL Database Code" = '' then
            Validate("Target SQL Database Code", ITIMigrationDataset."Target SQL Database Code");
    end;

    local procedure InsertSourceTableFields()
    var
        ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field";
        ITIAppObjectTableField: Record "ITI App. Object Table Field";
    begin
        ITIMigrDatasetTableField.SetRange("Migration Dataset Code", "Migration Dataset Code");
        ITIMigrDatasetTableField.SetRange("Source Table Name", "Source Table Name");
        if not ITIMigrDatasetTableField.IsEmpty then
            if not Confirm(DataExistsMsg, false) then
                exit;
        ITIMigrDatasetTableField.DeleteAll();
        ITIAppObjectTableField.SetRange("SQL Database Code", "Source SQL Database Code");
        ITIAppObjectTableField.SetRange("Table Name", "Source table name");
        ITIAppObjectTableField.SetFilter("SQL Table Name Excl. C. Name", '<>''''');
        ITIAppObjectTableField.SetFilter("SQL Field Name", '<>''''');
        if ITIAppObjectTableField.FindSet() then
            repeat
                ITIMigrDatasetTableField.Init();
                ITIMigrDatasetTableField."Migration Dataset Code" := "Migration Dataset Code";
                ITIMigrDatasetTableField."Source table name" := "Source Table Name";
                ITIMigrDatasetTableField.Validate("Source Field Name", ITIAppObjectTableField.Name);
                ITIMigrDatasetTableField.Insert();
            until ITIAppObjectTableField.Next() = 0;
    end;

    Local procedure AssignTargetTableFields(TargetTableName: Text[150])
    var
        ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field";
        ITIAppObjectTableField: Record "ITI App. Object Table Field";
    begin
        ITIMigrDatasetTableField.SetRange("Migration Dataset Code", "Migration Dataset Code");
        ITIMigrDatasetTableField.SetRange("Source Table Name", "Source Table Name");
        ITIMigrDatasetTableField.SetFilter("Target Field name", '<>''''');
        if not ITIMigrDatasetTableField.IsEmpty then
            if not Confirm(DataExists2Msg, false) then
                exit;

        ITIMigrDatasetTableField.Reset();
        ITIMigrDatasetTableField.SetRange("Migration Dataset Code", "Migration Dataset Code");
        ITIMigrDatasetTableField.SetRange("Source Table Name", "Source Table Name");
        if ITIMigrDatasetTableField.findset() then
            repeat
                ITIAppObjectTableField.SetRange("SQL Database Code", "Target SQL Database Code");
                ITIAppObjectTableField.SetRange("Table Name", "Target table name");
                ITIAppObjectTableField.SetRange(Name, ITIMigrDatasetTableField."Source Field Name");
                ITIAppObjectTableField.SetFilter("SQL Table Name Excl. C. Name", '<>''''');
                ITIAppObjectTableField.SetFilter("SQL Field Name", '<>''''');
                if ITIAppObjectTableField.FindFirst() then begin
                    ITIMigrDatasetTableField."Target table name" := TargetTableName;
                    ITIMigrDatasetTableField.Validate("Target Field name", ITIAppObjectTableField.Name);
                end else
                    ITIMigrDatasetTableField.Validate("Target Field name", '');
                ITIMigrDatasetTableField.Modify();
            until ITIMigrDatasetTableField.Next() = 0;
    end;

    local procedure ClearTableFields(TableName: Text[150])
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
        ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field";
        ITIMigrDatasetError: Record "ITI Migr. Dataset Error";
        ITIMigrDsTblFldOption: Record "ITI Migr. Ds. Tbl. Fld. Option";
    begin
        ITIMigrationDataset.Get("Migration Dataset Code");
        ITIMigrDatasetTableField.Reset();
        ITIMigrDatasetTableField.SetRange("Migration Dataset Code", "Migration Dataset Code");
        ITIMigrDatasetTableField.SetRange("Source Table Name", TableName);
        if ITIMigrDatasetTableField.FindSet() then
            repeat
                ITIMigrDatasetTableField."Target table name" := '';
                ITIMigrDatasetTableField.Validate("Target Field name", '');
                ITIMigrDatasetTableField.Modify();

                ITIMigrDsTblFldOption.SetRange("Migration Dataset Code", "Migration Dataset Code");
                ITIMigrDsTblFldOption.SetRange("Source SQL Database Code", "Source SQL Database Code");
                ITIMigrDsTblFldOption.SetRange("Source Table Name", "Source Table Name");
                if not ITIMigrDsTblFldOption.IsEmpty() then begin
                    //ITIMigrDsTblFldOption.ModifyAll("Target table name", '');
                    //ITIMigrDsTblFldOption.ModifyAll("Target field name", '');
                    ITIMigrDsTblFldOption.ModifyAll("Target option id", 0);
                    ITIMigrDsTblFldOption.ModifyAll("Target Option Name", '');
                end;

                ITIMigrDatasetError.SetRange("Migration Dataset Code", "Migration Dataset Code");
                ITIMigrDatasetError.SetRange("Source table name", "Source Table Name");
                ITIMigrDatasetError.DeleteAll();

            until ITIMigrDatasetTableField.Next() = 0;
    end;

    trigger OnDelete()
    var
        ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field";
        ITIMigrDsTblFldOption: Record "ITI Migr. Ds. Tbl. Fld. Option";
        ITIMigrDatasetError: Record "ITI Migr. Dataset Error";
        ITIMigrationDataset: Record "ITI Migration Dataset";
    begin
        ITIMigrationDataset.Get(Rec."Migration Dataset Code");
        if ITIMigrationDataset.Released then
            Error(CannotModifyAfterReleaseErr);

        ITIMigrDatasetTableField.SetRange("Migration Dataset Code", "Migration Dataset Code");
        ITIMigrDatasetTableField.SetRange("Source SQL Database Code", "Source SQL Database Code");
        ITIMigrDatasetTableField.SetRange("Source table name", "Source Table Name");
        ITIMigrDatasetTableField.DeleteAll(true);

        ITIMigrDsTblFldOption.SetRange("Migration Dataset Code", "Migration Dataset Code");
        ITIMigrDsTblFldOption.SetRange("Source SQL Database Code", "Source SQL Database Code");
        ITIMigrDsTblFldOption.SetRange("Source Table Name", "Source Table Name");
        ITIMigrDsTblFldOption.DeleteAll(true);

        ITIMigrDatasetError.SetRange("Migration Dataset Code", "Migration Dataset Code");
        ITIMigrDatasetError.SetRange("Source table name", "Source Table Name");
        ITIMigrDatasetError.DeleteAll(true);
    end;

    trigger OnModify()
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
    begin
        ITIMigrationDataset.Get("Migration Dataset Code");
        ITIMigrationDataset.TestField(Released, false);
    end;

    var
        DataExistsMsg: Label 'Existing fields connected to this line will be deleted. Do you want to continue?';
        DataExists2Msg: Label 'Existing target fields in lines will be exchanged. Do you want to continue?';
        CannotModifyAfterReleaseErr: Label 'A released Migration Dataset can not be modified.';
}

