page 99042 PTEMigrDsTableFieldAddTarOps
{
    ApplicationArea = All;
    Caption = 'Migration Dataset Table Field Additional Target Options';
    PageType = List;
    SourceTable = PTEMigrDsTableFieldAddTarOpti;
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
                field("Source Option ID"; Rec."Source Option ID")
                {
                    ToolTip = 'Specifies the value of the Source Option ID field.';
                }
                field("Source Option Name"; Rec."Source Option Name")
                {
                    ToolTip = 'Specifies the value of the Source Option ID field.';
                }
                field("Target Table Name"; Rec."Target Table Name")
                {
                    ToolTip = 'Specifies the value of the Target Table Name field.';
                    Visible = false;
                }
                field("Target Field Name"; Rec."Target Field Name")
                {
                    ToolTip = 'Specifies the value of the Target Field Name field.';
                    Visible = false;
                }
                field("Target Option ID"; Rec."Target Option ID")
                {
                    ToolTip = 'Specifies the value of the Target Option ID field.';
                }
                field("Target Option Name"; Rec."Target Option Name")
                {
                    ToolTip = 'Specifies the value of the Target Option Name field.';
                }
            }
        }
    }
}
