table 99031 ITIMigrDsTableFieldAddTarget
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
            TableRelation = "ITI App. Object Table Field".Name where("SQL Database Code" = field("Target SQL Database Code"), "Table Name" = field("Target table name"), "SQL Table Name Excl. C. Name" = filter(<> ''), "SQL Field Name" = filter(<> ''));
            trigger OnLookup()
            begin
                GetTargetObjectTableField();
            end;

            trigger OnValidate()
            var
                ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field";
            begin
                ITIMigrDatasetTableField.SetRange("Migration Dataset Code", Rec."Migration Dataset Code");
                ITIMigrDatasetTableField.SetRange("Source table name", Rec."Source table name");
                ITIMigrDatasetTableField.SetRange("Target table name", Rec."Target table name");
                ITIMigrDatasetTableField.SetRange("Target Field name", Rec."Target Field Name");

                if not ITIMigrDatasetTableField.IsEmpty() then
                    Error(FieldIsInUseErr, Rec."Target Field name");
            end;
        }
        field(60; "Target SQL Database Code"; Text[250])
        {
            Caption = 'Target SQL Database Code';
            FieldClass = FlowField;
            CalcFormula = lookup("ITI Migration Dataset"."Target SQL Database Code" where(Code = field("Migration Dataset Code")));
            Editable = false;
        }
        field(70; "Target table name"; Text[100])
        {
            Caption = 'Target table name';
            DataClassification = ToBeClassified;
            TableRelation = "ITI Migration Dataset Table"."Target Table Name" where("Source Table Name" = field("Source table name"));
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
        ITIMigrDsTableFieldAddTarOpti: Record ITIMigrDsTableFieldAddTarOpti;
    begin
        ITIMigrDsTableFieldAddTarOpti.SetRange("Migration Dataset Code", Rec."Migration Dataset Code");
        ITIMigrDsTableFieldAddTarOpti.SetRange("Source table name", Rec."Source table name");
        ITIMigrDsTableFieldAddTarOpti.SetRange("Source Field Name", Rec."Source Field Name");
        ITIMigrDsTableFieldAddTarOpti.SetRange("Target Field Name", Rec."Target Field Name");
        if not ITIMigrDsTableFieldAddTarOpti.IsEmpty() then
            ITIMigrDsTableFieldAddTarOpti.DeleteAll();
    end;

    local procedure GetTargetObjectTableField()
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
        ITIMigrationDatasetTable: Record "ITI Migration Dataset Table";
    begin
        ITIMigrationDataset.Get("Migration Dataset Code");
        ITIMigrationDatasetTable.Get("Migration Dataset Code", "Source table name");
        "Target table name" := ITIMigrationDatasetTable."Target table name";
        GetObjectTableField(ITIMigrationDataset."Target SQL Database Code", "Target table name");
    end;

    local procedure GetObjectTableField(SQLDatabaseCode: code[20]; TableName: Text[100])
    var
        SourceITIAppObjectTableField: Record "ITI App. Object Table Field";
        ITIAppObjectTableField: Record "ITI App. Object Table Field";
        ITIMigrationDataset: Record "ITI Migration Dataset";
        ITIAppObjectTableFields: Page "ITI App. Object Table Fields";
    begin
        ITIMigrationDataset.Get("Migration Dataset Code");

        SourceITIAppObjectTableField.SetRange("SQL Database Code", ITIMigrationDataset."Source SQL Database Code");
        SourceITIAppObjectTableField.SetRange("Table Name", Rec."Source table name");
        SourceITIAppObjectTableField.SetRange(Name, Rec."Source Field Name");
        if SourceITIAppObjectTableField.FindFirst() then
            ITIAppObjectTableField.SetRange(Datatype, SourceITIAppObjectTableField.Datatype);

        ITIAppObjectTableField.SetRange("SQL Database Code", SQLDatabaseCode);
        ITIAppObjectTableField.SetRange("Table Name", TableName);
        ITIAppObjectTableField.SetFilter("SQL Table Name Excl. C. Name", '<>''''');
        ITIAppObjectTableField.SetFilter("SQL Field Name", '<>''''');
        ITIAppObjectTableFields.LookupMode := true;
        ITIAppObjectTableFields.Editable := false;
        ITIAppObjectTableFields.SetTableView(ITIAppObjectTableField);
        if ITIAppObjectTableFields.RunModal() = Action::LookupOK then begin
            ITIAppObjectTableFields.GetRecord(ITIAppObjectTableField);
            Rec.Validate("Target Field Name", ITIAppObjectTableField.Name);
            ValidateConstantValue(ITIAppObjectTableField.Datatype);
        end;
    end;

    procedure GetSQLSourceFieldName(): Text[100]
    var
        ITIAppObjectTableField: Record "ITI App. Object Table Field";
        ITIMigrationDataset: Record "ITI Migration Dataset";
    begin
        ITIMigrationDataset.Get(Rec."Migration Dataset Code");

        ITIAppObjectTableField.SetRange("SQL Database Code", ITIMigrationDataset."Source SQL Database Code");
        ITIAppObjectTableField.SetRange("Table Name", "Source table name");
        ITIAppObjectTableField.SetRange(Name, "Source Field Name");
        ITIAppObjectTableField.FindFirst();

        exit(ITIAppObjectTableField."SQL Field Name");
    end;

    procedure GetSQLTargetFieldName(): Text[100]
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

    local procedure ValidateConstantValue(DataType: Text)
    var
        ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field";
        ValueInt: Integer;
        ValueDec: Decimal;
        GuidValue: Guid;
        DateValue: Date;
        DateTimeValue: DateTime;
        ValueBool, OK : Boolean;

    begin
        ITIMigrDatasetTableField.Get(Rec."Migration Dataset Code", Rec."Source table name", Rec."Source Field Name");
        if ITIMigrDatasetTableField."Mapping Type" <> ITIMigrDatasetTableField."Mapping Type"::ConstantToField then
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
