page 99021 "ITI Migr. SQL Query Field Opt."
{
    ApplicationArea = All;
    Caption = 'Migration SQL Query Field Options';
    PageType = List;
    SourceTable = "ITI Migr. SQL Query Field Opt.";
    UsageCategory = None;
    DataCaptionFields = "Migration Code", "Query No.", "Source SQL Table Name", "Source SQL Field Name", "Target SQL Table Name", "Target SQL Field Name";
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
                    ToolTip = 'Specifies the name of the source SQL table.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Source SQL Field Name"; Rec."Source SQL Field Name")
                {
                    ToolTip = 'Specifies the name of the source SQL field.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Source SQL Field Option"; Rec."Source SQL Field Option")
                {
                    ToolTip = 'Specifies the name of the source SQL field option.';
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
                    Visible = false;
                }
                field("Target SQL Field Option"; Rec."Target SQL Field Option")
                {
                    ToolTip = 'Specifies the name of the target SQL field option.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
