table 99005 "PTE Migration Dataset"
{
    Caption = 'migration Dataset';
    LookupPageId = "PTE Migration Dataset List";
    DrillDownPageId = "PTE Migration Dataset List";
    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(10; "Source SQL Database Code"; Code[20])
        {
            Caption = 'Source SQL Database Code';
            TableRelation = "PTE SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                PTEAppObject: Record "PTE App. Object";
                TableExtFoundQst: Label 'Selected Source SQL Database contains Table Extensions in its metadata. Data Migration Tool does not support migration of such objects. Do You want to proceed?';
            begin
                PTEAppObject.SetRange("SQL Database Code", Rec."Source SQL Database Code");
                PTEAppObject.SetRange(Type, PTEAppObject.Type::"TableExtension");
                if not PTEAppObject.IsEmpty then
                    if not Confirm(TableExtFoundQst) then
                        exit;
            end;
        }
        field(20; "Target SQL Database Code"; Code[20])
        {
            Caption = 'Target SQL Database Code';
            TableRelation = "PTE SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(30; "Released"; Boolean)
        {
            Caption = 'Released';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(40; "Number of Errors"; Integer)
        {
            Caption = 'Number Of Errors';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("PTE Migr. Dataset Error" where("Migration Dataset Code" = field(Code),
                                                                "Error Type" = const(Error), Ignore = const(false)));
        }
        field(50; "Description"; Text[250])
        {
            Caption = 'Description/Notes';
            Editable = true;
            DataClassification = ToBeClassified;
        }
        field(60; "Number of Warning"; Integer)
        {
            Caption = 'Number Of Warning';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("PTE Migr. Dataset Error" where("Migration Dataset Code" = field(Code),
                                                                "Error Type" = const(Warning), Ignore = const(false)));
        }
        field(70; "Number of Skipped Errors"; Integer)
        {
            Caption = 'Number Of Skipped Errors';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("PTE Migr. Dataset Error" where("Migration Dataset Code" = field(Code),
                                                                "Error Type" = const(Error), Ignore = const(true)));
        }
        field(80; "Number of Skipped Warning"; Integer)
        {
            Caption = 'Number Of Skipped Warning';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("PTE Migr. Dataset Error" where("Migration Dataset Code" = field(Code),
                                                                "Error Type" = const(Warning), Ignore = const(true)));
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
    trigger OnDelete()
    var
        PTEMigrationDatasetTable: Record "PTE Migration Dataset Table";
        PTEMigrDatasetError: Record "PTE Migr. Dataset Error";
        PTEMigration: Record "PTE Migration";
        MigrationDatasetIsUsedErrLbl: Label 'Migration Dataset %1 is currently used in Migrations, record deletion is blocked.', Comment = '%1 Migration Dataset.';

    begin
        PTEMigration.SetRange("Migration Dataset Code", Rec.Code);
        if not PTEMigration.IsEmpty() then
            Error(MigrationDatasetIsUsedErrLbl, Rec.Code)
        else begin
            TestField(Released, false);
            PTEMigrationDatasetTable.SetRange("Migration Dataset Code", Code);
            PTEMigrationDatasetTable.DeleteAll(true);
            PTEMigrDatasetError.SetRange("Migration Dataset Code", Code);
            PTEMigrDatasetError.DeleteAll(true);
        end;

    end;

    trigger OnModify()
    begin
        TestField(Released, false);
    end;

    procedure Release()
    var
        PTEReleaseMigrationDataset: Codeunit "PTE Release Migration Dataset";
    begin
        PTEReleaseMigrationDataset.Release(Rec);
    end;

    procedure Reopen()
    var
        PTEReleaseMigrationDataset: Codeunit "PTE Release Migration Dataset";
    begin
        PTEReleaseMigrationDataset.Reopen(Rec);
    end;

    procedure InsertMapping()
    var
        PTEApplyMapping: Codeunit "PTE Apply Mapping";
    begin
        PTEApplyMapping.InsertMapping(Rec);
    end;

    procedure UpdateMapping()
    var
        PTEApplyMapping: Codeunit "PTE Apply Mapping";
    begin
        PTEApplyMapping.UpdateMapping(Rec);
    end;

    procedure InsertTables();
    var
        PTEInsertMigrationTables: Report "PTE Insert Migration Tables";
    begin
        PTEInsertMigrationTables.SetMigrationDatasetCode(rec.Code);
        PTEInsertMigrationTables.RunModal();
    end;
}

