codeunit 99018 "ITI Run All Migr SQL Queries"
{
    TableNo = "ITI Migration";

    trigger OnRun()
    var
        ITIMigrBackgroundSession: Record "ITI Migr. Background Session";
    begin
        if Rec.Executed then begin
            rec.Executed := false;
            Rec.Modify();
        end;

        ITIMigrationSQLQuery.SetRange("Migration Code", Rec.Code);
        if ITIMigrationSQLQuery.FindSet() then
            repeat
                ITIRunMigrSQLQueryBackgr.SetHideMessages(true);
                ITIRunMigrSQLQueryBackgr.Run(ITIMigrationSQLQuery);
                ITIMigrBackgroundSession.Reset();
                ITIMigrBackgroundSession.SetRange("Migration Code", Rec.Code);
                ITIMigrBackgroundSession.SetRange("Query No.", ITIMigrationSQLQuery."Query No.");
                ITIMigrBackgroundSession.SetRange("Is Active", true);
                ITIMigrBackgroundSession.SetAutoCalcFields("Is Active");
                repeat
                    Sleep(50);
                until not ITIMigrBackgroundSession.FindFirst();
            until ITIMigrationSQLQuery.Next() = 0;

        ITIMigrationSQLQuery.Reset();
        ITIMigrationSQLQuery.SetRange("Migration Code", Rec.Code);
        ITIMigrationSQLQuery.SetRange(Executed, false);
        if ITIMigrationSQLQuery.IsEmpty() then begin
            Rec.Executed := true;
            Rec.Modify();
        end;
    end;

    var
        ITIMigrationSQLQuery: Record "ITI Migration SQL Query";
        ITIRunMigrSQLQueryBackgr: Codeunit "ITI Run Migr.SQL Query Backgr.";
}
