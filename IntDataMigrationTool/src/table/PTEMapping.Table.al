table 99021 "PTE Mapping"
{
    Caption = 'Mapping';
    DataClassification = ToBeClassified;
    LookupPageId = "PTE Mappings";
    DrillDownPageId = "PTE Mappings";
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(2; Description; Text[150])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        PTEMappingTable: Record "PTE Mapping Table";
        PTEMappingTableField: Record "PTE Mapping Table Field";
        PTEMappingTableFieldOption: Record "PTE Mapping Table Field Option";
    begin
        PTEMappingTable.SetRange("Mapping Code", Code);
        PTEMappingTable.DeleteAll(true);
        PTEMappingTableField.SetRange("Mapping Code", Code);
        PTEMappingTableField.DeleteAll(true);
        PTEMappingTableFieldOption.SetRange("Mapping Code");
        PTEMappingTableFieldOption.DeleteAll(true);
    end;

    procedure ExportMapping()
    var
        PTEExportImportMapping: Codeunit "PTE Export Import Mapping";
    begin
        PTEExportImportMapping.ExportToJson(Rec);
    end;

    procedure ImportMapping()
    var
        PTEExportImportMapping: Codeunit "PTE Export Import Mapping";
    begin
        PTEExportImportMapping.ImportFromJson();
    end;
}
