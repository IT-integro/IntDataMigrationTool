page 99047 "PTE Migr. Field Sum"
{
    ApplicationArea = all;
    Caption = 'PTE Migr. Field Sum';
    PageType = List;
    SourceTable = "PTE Migr. Field Sum";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Migration Code"; Rec."Migration Code")
                {
                    ToolTip = 'Specifies the value of the Migration Code field.', Comment = '%';
                    Visible = false;
                }
                field("No Of Rec. Entry No"; Rec."No Of Rec. Entry No")
                {
                    ToolTip = 'Specifies the value of the No Of Rec. Entry No field.', Comment = '%';
                    Visible = false;
                }
                field("Entry No"; Rec."Entry No")
                {
                    ToolTip = 'Specifies the value of the Entry No field.', Comment = '%';
                    Visible = false;
                }
                field("Source Table Name"; Rec."Source Table Name")
                {
                    ToolTip = 'Specifies the value of the Source Table Name field.', Comment = '%';
                }
                field("Source Field Name"; Rec."Source Field Name")
                {
                    ToolTip = 'Specifies the value of the Source Field Name field.', Comment = '%';
                }
                field("Target Table Name"; Rec."Target Table Name")
                {
                    ToolTip = 'Specifies the value of the Target Table Name field.', Comment = '%';
                }
                field("Target Field Name"; Rec."Target Field Name")
                {
                    ToolTip = 'Specifies the value of the Target Field Name field.', Comment = '%';
                }
                field("Source Sum Value"; Rec."Source Sum Value")
                {
                    ToolTip = 'Specifies the value of the Source Sum Value field.', Comment = '%';
                }
                field("Target Sum Value"; Rec."Target Sum Value")
                {
                    ToolTip = 'Specifies the value of the Target Sum Value field.', Comment = '%';
                }
                field(Difference; Rec.Difference)
                {
                    ToolTip = 'Specifies the value of the Difference field.', Comment = '%';
                }
            }
        }
    }
}
