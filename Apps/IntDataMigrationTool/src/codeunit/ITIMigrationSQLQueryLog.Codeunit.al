codeunit 99010 "ITI Migration SQL Query Log"
{
    procedure LogMigrationQuery(ITIMigrationSQLQuery: Record "ITI Migration SQL Query"; Executed: Boolean; ErrorDescription: text; StartingDatetime: DateTime; EndingDateTime: DateTime)
    var
        ITIMigrationLogEntry: Record "ITI Migration Log Entry";
    begin
        ITIMigrationSQLQuery.CalcFields(Query);
        ITIMigrationLogEntry.init();
        ITIMigrationLogEntry."Migration Code" := ITIMigrationSQLQuery."Migration Code";
        ITIMigrationLogEntry."Query No." := ITIMigrationSQLQuery."Query No.";
        ITIMigrationLogEntry."Query Description" := ITIMigrationSQLQuery.Description;
        ITIMigrationLogEntry.Query := ITIMigrationSQLQuery.Query;
        ITIMigrationLogEntry."Executed by User ID" := CopyStr(UserId, 1, MaxStrLen(ITIMigrationLogEntry."Executed by User ID"));
        ITIMigrationLogEntry.Executed := Executed;
        ITIMigrationLogEntry."Error Description" := CopyStr(ErrorDescription, 1, MaxStrLen(ITIMigrationLogEntry."Error Description"));
        ITIMigrationLogEntry."Starting Date Time" := StartingDatetime;
        ITIMigrationLogEntry."Ending Date Time" := EndingDateTime;
        ITIMigrationLogEntry.insert();
        Commit();
    end;
}

