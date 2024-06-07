codeunit 99023 "ITI Import Metadata From File"
{
    procedure ImportMetadata(ITIAppMetadataSet: Record "ITI App. Metadata Set")
    var
        ITIAppMetadataSetObject: Record "ITI App. Metadata Set Object";
        MetadataFileContent: BigText;
        FilePath: Text;
        InStream: InStream;
        XmlDocument: DotNet DotNetXmlDocument;
        XmlNodeReader: DotNet XmlNodeReader;
        XmlNodeType: DotNet XmlNodeTypee;
        OutStream: OutStream;
        DialogProgress: Dialog;
        CurrentProgress: Integer;
        ImportingDataFileMsg: Label 'Importing data file. Object:';
    begin
        if UploadIntoStream('Select File', '', '', FilePath, InStream) then
            MetadataFileContent.Read(InStream);

        GetXMLMetadata(MetadataFileContent, XmlDocument);
        XmlNodeReader := XmlNodeReader.XmlNodeReader(XmlDocument);
        ITIAppMetadataSetObject.SetRange("App. Metadata Set Code", ITIAppMetadataSet.Code);
        ITIAppMetadataSetObject.DeleteAll();
        CurrentProgress := 0;
        DialogProgress.OPEN(STRSUBSTNO(ImportingDataFileMsg) + ' #1#####', CurrentProgress);
        while XmlNodeReader.Read() do
            if XmlNodeReader.NodeType = XmlNodeType.Element then
                if XmlNodeReader.Name() = 'ObjectMetadata' then begin
                    ITIAppMetadataSetObject.Init();
                    ITIAppMetadataSetObject."App. Metadata Set Code" := ITIAppMetadataSet.Code;
                    Evaluate(ITIAppMetadataSetObject."Object ID", XmlNodeReader.GetAttribute('ObjectID'));
                    Evaluate(ITIAppMetadataSetObject."Object Type", XmlNodeReader.GetAttribute('ObjectType'));
                    ITIAppMetadataSetObject."Data Per Company" := GetBoolean(XmlNodeReader.GetAttribute('DataPerCompany'));
                    XmlNodeReader.Read();
                    Clear(ITIAppMetadataSetObject.Metadata);
                    ITIAppMetadataSetObject.Metadata.CreateOutStream(OutStream, TEXTENCODING::UTF8);
                    OutStream.Write(FORMAT(XmlNodeReader.Value));
                    ITIAppMetadataSetObject.Insert();
                    CurrentProgress := ITIAppMetadataSetObject."Object ID";
                    DialogProgress.Update(1, CurrentProgress);
                end;
        DialogProgress.Close();
    end;

    local procedure GetBoolean(TextValue: Text): Boolean
    begin
        CASE uppercase(TextValue) OF
            'NULL':
                exit(false);
            '':
                exit(FALSE);
            '1':
                exit(TRUE);
            '0':
                exit(FALSE);
            'TRUE':
                exit(TRUE);
            'FALSE':
                exit(FALSE);
            'YES':
                exit(true);
            'NO':
                exit(false);
            else
                exit(FALSE);
        end;
    end;


    local procedure GetXMLMetadata(ObjectMetadata: BigText; var XmlDocument: DotNet DotNetXmlDocument);
    var
        TempBlob: Codeunit "Temp Blob";
        StreamReader: DotNet SStreamReader;
        Instream: InStream;
        Outstream: OutStream;
        Encoding: DotNet EEncoding;
    begin
        TempBlob.CREATEOUTSTREAM(Outstream);
        ObjectMetadata.WRITE(Outstream);
        XmlDocument := XmlDocument.XmlDocument();
        TempBlob.CREATEINSTREAM(Instream, TEXTENCODING::UTF8);
        StreamReader := StreamReader.StreamReader(Instream, Encoding.UTF8, TRUE);
        XmlDocument.Load(StreamReader);
    end;
}
