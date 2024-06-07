page 99040 "ITIMigrDatasetSourFieldFactBox"
{
    ApplicationArea = All;
    Caption = 'Source field additional info.';
    PageType = CardPart;
    SourceTable = "ITI App. Object Table Field";

    layout
    {
        area(content)
        {
            field("SQL Database Code"; Rec."SQL Database Code")
            {
                ToolTip = 'Specifies the code of the SQL database.';
                ApplicationArea = All;
                Visible = false;
            }
            field("SQL Field Name"; Rec."SQL Field Name")
            {
                ToolTip = 'Specifies the name of the SQL field.';
                ApplicationArea = All;
                Visible = false;
            }
            field("Table Name"; Rec."Table Name")
            {
                ToolTip = 'Specifies the name of the table.';
                ApplicationArea = All;
            }
            field("Table ID"; Rec."Table ID")
            {
                ToolTip = 'Specifies the ID of the table.';
                ApplicationArea = All;
            }
            field("Field Name"; Rec.Name)
            {
                ToolTip = 'Specifies the name of the field.';
                ApplicationArea = All;
                Caption = 'Field Name';
            }
            field("Field ID"; Rec.ID)
            {
                ToolTip = 'Specifies the IF of the field.';
                ApplicationArea = All;
                Caption = 'Field ID';
            }
            field(FieldClass; Rec.FieldClass)
            {
                ToolTip = 'Specifies the field class.';
                ApplicationArea = All;
            }
            field(Datatype; Rec.Datatype)
            {
                ToolTip = 'Specifies the field data type.';
                ApplicationArea = All;
            }
            field(DataLength; Rec.DataLength)
            {
                ToolTip = 'Specifies the field data length.';
                ApplicationArea = All;
            }
            field(DataClassification; Rec.DataClassification)
            {
                ToolTip = 'Specifies the field data classification.';
                ApplicationArea = All;
            }
            field("App ID"; Rec."App ID")
            {
                ToolTip = 'Specifies the field application ID.';
                ApplicationArea = All;
            }
            field("App Name"; Rec."App Name")
            {
                ToolTip = 'Specifies the field application name.';
                ApplicationArea = All;
            }
            field(IsExtension; Rec.IsExtension)
            {
                ToolTip = 'Specifies if the field is an extension.';
                ApplicationArea = All;
                Caption = 'Is Extension';
            }
        }
    }
}

