table 99005 "ITI Migration Dataset"
{
    Caption = 'migration Dataset';
    LookupPageId = "ITI Migration Dataset List";
    DrillDownPageId = "ITI Migration Dataset List";
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
            TableRelation = "ITI SQL Database".Code;
            ValidateTableRelation = true;
            DataClassification = ToBeClassified;
        }
        field(20; "Target SQL Database Code"; Code[20])
        {
            Caption = 'Target SQL Database Code';
            TableRelation = "ITI SQL Database".Code;
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
            CalcFormula = count("ITI Migr. Dataset Error" where("Migration Dataset Code" = field(Code),
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
            CalcFormula = count("ITI Migr. Dataset Error" where("Migration Dataset Code" = field(Code),
                                                                "Error Type" = const(Warning), Ignore = const(false)));
        }
        field(70; "Number of Skipped Errors"; Integer)
        {
            Caption = 'Number Of Skipped Errors';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("ITI Migr. Dataset Error" where("Migration Dataset Code" = field(Code),
                                                                "Error Type" = const(Error), Ignore = const(true)));
        }
        field(80; "Number of Skipped Warning"; Integer)
        {
            Caption = 'Number Of Skipped Warning';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("ITI Migr. Dataset Error" where("Migration Dataset Code" = field(Code),
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
        ITIMigrationDatasetTable: Record "ITI Migration Dataset Table";
        ITIMigrDatasetError: Record "ITI Migr. Dataset Error";
        ITIMigration: Record "ITI Migration";
        MigrationDatasetIsUsedErrLbl: Label 'Migration Dataset %1 is currently used in Migrations, record deletion is blocked.', Comment = '%1 Migration Dataset.';

    begin
        ITIMigration.SetRange("Migration Dataset Code", Rec.Code);
        if not ITIMigration.IsEmpty() then
            Error(MigrationDatasetIsUsedErrLbl, Rec.Code)
        else begin
            TestField(Released, false);
            ITIMigrationDatasetTable.SetRange("Migration Dataset Code", Code);
            ITIMigrationDatasetTable.DeleteAll(true);
            ITIMigrDatasetError.SetRange("Migration Dataset Code", Code);
            ITIMigrDatasetError.DeleteAll(true);
        end;

    end;

    trigger OnModify()
    begin
        TestField(Released, false);
    end;

    procedure Release()
    var
        ITIReleaseMigrationDataset: Codeunit "ITI Release Migration Dataset";
    begin
        ITIReleaseMigrationDataset.Release(Rec);
    end;

    procedure Reopen()
    var
        ITIReleaseMigrationDataset: Codeunit "ITI Release Migration Dataset";
    begin
        ITIReleaseMigrationDataset.Reopen(Rec);
    end;

    procedure InsertMapping()
    var
        ITIApplyMapping: Codeunit "ITI Apply Mapping";
    begin
        ITIApplyMapping.InsertMapping(Rec);
    end;

    procedure UpdateMapping()
    var
        ITIApplyMapping: Codeunit "ITI Apply Mapping";
    begin
        ITIApplyMapping.UpdateMapping(Rec);
    end;

    procedure InsertTables();
    var
        ITIInsertMigrationTables: Report "ITI Insert Migration Tables";
    begin
        ITIInsertMigrationTables.SetMigrationDatasetCode(rec.Code);
        ITIInsertMigrationTables.RunModal();
    end;
}

