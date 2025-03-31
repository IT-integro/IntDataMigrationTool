table 99004 "PTE Migration Dataset Table"
{
    Caption = 'Migration Dataset Table';
    fields
    {
        field(1; "Migration Dataset Code"; Code[20])
        {
            Caption = 'Migration ataset Code';
            TableRelation = "PTE Migration Dataset".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(10; "Source SQL Database Code"; Code[20])
        {
            Caption = 'Source SQL Database Code';
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
            TableRelation = "PTE Migration Dataset"."Source SQL Database Code" where(Code = FIELD("Migration Dataset Code"));
            Editable = false;
        }

        field(30; "Source Table Name"; Text[150])
        {
            Caption = 'Source Table Name';
            DataClassification = ToBeClassified;
            TableRelation = "PTE App. Object Table".Name where("SQL Database Code" = field("Source SQL Database Code"));
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
            TableRelation = "PTE Migration Dataset"."Target SQL Database Code" where(Code = FIELD("Migration Dataset Code"));
            Editable = false;
        }

        field(60; "Target table name"; Text[150])
        {
            Caption = 'Target Table Name';
            DataClassification = ToBeClassified;
            TableRelation = "PTE App. Object Table".Name where("SQL Database Code" = field("Target SQL Database Code"));
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
            CalcFormula = count("PTE Migr. Dataset Error" where("Migration Dataset Code" = field("Migration Dataset Code"),
                                                             "Source Table Name" = field("Source table name"),
                                                             "Error Type" = const(Error)));
            Editable = false;
        }
        field(210; "Number of Warnings"; Integer)
        {
            Caption = 'Number of Warnings';
            FieldClass = FlowField;
            CalcFormula = count("PTE Migr. Dataset Error" where("Migration Dataset Code" = field("Migration Dataset Code"),
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
        PTEMigrationDataset: Record "PTE Migration Dataset";
    begin
        PTEMigrationDataset.Get(Rec."Migration Dataset Code");
        if PTEMigrationDataset.Released then
            Error(CannotModifyAfterReleaseErr);
    end;

    local procedure ValidateSourceTableName(TableName: Text[150])
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
    begin
        PTEMigrationDataset.Get("Migration Dataset Code");
        ValidateTableName(PTEMigrationDataset."Source SQL Database Code", TableName);
    end;

    local procedure ValidateTargetTableName(TableName: Text[150])
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
    begin
        PTEMigrationDataset.Get("Migration Dataset Code");
        ValidateTableName(PTEMigrationDataset."Target SQL Database Code", TableName);
    end;

    local procedure ValidateTableName(SQLDatabaseCode: code[20]; TableName: Text[150])
    var
        PTEAppObjectTable: Record "PTE App. Object Table";
        PTEMigrationDataset: Record "PTE Migration Dataset";
    begin
        PTEMigrationDataset.Get("Migration Dataset Code");
        PTEAppObjectTable.SetRange("SQL Database Code", SQLDatabaseCode);
        PTEAppObjectTable.SetFilter(TableType, '@Normal|''''');
        PTEAppObjectTable.SetRange(Name, TableName);
        if PTEAppObjectTable.FindFirst() then
            case SQLDatabaseCode of
                PTEMigrationDataset."Source SQL Database Code":
                    begin
                        UpdateDatabseCodes();
                        "Source table name" := PTEAppObjectTable.Name;
                        InsertSourceTableFields();
                    end;
                PTEMigrationDataset."Target SQL Database Code":
                    begin
                        UpdateDatabseCodes();
                        "Target table name" := PTEAppObjectTable.Name;
                        AssignTargetTableFields("Target table name");
                    end;
            end;
    end;

    local procedure GetSourceObjectTable()
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
    begin
        PTEMigrationDataset.Get("Migration Dataset Code");
        GetObjectTable(PTEMigrationDataset."Source SQL Database Code");
    end;

    local procedure GetTargetObjectTable()
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
    begin
        PTEMigrationDataset.Get("Migration Dataset Code");
        GetObjectTable(PTEMigrationDataset."Target SQL Database Code");
    end;

    local procedure GetObjectTable(SQLDatabaseCode: code[20]): Record "PTE App. Object Table"
    var
        PTEAppObjectTable: Record "PTE App. Object Table";
        PTEMigrationDataset: Record "PTE Migration Dataset";
        PTEAppObjectTables: Page "PTE App. Object Tables";
    begin
        PTEAppObjectTable.SetRange("SQL Database Code", SQLDatabaseCode);
        PTEAppObjectTable.SetFilter(TableType, '@Normal|''''');
        PTEAppObjectTables.LookupMode := true;
        PTEAppObjectTables.Editable := false;
        PTEAppObjectTables.SetTableView(PTEAppObjectTable);
        if PTEAppObjectTables.RunModal() = Action::LookupOK then begin
            PTEMigrationDataset.Get("Migration Dataset Code");
            PTEAppObjectTables.GetRecord(PTEAppObjectTable);
            case SQLDatabaseCode of
                PTEMigrationDataset."Source SQL Database Code":
                    begin
                        UpdateDatabseCodes();
                        Validate("Source table name", PTEAppObjectTable.Name);
                    end;
                PTEMigrationDataset."Target SQL Database Code":
                    begin
                        UpdateDatabseCodes();
                        Validate("Target table name", PTEAppObjectTable.Name);
                    end;
            end;
        end;
    end;

    local procedure UpdateDatabseCodes()
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
    begin
        PTEMigrationDataset.Get("Migration Dataset Code");
        if "Source SQL Database Code" = '' then
            Validate("Source SQL Database Code", PTEMigrationDataset."Source SQL Database Code");
        if "Target SQL Database Code" = '' then
            Validate("Target SQL Database Code", PTEMigrationDataset."Target SQL Database Code");
    end;

    local procedure InsertSourceTableFields()
    var
        PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field";
        PTEAppObjectTableField: Record "PTE App. Object Table Field";
    begin
        PTEMigrDatasetTableField.SetRange("Migration Dataset Code", "Migration Dataset Code");
        PTEMigrDatasetTableField.SetRange("Source Table Name", "Source Table Name");
        if not PTEMigrDatasetTableField.IsEmpty then
            if not Confirm(DataExistsMsg, false) then
                exit;
        PTEMigrDatasetTableField.DeleteAll();
        PTEAppObjectTableField.SetRange("SQL Database Code", "Source SQL Database Code");
        PTEAppObjectTableField.SetRange("Table Name", "Source table name");
        PTEAppObjectTableField.SetFilter("SQL Table Name Excl. C. Name", '<>''''');
        PTEAppObjectTableField.SetFilter("SQL Field Name", '<>''''');
        if PTEAppObjectTableField.FindSet() then
            repeat
                PTEMigrDatasetTableField.Init();
                PTEMigrDatasetTableField."Migration Dataset Code" := "Migration Dataset Code";
                PTEMigrDatasetTableField."Source table name" := "Source Table Name";
                PTEMigrDatasetTableField.Validate("Source Field Name", PTEAppObjectTableField.Name);
                PTEMigrDatasetTableField.Insert();
            until PTEAppObjectTableField.Next() = 0;
    end;

    Local procedure AssignTargetTableFields(TargetTableName: Text[150])
    var
        PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field";
        PTEAppObjectTableField: Record "PTE App. Object Table Field";
    begin
        PTEMigrDatasetTableField.SetRange("Migration Dataset Code", "Migration Dataset Code");
        PTEMigrDatasetTableField.SetRange("Source Table Name", "Source Table Name");
        PTEMigrDatasetTableField.SetFilter("Target Field name", '<>''''');
        if not PTEMigrDatasetTableField.IsEmpty then
            if not Confirm(DataExists2Msg, false) then
                exit;

        PTEMigrDatasetTableField.Reset();
        PTEMigrDatasetTableField.SetRange("Migration Dataset Code", "Migration Dataset Code");
        PTEMigrDatasetTableField.SetRange("Source Table Name", "Source Table Name");
        if PTEMigrDatasetTableField.findset() then
            repeat
                PTEAppObjectTableField.SetRange("SQL Database Code", "Target SQL Database Code");
                PTEAppObjectTableField.SetRange("Table Name", "Target table name");
                PTEAppObjectTableField.SetRange(Name, PTEMigrDatasetTableField."Source Field Name");
                PTEAppObjectTableField.SetFilter("SQL Table Name Excl. C. Name", '<>''''');
                PTEAppObjectTableField.SetFilter("SQL Field Name", '<>''''');
                if PTEAppObjectTableField.FindFirst() then begin
                    PTEMigrDatasetTableField."Target table name" := TargetTableName;
                    PTEMigrDatasetTableField.Validate("Target Field name", PTEAppObjectTableField.Name);
                end else
                    PTEMigrDatasetTableField.Validate("Target Field name", '');
                PTEMigrDatasetTableField.Modify();
            until PTEMigrDatasetTableField.Next() = 0;
    end;

    local procedure ClearTableFields(TableName: Text[150])
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
        PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field";
        PTEMigrDatasetError: Record "PTE Migr. Dataset Error";
        PTEMigrDsTblFldOption: Record "PTE Migr. Ds. Tbl. Fld. Option";
    begin
        PTEMigrationDataset.Get("Migration Dataset Code");
        PTEMigrDatasetTableField.Reset();
        PTEMigrDatasetTableField.SetRange("Migration Dataset Code", "Migration Dataset Code");
        PTEMigrDatasetTableField.SetRange("Source Table Name", TableName);
        if PTEMigrDatasetTableField.FindSet() then
            repeat
                PTEMigrDatasetTableField."Target table name" := '';
                PTEMigrDatasetTableField.Validate("Target Field name", '');
                PTEMigrDatasetTableField.Modify();

                PTEMigrDsTblFldOption.SetRange("Migration Dataset Code", "Migration Dataset Code");
                PTEMigrDsTblFldOption.SetRange("Source SQL Database Code", "Source SQL Database Code");
                PTEMigrDsTblFldOption.SetRange("Source Table Name", "Source Table Name");
                if not PTEMigrDsTblFldOption.IsEmpty() then begin
                    //PTEMigrDsTblFldOption.ModifyAll("Target table name", '');
                    //PTEMigrDsTblFldOption.ModifyAll("Target field name", '');
                    PTEMigrDsTblFldOption.ModifyAll("Target option id", 0);
                    PTEMigrDsTblFldOption.ModifyAll("Target Option Name", '');
                end;

                PTEMigrDatasetError.SetRange("Migration Dataset Code", "Migration Dataset Code");
                PTEMigrDatasetError.SetRange("Source table name", "Source Table Name");
                PTEMigrDatasetError.DeleteAll();

            until PTEMigrDatasetTableField.Next() = 0;
    end;

    trigger OnDelete()
    var
        PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field";
        PTEMigrDsTblFldOption: Record "PTE Migr. Ds. Tbl. Fld. Option";
        PTEMigrDatasetError: Record "PTE Migr. Dataset Error";
        PTEMigrationDataset: Record "PTE Migration Dataset";
    begin
        PTEMigrationDataset.Get(Rec."Migration Dataset Code");
        if PTEMigrationDataset.Released then
            Error(CannotModifyAfterReleaseErr);

        PTEMigrDatasetTableField.SetRange("Migration Dataset Code", "Migration Dataset Code");
        PTEMigrDatasetTableField.SetRange("Source SQL Database Code", "Source SQL Database Code");
        PTEMigrDatasetTableField.SetRange("Source table name", "Source Table Name");
        PTEMigrDatasetTableField.DeleteAll(true);

        PTEMigrDsTblFldOption.SetRange("Migration Dataset Code", "Migration Dataset Code");
        PTEMigrDsTblFldOption.SetRange("Source SQL Database Code", "Source SQL Database Code");
        PTEMigrDsTblFldOption.SetRange("Source Table Name", "Source Table Name");
        PTEMigrDsTblFldOption.DeleteAll(true);

        PTEMigrDatasetError.SetRange("Migration Dataset Code", "Migration Dataset Code");
        PTEMigrDatasetError.SetRange("Source table name", "Source Table Name");
        PTEMigrDatasetError.DeleteAll(true);
    end;

    trigger OnModify()
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
    begin
        PTEMigrationDataset.Get("Migration Dataset Code");
        PTEMigrationDataset.TestField(Released, false);
    end;

    var
        DataExistsMsg: Label 'Existing fields connected to this line will be deleted. Do you want to continue?';
        DataExists2Msg: Label 'Existing target fields in lines will be exchanged. Do you want to continue?';
        CannotModifyAfterReleaseErr: Label 'A released Migration Dataset can not be modified.';
}

