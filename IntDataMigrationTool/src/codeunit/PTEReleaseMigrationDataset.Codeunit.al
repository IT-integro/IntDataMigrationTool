codeunit 99002 "PTE Release Migration Dataset"
{
    Procedure Release(PTEMigrationDataset: Record "PTE Migration Dataset")
    begin
        if PTEMigrationDataset.Released then
            Error(DatasetMustBeOpenErr);
        CheckMigrationDataset(PTEMigrationDataset);

        PTEMigrationDataset.CalcFields("Number of Errors");

        if PTEMigrationDataset."Number of Errors" = 0 then begin
            PTEMigrationDataset.Released := true;
            PTEMigrationDataset.Modify();
        end else
            Message(AfterCheckMsg, PTEMigrationDataset."Number of Errors");
    end;

    Procedure Reopen(PTEMigrationDataset: Record "PTE Migration Dataset")
    begin
        PTEMigrationDataset.Released := False;
        PTEMigrationDataset.Modify();
    end;

    local Procedure CheckMigrationDataset(PTEMigrationDataset: Record "PTE Migration Dataset")
    var
        PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field";
        PTEMigrationDatasetTable: Record "PTE Migration Dataset Table";
        PTEMigrDatasetError: Record "PTE Migr. Dataset Error";
        LineNo: Integer;
        DialogIterator: Integer;
        TableCount: Integer;
        DialogProgress: Dialog;
        ProgressMsg: Label 'Checking tables: From 0 to %1  ', Comment = '#1 = Overall count of tables';

    begin
        LineNo := 1;
        DialogIterator := 1;
        PTEMigrDatasetError.SetRange("Migration Dataset Code", PTEMigrationDataset.Code);
        PTEMigrDatasetError.DeleteAll();

        PTEMigrDatasetError.SetRange("Migration Dataset Code", '');
        PTEMigrDatasetError.DeleteAll();

        PTEMigrationDatasetTable.SetRange("Migration Dataset Code", PTEMigrationDataset.Code);
        PTEMigrationDatasetTable.SetRange("Skip in Mapping", false);
        TableCount := PTEMigrationDatasetTable.Count();

        if PTEMigrationDatasetTable.FindSet() then begin
            DialogProgress.Open(StrSubstNo(ProgressMsg, TableCount) + '#1###', DialogIterator);
            repeat
                DialogProgress.Update();
                CheckTableType(PTEMigrationDatasetTable, LineNo);
                CheckKeys(PTEMigrationDatasetTable, LineNo);

                PTEMigrDatasetTableField.SetRange("Migration Dataset Code", PTEMigrationDataset.Code);
                PTEMigrDatasetTableField.SetRange("Source table name", PTEMigrationDatasetTable."Source Table Name");
                PTEMigrDatasetTableField.SetRange("Skip in Mapping", false);
                if PTEMigrDatasetTableField.FindSet() then
                    repeat
                        CheckIfTargetFieldIsFilled(PTEMigrDatasetTableField, LineNo);
                        CheckIfSourceFieldIsFilled(PTEMigrDatasetTableField, LineNo);
                        if PTEMigrDatasetTableField."Mapping Type" = PTEMigrDatasetTableField."Mapping Type"::FieldToField then
                            CheckFieldData(PTEMigrDatasetTableField, PTEMigrationDatasetTable, LineNo);
                    until PTEMigrDatasetTableField.Next() = 0;
                DialogIterator += 1;
            until PTEMigrationDatasetTable.Next() = 0;
        end
        else
            Error(NoMigrationTablesErr);
    end;

    local procedure CheckTableType(PTEMigrationDatasetTable: Record "PTE Migration Dataset Table"; var LineNo: Integer)
    var
        SrcPTEAppObjectTable: Record "PTE App. Object Table";
        DstPTEAppObjectTable: Record "PTE App. Object Table";
    begin
        SrcPTEAppObjectTable.SetCurrentKey("SQL Database Code", Name);
        DstPTEAppObjectTable.SetCurrentKey("SQL Database Code", Name);

        SrcPTEAppObjectTable.SetRange("SQL Database Code", PTEMigrationDatasetTable."Source SQL Database Code");
        SrcPTEAppObjectTable.SetRange(Name, PTEMigrationDatasetTable."Source Table Name");
        DstPTEAppObjectTable.SetRange("SQL Database Code", PTEMigrationDatasetTable."Target SQL Database Code");
        DstPTEAppObjectTable.SetRange(Name, PTEMigrationDatasetTable."Target table name");
        if SrcPTEAppObjectTable.FindFirst() then begin                                                           //Check table type and obsolete state
            if SrcPTEAppObjectTable.TableType.ToLower() <> 'normal' then
                AddNewError(PTEMigrationDatasetTable."Migration Dataset Code", SrcPTEAppObjectTable.Name, '', StrSubstNo(WrongTableTypeErr, SrcPTEAppObjectTable.Name, SrcPTEAppObjectTable.TableType), 0, LineNo, false);
            if SrcPTEAppObjectTable.ObsoleteState.ToLower() = 'removed' then
                AddNewError(PTEMigrationDatasetTable."Migration Dataset Code", SrcPTEAppObjectTable.Name, '', StrSubstNo(ObsoleteTableErr, SrcPTEAppObjectTable.Name), 0, LineNo, SrcPTEAppObjectTable.ObsoleteState, SrcPTEAppObjectTable.ObsoleteReason, '', '', false);
        end;
        if DstPTEAppObjectTable.FindFirst() then begin
            if DstPTEAppObjectTable.TableType.ToLower() <> 'normal' then
                AddNewError(PTEMigrationDatasetTable."Migration Dataset Code", DstPTEAppObjectTable.Name, '', StrSubstNo(WrongTableTypeErr, DstPTEAppObjectTable.Name, DstPTEAppObjectTable.TableType), 0, LineNo, false);
            if DstPTEAppObjectTable.ObsoleteState.ToLower() = 'removed' then
                AddNewError(PTEMigrationDatasetTable."Migration Dataset Code", DstPTEAppObjectTable.Name, '', StrSubstNo(ObsoleteTableErr, DstPTEAppObjectTable.Name), 0, LineNo, '', '', DstPTEAppObjectTable.ObsoleteState, DstPTEAppObjectTable.ObsoleteReason, false);
        end;
        //Add warning if obsolete state has been changed between versions but table is not removed
        if (SrcPTEAppObjectTable.ObsoleteState.ToLower() <> DstPTEAppObjectTable.ObsoleteState.ToLower()) and (SrcPTEAppObjectTable.ObsoleteState.ToLower() <> 'removed') and (DstPTEAppObjectTable.ObsoleteState.ToLower() <> 'removed') then
            AddNewError(PTEMigrationDatasetTable."Migration Dataset Code", DstPTEAppObjectTable.Name, '', ObsoleteStatesNotMatchingErr, 1, LineNo, false);
    end;

    local procedure CheckKeys(PTEMigrationDatasetTable: Record "PTE Migration Dataset Table"; var LineNo: Integer)
    var
        SrcPTEAppObjectTableField: Record "PTE App. Object Table Field";
        DstPTEAppObjectTableField: Record "PTE App. Object Table Field";
        PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field";
    begin
        SrcPTEAppObjectTableField.SetRange("SQL Database Code", PTEMigrationDatasetTable."Source SQL Database Code");
        SrcPTEAppObjectTableField.SetRange("Table Name", PTEMigrationDatasetTable."Source Table Name");
        SrcPTEAppObjectTableField.SetRange("Key", true);

        DstPTEAppObjectTableField.SetRange("SQL Database Code", PTEMigrationDatasetTable."Target SQL Database Code");
        DstPTEAppObjectTableField.SetRange("Table Name", PTEMigrationDatasetTable."Target Table Name");
        DstPTEAppObjectTableField.SetRange("Key", true);
        //Check if all source keys will be transfered
        if SrcPTEAppObjectTableField.FindSet() then
            repeat
                if not PTEMigrDatasetTableField.Get(PTEMigrationDatasetTable."Migration Dataset Code", PTEMigrationDatasetTable."Source table name", SrcPTEAppObjectTableField.Name) then
                    AddNewError(PTEMigrationDatasetTable."Migration Dataset Code", PTEMigrationDatasetTable."Source table name", SrcPTEAppObjectTableField."Name", StrSubstNo(KeyFieldNotFoundInSourceErr, SrcPTEAppObjectTableField.Name), 0, LineNo, PTEMigrDatasetTableField."Ignore Errors")
                else
                    if PTEMigrDatasetTableField."Target Field name" = '' then
                        AddNewError(PTEMigrDatasetTableField."Migration Dataset Code", PTEMigrationDatasetTable."Source table name", PTEMigrDatasetTableField."Source Field Name", StrSubstNo(KeyFieldHasNoTargetErr, PTEMigrDatasetTableField."Source Field Name", PTEMigrationDatasetTable."Source table name"), 0, LineNo, PTEMigrDatasetTableField."Ignore Errors");
            until SrcPTEAppObjectTableField.Next() = 0;
        //Check if all target keys have source values
        if DstPTEAppObjectTableField.FindSet() then
            repeat
                PTEMigrDatasetTableField.Reset();
                PTEMigrDatasetTableField.SetRange("Migration Dataset Code", PTEMigrationDatasetTable."Migration Dataset Code");
                PTEMigrDatasetTableField.SetRange("Target table name", DstPTEAppObjectTableField."Table Name");
                PTEMigrDatasetTableField.SetRange("Target Field name", DstPTEAppObjectTableField.Name);
                if PTEMigrDatasetTableField.IsEmpty() then
                    AddNewError(PTEMigrationDatasetTable."Migration Dataset Code", PTEMigrationDatasetTable."Target table name", DstPTEAppObjectTableField.Name, StrSubstNo(TargetKeyHasNoSourceFieldErr, DstPTEAppObjectTableField.Name, PTEMigrationDatasetTable."Target table name"), 0, LineNo, PTEMigrDatasetTableField."Ignore Errors");
            until DstPTEAppObjectTableField.Next() = 0;
    end;

    local procedure CheckIfTargetFieldIsFilled(PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field"; var LineNo: Integer)
    begin
        if PTEMigrDatasetTableField."Target Field name" = '' then
            AddNewError(PTEMigrDatasetTableField."Migration Dataset Code", PTEMigrDatasetTableField."Source table name", PTEMigrDatasetTableField."Source Field Name", NoTargetFieldErr, 1, LineNo, PTEMigrDatasetTableField."Ignore Errors");
    end;

    local procedure CheckIfSourceFieldIsFilled(PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field"; var LineNo: Integer)
    begin
        if PTEMigrDatasetTableField."Source Field Name" = '' then
            AddNewError(PTEMigrDatasetTableField."Migration Dataset Code", PTEMigrDatasetTableField."Source table name", PTEMigrDatasetTableField."Source Field Name", NoSourceFieldErr, 0, LineNo, PTEMigrDatasetTableField."Ignore Errors");
    end;

    local procedure CheckFieldData(PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field"; PTEMigrationDatasetTable: Record "PTE Migration Dataset Table"; LineNo: Integer)
    var
        SrcPTEAppObjectTableField: Record "PTE App. Object Table Field";
        DstPTEAppObjectTableField: Record "PTE App. Object Table Field";
    begin
        if (PTEMigrDatasetTableField."Source Field Name" = '') or (PTEMigrDatasetTableField."Target Field Name" = '') then
            exit;
        PTEMigrDatasetTableField.CalcFields("Source SQL Database Code", "Target SQL Database Code");

        SrcPTEAppObjectTableField.SetRange("SQL Database Code", PTEMigrDatasetTableField."Source SQL Database Code");
        SrcPTEAppObjectTableField.SetRange("Table Name", PTEMigrationDatasetTable."Source Table Name");
        SrcPTEAppObjectTableField.SetRange(Name, PTEMigrDatasetTableField."Source Field Name");

        DstPTEAppObjectTableField.SetRange("SQL Database Code", PTEMigrDatasetTableField."Target SQL Database Code");
        DstPTEAppObjectTableField.SetRange("Table Name", PTEMigrationDatasetTable."Target table name");
        DstPTEAppObjectTableField.SetRange(Name, PTEMigrDatasetTableField."Target Field Name");

        SrcPTEAppObjectTableField.FindFirst();
        DstPTEAppObjectTableField.FindFirst();
        //Check data type
        if SrcPTEAppObjectTableField.Datatype <> DstPTEAppObjectTableField.Datatype then
            AddNewError(PTEMigrationDatasetTable."Migration Dataset Code", PTEMigrationDatasetTable."Source Table Name", PTEMigrDatasetTableField."Source Field Name", DataTypesNotMatchingErr, 0, LineNo, PTEMigrDatasetTableField."Ignore Errors");
        //Check data length
        if (SrcPTEAppObjectTableField.DataLength > DstPTEAppObjectTableField.DataLength) and (SrcPTEAppObjectTableField."Key" = true) then
            AddNewError(PTEMigrationDatasetTable."Migration Dataset Code", PTEMigrationDatasetTable."Source Table Name", PTEMigrDatasetTableField."Source Field Name", StrSubstNo(BiggerKeyLengthOnSourceSideErr, PTEMigrDatasetTableField."Source Field Name"), 0, LineNo, PTEMigrDatasetTableField."Ignore Errors")
        else
            if SrcPTEAppObjectTableField.DataLength > DstPTEAppObjectTableField.DataLength then
                AddNewError(PTEMigrationDatasetTable."Migration Dataset Code", PTEMigrationDatasetTable."Source Table Name", PTEMigrDatasetTableField."Source Field Name", BiggerDataLengthOnSourcesSideErr, 1, LineNo, PTEMigrDatasetTableField."Ignore Errors");
        //Check field class
        if SrcPTEAppObjectTableField.FieldClass.ToLower() in ['flowfield', 'flowfilter'] then
            AddNewError(PTEMigrationDatasetTable."Migration Dataset Code", PTEMigrationDatasetTable."Source Table Name", PTEMigrDatasetTableField."Source Field Name", WrongFieldClassErr, 0, LineNo, PTEMigrDatasetTableField."Ignore Errors");
        //Check Obsolete State and Reason
        if SrcPTEAppObjectTableField.ObsoleteState <> DstPTEAppObjectTableField.ObsoleteState then
            if (SrcPTEAppObjectTableField.ObsoleteState.ToLower() = 'removed') or (DstPTEAppObjectTableField.ObsoleteState.ToLower() = 'removed') then
                AddNewError(PTEMigrationDatasetTable."Migration Dataset Code", PTEMigrationDatasetTable."Source Table Name", PTEMigrDatasetTableField."Source Field Name", ObsoleteStateNotMatchingErr, 0, LineNo, SrcPTEAppObjectTableField.ObsoleteState, SrcPTEAppObjectTableField.ObsoleteReason, DstPTEAppObjectTableField.ObsoleteState, DstPTEAppObjectTableField.ObsoleteReason, PTEMigrDatasetTableField."Ignore Errors")
            else
                AddNewError(PTEMigrationDatasetTable."Migration Dataset Code", PTEMigrationDatasetTable."Source Table Name", PTEMigrDatasetTableField."Source Field Name", ObsoleteStateNotMatchingErr, 1, LineNo, SrcPTEAppObjectTableField.ObsoleteState, SrcPTEAppObjectTableField.ObsoleteReason, DstPTEAppObjectTableField.ObsoleteState, DstPTEAppObjectTableField.ObsoleteReason, PTEMigrDatasetTableField."Ignore Errors");
        //Check SQL params
        if (SrcPTEAppObjectTableField."SQL Field Name" = '') or (SrcPTEAppObjectTableField."SQL Table Name Excl. C. Name" = '') or (DstPTEAppObjectTableField."SQL Field Name" = '') or (DstPTEAppObjectTableField."SQL Table Name Excl. C. Name" = '') then
            AddNewError(PTEMigrationDatasetTable."Migration Dataset Code", PTEMigrationDatasetTable."Source Table Name", PTEMigrDatasetTableField."Source Field Name", SqlParamsDifferentErr, 0, LineNo, PTEMigrDatasetTableField."Ignore Errors");
        CheckFieldOptions(SrcPTEAppObjectTableField, LineNo, PTEMigrationDatasetTable."Migration Dataset Code", PTEMigrDatasetTableField."Ignore Errors");
    end;

    local procedure CheckFieldOptions(SrcPTEAppObjectTableField: Record "PTE App. Object Table Field"; var LineNo: Integer; MigrationDatasetCode: Code[20]; SkipErr: Boolean)
    var
        PTEMigrDsTblFldOption: Record "PTE Migr. Ds. Tbl. Fld. Option";
        PTEAppObjectTblFieldOpt: Record "PTE App. Object Tbl.Field Opt.";
    begin
        //Check if all options from source have targets
        PTEMigrDsTblFldOption.SetRange("Migration Dataset Code", MigrationDatasetCode);
        PTEMigrDsTblFldOption.SetRange("Source table name", SrcPTEAppObjectTableField."Table Name");
        PTEMigrDsTblFldOption.SetRange("Source Field Name", SrcPTEAppObjectTableField.Name);
        if PTEMigrDsTblFldOption.FindSet() then
            repeat
                if (PTEMigrDsTblFldOption."Target Option Name" = '') and (PTEMigrDsTblFldOption."Target Option Name" <> PTEMigrDsTblFldOption."Source Option Name") then
                    AddNewError(MigrationDatasetCode, SrcPTEAppObjectTableField."Table Name", SrcPTEAppObjectTableField.Name, StrSubstNo(OptionHasNoTargetErr, PTEMigrDsTblFldOption."Source Option Name", SrcPTEAppObjectTableField.Name), 0, LineNo, PTEMigrDsTblFldOption."Source Option Name", SkipErr);
            until PTEMigrDsTblFldOption.Next() = 0;
        //Check if all options from db are in dataset
        PTEAppObjectTblFieldOpt.SetRange("SQL Database Code", SrcPTEAppObjectTableField."SQL Database Code");
        PTEAppObjectTblFieldOpt.SetRange("Table Name", SrcPTEAppObjectTableField."Table Name");
        PTEAppObjectTblFieldOpt.SetRange("Field Name", SrcPTEAppObjectTableField.Name);
        if PTEAppObjectTblFieldOpt.FindSet() then
            repeat
                PTEMigrDsTblFldOption.Reset();
                PTEMigrDsTblFldOption.SetRange("Migration Dataset Code", MigrationDatasetCode);
                PTEMigrDsTblFldOption.SetRange("Source table name", SrcPTEAppObjectTableField."Table Name");
                PTEMigrDsTblFldOption.SetRange("Source Field Name", SrcPTEAppObjectTableField.Name);
                PTEMigrDsTblFldOption.SetRange("Source Option Name", PTEAppObjectTblFieldOpt.Name);
                if PTEMigrDsTblFldOption.IsEmpty() then
                    AddNewError(MigrationDatasetCode, SrcPTEAppObjectTableField."Table Name", SrcPTEAppObjectTableField.Name, StrSubstNo(OptionNotFoundInSourceErr, PTEAppObjectTblFieldOpt.Name), 0, LineNo, PTEMigrDsTblFldOption."Source Option Name", SkipErr);
            until PTEAppObjectTblFieldOpt.Next() = 0;
    end;

    local procedure AddNewError(DatasetCode: Code[20]; SourceTableName: Text[150]; SourceFieldName: Text[150]; ErrorMsg: Text[250]; ErrorType: Integer; var LineNo: Integer; IgnoreErr: Boolean)
    var
        PTEMigrDatasetError: Record "PTE Migr. Dataset Error";
    begin
        PTEMigrDatasetError."Migration Dataset Code" := DatasetCode;
        PTEMigrDatasetError."Source Table Name" := SourceTableName;
        PTEMigrDatasetError."Source Field Name" := SourceFieldName;
        PTEMigrDatasetError."Error Message" := ErrorMsg;
        PTEMigrDatasetError."Error Type" := Enum::"PTE Dataset Error Types".FromInteger(ErrorType);
        PTEMigrDatasetError."Line No." := LineNo;
        PTEMigrDatasetError.Ignore := IgnoreErr;
        PTEMigrDatasetError.Insert();
        LineNo += 1;
    end;

    local procedure AddNewError(DatasetCode: Code[20]; SourceTableName: Text[150]; SourceFieldName: Text[150]; ErrorMsg: Text[250]; ErrorType: Integer; var LineNo: Integer; SrcObsoleteState: Text[150]; SrcObsoleteReason: Text[500]; DstObsoleteState: Text[150]; DstObsoleteReason: Text[500]; IgnoreErr: Boolean)
    var
        PTEMigrDatasetError: Record "PTE Migr. Dataset Error";
    begin
        PTEMigrDatasetError."Migration Dataset Code" := DatasetCode;
        PTEMigrDatasetError."Source Table Name" := SourceTableName;
        PTEMigrDatasetError."Source Field Name" := SourceFieldName;
        PTEMigrDatasetError."Error Message" := ErrorMsg;
        PTEMigrDatasetError."Error Type" := Enum::"PTE Dataset Error Types".FromInteger(ErrorType);
        PTEMigrDatasetError."Line No." := LineNo;
        PTEMigrDatasetError."Source Obsolete State" := SrcObsoleteState;
        PTEMigrDatasetError."Source Obsolete Reason" := SrcObsoleteReason;
        PTEMigrDatasetError."Target Obsolete State" := DstObsoleteState;
        PTEMigrDatasetError."Target Obsolete Reason" := DstObsoleteReason;
        PTEMigrDatasetError.Ignore := IgnoreErr;
        PTEMigrDatasetError.Insert();
        LineNo += 1;
    end;

    local procedure AddNewError(DatasetCode: Code[20]; SourceTableName: Text[150]; SourceFieldName: Text[150]; ErrorMsg: Text[250]; ErrorType: Integer; var LineNo: Integer; SourceOptionName: Text[250]; IgnoreErr: Boolean)
    var
        PTEMigrDatasetError: Record "PTE Migr. Dataset Error";
    begin
        PTEMigrDatasetError."Migration Dataset Code" := DatasetCode;
        PTEMigrDatasetError."Source Table Name" := SourceTableName;
        PTEMigrDatasetError."Source Field Name" := SourceFieldName;
        PTEMigrDatasetError."Error Message" := ErrorMsg;
        PTEMigrDatasetError."Error Type" := Enum::"PTE Dataset Error Types".FromInteger(ErrorType);
        PTEMigrDatasetError."Line No." := LineNo;
        PTEMigrDatasetError."Source Option Name" := SourceOptionName;
        PTEMigrDatasetError.Ignore := IgnoreErr;
        PTEMigrDatasetError.Insert();
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

