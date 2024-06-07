codeunit 99006 "ITI Export Import Mapping"
{
    procedure ExportToJson(ITIMapping: Record "ITI Mapping")
    var
        ITIMappingTable: Record "ITI Mapping Table";
        ITIMappingTableField: Record "ITI Mapping Table Field";
        ITIMappingTableFieldOption: Record "ITI Mapping Table Field Option";
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
        ITIMappingTableField.SetRange("Mapping Code", ITIMappingTable."Mapping Code");
        ProgressTotal := ITIMappingTableField.Count();
        DialogProgress.OPEN(STRSUBSTNO(GeneretingDataFileMsg, ProgressTotal) + ': #1#####', CurrentProgress);
        // Mapping
        MappingJsonObject.Add('Mapping Code', ITIMapping.Code);
        MappingJsonObject.Add('Mapping Description', ITIMapping.Description);
        //Tables
        ITIMappingTable.Reset();
        ITIMappingTable.SetRange("Mapping Code", ITIMapping.Code);
        if ITIMappingTable.FindSet() then begin
            repeat
                Clear(TablesJsonObject);
                TablesJsonObject.Add('Source Table Name', ITIMappingTable."Source Table Name");
                TablesJsonObject.Add('Target Table Name', ITIMappingTable."Target Table Name");
                //Fields
                ITIMappingTableField.SetRange("Mapping Code", ITIMappingTable."Mapping Code");
                ITIMappingTableField.SetRange("Source Table Name", ITIMappingTable."Source Table Name");
                ITIMappingTableField.SetRange("Target Table Name", ITIMappingTable."Target Table Name");
                if ITIMappingTableField.FindSet() then begin
                    Clear(TableFieldsJsonArray);
                    repeat
                        AdditionalTargetFileds := '';
                        Clear(TableFieldJsonObject);
                        TableFieldJsonObject.Add('Source Field Name', ITIMappingTableField."Source Field Name");
                        TableFieldJsonObject.Add('Target Field Name', ITIMappingTableField."Target Field Name");
                        TableFieldJsonObject.Add('Skip in Mapping', ITIMappingTableField.Skip);
                        TableFieldJsonObject.Add('Constant', ITIMappingTableField.Constant);
                        GetAdditionalTargetFields(ITIMappingTableField, AdditionalTargetFileds);
                        if AdditionalTargetFileds <> '' then
                            TableFieldJsonObject.Add('Additional Target Fields', AdditionalTargetFileds);
                        //Fields options
                        ITIMappingTableFieldOption.SetRange("Mapping Code", ITIMappingTableField."Mapping Code");
                        ITIMappingTableFieldOption.SetRange("Source Table Name", ITIMappingTableField."Source Table Name");
                        ITIMappingTableFieldOption.SetRange("Source Field Name", ITIMappingTableField."Source Field Name");
                        ITIMappingTableFieldOption.SetRange("Target Table Name", ITIMappingTableField."Target Table Name");
                        ITIMappingTableFieldOption.SetRange("Target Field Name", ITIMappingTableField."Target Field Name");
                        if ITIMappingTableFieldOption.FindSet() then begin
                            Clear(TableFieldOptionsJsonArray);
                            repeat
                                Clear(TableFieldOptionJsonObject);
                                TableFieldOptionJsonObject.Add('Source Field Option', ITIMappingTableFieldOption."Source Field Option");
                                TableFieldOptionJsonObject.Add('Target Field Option', ITIMappingTableFieldOption."Target Field Option");
                                TableFieldOptionsJsonArray.Add(TableFieldOptionJsonObject);
                            until ITIMappingTableFieldOption.Next() = 0;
                            TableFieldJsonObject.Add('Options', TableFieldOptionsJsonArray);
                        end;
                        TableFieldsJsonArray.Add(TableFieldJsonObject);
                        CurrentProgress := CurrentProgress + 1;
                        DialogProgress.UPDATE(1, CurrentProgress);
                    until ITIMappingTableField.Next() = 0;
                    TablesJsonObject.Add('Fields', TableFieldsJsonArray);
                end;
                TablesJsonArray.Add(TablesJsonObject);
            until ITIMappingTable.Next() = 0;
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
        ITIMapping: Record "ITI Mapping";
        ITIMappingTable: Record "ITI Mapping Table";

        ITIMappingTableField: Record "ITI Mapping Table Field";
        ITIMappingTableFieldOption: Record "ITI Mapping Table Field Option";
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
            ITIMapping.init();
            ITIMapping.Code := CopyStr(MappingCode, 1, MaxStrLen(ITIMapping.Code));
            ITIMapping.Description := CopyStr(MappingDescription, 1, MaxStrLen(ITIMapping.Description));
            ITIMapping.Insert();
            //Mapping Tables
            if MappingObjectJSONManagement.GetArrayPropertyValueAsStringByName('Tables', TablesJsonArrayText) then begin
                TablesArrayJSONManagement.InitializeCollection(TablesJsonArrayText);
                for i := 0 to TablesArrayJSONManagement.GetCollectionCount() - 1 do begin
                    TablesArrayJSONManagement.GetObjectFromCollectionByIndex(TablesJsonObjectText, i);
                    TableObjectJSONManagement.InitializeObject(TablesJsonObjectText);
                    TableObjectJSONManagement.GetStringPropertyValueByName('Source Table Name', SourceTableName);
                    TableObjectJSONManagement.GetStringPropertyValueByName('Target Table Name', TargetTableName);
                    ITIMappingTable.Init();
                    ITIMappingTable."Mapping Code" := CopyStr(MappingCode, 1, MaxStrLen(ITIMappingTable."Mapping Code"));
                    ITIMappingTable."Source Table Name" := CopyStr(SourceTableName, 1, MaxStrLen(ITIMappingTable."Source Table Name"));
                    ITIMappingTable."Target Table Name" := CopyStr(TargetTableName, 1, MaxStrLen(ITIMappingTable."Target Table Name"));
                    ITIMappingTable.Insert();
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

                            ITIMappingTableField.Init();
                            ITIMappingTableField."Mapping Code" := CopyStr(MappingCode, 1, MaxStrLen(ITIMappingTableField."Mapping Code"));
                            ITIMappingTableField."Source Field Name" := CopyStr(SourceFieldName, 1, MaxStrLen(ITIMappingTableField."Source Field Name"));
                            ITIMappingTableField."Source Table Name" := CopyStr(SourceTableName, 1, MaxStrLen(ITIMappingTableField."Source Table Name"));
                            ITIMappingTableField."Target Field Name" := CopyStr(TargetFieldName, 1, MaxStrLen(ITIMappingTableField."Target Field Name"));
                            ITIMappingTableField."Target Table Name" := CopyStr(TargetTableName, 1, MaxStrLen(ITIMappingTableField."Target Table Name"));
                            Evaluate(ITIMappingTableField.Skip, SkipInMapping);
                            Evaluate(ITIMappingTableField.Constant, Constant);
                            ITIMappingTableField.Insert();

                            if FieldObjectJSONManagement.GetStringPropertyValueByName('Additional Target Fields', AdditionalTargetTables) then
                                InsertAdditionalFields(AdditionalTargetTables, ITIMappingTableField);

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
                                    ITIMappingTableFieldOption.Init();
                                    ITIMappingTableFieldOption."Mapping Code" := CopyStr(MappingCode, 1, MaxStrLen(ITIMappingTableFieldOption."Mapping Code"));
                                    ITIMappingTableFieldOption."Source Field Name" := CopyStr(SourceFieldName, 1, MaxStrLen(ITIMappingTableFieldOption."Source Field Name"));
                                    ITIMappingTableFieldOption."Source Field Option" := SourceFieldOption;
                                    ITIMappingTableFieldOption."Source Table Name" := CopyStr(SourceTableName, 1, MaxStrLen(ITIMappingTableFieldOption."Source Table Name"));
                                    ITIMappingTableFieldOption."Target Field Name" := CopyStr(TargetFieldName, 1, MaxStrLen(ITIMappingTableFieldOption."Target Field Name"));
                                    ITIMappingTableFieldOption."Target Field Option" := TargetFieldOption;
                                    ITIMappingTableFieldOption."Target Table Name" := CopyStr(TargetTableName, 1, MaxStrLen(ITIMappingTableFieldOption."Target Table Name"));
                                    ITIMappingTableFieldOption.Insert();
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
        ITIMapping: Record "ITI Mapping";
        NewMappingCode: text;
        i: Integer;
    begin

        if ITIMapping.Get(CurrentMappingCode) then
            repeat
                i := i + 1;
                NewMappingCode := CurrentMappingCode + Format(i);
            until not ITIMapping.Get(NewMappingCode)
        else
            NewMappingCode := CurrentMappingCode;
        exit(NewMappingCode);
    end;

    local procedure GetAdditionalTargetFields(ITIMappingTableField: Record "ITI Mapping Table Field"; var AdditionalTargetFields: Text)
    var
        ITIMappingAddTargetField: Record ITIMappingAddTargetField;
    begin
        ITIMappingAddTargetField.SetRange("Mapping Code", ITIMappingTableField."Mapping Code");
        ITIMappingAddTargetField.SetRange("Source Table Name", ITIMappingTableField."Source Table Name");
        ITIMappingAddTargetField.SetRange("Source Field Name", ITIMappingTableField."Source Field Name");
        if ITIMappingAddTargetField.FindSet() then begin
            repeat
                AdditionalTargetFields := AdditionalTargetFields + ITIMappingAddTargetField."Additional Target Field" + '|';
            until ITIMappingAddTargetField.Next() = 0;
            AdditionalTargetFields := DelChr(AdditionalTargetFields, '>', '|');
        end;
    end;

    local procedure InsertAdditionalFields(AdditionalTargetTables: Text; ITIMappingTableField: Record "ITI Mapping Table Field")
    var
        ITIMappingAddTargetField: Record ITIMappingAddTargetField;
        FieldList: List of [Text];
        Field: Text;
    begin
        FieldList := AdditionalTargetTables.Split('|');
        foreach Field in FieldList do begin
            ITIMappingAddTargetField.Init();
            ITIMappingAddTargetField."Mapping Code" := ITIMappingTableField."Mapping Code";
            ITIMappingAddTargetField."Source Table Name" := ITIMappingTableField."Source Table Name";
            ITIMappingAddTargetField."Source Field Name" := ITIMappingTableField."Source Field Name";
            ITIMappingAddTargetField."Additional Target Field" := CopyStr(Field, 1, MaxStrLen(ITIMappingAddTargetField."Additional Target Field"));
            ITIMappingAddTargetField."Target Table Name" := ITIMappingTableField."Target Table Name";
            ITIMappingAddTargetField.Insert();
        end;
    end;
}
