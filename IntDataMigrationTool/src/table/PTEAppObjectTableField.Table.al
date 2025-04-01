table 99014 "PTE App. Object Table Field"
{
    Caption = 'Application Object Table Field';
    DrillDownPageID = "PTE App. Object Table Fields";
    LookupPageID = "PTE App. Object Table Fields";
    fields
    {
        field(1; "SQL Database Code"; Code[20])
        {
            Caption = 'SQL Database Code';
            TableRelation = "PTE SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            TableRelation = "PTE App. Object Table"."ID" where("SQL Database Code" = field("SQL Database Code"));
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(3; "ID"; Integer)
        {
            Caption = 'ID';
            DataClassification = ToBeClassified;
        }
        field(5; "Key"; Boolean)
        {
            Caption = 'Key';
            DataClassification = ToBeClassified;
        }
        field(7; "Table Name"; Text[150])
        {
            Caption = 'Table Name';
            TableRelation = "PTE App. Object Table"."Name" where("SQL Database Code" = field("SQL Database Code"), "ID" = field("Table ID"));
            Editable = false;
            ValidateTableRelation = true;
        }
        field(10; Name; Text[150])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
        field(20; Datatype; Text[150])
        {
            Caption = 'Data Type';
            DataClassification = ToBeClassified;
        }
        field(30; DataLength; Integer)
        {
            Caption = 'Data Length';
            DataClassification = ToBeClassified;
        }
        field(40; "App ID"; Text[40])
        {
            Caption = 'App ID';
            DataClassification = ToBeClassified;
            TableRelation = "PTE SQL Database Installed App"."ID" WHERE("SQL Database Code" = FIELD("SQL Database Code"));
        }
        field(45; "App Name"; Text[250])
        {
            Caption = 'App Name';
            FieldClass = FlowField;
            CalcFormula = Lookup("PTE SQL Database Installed App".Name WHERE("SQL Database Code" = FIELD("SQL Database Code"), "ID" = field("App ID")));

        }
        field(50; SourceExtensionType; Integer)
        {
            Caption = 'Source Extension Type';
            DataClassification = ToBeClassified;
        }
        field(60; NotBlank; Boolean)
        {
            Caption = 'Not Blank';
            DataClassification = ToBeClassified;
        }
        field(70; FieldClass; Text[150])
        {
            Caption = 'Field Class';
            DataClassification = ToBeClassified;
        }
        field(80; DateFormula; Text[150])
        {
            Caption = 'Date Formula';
            DataClassification = ToBeClassified;
        }
        field(90; Editable; Boolean)
        {
            Caption = 'Editable';
            DataClassification = ToBeClassified;
        }
        field(100; Access; Text[150])
        {
            Caption = 'Access';
            DataClassification = ToBeClassified;
        }
        field(110; Numeric; Boolean)
        {
            Caption = 'Numeric';
            DataClassification = ToBeClassified;
        }
        field(120; ExternalAccess; Text[150])
        {
            Caption = 'External Access';
            DataClassification = ToBeClassified;
        }
        field(130; ValidateTableRelation; Boolean)
        {
            Caption = 'Validate Table Relation';
            DataClassification = ToBeClassified;
        }
        field(140; DataClassification; Text[150])
        {
            Caption = 'Data Classification';
            DataClassification = ToBeClassified;
        }
        field(150; EnumTypeName; Text[150])
        {
            Caption = 'Enum Type';
            DataClassification = ToBeClassified;
        }
        field(160; EnumTypeId; Integer)
        {
            Caption = 'Enum Type ID';
            DataClassification = ToBeClassified;
        }
        field(170; InitValue; Text[150])
        {
            Caption = 'Init Value';
            DataClassification = ToBeClassified;
        }
        field(180; IsExtension; Boolean)
        {
            Caption = 'Is Extension';
            DataClassification = ToBeClassified;
        }
        field(190; ObsoleteState; Text[150])
        {
            Caption = 'Obsolete State';
            DataClassification = ToBeClassified;
        }
        field(200; ObsoleteReason; Text[250])
        {
            Caption = 'Obsolete Reason';
            DataClassification = ToBeClassified;
        }

        field(210; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = ToBeClassified;
        }

        field(500; "SQL Table Name Excl. C. Name"; Text[150])
        {
            Caption = 'SQL Table Name Excl. Company Name';
            DataClassification = ToBeClassified;
        }
        field(510; "SQL Field Name"; Text[150])
        {
            Caption = 'SQL Field Name';
            DataClassification = ToBeClassified;
        }

        field(511; "SQL Field Name Candidate"; Text[150])
        {
            Caption = 'SQL Field Name Candidate';
            DataClassification = ToBeClassified;
        }
        field(512; "SQL Field Name Candidate 2"; Text[150])
        {
            Caption = 'SQL Field Name Candidate 2';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "SQL Database Code", "Table ID", "ID")
        {
            Clustered = true;
        }
        key(Key2; "SQL Database Code", "Table ID", Name, FieldClass)
        {

        }
        key(Key3; "SQL Database Code", "Table ID", "SQL Table Name Excl. C. Name", "SQL Field Name")
        {

        }
        key(Key4; "SQL Database Code", "Table Name", Name, FieldClass)
        {
            Unique = true;
        }

        key(Key5; "SQL Database Code", "Table ID", FieldClass, Datatype)
        {
        }
    }


    fieldgroups
    {
    }

    trigger OnDelete()
    var
        PTEAppObjectTblFieldOpt: Record "PTE App. Object Tbl.Field Opt.";

    begin
        PTEAppObjectTblFieldOpt.SetRange("SQL Database Code", "SQL Database Code");
        PTEAppObjectTblFieldOpt.SetRange("Table ID", "Table ID");
        PTEAppObjectTblFieldOpt.SetRange("Field ID", ID);
        PTEAppObjectTblFieldOpt.DeleteAll();
    end;

    procedure GetSQLTableName(CompanyName: Text[150]): Text[250]
    var
        PTESQLDatabaseCompany: Record "PTE SQL Database Company";
        PTEAppObjectTable: Record "PTE App. Object Table";
    begin
        PTEAppObjectTable.Get("SQL Database Code", "Table ID");
        PTESQLDatabaseCompany.Get("SQL Database Code", CompanyName);
        if PTEAppObjectTable.DataPerCompany then
            exit(PTESQLDatabaseCompany."SQL Name" + '$' + "SQL Table Name Excl. C. Name")
        else
            exit("SQL Table Name Excl. C. Name");
    end;
}

