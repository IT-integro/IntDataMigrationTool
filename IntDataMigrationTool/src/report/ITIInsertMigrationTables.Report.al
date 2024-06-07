report 99000 "ITI Insert Migration Tables"
{
    Caption = 'ITI Insert Migration Tables';
    ProcessingOnly = true;
    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {

                    Caption = 'Options';

                    field("Insert Tables Option"; InsertTablesOption)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Insert option';
                        ToolTip = 'Specifies which tables will be inserted to the selected migration dataset.';
                        trigger OnValidate()
                        begin
                            UpdateControlls();
                        end;
                    }
                    field("All Companies"; AllCompanies)
                    {

                        ApplicationArea = Basic, Suite;
                        Caption = 'All companies';
                        ToolTip = 'If selected then system include tables contains data from all source application companies.';
                        Editable = AllCompaniesEditable;
                        trigger OnValidate()
                        begin
                            UpdateControlls();
                        end;
                    }
                    field("Selected Company Name"; SelectedCompanyName)
                    {
                        TableRelation = "ITI SQL Database Company".Name;
                        ApplicationArea = Basic, Suite;
                        Editable = SelectedCompaniesEditable;
                        Caption = 'Selected company';
                        ToolTip = 'Specifies Source Application Company name.';
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            ITISQLDatabaseCompany: Record "ITI SQL Database Company";
                            ITISQLDatabaseCompanies: Page "ITI SQL Database Companies";
                        begin
                            ITISQLDatabaseCompany.SetRange("SQL Database Code", ITIMigrationDataset."Source SQL Database Code");
                            ITISQLDatabaseCompanies.Editable := false;
                            ITISQLDatabaseCompanies.LookupMode := true;
                            ITISQLDatabaseCompanies.SetTableView(ITISQLDatabaseCompany);
                            if ITISQLDatabaseCompanies.RunModal() = Action::LookupOK then begin
                                ITISQLDatabaseCompanies.GetRecord(ITISQLDatabaseCompany);
                                SelectedCompanyName := ITISQLDatabaseCompany.Name;
                            end;
                        end;

                        trigger OnValidate()
                        var
                            ITISQLDatabaseCompany: Record "ITI SQL Database Company";
                        begin
                            ITISQLDatabaseCompany.Get(ITIMigrationDataset."Source SQL Database Code", SelectedCompanyName);
                        end;
                    }
                }
            }
        }
        local procedure UpdateControlls()
        var
            ITISQLDatabaseCompany: Record "ITI SQL Database Company";
        begin
            case InsertTablesOption of
                InsertTablesOption::"All Tables":
                    begin
                        AllCompaniesEditable := false;
                        SelectedCompaniesEditable := false;
                        SelectedCompanyName := '';
                    end;
                InsertTablesOption::"Tables contains data":
                    begin
                        AllCompaniesEditable := true;
                        if AllCompanies then begin
                            SelectedCompaniesEditable := false;
                            SelectedCompanyName := '';
                        end else begin
                            SelectedCompaniesEditable := true;
                            ITISQLDatabaseCompany.SetRange("SQL Database Code", ITIMigrationDataset."Source SQL Database Code");
                            ITISQLDatabaseCompany.FindFirst();
                            SelectedCompanyName := ITISQLDatabaseCompany.Name;
                        end;
                    end;
                InsertTablesOption::"Common tables contains data":
                    begin
                        AllCompaniesEditable := false;
                        SelectedCompaniesEditable := false;
                        SelectedCompanyName := '';
                    end;
            end;
            Update();
        end;




    }

    trigger OnPreReport()
    var
        ITIDatasetInsertTables: Codeunit "ITI Dataset Insert Tables";
    begin
        case InsertTablesOption of
            InsertTablesOption::"All Tables":
                ITIDatasetInsertTables.InsertAllTables(ITIMigrationDataset);
            InsertTablesOption::"Tables contains data":
                if AllCompanies then
                    ITIDatasetInsertTables.InsertTablesWithDataAllCompanies(ITIMigrationDataset)
                else
                    ITIDatasetInsertTables.InsertTablesWithDataSelectedCompany(ITIMigrationDataset, SelectedCompanyName);
            InsertTablesOption::"Common tables contains data":
                ITIDatasetInsertTables.InsertCommonCompanyTablesWithData(ITIMigrationDataset)
        end;
    end;

    Procedure SetMigrationDatasetCode(MigrationDatasetCode: code[20])
    begin
        ITIMigrationDataset.Get((MigrationDatasetCode));
    end;

    var
        ITIMigrationDataset: Record "ITI Migration Dataset";
        AllCompanies: Boolean;
        InsertTablesOption: Enum "ITI Dataset Insert Tbl. Option";
        AllCompaniesEditable: Boolean;
        SelectedCompaniesEditable: Boolean;
        SelectedCompanyName: Text[150];
}