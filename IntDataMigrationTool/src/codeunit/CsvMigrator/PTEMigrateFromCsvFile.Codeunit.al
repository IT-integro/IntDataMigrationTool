codeunit 99022 PTEMigrateFromCsvFile
{
    trigger OnRun()
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        FileName: Text;
    begin
        TempBlob.CreateInStream(InStream);
        UploadIntoStream('', '', '', FileName, InStream);

        GetZipFileContentFromFile(InStream);
    end;

    local procedure GetZipFileContentFromBase64(ZipBase64Content: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        ZipInStream: InStream;
        ZipOutStream: OutStream;
    begin
        TempBlob.CreateOutStream(ZipOutStream, TextEncoding::Windows);

        Base64Convert.FromBase64(ZipBase64Content, ZipOutStream);

        TempBlob.CreateInStream(ZipInStream, TextEncoding::Windows);

        GetZipFileContentFromFile(ZipInStream);
    end;

    local procedure GetZipFileContentFromFile(ZipInStream: InStream)
    var
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        ZipContentOutStream: OutStream;
        ZipContentInStream: InStream;
        IterFile: Text;
        ZipContent: List of [Text];

    begin
        DataCompression.OpenZipArchive(ZipInStream, false);
        DataCompression.GetEntryList(ZipContent);

        foreach IterFile in ZipContent do begin
            Clear(TempBlob);
            TempBlob.CreateOutStream(ZipContentOutStream);
            DataCompression.ExtractEntry(IterFile, ZipContentOutStream);
            TempBlob.CreateInStream(ZipContentInStream);
            ImportDataFromCsv(ZipContentInStream, IterFile);
        end;
    end;

    local procedure ImportDataFromCsv(ZipContentInStream: InStream; FileName: Text)
    var
        TempCsvBuffer: Record "CSV Buffer" temporary;
        TableNo, RecordNos : Integer;
    begin
        TempCsvBuffer.DeleteAll();
        TempCsvBuffer.LoadDataFromStream(ZipContentInStream, ';', '');
        SetVaribles(TableNo, RecordNos, FileName, TempCsvBuffer);
        ImportRecords(TempCsvBuffer, TableNo, RecordNos);
    end;

    local procedure SetVaribles(var TableNo: Integer; var RecordNos: Integer; FileName: Text; var TempCsvBuffer: Record "CSV Buffer" temporary)
    begin
        Evaluate(TableNo, DelChr(FileName, '>', '.csv'));
        TempCsvBuffer.FindLast();
        RecordNos := TempCsvBuffer."Line No." - 1;
    end;

    local procedure SetFieldMapping(var TempCsvBuffer: Record "CSV Buffer" temporary; var FieldMapping: Dictionary of [Integer, Integer])
    var
        tmp: Integer;
    begin
        TempCsvBuffer.SetRange("Line No.", 1);
        if TempCsvBuffer.FindFirst() then
            repeat
                Evaluate(tmp, TempCsvBuffer.Value);
                FieldMapping.Add(TempCsvBuffer."Field No.", tmp);
            until TempCsvBuffer.Next() = 0;
        TempCsvBuffer.Reset();
    end;

    local procedure ImportRecords(var TempCsvBuffer: Record "CSV Buffer" temporary; TableNo: Integer; RecordNos: Integer)
    var
        RecRef: RecordRef;
        FieldMapping: Dictionary of [Integer, Integer];
        CurrentRecordNo: Integer;
        ProgressDialog: Dialog;
    begin
        SetFieldMapping(TempCsvBuffer, FieldMapping);
        RecRef.Open(TableNo);
        //TODO: USUNAĆ TO Przed wydaniem!!!!!!!!
        RecRef.DeleteAll();
        //TODO: USUNAĆ TO Przed wydaniem!!!!!!!!

        CurrentRecordNo := 2;

        ProgressDialog.Open(ProgressMsg, TableNo, CurrentRecordNo, RecordNos);

        TempCsvBuffer.SetFilter("Line No.", '>1');
        if TempCsvBuffer.FindSet() then
            repeat
                if TempCsvBuffer."Line No." <> CurrentRecordNo then begin
                    CurrentRecordNo := TempCsvBuffer."Line No.";
                    ProgressDialog.Update();
                    RecRef.Insert();
                    RecRef.Init();
                end;

                SetRecordFieldValue(RecRef, TempCsvBuffer, FieldMapping);
            until TempCsvBuffer.Next() = 0;
        RecRef.Close();
    end;

    local procedure SetRecordFieldValue(var RecRef: RecordRef; var TempCsvBuffer: Record "CSV Buffer" temporary; FieldMapping: Dictionary of [Integer, Integer])
    var
        Field: Record Field;
        FieldRef: FieldRef;
        tmp: Text;
        Int: Integer;
        Date: Date;
        DateTime: DateTime;
        Dec: Decimal;
        Bool: Boolean;
        Options: List of [Text];
    begin
        if not Field.Get(RecRef.Number, FieldMapping.Get(TempCsvBuffer."Field No.")) then
            exit;// Error('Field %1 not found in table %2', FieldMapping.Get(TempCsvBuffer."Field No."), RecRef.Number);

        FieldRef := RecRef.Field(FieldMapping.Get(TempCsvBuffer."Field No."));
        case Field.Type of
            Field.Type::Integer, Field.Type::BigInteger:
                begin
                    Evaluate(Int, TempCsvBuffer.Value);
                    FieldRef.Value(Int);
                end;
            Field.Type::Code, Field.Type::Text:
                begin
                    tmp := TempCsvBuffer.Value.Replace('`!`', ';');
                    tmp := TempCsvBuffer.Value.Replace('`?`', '"');
                    FieldRef.Value(tmp);
                end;
            Field.Type::Date:
                begin
                    Evaluate(Date, TempCsvBuffer.Value);
                    FieldRef.Value(Date);
                end;
            Field.Type::DateTime:
                begin
                    Evaluate(DateTime, TempCsvBuffer.Value);
                    FieldRef.Value(DateTime);
                end;
            Field.Type::Decimal:
                begin
                    Evaluate(Dec, TempCsvBuffer.Value.Replace('.', ','));
                    FieldRef.Value(Dec);
                end;
            Field.Type::Boolean:
                begin
                    Evaluate(Bool, TempCsvBuffer.Value);
                    FieldRef.Value(Bool);
                end;
            Field.Type::BLOB, Field.Type::Media, Field.Type::MediaSet:
                begin
                    // TO DO
                end;
            Field.Type::Option:
                begin
                    Options := Field.OptionString.Split(',');
                    if Options.Contains(TempCsvBuffer.Value) then
                        FieldRef.Value(Options.IndexOf(TempCsvBuffer.Value) - 1)
                    else
                        FieldRef.Value(0);
                end;
            else
                FieldRef.Value(TempCsvBuffer.Value);
        end;

    end;

    var
        ProgressMsg: Label 'Importing table No : #1 #2 records processed of #3';
}
