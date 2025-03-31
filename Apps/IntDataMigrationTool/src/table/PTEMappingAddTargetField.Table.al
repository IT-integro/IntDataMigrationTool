table 99033 PTEMappingAddTargetField
{
    Caption = 'PTEMappingAddTargetField';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Mapping Code"; Code[20])
        {
            Caption = 'Mapping Code';
        }
        field(20; "Source Table Name"; Text[100])
        {
            Caption = 'Source Table Name';
        }
        field(30; "Source Field Name"; Text[100])
        {
            Caption = 'Source Field Name';
        }
        field(40; "Additional Target Field"; Text[100])
        {
            Caption = 'Additional Target Field';
        }
        field(50; "Target Table Name"; Text[100])
        {
            Caption = 'Target Table Name';
        }
    }
    keys
    {
        key(PK; "Mapping Code", "Source Table Name", "Source Field Name", "Additional Target Field")
        {
            Clustered = true;
        }
    }
}
