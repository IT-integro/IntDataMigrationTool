table 99032 PTEMigrDsTableFieldAddTarOpti
{
    Caption = 'Migration Dataset Table Field Additional Target Option';
    DataClassification = ToBeClassified;

    fields
    {
        field(10; "Migration Dataset Code"; Code[20])
        {
            Caption = 'Migration Dataset Code';
        }
        field(20; "Source table name"; Text[100])
        {
            Caption = 'Source table name';
        }
        field(30; "Source Field Name"; Text[100])
        {
            Caption = 'Source Field Name';
        }
        field(40; "Target Field Name"; Text[100])
        {
            Caption = 'Target Field Name';
        }
        field(50; "Source Option ID"; Integer)
        {
            Caption = 'Source Option ID';

            trigger OnLookup()
            begin
                GetSourceObjectTableFieldOption();
            end;

        }
        field(60; "Source Option Name"; Text[250])
        {
            Caption = 'Source Option Name';
        }
        field(70; "Target Option ID"; Integer)
        {
            Caption = 'Target Option ID';

            trigger OnLookup()
            begin
                GetTargetObjectTableFieldOption();
            end;
        }
        field(80; "Target Option Name"; Text[250])
        {
            Caption = 'Target Option Name';
        }
        field(90; "Target Table Name"; Text[100])
        {
            Caption = 'Target Table Name';
        }
    }
    keys
    {
        key(PK; "Migration Dataset Code", "Source table name", "Source Field Name", "Target Field Name", "Source Option ID")
        {
            Clustered = true;
        }
    }

    local procedure GetSourceObjectTableFieldOption()
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
    begin
        PTEMigrationDataset.Get("Migration Dataset Code");
        GetObjectTableFieldOption(PTEMigrationDataset."Source SQL Database Code", "Source table name", "Source Field Name");
    end;

    local procedure GetTargetObjectTableFieldOption()
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
        PTEMigrationDatasetTable: Record "PTE Migration Dataset Table";
    begin
        PTEMigrationDataset.Get("Migration Dataset Code");
        PTEMigrationDatasetTable.Get("Migration Dataset Code", "Source table name");
        "Target table name" := PTEMigrationDatasetTable."Target table name";
        GetObjectTableFieldOption(PTEMigrationDataset."Target SQL Database Code", "Target table name", "Target Field name");
    end;


    local procedure GetObjectTableFieldOption(SQLDatabaseCode: code[20]; TableName: Text[100]; FieldName: Text[100])
    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
        PTEAppObjectTblFieldOpt: Record "PTE App. Object Tbl.Field Opt.";
        PagePTEAppObjectTblFieldOpt: page "PTE App. Object Tbl.Field Opt.";
    begin
        PTEAppObjectTblFieldOpt.SetRange("SQL Database Code", SQLDatabaseCode);
        PTEAppObjectTblFieldOpt.SetRange("Table Name", TableName);
        PTEAppObjectTblFieldOpt.SetRange("Field Name", FieldName);
        PagePTEAppObjectTblFieldOpt.LookupMode := true;
        PagePTEAppObjectTblFieldOpt.Editable := false;
        PagePTEAppObjectTblFieldOpt.SetTableView(PTEAppObjectTblFieldOpt);
        if PagePTEAppObjectTblFieldOpt.RunModal() = Action::LookupOK then begin
            PTEMigrationDataset.Get("Migration Dataset Code");
            PagePTEAppObjectTblFieldOpt.GetRecord(PTEAppObjectTblFieldOpt);
            case SQLDatabaseCode of
                PTEMigrationDataset."Source SQL Database Code":
                    begin
                        "Source Option ID" := PTEAppObjectTblFieldOpt."Option ID";
                        "Source Option Name" := PTEAppObjectTblFieldOpt.Name;
                    end;
                PTEMigrationDataset."Target SQL Database Code":
                    begin
                        "Target Option ID" := PTEAppObjectTblFieldOpt."Option ID";
                        "Target Option Name" := PTEAppObjectTblFieldOpt.Name;
                    end;
            end;
        end;
    end;
}
