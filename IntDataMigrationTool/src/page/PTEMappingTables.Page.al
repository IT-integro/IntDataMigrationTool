page 99023 "PTE Mapping Tables"
{
    ApplicationArea = All;
    Caption = 'Mapping Tables';
    PageType = List;
    SourceTable = "PTE Mapping Table";
    UsageCategory = None;
    DataCaptionFields = "Mapping Code";
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
                    ApplicationArea = All;
                }
                field("Target Table Name"; Rec."Target Table Name")
                {
                    ToolTip = 'Specifies the Table Name to which source data will be migrated.';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("Fields")
            {
                ToolTip = 'Show mapping table fields';
                ApplicationArea = All;
                Image = Line;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "PTE Mapping Table Fields";
                RunPageLink = "Mapping Code" = field("Mapping Code"), "Source Table Name" = field("Source Table Name"), "Target Table Name" = field("Target Table Name");
                RunPageMode = View;
            }
        }
    }
}
