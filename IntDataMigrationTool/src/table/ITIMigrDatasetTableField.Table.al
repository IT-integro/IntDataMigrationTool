table 99018 "ITI Migr. Dataset Table Field"
{
    Caption = 'Migration Dataset Table Field';
    LookupPageId = "ITI Migr.Dataset Table Fields";
    DrillDownPageId = "ITI Migr.Dataset Table Fields";
    DataCaptionFields = "Migration Dataset Code", "Source table name";
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
            TableRelation = if ("Mapping Type" = const(FieldToField)) "ITI App. Object Table Field".Name where("SQL Database Code" = field("Source SQL Database Code"), "Table Name" = field("Source table name"), "SQL Table Name Excl. C. Name" = filter(<> ''), "SQL Field Name" = filter(<> ''));
            trigger OnLookup()
            begin
                if Rec."Mapping Type" = Rec."Mapping Type"::FieldToField then
                    GetSourceObjectTableField();
            end;

            trigger OnValidate()
            var
                ITIMigrDsTableFieldAddTarget: Record "ITIMigrDsTableFieldAddTarget";
            begin
                if Rec."Mapping Type" = Rec."Mapping Type"::FieldToField then begin
                    if Rec."Source Field Name" <> xRec."Source Field Name" then begin
                        ITIMigrDsTableFieldAddTarget.SetRange("Migration Dataset Code", Rec."Migration Dataset Code");
                        ITIMigrDsTableFieldAddTarget.SetRange("Source table name", Rec."Source table name");
                        ITIMigrDsTableFieldAddTarget.SetRange("Source Field Name", xRec."Source Field Name");
                        if not ITIMigrDsTableFieldAddTarget.IsEmpty() then
                            ITIMigrDsTableFieldAddTarget.DeleteAll();
                    end;
                    if "Source Field Name" <> '' then
                        ValidateSourceObjectTableFieldName();
                end;

            end;
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
            DataClassification = ToBeClassified;
            TableRelation = "ITI Migration Dataset Table"."Target Table Name" where("Source Table Name" = field("Source table name"));
            Editable = false;
        }

        field(80; "Target Field name"; Text[150])
        {
            Caption = 'Target Field name';
            ValidateTableRelation = false;
            DataClassification = ToBeClassified;
            TableRelation = "ITI App. Object Table Field".Name where("SQL Database Code" = field("Target SQL Database Code"), "Table Name" = field("Target table name"), "SQL Table Name Excl. C. Name" = filter(<> ''), "SQL Field Name" = filter(<> ''));
            trigger OnLookup()
            begin
                GetTargetObjectTableField();
            end;

            trigger OnValidate()
            begin
                if "Target Field name" <> '' then
                    ValidateTargetObjectTableFieldName();
            end;
        }
        field(90; "Number of Errors"; Integer)
        {
            Caption = 'Number of Errors';
            FieldClass = FlowField;
            CalcFormula = count("ITI Migr. Dataset Error" where("Migration Dataset Code" = field("Migration Dataset Code"),
                                                             "Source Table Name" = field("Source table name"),
                                                             "Source Field Name" = field("Source Field Name"),
                                                             "Error Type" = const(Error)));
            Editable = false;
        }
        field(100; "Number of Warnings"; Integer)
        {
            Caption = 'Number of Warnings';
            FieldClass = FlowField;
            CalcFormula = count("ITI Migr. Dataset Error" where("Migration Dataset Code" = field("Migration Dataset Code"),
                                                             "Source Table Name" = field("Source table name"),
                                                             "Source Field Name" = field("Source Field Name"),
                                                             "Error Type" = const(Warning)));
            Editable = false;
        }
        field(110; "Ignore Errors"; Boolean)
        {
            Caption = 'Ignore Errors';
        }
        field(120; "No. of Target Field Proposals"; Integer)
        {
            Caption = 'No. of Target Field Proposals';
            FieldClass = FlowField;
            CalcFormula = count("ITIMigrDataTableFieldProposal" where("Migration Dataset Code" = field("Migration Dataset Code"),
                                                                          "Source Table Name" = field("Source table name"),
                                                                        "Source Field Name" = field("Source Field Name")));
            Editable = false;
        }
        field(140; Comment; text[250])
        {
            Caption = 'Comment';
            Editable = true;
            DataClassification = ToBeClassified;
        }
        field(150; "Is Empty"; Enum "ITI Mig Dat Tab Fiel Is Empty")
        {
            Caption = 'Is Empty';
            DataClassification = ToBeClassified;
        }
        field(230; "Skip in Mapping"; Boolean)
        {
            Caption = 'Skip in Mapping';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                ITIAppObjectTableField: Record "ITI App. Object Table Field";
            begin
                Rec.CalcFields("Source SQL Database Code");
                if Rec."Skip in Mapping" = true then begin
                    ITIAppObjectTableField.SetRange("SQL Database Code", Rec."Source SQL Database Code");
                    ITIAppObjectTableField.SetRange("Table Name", "Source table name");
                    ITIAppObjectTableField.SetRange(Name, Rec."Source Field Name");
                    ITIAppObjectTableField.SetRange("Key", true);

                    if not ITIAppObjectTableField.IsEmpty() then
                        if not Dialog.Confirm(SkipMappingConfMsg) then
                            exit
                        else
                            Rec.Validate("Target Field name", '');
                end;

            end;
        }
        field(240; "Mapping Type"; Enum ITIMappingType)
        {
            Caption = 'Mapping Type';
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Rec."Mapping Type" <> xRec."Mapping Type" then begin
                    Rec.Validate("Source Field Name", '');
                    Rec.Validate("Target Field name", '');
                end;
            end;
        }

    }

    keys
    {
        key(Key1; "Migration Dataset Code", "Source table name", "Source Field Name")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }


    local procedure ValidateSourceObjectTableFieldName()
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
    begin
        CalcFields("Source SQL Database Code");
        ITIMigrationDataset.Get("Migration Dataset Code");
        ValidateFieldName(ITIMigrationDataset."Source SQL Database Code", "Source table name", "Source Field Name");
    end;

    local procedure ValidateTargetObjectTableFieldName()
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
        ITIMigrationDatasetTable: record "ITI Migration Dataset Table";
    begin
        CalcFields("Target SQL Database Code");
        ITIMigrationDataset.Get("Migration Dataset Code");
        ITIMigrationDatasetTable.Get("Migration Dataset Code", "Source table name");
        if "Target table name" = '' then
            "Target table name" := ITIMigrationDatasetTable."Target table name";
        ValidateFieldName(ITIMigrationDataset."Target SQL Database Code", "Target table name", "Target Field Name");
    end;

    local procedure ValidateFieldName(SQLDatabaseCode: code[20]; TableName: Text[150]; FieldName: Text[150])
    var
        ITIAppObjectTableField: Record "ITI App. Object Table Field";
        ITIMigrationDataset: Record "ITI Migration Dataset";
    begin
        ITIAppObjectTableField.SetRange("SQL Database Code", SQLDatabaseCode);
        ITIAppObjectTableField.SetRange("Table Name", TableName);
        ITIAppObjectTableField.SetRange(Name, FieldName);
        ITIAppObjectTableField.SetFilter("SQL Table Name Excl. C. Name", '<>''''');
        ITIAppObjectTableField.SetFilter("SQL Field Name", '<>''''');
        ITIAppObjectTableField.FindFirst();
        ITIMigrationDataset.Get("Migration Dataset Code");
        case SQLDatabaseCode of
            ITIMigrationDataset."Source SQL Database Code":
                begin
                    "Source Field Name" := ITIAppObjectTableField.Name;
                    InsertSourceTableFieldOptions();
                end;
            ITIMigrationDataset."Target SQL Database Code":
                begin
                    "Target Field Name" := ITIAppObjectTableField.Name;
                    AssignTargetTableFieldOptions();
                end;
        end;
    end;

    local procedure GetSourceObjectTableField()
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
    begin
        CalcFields("Source SQL Database Code");
        ITIMigrationDataset.Get("Migration Dataset Code");
        GetObjectTableField(ITIMigrationDataset."Source SQL Database Code", "Source table name");
    end;

    local procedure GetTargetObjectTableField()
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
        ITIMigrationDatasetTable: Record "ITI Migration Dataset Table";
    begin
        CalcFields("Target SQL Database Code");
        ITIMigrationDataset.Get("Migration Dataset Code");
        ITIMigrationDatasetTable.Get("Migration Dataset Code", "Source table name");
        "Target table name" := ITIMigrationDatasetTable."Target table name";
        GetObjectTableField(ITIMigrationDataset."Target SQL Database Code", "Target table name");
    end;

    local procedure GetObjectTableField(SQLDatabaseCode: code[20]; TableName: Text[150])
    var
        ITIAppObjectTableField: Record "ITI App. Object Table Field";
        ITIMigrationDataset: Record "ITI Migration Dataset";
        ITIAppObjectTableFields: Page "ITI App. Object Table Fields";
    begin
        ITIAppObjectTableField.SetRange("SQL Database Code", SQLDatabaseCode);
        ITIAppObjectTableField.SetRange("Table Name", TableName);
        ITIAppObjectTableField.SetFilter("SQL Table Name Excl. C. Name", '<>''''');
        ITIAppObjectTableField.SetFilter("SQL Field Name", '<>''''');
        ITIAppObjectTableFields.LookupMode := true;
        ITIAppObjectTableFields.Editable := false;
        ITIAppObjectTableFields.SetTableView(ITIAppObjectTableField);
        if ITIAppObjectTableFields.RunModal() = Action::LookupOK then begin
            ITIMigrationDataset.Get("Migration Dataset Code");
            ITIAppObjectTableFields.GetRecord(ITIAppObjectTableField);
            case SQLDatabaseCode of
                ITIMigrationDataset."Source SQL Database Code":
                    "Source Field Name" := ITIAppObjectTableField.Name;
                ITIMigrationDataset."Target SQL Database Code":
                    begin
                        "Target Field Name" := ITIAppObjectTableField.Name;
                        ValidateConstantValue(ITIAppObjectTableField.Datatype);
                    end;

            end;
        end;
    end;

    local procedure InsertSourceTableFieldOptions()
    var
        ITIMigrDsTblFldOption: Record "ITI Migr. Ds. Tbl. Fld. Option";
        ITIAppObjectTblFieldOpt: record "ITI App. Object Tbl.Field Opt.";
    begin
        CalcFields("Source SQL Database Code");
        ITIMigrDsTblFldOption.SetRange("Migration Dataset Code", "Migration Dataset Code");
        ITIMigrDsTblFldOption.SetRange("Source Table Name", "Source Table Name");
        ITIMigrDsTblFldOption.SetRange("Source Field Name", "Source Field Name");
        ITIMigrDsTblFldOption.DeleteAll();

        ITIAppObjectTblFieldOpt.SetRange("SQL Database Code", "Source SQL Database Code");
        ITIAppObjectTblFieldOpt.SetRange("Table Name", "Source table name");
        ITIAppObjectTblFieldOpt.SetRange("Field Name", "Source Field Name");
        if ITIAppObjectTblFieldOpt.Findset() then
            repeat
                ITIMigrDsTblFldOption.init();
                ITIMigrDsTblFldOption."Migration Dataset Code" := "Migration Dataset Code";
                ITIMigrDsTblFldOption."Source table name" := "Source Table Name";
                ITIMigrDsTblFldOption."Source Field Name" := "Source Field Name";
                ITIMigrDsTblFldOption."Source Option ID" := ITIAppObjectTblFieldOpt."Option ID";
                ITIMigrDsTblFldOption."Source Option Name" := ITIAppObjectTblFieldOpt.Name;
                ITIMigrDsTblFldOption.Insert();
            until ITIAppObjectTblFieldOpt.Next() = 0;
    end;

    local procedure AssignTargetTableFieldOptions()
    var
        ITIMigrDsTblFldOption: Record "ITI Migr. Ds. Tbl. Fld. Option";
        ITIAppObjectTblFieldOpt: record "ITI App. Object Tbl.Field Opt.";
    begin
        CalcFields("Target SQL Database Code");
        ITIMigrDsTblFldOption.SetRange("Migration Dataset Code", "Migration Dataset Code");
        ITIMigrDsTblFldOption.SetRange("Source Table Name", "Source Table Name");
        ITIMigrDsTblFldOption.SetRange("Source Field Name", "Source Field Name");
        if ITIMigrDsTblFldOption.Findset() then
            repeat
                ITIAppObjectTblFieldOpt.SetRange("SQL Database Code", "Target SQL Database Code");
                ITIAppObjectTblFieldOpt.SetRange("Table Name", "Target table name");
                ITIAppObjectTblFieldOpt.SetRange("Field Name", "Target Field Name");
                ITIAppObjectTblFieldOpt.SetRange("Option ID", ITIMigrDsTblFldOption."Source Option ID");
                if ITIAppObjectTblFieldOpt.FindFirst() then begin
                    ITIMigrDsTblFldOption."Target Option ID" := ITIAppObjectTblFieldOpt."Option ID";
                    ITIMigrDsTblFldOption."Target Option Name" := ITIAppObjectTblFieldOpt.Name;
                    ITIMigrDsTblFldOption.Modify();
                end;
            until ITIMigrDsTblFldOption.Next() = 0;
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
        ITIMigrDsTblFldOption: Record "ITI Migr. Ds. Tbl. Fld. Option";
        ITIMigrDatasetError: Record "ITI Migr. Dataset Error";
        ITIMigrDataTableFieldProposal: Record "ITIMigrDataTableFieldProposal";
        ITIMigrDsTableFieldAddTarget: Record ITIMigrDsTableFieldAddTarget;
    begin
        ITIMigrDsTblFldOption.SetRange("Migration Dataset Code", "Migration Dataset Code");
        ITIMigrDsTblFldOption.SetRange("Source Table Name", "Source Table Name");
        ITIMigrDsTblFldOption.SetRange("Source Field Name", "Source Field Name");
        ITIMigrDsTblFldOption.DeleteAll();

        ITIMigrDatasetError.SetRange("Migration Dataset Code", "Migration Dataset Code");
        ITIMigrDatasetError.SetRange("Source Table Name", "Source Table Name");
        ITIMigrDatasetError.SetRange("Source Field Name", "Source Field Name");
        ITIMigrDatasetError.DeleteAll();

        ITIMigrDataTableFieldProposal.SetRange("Migration Dataset Code", "Migration Dataset Code");
        ITIMigrDataTableFieldProposal.SetRange("Source Table Name", "Source Table Name");
        ITIMigrDataTableFieldProposal.SetRange("Source Field Name", "Source Field Name");
        ITIMigrDataTableFieldProposal.DeleteAll();

        ITIMigrDsTableFieldAddTarget.SetRange("Migration Dataset Code", Rec."Migration Dataset Code");
        ITIMigrDsTableFieldAddTarget.SetRange("Source table name", rec."Source table name");
        ITIMigrDsTableFieldAddTarget.SetRange("Source Field Name", Rec."Source Field Name");
        ITIMigrDsTableFieldAddTarget.DeleteAll(true);
    end;

    procedure GetSQLSourceFieldName(): Text[150]
    var
        ITIAppObjectTableField: Record "ITI App. Object Table Field";
    begin
        CalcFields("Source SQL Database Code");
        ITIAppObjectTableField.SetRange("SQL Database Code", "Source SQL Database Code");
        ITIAppObjectTableField.SetRange("Table Name", "Source table name");
        ITIAppObjectTableField.SetRange(Name, "Source Field Name");
        ITIAppObjectTableField.FindFirst();

        exit(ITIAppObjectTableField."SQL Field Name");
    end;

    procedure GetSQLTargetFieldName(): Text[150]
    var
        ITIAppObjectTableField: Record "ITI App. Object Table Field";
    begin
        CalcFields("Target SQL Database Code");
        ITIAppObjectTableField.SetRange("SQL Database Code", "Target SQL Database Code");
        ITIAppObjectTableField.SetRange("Table Name", "Target table name");
        ITIAppObjectTableField.SetRange(Name, "Target Field Name");
        ITIAppObjectTableField.FindFirst();

        exit(ITIAppObjectTableField."SQL Field Name");
    end;

    procedure GetSQLSourceTableName(CompanyName: Text[150]): Text[250]
    var
        ITIAppObjectTableField: Record "ITI App. Object Table Field";
    begin
        CalcFields("Source SQL Database Code");
        ITIAppObjectTableField.SetRange("SQL Database Code", "Source SQL Database Code");
        ITIAppObjectTableField.SetRange("Table Name", "Source table name");
        if "Mapping Type" = "Mapping Type"::FieldToField then
            ITIAppObjectTableField.SetRange(Name, "Source Field Name");
        ITIAppObjectTableField.FindFirst();

        exit(ITIAppObjectTableField.GetSQLTableName(CompanyName));
    end;

    procedure GetSQLTargetTableName(CompanyName: Text[150]): Text[250]
    var
        ITIAppObjectTableField: Record "ITI App. Object Table Field";
    begin
        CalcFields("Target SQL Database Code");
        ITIAppObjectTableField.SetRange("SQL Database Code", "Target SQL Database Code");
        ITIAppObjectTableField.SetRange("Table Name", "Target table name");
        ITIAppObjectTableField.SetRange(Name, "Target Field Name");
        ITIAppObjectTableField.FindFirst();

        exit(ITIAppObjectTableField.GetSQLTableName(CompanyName));
    end;

    local procedure ValidateConstantValue(DataType: Text)
    var
        ValueInt: Integer;
        ValueDec: Decimal;
        GuidValue: Guid;
        DateValue: Date;
        DateTimeValue: DateTime;
        ValueBool, OK : Boolean;

    begin
        if Rec."Mapping Type" <> Rec."Mapping Type"::ConstantToField then
            exit;

        case UpperCase(DataType) of
            'CODE', 'TEXT', 'RECORDID', 'DATEFORMULA':
                exit;
            'INTEGER', 'BIGINTEGER', 'OPTION':
                OK := Evaluate(ValueInt, Rec."Source Field Name");
            'DECIMAL':
                OK := Evaluate(ValueDec, Rec."Source Field Name");
            'BOOLEAN':
                OK := Evaluate(ValueBool, Rec."Source Field Name");
            'GUID':
                OK := Evaluate(GuidValue, Rec."Source Field Name");
            'DATE':
                OK := Evaluate(DateValue, Rec."Source Field Name");
            'DATETIME':
                OK := Evaluate(DateTimeValue, Rec."Source Field Name");
        end;
        if not OK then
            Error(DatatypeIsNotProperErr, Rec."Source Field Name", Rec."Target Field Name");
    end;

    var
        SkipMappingConfMsg: Label 'This field is part of primary key, are You sure skip this field in mapping?';
        DatatypeIsNotProperErr: Label 'Value %1 can not be inserted into field %2.', Comment = '%1 = Field Value, %2 = Field Name';

}

