page 99013 "PTE Migration Dataset Card"
{
    ApplicationArea = All;
    Caption = 'Migration Dataset Card';
    PageType = Document;
    SourceTable = "PTE Migration Dataset";
    UsageCategory = None;
    DataCaptionFields = "Code", "Source SQL Database Code", "Target SQL Database Code";
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the code of the migration dataset.';
                    ApplicationArea = All;
                }
                field("Source SQL Database Code"; Rec."Source SQL Database Code")
                {
                    ToolTip = 'Specifies the code of the Source SQL Database.';
                    ApplicationArea = All;
                }
                field("Target SQL Database Code"; Rec."Target SQL Database Code")
                {
                    ToolTip = 'Specifies the code of the Target SQL Database.';
                    ApplicationArea = All;
                }
                field(Released; Rec.Released)
                {
                    ToolTip = 'Specifies whether this migration dataset is released.';
                    ApplicationArea = All;
                }
                field("Description/Notes"; Rec.Description)
                {
                    ToolTip = 'Add description or notes for this dateset.';
                    ApplicationArea = All;
                }
            }
            group("Errors & Warnings")
            {
                field("Number of Erros"; Rec."Number of Errors")
                {
                    ToolTip = 'Specifies number of errors detected for this dataset.';
                    ApplicationArea = All;
                }
                field("Number of Warning"; Rec."Number of Warning")
                {
                    ToolTip = 'Specifies number of warnings detected for this dataset.';
                    ApplicationArea = All;
                }
                field("Number of Skipped Errors"; Rec."Number of Skipped Errors")
                {
                    ToolTip = 'Specifies number of skipped errors detected for this dataset.';
                    ApplicationArea = All;
                }
                field("Number of Skipped Warning"; Rec."Number of Skipped Warning")
                {
                    ToolTip = 'Specifies number of skipped warnings detected for this dataset.';
                    ApplicationArea = All;
                }
            }
            part(MigrationDatasetTables; "PTE Migration Dataset Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Migration Dataset Code" = FIELD("Code");
                UpdatePropagation = Both;

            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Insert Tables")
            {
                Image = SuggestTables;
                ToolTip = 'Insert Tables to the migration dataset';
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Rec.InsertTables();
                end;
            }

            group("Mapping")
            {
                Image = MapAccounts;
                action("Insert Mapping")
                {
                    Image = ImportChartOfAccounts;
                    ApplicationArea = All;
                    ToolTip = 'Insert Mapping';
                    trigger OnAction()
                    begin
                        Rec.InsertMapping();
                    end;
                }
                action("Update Mapping")
                {
                    Image = IntercompanyOrder;
                    ApplicationArea = All;
                    ToolTip = 'Update Mapping';
                    trigger OnAction()
                    begin
                        Rec.UpdateMapping();
                    end;
                }
                action("Create Mapping from Dataset")
                {
                    Image = CopyWorksheet;
                    ApplicationArea = All;
                    ToolTip = 'Create Mapping from selected Dataset';
                    Ellipsis = true;
                    trigger OnAction()
                    var
                        PTECopyMappingFromDataset: Codeunit "PTE Copy Mapping From Dataset";
                    begin
                        PTECopyMappingFromDataset.Run(Rec);
                    end;
                }
                action("Export CSV Mapping to JSON")
                {
                    Image = ExportToExcel;
                    ApplicationArea = All;
                    ToolTip = 'Export CSV Mapping to JSON file';
                    Ellipsis = true;
                    trigger OnAction()
                    var
                        PTEMigrationDatasetMapping: Codeunit PTEMigrationDatasetMapping;
                    begin
                        PTEMigrationDatasetMapping.GetMigrationDatasetMapping(Rec."Code");
                    end;
                }
            }
            action("Release")
            {
                Image = ReleaseDoc;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Check and release Migration Dataset';
                trigger OnAction()
                begin
                    Rec.Release();
                end;
            }
            action("Reopen")
            {
                Image = ReleaseDoc;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Reopen Migration Dataset';
                trigger OnAction()
                begin
                    Rec.Reopen();
                end;
            }
        }
    }
}
