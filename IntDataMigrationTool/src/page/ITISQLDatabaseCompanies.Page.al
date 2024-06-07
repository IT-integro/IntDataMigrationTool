page 99015 "ITI SQL Database Companies"
{
    ApplicationArea = All;
    Caption = 'SQL Database Companies';
    PageType = List;
    SourceTable = "ITI SQL Database Company";
    UsageCategory = None;
    DataCaptionFields = "SQL Database Code";
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("SQL Database Code"; Rec."SQL Database Code")
                {
                    ToolTip = 'Specifies the code of the SQL database.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Name"; Rec."Name")
                {
                    ToolTip = 'Specifies the name of the company.';
                    ApplicationArea = All;
                }
                field("SQL Name"; Rec."SQL Name")
                {
                    ToolTip = 'Specifies the name of the company in the SQL database.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
