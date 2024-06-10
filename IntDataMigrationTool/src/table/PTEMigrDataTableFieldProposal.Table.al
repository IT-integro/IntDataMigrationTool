table 99030 "PTEMigrDataTableFieldProposal"
{
    Caption = 'Migration Data Table Field Proposal';
    fields
    {
        field(1; "Migration Dataset Code"; Code[20])
        {
            Caption = 'Migration Dataset Code';
            TableRelation = "PTE Migration Dataset".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Source table name"; Text[150])
        {
            Caption = 'Source table name';
            TableRelation = "PTE Migration Dataset Table"."Source Table Name";
            DataClassification = ToBeClassified;
        }
        field(10; "Source SQL Database Code"; Code[20])
        {
            Caption = 'Source SQL Database Code';
            DataClassification = ToBeClassified;
        }
        field(20; "Source Field Name"; Text[150])
        {
            Caption = 'Source Field Name';
            DataClassification = ToBeClassified;
        }
        field(30; "Target Field Name Proposal"; Text[150])
        {
            Caption = 'Target Field Name Proposal';
            DataClassification = ToBeClassified;
        }
        field(40; "Target Field No. Proposal"; Integer)
        {
            Caption = 'Target Field No. Proposal';
            DataClassification = ToBeClassified;
        }
        field(50; "Field Data Type"; Text[150])
        {
            Caption = 'Field Data Type';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Migration Dataset Code", "Source table name", "Source Field Name", "Target Field Name Proposal")
        {
            Clustered = true;
        }
    }

}