codeunit 99006 "PTE Export Import Mapping"
{
    procedure ExportToJson(PTEMapping: Record "PTE Mapping")
    var
        PTEMappingTable: Record "PTE Mapping Table";
        PTEMappingTableField: Record "PTE Mapping Table Field";
        PTEMappingTableFieldOption: Record "PTE Mapping Table Field Option";
        FileManagement: Codeunit "File Management";
        JsonText: Text;
        FileName: Text;
        DataFile: File;
        JsonObject: JsonObject;
        MappingJsonObject: JsonObject;
        TablesJsonObject: JsonObject;
        TableFieldJsonObject: JsonObject;
        TableFieldOptionJsonObject: JsonObject;
        TablesJsonArray: JsonArray;
        TableFieldsJsonArray: JsonArray;
        TableFieldOptionsJsonArray: JsonArray;
        DialogProgress: Dialog;
        ProgressTotal: Integer;
        CurrentProgress: Integer;
        AdditionalTargetFileds: Text;
        GeneretingDataFileMsg: Label 'Generating data file. No of records: %1', Comment = '%1 = No Of Records';
    begin
        PTEMappingTableField.SetRange("Mapping Code", PTEMappingTable."Mapping Code");
        ProgressTotal := PTEMappingTableField.Count();
        DialogProgress.OPEN(STRSUBSTNO(GeneretingDataFileMsg, ProgressTotal) + ': #1#####', CurrentProgress);
        // Mapping
        MappingJsonObject.Add('Mapping Code', PTEMapping.Code);
        MappingJsonObject.Add('Mapping Description', PTEMapping.Description);
        //Tables
        PTEMappingTable.Reset();
        PTEMappingTable.SetRange("Mapping Code", PTEMapping.Code);
        if PTEMappingTable.FindSet() then begin
            repeat
                Clear(TablesJsonObject);
                TablesJsonObject.Add('Source Table Name', PTEMappingTable."Source Table Name");
                TablesJsonObject.Add('Target Table Name', PTEMappingTable."Target Table Name");
                //Fields
                PTEMappingTableField.SetRange("Mapping Code", PTEMappingTable."Mapping Code");
                PTEMappingTableField.SetRange("Source Table Name", PTEMappingTable."Source Table Name");
                PTEMappingTableField.SetRange("Target Table Name", PTEMappingTable."Target Table Name");
                if PTEMappingTableField.FindSet() then begin
                    Clear(TableFieldsJsonArray);
                    repeat
                        AdditionalTargetFileds := '';
                        Clear(TableFieldJsonObject);
                        TableFieldJsonObject.Add('Source Field Name', PTEMappingTableField."Source Field Name");
                        TableFieldJsonObject.Add('Target Field Name', PTEMappingTableField."Target Field Name");
                        TableFieldJsonObject.Add('Skip in Mapping', PTEMappingTableField.Skip);
                        TableFieldJsonObject.Add('Constant', PTEMappingTableField.Constant);
                        GetAdditionalTargetFields(PTEMappingTableField, AdditionalTargetFileds);
                        if AdditionalTargetFileds <> '' then
                            TableFieldJsonObject.Add('Additional Target Fields', AdditionalTargetFileds);
                        //Fields options
                        PTEMappingTableFieldOption.SetRange("Mapping Code", PTEMappingTableField."Mapping Code");
                        PTEMappingTableFieldOption.SetRange("Source Table Name", PTEMappingTableField."Source Table Name");
                        PTEMappingTableFieldOption.SetRange("Source Field Name", PTEMappingTableField."Source Field Name");
                        PTEMappingTableFieldOption.SetRange("Target Table Name", PTEMappingTableField."Target Table Name");
                        PTEMappingTableFieldOption.SetRange("Target Field Name", PTEMappingTableField."Target Field Name");
                        if PTEMappingTableFieldOption.FindSet() then begin
                            Clear(TableFieldOptionsJsonArray);
                            repeat
                                Clear(TableFieldOptionJsonObject);
                                TableFieldOptionJsonObject.Add('Source Field Option', PTEMappingTableFieldOption."Source Field Option");
                                TableFieldOptionJsonObject.Add('Target Field Option', PTEMappingTableFieldOption."Target Field Option");
                                TableFieldOptionsJsonArray.Add(TableFieldOptionJsonObject);
                            until PTEMappingTableFieldOption.Next() = 0;
                            TableFieldJsonObject.Add('Options', TableFieldOptionsJsonArray);
                        end;
                        TableFieldsJsonArray.Add(TableFieldJsonObject);
                        CurrentProgress := CurrentProgress + 1;
                        DialogProgress.UPDATE(1, CurrentProgress);
                    until PTEMappingTableField.Next() = 0;
                    TablesJsonObject.Add('Fields', TableFieldsJsonArray);
                end;
                TablesJsonArray.Add(TablesJsonObject);
            until PTEMappingTable.Next() = 0;
            MappingJsonObject.Add('Tables', TablesJsonArray);
        end;
        JsonObject.Add('Mapping', MappingJsonObject);
        JsonObject.WriteTo(JsonText);

        FileName := FileManagement.ServerTempFileName('json');
        DataFile.TextMode(true);
        DataFile.Create(FileName);
        DataFile.Write(JsonText);
        DataFile.close();
        FileManagement.DownloadHandler(FileName, 'Mapping', '', '', 'Mapping.json');
    end;

    procedure ImportFromJson()
    var
        PTEMapping: Record "PTE Mapping";
        PTEMappingTable: Record "PTE Mapping Table";

        PTEMappingTableField: Record "PTE Mapping Table Field";
        PTEMappingTableFieldOption: Record "PTE Mapping Table Field Option";
        JSONManagement: Codeunit "JSON Management";
        MappingObjectJSONManagement: Codeunit "JSON Management";
        TableObjectJSONManagement: Codeunit "JSON Management";
        FieldObjectJSONManagement: Codeunit "JSON Management";
        OptionObjectJSONManagement: Codeunit "JSON Management";
        TablesArrayJSONManagement: Codeunit "JSON Management";
        FieldsArrayJSONManagement: Codeunit "JSON Management";
        OptionArrayJSONManagement: Codeunit "JSON Management";

        JsonContent: Text;
        FilePath: Text;
        InStream: InStream;
        MappingJsonObject: Text;
        MappingCode: Text;
        MappingDescription: Text;
        TablesJsonArrayText: Text;
        TablesJsonObjectText: Text;
        FieldsJsonArrayText: Text;
        FieldsJsonObjectText: Text;
        OptionsJsonArrayText: Text;
        OptionsJsonObjectText: Text;
        SourceTableName: Text;
        TargetTableName: Text;
        SourceFieldName: Text;
        TargetFieldName: Text;
        AdditionalTargetTables: Text;
        SkipInMapping: Text;
        Constant: Text;
        SourceFieldOptionText: Text;
        TargetFieldOptionText: Text;
        SourceFieldOption: Integer;
        TargetFieldOption: Integer;
        i: integer;
        j: integer;
        k: integer;

        DialogProgress: Dialog;
        CurrentProgress: Integer;
        ImportingDataFileMsg: Label 'Importing data file. Field Mapping:';
    begin
        if UploadIntoStream('Select File', '', '', FilePath, InStream) then
            InStream.Read(JsonContent);
        DialogProgress.OPEN(STRSUBSTNO(ImportingDataFileMsg) + ' #1#####', CurrentProgress);

        JSONManagement.InitializeObject(JsonContent);
        if JSONManagement.GetArrayPropertyValueAsStringByName('Mapping', MappingJsonObject) then begin
            //Mapping
            MappingObjectJSONManagement.InitializeObject(MappingJsonObject);
            MappingObjectJSONManagement.GetStringPropertyValueByName('Mapping Code', MappingCode);
            MappingObjectJSONManagement.GetStringPropertyValueByName('Mapping Description', MappingDescription);
            MappingCode := GetNewMappingCode(MappingCode);
            PTEMapping.init();
            PTEMapping.Code := CopyStr(MappingCode, 1, MaxStrLen(PTEMapping.Code));
            PTEMapping.Description := CopyStr(MappingDescription, 1, MaxStrLen(PTEMapping.Description));
            PTEMapping.Insert();
            //Mapping Tables
            if MappingObjectJSONManagement.GetArrayPropertyValueAsStringByName('Tables', TablesJsonArrayText) then begin
                TablesArrayJSONManagement.InitializeCollection(TablesJsonArrayText);
                for i := 0 to TablesArrayJSONManagement.GetCollectionCount() - 1 do begin
                    TablesArrayJSONManagement.GetObjectFromCollectionByIndex(TablesJsonObjectText, i);
                    TableObjectJSONManagement.InitializeObject(TablesJsonObjectText);
                    TableObjectJSONManagement.GetStringPropertyValueByName('Source Table Name', SourceTableName);
                    TableObjectJSONManagement.GetStringPropertyValueByName('Target Table Name', TargetTableName);
                    PTEMappingTable.Init();
                    PTEMappingTable."Mapping Code" := CopyStr(MappingCode, 1, MaxStrLen(PTEMappingTable."Mapping Code"));
                    PTEMappingTable."Source Table Name" := CopyStr(SourceTableName, 1, MaxStrLen(PTEMappingTable."Source Table Name"));
                    PTEMappingTable."Target Table Name" := CopyStr(TargetTableName, 1, MaxStrLen(PTEMappingTable."Target Table Name"));
                    PTEMappingTable.Insert();
                    //Mapping Fields
                    if TableObjectJSONManagement.GetArrayPropertyValueAsStringByName('Fields', FieldsJsonArrayText) then begin
                        FieldsArrayJSONManagement.InitializeCollection(FieldsJsonArrayText);
                        for j := 0 to FieldsArrayJSONManagement.GetCollectionCount() - 1 do begin
                            CurrentProgress := CurrentProgress + 1;
                            DialogProgress.UPDATE(1, CurrentProgress);
                            FieldsArrayJSONManagement.GetObjectFromCollectionByIndex(FieldsJsonObjectText, j);
                            FieldObjectJSONManagement.InitializeObject(FieldsJsonObjectText);
                            FieldObjectJSONManagement.GetStringPropertyValueByName('Source Field Name', SourceFieldName);
                            FieldObjectJSONManagement.GetStringPropertyValueByName('Target Field Name', TargetFieldName);
                            FieldObjectJSONManagement.GetStringPropertyValueByName('Skip in Mapping', SkipInMapping);
                            FieldObjectJSONManagement.GetStringPropertyValueByName('Constant', Constant);

                            PTEMappingTableField.Init();
                            PTEMappingTableField."Mapping Code" := CopyStr(MappingCode, 1, MaxStrLen(PTEMappingTableField."Mapping Code"));
                            PTEMappingTableField."Source Field Name" := CopyStr(SourceFieldName, 1, MaxStrLen(PTEMappingTableField."Source Field Name"));
                            PTEMappingTableField."Source Table Name" := CopyStr(SourceTableName, 1, MaxStrLen(PTEMappingTableField."Source Table Name"));
                            PTEMappingTableField."Target Field Name" := CopyStr(TargetFieldName, 1, MaxStrLen(PTEMappingTableField."Target Field Name"));
                            PTEMappingTableField."Target Table Name" := CopyStr(TargetTableName, 1, MaxStrLen(PTEMappingTableField."Target Table Name"));

                            if SkipInMapping <> '' then
                                Evaluate(PTEMappingTableField.Skip, SkipInMapping);
                            if Constant <> '' then
                                Evaluate(PTEMappingTableField.Constant, Constant);

                            PTEMappingTableField.Insert();

                            if FieldObjectJSONManagement.GetStringPropertyValueByName('Additional Target Fields', AdditionalTargetTables) then
                                InsertAdditionalFields(AdditionalTargetTables, PTEMappingTableField);

                            //Mapping Field Options
                            if FieldObjectJSONManagement.GetArrayPropertyValueAsStringByName('Options', OptionsJsonArrayText) then begin
                                OptionArrayJSONManagement.InitializeCollection(OptionsJsonArrayText);
                                for k := 0 to OptionArrayJSONManagement.GetCollectionCount() - 1 do begin
                                    OptionArrayJSONManagement.GetObjectFromCollectionByIndex(OptionsJsonObjectText, k);
                                    OptionObjectJSONManagement.InitializeObject(OptionsJsonObjectText);
                                    OptionObjectJSONManagement.GetStringPropertyValueByName('Source Field Option', SourceFieldOptionText);
                                    OptionObjectJSONManagement.GetStringPropertyValueByName('Target Field Option', TargetFieldOptionText);
                                    Evaluate(SourceFieldOption, SourceFieldOptionText);
                                    Evaluate(TargetFieldOption, TargetFieldOptionText);
                                    PTEMappingTableFieldOption.Init();
                                    PTEMappingTableFieldOption."Mapping Code" := CopyStr(MappingCode, 1, MaxStrLen(PTEMappingTableFieldOption."Mapping Code"));
                                    PTEMappingTableFieldOption."Source Field Name" := CopyStr(SourceFieldName, 1, MaxStrLen(PTEMappingTableFieldOption."Source Field Name"));
                                    PTEMappingTableFieldOption."Source Field Option" := SourceFieldOption;
                                    PTEMappingTableFieldOption."Source Table Name" := CopyStr(SourceTableName, 1, MaxStrLen(PTEMappingTableFieldOption."Source Table Name"));
                                    PTEMappingTableFieldOption."Target Field Name" := CopyStr(TargetFieldName, 1, MaxStrLen(PTEMappingTableFieldOption."Target Field Name"));
                                    PTEMappingTableFieldOption."Target Field Option" := TargetFieldOption;
                                    PTEMappingTableFieldOption."Target Table Name" := CopyStr(TargetTableName, 1, MaxStrLen(PTEMappingTableFieldOption."Target Table Name"));
                                    PTEMappingTableFieldOption.Insert();
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;

    end;

    local procedure GetNewMappingCode(CurrentMappingCode: Text): Text;
    var
        PTEMapping: Record "PTE Mapping";
        NewMappingCode: text;
        i: Integer;
    begin

        if PTEMapping.Get(CurrentMappingCode) then
            repeat
                i := i + 1;
                NewMappingCode := CurrentMappingCode + Format(i);
            until not PTEMapping.Get(NewMappingCode)
        else
            NewMappingCode := CurrentMappingCode;
        exit(NewMappingCode);
    end;

    local procedure GetAdditionalTargetFields(PTEMappingTableField: Record "PTE Mapping Table Field"; var AdditionalTargetFields: Text)
    var
        PTEMappingAddTargetField: Record PTEMappingAddTargetField;
    begin
        PTEMappingAddTargetField.SetRange("Mapping Code", PTEMappingTableField."Mapping Code");
        PTEMappingAddTargetField.SetRange("Source Table Name", PTEMappingTableField."Source Table Name");
        PTEMappingAddTargetField.SetRange("Source Field Name", PTEMappingTableField."Source Field Name");
        if PTEMappingAddTargetField.FindSet() then begin
            repeat
                AdditionalTargetFields := AdditionalTargetFields + PTEMappingAddTargetField."Additional Target Field" + '|';
            until PTEMappingAddTargetField.Next() = 0;
            AdditionalTargetFields := DelChr(AdditionalTargetFields, '>', '|');
        end;
    end;

    local procedure InsertAdditionalFields(AdditionalTargetTables: Text; PTEMappingTableField: Record "PTE Mapping Table Field")
    var
        PTEMappingAddTargetField: Record PTEMappingAddTargetField;
        FieldList: List of [Text];
        Field: Text;
    begin
        FieldList := AdditionalTargetTables.Split('|');
        foreach Field in FieldList do begin
            PTEMappingAddTargetField.Init();
            PTEMappingAddTargetField."Mapping Code" := PTEMappingTableField."Mapping Code";
            PTEMappingAddTargetField."Source Table Name" := PTEMappingTableField."Source Table Name";
            PTEMappingAddTargetField."Source Field Name" := PTEMappingTableField."Source Field Name";
            PTEMappingAddTargetField."Additional Target Field" := CopyStr(Field, 1, MaxStrLen(PTEMappingAddTargetField."Additional Target Field"));
            PTEMappingAddTargetField."Target Table Name" := PTEMappingTableField."Target Table Name";
            PTEMappingAddTargetField.Insert();
        end;
    end;
}
