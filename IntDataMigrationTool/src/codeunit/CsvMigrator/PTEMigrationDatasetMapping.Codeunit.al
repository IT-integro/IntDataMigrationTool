codeunit 99024 PTEMigrationDatasetMapping
{
    procedure GetMigrationDatasetMapping(MigrationDatasetCode: Code[20])
    var
        PTEMigrationDatasetTable: Record "PTE Migration Dataset Table";
        TempBlob: Codeunit "Temp Blob";
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        OutStream: OutStream;
        InStr: InStream;
        FileName: Text;
    begin
        PTEMigrationDatasetTable.SetAutoCalcFields("Source Table No.", "Target Table No.");
        PTEMigrationDatasetTable.SetRange("Migration Dataset Code", MigrationDatasetCode);
        PTEMigrationDatasetTable.SetFilter("Target table name", '<>%1', '');
        PTEMigrationDatasetTable.SetRange("Skip in Mapping", false);
        if not PTEMigrationDatasetTable.FindSet() then
            exit;

        repeat
            Clear(JsonObject);
            JsonObject.Add('SourceTableNo', PTEMigrationDatasetTable."Source Table No.");
            JsonObject.Add('TargetTableNo', PTEMigrationDatasetTable."Target Table No.");
            SetDatasetFields(PTEMigrationDatasetTable, JsonObject);
            JsonArray.Add(JsonObject);
        until PTEMigrationDatasetTable.Next() = 0;


        TempBlob.CreateOutStream(OutStream);
        JsonArray.WriteTo(OutStream);
        TempBlob.CreateInStream(InStr);
        FileName := 'MigrationDatasetMapping_' + MigrationDatasetCode + '.json';
        DownloadFromStream(InStr, '', '', '', FileName);
    end;

    local procedure SetDatasetFields(PTEMigrationDatasetTable: Record "PTE Migration Dataset Table"; var JsonObject: JsonObject)
    var
        PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field";
        FieldObj: JsonObject;
        FieldsObj: JsonArray;
    begin
        PTEMigrDatasetTableField.SetAutoCalcFields("Source Field ID", "Target Field ID");

        PTEMigrDatasetTableField.SetRange("Migration Dataset Code", PTEMigrationDatasetTable."Migration Dataset Code");
        PTEMigrDatasetTableField.SetRange("Source table name", PTEMigrationDatasetTable."Source table name");
        PTEMigrDatasetTableField.SetRange("Target table name", PTEMigrationDatasetTable."Target table name");
        PTEMigrDatasetTableField.SetRange("Skip in Mapping", false);
        PTEMigrDatasetTableField.SetFilter("Target Field name", '<>%1', '');
        if not PTEMigrDatasetTableField.FindSet() then
            exit;

        repeat
            Clear(FieldObj);
            FieldObj.Add('SourceFieldNo', PTEMigrDatasetTableField."Source Field ID");
            FieldObj.Add('TargetFieldNo', PTEMigrDatasetTableField."Target Field ID");
            FieldsObj.Add(FieldObj);
        until PTEMigrDatasetTableField.Next() = 0;

        JsonObject.Add('Fields', FieldsObj);
    end;
}
