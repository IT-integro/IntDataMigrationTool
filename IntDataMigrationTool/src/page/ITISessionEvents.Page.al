page 99038 "ITI Session Events"
{
    ApplicationArea = All;
    Caption = 'Session Events';
    PageType = List;
    SourceTable = "Session Event";
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Session ID"; Rec."Session ID")
                {
                    ToolTip = 'Specifies the ID of the session.';
                    ApplicationArea = All;
                }
                field("Server Instance ID"; Rec."Server Instance ID")
                {
                    ToolTip = 'Specifies the ID of the server instance.';
                    ApplicationArea = All;
                }
                field("Session Unique ID"; Rec."Session Unique ID")
                {
                    ToolTip = 'Specifies the unique ID of the session.';
                    ApplicationArea = All;
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Specifies the ID of the User who started the session.';
                    ApplicationArea = All;
                }
                field("Event Datetime"; Rec."Event Datetime")
                {
                    ToolTip = 'Specifies the date and time of the event occurance.';
                    ApplicationArea = All;
                }
                field("Event Type"; Rec."Event Type")
                {
                    ToolTip = 'Specifies the type of the event.';
                    ApplicationArea = All;
                }
                field(Comment; Rec.Comment)
                {
                    ToolTip = 'Specifies the Comment.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
