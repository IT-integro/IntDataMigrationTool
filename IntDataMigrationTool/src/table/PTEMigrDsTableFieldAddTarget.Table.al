table 99031 PTEMigrDsTableFieldAddTarget
{
    Caption = 'Dataset Table Field Additional Target';
    DataClassification = ToBeClassified;

    fields
    {
        field(10; "Migration Dataset Code"; Code[20])
        {
            Caption = 'Migration Dataset Code';
        }
        field(20; "Source table name"; Text[100])
        {
            Caption = 'Source table name';
        }
        field(30; "Source Field Name"; Text[100])
        {
            Caption = 'Source Field Name';
        }
        field(40; "Target Field Name"; Text[100])
        {
            Caption = 'Target Field Name';
            TableRelation = "PTE App. Object Table Field".Name where("SQL Database Code" = field("Target SQL Database Code"), "Table Name" = field("Target table name"), "SQL Table Name Excl. C. Name" = filter(<> ''), "SQL Field Name" = filter(<> ''));
            trigger OnLookup()
            begin
                GetTargetObjectTableField();
            end;

            trigger OnValidate()
            var
                PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field";
            begin
                PTEMigrDatasetTableField.SetRange("Migration Dataset Code", Rec."Migration Dataset Code");
                PTEMigrDatasetTableField.SetRange("Source table name", Rec."Source table name");
                PTEMigrDatasetTableField.SetRange("Target table name", Rec."Target table name");
                PTEMigrDatasetTableField.SetRange("Target Field name", Rec."Target Field Name");

                if not PTEMigrDatasetTableField.IsEmpty() then
                    Error(FieldIsInUseErr, Rec."Target Field name");
            end;
        }
        field(60; "Target SQL Database Code"; Text[250])
        {
            Caption = 'Target SQL Database Code';
            FieldClass = FlowField;
            CalcFormula = lookup("PTE Migration Dataset"."Target SQL Database Code" where(Code = field("Migration Dataset Code")));
            Editable = false;
        }
        field(70; "Target table name"; Text[100])
        {
            Caption = 'Target table name';
            DataClassification = ToBeClassified;
            TableRelation = "PTE Migration Dataset Table"."Target Table Name" where("Source Table Name" = field("Source table name"), "Migration Dataset Code" = field("Migration Dataset Code"));
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Migration Dataset Code", "Source table name", "Source Field Name", "Target Field Name")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        PTEMigrDsTableFieldAddTarOpti: Record PTEMigrDsTableFieldAddTarOpti;
    begin
        PTEMigrDsTableFieldAddTarOpti.SetRange("Migration Dataset Code", Rec."Migration Dataset Code");
        PTEMigrDsTableFieldAddTarOpti.SetRange("Source table name", Rec."Source table name");
        PTEMigrDsTableFieldAddTarOpti.SetRange("Source Field Name", Rec."Source Field Name");
        PTEMigrDsTableFieldAddTarOpti.SetRange("Target Field Name", Rec."Target Field Name");
        if not PTEMigrDsTableFieldAddTarOpti.IsEmpty() then
            PTEMigrDsTableFieldAddTarOpti.DeleteAll();
    end;

    local procedure GetTargetObjectTableField()
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
        PTEMigrationDatasetTable: Record "PTE Migration Dataset Table";
    begin
        PTEMigrationDataset.Get("Migration Dataset Code");
        PTEMigrationDatasetTable.Get("Migration Dataset Code", "Source table name");
        "Target table name" := PTEMigrationDatasetTable."Target table name";
        GetObjectTableField(PTEMigrationDataset."Target SQL Database Code", "Target table name");
    end;

    local procedure GetObjectTableField(SQLDatabaseCode: code[20]; TableName: Text[100])
    var
        SourcePTEAppObjectTableField: Record "PTE App. Object Table Field";
        PTEAppObjectTableField: Record "PTE App. Object Table Field";
        PTEMigrationDataset: Record "PTE Migration Dataset";
        PTEAppObjectTableFields: Page "PTE App. Object Table Fields";
    begin
        PTEMigrationDataset.Get("Migration Dataset Code");

        SourcePTEAppObjectTableField.SetRange("SQL Database Code", PTEMigrationDataset."Source SQL Database Code");
        SourcePTEAppObjectTableField.SetRange("Table Name", Rec."Source table name");
        SourcePTEAppObjectTableField.SetRange(Name, Rec."Source Field Name");
        if SourcePTEAppObjectTableField.FindFirst() then
            PTEAppObjectTableField.SetRange(Datatype, SourcePTEAppObjectTableField.Datatype);

        PTEAppObjectTableField.SetRange("SQL Database Code", SQLDatabaseCode);
        PTEAppObjectTableField.SetRange("Table Name", TableName);
        PTEAppObjectTableField.SetFilter("SQL Table Name Excl. C. Name", '<>''''');
        PTEAppObjectTableField.SetFilter("SQL Field Name", '<>''''');
        PTEAppObjectTableFields.LookupMode := true;
        PTEAppObjectTableFields.Editable := false;
        PTEAppObjectTableFields.SetTableView(PTEAppObjectTableField);
        if PTEAppObjectTableFields.RunModal() = Action::LookupOK then begin
            PTEAppObjectTableFields.GetRecord(PTEAppObjectTableField);
            Rec.Validate("Target Field Name", PTEAppObjectTableField.Name);
            ValidateConstantValue(PTEAppObjectTableField.Datatype);
        end;
    end;

    procedure GetSQLSourceFieldName(): Text[100]
    var
        PTEAppObjectTableField: Record "PTE App. Object Table Field";
        PTEMigrationDataset: Record "PTE Migration Dataset";
    begin
        PTEMigrationDataset.Get(Rec."Migration Dataset Code");

        PTEAppObjectTableField.SetRange("SQL Database Code", PTEMigrationDataset."Source SQL Database Code");
        PTEAppObjectTableField.SetRange("Table Name", "Source table name");
        PTEAppObjectTableField.SetRange(Name, "Source Field Name");
        PTEAppObjectTableField.FindFirst();

        exit(PTEAppObjectTableField."SQL Field Name");
    end;

    procedure GetSQLTargetFieldName(): Text[100]
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

    local procedure ValidateConstantValue(DataType: Text)
    var
        PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field";
        ValueInt: Integer;
        ValueDec: Decimal;
        GuidValue: Guid;
        DateValue: Date;
        DateTimeValue: DateTime;
        ValueBool, OK : Boolean;

    begin
        PTEMigrDatasetTableField.Get(Rec."Migration Dataset Code", Rec."Source table name", Rec."Source Field Name");
        if PTEMigrDatasetTableField."Mapping Type" <> PTEMigrDatasetTableField."Mapping Type"::ConstantToField then
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
        FieldIsInUseErr: Label 'Field %1 is in use in other mapping', Comment = '%1 = Field Name';
        DatatypeIsNotProperErr: Label 'Value %1 can not be inserted into field %2.', Comment = '%1 = Field Value, %2 = Field Name';

}
