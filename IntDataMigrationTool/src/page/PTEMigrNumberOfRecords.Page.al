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
                field("No of Incorrect Sums"; Rec."No of Incorrect Sums")
                {
                    ToolTip = 'Specifies the number of decimal fields in the table with differences in sums.';
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
        CountDifference: BigInteger;
        SumDifference: Decimal;
        Migration: Record "PTE Migration";
        MigrFieldSum: Record "PTE Migr. Field Sum";
        IncorrectFieldsDetails: Text;
    begin
        PTEMigrNumberOfRecords.CopyFilters(Rec);
        if PTEMigrNumberOfRecords.FindFirst() then
            Migration.Get(PTEMigrNumberOfRecords."Migration Code");
        if PTEMigrNumberOfRecords.FindSet() then
            repeat
                SourceQty := SourceQty + PTEMigrNumberOfRecords."Number of source records";
                TargetQty := TargetQty + PTEMigrNumberOfRecords."Number of target records";
                if Migration."Check Sums In Record Counting" then begin
                    MigrFieldSum.SetRange("Migration Code", PTEMigrNumberOfRecords."Migration Code");
                    MigrFieldSum.SetRange("No Of Rec. Entry No", PTEMigrNumberOfRecords."Entry No");
                    if MigrFieldSum.FindSet() then
                        repeat
                            if MigrFieldSum."Source Sum Value" <> MigrFieldSum."Target Sum Value" then
                                IncorrectFieldsDetails := IncorrectFieldsDetails + StrSubstNo('%1.%2; ', MigrFieldSum."Source Table Name", MigrFieldSum."Source Field Name");
                        until MigrFieldSum.Next() = 0

                end;
            until PTEMigrNumberOfRecords.Next() = 0;
        CountDifference := SourceQty - TargetQty;
        if CountDifference = 0 then
            Comment := StrSubstNo(ReportOK, SourceQty)
        else begin
            Comment := Comment + ReportNotOK1 + '\';
            Comment := Comment + StrSubstNo(ReportNotOK2, SourceQty, TargetQty, CountDifference)
        end;
        if IncorrectFieldsDetails <> '' then
            Comment := Comment + '\' + StrSubstNo(ReportNotOK3, IncorrectFieldsDetails);

    end;

    var
        ReportOK: Label 'All records have been migrated properly. No difference between Source and Target.\Number of migrated records: %1', Comment = '%1 = Number of records';
        ReportNotOK1: Label 'Note. Not all records were migrated.';
        ReportNotOK2: label 'Number of records in source database: %1,\Number of records in target database: %2.\Difference: %3', Comment = '%1 = Number of records in source database, %2 = Number of records in target database, %3 = Difference';
        ReportNotOK3: label 'Sum of decimal fields in tables below are different in source and target database.\%1', Comment = '%1 = List of incorrect fields';
        Comment: Text;
}
