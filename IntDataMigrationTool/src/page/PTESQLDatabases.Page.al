page 99005 "PTE SQL Databases"
{
    ApplicationArea = All;
    Caption = 'SQL Databases';
    PageType = List;
    SourceTable = "PTE SQL Database";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the code of the Server.';
                    ApplicationArea = All;
                }
                field("Server Name"; Rec."Server Name")
                {
                    ToolTip = 'Specifies the name of the server.';
                    ApplicationArea = All;
                }
                field("Database Name"; Rec."Database Name")
                {
                    ToolTip = 'Specifies the name of the database.';
                    ApplicationArea = All;
                }
                field("User Name"; Rec."User Name")
                {
                    ToolTip = 'Specifies the name of the user which will be used to perform actions in database.';
                    ApplicationArea = All;
                }
                field(Password; Password)
                {
                    ToolTip = 'Specifies the password of the user which will be used to perform actions in database.';
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    Caption = 'Password';
                    trigger OnValidate()
                    begin
                        Rec.SetPassword(Password);
                    end;
                }
                field("Use Metadata Set Code"; Rec."Use Metadata Set Code")
                {
                    ToolTip = 'Specifies the code of the already uploaded Metadata Set, which will be used instead of the downloaded metadata.';
                    ApplicationArea = All;
                }
                field("Forbidden Chars"; Rec."Forbidden Chars")
                {
                    ToolTip = 'Specifies the forbidden characters.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Application Version"; Rec."Application Version")
                {
                    ToolTip = 'Specifies the application version.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Application Family"; Rec."Application Family")
                {
                    ToolTip = 'Specifies the application family.';
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Metadata Downloaded"; Rec."Metadata Exists")
                {
                    ToolTip = 'Specifies if the metadata was downloaded.';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Get Metadata")
            {
                Image = DeleteAllBreakpoints;
                ToolTip = 'Get all application objects metadata and database structure from SQL server';
                ApplicationArea = All;
                trigger OnAction()
                begin
                    Rec.GetMetadata();
                end;
            }
        }
        area(Navigation)
        {
            action("SQL Tables")
            {
                ToolTip = 'Show SQL server physical tables';
                ApplicationArea = All;
                Image = "Table";
                RunObject = Page "PTE SQL Database Tables";
                RunPageLink = "SQL Database Code" = FIELD("Code");
                RunPageMode = View;
            }
            action("Installed Apps")
            {
                ToolTip = 'Show Installed apps';
                ApplicationArea = All;
                Image = ApplicationWorksheet;
                RunObject = Page "PTE SQL Database InstalledApps";
                RunPageLink = "SQL Database Code" = field("Code");
                RunPageMode = View;
            }
            action("Application Objects")
            {
                ToolTip = 'Show Objects';
                ApplicationArea = All;
                Image = ExtendedDataEntry;
                RunObject = Page "PTE App. Objects";
                RunPageLink = "SQL Database Code" = field("Code");
            }
            action("Application Object Tables")
            {
                ToolTip = 'Show Database Objects - Tables';
                ApplicationArea = All;
                Image = ExtendedDataEntry;
                RunObject = Page "PTE App. Object Tables";
                RunPageLink = "SQL Database Code" = field("Code");
            }
            action("Application Object Enums")
            {
                ToolTip = 'Show Database Objects - Enums';
                ApplicationArea = All;
                Image = ExtendedDataEntry;
                RunObject = Page "PTE App. Object Enums";
                RunPageLink = "SQL Database Code" = field("Code");
            }
            action("Database Companies")
            {
                ToolTip = 'Show Database Comoanies';
                ApplicationArea = All;
                Image = ExtendedDataEntry;
                RunObject = Page "PTE SQL Database COmpanies";
                RunPageLink = "SQL Database Code" = field("Code");
            }
            action("Migrate From Csv")
            {
                Caption = 'Migrate from CSV';
                ToolTip = 'Migrate data from CSV files to SQL Database';
                ApplicationArea = All;
                Image = Import;
                trigger OnAction()
                var
                    PTEMigrateFromCsvFile: Codeunit PTEMigrateFromCsvFile;
                begin
                    PTEMigrateFromCsvFile.Run();
                end;


            }
        }
        area(Promoted)
        {
            actionref(PromMigrateFromCsv; "Migrate From Csv") { }
        }
    }
    var
        Password: Text;

    trigger OnAfterGetRecord()
    begin
        Clear(Password);
        if IsolatedStorage.Contains(Rec.Code) then
            Password := '.'
    end;

    trigger OnAfterGetCurrRecord()
    begin
        Clear(Password);
        if IsolatedStorage.Contains(Rec.Code) then
            Password := '.'
    end;
}
