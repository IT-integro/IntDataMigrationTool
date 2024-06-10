table 99023 "PTE Mapping Table Field"
{
    Caption = 'Mapping Table Field';
    DataClassification = ToBeClassified;
    LookupPageId = "PTE Mapping Table Fields";
    DrillDownPageId = "PTE Mapping Table Fields";
    fields
    {
        field(1; "Mapping Code"; Code[20])
        {
            TableRelation = "PTE Mapping Table"."Mapping Code";
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(2; "Source Table Name"; Text[150])
        {
            TableRelation = "PTE Mapping Table"."Source Table Name" where("Mapping Code" = field("Mapping Code"));
            Caption = 'Source Table Name';
            DataClassification = ToBeClassified;
        }
        field(3; "Source Field Name"; Text[150])
        {
            Caption = 'Source Field Name';
            DataClassification = ToBeClassified;
        }
        field(10; "Target Table Name"; Text[150])
        {
            TableRelation = "PTE Mapping Table"."Target Table Name" where("Mapping Code" = field("Mapping Code"), "Source Table Name" = field("Source Table Name"));
            Caption = 'Target Table Name';
            DataClassification = ToBeClassified;
        }
        field(20; "Target Field Name"; Text[150])
        {
            Caption = 'Target Field Name';
            DataClassification = ToBeClassified;
        }
        field(30; "Skip"; Boolean)
        {
            Caption = 'Skip';
            DataClassification = ToBeClassified;
        }
        field(40; "Constant"; Boolean)
        {
            Caption = 'Constant';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Mapping Code", "Source Table Name", "Target Table Name", "Source Field Name")
        {
            Clustered = true;
        }
        key(Key1; "Mapping Code", "Source Table Name", "Source Field Name")
        {
            Unique = true;
        }
    }

    trigger OnDelete()
    var
        PTEMappingTableFieldOption: Record "PTE Mapping Table Field Option";
        PTEMappingAddTargetField: Record PTEMappingAddTargetField;
    begin
        PTEMappingTableFieldOption.SetRange("Mapping Code");
        PTEMappingTableFieldOption.SetRange("Source Table Name", "Source Table Name", "Source Field Name");
        PTEMappingTableFieldOption.DeleteAll();

        PTEMappingAddTargetField.SetRange("Mapping Code", Rec."Mapping Code");
        PTEMappingAddTargetField.SetRange("Source Table Name", Rec."Source Table Name");
        PTEMappingAddTargetField.SetRange("Source Field Name", Rec."Source Field Name");
        PTEMappingAddTargetField.DeleteAll(true);
    end;
}
