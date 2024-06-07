page 99027 "ITI Migr. Dataset Err. FactBox"
{
    ApplicationArea = All;
    Caption = 'ITI Migr. Dataset Err. FactBox';
    PageType = ListPart;
    SourceTable = "ITI Migr. Dataset Error";
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
