table 99022 "ITI Mapping Table"
{
    Caption = 'Mapping Table';
    DataClassification = ToBeClassified;
    LookupPageId = "ITI Mapping Tables";
    DrillDownPageId = "ITI Mapping Tables";
    fields
    {
        field(1; "Mapping Code"; Code[20])
        {
            TableRelation = "ITI Mapping".Code;
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
        ITIMappingTableField: Record "ITI Mapping Table Field";
        ITIMappingTableFieldOption: Record "ITI Mapping Table Field Option";
    begin
        ITIMappingTableField.SetRange("Mapping Code", "Mapping Code");
        ITIMappingTableField.SetRange("Source Table Name", "Source Table Name");
        ITIMappingTableField.DeleteAll(true);
        ITIMappingTableFieldOption.SetRange("Mapping Code");
        ITIMappingTableFieldOption.SetRange("Source Table Name", "Source Table Name");
        ITIMappingTableFieldOption.DeleteAll();
    end;
}
