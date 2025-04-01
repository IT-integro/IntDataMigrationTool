codeunit 99013 "PTE Download SQL Query"
{
    TableNo = "PTE Migration SQL Query";

    trigger OnRun()
    var
        TempPTEMigrationSQLQuery: Record "PTE Migration SQL Query" temporary;
        FileTxt: Text;
    begin
        if Rec.FindSet() then begin
            FileTxt := '';
            FileTxt := FileTxt + GetLinkedServerQueryText(Rec) + NewLine();
            TempPTEMigrationSQLQuery."Migration Code" := Rec."Migration Code";
            TempPTEMigrationSQLQuery."Query No." := Rec."Query No.";
            repeat
                FileTxt := FileTxt + GetQueryText(Rec) + NewLine();
            until Rec.Next() = 0;
            SaveToBlob(TempPTEMigrationSQLQuery, FileTxt);
            DownloadQuery(TempPTEMigrationSQLQuery);
        end;
    end;

    local procedure GetLinkedServerQueryText(PTEMigrationSQLQuery: Record "PTE Migration SQL Query"): Text
    var
        PTEMigration: Record "PTE Migration";
        Field: Record Field;
        TempBlob: Codeunit "Temp Blob";
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        PTEMigration.Get(PTEMigrationSQLQuery."Migration Code");
        Field.SetRange(TableNo, Database::"PTE Migration");
        Field.SetRange(FieldName, 'Linked Server Query');
        Field.FindFirst();
        TempBlob.FromRecord(PTEMigration, Field."No.");
        TempBlob.CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    local procedure GetQueryText(PTEMigrationSQLQuery: Record "PTE Migration SQL Query"): Text
    var
        Field: Record Field;
        TempBlob: Codeunit "Temp Blob";
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        Field.SetRange(TableNo, Database::"PTE Migration SQL Query");
        Field.SetRange(FieldName, 'Query');
        Field.FindFirst();
        TempBlob.FromRecord(PTEMigrationSQLQuery, Field."No.");
        TempBlob.CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    local procedure DownloadQuery(PTEMigrationSQLQuery: Record "PTE Migration SQL Query")
    var
        InStream: InStream;
        Filename: Text;
    begin
        PTEMigrationSQLQuery.Query.CreateInStream(InStream, TEXTENCODING::UTF8);
        Filename := 'Query-' + PTEMigrationSQLQuery."Migration Code" + '-' + Format(PTEMigrationSQLQuery."Query No.", 0, 9) + '.txt';
        Filename := DELCHR(Filename, '=', DELCHR(Filename, '=', 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-.'));
        DownloadFromStream(InStream, '', '', '', Filename);
    end;

    local procedure SaveToBlob(var PTEMigrationSqlQuery: Record "PTE Migration SQL Query"; QueryTxt: Text)
    var
        OutStream: OutStream;
    begin
        Clear(PTEMigrationSqlQuery.Query);
        PTEMigrationSqlQuery.Query.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.Write(QueryTxt);
    end;

    local procedure NewLine(): Text
    var
        NewLineText: Text;
        char13: Char;
        char10: Char;
    begin
        char13 := 13;
        char10 := 10;
        NewLineText := FORMAT(char13) + FORMAT(char10);
        exit(NewLineText);
    end;
}
