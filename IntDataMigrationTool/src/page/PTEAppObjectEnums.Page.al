page 99001 "PTE App. Object Enums"
{
    ApplicationArea = All;
    Caption = 'Application Object Enums';
    PageType = List;
    SourceTable = "PTE App. Object Enum";
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
                    ToolTip = 'Specifies the code of a SQL Database Code.';
                    Visible = false;
                }
                field("ID"; Rec."ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of an object.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the objects name.';
                }
                field(Extensible; Rec.Extensible)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this object is extensible';
                }
                field(AssignmentCompatibility; Rec.AssignmentCompatibility)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this object can be assigned to from another Enum type.';
                }
            }
        }
    }
    actions
    {
        area(creation)
        {
            action("Values")
            {
                ToolTip = 'Show enum values';
                Image = SelectField;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                RunObject = Page "PTE App. Object Enum Values";
                RunPageLink = "SQL Database Code" = FIELD("SQL Database Code"), "Enum ID" = FIELD("ID");
                RunPageMode = View;
            }
        }
    }
}
