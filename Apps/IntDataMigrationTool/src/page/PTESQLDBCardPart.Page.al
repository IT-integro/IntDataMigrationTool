page 99030 "PTE SQL DB CardPart"
{
    ApplicationArea = All;
    Caption = 'Migration Data';
    PageType = CardPart;
    SourceTable = "PTE SQL Database";

    layout
    {
        area(content)
        {

            cuegroup("Application Metadata Sets")
            {
                Caption = 'Application Metadata Sets';
                field("Get Metadata Set Count"; PTEAppMetadataSet.Count())
                {
                    ApplicationArea = All;
                    Caption = 'Application Metadata Sets';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of imported application metadata sets.';


                    trigger OnDrillDown()
                    var
                        PTEAppMetadataSetList: Page "PTE App. Metadata Set List";
                    begin
                        PTEAppMetadataSetList.Run();
                    end;
                }
            }

            cuegroup("SQL Databases")
            {
                Caption = 'SQL Databases';
                field("Get SQL DB Count"; PTESQLDatabase.Count())
                {
                    ApplicationArea = All;
                    Caption = 'SQL Databases';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of known SQL databases.';

                    trigger OnDrillDown()
                    var
                        PTESQLDatabases: Page "PTE SQL Databases";
                    begin
                        PTESQLDatabases.Run();
                    end;
                }
            }
            cuegroup("Migration Datasets")
            {
                Caption = 'Migration Datasets';
                field("Get Migration DS Count"; PTEMigrationDataset.Count())
                {
                    ApplicationArea = All;
                    Caption = 'Migration Datasets';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of created migration datasets.';

                    trigger OnDrillDown()
                    var
                        PTEMigrationDatasetList: Page "PTE Migration Dataset List";
                    begin
                        PTEMigrationDatasetList.Run();
                    end;
                }
            }
            cuegroup("Migrations")
            {
                Caption = 'Migrations';
                field("Get Migration Count"; PTEMigration.Count())
                {
                    ApplicationArea = All;
                    Caption = 'Migrations';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of created migrations.';

                    trigger OnDrillDown()
                    var
                        PTEMigrations: Page "PTE Migrations";
                    begin
                        PTEMigrations.Run();
                    end;
                }
            }
            cuegroup("Mapping")
            {
                Caption = 'Mappings';
                field("Get Mapping Count"; PTEMapping.Count())
                {
                    ApplicationArea = All;
                    Caption = 'Mappings';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of created mappings.';

                    trigger OnDrillDown()
                    var
                        PTEMappings: Page "PTE Mappings";
                    begin
                        PTEMappings.Run();
                    end;
                }
            }
        }
    }

    var
        PTESQLDatabase: Record "PTE SQL Database";
        PTEMigrationDataset: Record "PTE Migration Dataset";
        PTEMigration: Record "PTE Migration";
        PTEMapping: Record "PTE Mapping";
        PTEAppMetadataSet: Record "PTE App. Metadata Set";
}
