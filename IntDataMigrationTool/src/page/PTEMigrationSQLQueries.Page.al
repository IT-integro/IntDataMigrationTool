page 99017 "PTE Migration SQL Queries"
{
    ApplicationArea = All;
    Caption = 'Migration SQL Queries';
    PageType = List;
    SourceTable = "PTE Migration SQL Query";
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
                    PTEMigration: Record "PTE Migration";
                    PTERunLinkedServerQuery: Codeunit "PTE Run Linked Server Query";
                begin
                    PTEMigration.Get(Rec."Migration Code");
                    PTERunLinkedServerQuery.Run(PTEMigration);
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
                    PTEMigration: Record "PTE Migration";
                    PTERunLinkedServerQuery: Codeunit "PTE Run Linked Server Query";
                begin
                    if ExecuteMultipleQuery() then exit;

                    PTEMigration.Get(Rec."Migration Code");
                    PTERunLinkedServerQuery.Run(PTEMigration);
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
                    PTEMigrationSQLQuery: Record "PTE Migration SQL Query";
                    PTEDownloadSQLQuery: Codeunit "PTE Download SQL Query";
                begin
                    CurrPage.SetSelectionFilter(PTEMigrationSQLQuery);
                    PTEDownloadSQLQuery.Run(PTEMigrationSQLQuery);
                end;
            }
            action("Edit Query Text")
            {
                Image = Edit;
                ToolTip = 'Edit Query Text';
                ApplicationArea = All;
                RunObject = Page "PTE Edit SQL Query";
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
                RunObject = Page "PTE Migration SQL Query Tables";
                RunPageLink = "Migration Code" = field("Migration Code"), "Query No." = field("Query No.");
                RunPageMode = View;
            }
            action("Log Entries")
            {
                ToolTip = 'Show migration Log Entries';
                ApplicationArea = All;
                Image = InteractionLog;
                RunObject = Page "PTE Migration Log Entries";
                RunPageLink = "Migration Code" = field("Migration Code"), "Query No." = field("Query No.");
                RunPageMode = View;
            }
            action("Migration Background Sessions")
            {
                ToolTip = 'Show migration macground sessions';
                ApplicationArea = All;
                Image = CarryOutActionMessage;
                RunObject = Page "PTE Migr. Background Sessions";
                RunPageLink = "Migration Code" = field("Migration Code"), "Query No." = field("Query No.");
                RunPageMode = View;
            }
        }
    }
    local procedure ExecuteMultipleQuery(): Boolean
    var
        ActiveSession: Record "Active Session";
        PTEMigrBackgroundSession: Record "PTE Migr. Background Session";
        PTEMigrationSQLQuery: Record "PTE Migration SQL Query";
        Timeout, SessionID : Integer;
        SessionUniqueID: Guid;
        SessionStartedMsg: Label 'Migration %1, Queries are running in Background\Session ID: %3\Session Unique ID:%4', Comment = '%1 = Migration Code,  %2= Session ID, %3 = UniqueSessionID';
        SessionNotStartedErr: Label 'Failed to start background session';
    begin
        CurrPage.SetSelectionFilter(PTEMigrationSQLQuery);
        if PTEMigrationSQLQuery.Count() <= 1 then
            exit(false);

        if not Confirm(RunConfirmarionMsg) then
            exit;

        Timeout := 1000 * 60 * 60 * 100; // 100 hours
        if StartSession(SessionID, Codeunit::"PTE Run Multiple Queries", CompanyName, PTEMigrationSQLQuery, Timeout) then begin
            ActiveSession.Get(Database.ServiceInstanceId(), SessionID);
            SessionUniqueID := ActiveSession."Session Unique ID";
            if NOT PTEMigrBackgroundSession.Get(Rec."Migration Code", Rec."Query No.") then begin
                PTEMigrBackgroundSession.Init();
                PTEMigrBackgroundSession."Migration Code" := Rec."Migration Code";
                PTEMigrBackgroundSession."Query No." := Rec."Query No.";
                PTEMigrBackgroundSession.Insert();
            end;
            PTEMigrBackgroundSession."Session ID" := SessionID;
            PTEMigrBackgroundSession."Session Unique ID" := SessionUniqueID;
            PTEMigrBackgroundSession.Modify();
            Commit();
            Message(SessionStartedMsg, Rec."Migration Code", Rec."Query No.", SessionID, SessionUniqueID);
        end else
            Error(SessionNotStartedErr);
        exit(true);
    end;

    var
        RunConfirmarionMsg: label 'This operation will delete data in target tables and migrate data from source tables to target tables. Do you want to continue ?';
        MultipleQueryMsg: Label 'Multiple queries will be executed in background.';

}
