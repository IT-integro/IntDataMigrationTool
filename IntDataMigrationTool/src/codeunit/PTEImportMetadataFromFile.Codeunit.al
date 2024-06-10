codeunit 99023 "PTE Import Metadata From File"
{
    procedure ImportMetadata(PTEAppMetadataSet: Record "PTE App. Metadata Set")
    var
        PTEAppMetadataSetObject: Record "PTE App. Metadata Set Object";
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
        PTEAppMetadataSetObject.SetRange("App. Metadata Set Code", PTEAppMetadataSet.Code);
        PTEAppMetadataSetObject.DeleteAll();
        CurrentProgress := 0;
        DialogProgress.OPEN(STRSUBSTNO(ImportingDataFileMsg) + ' #1#####', CurrentProgress);
        while XmlNodeReader.Read() do
            if XmlNodeReader.NodeType = XmlNodeType.Element then
                if XmlNodeReader.Name() = 'ObjectMetadata' then begin
                    PTEAppMetadataSetObject.Init();
                    PTEAppMetadataSetObject."App. Metadata Set Code" := PTEAppMetadataSet.Code;
                    Evaluate(PTEAppMetadataSetObject."Object ID", XmlNodeReader.GetAttribute('ObjectID'));
                    Evaluate(PTEAppMetadataSetObject."Object Type", XmlNodeReader.GetAttribute('ObjectType'));
                    PTEAppMetadataSetObject."Data Per Company" := GetBoolean(XmlNodeReader.GetAttribute('DataPerCompany'));
                    XmlNodeReader.Read();
                    Clear(PTEAppMetadataSetObject.Metadata);
                    PTEAppMetadataSetObject.Metadata.CreateOutStream(OutStream, TEXTENCODING::UTF8);
                    OutStream.Write(FORMAT(XmlNodeReader.Value));
                    PTEAppMetadataSetObject.Insert();
                    CurrentProgress := PTEAppMetadataSetObject."Object ID";
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
