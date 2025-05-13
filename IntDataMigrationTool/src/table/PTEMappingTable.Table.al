table 99022 "PTE Mapping Table"
{
    Caption = 'Mapping Table';
    DataClassification = ToBeClassified;
    LookupPageId = "PTE Mapping Tables";
    DrillDownPageId = "PTE Mapping Tables";
    fields
    {
        field(1; "Mapping Code"; Code[20])
        {
            TableRelation = "PTE Mapping".Code;
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(2; "Source Table Name"; Text[150])
        {
            Caption = 'Source Table Name';
            DataClassification = ToBeClassified;
        }
        field(10; "Target Table Name"; Text[150])
        {
            Caption = 'Target Table Name';
            DataClassification = ToBeClassified;
        }
        field(20; "Skip"; Boolean)
        {
            Caption = 'Skip';
            DataClassification = ToBeClassified;
        }
        field(30; "Description"; Text[250])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Mapping Code", "Source Table Name", "Target Table Name")
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    var
        PTEMappingTableField: Record "PTE Mapping Table Field";
        PTEMappingTableFieldOption: Record "PTE Mapping Table Field Option";
    begin
        PTEMappingTableField.SetRange("Mapping Code", "Mapping Code");
        PTEMappingTableField.SetRange("Source Table Name", "Source Table Name");
        PTEMappingTableField.DeleteAll(true);
        PTEMappingTableFieldOption.SetRange("Mapping Code");
        PTEMappingTableFieldOption.SetRange("Source Table Name", "Source Table Name");
        PTEMappingTableFieldOption.DeleteAll();
    end;
}
