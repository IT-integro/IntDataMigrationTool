page 99006 "PTE SQL Database Table Fields"
{
    //ApplicationArea = All;
    Caption = 'SQL Database Table Fields';
    PageType = List;
    SourceTable = "PTE SQL Database Table Field";
    UsageCategory = None;
    DataCaptionFields = "SQL Database Code", "Table Name";
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("SQL Database Code"; Rec."SQL Database Code")
                {
                    ToolTip = 'Specifies the code of the SQL database.';
                    Visible = false;
                    ApplicationArea = All;
                }

                field("Table Schema"; Rec."Table Schema")
                {
                    ToolTip = 'Specifies the value of the Table Schema property.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Table Catalog"; Rec."Table Catalog")
                {
                    ToolTip = 'Specifies the value of the Table Catalog property.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ToolTip = 'Specifies the name of the table.';
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Column Name"; Rec."Column Name")
                {
                    ToolTip = 'Specifies the name of the column in SQL table.';
                    ApplicationArea = All;
                }
                field("Data Type"; Rec."Data Type")
                {
                    ToolTip = 'Specifies the data type.';
                    ApplicationArea = All;
                }
                field("Ordinal Position"; Rec."Ordinal Position")
                {
                    ToolTip = 'Specifies the ordinal position.';
                    ApplicationArea = All;
                }
                field("Character Octet Lenght"; Rec."Character Octet Lenght")
                {
                    ToolTip = 'Specifies the length of the character octet, which represent fields value.';
                    ApplicationArea = All;
                }
                field("Character Maximum Length"; Rec."Character Maximum Length")
                {
                    ToolTip = 'Specifies the maximum length of the characters.';
                    ApplicationArea = All;
                }
                field("Allow Nulls"; Rec."Allow Nulls")
                {
                    ToolTip = 'Specifies if null values are allowed.';
                    ApplicationArea = All;
                }
                field("Column Default"; Rec."Column Default")
                {
                    ToolTip = 'Specifies the default value of the columns field.';
                    ApplicationArea = All;
                }
                field("Autoincrement"; Rec.Autoincrement)
                {
                    ToolTip = 'Specifies if autoincrement is enabled.';
                    ApplicationArea = All;
                }
                field("Collation Name"; Rec."Collation Name")
                {
                    ToolTip = 'Specifies collation name used for the field.';
                    ApplicationArea = All;
                }
                field("Character Set Name"; Rec."Character Set Name")
                {
                    ToolTip = 'Specifies the name of the character set used as fields values.';
                    ApplicationArea = All;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the entry number for the field.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
