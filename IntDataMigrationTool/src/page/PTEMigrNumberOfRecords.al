page 99046 "PTE Migr. Number Of Records"
{
    ApplicationArea = All;
    Caption = 'Migration Number Of Records';
    PageType = List;
    SourceTable = "PTE Migr. Number Of Records";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(Content)
        {
            field(MigratedRecords; Comment)
            {
                Caption = '';
                MultiLine = true;
            }
            repeater(General)
            {
                field("Migration Code"; Rec."Migration Code")
                {
                    ToolTip = 'Specifies the value of the Migration Code field.';
                }
                field("Source Table Name"; Rec."Source Table Name")
                {
                    ToolTip = 'Specifies the value of the Source Table Name field.';
                }
                field("Target Table Name"; Rec."Target Table Name")
                {
                    ToolTip = 'Specifies the value of the Target Table Name field.';
                }
                field("Number of source records"; Rec."Number of source records")
                {
                    ToolTip = 'Specifies the value of the Number of source records field.';
                }
                field("Number of target records"; Rec."Number of target records")
                {
                    ToolTip = 'Specifies the value of the Number of target records field.';
                }
                field(Difference; Rec.Difference)
                {
                    ToolTip = 'Specifies the value of the Difference field.';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        UpdateComment();
    end;

    local procedure UpdateComment()
    var
        PTEMigrNumberOfRecords: Record "PTE Migr. Number Of Records";
        SourceQty: BigInteger;
        TargetQty: BigInteger;
        Difference: BigInteger;
    begin
        PTEMigrNumberOfRecords.CopyFilters(Rec);
        if PTEMigrNumberOfRecords.FindSet() then
            repeat
                SourceQty := SourceQty + PTEMigrNumberOfRecords."Number of source records";
                TargetQty := TargetQty + PTEMigrNumberOfRecords."Number of target records";
            until PTEMigrNumberOfRecords.Next() = 0;
        Difference := SourceQty - TargetQty;
        if Difference = 0 then
            Comment := StrSubstNo(ReportOK, SourceQty)
        else
            Comment := StrSubstNo(ReportNoOK, SourceQty, TargetQty, Difference)
    end;

    var
        ReportOK: Label 'All records have been migrated properly. No difference between Source and Target.\Number of migrated records: %1', Comment = '%1 = Number of records';
        ReportNoOK: Label 'Note. Not all records were migrated.\Number of records in source database: %1,\Number of records in target database: %2.\Difference: %3', Comment = '%1 = Number of records in source database, %2 = Number of records in target database, %3 = Difference';
        Comment: Text;
}
