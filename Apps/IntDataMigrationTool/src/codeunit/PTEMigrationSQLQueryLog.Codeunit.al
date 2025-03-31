codeunit 99010 "PTE Migration SQL Query Log"
{
    procedure LogMigrationQuery(PTEMigrationSQLQuery: Record "PTE Migration SQL Query"; Executed: Boolean; ErrorDescription: text; StartingDatetime: DateTime; EndingDateTime: DateTime)
    var
        PTEMigrationLogEntry: Record "PTE Migration Log Entry";
    begin
        PTEMigrationSQLQuery.CalcFields(Query);
        PTEMigrationLogEntry.init();
        PTEMigrationLogEntry."Migration Code" := PTEMigrationSQLQuery."Migration Code";
        PTEMigrationLogEntry."Query No." := PTEMigrationSQLQuery."Query No.";
        PTEMigrationLogEntry."Query Description" := PTEMigrationSQLQuery.Description;
        PTEMigrationLogEntry.Query := PTEMigrationSQLQuery.Query;
        PTEMigrationLogEntry."Executed by User ID" := CopyStr(UserId, 1, MaxStrLen(PTEMigrationLogEntry."Executed by User ID"));
        PTEMigrationLogEntry.Executed := Executed;
        PTEMigrationLogEntry."Error Description" := CopyStr(ErrorDescription, 1, MaxStrLen(PTEMigrationLogEntry."Error Description"));
        PTEMigrationLogEntry."Starting Date Time" := StartingDatetime;
        PTEMigrationLogEntry."Ending Date Time" := EndingDateTime;
        PTEMigrationLogEntry.insert();
        Commit();
    end;
}

