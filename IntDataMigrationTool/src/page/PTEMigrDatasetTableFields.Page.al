page 99014 "PTE Migr.Dataset Table Fields"
{
    Caption = 'Migration Dataset Table Fields';
    PageType = List;
    SourceTable = "PTE Migr. Dataset Table Field";
    UsageCategory = None;
    DataCaptionFields = "Migration Dataset Code", "Source SQL Database Code", "Target SQL Database Code", "Source Table Name", "Target table name";
    DataCaptionExpression = GetCaption();
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Migration Dataset Code"; Rec."Migration Dataset Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the Migration Dataset.';
                    Visible = false;
                    editable = false;
                    StyleExpr = StyleOption;
                }
                field("Source SQL Database Code"; Rec."Source SQL Database Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the Source SQL Database.';
                    Visible = false;
                    editable = false;
                    StyleExpr = StyleOption;
                }
                field("Source Table Name"; Rec."Source Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the source table.';
                    Visible = false;
                    editable = false;
                    StyleExpr = StyleOption;
                }
                field("Mapping Type"; Rec."Mapping Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mapping Type field.';
                    StyleExpr = StyleOption;
                }
                field("Source Field Name"; Rec."Source Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the source field.';
                    StyleExpr = StyleOption;
                }
                field("Source Field Data Type"; Rec."Source Field Data Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Data Type of the source field.';
                    StyleExpr = StyleOption;
                }
                field("Target SQL Database Code"; Rec."Target SQL Database Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the target SQL database.';
                    Visible = false;
                    editable = false;
                    StyleExpr = StyleOption;
                }
                field("Target Table Name"; Rec."Target Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the target table.';
                    Visible = false;
                    editable = false;
                    StyleExpr = StyleOption;
                }
                field("Target Field name"; Rec."Target Field name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the target field.';
                    StyleExpr = StyleOption;
                    Editable = not Rec."Skip in Mapping";
                }
                field("Target Field Data Type"; Rec."Target Field Data Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Data Type of the target field.';
                    StyleExpr = StyleOption;
                }
                field("No. of Target Field Proposals"; Rec."No. of Target Field Proposals")
                {
                    ToolTip = 'Specifies the number of proposed target fields.';
                    Editable = false;
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    var
                        PTEPropositionFieldsMapping: Record "PTEMigrDataTableFieldProposal";
                        PTEMigrDataTblFieldProp: Page "PTE Migr. Data Tbl Field Prop";
                    begin
                        PTEPropositionFieldsMapping.SetRange("Migration Dataset Code", Rec."Migration Dataset Code");
                        PTEPropositionFieldsMapping.SetRange("Source table name", Rec."Source table name");
                        PTEPropositionFieldsMapping.SetRange("Source Field Name", Rec."Source Field Name");
                        if PTEPropositionFieldsMapping.FindSet() then begin
                            PTEMigrDataTblFieldProp.SetTableView(PTEPropositionFieldsMapping);
                            PTEMigrDataTblFieldProp.LookupMode(true);
                            PTEMigrDataTblFieldProp.Editable(false);
                            if PTEMigrDataTblFieldProp.RunModal() = Action::LookupOK then begin
                                PTEMigrDataTblFieldProp.GetRecord(PTEPropositionFieldsMapping);
                                Rec.Validate("Target Field name", PTEPropositionFieldsMapping."Target Field Name Proposal");
                            end;
                        end;
                    end;
                }
                field("Is Empty"; Rec."Is Empty")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the field is empty in source database.';
                    StyleExpr = StyleOption;
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        PTEMigrDsTblFldEmptyCount: Record PTEMigrDsTblFldEmptyCount;
                        PTEMigrDsTblFldEmptyCountPage: Page PTEMigrDsTblFldEmptyCount;
                    begin
                        PTEMigrDsTblFldEmptyCount.SetRange("Migration Dataset Code", Rec."Migration Dataset Code");
                        PTEMigrDsTblFldEmptyCount.SetRange("Source table name", Rec."Source table name");
                        PTEMigrDsTblFldEmptyCount.SetRange("Source Field Name", Rec."Source Field Name");
                        if PTEMigrDsTblFldEmptyCount.FindSet() then begin
                            PTEMigrDsTblFldEmptyCountPage.SetTableView(PTEMigrDsTblFldEmptyCount);
                            PTEMigrDsTblFldEmptyCountPage.Editable(false);
                            PTEMigrDsTblFldEmptyCountPage.RunModal();
                        end;
                    end;

                }
                field("Number of Errors"; Rec."Number of Errors")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of detected errors, which could break the migration.';
                    StyleExpr = StyleOption;
                }
                field("Number of Warnings"; Rec."Number of Warnings")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of detected warnings, which could occur during the migration.';
                    StyleExpr = StyleOption;
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies te Comments.';
                    StyleExpr = StyleOption;
                    Visible = true;
                }
                field("Ignore Errors"; Rec."Ignore Errors")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if errors should be ignored for this field.';
                    StyleExpr = StyleOption;
                }
                field("Skip in Mapping"; Rec."Skip in Mapping")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this field should be skipped during all actions which apply mapping.';
                    StyleExpr = StyleOption;
                }
            }
        }
        area(FactBoxes)
        {
            part(Control17; "PTE Migr. Dataset Err. FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Migration Dataset Code" = field("Migration Dataset Code"),
                              "Source Table Name" = field("Source table name"),
                              "Source Field Name" = field("Source Field Name");
                Editable = false;
            }
            part(Control20; PTEDstTableFieldTargets)
            {
                ApplicationArea = All;
                SubPageLink = "Migration Dataset Code" = field("Migration Dataset Code"),
                                "Source Table Name" = field("Source table name"),
                                "Source Field Name" = field("Source Field Name");
                Editable = false;
            }
            part(Control18; PTEMigrDatasetSourFieldFactBox)
            {
                ApplicationArea = All;
                SubPageLink = "SQL Database Code" = field("Source SQL Database Code"),
                                "Table Name" = field("Source table name"),
                                "SQL Field Name" = field("Source Field Name");
            }
            part(control19; PTEMigrDatasTargetFieldFactBox)
            {
                ApplicationArea = All;
                SubPageLink = "SQL Database Code" = field("Target SQL Database Code"),
                                "Table Name" = field("Target table name"),
                                "SQL Field Name" = field("Target Field Name");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Options Mapping")
            {
                ApplicationArea = All;
                ToolTip = 'Show dataset field Options';
                Image = ValidateEmailLoggingSetup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "PTE Migr. Ds. Tbl. Fld. Option";
                RunPageLink = "Migration Dataset Code" = FIELD("Migration Dataset Code"), "Source table name" = field("Source Table Name"), "Source Field Name" = field("Source Field Name");
                RunPageMode = View;
            }

            action("Get Empty Fields Count")
            {
                ApplicationArea = All;
                ToolTip = 'Get Empty Fields Count';
                Image = SetupColumns;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    PTEChkEmptyFieldCount: Codeunit PTECheckEmptyFieldCount;
                begin
                    PTEChkEmptyFieldCount.Run(Rec)
                end;
            }

            action("Additional Target Fields")
            {
                ApplicationArea = All;
                ToolTip = 'Additional Target Fields';
                Image = SetupColumns;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec."Target Field name" <> '';
                RunObject = Page PTEDsTableFieldAddTarget;
                RunPageLink = "Migration Dataset Code" = field("Migration Dataset Code"), "Source table name" = field("Source table name"),
                        "Source Field Name" = field("Source Field Name"), "Target SQL Database Code" = field("Target SQL Database Code"),
                        "Target table name" = field("Target table name");
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        StyleOption := 'Standard';
        if Rec."Number of Errors" > 0 then begin
            if not Rec."Ignore Errors" then
                StyleOption := 'Unfavorable'
            else
                StyleOption := 'Attention';
        end else
            if Rec."Number of Warnings" > 0 then
                StyleOption := 'AttentionAccent';
    end;

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields(Rec."No. of Target Field Proposals");
    end;

    var
        StyleOption: Text[20];

    local procedure GetCaption(): Text
    var
        TableLbl: Label ' Table: ';
    begin
        exit(Rec."Migration Dataset Code" + TableLbl + Rec."Source table name")
    end;
}

