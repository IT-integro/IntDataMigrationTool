table 99024 "ITI Mapping Table Field Option"
{
    Caption = 'Mapping Table Field Option';
    DataClassification = ToBeClassified;
    LookupPageId = "ITI Mapping Table Field Option";
    DrillDownPageId = "ITI Mapping Table Field Option";
    fields
    {
        field(1; "Mapping Code"; Code[20])
        {
            TableRelation = "ITI Mapping Table Field"."Mapping Code";
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(2; "Source Table Name"; Text[150])
        {
            TableRelation = "ITI Mapping Table Field"."Source Table Name" where("Mapping Code" = field("Mapping Code"));
            Caption = 'Source Table Name';
            DataClassification = ToBeClassified;
        }
        field(3; "Source Field Name"; Text[150])
        {
            TableRelation = "ITI Mapping Table Field"."Source Field Name" where("Mapping Code" = field("Mapping Code"), "Source Table Name" = field("Source Table Name"));
            Caption = 'Source Field Name';
            DataClassification = ToBeClassified;
        }
        field(4; "Source Field Option"; Integer)
        {
            Caption = 'Source Field Option';
            DataClassification = ToBeClassified;
        }
        field(10; "Target Table Name"; Text[150])
        {
            TableRelation = "ITI Mapping Table Field"."Target Table Name" where("Mapping Code" = field("Mapping Code"), "Source Table Name" = field("Source Table Name"));
            Caption = 'Target Table Name';
            DataClassification = ToBeClassified;
        }
        field(20; "Target Field Name"; Text[150])
        {
            TableRelation = "ITI Mapping Table Field"."Target Field Name" where("Mapping Code" = field("Mapping Code"), "Source Table Name" = field("Source Table Name"), "Source Field Name" = field("Source Field Name"));
            Caption = 'Target Field Name';
            DataClassification = ToBeClassified;
        }
        field(30; "Target Field Option"; Integer)
        {
            Caption = 'Source Field Option';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Mapping Code", "Source Table Name", "Source Field Name", "Source Field Option", "Target Table Name", "Target Field Name")
        {
            Clustered = true;
        }
        key(Key1; "Mapping Code", "Source Table Name", "Source Field Name", "Source Field Option")
        {
            Unique = true;
        }
    }
}
