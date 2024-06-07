page 99018 "ITI Migration SQL Query Fields"
{
    ApplicationArea = All;
    Caption = 'Migration SQL Query Fields';
    PageType = List;
    SourceTable = "ITI Migration SQL Query Field";
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
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Source SQL Field Name"; Rec."Source SQL Field Name")
                {
                    ToolTip = 'Specifies the name of the source SQL field.';
                    ApplicationArea = All;
                }
                field("Target SQL Table Name"; Rec."Target SQL Table Name")
                {
                    ToolTip = 'Specifies the name of the target SQL table.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Target SQL Field Name"; Rec."Target SQL Field Name")
                {
                    ToolTip = 'Specifies the name of the target SQL field.';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("Field Options")
            {
                ToolTip = 'Show field options';
                Image = ValidateEmailLoggingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "ITI Migr. SQL Query Field Opt.";
                RunPageLink = "Migration Code" = field("Migration Code"), "Query No." = field("Query No."), "Source SQL Table Name" = field("Source SQL Table Name"), "Source SQL Field Name" = field("Source SQL Field Name"), "Target SQL Table Name" = field("Target SQL Table Name"), "Target SQL Field Name" = field("Target SQL Field Name");
                RunPageMode = View;
                ApplicationArea = All;
            }
        }
    }
}
