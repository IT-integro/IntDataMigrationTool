codeunit 99014 "ITI Copy Mapping From Dataset"
{
    TableNo = "ITI Migration Dataset";

    trigger OnRun()
    begin
        if ITICopyMappingDialog.RunModal() = Action::OK then
            CreateNewMapping(ITICopyMappingDialog.GetMappingCode(), ITICopyMappingDialog.GetMappingDescription(), Rec);
    end;

    local procedure CreateNewMapping(MappingCode: Code[20]; MappingDescription: Text[150]; ITIMigrationDataset: Record "ITI Migration Dataset");
    var
        ITIMapping: Record "ITI Mapping";
        ITIMappingTable: Record "ITI Mapping Table";
        ITIMigrationDatasetTable: Record "ITI Migration Dataset Table";
    begin
        ITIMapping.Code := MappingCode;
        ITIMapping.Description := MappingDescription;
        ITIMapping.Insert(true);

        ITIMigrationDatasetTable.SetRange("Migration Dataset Code", ITIMigrationDataset.Code);
        if ITIMigrationDatasetTable.FindSet() then
            repeat
                ITIMappingTable.Reset();
                ITIMappingTable.Validate("Mapping Code", MappingCode);
                ITIMappingTable.Validate("Source Table Name", ITIMigrationDatasetTable."Source Table Name");
                ITIMappingTable.Validate("Target Table Name", ITIMigrationDatasetTable."Target table name");
                ITIMappingTable.Skip := ITIMigrationDatasetTable."Skip in Mapping";
                ITIMappingTable.Insert(true);

                CopyFieldMappings(ITIMappingTable, ITIMigrationDatasetTable);
            until ITIMigrationDatasetTable.Next() = 0;
    end;

    local procedure CopyFieldMappings(ITIMappingTable: Record "ITI Mapping Table"; ITIMigrationDatasetTable: Record "ITI Migration Dataset Table")
    var
        ITIMappingTableField: Record "ITI Mapping Table Field";
        ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field";
    begin
        ITIMigrDatasetTableField.SetRange("Migration Dataset Code", ITIMigrationDatasetTable."Migration Dataset Code");
        ITIMigrDatasetTableField.SetRange("Source table name", ITIMigrationDatasetTable."Source Table Name");
        if ITIMigrDatasetTableField.FindSet() then
            repeat
                ITIMappingTableField.Reset();
                ITIMappingTableField.Validate("Mapping Code", ITIMappingTable."Mapping Code");
                ITIMappingTableField.Validate("Source Table Name", ITIMappingTable."Source Table Name");
                ITIMappingTableField.Validate("Target Table Name", ITIMappingTable."Target Table Name");
                ITIMappingTableField.Validate("Source Field Name", ITIMigrDatasetTableField."Source Field Name");
                ITIMappingTableField.Validate("Target Field Name", ITIMigrDatasetTableField."Target Field name");
                ITIMappingTableField.Skip := ITIMigrDatasetTableField."Skip in Mapping";
                ITIMappingTableField.Constant := ITIMigrDatasetTableField."Mapping Type" = ITIMigrDatasetTableField."Mapping Type"::ConstantToField;
                ITIMappingTableField.Insert(true);

                CopyAdditionalFields(ITIMigrDatasetTableField, ITIMappingTable."Mapping Code");

                if not ITIMigrDatasetTableField."Skip in Mapping" then
                    CopyOptionMappings(ITIMappingTableField, ITIMigrDatasetTableField);
            until ITIMigrDatasetTableField.Next() = 0;
    end;

    local procedure CopyOptionMappings(ITIMappingTableField: Record "ITI Mapping Table Field"; ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field")
    var
        ITIMappingTableFieldOptions: Record "ITI Mapping Table Field Option";
        ITIMigrDsTblFldOption: Record "ITI Migr. Ds. Tbl. Fld. Option";
    begin
        ITIMigrDsTblFldOption.SetRange("Migration Dataset Code", ITIMigrDatasetTableField."Migration Dataset Code");
        ITIMigrDsTblFldOption.SetRange("Source table name", ITIMigrDatasetTableField."Source table name");
        ITIMigrDsTblFldOption.SetRange("Source Field Name", ITIMigrDatasetTableField."Source Field Name");
        if ITIMigrDsTblFldOption.FindSet() then
            repeat
                ITIMappingTableFieldOptions.Reset();
                ITIMappingTableFieldOptions.Validate("Mapping Code", ITIMappingTableField."Mapping Code");
                ITIMappingTableFieldOptions.Validate("Source Table Name", ITIMappingTableField."Source Table Name");
                ITIMappingTableFieldOptions.Validate("Source Field Name", ITIMappingTableField."Source Field Name");
                ITIMappingTableFieldOptions.Validate("Target Table Name", ITIMappingTableField."Target Table Name");
                ITIMappingTableFieldOptions.Validate("Target Field Name", ITIMappingTableField."Target Field Name");
                ITIMappingTableFieldOptions.Validate("Source Field Option", ITIMigrDsTblFldOption."Source Option ID");
                ITIMappingTableFieldOptions.Validate("Target Field Option", ITIMigrDsTblFldOption."Target Option ID");
                ITIMappingTableFieldOptions.Insert(true);
            until ITIMigrDsTblFldOption.Next() = 0;
    end;

    local procedure CopyAdditionalFields(ITIMigrDatasetTableField: Record "ITI Migr. Dataset Table Field"; MappingCode: Code[20])
    var
        ITIMappingAddTargetField: Record ITIMappingAddTargetField;
        ITIMigrDsTableFieldAddTarget: Record ITIMigrDsTableFieldAddTarget;
    begin
        ITIMigrDsTableFieldAddTarget.SetRange("Migration Dataset Code", ITIMigrDatasetTableField."Migration Dataset Code");
        ITIMigrDsTableFieldAddTarget.SetRange("Source table name", ITIMigrDatasetTableField."Source table name");
        ITIMigrDsTableFieldAddTarget.SetRange("Source Field Name", ITIMigrDatasetTableField."Source Field Name");

        if ITIMigrDsTableFieldAddTarget.FindSet() then
            repeat
                ITIMappingAddTargetField.Init();
                ITIMappingAddTargetField."Mapping Code" := MappingCode;
                ITIMappingAddTargetField."Source Table Name" := ITIMigrDatasetTableField."Source table name";
                ITIMappingAddTargetField."Source Field Name" := ITIMigrDatasetTableField."Source Field Name";
                ITIMappingAddTargetField."Additional Target Field" := ITIMigrDsTableFieldAddTarget."Target Field Name";
                ITIMappingAddTargetField."Target Table Name" := ITIMigrDsTableFieldAddTarget."Target table name";
                ITIMappingAddTargetField.Insert();
            until ITIMigrDsTableFieldAddTarget.Next() = 0;


    end;

    var
        ITICopyMappingDialog: Page "ITI Copy Mapping Dialog";
}
