page 99045 "ITI Migr. Data Tbl Field Prop"
{
    ApplicationArea = All;
    Caption = 'Migration Data Table Field Proposal';
    PageType = List;
    SourceTable = "ITIMigrDataTableFieldProposal";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Migration Dataset Code"; Rec."Migration Dataset Code")
                {
                    ToolTip = 'Specifies the Migration Dataset Code.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Source Table Name"; Rec."Source Table Name")
                {
                    ToolTip = 'Specifies the name of the source Table.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Source Field Name"; Rec."Source Field Name")
                {
                    ToolTip = 'Specifies the name of the source Field.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Proposition Target Field Name"; Rec."Target Field Name Proposal")
                {
                    ToolTip = 'Specifies the name of the proposed target Field.';
                    ApplicationArea = All;
                }
                field("Proposition Target Field No."; Rec."Target Field No. Proposal")
                {
                    ToolTip = 'Specifies the number of the proposed target Field.';
                    ApplicationArea = All;
                }
                field("Field Data Type"; Rec."Field Data Type")
                {
                    ToolTip = 'Specifies the fields data type.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
