page 99032 "PTE App. Metadata Set List"
{
    ApplicationArea = All;
    Caption = 'Application Metadata Set List';
    PageType = List;
    SourceTable = "PTE App. Metadata Set";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Code of the metadata set.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Description of the metadata set.';
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Import Metadata Set")
            {
                ToolTip = 'Import Metadata Set';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Rec.ImportMetadataSetFromFile();
                end;
            }
            action("Objects")
            {
                ToolTip = 'Show objects list';
                Image = List;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "PTE App. Metadata Set Objects";
                RunPageLink = "App. Metadata Set Code" = Field("Code");
                RunPageMode = View;
                ApplicationArea = All;
            }
        }
        area(Navigation)
        {
            action("Get Export CU for NAV 2009")
            {
                ToolTip = 'Get NAV 2009 Metadata Export CU';
                Image = ExportAttachment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                var
                    GetExportCodeunitFile: Codeunit "PTE Get Export Codeunit File";
                begin
                    GetExportCodeunitFile.GetCUForNAV2009();
                end;
            }
        }
    }
}
