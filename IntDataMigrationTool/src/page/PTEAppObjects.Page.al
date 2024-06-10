page 99009 "PTE App. Objects"
{
    //ApplicationArea = All;
    Caption = 'Application Objects';
    PageType = List;
    SourceTable = "PTE App. Object";
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
                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the Object.';
                }
                field("Subtype"; Rec."Subtype")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the subtype of the Object.';
                }
                field("ID"; Rec."ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the Object.';
                }
                field("Source"; Rec."Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source of the object.';
                }
                field("Package ID"; Rec."Package ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Package ID of the object.';
                }
                field("Runtime Package ID"; Rec."Runtime Package ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Runtime Package ID of the object.';
                }
            }
        }
    }
    actions
    {
        area(creation)
        {
            action("Download Object Metadata")
            {
                ToolTip = 'Download object metadata to XML file';
                Image = "1099Form";
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Rec.DownloadMetadata();
                end;
            }
        }
    }
}
