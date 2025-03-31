page 99039 PTEDsTableFieldAddTarget
{
    ApplicationArea = All;
    Caption = 'Dataset Table Field Additional Targets';
    PageType = List;
    SourceTable = PTEMigrDsTableFieldAddTarget;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Migration Dataset Code"; Rec."Migration Dataset Code")
                {
                    ToolTip = 'Specifies the value of the Migration Dataset Code field.';
                    Visible = false;
                }
                field("Source table name"; Rec."Source table name")
                {
                    ToolTip = 'Specifies the value of the Source table name field.';
                    Visible = false;
                }
                field("Source Field Name"; Rec."Source Field Name")
                {
                    ToolTip = 'Specifies the value of the Source Field Name field.';
                    Visible = false;
                }
                field("Target SQL Database Code"; Rec."Target SQL Database Code")
                {
                    ToolTip = 'Specifies the value of the Target SQL Database Code field.';
                    Visible = false;
                }
                field("Target table name"; Rec."Target table name")
                {
                    ToolTip = 'Specifies the value of the Target table name field.';
                    Visible = false;
                }
                field("Target Field Name"; Rec."Target Field Name")
                {
                    ToolTip = 'Specifies the value of the Target Field Name field.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Options Mapping")
            {
                ApplicationArea = All;
                ToolTip = 'Show dataset field Options';
                Image = ValidateEmailLoggingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page PTEMigrDsTableFieldAddTarOps;
                RunPageLink = "Migration Dataset Code" = field("Migration Dataset Code"), "Source table name" = field("Source table name"), "Source Field Name" = field("Source Field Name"), "Target Field Name" = field("Target Field Name");
            }
        }
    }
}
