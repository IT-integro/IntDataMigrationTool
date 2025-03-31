page 99012 "PTE App. Object Tbl.Field Opt."
{
    //ApplicationArea = All;
    Caption = 'Application Object Table Field Options';
    PageType = List;
    SourceTable = "PTE App. Object Tbl.Field Opt.";
    UsageCategory = None;
    DataCaptionFields = "SQL Database Code", "Table Name", "Field Name";
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("SQL Database Code"; Rec."SQL Database Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the SQL database.';
                    Visible = false;
                }
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the Table to which option is connected.';
                }
                field("Field ID"; Rec."Field ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Field ID of the Field to which option is connected.';
                    Visible = false;
                }
                field("Option ID"; Rec."Option ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the option.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Name of the option.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Table to which option is connected.';
                    visible = false;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Field to which option is connected.';
                    Visible = false;
                }
            }
        }
    }
}
