codeunit 99013 "ITI Download SQL Query"
{
    TableNo = "ITI Migration SQL Query";

    trigger OnRun()
    var
        TempITIMigrationSQLQuery: Record "ITI Migration SQL Query" temporary;
        FileTxt: Text;
    begin
        if Rec.FindSet() then begin
            FileTxt := '';
            FileTxt := FileTxt + GetLinkedServerQueryText(Rec) + NewLine();
            TempITIMigrationSQLQuery."Migration Code" := Rec."Migration Code";
            TempITIMigrationSQLQuery."Query No." := Rec."Query No.";
            repeat
                FileTxt := FileTxt + GetQueryText(Rec) + NewLine();
            until Rec.Next() = 0;
            SaveToBlob(TempITIMigrationSQLQuery, FileTxt);
            DownloadQuery(TempITIMigrationSQLQuery);
        end;
    end;

    local procedure GetLinkedServerQueryText(ITIMigrationSQLQuery: Record "ITI Migration SQL Query"): Text
    var
        ITIMigration: Record "ITI Migration";
        Field: Record Field;
        TempBlob: Codeunit "Temp Blob";
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        ITIMigration.Get(ITIMigrationSQLQuery."Migration Code");
        Field.SetRange(TableNo, Database::"ITI Migration");
        Field.SetRange(FieldName, 'Linked Server Query');
        Field.FindFirst();
        TempBlob.FromRecord(ITIMigration, Field."No.");
        TempBlob.CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    local procedure GetQueryText(ITIMigrationSQLQuery: Record "ITI Migration SQL Query"): Text
    var
        Field: Record Field;
        TempBlob: Codeunit "Temp Blob";
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        Field.SetRange(TableNo, Database::"ITI Migration SQL Query");
        Field.SetRange(FieldName, 'Query');
        Field.FindFirst();
        TempBlob.FromRecord(ITIMigrationSQLQuery, Field."No.");
        TempBlob.CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
    end;

    local procedure DownloadQuery(ITIMigrationSQLQuery: Record "ITI Migration SQL Query")
    var
        InStream: InStream;
        Filename: Text;
    begin
        ITIMigrationSQLQuery.Query.CreateInStream(InStream, TEXTENCODING::UTF8);
        Filename := 'Query-' + ITIMigrationSQLQuery."Migration Code" + '-' + Format(ITIMigrationSQLQuery."Query No.", 0, 9) + '.txt';
        Filename := DELCHR(Filename, '=', DELCHR(Filename, '=', 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-.'));
        DownloadFromStream(InStream, '', '', '', Filename);
    end;

    local procedure SaveToBlob(var ITIMigrationSqlQuery: Record "ITI Migration SQL Query"; QueryTxt: Text)
    var
        OutStream: OutStream;
    begin
        Clear(ITIMigrationSqlQuery.Query);
        ITIMigrationSqlQuery.Query.CreateOutStream(OutStream, TEXTENCODING::UTF8);
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
