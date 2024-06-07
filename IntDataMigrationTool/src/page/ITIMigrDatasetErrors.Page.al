page 99026 "ITI Migr. Dataset Errors"
{
    ApplicationArea = All;
    Caption = 'Migration Dataset Errors';
    PageType = List;
    SourceTable = "ITI Migr. Dataset Error";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Migration Dataset Code"; Rec."Migration Dataset Code")
                {
                    ToolTip = 'Specifies the code of the Migration Dataset.';
                    StyleExpr = StyleOption;
                    ApplicationArea = All;
                }
                field("Source Table Name"; Rec."Source Table Name")
                {
                    ToolTip = 'Specifies the name of the Source Table.';
                    StyleExpr = StyleOption;
                    ApplicationArea = All;
                }
                field("Source Field Name"; Rec."Source Field Name")
                {
                    ToolTip = 'Specifies the name of the Source Field.';
                    StyleExpr = StyleOption;
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the Entry No.';
                    StyleExpr = StyleOption;
                    ApplicationArea = All;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ToolTip = 'Specifies the Error Message.';
                    StyleExpr = StyleOption;
                    ApplicationArea = All;
                }
                field("Error Type"; Rec."Error Type")
                {
                    ToolTip = 'Specifies the Error Type.';
                    StyleExpr = StyleOption;
                    ApplicationArea = All;
                }
                field("Source Obsolete State"; Rec."Source Obsolete State")
                {
                    ToolTip = 'Specifies the Source Obsolete State.';
                    StyleExpr = StyleOption;
                    ApplicationArea = All;
                }
                field("Source Obsolete Reason"; Rec."Source Obsolete Reason")
                {
                    ToolTip = 'Specifies the Source Obsolete Reason.';
                    StyleExpr = StyleOption;
                    ApplicationArea = All;
                }
                field("Target Obsolete State"; Rec."Target Obsolete State")
                {
                    ToolTip = 'Specifies the Target Obsolete State.';
                    StyleExpr = StyleOption;
                    ApplicationArea = All;
                }
                field("Target Obsolete Reason"; Rec."target Obsolete Reason")
                {
                    ToolTip = 'Specifies the target Obsolete Reason.';
                    StyleExpr = StyleOption;
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StyleOption := 'Standard';
        if Rec."Error Type" = Rec."Error Type"::Error then
            StyleOption := 'Unfavorable';
        if Rec."Error Type" = Rec."Error Type"::Warning then
            StyleOption := 'Ambiguous';
    end;

    var
        StyleOption: Text[20];
}
