page 99020 "PTE Migr. Ds. Tbl. Fld. Option"
{
    ApplicationArea = All;
    Caption = 'Migration Dataset Table Field Options';
    PageType = List;
    SourceTable = "PTE Migr. Ds. Tbl. Fld. Option";
    UsageCategory = None;
    DataCaptionFields = "Migration Dataset Code", "Source SQL Database Code", "Target SQL Database Code", "Source Table Name", "Source Field Name", "Target table name", "Target Field name";
    DataCaptionExpression = GetCaption();
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Migration Dataset Code"; Rec."Migration Dataset Code")
                {
                    ToolTip = 'Specifies the code of the Migration Dataset.';
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Source SQL Database Code"; Rec."Source SQL Database Code")
                {
                    ToolTip = 'Specifies the code of the source SQL database.';
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Source table name"; Rec."Source table name")
                {
                    ToolTip = 'Specifies the name of the source table.';
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Source Field Name"; Rec."Source Field Name")
                {
                    ToolTip = 'Specifies the name of the source field.';
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Source Option ID"; Rec."Source Option ID")
                {
                    ToolTip = 'Specifies the ID of the source option.';
                    ApplicationArea = All;
                }
                field("Source Option Name"; Rec."Source Option Name")
                {
                    ToolTip = 'Specifies the name of the source option.';
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Target SQL Database Code"; Rec."Target SQL Database Code")
                {
                    ToolTip = 'Specifies the code of the target SQL database.';
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Target table name"; Rec."Target table name")
                {
                    ToolTip = 'Specifies the name of the target table.';
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Target Field name"; Rec."Target Field name")
                {
                    ToolTip = 'Specifies the name of the target field.';
                    Visible = false;
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Target Option ID"; Rec."Target Option ID")
                {
                    ToolTip = 'Specifies the ID of the target option.';
                    ApplicationArea = All;
                }
                field("Target Option Name"; Rec."Target Option Name")
                {
                    ToolTip = 'Specifies the name of the target option.';
                    Editable = false;
                    ApplicationArea = All;
                }
            }
        }
    }
    local procedure GetCaption(): Text
    var
        TableLbl: Label ' Table: ';
    begin
        exit(Rec."Migration Dataset Code" + TableLbl + Rec."Source table name")
    end;
}
