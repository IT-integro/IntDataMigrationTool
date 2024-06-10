codeunit 99008 "PTE Dataset Insert Tables"
{
    procedure InsertAllTables(PTEMigrationDataset: Record "PTE Migration Dataset")
    var
        ConfirmationMsg: label 'This operation will insert all tables to the dataset %1. Do you want to continue ?', Comment = '%1= Migration Dataset Code';
    begin
        if not Confirm(ConfirmationMsg, false, PTEMigrationDataset.Code) then
            exit;
        InsertTables(PTEMigrationDataset, '', false, false, false);
    end;

    procedure InsertTablesWithDataAllCompanies(PTEMigrationDataset: Record "PTE Migration Dataset")
    var
        ConfirmationMsg: label 'This operation will insert all tables contains data to the dataset %1. Do you want to continue ?', Comment = '%1= Migration Dataset Code';
    begin
        if not Confirm(ConfirmationMsg, false, PTEMigrationDataset.Code) then
            exit;
        InsertTables(PTEMigrationDataset, '', true, false, false);
    end;

    procedure InsertTablesWithDataSelectedCompany(PTEMigrationDataset: Record "PTE Migration Dataset"; CompanyName: Text[150])
    var
        PTESQLDatabaseCompany: Record "PTE SQL Database Company";
        ConfirmationMsg: label 'This operation will insert all tables contains Company: %1 data to the dataset %2. Do you want to continue ?', Comment = '%1= Company Name, %2= Migration Dataset Code';
    begin
        PTESQLDatabaseCompany.SetRange("SQL Database Code", PTEMigrationDataset."Source SQL Database Code");
        PTESQLDatabaseCompany.SetRange(Name, CompanyName);
        PTESQLDatabaseCompany.FindFirst();
        if not Confirm(ConfirmationMsg, false, PTESQLDatabaseCompany.Name, PTEMigrationDataset.Code) then
            exit;
        InsertTables(PTEMigrationDataset, PTESQLDatabaseCompany.Name, true, true, false);

    end;

    procedure InsertCommonCompanyTablesWithData(PTEMigrationDataset: Record "PTE Migration Dataset")
    var
        ConfirmationMsg: label 'This operation will insert all common tables contains data to the dataset %1. Do you want to continue ?', Comment = '%1= Company Name, %2= Migration Dataset Code';
    begin
        if not Confirm(ConfirmationMsg, false, PTEMigrationDataset.Code) then
            exit;
        InsertTables(PTEMigrationDataset, '', true, false, true);
    end;

    local procedure InsertTables(PTEMigrationDataset: Record "PTE Migration Dataset"; CompanyName: Text[150]; WithDataOnly: Boolean; ExcludeCommonTables: Boolean; CommonTablesOnly: Boolean)
    var
        PTEMigrationDatasetTable: Record "PTE Migration Dataset Table";
        SourcePTEAppObjectTable: Record "PTE App. Object Table";
        SourcePTEAppObjectTableField: Record "PTE App. Object Table Field";
        TargetPTEAppObjectTable: Record "PTE App. Object Table";
        PTESQLDatabaseTable: Record "PTE SQL Database Table";
        SkipTable: Boolean;
        SQLTableName: Text;
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;

        ProgressMsg: Label 'Processing... No of records: %1', Comment = '%1 = No Of Records';
    begin
        SourcePTEAppObjectTable.SetRange("SQL Database Code", PTEMigrationDataset."Source SQL Database Code");
        SourcePTEAppObjectTable.SetFilter(TableType, '@Normal|''''');
        if ExcludeCommonTables then
            SourcePTEAppObjectTable.Setrange(DataPerCompany, true);
        if CommonTablesOnly then
            SourcePTEAppObjectTable.Setrange(DataPerCompany, false);
        if WithDataOnly then
            SourcePTEAppObjectTable.SetFilter("Number Of Records", '>0');
        ProgressTotal := SourcePTEAppObjectTable.Count();
        DialogProgress.OPEN(STRSUBSTNO(ProgressMsg, ProgressTotal) + '/ #1#####', CurrentProgress);
        if SourcePTEAppObjectTable.FindSet() then
            repeat
                SkipTable := false;
                if WithDataOnly and (CompanyName <> '') then begin
                    SourcePTEAppObjectTableField.SetRange("SQL Database Code", SourcePTEAppObjectTable."SQL Database Code");
                    SourcePTEAppObjectTableField.SetRange("Table Name", SourcePTEAppObjectTable.TableName);
                    SourcePTEAppObjectTableField.SetRange("Key", true);
                    if SourcePTEAppObjectTableField.FindFirst() then
                        SQLTableName := SourcePTEAppObjectTableField.GetSQLTableName(CompanyName);
                    PTESQLDatabaseTable.SetRange("SQL Database Code", SourcePTEAppObjectTable."SQL Database Code");
                    PTESQLDatabaseTable.SetRange("Table Name", SQLTableName);
                    if PTESQLDatabaseTable.FindFirst() then
                        if PTESQLDatabaseTable."Number Of Records" = 0 then
                            SkipTable := true;
                end;
                if not SkipTable then begin
                    PTEMigrationDatasetTable.SetRange("Migration Dataset Code", PTEMigrationDataset.Code);
                    PTEMigrationDatasetTable.SetRange("Source Table Name", SourcePTEAppObjectTable.Name);
                    if PTEMigrationDatasetTable.IsEmpty then begin
                        PTEMigrationDatasetTable.Init();
                        PTEMigrationDatasetTable."Migration Dataset Code" := PTEMigrationDataset.Code;
                        PTEMigrationDatasetTable."Source SQL Database Code" := PTEMigrationDataset."Source SQL Database Code";
                        PTEMigrationDatasetTable.Validate("Source Table Name", SourcePTEAppObjectTable."Name");
                        PTEMigrationDatasetTable.Insert();
                        TargetPTEAppObjectTable.SetRange("SQL Database Code", PTEMigrationDataset."Target SQL Database Code");
                        TargetPTEAppObjectTable.SetFilter(TableType, '@Normal|''''');
                        TargetPTEAppObjectTable.SetFilter(Name, '''%1''', SourcePTEAppObjectTable."Name");
                        if TargetPTEAppObjectTable.FindFirst() then begin
                            PTEMigrationDatasetTable."Target SQL Database Code" := PTEMigrationDataset."Target SQL Database Code";
                            PTEMigrationDatasetTable.Validate("Target table name", TargetPTEAppObjectTable."Name");
                            PTEMigrationDatasetTable.Modify();
                        end;
                    end;
                end;
                CurrentProgress := CurrentProgress + 1;
                DialogProgress.UPDATE(1, CurrentProgress);
            until SourcePTEAppObjectTable.Next() = 0;
    end;
}
