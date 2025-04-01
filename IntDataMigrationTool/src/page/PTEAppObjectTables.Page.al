page 99010 "PTE App. Object Tables"
{
    //ApplicationArea = All;
    Caption = 'Application Object Tables';
    PageType = List;
    SourceTable = "PTE App. Object Table";
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
                field("ID"; Rec."ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the table.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Name of the table.';
                }
                field(TableType; Rec.TableType)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the table.';
                }
                field(Access; Rec.Access)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Access property of the table.';
                }
                field(CompressionType; Rec.CompressionType)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the compression type of the table.';
                }
                field("DataClassification"; Rec."DataClassification")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the DataClassification property of the table.';
                }
                field(DataPerCompany; Rec.DataPerCompany)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the DataPerCompany property of the table.';
                }
                field(Extensible; Rec.Extensible)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Extensible property of the table.';
                }
                field(LinkedObject; Rec.LinkedObject)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the LinkedObject property of the table.';
                }
                field(PasteIsValid; Rec.PasteIsValid)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PasteIsValid property of the table.';
                }
                field(ReplicateData; Rec.ReplicateData)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ReplicateData property of the table.';
                }
                field(SourceAppId; Rec.SourceAppId)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source app ID of the table.';
                }
                field(SourceExtensionType; Rec.SourceExtensionType)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source extension type of the table.';
                }
                field(ObsoleteState; Rec.ObsoleteState)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ObsoleteState property of the table.';
                }
                field(ObsoleteReason; Rec.ObsoleteReason)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ObsoleteReason property of the table.';
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Fields")
            {
                ApplicationArea = All;
                ToolTip = 'Show table fields';
                Image = SelectField;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "PTE App. Object Table Fields";
                RunPageLink = "SQL Database Code" = FIELD("SQL Database Code"), "Table ID" = FIELD("ID");
                RunPageMode = View;
            }
        }
    }
}
