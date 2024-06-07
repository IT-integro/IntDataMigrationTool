codeunit 99005 "ITI Run Migration"
{
    Procedure RunMigration(ITIMigration: Record "ITI Migration"; SkipConfirmation: Boolean)
    var
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
        ProgressMsg: Label 'Executing an SQL query: #1#####; #2#####./Current Query: #3#####/Number of queries: #4#####', Comment = '%1 = Query No., %2=Query description, %3 = Current Query, %4 = Number of queries';
        RunConfirmarionMsg: label 'This operation will delete data in target tables and migrate data from source tables to target tables. Do you want to continue ?';
        FinalMsg: Label 'Migration completed';
    begin
        if not SkipConfirmation then
            if not Confirm(RunConfirmarionMsg, false) then
                exit;
        CurrentProgress := 0;
        ITIMigrationSQLQuery.Setrange("Migration Code", ITIMigration.Code);
        ProgressTotal := ITIMigrationSQLQuery.Count();
        DialogProgress.OPEN(STRSUBSTNO(ProgressMsg), ITIMigrationSQLQuery."Query No.", ITIMigrationSQLQuery.Description, CurrentProgress, ProgressTotal);
        ITIRunLinkedServerQuery.Run(ITIMigration);
        if ITIMigrationSQLQuery.FindSet() then
            repeat
                CurrentProgress := CurrentProgress + 1;
                DialogProgress.UPDATE(1, ITIMigrationSQLQuery."Query No.");
                DialogProgress.UPDATE(2, ITIMigrationSQLQuery.Description);
                DialogProgress.UPDATE(3, CurrentProgress);
                ITIMigrationSQLQuery.RunMigration(true);
            until ITIMigrationSQLQuery.Next() = 0;
        DialogProgress.Close();
        Message(FinalMsg);
    end;

    var
        ITIMigrationSQLQuery: Record "ITI Migration SQL Query";
        ITIRunLinkedServerQuery: Codeunit "ITI Run Linked Server Query";
}

