codeunit 99019 "PTE Run Multiple Queries"
{
    TableNo = "PTE Migration SQL Query";

    trigger OnRun()
    begin
        RunMultipleQueriesInBackground(Rec);
    end;

    procedure RunMultipleQueriesInBackground(var PTEMigrationSQLQuery: Record "PTE Migration SQL Query")
    var
        PTERunMigrSQLQueryBackgr: Codeunit "PTE Run Migr.SQL Query Backgr.";
        MigrationCode: Code[20];
    begin
        MigrationCode := '';
        if PTEMigrationSQLQuery.FindSet() then
            repeat
                if MigrationCode = '' then
                    MigrationCode := PTEMigrationSQLQuery."Migration Code";

                PTERunMigrSQLQueryBackgr.SetHideMessages(true);
                PTERunMigrSQLQueryBackgr.Run(PTEMigrationSQLQuery);
                CheckIfQueryEnded(MigrationCode, PTEMigrationSQLQuery."Query No.");
            until PTEMigrationSQLQuery.Next() = 0;

        CheckIfMigrationEnded(MigrationCode);
    end;

    local procedure CheckIfQueryEnded(MigrationCode: Code[20]; QueryNo: Integer)
    var
        PTEMigrBackgroundSession: Record "PTE Migr. Background Session";
    begin
        PTEMigrBackgroundSession.Reset();
        PTEMigrBackgroundSession.SetRange("Migration Code", MigrationCode);
        PTEMigrBackgroundSession.SetRange("Query No.", QueryNo);
        PTEMigrBackgroundSession.SetRange("Is Active", true);
        PTEMigrBackgroundSession.SetAutoCalcFields("Is Active");
        repeat
            Sleep(50);
        until not PTEMigrBackgroundSession.FindFirst();
    end;

    local procedure CheckIfMigrationEnded(MigrationCode: Code[20])
    var
        PTEMigration: Record "PTE Migration";
        PTEMigrationSQLQuery: Record "PTE Migration SQL Query";
    begin
        PTEMigration.Get(MigrationCode);
        PTEMigrationSQLQuery.Reset();
        PTEMigrationSQLQuery.SetRange("Migration Code", PTEMigration.Code);
        PTEMigrationSQLQuery.SetRange(Executed, false);
        if PTEMigrationSQLQuery.IsEmpty() then begin
            PTEMigration.Executed := true;
            PTEMigration.Modify();
        end;
    end;
}
