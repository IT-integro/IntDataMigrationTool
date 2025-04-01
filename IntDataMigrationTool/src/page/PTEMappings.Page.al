page 99022 "PTE Mappings"
{
    ApplicationArea = All;
    Caption = 'Mappings';
    PageType = List;
    SourceTable = "PTE Mapping";
    UsageCategory = Administration;
    DataCaptionFields = "Code", Description;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Code of the mapping.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Description of the mapping.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Export Mapping")
            {
                ToolTip = 'Export Mapping to the File';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Rec.ExportMapping();
                end;
            }
            action("Import Mapping")
            {
                ToolTip = 'Import Mapping from File';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Rec.ImportMapping();
                end;
            }
        }
        area(Navigation)
        {
            action("Tables")
            {
                ToolTip = 'Show mapping tables';
                Image = Table;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "PTE Mapping Tables";
                RunPageLink = "Mapping Code" = field("Code");
                RunPageMode = View;
                ApplicationArea = All;
            }
        }
    }
}
