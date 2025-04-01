codeunit 99012 "PTE Run Linked Server Query"
{
    TableNo = "PTE Migration";

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
                PTESQLDatabase.Get(Rec."Target SQL Database Code");
            if Rec."Execute On" = Rec."Execute On"::Source then
                PTESQLDatabase.Get(Rec."Source SQL Database Code");
            SourceConnection := SourceConnection.SqlConnection(PTESQLDatabase.GetDatabaseConnectionString());
            Command := Command.SqlCommand(SQLQueryText, SourceConnection);
            SourceConnection.Open();
            Reader := Command.ExecuteReader();
        end else
            if not CheckIfSameServerName(Rec) then
                Error(EmptyQueryStringErr, Rec.Code);
    end;

    local procedure CheckIfSameServerName(PTEMigration: Record "PTE Migration"): Boolean
    var
        SourcePTESQLDatabase, TargetSQLDatabase : Record "PTE SQL Database";
    begin
        SourcePTESQLDatabase.Get(PTEMigration."Source SQL Database Code");
        TargetSQLDatabase.Get(PTEMigration."Target SQL Database Code");

        exit(SourcePTESQLDatabase."Server Name" = TargetSQLDatabase."Server Name");
    end;

    var
        PTESQLDatabase: Record "PTE SQL Database";
        SourceConnection: DotNet SqlConnection;
        Command: DotNet SqlCommand;
        Reader: DotNet SqlDataReader;
        SQLQueryText: Text;
        InStream: InStream;
        EmptyQueryStringErr: Label 'SQL Query String is Empty. Migration %1', Comment = '%1 = Migration Code.';
}