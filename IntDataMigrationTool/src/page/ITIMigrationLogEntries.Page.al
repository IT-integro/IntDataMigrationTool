page 99028 "ITI Migration Log Entries"
{
    ApplicationArea = All;
    Caption = 'ITI Migration Log Entries';
    PageType = List;
    SourceTable = "ITI Migration Log Entry";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the number of entry.';
                    ApplicationArea = All;
                }
                field(Executed; Rec.Executed)
                {
                    ToolTip = 'Specifies whether action was executed.';
                    ApplicationArea = All;
                }
                field("Error Description"; Rec."Error Description")
                {
                    ToolTip = 'Specifies the description of the error, which occured during the migration.';
                    ApplicationArea = All;
                }
                field("Executed by User ID"; Rec."Executed by User ID")
                {
                    ToolTip = 'Specifies the ID of user who executed specific task.';
                    ApplicationArea = All;
                }
                field("Starting Date Time"; Rec."Starting Date Time")
                {
                    ToolTip = 'Specifies starting date and time of the task.';
                    ApplicationArea = All;
                }
                field("Ending Date Time"; Rec."Ending Date Time")
                {
                    ToolTip = 'Specifies ending date and time of the task.';
                    ApplicationArea = All;
                }
                field("Migration Code"; Rec."Migration Code")
                {
                    ToolTip = 'Specifies the code of the migration.';
                    ApplicationArea = All;
                }
                field("Query No."; Rec."Query No.")
                {
                    ToolTip = 'Specifies the number of the Query.';
                    ApplicationArea = All;
                }
                field("Query Description"; Rec."Query Description")
                {
                    ToolTip = 'Specifies the description of the Query.';
                    ApplicationArea = All;
                }

            }
        }

    }
    actions
    {
        area(Processing)
        {
            action("Download Query Text")
            {
                Image = Download;
                ToolTip = 'Download Query Text';
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Rec.DownloadQuery();
                end;
            }
        }
    }
}
