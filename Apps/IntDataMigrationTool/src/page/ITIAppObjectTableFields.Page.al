page 99011 "ITI App. Object Table Fields"
{
    //ApplicationArea = All;
    Caption = 'Application Object Table Fields';
    PageType = List;
    SourceTable = "ITI App. Object Table Field";
    UsageCategory = None;
    DataCaptionFields = "SQL Database Code", "Table Name";
    DataCaptionExpression = GetCaption();
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
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the table from which this field stems.';
                    Visible = false;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the table from which this field stems.';
                    Visible = false;
                }
                field("ID"; Rec."ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the field represented by the object.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the field represented by the object.';
                }
                field(Datatype; Rec.Datatype)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the datatype of the field represented by the object.';
                }
                field(DataLength; Rec.DataLength)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the length of input which can be held by field represented by the object.';
                }
                field(EnumTypeId; Rec.EnumTypeId)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the Enum which defines values in field represented by the object.';
                }
                field(EnumTypeName; Rec.EnumTypeName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the Enum which defines values in field represented by the object.';
                }
                field("DateFormula"; Rec."DateFormula")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the DateFormula for field represented by the object.';
                }
                field("DataClassification"; Rec."DataClassification")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the DataClassification field for field represented by the object.';
                }
                field(Editable; Rec.Editable)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether field represented by the object is editable.';
                }
                field(ExternalAccess; Rec.ExternalAccess)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ExternalAccess property for the field represented by the object.';
                }
                field("FieldClass"; Rec."FieldClass")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the FieldClass property for the field represented by the object.';
                }
                field(InitValue; Rec.InitValue)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the InitValue property for the field represented by the object.';
                }
                field(IsExtension; Rec.IsExtension)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether field represented by the object is an extension.';
                }
                field("Key"; Rec."Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether field represented by the object is a part of a key.';
                }
                field(NotBlank; Rec.NotBlank)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NotBlank property for the field represented by the object.';
                }
                field(Numeric; Rec.Numeric)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Numeric property for the field represented by the object.';
                }
                field(ValidateTableRelation; Rec.ValidateTableRelation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ValidateTableRelation property for the field represented by the object.';
                }
                field(SourceExtensionType; Rec.SourceExtensionType)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of source extension for the field represented by the object.';
                }
                field(SourceAppId; Rec."App ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Source App ID for the field represented by the object.';
                }
                field(Access; Rec.Access)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Access property for the field represented by the object.';
                }
                field(ObsoleteState; Rec.ObsoleteState)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ObsoleteState property for the field represented by the object.';
                }
                field(ObsoleteReason; Rec.ObsoleteReason)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ObsoleteReason property for the field represented by the object.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled property for the field represented by the object.';
                }
                field("SQL Table Name"; Rec."SQL Table Name Excl. C. Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SQL Table Name field.';
                }
                field("SQL Field Name"; Rec."SQL Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the SQL Field Name field.';
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Field Options")
            {
                ApplicationArea = All;
                ToolTip = 'Show field options';
                Image = SelectField;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "ITI App. Object Tbl.Field Opt.";
                RunPageLink = "SQL Database Code" = FIELD("SQL Database Code"), "Table ID" = FIELD("Table ID"), "Field ID" = field("ID");
                RunPageMode = View;
            }
        }
    }

    local procedure GetCaption(): Text
    var
        TableLbl: Label ' Table: ';
    begin
        exit(Rec."SQL Database Code" + TableLbl + Rec."SQL Table Name Excl. C. Name")
    end;
}
