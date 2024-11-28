codeunit 99005 "PTE Run Migration"
{
    Procedure RunMigration(PTEMigration: Record "PTE Migration"; SkipConfirmation: Boolean)
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
        PTEMigrationSQLQuery.Setrange("Migration Code", PTEMigration.Code);
        ProgressTotal := PTEMigrationSQLQuery.Count();
        DialogProgress.OPEN(STRSUBSTNO(ProgressMsg), PTEMigrationSQLQuery."Query No.", PTEMigrationSQLQuery.Description, CurrentProgress, ProgressTotal);
        PTERunLinkedServerQuery.Run(PTEMigration);
        if PTEMigrationSQLQuery.FindSet() then
            repeat
                CurrentProgress := CurrentProgress + 1;
                DialogProgress.UPDATE(1, PTEMigrationSQLQuery."Query No.");
                DialogProgress.UPDATE(2, PTEMigrationSQLQuery.Description);
                DialogProgress.UPDATE(3, CurrentProgress);
                PTEMigrationSQLQuery.RunMigration(true);
            until PTEMigrationSQLQuery.Next() = 0;
        DialogProgress.Close();

        PTEMigrationSQLQuery.Reset();
        PTEMigrationSQLQuery.SetRange("Migration Code", PTEMigration.Code);
        PTEMigrationSQLQuery.SetRange(Executed, false);
        if PTEMigrationSQLQuery.IsEmpty() then begin
            PTEMigration.Executed := true;
            PTEMigration.Modify();
        end;

        Message(FinalMsg);
    end;

    var
        PTEMigrationSQLQuery: Record "PTE Migration SQL Query";
        PTERunLinkedServerQuery: Codeunit "PTE Run Linked Server Query";
}

