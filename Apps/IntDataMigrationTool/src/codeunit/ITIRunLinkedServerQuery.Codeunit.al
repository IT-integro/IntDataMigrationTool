codeunit 99012 "ITI Run Linked Server Query"
{
    TableNo = "ITI Migration";

    trigger OnRun()
    begin
        if Rec.Executed then begin
            rec.Executed := false;
            Rec.Modify();
            Commit();
        end;

        Rec.CalcFields("Linked Server Query");
        if Rec."Linked Server Query".HasValue() then begin
            Rec."Linked Server Query".CreateInStream(InStream, TEXTENCODING::UTF8);
            InStream.Read(SQLQueryText);
            if Rec."Execute On" = Rec."Execute On"::Target then
                ITISQLDatabase.Get(Rec."Target SQL Database Code");
            if Rec."Execute On" = Rec."Execute On"::Source then
                ITISQLDatabase.Get(Rec."Source SQL Database Code");
            SourceConnection := SourceConnection.SqlConnection(ITISQLDatabase.GetDatabaseConnectionString());
            Command := Command.SqlCommand(SQLQueryText, SourceConnection);
            SourceConnection.Open();
            Reader := Command.ExecuteReader();
        end else
            if not CheckIfSameServerName(Rec) then
                Error(EmptyQueryStringErr, Rec.Code);
    end;

    local procedure CheckIfSameServerName(ITIMigration: Record "ITI Migration"): Boolean
    var
        SourceITISQLDatabase, TargetSQLDatabase : Record "ITI SQL Database";
    begin
        SourceITISQLDatabase.Get(ITIMigration."Source SQL Database Code");
        TargetSQLDatabase.Get(ITIMigration."Target SQL Database Code");

        exit(SourceITISQLDatabase."Server Name" = TargetSQLDatabase."Server Name");
    end;

    var
        ITISQLDatabase: Record "ITI SQL Database";
        SourceConnection: DotNet SqlConnection;
        Command: DotNet SqlCommand;
        Reader: DotNet SqlDataReader;
        SQLQueryText: Text;
        InStream: InStream;
        EmptyQueryStringErr: Label 'SQL Query String is Empty. Migration %1', Comment = '%1 = Migration Code.';
}