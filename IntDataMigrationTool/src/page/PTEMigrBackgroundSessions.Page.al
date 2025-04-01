page 99037 "PTE Migr. Background Sessions"
{
    ApplicationArea = All;
    Caption = 'PTE Migr. Background Sessions';
    PageType = List;
    SourceTable = "PTE Migr. Background Session";
    UsageCategory = Lists;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Migration Code"; Rec."Migration Code")
                {
                    ToolTip = 'Specifies the code of the Migration.';
                    ApplicationArea = All;
                }
                field("Query No."; Rec."Query No.")
                {
                    ToolTip = 'Specifies the number of the Query.';
                    ApplicationArea = All;
                }
                field("Session ID"; Rec."Session ID")
                {
                    ToolTip = 'Specifies the ID of the background session, which is used to run queries.';
                    ApplicationArea = All;
                }
                field("Session Unique ID"; Rec."Session Unique ID")
                {
                    ToolTip = 'Specifies the unique ID of the background session, which is used to run queries.';
                    ApplicationArea = All;
                }
                field("Is Active"; Rec."Is Active")
                {
                    ToolTip = 'Specifies if the background session is still running.';
                    ApplicationArea = All;
                }
                field("No Of Session Events"; Rec."No Of Session Events")
                {
                    ToolTip = 'Specifies the number of events which occured during selected session.';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    var
                        SessionEvent: Record "Session Event";
                        PTESessionEvents: page "PTE Session Events";
                    begin
                        SessionEvent.SetRange("Session Unique ID", Rec."Session Unique ID");
                        PTESessionEvents.SetTableView(SessionEvent);
                        PTESessionEvents.LookupMode := true;
                        PTESessionEvents.RunModal();
                    end;
                }
                field("Last Comment"; Rec.GetLastComment())
                {
                    Caption = 'Last Comment';
                    ToolTip = 'Specifies the last comment from the session event.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
