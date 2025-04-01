table 99018 "PTE Migr. Dataset Table Field"
{
    Caption = 'Migration Dataset Table Field';
    LookupPageId = "PTE Migr.Dataset Table Fields";
    DrillDownPageId = "PTE Migr.Dataset Table Fields";
    DataCaptionFields = "Migration Dataset Code", "Source table name";
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
            TableRelation = if ("Mapping Type" = const(FieldToField)) "PTE App. Object Table Field".Name where("SQL Database Code" = field("Source SQL Database Code"), "Table Name" = field("Source table name"), "SQL Table Name Excl. C. Name" = filter(<> ''), "SQL Field Name" = filter(<> ''));
            trigger OnLookup()
            begin
                if Rec."Mapping Type" = Rec."Mapping Type"::FieldToField then
                    GetSourceObjectTableField();
            end;

            trigger OnValidate()
            var
                PTEMigrDsTableFieldAddTarget: Record "PTEMigrDsTableFieldAddTarget";
            begin
                if Rec."Mapping Type" = Rec."Mapping Type"::FieldToField then begin
                    if Rec."Source Field Name" <> xRec."Source Field Name" then begin
                        PTEMigrDsTableFieldAddTarget.SetRange("Migration Dataset Code", Rec."Migration Dataset Code");
                        PTEMigrDsTableFieldAddTarget.SetRange("Source table name", Rec."Source table name");
                        PTEMigrDsTableFieldAddTarget.SetRange("Source Field Name", xRec."Source Field Name");
                        if not PTEMigrDsTableFieldAddTarget.IsEmpty() then
                            PTEMigrDsTableFieldAddTarget.DeleteAll();
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
            CalcFormula = lookup("PTE Migration Dataset"."Target SQL Database Code" where(Code = field("Migration Dataset Code")));
            Editable = false;
        }
        field(70; "Target table name"; Text[150])
        {
            Caption = 'Target table name';
            DataClassification = ToBeClassified;
            TableRelation = "PTE Migration Dataset Table"."Target Table Name" where("Source Table Name" = field("Source table name"));
            Editable = false;
        }

        field(80; "Target Field name"; Text[150])
        {
            Caption = 'Target Field name';
            ValidateTableRelation = false;
            DataClassification = ToBeClassified;
            TableRelation = "PTE App. Object Table Field".Name where("SQL Database Code" = field("Target SQL Database Code"), "Table Name" = field("Target table name"), "SQL Table Name Excl. C. Name" = filter(<> ''), "SQL Field Name" = filter(<> ''));
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
            CalcFormula = count("PTE Migr. Dataset Error" where("Migration Dataset Code" = field("Migration Dataset Code"),
                                                             "Source Table Name" = field("Source table name"),
                                                             "Source Field Name" = field("Source Field Name"),
                                                             "Error Type" = const(Error)));
            Editable = false;
        }
        field(100; "Number of Warnings"; Integer)
        {
            Caption = 'Number of Warnings';
            FieldClass = FlowField;
            CalcFormula = count("PTE Migr. Dataset Error" where("Migration Dataset Code" = field("Migration Dataset Code"),
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
            CalcFormula = count("PTEMigrDataTableFieldProposal" where("Migration Dataset Code" = field("Migration Dataset Code"),
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
        field(150; "Is Empty"; Enum "PTE Mig Dat Tab Fiel Is Empty")
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
                PTEAppObjectTableField: Record "PTE App. Object Table Field";
            begin
                Rec.CalcFields("Source SQL Database Code");
                if Rec."Skip in Mapping" = true then begin
                    PTEAppObjectTableField.SetRange("SQL Database Code", Rec."Source SQL Database Code");
                    PTEAppObjectTableField.SetRange("Table Name", "Source table name");
                    PTEAppObjectTableField.SetRange(Name, Rec."Source Field Name");
                    PTEAppObjectTableField.SetRange("Key", true);

                    if not PTEAppObjectTableField.IsEmpty() then
                        if not Dialog.Confirm(SkipMappingConfMsg) then
                            exit
                        else
                            Rec.Validate("Target Field name", '');
                end;

            end;
        }
        field(240; "Mapping Type"; Enum PTEMappingType)
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

        field(250; "Source Field Data Type"; Text[150])
        {
            Caption = 'Source Field Data Type';
            FieldClass = FlowField;
            CalcFormula = lookup("PTE App. Object Table Field".Datatype where("SQL Database Code" = field("Source SQL Database Code"),
                                                                               "Table Name" = field("Source table name"),
                                                                               "Name" = field("Source Field Name")));
            Editable = false;
        }
        field(251; "Target Field Data Type"; Text[150])
        {
            Caption = 'Target Field Data Type';
            FieldClass = FlowField;
            CalcFormula = lookup("PTE App. Object Table Field".Datatype where("SQL Database Code" = field("Target SQL Database Code"),
                                                                               "Table Name" = field("Target table name"),
                                                                               "Name" = field("Target Field Name")));
            Editable = false;
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
        PTEMigrationDataset: Record "PTE Migration Dataset";
    begin
        CalcFields("Source SQL Database Code");
        PTEMigrationDataset.Get("Migration Dataset Code");
        ValidateFieldName(PTEMigrationDataset."Source SQL Database Code", "Source table name", "Source Field Name");
    end;

    local procedure ValidateTargetObjectTableFieldName()
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
        PTEMigrationDatasetTable: record "PTE Migration Dataset Table";
    begin
        CalcFields("Target SQL Database Code");
        PTEMigrationDataset.Get("Migration Dataset Code");
        PTEMigrationDatasetTable.Get("Migration Dataset Code", "Source table name");
        if "Target table name" = '' then
            "Target table name" := PTEMigrationDatasetTable."Target table name";
        ValidateFieldName(PTEMigrationDataset."Target SQL Database Code", "Target table name", "Target Field Name");
    end;

    local procedure ValidateFieldName(SQLDatabaseCode: code[20]; TableName: Text[150]; FieldName: Text[150])
    var
        PTEAppObjectTableField: Record "PTE App. Object Table Field";
        PTEMigrationDataset: Record "PTE Migration Dataset";
    begin
        PTEAppObjectTableField.SetRange("SQL Database Code", SQLDatabaseCode);
        PTEAppObjectTableField.SetRange("Table Name", TableName);
        PTEAppObjectTableField.SetRange(Name, FieldName);
        PTEAppObjectTableField.SetFilter("SQL Table Name Excl. C. Name", '<>''''');
        PTEAppObjectTableField.SetFilter("SQL Field Name", '<>''''');
        PTEAppObjectTableField.FindFirst();
        PTEMigrationDataset.Get("Migration Dataset Code");
        case SQLDatabaseCode of
            PTEMigrationDataset."Source SQL Database Code":
                begin
                    "Source Field Name" := PTEAppObjectTableField.Name;
                    InsertSourceTableFieldOptions();
                end;
            PTEMigrationDataset."Target SQL Database Code":
                begin
                    "Target Field Name" := PTEAppObjectTableField.Name;
                    AssignTargetTableFieldOptions();
                end;
        end;
    end;

    local procedure GetSourceObjectTableField()
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
    begin
        CalcFields("Source SQL Database Code");
        PTEMigrationDataset.Get("Migration Dataset Code");
        GetObjectTableField(PTEMigrationDataset."Source SQL Database Code", "Source table name");
    end;

    local procedure GetTargetObjectTableField()
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
        PTEMigrationDatasetTable: Record "PTE Migration Dataset Table";
    begin
        CalcFields("Target SQL Database Code");
        PTEMigrationDataset.Get("Migration Dataset Code");
        PTEMigrationDatasetTable.Get("Migration Dataset Code", "Source table name");
        "Target table name" := PTEMigrationDatasetTable."Target table name";
        GetObjectTableField(PTEMigrationDataset."Target SQL Database Code", "Target table name");
    end;

    local procedure GetObjectTableField(SQLDatabaseCode: code[20]; TableName: Text[150])
    var
        PTEAppObjectTableField: Record "PTE App. Object Table Field";
        PTEMigrationDataset: Record "PTE Migration Dataset";
        PTEAppObjectTableFields: Page "PTE App. Object Table Fields";
    begin
        PTEAppObjectTableField.SetRange("SQL Database Code", SQLDatabaseCode);
        PTEAppObjectTableField.SetRange("Table Name", TableName);
        PTEAppObjectTableField.SetFilter("SQL Table Name Excl. C. Name", '<>''''');
        PTEAppObjectTableField.SetFilter("SQL Field Name", '<>''''');
        PTEAppObjectTableFields.LookupMode := true;
        PTEAppObjectTableFields.Editable := false;
        PTEAppObjectTableFields.SetTableView(PTEAppObjectTableField);
        if PTEAppObjectTableFields.RunModal() = Action::LookupOK then begin
            PTEMigrationDataset.Get("Migration Dataset Code");
            PTEAppObjectTableFields.GetRecord(PTEAppObjectTableField);
            case SQLDatabaseCode of
                PTEMigrationDataset."Source SQL Database Code":
                    "Source Field Name" := PTEAppObjectTableField.Name;
                PTEMigrationDataset."Target SQL Database Code":
                    begin
                        "Target Field Name" := PTEAppObjectTableField.Name;
                        ValidateConstantValue(PTEAppObjectTableField.Datatype);
                    end;

            end;
        end;
    end;

    local procedure InsertSourceTableFieldOptions()
    var
        PTEMigrDsTblFldOption: Record "PTE Migr. Ds. Tbl. Fld. Option";
        PTEAppObjectTblFieldOpt: record "PTE App. Object Tbl.Field Opt.";
    begin
        CalcFields("Source SQL Database Code");
        PTEMigrDsTblFldOption.SetRange("Migration Dataset Code", "Migration Dataset Code");
        PTEMigrDsTblFldOption.SetRange("Source Table Name", "Source Table Name");
        PTEMigrDsTblFldOption.SetRange("Source Field Name", "Source Field Name");
        PTEMigrDsTblFldOption.DeleteAll();

        PTEAppObjectTblFieldOpt.SetRange("SQL Database Code", "Source SQL Database Code");
        PTEAppObjectTblFieldOpt.SetRange("Table Name", "Source table name");
        PTEAppObjectTblFieldOpt.SetRange("Field Name", "Source Field Name");
        if PTEAppObjectTblFieldOpt.Findset() then
            repeat
                PTEMigrDsTblFldOption.init();
                PTEMigrDsTblFldOption."Migration Dataset Code" := "Migration Dataset Code";
                PTEMigrDsTblFldOption."Source table name" := "Source Table Name";
                PTEMigrDsTblFldOption."Source Field Name" := "Source Field Name";
                PTEMigrDsTblFldOption."Source Option ID" := PTEAppObjectTblFieldOpt."Option ID";
                PTEMigrDsTblFldOption."Source Option Name" := PTEAppObjectTblFieldOpt.Name;
                PTEMigrDsTblFldOption.Insert();
            until PTEAppObjectTblFieldOpt.Next() = 0;
    end;

    local procedure AssignTargetTableFieldOptions()
    var
        PTEMigrDsTblFldOption: Record "PTE Migr. Ds. Tbl. Fld. Option";
        PTEAppObjectTblFieldOpt: record "PTE App. Object Tbl.Field Opt.";
    begin
        CalcFields("Target SQL Database Code");
        PTEMigrDsTblFldOption.SetRange("Migration Dataset Code", "Migration Dataset Code");
        PTEMigrDsTblFldOption.SetRange("Source Table Name", "Source Table Name");
        PTEMigrDsTblFldOption.SetRange("Source Field Name", "Source Field Name");
        if PTEMigrDsTblFldOption.Findset() then
            repeat
                PTEAppObjectTblFieldOpt.SetRange("SQL Database Code", "Target SQL Database Code");
                PTEAppObjectTblFieldOpt.SetRange("Table Name", "Target table name");
                PTEAppObjectTblFieldOpt.SetRange("Field Name", "Target Field Name");
                PTEAppObjectTblFieldOpt.SetRange("Option ID", PTEMigrDsTblFldOption."Source Option ID");
                if PTEAppObjectTblFieldOpt.FindFirst() then begin
                    PTEMigrDsTblFldOption."Target Option ID" := PTEAppObjectTblFieldOpt."Option ID";
                    PTEMigrDsTblFldOption."Target Option Name" := PTEAppObjectTblFieldOpt.Name;
                    PTEMigrDsTblFldOption.Modify();
                end;
            until PTEMigrDsTblFldOption.Next() = 0;
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
        PTEMigrDsTblFldOption: Record "PTE Migr. Ds. Tbl. Fld. Option";
        PTEMigrDatasetError: Record "PTE Migr. Dataset Error";
        PTEMigrDataTableFieldProposal: Record "PTEMigrDataTableFieldProposal";
        PTEMigrDsTableFieldAddTarget: Record PTEMigrDsTableFieldAddTarget;
    begin
        PTEMigrDsTblFldOption.SetRange("Migration Dataset Code", "Migration Dataset Code");
        PTEMigrDsTblFldOption.SetRange("Source Table Name", "Source Table Name");
        PTEMigrDsTblFldOption.SetRange("Source Field Name", "Source Field Name");
        PTEMigrDsTblFldOption.DeleteAll();

        PTEMigrDatasetError.SetRange("Migration Dataset Code", "Migration Dataset Code");
        PTEMigrDatasetError.SetRange("Source Table Name", "Source Table Name");
        PTEMigrDatasetError.SetRange("Source Field Name", "Source Field Name");
        PTEMigrDatasetError.DeleteAll();

        PTEMigrDataTableFieldProposal.SetRange("Migration Dataset Code", "Migration Dataset Code");
        PTEMigrDataTableFieldProposal.SetRange("Source Table Name", "Source Table Name");
        PTEMigrDataTableFieldProposal.SetRange("Source Field Name", "Source Field Name");
        PTEMigrDataTableFieldProposal.DeleteAll();

        PTEMigrDsTableFieldAddTarget.SetRange("Migration Dataset Code", Rec."Migration Dataset Code");
        PTEMigrDsTableFieldAddTarget.SetRange("Source table name", rec."Source table name");
        PTEMigrDsTableFieldAddTarget.SetRange("Source Field Name", Rec."Source Field Name");
        PTEMigrDsTableFieldAddTarget.DeleteAll(true);
    end;

    procedure GetSQLSourceFieldName(): Text[150]
    var
        PTEAppObjectTableField: Record "PTE App. Object Table Field";
    begin
        CalcFields("Source SQL Database Code");
        PTEAppObjectTableField.SetRange("SQL Database Code", "Source SQL Database Code");
        PTEAppObjectTableField.SetRange("Table Name", "Source table name");
        PTEAppObjectTableField.SetRange(Name, "Source Field Name");
        PTEAppObjectTableField.FindFirst();

        exit(PTEAppObjectTableField."SQL Field Name");
    end;

    procedure GetSQLTargetFieldName(): Text[150]
    var
        PTEAppObjectTableField: Record "PTE App. Object Table Field";
    begin
        CalcFields("Target SQL Database Code");
        PTEAppObjectTableField.SetRange("SQL Database Code", "Target SQL Database Code");
        PTEAppObjectTableField.SetRange("Table Name", "Target table name");
        PTEAppObjectTableField.SetRange(Name, "Target Field Name");
        PTEAppObjectTableField.FindFirst();

        exit(PTEAppObjectTableField."SQL Field Name");
    end;

    procedure GetSQLSourceTableName(CompanyName: Text[150]): Text[250]
    var
        PTEAppObjectTableField: Record "PTE App. Object Table Field";
    begin
        CalcFields("Source SQL Database Code");
        PTEAppObjectTableField.SetRange("SQL Database Code", "Source SQL Database Code");
        PTEAppObjectTableField.SetRange("Table Name", "Source table name");
        if "Mapping Type" = "Mapping Type"::FieldToField then
            PTEAppObjectTableField.SetRange(Name, "Source Field Name");
        PTEAppObjectTableField.FindFirst();

        exit(PTEAppObjectTableField.GetSQLTableName(CompanyName));
    end;

    procedure GetSQLTargetTableName(CompanyName: Text[150]): Text[250]
    var
        PTEAppObjectTableField: Record "PTE App. Object Table Field";
    begin
        CalcFields("Target SQL Database Code");
        PTEAppObjectTableField.SetRange("SQL Database Code", "Target SQL Database Code");
        PTEAppObjectTableField.SetRange("Table Name", "Target table name");
        PTEAppObjectTableField.SetRange(Name, "Target Field Name");
        PTEAppObjectTableField.FindFirst();

        exit(PTEAppObjectTableField.GetSQLTableName(CompanyName));
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

