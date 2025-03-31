table 99011 "PTE SQL Database Installed App"
{
    Caption = 'SQL Database Installed App';
    DrillDownPageID = "PTE SQL Database InstalledApps";
    LookupPageID = "PTE SQL Database InstalledApps";
    fields
    {
        field(1; "SQL Database Code"; Code[20])
        {
            Caption = 'SQL Database Code';
            TableRelation = "PTE SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(2; "ID"; Text[250])
        {
            Caption = 'ID';
            DataClassification = ToBeClassified;
        }
        field(20; "Package ID"; Text[250])
        {
            Caption = 'Package ID';
            DataClassification = ToBeClassified;
        }
        field(30; Name; Text[250])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
        field(40; Publisher; Text[250])
        {
            Caption = 'Publisher';
            DataClassification = ToBeClassified;
        }
        field(50; "Version Major"; Integer)
        {
            Caption = 'Version Major';
            DataClassification = ToBeClassified;
        }
        field(60; "Version Minor"; Integer)
        {
            Caption = 'Version Minor';
            DataClassification = ToBeClassified;
        }
        field(70; "Version Build"; Integer)
        {
            Caption = 'Version Build';
            DataClassification = ToBeClassified;
        }
        field(80; "Version Revision"; Integer)
        {
            Caption = 'Version Revision';
            DataClassification = ToBeClassified;
        }
        field(90; "System ID"; Text[250])
        {
            Caption = 'System ID';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "SQL Database Code", "ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

