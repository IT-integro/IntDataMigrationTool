table 99012 "PTE App. Object"
{
    Caption = 'Application Object';
    DrillDownPageID = "PTE App. Objects";
    LookupPageID = "PTE App. Objects";
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
        field(3; "Type"; Enum "PTE Object Type")
        {
            Caption = 'Type';
            DataClassification = ToBeClassified;
        }
        field(5; "Source"; Text[250])
        {
            Caption = 'Source';
            DataClassification = ToBeClassified;
        }
        field(6; "Name"; Text[250])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
        field(10; "Subtype"; Text[250])
        {
            Caption = 'Subtype';
            DataClassification = ToBeClassified;
        }
        field(20; "Runtime Package ID"; Text[40])
        {
            Caption = 'Runtime Package ID';
            DataClassification = ToBeClassified;
        }
        field(30; "Package ID"; Text[40])
        {
            Caption = 'Package ID';
            DataClassification = ToBeClassified;
        }
        field(40; "Application ID"; Text[40])
        {
            Caption = 'Application ID';
            DataClassification = ToBeClassified;
        }
        field(50; "Application Name"; Text[250])
        {
            Caption = 'Application Name';
            DataClassification = ToBeClassified;
        }
        field(51; "Duplicated Name"; Boolean)
        {
            Caption = 'Duplicated Name';
            DataClassification = ToBeClassified;
        }
        field(52; "Skipped"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Exist("PTE App Skipped Objects" where("SQL Database Code" = field("SQL Database Code"), "ID" = field("ID"), "Type" = field("Type"), "Source" = field("Source")));
            Caption = 'Skipped';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "SQL Database Code", "ID", "Type", "Source")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    Procedure DownloadMetadata()
    var
        PTEGetMetadata: Codeunit "PTE Get Metadata";
    begin
        PTEGetMetadata.DownloadObject(Rec);
    end;

    Procedure AddToSkipped()
    var
        PTEAppSkippedObjects: Record "PTE App Skipped Objects";
    begin
        if not PTEAppSkippedObjects.Get(Rec."SQL Database Code", Rec."ID", Rec."Type", Rec."Source") then begin
            PTEAppSkippedObjects.Init();
            PTEAppSkippedObjects.TransferFields(Rec);
            PTEAppSkippedObjects.Insert();
        end;
    end;

    Procedure RemoveFromSkipped()
    var
        PTEAppSkippedObjects: Record "PTE App Skipped Objects";
    begin
        if PTEAppSkippedObjects.Get(Rec."SQL Database Code", Rec."ID", Rec."Type", Rec."Source") then begin
            PTEAppSkippedObjects.Delete();
        end;
    end;
}

