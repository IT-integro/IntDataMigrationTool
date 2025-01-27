page 99016 "PTE Migrations"
{
    ApplicationArea = All;
    Caption = 'Migrations';
    PageType = List;
    SourceTable = "PTE Migration";
    UsageCategory = Administration;
    DataCaptionFields = "Code", "Source SQL Database Code", "Target SQL Database Code";
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the code of the migration.';
                    ApplicationArea = All;
                }
                field(Executed; Rec.Executed)
                {
                    ToolTip = 'Specifies if the meigration queries were executed.';
                    ApplicationArea = All;
                }
                field("Generated Queries"; Rec."Generated Queries")
                {
                    ToolTip = 'Specifies if migration queries were generated.';
                    ApplicationArea = All;
                }
                field("Migration Dataset Code"; Rec."Migration Dataset Code")
                {
                    ToolTip = 'Specifies the ocde of the Migration Dataset.';
                    ApplicationArea = All;
                }
                field("Source SQL Database Code"; Rec."Source SQL Database Code")
                {
                    ToolTip = 'Specifies the code of the Source SQL Database.';
                    ApplicationArea = All;
                }
                field("Source Company Name"; Rec."Source Company Name")
                {
                    ToolTip = 'Specifies the name of the source Company.';
                    ApplicationArea = All;
                }
                field("Target SQL Database Code"; Rec."Target SQL Database Code")
                {
                    ToolTip = 'Specifies the code of the target SQL Database.';
                    ApplicationArea = All;
                }
                field("Target Company Name"; Rec."Target Company Name")
                {
                    ToolTip = 'Specifies the name of the target Company.';
                    ApplicationArea = All;
                }
                field("Execute On"; Rec."Execute On")
                {
                    ToolTip = 'Specifies the database, which will be the target of the generated queries.';
                    ApplicationArea = All;
                }
                field("Do Not Use Transaction"; Rec."Do Not Use Transaction")
                {
                    ToolTip = 'Specifies if every query should be executed as a single transaction.';
                    ApplicationArea = All;
                }
                field("Check Sums In Record Counting"; Rec."Check Sums In Record Counting")
                {
                    ToolTip = 'Specifies whether the system should also calculate the sums of decimal fields when checking the number of records.';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Generate Queries")
            {
                ToolTip = 'Generate Queries';
                Image = ProductionSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Rec.GenerateSQLQueries(false, '');
                end;
            }
            action("Execute")
            {
                Image = ExecuteBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Execute Migration';
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Rec.RunMigration(false);
                end;
            }
            action("Execute In Background")
            {
                Image = AutoReserve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Execute all of this migrations queries in background.';
                ApplicationArea = All;
                trigger OnAction()
                var
                    PTERunLinkedServerQuery: Codeunit "PTE Run Linked Server Query";
                    PTERunMigrSQLQueriesBG: Codeunit "PTE Run Migr SQL Queries BG";
                begin
                    PTERunLinkedServerQuery.Run(Rec);
                    PTERunMigrSQLQueriesBG.Run(Rec);
                end;
            }
            action("Check Number of Records")
            {
                Image = Answers;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Count';
                ApplicationArea = All;
                trigger OnAction()
                var
                    PTEMigrCheckNoOfRecords: Codeunit "PTE Migr. Check No. of Records";
                    PTEMigrNoOfRecordsPage: Page "PTE Migr. Number Of Records";
                    PTEMigrNumberOfRecords: Record "PTE Migr. Number Of Records";
                begin
                    PTEMigrCheckNoOfRecords.CountMigratedRecords(Rec);
                    PTEMigrNumberOfRecords.SetRange("Migration Code", rec.Code);
                    PTEMigrNoOfRecordsPage.SetTableView(PTEMigrNumberOfRecords);
                    PTEMigrNoOfRecordsPage.Run;
                end;
            }
        }
        area(Navigation)
        {
            action("Queries")
            {
                ToolTip = 'Show migration SQL Queries';
                Image = Table;
                RunObject = Page "PTE Migration SQL Queries";
                RunPageLink = "Migration Code" = field("Code");
                RunPageMode = View;
                ApplicationArea = All;
            }
            action("Log Entries")
            {
                ToolTip = 'Show migration Log Entries';
                Image = InteractionLog;
                RunObject = Page "PTE Migration Log Entries";
                RunPageLink = "Migration Code" = field("Code");
                RunPageMode = View;
                ApplicationArea = All;
            }
            action("Edit Linked Server Query")
            {
                ToolTip = 'Edit SQL query which will link source database to the one marked as target.';
                Image = Edit;
                RunObject = Page "PTE Edit Linked Server Query";
                RunPageLink = Code = field("Code");
                RunPageMode = View;
                ApplicationArea = All;
            }

            action("Migration Background Sessions")
            {
                ToolTip = 'Show migration macground sessions';
                ApplicationArea = All;
                Image = CarryOutActionMessage;
                RunObject = Page "PTE Migr. Background Sessions";
                RunPageLink = "Migration Code" = field("Code");
                RunPageMode = View;
            }
        }
    }

}
