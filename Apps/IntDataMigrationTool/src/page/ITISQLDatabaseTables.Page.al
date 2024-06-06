page 99007 "ITI SQL Database Tables"
{
    //ApplicationArea = All;
    Caption = 'SQL Database Tables';
    PageType = List;
    SourceTable = "ITI SQL Database Table";
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
                field("Table Catalog"; Rec."Table Catalog")
                {
                    ToolTip = 'Specifies the table catalog used for the SQL table.';
                    ApplicationArea = All;
                }
                field("Table Schema"; Rec."Table Schema")
                {
                    ToolTip = 'Specifies the Table Schema of the SQL table.';
                    ApplicationArea = All;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ToolTip = 'Specifies the name of the Table.';
                    ApplicationArea = All;
                }
                field("Table Type"; Rec."Table Type")
                {
                    ToolTip = 'Specifies the type of the table.';
                    ApplicationArea = All;
                }
                field("Number Of Records"; Rec."Number Of Records")
                {
                    ToolTip = 'Specifies the number of records in SQL table.';
                    ApplicationArea = All;
                }
                field("App ID"; Rec."App ID")
                {
                    ToolTip = 'Specifies the ID of the app.';
                    ApplicationArea = All;
                }
                field("App Name"; Rec."App Name")
                {
                    ToolTip = 'Specifies the name of the app.';
                    ApplicationArea = All;
                }
                field("App Publisher"; Rec."App Publisher")
                {
                    ToolTip = 'Specifies the publisher of the app.';
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the entry number.';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Table Fields")
            {
                ToolTip = 'Show table fields';
                ApplicationArea = All;
                Image = SelectField;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "ITI SQL Database Table Fields";
                RunPageLink = "SQL Database Code" = field("SQL Database Code"), "Table Catalog" = field("Table Catalog"), "Table Name" = field("Table Name");
                RunPageMode = View;
            }
        }
    }
}
