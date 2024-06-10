codeunit 99020 PTEFieldsMappingProposition
{
    procedure ProposeFieldsMapping(MigrationDatasetCode: Code[20]; SourceTableName: text[150]; TargetSQLDatabaseCode: Text[250]; TargetTableName: Text[150])
    var
        PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field";
        PTEMigrDataTableFieldProposal: Record "PTEMigrDataTableFieldProposal";
    begin
        PTEMigrDataTableFieldProposal.SetRange("Migration Dataset Code", MigrationDatasetCode);
        PTEMigrDataTableFieldProposal.SetRange("Source table name", SourceTableName);
        if PTEMigrDataTableFieldProposal.FindSet() then
            PTEMigrDataTableFieldProposal.DeleteAll();

        PTEMigrDatasetTableField.SetRange("Migration Dataset Code", MigrationDatasetCode);
        PTEMigrDatasetTableField.SetRange("Source table name", SourceTableName);
        PTEMigrDatasetTableField.SetRange("Target Field name", '');
        PTEMigrDatasetTableField.SetRange("Mapping Type", PTEMigrDatasetTableField."Mapping Type"::FieldToField);

        if not PTEMigrDatasetTableField.IsEmpty() then begin
            GlobalMigrationDatasetCode := MigrationDatasetCode;
            GetUnusedFields(SourceTableName, TargetSQLDatabaseCode, TargetTableName);
            if PTEMigrDatasetTableField.FindSet() then
                repeat
                    MakeMappingProposition(PTEMigrDatasetTableField);
                until PTEMigrDatasetTableField.Next() = 0;
        end;
    end;

    local procedure GetUnusedFields(SourceTableName: Text[150]; TargetSQLDatabaseCode: Text[250]; TargetTableName: Text[150])
    var
        PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field";
        PTEAppObjectTableField: Record "PTE App. Object Table Field";
    begin
        PTEMigrDatasetTableField.SetRange("Migration Dataset Code", GlobalMigrationDatasetCode);
        PTEMigrDatasetTableField.SetRange("Source table name", SourceTableName);

        PTEAppObjectTableField.SetRange("SQL Database Code", TargetSQLDatabaseCode);
        PTEAppObjectTableField.SetRange("Table Name", TargetTableName);
        PTEAppObjectTableField.SetFilter("SQL Table Name Excl. C. Name", '<>%1', '');
        PTEAppObjectTableField.SetFilter("SQL Field Name", '<>%1', '');

        if PTEAppObjectTableField.FindSet() then begin
            repeat
                PTEMigrDatasetTableField.SetRange("Target Field name", PTEAppObjectTableField.Name);
                if PTEMigrDatasetTableField.IsEmpty() then begin
                    if not UnusedField.ContainsKey(PTEAppObjectTableField.ID) then
                        UnusedField.Add(PTEAppObjectTableField.ID, PTEAppObjectTableField.Name);
                    if not UnusedFieldType.ContainsKey(PTEAppObjectTableField.Name) then
                        UnusedFieldType.Add(PTEAppObjectTableField.Name, PTEAppObjectTableField.Datatype);
                end;
            until PTEAppObjectTableField.Next() = 0;
            FormatUnusedFields();
        end;
    end;

    local procedure MakeMappingProposition(PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field")
    var
        SourcePTEAppObjectTableField: Record "PTE App. Object Table Field";
        PTEMigrDataTableFieldProposal: Record "PTEMigrDataTableFieldProposal";
    begin
        PTEMigrDatasetTableField.CalcFields("Source SQL Database Code");
        SourcePTEAppObjectTableField.SetRange("SQL Database Code", PTEMigrDatasetTableField."Source SQL Database Code");
        SourcePTEAppObjectTableField.SetRange("Table Name", PTEMigrDatasetTableField."Source table name");
        SourcePTEAppObjectTableField.SetRange(Name, PTEMigrDatasetTableField."Source Field Name");
        if SourcePTEAppObjectTableField.FindFirst() then begin
            if (UnusedField.Keys.Contains(SourcePTEAppObjectTableField.ID)) then
                if (UnusedFieldType.Get(UnusedField.Get(SourcePTEAppObjectTableField.ID)) = SourcePTEAppObjectTableField.Datatype) then
                    PTEMigrDataTableFieldProposal := InsertProposition(PTEMigrDatasetTableField, SourcePTEAppObjectTableField.ID);

            ChekIfFieldNameExistInUnusedFields(PTEMigrDatasetTableField."Source Field Name", PTEMigrDatasetTableField, SourcePTEAppObjectTableField.Datatype);
        end;
    end;

    local procedure InsertProposition(PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field"; PropositionFieldId: Integer): Record "PTEMigrDataTableFieldProposal";
    var
        PTEMigrDataTableFieldProposal: Record "PTEMigrDataTableFieldProposal";
    begin
        PTEMigrDataTableFieldProposal.Reset();
        if not PTEMigrDataTableFieldProposal.Get(GlobalMigrationDatasetCode, PTEMigrDatasetTableField."Source table name", PTEMigrDatasetTableField."Source Field Name", UnusedField.Get(PropositionFieldId)) then begin
            PTEMigrDataTableFieldProposal.Init();
            PTEMigrDataTableFieldProposal."Migration Dataset Code" := GlobalMigrationDatasetCode;
            PTEMigrDataTableFieldProposal."Source table name" := PTEMigrDatasetTableField."Source table name";
            PTEMigrDataTableFieldProposal."Source SQL Database Code" := PTEMigrDatasetTableField."Source SQL Database Code";
            PTEMigrDataTableFieldProposal."Source Field Name" := PTEMigrDatasetTableField."Source Field Name";
            PTEMigrDataTableFieldProposal."Target Field Name Proposal" := UnusedField.Get(PropositionFieldId);
            PTEMigrDataTableFieldProposal."Target Field No. Proposal" := PropositionFieldId;
            PTEMigrDataTableFieldProposal."Field Data Type" := UnusedFieldType.Get(UnusedField.Get(PropositionFieldId));
            PTEMigrDataTableFieldProposal.Insert();
        end;
        exit(PTEMigrDataTableFieldProposal);
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

    local procedure ChekIfFieldNameExistInUnusedFields(FieldName: Text[150]; PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field"; DataType: Text[150])
    var
        TextIterator: Text[150];
        FrmatedFieldName: Text[150];
    begin
        FrmatedFieldName := FieldName.ToUpper();
        FrmatedFieldName := DELCHR(FrmatedFieldName, '=', DELCHR(FrmatedFieldName, '=', '1234567890QAZWSXEDCRFVTGBYHNUJMIKOLP'));
        foreach TextIterator in UnusedFieldsName.Keys do
            if (TextIterator.Contains(FrmatedFieldName)) then
                if (DataType = UnusedFieldType.Get(UnusedFieldsName.get(TextIterator))) then
                    InsertProposition(PTEMigrDatasetTableField, GetUnusedFieldIdByName(UnusedFieldsName.Get(TextIterator)));
    end;


    local procedure GetUnusedFieldIdByName(FieldName: Text[150]): Integer
    var
        iterator: Integer;
    begin
        foreach iterator in UnusedField.Keys do
            if UnusedField.Get(iterator).ToUpper() = FieldName.ToUpper() then
                exit(iterator);
    end;

    [EventSubscriber(ObjectType::Table, Database::"PTE Migr. Dataset Table Field", 'OnAfterModifyEvent', '', false, false)]
    local procedure CheckModifyReck(var Rec: Record "PTE Migr. Dataset Table Field"; var xRec: Record "PTE Migr. Dataset Table Field"; RunTrigger: Boolean)
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