page 99024 "ITI Mapping Table Fields"
{
    ApplicationArea = All;
    Caption = 'Mapping Table Fields';
    PageType = List;
    SourceTable = "ITI Mapping Table Field";
    UsageCategory = None;
    DataCaptionFields = "Mapping Code", "Source Table Name", "Target Table Name";
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
                }
            }
        }

    }
    actions
    {
        area(Navigation)
        {
            action("Field options")
            {
                ToolTip = 'Show mapping table field Options';
                Image = Line;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "ITI Mapping Table Field Option";
                RunPageLink = "Mapping Code" = field("Mapping Code"), "Source Table Name" = field("Source Table Name"), "Source Field Name" = field("Source Field Name"), "Target Table Name" = field("Target Table Name"), "Target Field Name" = field("Target Field Name");
                RunPageMode = View;
                ApplicationArea = All;
            }
            action("Additional Target Field")
            {
                ToolTip = 'Show mapping table Additional Target Field';
                Image = Table;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page ITIMappingAddTargetFields;
                RunPageLink = "Mapping Code" = field("Mapping Code"), "Source Table Name" = field("Source Table Name"), "Source Field Name" = field("Source Field Name"), "Target Table Name" = field("Target Table Name");
                RunPageMode = View;
                ApplicationArea = All;
            }
        }
    }
}
