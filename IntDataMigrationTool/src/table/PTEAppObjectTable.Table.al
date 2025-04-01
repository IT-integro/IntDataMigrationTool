table 99013 "PTE App. Object Table"
{
    Caption = 'Application Object Table';
    DrillDownPageID = "PTE App. Object Tables";
    LookupPageID = "PTE App. Object Tables";
    fields
    {
        field(1; "SQL Database Code"; Code[20])
        {
            Caption = 'SQL Database Code';
            TableRelation = "PTE SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(2; "ID"; Integer)
        {
            Caption = 'ID';
            DataClassification = ToBeClassified;
        }
        field(10; Name; Text[150])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
        field(20; TableType; Text[150])
        {
            Caption = 'Table Type';
            DataClassification = ToBeClassified;
        }
        field(30; CompressionType; Text[150])
        {
            Caption = 'Compression Type';
            DataClassification = ToBeClassified;
        }
        field(40; Access; Text[150])
        {
            Caption = 'Access';
            DataClassification = ToBeClassified;
        }
        field(50; PasteIsValid; Boolean)
        {
            Caption = 'Paste Is Valid';
            DataClassification = ToBeClassified;
        }
        field(60; LinkedObject; Text[150])
        {
            Caption = 'Linked Object';
            DataClassification = ToBeClassified;
        }
        field(70; Extensible; Boolean)
        {
            Caption = 'Extensible';
            DataClassification = ToBeClassified;
        }
        field(80; ReplicateData; Boolean)
        {
            Caption = 'Replicate Data';
            DataClassification = ToBeClassified;
        }
        field(90; DataClassification; Text[150])
        {
            Caption = 'Data Classification';
            DataClassification = ToBeClassified;
        }
        field(100; SourceAppId; Text[40])
        {
            Caption = 'Source App ID';
            DataClassification = ToBeClassified;
        }
        field(110; DataPerCompany; Boolean)
        {
            Caption = 'Data Per Company';
            DataClassification = ToBeClassified;
        }
        field(120; SourceExtensionType; Text[150])
        {
            Caption = 'Source Extension Type';
            DataClassification = ToBeClassified;
        }
        field(130; ObsoleteState; Text[150])
        {
            Caption = 'Obsolete State';
            DataClassification = ToBeClassified;
        }
        field(140; ObsoleteReason; Text[400])
        {
            Caption = 'Obsolete Reason';
            DataClassification = ToBeClassified;
        }
        field(150; "Number Of Records"; Integer)
        {
            Caption = 'Number Of Records';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "SQL Database Code", "ID")
        {
            Clustered = true;
        }
        key(Key2; "SQL Database Code", Name)
        {
            Unique = true;
        }
        key(Key3; "SQL Database Code", TableType)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        PTEAppObjectTableField: Record "PTE App. Object Table Field";
        PTEAppObjectTblFieldOpt: Record "PTE App. Object Tbl.Field Opt.";

    begin
        PTEAppObjectTableField.SetRange("SQL Database Code", "SQL Database Code");
        PTEAppObjectTableField.SetRange("Table ID", ID);
        PTEAppObjectTableField.DeleteAll();
        PTEAppObjectTblFieldOpt.SetRange("SQL Database Code", "SQL Database Code");
        PTEAppObjectTblFieldOpt.SetRange("Table ID", ID);
        PTEAppObjectTblFieldOpt.DeleteAll();
    end;
}

