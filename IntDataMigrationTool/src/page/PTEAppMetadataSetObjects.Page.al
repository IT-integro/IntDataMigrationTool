page 99033 "PTE App. Metadata Set Objects"
{
    ApplicationArea = All;
    Caption = 'Application Metadata Set Objects';
    PageType = List;
    SourceTable = "PTE App. Metadata Set Object";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("App. Metadata Set Code"; Rec."App. Metadata Set Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Code of the metadata set.';
                }
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of object.';
                }
                field("Object Subtype"; Rec."Object Subtype")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the subtype of object.';
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of a given object.';
                }
                field("Package ID"; Rec."Package ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Package ID of a give object.';
                }
                field("Data Per Company"; Rec."Data Per Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this object holds different data for each company.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
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
