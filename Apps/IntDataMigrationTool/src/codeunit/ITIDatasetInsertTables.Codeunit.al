codeunit 99008 "ITI Dataset Insert Tables"
{
    procedure InsertAllTables(ITIMigrationDataset: Record "ITI Migration Dataset")
    var
        ConfirmationMsg: label 'This operation will insert all tables to the dataset %1. Do you want to continue ?', Comment = '%1= Migration Dataset Code';
    begin
        if not Confirm(ConfirmationMsg, false, ITIMigrationDataset.Code) then
            exit;
        InsertTables(ITIMigrationDataset, '', false, false, false);
    end;

    procedure InsertTablesWithDataAllCompanies(ITIMigrationDataset: Record "ITI Migration Dataset")
    var
        ConfirmationMsg: label 'This operation will insert all tables contains data to the dataset %1. Do you want to continue ?', Comment = '%1= Migration Dataset Code';
    begin
        if not Confirm(ConfirmationMsg, false, ITIMigrationDataset.Code) then
            exit;
        InsertTables(ITIMigrationDataset, '', true, false, false);
    end;

    procedure InsertTablesWithDataSelectedCompany(ITIMigrationDataset: Record "ITI Migration Dataset"; CompanyName: Text[150])
    var
        ITISQLDatabaseCompany: Record "ITI SQL Database Company";
        ConfirmationMsg: label 'This operation will insert all tables contains Company: %1 data to the dataset %2. Do you want to continue ?', Comment = '%1= Company Name, %2= Migration Dataset Code';
    begin
        ITISQLDatabaseCompany.SetRange("SQL Database Code", ITIMigrationDataset."Source SQL Database Code");
        ITISQLDatabaseCompany.SetRange(Name, CompanyName);
        ITISQLDatabaseCompany.FindFirst();
        if not Confirm(ConfirmationMsg, false, ITISQLDatabaseCompany.Name, ITIMigrationDataset.Code) then
            exit;
        InsertTables(ITIMigrationDataset, ITISQLDatabaseCompany.Name, true, true, false);

    end;

    procedure InsertCommonCompanyTablesWithData(ITIMigrationDataset: Record "ITI Migration Dataset")
    var
        ConfirmationMsg: label 'This operation will insert all common tables contains data to the dataset %1. Do you want to continue ?', Comment = '%1= Company Name, %2= Migration Dataset Code';
    begin
        if not Confirm(ConfirmationMsg, false, ITIMigrationDataset.Code) then
            exit;
        InsertTables(ITIMigrationDataset, '', true, false, true);
    end;

    local procedure InsertTables(ITIMigrationDataset: Record "ITI Migration Dataset"; CompanyName: Text[150]; WithDataOnly: Boolean; ExcludeCommonTables: Boolean; CommonTablesOnly: Boolean)
    var
        ITIMigrationDatasetTable: Record "ITI Migration Dataset Table";
        SourceITIAppObjectTable: Record "ITI App. Object Table";
        SourceITIAppObjectTableField: Record "ITI App. Object Table Field";
        TargetITIAppObjectTable: Record "ITI App. Object Table";
        ITISQLDatabaseTable: Record "ITI SQL Database Table";
        SkipTable: Boolean;
        SQLTableName: Text;
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;

        ProgressMsg: Label 'Processing... No of records: %1', Comment = '%1 = No Of Records';
    begin
        SourceITIAppObjectTable.SetRange("SQL Database Code", ITIMigrationDataset."Source SQL Database Code");
        SourceITIAppObjectTable.SetFilter(TableType, '@Normal|''''');
        if ExcludeCommonTables then
            SourceITIAppObjectTable.Setrange(DataPerCompany, true);
        if CommonTablesOnly then
            SourceITIAppObjectTable.Setrange(DataPerCompany, false);
        if WithDataOnly then
            SourceITIAppObjectTable.SetFilter("Number Of Records", '>0');
        ProgressTotal := SourceITIAppObjectTable.Count();
        DialogProgress.OPEN(STRSUBSTNO(ProgressMsg, ProgressTotal) + '/ #1#####', CurrentProgress);
        if SourceITIAppObjectTable.FindSet() then
            repeat
                SkipTable := false;
                if WithDataOnly and (CompanyName <> '') then begin
                    SourceITIAppObjectTableField.SetRange("SQL Database Code", SourceITIAppObjectTable."SQL Database Code");
                    SourceITIAppObjectTableField.SetRange("Table Name", SourceITIAppObjectTable.TableName);
                    SourceITIAppObjectTableField.SetRange("Key", true);
                    if SourceITIAppObjectTableField.FindFirst() then
                        SQLTableName := SourceITIAppObjectTableField.GetSQLTableName(CompanyName);
                    ITISQLDatabaseTable.SetRange("SQL Database Code", SourceITIAppObjectTable."SQL Database Code");
                    ITISQLDatabaseTable.SetRange("Table Name", SQLTableName);
                    if ITISQLDatabaseTable.FindFirst() then
                        if ITISQLDatabaseTable."Number Of Records" = 0 then
                            SkipTable := true;
                end;
                if not SkipTable then begin
                    ITIMigrationDatasetTable.SetRange("Migration Dataset Code", ITIMigrationDataset.Code);
                    ITIMigrationDatasetTable.SetRange("Source Table Name", SourceITIAppObjectTable.Name);
                    if ITIMigrationDatasetTable.IsEmpty then begin
                        ITIMigrationDatasetTable.Init();
                        ITIMigrationDatasetTable."Migration Dataset Code" := ITIMigrationDataset.Code;
                        ITIMigrationDatasetTable."Source SQL Database Code" := ITIMigrationDataset."Source SQL Database Code";
                        ITIMigrationDatasetTable.Validate("Source Table Name", SourceITIAppObjectTable."Name");
                        ITIMigrationDatasetTable.Insert();
                        TargetITIAppObjectTable.SetRange("SQL Database Code", ITIMigrationDataset."Target SQL Database Code");
                        TargetITIAppObjectTable.SetFilter(TableType, '@Normal|''''');
                        TargetITIAppObjectTable.SetFilter(Name, '''%1''', SourceITIAppObjectTable."Name");
                        if TargetITIAppObjectTable.FindFirst() then begin
                            ITIMigrationDatasetTable."Target SQL Database Code" := ITIMigrationDataset."Target SQL Database Code";
                            ITIMigrationDatasetTable.Validate("Target table name", TargetITIAppObjectTable."Name");
                            ITIMigrationDatasetTable.Modify();
                        end;
                    end;
                end;
                CurrentProgress := CurrentProgress + 1;
                DialogProgress.UPDATE(1, CurrentProgress);
            until SourceITIAppObjectTable.Next() = 0;
    end;
}
