codeunit 99007 "ITI Apply Mapping"
{
    procedure InsertMapping(ITIMigrationDataset: Record "ITI Migration Dataset")
    begin
        ITIApplyMapping(ITIMigrationDataset, true);
    end;

    procedure UpdateMapping(ITIMigrationDataset: Record "ITI Migration Dataset")
    begin
        ITIApplyMapping(ITIMigrationDataset, false);
    end;

    local procedure ITIApplyMapping(ITIMigrationDataset: Record "ITI Migration Dataset"; InsertMode: Boolean)
    var
        ITIMapping: Record "ITI Mapping";
        ITIMappingTable: Record "ITI Mapping Table";
        ITIMappingTableField: Record "ITI Mapping Table Field";
        ITIMappingTableFieldOption: Record "ITI Mapping Table Field Option";
        ITIMigrationDatasetTable: Record "ITI Migration Dataset Table";
        ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field";
        ITIMigrDsTblFldOption: Record "ITI Migr. Ds. Tbl. Fld. Option";
        ITIMappings: Page "ITI Mappings";
        UpdateConfirmationMsg: label 'This operation will applay mapping %1 to the dataset %2. Do you want to continue ?', Comment = '%1 = Mapping Code, %2= Migration Dataset Code';
        InsertConfirmationMsg: label 'This operation will insert mapping %1 to the dataset %2. Do you want to continue ?', Comment = '%1 = Mapping Code, %2= Migration Dataset Code';
    begin

        ITIMappings.LookupMode := true;
        ITIMappings.Editable := false;
        ITIMappings.SetTableView(ITIMapping);
        if ITIMappings.RunModal() = Action::LookupOK then begin
            ITIMappings.GetRecord(ITIMapping);
            if InsertMode then begin
                if not Confirm(InsertConfirmationMsg, false, ITIMapping.Code, ITIMigrationDataset.Code) then
                    exit;
            end else
                if not Confirm(UpdateConfirmationMsg, false, ITIMapping.Code, ITIMigrationDataset.Code) then
                    exit;
            //insert/update dataset tables
            ITIMappingTable.SetRange("Mapping Code", ITIMapping.Code);
            if ITIMappingTable.FindSet() then
                repeat
                    ITIMigrationDatasetTable.SetRange("Migration Dataset Code", ITIMigrationDataset.Code);
                    ITIMigrationDatasetTable.SetRange("Source Table Name", ITIMappingTable."Source Table Name");
                    if ITIMigrationDatasetTable.FindFirst() then begin
                        if (ITIMigrationDatasetTable."Target table name" = '') or (ITIMigrationDatasetTable."Target table name" <> ITIMappingTable."Target Table Name") then begin
                            ITIMigrationDatasetTable."Target SQL Database Code" := ITIMigrationDataset."Target SQL Database Code";
                            ITIMigrationDatasetTable.Validate("Target table name", ITIMappingTable."Target Table Name");
                            ITIMigrationDatasetTable.Validate("Skip in Mapping", ITIMappingTable.Skip);
                            ITIMigrationDatasetTable.Modify();
                        end;
                    end else
                        if InsertMode then begin
                            ITIMigrationDatasetTable.Init();
                            ITIMigrationDatasetTable."Migration Dataset Code" := ITIMigrationDataset.Code;
                            ITIMigrationDatasetTable."Source SQL Database Code" := ITIMigrationDataset."Source SQL Database Code";
                            ITIMigrationDatasetTable.Validate("Source Table Name", ITIMappingTable."Source Table Name");
                            ITIMigrationDatasetTable.Insert();
                            ITIMigrationDatasetTable."Target SQL Database Code" := ITIMigrationDataset."Target SQL Database Code";
                            ITIMigrationDatasetTable.Validate("Target table name", ITIMappingTable."Target Table Name");
                            ITIMigrationDatasetTable.Validate("Skip in Mapping", ITIMappingTable.Skip);
                            ITIMigrationDatasetTable.Modify();
                        end;
                until ITIMappingTable.Next() = 0;

            //update dataset fields
            ITIMappingTableField.SetRange("Mapping Code", ITIMapping.Code);
            ITIMappingTableField.SetRange(Constant, false);
            if ITIMappingTableField.FindSet() then
                repeat
                    ITIMigrDatasetTableField.SetRange("Migration Dataset Code", ITIMigrationDataset.Code);
                    ITIMigrDatasetTableField.SetRange("Source Table Name", ITIMappingTableField."Source Table Name");
                    ITIMigrDatasetTableField.SetRange("Source Field Name", ITIMappingTableField."Source Field Name");
                    if ITIMigrDatasetTableField.FindFirst() then begin
                        if ITIMigrDatasetTableField."Target Table name" = '' then
                            ITIMigrDatasetTableField."Target Table name" := ITIMappingTableField."Target Table Name";
                        if (ITIMigrDatasetTableField."Target Field name" = '') or (ITIMigrDatasetTableField."Target Field name" <> ITIMappingTableField."Target Field name") then
                            ITIMigrDatasetTableField.Validate("Target Field name", ITIMappingTableField."Target Field Name");
                        ITIMigrDatasetTableField.Validate("Skip in Mapping", ITIMappingTableField.Skip);
                        ITIMigrDatasetTableField.Modify();
                        InsertAdditionalTables(ITIMigrDatasetTableField, ITIMappingTableField."Mapping Code")
                    end;
                until ITIMappingTableField.Next() = 0;

            //update dataset field options
            ITIMappingTableFieldOption.SetRange("Mapping Code", ITIMapping.Code);
            if ITIMappingTableFieldOption.FindSet() then
                repeat
                    ITIMigrDsTblFldOption.SetRange("Migration Dataset Code", ITIMigrationDataset.Code);
                    ITIMigrDsTblFldOption.SetRange("Source Table Name", ITIMappingTableFieldOption."Source Table Name");
                    ITIMigrDsTblFldOption.SetRange("Source Field Name", ITIMappingTableFieldOption."Source Field Name");
                    ITIMigrDsTblFldOption.SetRange("Source Option ID", ITIMappingTableFieldOption."Source Field Option");
                    if ITIMigrDsTblFldOption.FindFirst() then begin
                        ITIMigrDsTblFldOption.CalcFields("Target Table Name", "Target Field name");
                        if ITIMigrDsTblFldOption."Target Table name" = '' then
                            ITIMigrDsTblFldOption."Target Table name" := ITIMappingTableFieldOption."Target Table Name";
                        if ITIMigrDsTblFldOption."Target Field name" = '' then
                            ITIMigrDsTblFldOption."Target Field name" := ITIMappingTableFieldOption."Target Field Name";
                        if (ITIMigrDsTblFldOption."Target Option Name" <> '') and ((ITIMigrDsTblFldOption."Target Option ID" = 0) or (ITIMigrDsTblFldOption."Target Option ID" <> ITIMappingTableFieldOption."Target Field Option")) then
                            ITIMigrDsTblFldOption.Validate("Target Option ID", ITIMappingTableFieldOption."Target Field Option");
                        ITIMigrDatasetTableField.Modify();
                    end;
                until ITIMappingTableFieldOption.Next() = 0;

            //update dataset constant 
            ITIMappingTableField.SetRange(Constant, true);
            if ITIMappingTableField.FindSet() then
                repeat
                    ITIMigrDatasetTableField.Init();
                    ITIMigrDatasetTableField."Migration Dataset Code" := ITIMigrationDataset.Code;
                    ITIMigrDatasetTableField.Validate("Source table name", ITIMappingTableField."Source Table Name");
                    ITIMigrDatasetTableField.Validate("Mapping Type", ITIMigrDatasetTableField."Mapping Type"::ConstantToField);
                    ITIMigrDatasetTableField.Validate("Source Field Name", ITIMappingTableField."Source Field Name");
                    ITIMigrDatasetTableField.Validate("Target Field Name", ITIMappingTableField."Target Field Name");
                    ITIMigrDatasetTableField.Insert();
                    InsertAdditionalTables(ITIMigrDatasetTableField, ITIMappingTableField."Mapping Code")
                until ITIMappingTableField.Next() = 0;
        end;
    end;

    local procedure InsertAdditionalTables(ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field"; MappingCode: Code[20])
    var
        ITIMigrDsTableFieldAddTarget: Record ITIMigrDsTableFieldAddTarget;
        ITIMappingAddTargetField: Record ITIMappingAddTargetField;
    begin
        ITIMappingAddTargetField.SetRange("Mapping Code", MappingCode);
        ITIMappingAddTargetField.SetRange("Source Table Name", ITIMigrDatasetTableField."Source table name");
        ITIMappingAddTargetField.SetRange("Source Field Name", ITIMigrDatasetTableField."Source Field Name");

        if ITIMappingAddTargetField.FindSet() then
            repeat
                ITIMigrDsTableFieldAddTarget.Init();
                ITIMigrDsTableFieldAddTarget."Migration Dataset Code" := ITIMigrDatasetTableField."Migration Dataset Code";
                ITIMigrDsTableFieldAddTarget."Source table name" := ITIMigrDatasetTableField."Source table name";
                ITIMigrDsTableFieldAddTarget."Source Field Name" := ITIMigrDatasetTableField."Source Field Name";
                ITIMigrDsTableFieldAddTarget."Target Field Name" := ITIMappingAddTargetField."Additional Target Field";
                ITIMigrDsTableFieldAddTarget."Target table name" := ITIMigrDatasetTableField."Target table name";
                ITIMigrDsTableFieldAddTarget.Insert();
            until ITIMappingAddTargetField.Next() = 0;
    end;
}
