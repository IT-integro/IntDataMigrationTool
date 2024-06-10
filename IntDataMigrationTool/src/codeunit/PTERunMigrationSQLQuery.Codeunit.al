codeunit 99004 "PTE Run Migration SQL Query"
{
    TableNo = "PTE Migration SQL Query";
    trigger OnRun()
    begin
        if Rec.Executed then begin
            rec.Executed := false;
            Rec.Modify();
            Commit();
        end;
        Rec.CalcFields(Query);
        if rec.Query.HasValue() then begin
            Rec.Query.CreateInStream(InStream, TEXTENCODING::UTF8);
            InStream.Read(SQLQueryText);
            PTEMigration.Get(Rec."Migration Code");
            if PTEMigration."Execute On" = PTEMigration."Execute On"::Target then
                PTESQLDatabase.Get(PTEMigration."Target SQL Database Code");
            if PTEMigration."Execute On" = PTEMigration."Execute On"::Source then
                PTESQLDatabase.Get(PTEMigration."Source SQL Database Code");

            PTERunSQLQuery.SetSQLQueryText(SQLQueryText);
            PTERunSQLQuery.SetSQLServerConnectionString(PTESQLDatabase.GetDatabaseConnectionString());
            StartingTime := CurrentDateTime;
            ClearLastError();
            if PTERunSQLQuery.Run() then begin
                EndingTime := CurrentDateTime;
                PTEMigrationLogEntry.InsertLogEntry(Rec, true, '', StartingTime, EndingTime);
                Rec.Executed := true;
                Rec.Modify();
                Commit();
            end else begin
                EndingTime := CurrentDateTime;
                PTEMigrationLogEntry.InsertLogEntry(Rec, false, GetLastErrorText(), StartingTime, EndingTime);
                Commit();
                Error(GetLastErrorText());
            end;
        end else
            Error(EmptyQueryStringErr, Rec."Migration Code", Rec."Query No.");
    end;

    var
        PTEMigration: Record "PTE Migration";
        PTESQLDatabase: Record "PTE SQL Database";
        PTEMigrationLogEntry: Record "PTE Migration Log Entry";
        PTERunSQLQuery: Codeunit "PTE Run SQL Query";
        SQLQueryText: Text;
        StartingTime: DateTime;
        EndingTime: DateTime;
        InStream: InStream;
        EmptyQueryStringErr: Label 'SQL Query String is Empty. Migration %1, Query %2', Comment = '%1 = Migration Code, %2 = Query No.';
}
