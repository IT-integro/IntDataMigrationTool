codeunit 99009 "PTE Get Export Codeunit File"
{
    procedure GetCUForNAV2009(): BigText;
    var
        CodeunitText: BigText;
        NewLine: Text;
        char13: Char;
        char10: Char;
    begin
        char13 := 13;
        char10 := 10;
        NewLine := FORMAT(char13) + FORMAT(char10);
        CodeunitText.AddText('Codeunit 90010 Export Objects Metadata' + NewLine);
        CodeunitText.AddText('{' + NewLine);
        CodeunitText.AddText('  OBJECT-PROPERTIES' + NewLine);
        CodeunitText.AddText('  {' + NewLine);
        CodeunitText.AddText('    Modified=Yes;' + NewLine);
        CodeunitText.AddText('        Version List=PTE Migration Tool;' + NewLine);
        CodeunitText.AddText('  }' + NewLine);
        CodeunitText.AddText('  PROPERTIES' + NewLine);
        CodeunitText.AddText('  {' + NewLine);
        CodeunitText.AddText('    OnRun=VAR' + NewLine);
        CodeunitText.AddText('            ObjectMetadata@100000000 : Record 2000000071;' + NewLine);
        CodeunitText.AddText('            Object@100000012 : Record 2000000001;' + NewLine);
        CodeunitText.AddText('            OutStream@100000002 : OutStream;' + NewLine);
        CodeunitText.AddText('            Filename@100000003 : Text[250];' + NewLine);
        CodeunitText.AddText('            OutputFile@100000004 : File;' + NewLine);
        CodeunitText.AddText('            InStream@100000005 : InStream;' + NewLine);
        CodeunitText.AddText('            TextLine@100000006 : Text[1000];' + NewLine);
        CodeunitText.AddText('            intProgressI@100000008 : Integer;' + NewLine);
        CodeunitText.AddText('            diaProgress@100000009 : Dialog;' + NewLine);
        CodeunitText.AddText('            intProgress@100000010 : Integer;' + NewLine);
        CodeunitText.AddText('            intProgressTotal@100000011 : Integer;' + NewLine);
        CodeunitText.AddText('            TempFilename@100000015 : Text[250];' + NewLine);
        CodeunitText.AddText('            ObjectStartTag@100000007 : TextConst ''ENU="<ObjectMetadata ObjectType=""%1"" ObjectID=""%2"" VersionList=""%3"" DataPerCompany=""%4"">"'';' + NewLine);
        CodeunitText.AddText('            ProgressMsg@100000001 : TextConst ''ENU=Work in progress...: \@1@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\'';' + NewLine);
        CodeunitText.AddText('            DataPerCompany@100000013 : Boolean;' + NewLine);
        CodeunitText.AddText('          BEGIN' + NewLine);
        CodeunitText.AddText('            //This codeunit exports metadata of NAV 2009 table objects for PTE Migration Tool.' + NewLine);
        CodeunitText.AddText('            Filename := ''C:\temp\NAV2009-Metadata.xml''; // Filename where data will be exported.' + NewLine);
        CodeunitText.AddText('            ObjectMetadata.SETRANGE("Object Type", ObjectMetadata."Object Type"::Table); //Objects filter' + NewLine);
        CodeunitText.AddText('            intProgressI := 0;' + NewLine);
        CodeunitText.AddText('            diaProgress.OPEN(ProgressMsg, intProgress);' + NewLine);
        CodeunitText.AddText('            intProgressTotal := ObjectMetadata.COUNT;' + NewLine);
        CodeunitText.AddText('            OutputFile.CREATETEMPFILE;' + NewLine);
        CodeunitText.AddText('            TempFilename := OutputFile.NAME;' + NewLine);
        CodeunitText.AddText('            OutputFile.CREATE(TempFilename);' + NewLine);
        CodeunitText.AddText('            OutputFile.TEXTMODE(TRUE);' + NewLine);
        CodeunitText.AddText('            OutputFile.OPEN(OutputFile.NAME);' + NewLine);
        CodeunitText.AddText('            OutputFile.WRITE('' <?xml version="1.0" encoding="UTF-8" standalone="no"?>'');' + NewLine);
        CodeunitText.AddText('            OutputFile.WRITE('' < Objects > '');' + NewLine);
        CodeunitText.AddText('            IF ObjectMetadata.FINDSET THEN REPEAT' + NewLine);
        CodeunitText.AddText('              Object.SETRANGE(Type, ObjectMetadata."Object Type");' + NewLine);
        CodeunitText.AddText('              Object.SETRANGE("Company Name", '');' + NewLine);
        CodeunitText.AddText('              Object.SETRANGE(ID, ObjectMetadata."Object ID");' + NewLine);
        CodeunitText.AddText('              DataPerCompany := NOT Object.ISEMPTY;' + NewLine);
        CodeunitText.AddText('              OutputFile.WRITE(STRSUBSTNO(ObjectStartTag, ObjectMetadata."Object Type",' + NewLine);
        CodeunitText.AddText('                                                          ObjectMetadata."Object ID",' + NewLine);
        CodeunitText.AddText('                                                          ObjectMetadata."Version List",' + NewLine);
        CodeunitText.AddText('                                                          DataPerCompany));' + NewLine);
        CodeunitText.AddText('              intProgressI := intProgressI + 1;' + NewLine);
        CodeunitText.AddText('              intProgress := ROUND(intProgressI / intProgressTotal*10000,1);' + NewLine);
        CodeunitText.AddText('              diaProgress.UPDATE;' + NewLine);
        CodeunitText.AddText('              ObjectMetadata.CALCFIELDS(Metadata);' + NewLine);
        CodeunitText.AddText('              CLEAR(InStream);' + NewLine);
        CodeunitText.AddText('              ObjectMetadata.Metadata.CREATEINSTREAM(InStream);' + NewLine);
        CodeunitText.AddText('              OutputFile.WRITE('' <![CDATA['');' + NewLine);
        CodeunitText.AddText('              REPEAT' + NewLine);
        CodeunitText.AddText('                InStream.READTEXT(TextLine);' + NewLine);
        CodeunitText.AddText('                OutputFile.WRITE(FORMAT(TextLine));' + NewLine);
        CodeunitText.AddText('              UNTIL InStream.EOS;' + NewLine);
        CodeunitText.AddText('              OutputFile.WRITE('']]>'');' + NewLine);
        CodeunitText.AddText('              OutputFile.WRITE('' </ObjectMetadata>'');' + NewLine);
        CodeunitText.AddText('            UNTIL ObjectMetadata.NEXT = 0;' + NewLine);
        CodeunitText.AddText('            OutputFile.WRITE('' </Objects>'');' + NewLine);
        CodeunitText.AddText('            diaProgress.CLOSE;' + NewLine);
        CodeunitText.AddText('            OutputFile.CLOSE;' + NewLine);
        CodeunitText.AddText('            FILE.COPY(TempFilename,Filename);' + NewLine);
        CodeunitText.AddText('          END;' + NewLine);
        CodeunitText.AddText('  }' + NewLine);
        CodeunitText.AddText('  CODE' + NewLine);
        CodeunitText.AddText('  {' + NewLine);
        CodeunitText.AddText('    BEGIN' + NewLine);
        CodeunitText.AddText('    END.' + NewLine);
        CodeunitText.AddText('  }' + NewLine);
        CodeunitText.AddText('}' + NewLine);

        DownloadCU(CodeunitText);
    end;


    local procedure DownloadCU(CodeunitText: BigText)
    var
        FileManagement: Codeunit "File Management";
        DataFile: File;
        FileName: Text;

    begin
        FileName := FileManagement.ServerTempFileName('txt');
        DataFile.TEXTMODE(TRUE);
        DataFile.CREATE(FileName);
        DataFile.WRITE(FORMAT(CodeunitText));
        DataFile.close();
        FileManagement.DownloadHandler(FileName, 'Save Codeunit', '', '', 'CU_90010-Export_Objects_Metadata.txt');
    end;
}
