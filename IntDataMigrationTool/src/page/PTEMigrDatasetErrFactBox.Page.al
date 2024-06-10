page 99027 "PTE Migr. Dataset Err. FactBox"
{
    ApplicationArea = All;
    Caption = 'PTE Migr. Dataset Err. FactBox';
    PageType = ListPart;
    SourceTable = "PTE Migr. Dataset Error";
    ShowFilter = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Error Type"; Rec."Error Type")
                {
                    ToolTip = 'Specifies the type of the error.';
                    ApplicationArea = All;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ToolTip = 'Specifies the Error Message.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
