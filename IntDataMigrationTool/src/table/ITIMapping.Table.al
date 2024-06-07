table 99021 "ITI Mapping"
{
    Caption = 'Mapping';
    DataClassification = ToBeClassified;
    LookupPageId = "ITI Mappings";
    DrillDownPageId = "ITI Mappings";
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
        ITIMappingTable: Record "ITI Mapping Table";
        ITIMappingTableField: Record "ITI Mapping Table Field";
        ITIMappingTableFieldOption: Record "ITI Mapping Table Field Option";
    begin
        ITIMappingTable.SetRange("Mapping Code", Code);
        ITIMappingTable.DeleteAll(true);
        ITIMappingTableField.SetRange("Mapping Code", Code);
        ITIMappingTableField.DeleteAll(true);
        ITIMappingTableFieldOption.SetRange("Mapping Code");
        ITIMappingTableFieldOption.DeleteAll(true);
    end;

    procedure ExportMapping()
    var
        ITIExportImportMapping: Codeunit "ITI Export Import Mapping";
    begin
        ITIExportImportMapping.ExportToJson(Rec);
    end;

    procedure ImportMapping()
    var
        ITIExportImportMapping: Codeunit "ITI Export Import Mapping";
    begin
        ITIExportImportMapping.ImportFromJson();
    end;
}
