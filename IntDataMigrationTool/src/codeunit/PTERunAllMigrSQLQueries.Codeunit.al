codeunit 99018 "PTE Run All Migr SQL Queries"
{
    TableNo = "PTE Migration";

    trigger OnRun()
    var
        PTEMigrBackgroundSession: Record "PTE Migr. Background Session";
    begin
        if Rec.Executed then begin
            rec.Executed := false;
            Rec.Modify();
        end;

        PTEMigrationSQLQuery.SetRange("Migration Code", Rec.Code);
        if PTEMigrationSQLQuery.FindSet() then
            repeat
                PTERunMigrSQLQueryBackgr.SetHideMessages(true);
                PTERunMigrSQLQueryBackgr.Run(PTEMigrationSQLQuery);
                PTEMigrBackgroundSession.Reset();
                PTEMigrBackgroundSession.SetRange("Migration Code", Rec.Code);
                PTEMigrBackgroundSession.SetRange("Query No.", PTEMigrationSQLQuery."Query No.");
                PTEMigrBackgroundSession.SetRange("Is Active", true);
                PTEMigrBackgroundSession.SetAutoCalcFields("Is Active");
                repeat
                    Sleep(50);
                until not PTEMigrBackgroundSession.FindFirst();
            until PTEMigrationSQLQuery.Next() = 0;

        PTEMigrationSQLQuery.Reset();
        PTEMigrationSQLQuery.SetRange("Migration Code", Rec.Code);
        PTEMigrationSQLQuery.SetRange(Executed, false);
        if PTEMigrationSQLQuery.IsEmpty() then begin
            Rec.Executed := true;
            Rec.Modify();
        end;
    end;

    var
        PTEMigrationSQLQuery: Record "PTE Migration SQL Query";
        PTERunMigrSQLQueryBackgr: Codeunit "PTE Run Migr.SQL Query Backgr.";
}
