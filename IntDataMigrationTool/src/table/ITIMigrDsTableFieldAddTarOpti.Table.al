table 99032 ITIMigrDsTableFieldAddTarOpti
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
        ITIMigrationDataset: Record "ITI Migration Dataset";
    begin
        ITIMigrationDataset.Get("Migration Dataset Code");
        GetObjectTableFieldOption(ITIMigrationDataset."Source SQL Database Code", "Source table name", "Source Field Name");
    end;

    local procedure GetTargetObjectTableFieldOption()
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
        ITIMigrationDatasetTable: Record "ITI Migration Dataset Table";
    begin
        ITIMigrationDataset.Get("Migration Dataset Code");
        ITIMigrationDatasetTable.Get("Migration Dataset Code", "Source table name");
        "Target table name" := ITIMigrationDatasetTable."Target table name";
        GetObjectTableFieldOption(ITIMigrationDataset."Target SQL Database Code", "Target table name", "Target Field name");
    end;


    local procedure GetObjectTableFieldOption(SQLDatabaseCode: code[20]; TableName: Text[100]; FieldName: Text[100])
    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
        ITIAppObjectTblFieldOpt: Record "ITI App. Object Tbl.Field Opt.";
        PageITIAppObjectTblFieldOpt: page "ITI App. Object Tbl.Field Opt.";
    begin
        ITIAppObjectTblFieldOpt.SetRange("SQL Database Code", SQLDatabaseCode);
        ITIAppObjectTblFieldOpt.SetRange("Table Name", TableName);
        ITIAppObjectTblFieldOpt.SetRange("Field Name", FieldName);
        PageITIAppObjectTblFieldOpt.LookupMode := true;
        PageITIAppObjectTblFieldOpt.Editable := false;
        PageITIAppObjectTblFieldOpt.SetTableView(ITIAppObjectTblFieldOpt);
        if PageITIAppObjectTblFieldOpt.RunModal() = Action::LookupOK then begin
            ITIMigrationDataset.Get("Migration Dataset Code");
            PageITIAppObjectTblFieldOpt.GetRecord(ITIAppObjectTblFieldOpt);
            case SQLDatabaseCode of
                ITIMigrationDataset."Source SQL Database Code":
                    begin
                        "Source Option ID" := ITIAppObjectTblFieldOpt."Option ID";
                        "Source Option Name" := ITIAppObjectTblFieldOpt.Name;
                    end;
                ITIMigrationDataset."Target SQL Database Code":
                    begin
                        "Target Option ID" := ITIAppObjectTblFieldOpt."Option ID";
                        "Target Option Name" := ITIAppObjectTblFieldOpt.Name;
                    end;
            end;
        end;
    end;
}
