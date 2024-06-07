codeunit 99004 "ITI Run Migration SQL Query"
{
    TableNo = "ITI Migration SQL Query";
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
            ITIMigration.Get(Rec."Migration Code");
            if ITIMigration."Execute On" = ITIMigration."Execute On"::Target then
                ITISQLDatabase.Get(ITIMigration."Target SQL Database Code");
            if ITIMigration."Execute On" = ITIMigration."Execute On"::Source then
                ITISQLDatabase.Get(ITIMigration."Source SQL Database Code");

            ITIRunSQLQuery.SetSQLQueryText(SQLQueryText);
            ITIRunSQLQuery.SetSQLServerConnectionString(ITISQLDatabase.GetDatabaseConnectionString());
            StartingTime := CurrentDateTime;
            ClearLastError();
            if ITIRunSQLQuery.Run() then begin
                EndingTime := CurrentDateTime;
                ITIMigrationLogEntry.InsertLogEntry(Rec, true, '', StartingTime, EndingTime);
                Rec.Executed := true;
                Rec.Modify();
                Commit();
            end else begin
                EndingTime := CurrentDateTime;
                ITIMigrationLogEntry.InsertLogEntry(Rec, false, GetLastErrorText(), StartingTime, EndingTime);
                Commit();
                Error(GetLastErrorText());
            end;
        end else
            Error(EmptyQueryStringErr, Rec."Migration Code", Rec."Query No.");
    end;

    var
        ITIMigration: Record "ITI Migration";
        ITISQLDatabase: Record "ITI SQL Database";
        ITIMigrationLogEntry: Record "ITI Migration Log Entry";
        ITIRunSQLQuery: Codeunit "ITI Run SQL Query";
        SQLQueryText: Text;
        StartingTime: DateTime;
        EndingTime: DateTime;
        InStream: InStream;
        EmptyQueryStringErr: Label 'SQL Query String is Empty. Migration %1, Query %2', Comment = '%1 = Migration Code, %2 = Query No.';
}
