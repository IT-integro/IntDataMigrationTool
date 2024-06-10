report 99000 "PTE Insert Migration Tables"
{
    Caption = 'PTE Insert Migration Tables';
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
                        TableRelation = "PTE SQL Database Company".Name;
                        ApplicationArea = Basic, Suite;
                        Editable = SelectedCompaniesEditable;
                        Caption = 'Selected company';
                        ToolTip = 'Specifies Source Application Company name.';
                        trigger OnLookup(var Text: Text): Boolean
                        var
                            PTESQLDatabaseCompany: Record "PTE SQL Database Company";
                            PTESQLDatabaseCompanies: Page "PTE SQL Database Companies";
                        begin
                            PTESQLDatabaseCompany.SetRange("SQL Database Code", PTEMigrationDataset."Source SQL Database Code");
                            PTESQLDatabaseCompanies.Editable := false;
                            PTESQLDatabaseCompanies.LookupMode := true;
                            PTESQLDatabaseCompanies.SetTableView(PTESQLDatabaseCompany);
                            if PTESQLDatabaseCompanies.RunModal() = Action::LookupOK then begin
                                PTESQLDatabaseCompanies.GetRecord(PTESQLDatabaseCompany);
                                SelectedCompanyName := PTESQLDatabaseCompany.Name;
                            end;
                        end;

                        trigger OnValidate()
                        var
                            PTESQLDatabaseCompany: Record "PTE SQL Database Company";
                        begin
                            PTESQLDatabaseCompany.Get(PTEMigrationDataset."Source SQL Database Code", SelectedCompanyName);
                        end;
                    }
                }
            }
        }
        local procedure UpdateControlls()
        var
            PTESQLDatabaseCompany: Record "PTE SQL Database Company";
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
                            PTESQLDatabaseCompany.SetRange("SQL Database Code", PTEMigrationDataset."Source SQL Database Code");
                            PTESQLDatabaseCompany.FindFirst();
                            SelectedCompanyName := PTESQLDatabaseCompany.Name;
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
        PTEDatasetInsertTables: Codeunit "PTE Dataset Insert Tables";
    begin
        case InsertTablesOption of
            InsertTablesOption::"All Tables":
                PTEDatasetInsertTables.InsertAllTables(PTEMigrationDataset);
            InsertTablesOption::"Tables contains data":
                if AllCompanies then
                    PTEDatasetInsertTables.InsertTablesWithDataAllCompanies(PTEMigrationDataset)
                else
                    PTEDatasetInsertTables.InsertTablesWithDataSelectedCompany(PTEMigrationDataset, SelectedCompanyName);
            InsertTablesOption::"Common tables contains data":
                PTEDatasetInsertTables.InsertCommonCompanyTablesWithData(PTEMigrationDataset)
        end;
    end;

    Procedure SetMigrationDatasetCode(MigrationDatasetCode: code[20])
    begin
        PTEMigrationDataset.Get((MigrationDatasetCode));
    end;

    var
        PTEMigrationDataset: Record "PTE Migration Dataset";
        AllCompanies: Boolean;
        InsertTablesOption: Enum "PTE Dataset Insert Tbl. Option";
        AllCompaniesEditable: Boolean;
        SelectedCompaniesEditable: Boolean;
        SelectedCompanyName: Text[150];
}