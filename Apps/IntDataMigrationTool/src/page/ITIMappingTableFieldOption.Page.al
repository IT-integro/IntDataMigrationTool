page 99025 "ITI Mapping Table Field Option"
{
    ApplicationArea = All;
    Caption = 'Mapping Table Fields Options';
    PageType = List;
    SourceTable = "ITI Mapping Table Field Option";
    UsageCategory = None;
    DataCaptionFields = "Mapping Code", "Source Table Name", "Source Field Name", "Target Table Name", "Target Field Name";
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Mapping Code"; Rec."Mapping Code")
                {
                    ToolTip = 'Specifies the code of the mapping.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Source Table Name"; Rec."Source Table Name")
                {
                    ToolTip = 'Specifies the Table Name from which source data will be taken.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Source Field Name"; Rec."Source Field Name")
                {
                    ToolTip = 'Specifies the Field Name from which source data will be taken.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Source Field Option"; Rec."Source Field Option")
                {
                    ToolTip = 'Specifies the Option Name from will serve as source data.';
                    ApplicationArea = All;
                }
                field("Target Table Name"; Rec."Target Table Name")
                {
                    ToolTip = 'Specifies the Table Name to which source data will be migrated.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Target Field Name"; Rec."Target Field Name")
                {
                    ToolTip = 'Specifies the Field Name to which source data will be migrated.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Target Field Option"; Rec."Target Field Option")
                {
                    ToolTip = 'Specifies the Option Name to which source data will be migrated.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
