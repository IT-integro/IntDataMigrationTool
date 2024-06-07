page 99044 ITIMappingAddTargetFields
{
    ApplicationArea = All;
    Caption = 'ITIMappingAddTargetFields';
    PageType = List;
    SourceTable = ITIMappingAddTargetField;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Mapping Code"; Rec."Mapping Code")
                {
                    ToolTip = 'Specifies the value of the Mapping Code field.';
                    Visible = false;
                }
                field("Source Table Name"; Rec."Source Table Name")
                {
                    ToolTip = 'Specifies the value of the Source Table Name field.';
                    Visible = false;
                }
                field("Source Field Name"; Rec."Source Field Name")
                {
                    ToolTip = 'Specifies the value of the Source Field Name field.';
                    Visible = false;
                }
                field("Additional Target Field"; Rec."Additional Target Field")
                {
                    ToolTip = 'Specifies the value of the Additional Target Field field.';
                }
                field("Target Table Name"; Rec."Target Table Name")
                {
                    ToolTip = 'Specifies the value of the Target Table Name field.';
                    Visible = false;
                }
            }
        }
    }
}
