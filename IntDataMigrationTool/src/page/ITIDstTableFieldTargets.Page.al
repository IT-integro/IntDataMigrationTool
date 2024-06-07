page 99043 ITIDstTableFieldTargets
{
    ApplicationArea = All;
    Caption = 'Dataset Table Field Additional Targets';
    PageType = ListPart;
    SourceTable = ITIMigrDsTableFieldAddTarget;
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
}
