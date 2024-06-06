codeunit 99020 ITIFieldsMappingProposition
{
    procedure ProposeFieldsMapping(MigrationDatasetCode: Code[20]; SourceTableName: text[150]; TargetSQLDatabaseCode: Text[250]; TargetTableName: Text[150])
    var
        ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field";
        ITIMigrDataTableFieldProposal: Record "ITIMigrDataTableFieldProposal";
    begin
        ITIMigrDataTableFieldProposal.SetRange("Migration Dataset Code", MigrationDatasetCode);
        ITIMigrDataTableFieldProposal.SetRange("Source table name", SourceTableName);
        if ITIMigrDataTableFieldProposal.FindSet() then
            ITIMigrDataTableFieldProposal.DeleteAll();

        ITIMigrDatasetTableField.SetRange("Migration Dataset Code", MigrationDatasetCode);
        ITIMigrDatasetTableField.SetRange("Source table name", SourceTableName);
        ITIMigrDatasetTableField.SetRange("Target Field name", '');
        ITIMigrDatasetTableField.SetRange("Mapping Type", ITIMigrDatasetTableField."Mapping Type"::FieldToField);

        if not ITIMigrDatasetTableField.IsEmpty() then begin
            GlobalMigrationDatasetCode := MigrationDatasetCode;
            GetUnusedFields(SourceTableName, TargetSQLDatabaseCode, TargetTableName);
            if ITIMigrDatasetTableField.FindSet() then
                repeat
                    MakeMappingProposition(ITIMigrDatasetTableField);
                until ITIMigrDatasetTableField.Next() = 0;
        end;
    end;

    local procedure GetUnusedFields(SourceTableName: Text[150]; TargetSQLDatabaseCode: Text[250]; TargetTableName: Text[150])
    var
        ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field";
        ITIAppObjectTableField: Record "ITI App. Object Table Field";
    begin
        ITIMigrDatasetTableField.SetRange("Migration Dataset Code", GlobalMigrationDatasetCode);
        ITIMigrDatasetTableField.SetRange("Source table name", SourceTableName);

        ITIAppObjectTableField.SetRange("SQL Database Code", TargetSQLDatabaseCode);
        ITIAppObjectTableField.SetRange("Table Name", TargetTableName);
        ITIAppObjectTableField.SetFilter("SQL Table Name Excl. C. Name", '<>%1', '');
        ITIAppObjectTableField.SetFilter("SQL Field Name", '<>%1', '');

        if ITIAppObjectTableField.FindSet() then begin
            repeat
                ITIMigrDatasetTableField.SetRange("Target Field name", ITIAppObjectTableField.Name);
                if ITIMigrDatasetTableField.IsEmpty() then begin
                    if not UnusedField.ContainsKey(ITIAppObjectTableField.ID) then
                        UnusedField.Add(ITIAppObjectTableField.ID, ITIAppObjectTableField.Name);
                    if not UnusedFieldType.ContainsKey(ITIAppObjectTableField.Name) then
                        UnusedFieldType.Add(ITIAppObjectTableField.Name, ITIAppObjectTableField.Datatype);
                end;
            until ITIAppObjectTableField.Next() = 0;
            FormatUnusedFields();
        end;
    end;

    local procedure MakeMappingProposition(ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field")
    var
        SourceITIAppObjectTableField: Record "ITI App. Object Table Field";
        ITIMigrDataTableFieldProposal: Record "ITIMigrDataTableFieldProposal";
    begin
        ITIMigrDatasetTableField.CalcFields("Source SQL Database Code");
        SourceITIAppObjectTableField.SetRange("SQL Database Code", ITIMigrDatasetTableField."Source SQL Database Code");
        SourceITIAppObjectTableField.SetRange("Table Name", ITIMigrDatasetTableField."Source table name");
        SourceITIAppObjectTableField.SetRange(Name, ITIMigrDatasetTableField."Source Field Name");
        if SourceITIAppObjectTableField.FindFirst() then begin
            if (UnusedField.Keys.Contains(SourceITIAppObjectTableField.ID)) then
                if (UnusedFieldType.Get(UnusedField.Get(SourceITIAppObjectTableField.ID)) = SourceITIAppObjectTableField.Datatype) then
                    ITIMigrDataTableFieldProposal := InsertProposition(ITIMigrDatasetTableField, SourceITIAppObjectTableField.ID);

            ChekIfFieldNameExistInUnusedFields(ITIMigrDatasetTableField."Source Field Name", ITIMigrDatasetTableField, SourceITIAppObjectTableField.Datatype);
        end;
    end;

    local procedure InsertProposition(ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field"; PropositionFieldId: Integer): Record "ITIMigrDataTableFieldProposal";
    var
        ITIMigrDataTableFieldProposal: Record "ITIMigrDataTableFieldProposal";
    begin
        ITIMigrDataTableFieldProposal.Reset();
        if not ITIMigrDataTableFieldProposal.Get(GlobalMigrationDatasetCode, ITIMigrDatasetTableField."Source table name", ITIMigrDatasetTableField."Source Field Name", UnusedField.Get(PropositionFieldId)) then begin
            ITIMigrDataTableFieldProposal.Init();
            ITIMigrDataTableFieldProposal."Migration Dataset Code" := GlobalMigrationDatasetCode;
            ITIMigrDataTableFieldProposal."Source table name" := ITIMigrDatasetTableField."Source table name";
            ITIMigrDataTableFieldProposal."Source SQL Database Code" := ITIMigrDatasetTableField."Source SQL Database Code";
            ITIMigrDataTableFieldProposal."Source Field Name" := ITIMigrDatasetTableField."Source Field Name";
            ITIMigrDataTableFieldProposal."Target Field Name Proposal" := UnusedField.Get(PropositionFieldId);
            ITIMigrDataTableFieldProposal."Target Field No. Proposal" := PropositionFieldId;
            ITIMigrDataTableFieldProposal."Field Data Type" := UnusedFieldType.Get(UnusedField.Get(PropositionFieldId));
            ITIMigrDataTableFieldProposal.Insert();
        end;
        exit(ITIMigrDataTableFieldProposal);
    end;

    local procedure FormatUnusedFields()
    var
        TextIterator: Text[150];
        TextChanged: Text[150];
    begin
        foreach TextIterator in UnusedFieldType.Keys() do begin
            TextChanged := TextIterator.ToUpper();
            TextChanged := DELCHR(TextChanged, '=', DELCHR(TextChanged, '=', '1234567890QAZWSXEDCRFVTGBYHNUJMIKOLP'));
            if not UnusedFieldsName.ContainsKey(TextChanged) then
                UnusedFieldsName.Add(TextChanged, TextIterator);
        end;
    end;

    local procedure ChekIfFieldNameExistInUnusedFields(FieldName: Text[150]; ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field"; DataType: Text[150])
    var
        TextIterator: Text[150];
        FrmatedFieldName: Text[150];
    begin
        FrmatedFieldName := FieldName.ToUpper();
        FrmatedFieldName := DELCHR(FrmatedFieldName, '=', DELCHR(FrmatedFieldName, '=', '1234567890QAZWSXEDCRFVTGBYHNUJMIKOLP'));
        foreach TextIterator in UnusedFieldsName.Keys do
            if (TextIterator.Contains(FrmatedFieldName)) then
                if (DataType = UnusedFieldType.Get(UnusedFieldsName.get(TextIterator))) then
                    InsertProposition(ITIMigrDatasetTableField, GetUnusedFieldIdByName(UnusedFieldsName.Get(TextIterator)));
    end;


    local procedure GetUnusedFieldIdByName(FieldName: Text[150]): Integer
    var
        iterator: Integer;
    begin
        foreach iterator in UnusedField.Keys do
            if UnusedField.Get(iterator).ToUpper() = FieldName.ToUpper() then
                exit(iterator);
    end;

    [EventSubscriber(ObjectType::Table, Database::"ITI Migr. Dataset Table Field", 'OnAfterModifyEvent', '', false, false)]
    local procedure CheckModifyReck(var Rec: Record "ITI Migr. Dataset Table Field"; var xRec: Record "ITI Migr. Dataset Table Field"; RunTrigger: Boolean)
    begin
        if Rec."Target Field name" <> xRec."Target Field name" then
            ProposeFieldsMapping(Rec."Migration Dataset Code", Rec."Source table name", Rec."Target SQL Database Code", Rec."Target table name");
    end;

    var
        UnusedField: Dictionary of [Integer, Text[150]];
        UnusedFieldType: Dictionary of [Text[150], Text[150]];
        GlobalMigrationDatasetCode: Code[20];
        UnusedFieldsName: Dictionary of [Text[150], Text[150]];
}