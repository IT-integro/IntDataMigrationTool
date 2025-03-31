table 99028 "PTE App. Metadata Set"
{
    Caption = 'Application Metadata Set';
    DrillDownPageID = "PTE App. Metadata Set List";
    LookupPageID = "PTE App. Metadata Set List";
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(10; "Description"; Text[150])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        PTEAppMetadataSetObject: Record "PTE App. Metadata Set Object";
    begin
        PTEAppMetadataSetObject.SetRange("App. Metadata Set Code", Code);
        PTEAppMetadataSetObject.DeleteAll();
    end;

    Procedure ImportMetadataSetFromFile()
    var
        PTEImportMetadataFromFile: Codeunit "PTE Import Metadata From File";
    begin
        PTEImportMetadataFromFile.ImportMetadata(Rec);
    end;
}

