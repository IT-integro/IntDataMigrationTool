codeunit 99021 "PTE Migr. Check No. of Records"
{
    procedure CountMigratedRecords(PTEMigration: Record "PTE Migration")
    var
        PTEMigrNumberOfRecords: Record "PTE Migr. Number Of Records";
        PTEMigrFieldSum: Record "PTE Migr. Field Sum";
    begin
        PTEMigrNumberOfRecords.SetRange("Migration Code", PTEMigration.code);
        PTEMigrNumberOfRecords.DeleteAll();
        PTEMigrFieldSum.SetRange("Migration Code", PTEMigration.code);
        PTEMigrFieldSum.DeleteAll();
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
        PTEMigrFieldSum: Record "PTE Migr. Field Sum";
        SumEntryNo: Integer;
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
            if PTEMigration."Check Sums In Record Counting" then begin
                PTEMigrDatasetTableField.SetRange("Migration Dataset Code", PTEMigrationDatasetTable."Migration Dataset Code");
                PTEMigrDatasetTableField.SetRange("Source table name", PTEMigrationDatasetTable."Source Table Name");
                PTEMigrDatasetTableField.SetRange("Mapping Type", PTEMigrDatasetTableField."Mapping Type"::FieldToField);
                PTEMigrDatasetTableField.SetFilter("Source Field Name", '<>''''');
                PTEMigrDatasetTableField.SetFilter("Target Field name", '<>''''');
                PTEMigrDatasetTableField.SetRange("Source Field Data Type", 'Decimal');
                PTEMigrDatasetTableField.SetRange("Skip in Mapping", false);
                SumEntryNo := 1;
                if PTEMigrDatasetTableField.FindSet() then
                    repeat
                        PTEMigrFieldSum.Init();
                        PTEMigrFieldSum."Migration Code" := PTEMigration.code;
                        PTEMigrFieldSum."No Of Rec. Entry No" := EntryNo;
                        PTEMigrFieldSum."Entry No" := SumEntryNo;
                        PTEMigrFieldSum."Source SQL Database Code" := PTEMigration."Source SQL Database Code";
                        PTEMigrFieldSum."Source Table Name" := PTEMigrDatasetTableField."Source table name";
                        PTEMigrFieldSum."Source SQL Table Name" := PTEMigrDatasetTableField.GetSQLSourceTableName(PTEMigration."Source Company Name");
                        PTEMigrFieldSum."Source Field Name" := PTEMigrDatasetTableField."Source Field Name";
                        PTEMigrFieldSum."Source SQL Field Name" := PTEMigrDatasetTableField.GetSQLSourceFieldName();
                        PTEMigrFieldSum."Target SQL Database Code" := PTEMigration."Target SQL Database Code";
                        PTEMigrFieldSum."Target Table Name" := PTEMigrDatasetTableField."Target table name";
                        PTEMigrFieldSum."Target SQL Table Name" := PTEMigrDatasetTableField.GetSQLTargetTableName(PTEMigration."Target Company Name");
                        PTEMigrFieldSum."Target Field Name" := PTEMigrDatasetTableField."Target Field Name";
                        PTEMigrFieldSum."Target SQL Field Name" := PTEMigrDatasetTableField.GetSQLTargetFieldName();
                        PTEMigrFieldSum.Insert();
                        SumEntryNo := SumEntryNo + 1;
                    until PTEMigrDatasetTableField.Next() = 0;
            end;
        end;
    end;

    local procedure CountRecords(MigrationCode: Code[20])
    var
        PTEMigrNumberOfRecords: Record "PTE Migr. Number Of Records";
        PTEMigrFieldSum: Record "PTE Migr. Field Sum";
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
        CountingRecordsMsg: Label 'Processing - Step 2 of 2\Counting Records.\No Of Records: %1', Comment = '%1 = No Of Records';
        PTEMigration: Record "PTE Migration";
    begin
        PTEMigration.Get(MigrationCode);
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
                if PTEMigration."Check Sums In Record Counting" then begin
                    PTEMigrFieldSum.SetRange("Migration Code", PTEMigrNumberOfRecords."Migration Code");
                    PTEMigrFieldSum.SetRange("No Of Rec. Entry No", PTEMigrNumberOfRecords."Entry No");
                    if PTEMigrFieldSum.FindSet() then
                        repeat
                            PTEMigrFieldSum."Source Sum Value" := SumDecimalValue(PTEMigrFieldSum."Source SQL Table Name", PTEMigrFieldSum."Source SQL Field Name", PTEMigrFieldSum."Source SQL Database Code");
                            PTEMigrFieldSum."Target Sum Value" := SumDecimalValue(PTEMigrFieldSum."Target SQL Table Name", PTEMigrFieldSum."Target SQL Field Name", PTEMigrFieldSum."Target SQL Database Code");
                            PTEMigrFieldSum.Difference := PTEMigrFieldSum."Source Sum Value" - PTEMigrFieldSum."Target Sum Value";
                            PTEMigrFieldSum.Modify();
                        until PTEMigrFieldSum.Next() = 0;
                end;
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


    local procedure SumDecimalValue(TableName: Text; FieldName: Text; DatabaseCode: Code[20]): Decimal;
    var
        PTESQLDatabase: Record "PTE SQL Database";
        SQLQueryText: Text;
        ConnectionString: Text;
        SQLConnection: DotNet SqlConnection;
        SQLCommand: DotNet SqlCommand;
        SQLReader: DotNet SqlDataReader;
        SumValue: Decimal;
    begin
        PTESQLDatabase.Get(DatabaseCode);
        SQLQueryText := 'SELECT SUM([' + FieldName + ']) FROM [' + TableName + ']';
        ConnectionString := PTESQLDatabase.GetDatabaseConnectionString();

        SQLConnection := SQLConnection.SqlConnection(ConnectionString);
        SQLConnection.Open();

        SQLCommand := SQLCommand.SqlCommand(SQLQueryText, SQLConnection);
        SQLCommand.CommandTimeout := 10 * 60 * 100; // 10 min.
        SQLReader := SQLCommand.ExecuteReader();
        SQLReader.Read();
        EVALUATE(SumValue, Format(SQLReader.GetValue(0)));
        SQLConnection.Close();
        exit(SumValue);
    end;
}
