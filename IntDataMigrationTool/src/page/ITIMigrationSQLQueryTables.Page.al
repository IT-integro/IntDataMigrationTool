page 99019 "ITI Migration SQL Query Tables"
{
    ApplicationArea = All;
    Caption = 'Migration SQL Query Tables';
    PageType = List;
    SourceTable = "ITI Migration SQL Query Table";
    UsageCategory = None;
    DataCaptionFields = "Migration Code", "Query No.", "Source SQL Table Name", "Target SQL Table Name";
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Migration Code"; Rec."Migration Code")
                {
                    ToolTip = 'Specifies the code of the Migration.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Query No."; Rec."Query No.")
                {
                    ToolTip = 'Specifies the number of the Query.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Source SQL Table Name"; Rec."Source SQL Table Name")
                {
                    ToolTip = 'Specifies the name of the source SQL Table.';
                    ApplicationArea = All;
                }
                field("Target SQL Table Name"; Rec."Target SQL Table Name")
                {
                    ToolTip = 'Specifies the name of the target SQL Table.';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("Table Fields")
            {
                ToolTip = 'Show table fields';
                ApplicationArea = All;
                Image = SelectField;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "ITI Migration SQL Query Fields";
                RunPageLink = "Migration Code" = field("Migration Code"), "Query No." = field("Query No."), "Source SQL Table Name" = field("Source SQL Table Name"), "Target SQL Table Name" = field("Target SQL Table Name");
                RunPageMode = View;
            }
        }
    }
}
