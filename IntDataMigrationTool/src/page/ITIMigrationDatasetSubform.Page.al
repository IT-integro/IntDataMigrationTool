page 99004 "ITI Migration Dataset Subform"
{
    ApplicationArea = All;
    Caption = 'Migration Dataset Tables';
    PageType = ListPart;
    SourceTable = "ITI Migration Dataset Table";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Source Table Name"; Rec."Source Table Name")
                {
                    ToolTip = 'Specifies the Table Name from which source data will be taken.';
                    StyleExpr = StyleOption;
                    ApplicationArea = All;
                }
                field("Target table name"; Rec."Target table name")
                {
                    ToolTip = 'Specifies the Table Name to which source data will be migrated.';
                    StyleExpr = StyleOption;
                    ApplicationArea = All;
                    Editable = not Rec."Skip in Mapping";
                }
                field("Description"; Rec.Description)
                {
                    ToolTip = 'Add description or notes for field.';
                    StyleExpr = StyleOption;
                    ApplicationArea = All;
                }
                field("Skip in Mapping"; Rec."Skip in Mapping")
                {
                    ApplicationArea = All;
                    ToolTip = 'Skip field in Mapping, so no value will be assigned to it.';
                    StyleExpr = StyleOption;
                }
                field("Number of Errors"; Rec."Number of Errors")
                {
                    ToolTip = 'Specifies number of errors in this table, which could break the migration.';
                    StyleExpr = StyleOption;
                    ApplicationArea = All;
                }
                field("Number of Warnings"; Rec."Number of Warnings")
                {
                    ToolTip = 'Specifies number of warnings in this table, which may occur during the migration.';
                    StyleExpr = StyleOption;
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Fields")
            {
                ToolTip = 'Show dataset table fields';
                Image = SelectField;
                ApplicationArea = All;
                trigger OnAction()
                var
                    ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field";
                    ITIFieldsMappingProposition: Codeunit ITIFieldsMappingProposition;
                    ITIMigrDatasetTableFields: Page "ITI Migr.Dataset Table Fields";
                begin
                    ITIFieldsMappingProposition.ProposeFieldsMapping(Rec."Migration Dataset Code", Rec."Source table name", Rec."Target SQL Database Code", Rec."Target table name");
                    ITIMigrDatasetTableField.SetRange("Migration Dataset Code", Rec."Migration Dataset Code");
                    ITIMigrDatasetTableField.SetRange("Source table name", Rec."Source Table Name");
                    if ITIMigrDatasetTableField.FindSet() then
                        ;
                    ITIMigrDatasetTableFields.SetTableView(ITIMigrDatasetTableField);
                    ITIMigrDatasetTableFields.Run();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StyleOption := 'Standard';
        if Rec."Number of Errors" > 0 then
            StyleOption := 'Unfavorable'
        else
            if Rec."Number of Warnings" > 0 then
                StyleOption := 'AttentionAccent';
    end;

    var
        StyleOption: Text[20];
}
