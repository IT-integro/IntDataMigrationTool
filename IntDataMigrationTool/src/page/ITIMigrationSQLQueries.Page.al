page 99017 "ITI Migration SQL Queries"
{
    ApplicationArea = All;
    Caption = 'Migration SQL Queries';
    PageType = List;
    SourceTable = "ITI Migration SQL Query";
    UsageCategory = None;
    DataCaptionFields = "Migration Code", Description;
    Editable = false;
    InsertAllowed = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Migration Code"; Rec."Migration Code")
                {
                    ToolTip = 'Specifies the code of the migration.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Query No."; Rec."Query No.")
                {
                    ToolTip = 'Specifies the number of the Query.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the query.';
                    ApplicationArea = All;
                }
                field(Executed; Rec.Executed)
                {
                    ToolTip = 'Specifies if the query was executed on target database.';
                    ApplicationArea = All;
                }
                field("Modified"; Rec."Modified")
                {
                    ToolTip = 'Specifies if the code of the query has been changed manually.';
                    ApplicationArea = All;
                }
                field("Running in Background Session"; Rec."Running in Background Session")
                {
                    ToolTip = 'Determines if the query is running in a background session.';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Execute")
            {
                Image = ExecuteBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Execute Query';
                ApplicationArea = All;
                trigger OnAction()
                var
                    ITIMigration: Record "ITI Migration";
                    ITIRunLinkedServerQuery: Codeunit "ITI Run Linked Server Query";
                begin
                    ITIMigration.Get(Rec."Migration Code");
                    ITIRunLinkedServerQuery.Run(ITIMigration);
                    Rec.RunMigration(false);
                end;
            }
            action("Execute In Background")
            {
                Image = AddAction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Execute Query in background session';
                ApplicationArea = All;
                trigger OnAction()
                var
                    ITIMigration: Record "ITI Migration";
                    ITIRunLinkedServerQuery: Codeunit "ITI Run Linked Server Query";
                begin
                    ITIMigration.Get(Rec."Migration Code");
                    ITIRunLinkedServerQuery.Run(ITIMigration);
                    Rec.RunMigrationInBackground(false);
                end;
            }
            action("Generate Single Table Query")
            {
                ToolTip = 'Generate Queries';
                Image = ProductionSetup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Rec.GenerateSQLQuery(false, Rec.SourceTableName);
                end;
            }

            action("Download Query Text")
            {
                Image = Download;
                ToolTip = 'Download Query Text';
                ApplicationArea = All;
                trigger OnAction()
                var
                    ITIMigrationSQLQuery: Record "ITI Migration SQL Query";
                    ITIDownloadSQLQuery: Codeunit "ITI Download SQL Query";
                begin
                    CurrPage.SetSelectionFilter(ITIMigrationSQLQuery);
                    ITIDownloadSQLQuery.Run(ITIMigrationSQLQuery);
                end;
            }
            action("Edit Query Text")
            {
                Image = Edit;
                ToolTip = 'Edit Query Text';
                ApplicationArea = All;
                RunObject = Page "ITI Edit SQL Query";
                RunPageLink = "Migration Code" = field("Migration Code"), "Query No." = field("Query No.");
                RunPageMode = View;
            }


        }
        area(Navigation)
        {
            action("Tables")
            {
                ToolTip = 'Show migration tables';
                ApplicationArea = All;
                Image = Table;
                RunObject = Page "ITI Migration SQL Query Tables";
                RunPageLink = "Migration Code" = field("Migration Code"), "Query No." = field("Query No.");
                RunPageMode = View;
            }
            action("Log Entries")
            {
                ToolTip = 'Show migration Log Entries';
                ApplicationArea = All;
                Image = InteractionLog;
                RunObject = Page "ITI Migration Log Entries";
                RunPageLink = "Migration Code" = field("Migration Code"), "Query No." = field("Query No.");
                RunPageMode = View;
            }
            action("Migration Background Sessions")
            {
                ToolTip = 'Show migration macground sessions';
                ApplicationArea = All;
                Image = CarryOutActionMessage;
                RunObject = Page "ITI Migr. Background Sessions";
                RunPageLink = "Migration Code" = field("Migration Code"), "Query No." = field("Query No.");
                RunPageMode = View;
            }
        }
    }
}
