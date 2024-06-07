page 99002 "ITI App. Object Enum Values"
{
    ApplicationArea = All;
    Caption = 'Application Object Enum Values';
    PageType = List;
    SourceTable = "ITI App. Object Enum Value";
    UsageCategory = None;
    DataCaptionFields = "SQL Database Code";
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("SQL Database Code"; Rec."SQL Database Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the SQL Database.';
                    Visible = false;
                }
                field("Enum ID"; Rec."Enum ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the Enum represented by this object.';
                }
                field(Ordinal; Rec.Ordinal)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies ordinal of Enum value represented by object.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Name of the Enum value.';
                }
            }
        }
    }
}
