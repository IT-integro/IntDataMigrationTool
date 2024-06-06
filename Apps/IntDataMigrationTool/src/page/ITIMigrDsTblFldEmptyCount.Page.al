page 99036 ITIMigrDsTblFldEmptyCount
{
    PageType = List;
    SourceTable = ITIMigrDsTblFldEmptyCount;
    Editable = false;
    UsageCategory = None;
    Caption = 'Migration Dataset Table Empty Fields Count';
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies company.';
                }
                field("Empty Fields Count"; Rec."Empty Fields Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies count of empty fields in database for certain company.';
                }
                field("Records Count"; Rec."Records Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies count of records in database.';
                }
            }
        }
    }
}