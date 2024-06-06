codeunit 99002 "ITI Release Migration Dataset"
{
    Procedure Release(ITIMigrationDataset: Record "ITI Migration Dataset")
    begin
        if ITIMigrationDataset.Released then
            Error(DatasetMustBeOpenErr);
        CheckMigrationDataset(ITIMigrationDataset);

        ITIMigrationDataset.CalcFields("Number of Errors");

        if ITIMigrationDataset."Number of Errors" = 0 then begin
            ITIMigrationDataset.Released := true;
            ITIMigrationDataset.Modify();
        end else
            Message(AfterCheckMsg, ITIMigrationDataset."Number of Errors");
    end;

    Procedure Reopen(ITIMigrationDataset: Record "ITI Migration Dataset")
    begin
        ITIMigrationDataset.Released := False;
        ITIMigrationDataset.Modify();
    end;

    local Procedure CheckMigrationDataset(ITIMigrationDataset: Record "ITI Migration Dataset")
    var
        ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field";
        ITIMigrationDatasetTable: Record "ITI Migration Dataset Table";
        ITIMigrDatasetError: Record "ITI Migr. Dataset Error";
        LineNo: Integer;
        DialogIterator: Integer;
        TableCount: Integer;
        DialogProgress: Dialog;
        ProgressMsg: Label 'Checking tables: From 0 to %1  ', Comment = '#1 = Overall count of tables';

    begin
        LineNo := 1;
        DialogIterator := 1;
        ITIMigrDatasetError.SetRange("Migration Dataset Code", ITIMigrationDataset.Code);
        ITIMigrDatasetError.DeleteAll();

        ITIMigrationDatasetTable.SetRange("Migration Dataset Code", ITIMigrationDataset.Code);
        ITIMigrationDatasetTable.SetRange("Skip in Mapping", false);
        TableCount := ITIMigrationDatasetTable.Count();

        if ITIMigrationDatasetTable.FindSet() then begin
            DialogProgress.Open(StrSubstNo(ProgressMsg, TableCount) + '#1###', DialogIterator);
            repeat
                DialogProgress.Update();
                CheckTableType(ITIMigrationDatasetTable, LineNo);
                CheckKeys(ITIMigrationDatasetTable, LineNo);

                ITIMigrDatasetTableField.SetRange("Migration Dataset Code", ITIMigrationDataset.Code);
                ITIMigrDatasetTableField.SetRange("Source table name", ITIMigrationDatasetTable."Source Table Name");
                ITIMigrDatasetTableField.SetRange("Skip in Mapping", false);
                if ITIMigrDatasetTableField.FindSet() then
                    repeat
                        CheckIfTargetFieldIsFilled(ITIMigrDatasetTableField, LineNo);
                        CheckIfSourceFieldIsFilled(ITIMigrDatasetTableField, LineNo);
                        if ITIMigrDatasetTableField."Mapping Type" = ITIMigrDatasetTableField."Mapping Type"::FieldToField then
                            CheckFieldData(ITIMigrDatasetTableField, ITIMigrationDatasetTable, LineNo);
                    until ITIMigrDatasetTableField.Next() = 0;
                DialogIterator += 1;
            until ITIMigrationDatasetTable.Next() = 0;
        end
        else
            Error(NoMigrationTablesErr);
    end;

    local procedure CheckTableType(ITIMigrationDatasetTable: Record "ITI Migration Dataset Table"; var LineNo: Integer)
    var
        SrcITIAppObjectTable: Record "ITI App. Object Table";
        DstITIAppObjectTable: Record "ITI App. Object Table";
    begin
        SrcITIAppObjectTable.SetRange("SQL Database Code", ITIMigrationDatasetTable."Source SQL Database Code");
        DstITIAppObjectTable.SetRange("SQL Database Code", ITIMigrationDatasetTable."Target SQL Database Code");
        if SrcITIAppObjectTable.FindFirst() then begin                                                           //Check table type and obsolete state
            if SrcITIAppObjectTable.TableType.ToLower() <> 'normal' then
                AddNewError(ITIMigrationDatasetTable."Migration Dataset Code", SrcITIAppObjectTable.Name, '', StrSubstNo(WrongTableTypeErr, SrcITIAppObjectTable.Name, SrcITIAppObjectTable.TableType), 0, LineNo, false);
            if SrcITIAppObjectTable.ObsoleteState.ToLower() = 'removed' then
                AddNewError(ITIMigrationDatasetTable."Migration Dataset Code", SrcITIAppObjectTable.Name, '', StrSubstNo(ObsoleteTableErr, SrcITIAppObjectTable.Name), 0, LineNo, SrcITIAppObjectTable.ObsoleteState, SrcITIAppObjectTable.ObsoleteReason, '', '', false);
        end;
        if DstITIAppObjectTable.FindFirst() then begin
            if DstITIAppObjectTable.TableType.ToLower() <> 'normal' then
                AddNewError(ITIMigrationDatasetTable."Migration Dataset Code", DstITIAppObjectTable.Name, '', StrSubstNo(WrongTableTypeErr, DstITIAppObjectTable.Name, DstITIAppObjectTable.TableType), 0, LineNo, false);
            if DstITIAppObjectTable.ObsoleteState.ToLower() = 'removed' then
                AddNewError(ITIMigrationDatasetTable."Migration Dataset Code", DstITIAppObjectTable.Name, '', StrSubstNo(ObsoleteTableErr, DstITIAppObjectTable.Name), 0, LineNo, '', '', DstITIAppObjectTable.ObsoleteState, DstITIAppObjectTable.ObsoleteReason, false);
        end;
        //Add warning if obsolete state has been changed between versions but table is not removed
        if (SrcITIAppObjectTable.ObsoleteState.ToLower() <> DstITIAppObjectTable.ObsoleteState.ToLower()) and (SrcITIAppObjectTable.ObsoleteState.ToLower() <> 'removed') and (DstITIAppObjectTable.ObsoleteState.ToLower() <> 'removed') then
            AddNewError(ITIMigrationDatasetTable."Migration Dataset Code", DstITIAppObjectTable.Name, '', ObsoleteStatesNotMatchingErr, 1, LineNo, false);
    end;

    local procedure CheckKeys(ITIMigrationDatasetTable: Record "ITI Migration Dataset Table"; var LineNo: Integer)
    var
        SrcITIAppObjectTableField: Record "ITI App. Object Table Field";
        DstITIAppObjectTableField: Record "ITI App. Object Table Field";
        ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field";
    begin
        SrcITIAppObjectTableField.SetRange("SQL Database Code", ITIMigrationDatasetTable."Source SQL Database Code");
        SrcITIAppObjectTableField.SetRange("Table Name", ITIMigrationDatasetTable."Source Table Name");
        SrcITIAppObjectTableField.SetRange("Key", true);

        DstITIAppObjectTableField.SetRange("SQL Database Code", ITIMigrationDatasetTable."Target SQL Database Code");
        DstITIAppObjectTableField.SetRange("Table Name", ITIMigrationDatasetTable."Target Table Name");
        DstITIAppObjectTableField.SetRange("Key", true);
        //Check if all source keys will be transfered
        if SrcITIAppObjectTableField.FindSet() then
            repeat
                if not ITIMigrDatasetTableField.Get(ITIMigrationDatasetTable."Migration Dataset Code", ITIMigrationDatasetTable."Source table name", SrcITIAppObjectTableField.Name) then
                    AddNewError(ITIMigrDatasetTableField."Migration Dataset Code", ITIMigrationDatasetTable."Source table name", ITIMigrDatasetTableField."Source Field Name", StrSubstNo(KeyFieldNotFoundInSourceErr, SrcITIAppObjectTableField.Name), 0, LineNo, ITIMigrDatasetTableField."Ignore Errors");
                if ITIMigrDatasetTableField."Target Field name" = '' then
                    AddNewError(ITIMigrDatasetTableField."Migration Dataset Code", ITIMigrationDatasetTable."Source table name", ITIMigrDatasetTableField."Source Field Name", StrSubstNo(KeyFieldHasNoTargetErr, ITIMigrDatasetTableField."Source Field Name", ITIMigrationDatasetTable."Source table name"), 0, LineNo, ITIMigrDatasetTableField."Ignore Errors");
            until SrcITIAppObjectTableField.Next() = 0;
        //Check if all target keys have source values
        if DstITIAppObjectTableField.FindSet() then
            repeat
                ITIMigrDatasetTableField.Reset();
                ITIMigrDatasetTableField.SetRange("Migration Dataset Code", ITIMigrationDatasetTable."Migration Dataset Code");
                ITIMigrDatasetTableField.SetRange("Target table name", DstITIAppObjectTableField."Table Name");
                ITIMigrDatasetTableField.SetRange("Target Field name", DstITIAppObjectTableField.Name);
                if ITIMigrDatasetTableField.IsEmpty() then
                    AddNewError(ITIMigrDatasetTableField."Migration Dataset Code", ITIMigrationDatasetTable."Target table name", ITIMigrDatasetTableField."Target Field Name", StrSubstNo(TargetKeyHasNoSourceFieldErr, DstITIAppObjectTableField.Name, ITIMigrationDatasetTable."Target table name"), 0, LineNo, ITIMigrDatasetTableField."Ignore Errors");
            until DstITIAppObjectTableField.Next() = 0;
    end;

    local procedure CheckIfTargetFieldIsFilled(ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field"; var LineNo: Integer)
    begin
        if ITIMigrDatasetTableField."Target Field name" = '' then
            AddNewError(ITIMigrDatasetTableField."Migration Dataset Code", ITIMigrDatasetTableField."Source table name", ITIMigrDatasetTableField."Source Field Name", NoTargetFieldErr, 1, LineNo, ITIMigrDatasetTableField."Ignore Errors");
    end;

    local procedure CheckIfSourceFieldIsFilled(ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field"; var LineNo: Integer)
    begin
        if ITIMigrDatasetTableField."Source Field Name" = '' then
            AddNewError(ITIMigrDatasetTableField."Migration Dataset Code", ITIMigrDatasetTableField."Source table name", ITIMigrDatasetTableField."Source Field Name", NoSourceFieldErr, 0, LineNo, ITIMigrDatasetTableField."Ignore Errors");
    end;

    local procedure CheckFieldData(ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field"; ITIMigrationDatasetTable: Record "ITI Migration Dataset Table"; LineNo: Integer)
    var
        SrcITIAppObjectTableField: Record "ITI App. Object Table Field";
        DstITIAppObjectTableField: Record "ITI App. Object Table Field";
    begin
        if (ITIMigrDatasetTableField."Source Field Name" = '') or (ITIMigrDatasetTableField."Target Field Name" = '') then
            exit;
        ITIMigrDatasetTableField.CalcFields("Source SQL Database Code", "Target SQL Database Code");

        SrcITIAppObjectTableField.SetRange("SQL Database Code", ITIMigrDatasetTableField."Source SQL Database Code");
        SrcITIAppObjectTableField.SetRange("Table Name", ITIMigrationDatasetTable."Source Table Name");
        SrcITIAppObjectTableField.SetRange(Name, ITIMigrDatasetTableField."Source Field Name");

        DstITIAppObjectTableField.SetRange("SQL Database Code", ITIMigrDatasetTableField."Target SQL Database Code");
        DstITIAppObjectTableField.SetRange("Table Name", ITIMigrationDatasetTable."Target table name");
        DstITIAppObjectTableField.SetRange(Name, ITIMigrDatasetTableField."Target Field Name");

        SrcITIAppObjectTableField.FindFirst();
        DstITIAppObjectTableField.FindFirst();
        //Check data type
        if SrcITIAppObjectTableField.Datatype <> DstITIAppObjectTableField.Datatype then
            AddNewError(ITIMigrationDatasetTable."Migration Dataset Code", ITIMigrationDatasetTable."Source Table Name", ITIMigrDatasetTableField."Source Field Name", DataTypesNotMatchingErr, 0, LineNo, ITIMigrDatasetTableField."Ignore Errors");
        //Check data length
        if (SrcITIAppObjectTableField.DataLength > DstITIAppObjectTableField.DataLength) and (SrcITIAppObjectTableField."Key" = true) then
            AddNewError(ITIMigrationDatasetTable."Migration Dataset Code", ITIMigrationDatasetTable."Source Table Name", ITIMigrDatasetTableField."Source Field Name", StrSubstNo(BiggerKeyLengthOnSourceSideErr, ITIMigrDatasetTableField."Source Field Name"), 0, LineNo, ITIMigrDatasetTableField."Ignore Errors")
        else
            if SrcITIAppObjectTableField.DataLength > DstITIAppObjectTableField.DataLength then
                AddNewError(ITIMigrationDatasetTable."Migration Dataset Code", ITIMigrationDatasetTable."Source Table Name", ITIMigrDatasetTableField."Source Field Name", BiggerDataLengthOnSourcesSideErr, 1, LineNo, ITIMigrDatasetTableField."Ignore Errors");
        //Check field class
        if SrcITIAppObjectTableField.FieldClass.ToLower() in ['flowfield', 'flowfilter'] then
            AddNewError(ITIMigrationDatasetTable."Migration Dataset Code", ITIMigrationDatasetTable."Source Table Name", ITIMigrDatasetTableField."Source Field Name", WrongFieldClassErr, 0, LineNo, ITIMigrDatasetTableField."Ignore Errors");
        //Check Obsolete State and Reason
        if SrcITIAppObjectTableField.ObsoleteState <> DstITIAppObjectTableField.ObsoleteState then
            if (SrcITIAppObjectTableField.ObsoleteState.ToLower() = 'removed') or (DstITIAppObjectTableField.ObsoleteState.ToLower() = 'removed') then
                AddNewError(ITIMigrationDatasetTable."Migration Dataset Code", ITIMigrationDatasetTable."Source Table Name", ITIMigrDatasetTableField."Source Field Name", ObsoleteStateNotMatchingErr, 0, LineNo, SrcITIAppObjectTableField.ObsoleteState, SrcITIAppObjectTableField.ObsoleteReason, DstITIAppObjectTableField.ObsoleteState, DstITIAppObjectTableField.ObsoleteReason, ITIMigrDatasetTableField."Ignore Errors")
            else
                AddNewError(ITIMigrationDatasetTable."Migration Dataset Code", ITIMigrationDatasetTable."Source Table Name", ITIMigrDatasetTableField."Source Field Name", ObsoleteStateNotMatchingErr, 1, LineNo, SrcITIAppObjectTableField.ObsoleteState, SrcITIAppObjectTableField.ObsoleteReason, DstITIAppObjectTableField.ObsoleteState, DstITIAppObjectTableField.ObsoleteReason, ITIMigrDatasetTableField."Ignore Errors");
        //Check SQL params
        if (SrcITIAppObjectTableField."SQL Field Name" = '') or (SrcITIAppObjectTableField."SQL Table Name Excl. C. Name" = '') or (DstITIAppObjectTableField."SQL Field Name" = '') or (DstITIAppObjectTableField."SQL Table Name Excl. C. Name" = '') then
            AddNewError(ITIMigrationDatasetTable."Migration Dataset Code", ITIMigrationDatasetTable."Source Table Name", ITIMigrDatasetTableField."Source Field Name", SqlParamsDifferentErr, 0, LineNo, ITIMigrDatasetTableField."Ignore Errors");
        CheckFieldOptions(SrcITIAppObjectTableField, LineNo, ITIMigrationDatasetTable."Migration Dataset Code", ITIMigrDatasetTableField."Ignore Errors");
    end;

    local procedure CheckFieldOptions(SrcITIAppObjectTableField: Record "ITI App. Object Table Field"; var LineNo: Integer; MigrationDatasetCode: Code[20]; SkipErr: Boolean)
    var
        ITIMigrDsTblFldOption: Record "ITI Migr. Ds. Tbl. Fld. Option";
        ITIAppObjectTblFieldOpt: Record "ITI App. Object Tbl.Field Opt.";
    begin
        //Check if all options from source have targets
        ITIMigrDsTblFldOption.SetRange("Migration Dataset Code", MigrationDatasetCode);
        ITIMigrDsTblFldOption.SetRange("Source table name", SrcITIAppObjectTableField."Table Name");
        ITIMigrDsTblFldOption.SetRange("Source Field Name", SrcITIAppObjectTableField.Name);
        if ITIMigrDsTblFldOption.FindSet() then
            repeat
                if ITIMigrDsTblFldOption."Target Option Name" = '' then
                    AddNewError(MigrationDatasetCode, SrcITIAppObjectTableField."Table Name", SrcITIAppObjectTableField.Name, StrSubstNo(OptionHasNoTargetErr, ITIMigrDsTblFldOption."Source Option Name", SrcITIAppObjectTableField.Name), 0, LineNo, ITIMigrDsTblFldOption."Source Option Name", SkipErr);
            until ITIMigrDsTblFldOption.Next() = 0;
        //Check if all options from db are in dataset
        ITIAppObjectTblFieldOpt.SetRange("SQL Database Code", SrcITIAppObjectTableField."SQL Database Code");
        ITIAppObjectTblFieldOpt.SetRange("Table Name", SrcITIAppObjectTableField."Table Name");
        ITIAppObjectTblFieldOpt.SetRange("Field Name", SrcITIAppObjectTableField.Name);
        if ITIAppObjectTblFieldOpt.FindSet() then
            repeat
                ITIMigrDsTblFldOption.Reset();
                ITIMigrDsTblFldOption.SetRange("Migration Dataset Code", MigrationDatasetCode);
                ITIMigrDsTblFldOption.SetRange("Source table name", SrcITIAppObjectTableField."Table Name");
                ITIMigrDsTblFldOption.SetRange("Source Field Name", SrcITIAppObjectTableField.Name);
                ITIMigrDsTblFldOption.SetRange("Source Option Name", ITIAppObjectTblFieldOpt.Name);
                if ITIMigrDsTblFldOption.IsEmpty() then
                    AddNewError(MigrationDatasetCode, SrcITIAppObjectTableField."Table Name", SrcITIAppObjectTableField.Name, StrSubstNo(OptionNotFoundInSourceErr, ITIAppObjectTblFieldOpt.Name), 0, LineNo, ITIMigrDsTblFldOption."Source Option Name", SkipErr);
            until ITIAppObjectTblFieldOpt.Next() = 0;
    end;

    local procedure AddNewError(DatasetCode: Code[20]; SourceTableName: Text[150]; SourceFieldName: Text[150]; ErrorMsg: Text[250]; ErrorType: Integer; var LineNo: Integer; IgnoreErr: Boolean)
    var
        ITIMigrDatasetError: Record "ITI Migr. Dataset Error";
    begin
        ITIMigrDatasetError."Migration Dataset Code" := DatasetCode;
        ITIMigrDatasetError."Source Table Name" := SourceTableName;
        ITIMigrDatasetError."Source Field Name" := SourceFieldName;
        ITIMigrDatasetError."Error Message" := ErrorMsg;
        ITIMigrDatasetError."Error Type" := Enum::"ITI Dataset Error Types".FromInteger(ErrorType);
        ITIMigrDatasetError."Line No." := LineNo;
        ITIMigrDatasetError.Ignore := IgnoreErr;
        ITIMigrDatasetError.Insert();
        LineNo += 1;
    end;

    local procedure AddNewError(DatasetCode: Code[20]; SourceTableName: Text[150]; SourceFieldName: Text[150]; ErrorMsg: Text[250]; ErrorType: Integer; var LineNo: Integer; SrcObsoleteState: Text[150]; SrcObsoleteReason: Text[500]; DstObsoleteState: Text[150]; DstObsoleteReason: Text[500]; IgnoreErr: Boolean)
    var
        ITIMigrDatasetError: Record "ITI Migr. Dataset Error";
    begin
        ITIMigrDatasetError."Migration Dataset Code" := DatasetCode;
        ITIMigrDatasetError."Source Table Name" := SourceTableName;
        ITIMigrDatasetError."Source Field Name" := SourceFieldName;
        ITIMigrDatasetError."Error Message" := ErrorMsg;
        ITIMigrDatasetError."Error Type" := Enum::"ITI Dataset Error Types".FromInteger(ErrorType);
        ITIMigrDatasetError."Line No." := LineNo;
        ITIMigrDatasetError."Source Obsolete State" := SrcObsoleteState;
        ITIMigrDatasetError."Source Obsolete Reason" := SrcObsoleteReason;
        ITIMigrDatasetError."Target Obsolete State" := DstObsoleteState;
        ITIMigrDatasetError."Target Obsolete Reason" := DstObsoleteReason;
        ITIMigrDatasetError.Ignore := IgnoreErr;
        ITIMigrDatasetError.Insert();
        LineNo += 1;
    end;

    local procedure AddNewError(DatasetCode: Code[20]; SourceTableName: Text[150]; SourceFieldName: Text[150]; ErrorMsg: Text[250]; ErrorType: Integer; var LineNo: Integer; SourceOptionName: Text[250]; IgnoreErr: Boolean)
    var
        ITIMigrDatasetError: Record "ITI Migr. Dataset Error";
    begin
        ITIMigrDatasetError."Migration Dataset Code" := DatasetCode;
        ITIMigrDatasetError."Source Table Name" := SourceTableName;
        ITIMigrDatasetError."Source Field Name" := SourceFieldName;
        ITIMigrDatasetError."Error Message" := ErrorMsg;
        ITIMigrDatasetError."Error Type" := Enum::"ITI Dataset Error Types".FromInteger(ErrorType);
        ITIMigrDatasetError."Line No." := LineNo;
        ITIMigrDatasetError."Source Option Name" := SourceOptionName;
        ITIMigrDatasetError.Ignore := IgnoreErr;
        ITIMigrDatasetError.Insert();
        LineNo += 1;
    end;

    var
        AfterCheckMsg: Label '%1 errors have been found.', Comment = '%1 = Numer of errors in dataset.';
        DatasetMustBeOpenErr: Label 'You can not release dataset which is not open.';
        NoMigrationTablesErr: Label 'No tables were declared for given dataset.';
        WrongTableTypeErr: Label 'Table type of table %1 is equal to %2 instead of being equal to "Normal".', Comment = '%1 = No of table which is being checked; %2 = Value of field Table Type.';
        ObsoleteTableErr: Label 'Table %1 parameter obsolete state is equal to removed.', Comment = '%1 = Table name';
        ObsoleteStatesNotMatchingErr: Label 'Obsolete states are not matching.';
        KeyFieldNotFoundInSourceErr: Label 'Key field "%1" has been omitted in source dataset.', Comment = '%1 = field name.';
        KeyFieldHasNoTargetErr: Label 'Field %1 which is a part of the key of table %2 has no migration target.', Comment = '%1 = Field name; %2 = table name.';
        TargetKeyHasNoSourceFieldErr: Label 'Field %1 which is a part of the key of table %2 in target database has no source.', Comment = '%1 = Field name; %2 = table name.';
        NoTargetFieldErr: Label 'This field has no migration target.';
        NoSourceFieldErr: Label 'This field has no named source.';
        DataTypesNotMatchingErr: Label 'Datatypes of this field in selected datatbases are different.';
        BiggerKeyLengthOnSourceSideErr: Label 'Data length parameter of field %1 which is a part of the key is bigger in source database.', Comment = '%1 = Field name.';
        BiggerDataLengthOnSourcesSideErr: Label 'Data length parameter on the side of the source database is bigger than in destination. This may cause data clipping.';
        WrongFieldClassErr: Label 'Field class must not be equal to neither flowfield nor flowfilter.';
        ObsoleteStateNotMatchingErr: Label 'Obsolete state values are different.';
        SqlParamsDifferentErr: Label 'SQL parameters "SQL Field Name" and "SQL Table Name Excl. C. Name" must not be empty';
        OptionHasNoTargetErr: Label 'Option %1 of field %2 has no mapped target.', Comment = '%1 = option name; %2 = field name.';
        OptionNotFoundInSourceErr: Label 'Option %1, which is present in database, has not been found in this source dataset.', Comment = '%1 = option name';
}

