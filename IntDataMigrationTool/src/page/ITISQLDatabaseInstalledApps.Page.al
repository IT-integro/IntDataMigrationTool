page 99008 "ITI SQL Database InstalledApps"
{
    //ApplicationArea = All;
    Caption = 'SQL Database Installed Apps';
    PageType = List;
    SourceTable = "ITI SQL Database Installed App";
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
                field("App ID"; Rec."ID")
                {
                    ToolTip = 'Specifies the ID of the app.';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the app.';
                    ApplicationArea = All;
                }
                field("Package ID"; Rec."Package ID")
                {
                    ToolTip = 'Specifies the ID of the package.';
                    ApplicationArea = All;
                }
                field(Publisher; Rec.Publisher)
                {
                    ToolTip = 'Specifies the publisher of the app.';
                    ApplicationArea = All;
                }
                field("Version Build"; Rec."Version Build")
                {
                    ToolTip = 'Specifies the version build of the app.';
                    ApplicationArea = All;
                }
                field("Version Major"; Rec."Version Major")
                {
                    ToolTip = 'Specifies the version major of the app.';
                    ApplicationArea = All;
                }
                field("Version Minor"; Rec."Version Minor")
                {
                    ToolTip = 'Specifies the version minor of the app.';
                    ApplicationArea = All;
                }
                field("Version Revision"; Rec."Version Revision")
                {
                    ToolTip = 'Specifies the version revision of the app.';
                    ApplicationArea = All;
                }
                field("System ID"; Rec."System ID")
                {
                    ToolTip = 'Specifies the system ID of the app.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
