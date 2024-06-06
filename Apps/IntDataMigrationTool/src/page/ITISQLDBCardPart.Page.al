page 99030 "ITI SQL DB CardPart"
{
    ApplicationArea = All;
    Caption = 'Migration Data';
    PageType = CardPart;
    SourceTable = "ITI SQL Database";

    layout
    {
        area(content)
        {

            cuegroup("Application Metadata Sets")
            {
                Caption = 'Application Metadata Sets';
                field("Get Metadata Set Count"; ITIAppMetadataSet.Count())
                {
                    ApplicationArea = All;
                    Caption = 'Application Metadata Sets';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of imported application metadata sets.';


                    trigger OnDrillDown()
                    var
                        ITIAppMetadataSetList: Page "ITI App. Metadata Set List";
                    begin
                        ITIAppMetadataSetList.Run();
                    end;
                }
            }

            cuegroup("SQL Databases")
            {
                Caption = 'SQL Databases';
                field("Get SQL DB Count"; ITISQLDatabase.Count())
                {
                    ApplicationArea = All;
                    Caption = 'SQL Databases';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of known SQL databases.';

                    trigger OnDrillDown()
                    var
                        ITISQLDatabases: Page "ITI SQL Databases";
                    begin
                        ITISQLDatabases.Run();
                    end;
                }
            }
            cuegroup("Migration Datasets")
            {
                Caption = 'Migration Datasets';
                field("Get Migration DS Count"; ITIMigrationDataset.Count())
                {
                    ApplicationArea = All;
                    Caption = 'Migration Datasets';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of created migration datasets.';

                    trigger OnDrillDown()
                    var
                        ITIMigrationDatasetList: Page "ITI Migration Dataset List";
                    begin
                        ITIMigrationDatasetList.Run();
                    end;
                }
            }
            cuegroup("Migrations")
            {
                Caption = 'Migrations';
                field("Get Migration Count"; ITIMigration.Count())
                {
                    ApplicationArea = All;
                    Caption = 'Migrations';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of created migrations.';

                    trigger OnDrillDown()
                    var
                        ITIMigrations: Page "ITI Migrations";
                    begin
                        ITIMigrations.Run();
                    end;
                }
            }
            cuegroup("Mapping")
            {
                Caption = 'Mappings';
                field("Get Mapping Count"; ITIMapping.Count())
                {
                    ApplicationArea = All;
                    Caption = 'Mappings';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of created mappings.';

                    trigger OnDrillDown()
                    var
                        ITIMappings: Page "ITI Mappings";
                    begin
                        ITIMappings.Run();
                    end;
                }
            }
        }
    }

    var
        ITISQLDatabase: Record "ITI SQL Database";
        ITIMigrationDataset: Record "ITI Migration Dataset";
        ITIMigration: Record "ITI Migration";
        ITIMapping: Record "ITI Mapping";
        ITIAppMetadataSet: Record "ITI App. Metadata Set";
}
