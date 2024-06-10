page 99003 "PTE Migration Dataset List"
{
    ApplicationArea = All;
    Caption = 'Migration Dataset List';
    PageType = List;
    SourceTable = "PTE Migration Dataset";
    Editable = false;
    UsageCategory = Administration;
    CardPageId = "PTE Migration Dataset Card";
    DataCaptionFields = "Code", "Source SQL Database Code", "Target SQL Database Code";
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the code of the migration dataset.';
                    ApplicationArea = All;
                }
                field("Source SQL Database Code"; Rec."Source SQL Database Code")
                {
                    ToolTip = 'Specifies the code of the Source SQL Database.';
                    ApplicationArea = All;
                }
                field("Target SQL Database Code"; Rec."Target SQL Database Code")
                {
                    ToolTip = 'Specifies the code of the Target SQL Database.';
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Add description or notes for dataset.';
                    ApplicationArea = All;

                }
            }
        }
    }
}
