codeunit 99021 "PTE Migr. Check No. of Records"
{
    procedure CountMigratedRecords(PTEMigration: Record "PTE Migration")
    var
        PTEMigrNumberOfRecords: Record "PTE Migr. Number Of Records";
    begin
        PTEMigrNumberOfRecords.SetRange("Migration Code", PTEMigration.code);
        PTEMigrNumberOfRecords.DeleteAll();
        AddTablesToCount(PTEMigration);
        CountRecords(PTEMigration.Code);

    end;

    local procedure AddTablesToCount(Migration: Record "PTE Migration")
    var
        PTEMigrationDatasetTable: Record "PTE Migration Dataset Table";
        NextEntryNo: Integer;
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
        AnalysisRecordsMsg: Label 'Processing - Step 1 of 2\Data analysis.\No Of Records: %1', Comment = '%1 = No Of Records';
    begin
        PTEMigrationDatasetTable.SetRange("Migration Dataset Code", Migration."Migration Dataset Code");

        CurrentProgress := 0;
        ProgressTotal := PTEMigrationDatasetTable.Count();
        DialogProgress.OPEN(STRSUBSTNO(AnalysisRecordsMsg, ProgressTotal) + ': #1#####', CurrentProgress);
        NextEntryNo := 0;
        if PTEMigrationDatasetTable.FindSet() then
            repeat
                NextEntryNo := NextEntryNo + 1;
                InsertTableToCount(PTEMigrationDatasetTable, Migration, NextEntryNo);
                CurrentProgress := CurrentProgress + 1;
                DialogProgress.Update(1, CurrentProgress);
            until PTEMigrationDatasetTable.Next() = 0;
        DialogProgress.Close();
    end;

    local procedure InsertTableToCount(PTEMigrationDatasetTable: Record "PTE Migration Dataset Table"; PTEMigration: Record "PTE Migration"; EntryNo: Integer)
    var
        PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field";
        PTEMigrNumberOfRecords: Record "PTE Migr. Number Of Records";
    begin
        PTEMigrDatasetTableField.SetRange("Migration Dataset Code", PTEMigrationDatasetTable."Migration Dataset Code");
        PTEMigrDatasetTableField.SetRange("Source table name", PTEMigrationDatasetTable."Source Table Name");
        PTEMigrDatasetTableField.SetRange("Mapping Type", PTEMigrDatasetTableField."Mapping Type"::FieldToField);
        PTEMigrDatasetTableField.SetFilter("Source Field Name", '<>''''');
        PTEMigrDatasetTableField.SetFilter("Target Field name", '<>''''');
        PTEMigrDatasetTableField.SetRange("Skip in Mapping", false);
        if PTEMigrDatasetTableField.FindFirst() then begin
            PTEMigrNumberOfRecords.Init();
            PTEMigrNumberOfRecords."Migration Code" := PTEMigration.code;
            PTEMigrNumberOfRecords."Entry No" := EntryNo;
            PTEMigrNumberOfRecords."Source SQL Database Code" := PTEMigration."Source SQL Database Code";
            PTEMigrNumberOfRecords."Source Table Name" := PTEMigrDatasetTableField."Source table name";
            PTEMigrNumberOfRecords."Source SQL Table Name" := PTEMigrDatasetTableField.GetSQLSourceTableName(PTEMigration."Source Company Name");
            PTEMigrNumberOfRecords."Target SQL Database Code" := PTEMigration."Target SQL Database Code";
            PTEMigrNumberOfRecords."Target Table Name" := PTEMigrDatasetTableField."Target table name";
            PTEMigrNumberOfRecords."Target SQL Table Name" := PTEMigrDatasetTableField.GetSQLTargetTableName(PTEMigration."Target Company Name");
            PTEMigrNumberOfRecords.Insert();
        end;
    end;

    local procedure CountRecords(MigrationCode: Code[20])
    var
        PTEMigrNumberOfRecords: Record "PTE Migr. Number Of Records";
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
        CountingRecordsMsg: Label 'Processing - Step 2 of 2\Counting Records.\No Of Records: %1', Comment = '%1 = No Of Records';
    begin
        PTEMigrNumberOfRecords.SetRange("Migration Code", MigrationCode);
        CurrentProgress := 0;
        ProgressTotal := PTEMigrNumberOfRecords.Count();
        DialogProgress.OPEN(STRSUBSTNO(CountingRecordsMsg, ProgressTotal) + ': #1#####', CurrentProgress);
        if PTEMigrNumberOfRecords.Findset() then
            repeat
                PTEMigrNumberOfRecords."Number of source records" := CountRecordsInTable(PTEMigrNumberOfRecords."Source SQL Table Name", PTEMigrNumberOfRecords."Source SQL Database Code");
                PTEMigrNumberOfRecords."Number of target records" := CountRecordsInTable(PTEMigrNumberOfRecords."Target SQL Table Name", PTEMigrNumberOfRecords."Target SQL Database Code");
                PTEMigrNumberOfRecords.Difference := PTEMigrNumberOfRecords."Number of source records" - PTEMigrNumberOfRecords."Number of target records";
                PTEMigrNumberOfRecords.Modify();
                CurrentProgress := CurrentProgress + 1;
                DialogProgress.Update(1, CurrentProgress);
            until PTEMigrNumberOfRecords.Next() = 0;
        DialogProgress.Close();
    end;

    local procedure CountRecordsInTable(TableName: Text; DatabaseCode: Code[20]): Integer;
    var
        PTESQLDatabase: Record "PTE SQL Database";
        SQLQueryText: Text;
        ConnectionString: Text;
        SQLConnection: DotNet SqlConnection;
        SQLCommand: DotNet SqlCommand;
        SQLReader: DotNet SqlDataReader;
        NumberOfRecords: Integer;
    begin
        PTESQLDatabase.Get(DatabaseCode);
        SQLQueryText := 'SELECT COUNT(*) FROM [' + TableName + ']';
        ConnectionString := PTESQLDatabase.GetDatabaseConnectionString();

        //Get number of records
        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();

        SQLCommand := SQLCommand.SqlCommand(SQLQueryText, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();
        SQLReader.Read();
        EVALUATE(NumberOfRecords, Format(SQLReader.GetValue(0)));
        SQLConnection.Close();
        exit(NumberOfRecords);
    end;

}
