codeunit 99007 "PTE Apply Mapping"
{
    procedure InsertMapping(PTEMigrationDataset: Record "PTE Migration Dataset")
    begin
        PTEApplyMapping(PTEMigrationDataset, true);
    end;

    procedure UpdateMapping(PTEMigrationDataset: Record "PTE Migration Dataset")
    begin
        PTEApplyMapping(PTEMigrationDataset, false);
    end;

    local procedure PTEApplyMapping(PTEMigrationDataset: Record "PTE Migration Dataset"; InsertMode: Boolean)
    var
        PTEMapping: Record "PTE Mapping";
        PTEMappingTable: Record "PTE Mapping Table";
        PTEMappingTableField: Record "PTE Mapping Table Field";
        PTEMappingTableFieldOption: Record "PTE Mapping Table Field Option";
        PTEMigrationDatasetTable: Record "PTE Migration Dataset Table";
        PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field";
        PTEMigrDsTblFldOption: Record "PTE Migr. Ds. Tbl. Fld. Option";
        PTEMappings: Page "PTE Mappings";
        UpdateConfirmationMsg: label 'This operation will applay mapping %1 to the dataset %2. Do you want to continue ?', Comment = '%1 = Mapping Code, %2= Migration Dataset Code';
        InsertConfirmationMsg: label 'This operation will insert mapping %1 to the dataset %2. Do you want to continue ?', Comment = '%1 = Mapping Code, %2= Migration Dataset Code';
    begin

        PTEMappings.LookupMode := true;
        PTEMappings.Editable := false;
        PTEMappings.SetTableView(PTEMapping);
        if PTEMappings.RunModal() = Action::LookupOK then begin
            PTEMappings.GetRecord(PTEMapping);
            if InsertMode then begin
                if not Confirm(InsertConfirmationMsg, false, PTEMapping.Code, PTEMigrationDataset.Code) then
                    exit;
            end else
                if not Confirm(UpdateConfirmationMsg, false, PTEMapping.Code, PTEMigrationDataset.Code) then
                    exit;
            //insert/update dataset tables
            PTEMappingTable.SetRange("Mapping Code", PTEMapping.Code);
            if PTEMappingTable.FindSet() then
                repeat
                    PTEMigrationDatasetTable.SetRange("Migration Dataset Code", PTEMigrationDataset.Code);
                    PTEMigrationDatasetTable.SetRange("Source Table Name", PTEMappingTable."Source Table Name");
                    if PTEMigrationDatasetTable.FindFirst() then begin
                        if (PTEMigrationDatasetTable."Target table name" = '') or (PTEMigrationDatasetTable."Target table name" <> PTEMappingTable."Target Table Name") then begin
                            PTEMigrationDatasetTable."Target SQL Database Code" := PTEMigrationDataset."Target SQL Database Code";
                            PTEMigrationDatasetTable.Validate("Target table name", PTEMappingTable."Target Table Name");
                            PTEMigrationDatasetTable.Validate("Skip in Mapping", PTEMappingTable.Skip);
                            PTEMigrationDatasetTable.Modify();
                        end;
                    end else
                        if InsertMode then begin
                            PTEMigrationDatasetTable.Init();
                            PTEMigrationDatasetTable."Migration Dataset Code" := PTEMigrationDataset.Code;
                            PTEMigrationDatasetTable."Source SQL Database Code" := PTEMigrationDataset."Source SQL Database Code";
                            PTEMigrationDatasetTable.Validate("Source Table Name", PTEMappingTable."Source Table Name");
                            PTEMigrationDatasetTable.Insert();
                            PTEMigrationDatasetTable."Target SQL Database Code" := PTEMigrationDataset."Target SQL Database Code";
                            PTEMigrationDatasetTable.Validate("Target table name", PTEMappingTable."Target Table Name");
                            PTEMigrationDatasetTable.Validate("Skip in Mapping", PTEMappingTable.Skip);
                            PTEMigrationDatasetTable.Modify();
                        end;
                until PTEMappingTable.Next() = 0;

            //update dataset fields
            PTEMappingTableField.SetRange("Mapping Code", PTEMapping.Code);
            PTEMappingTableField.SetRange(Constant, false);
            if PTEMappingTableField.FindSet() then
                repeat
                    PTEMigrDatasetTableField.SetRange("Migration Dataset Code", PTEMigrationDataset.Code);
                    PTEMigrDatasetTableField.SetRange("Source Table Name", PTEMappingTableField."Source Table Name");
                    PTEMigrDatasetTableField.SetRange("Source Field Name", PTEMappingTableField."Source Field Name");
                    if PTEMigrDatasetTableField.FindFirst() then begin
                        if PTEMigrDatasetTableField."Target Table name" = '' then
                            PTEMigrDatasetTableField."Target Table name" := PTEMappingTableField."Target Table Name";
                        if (PTEMigrDatasetTableField."Target Field name" = '') or (PTEMigrDatasetTableField."Target Field name" <> PTEMappingTableField."Target Field name") then
                            PTEMigrDatasetTableField.Validate("Target Field name", PTEMappingTableField."Target Field Name");
                        PTEMigrDatasetTableField.Validate("Skip in Mapping", PTEMappingTableField.Skip);
                        PTEMigrDatasetTableField.Modify();
                        InsertAdditionalTables(PTEMigrDatasetTableField, PTEMappingTableField."Mapping Code")
                    end;
                until PTEMappingTableField.Next() = 0;

            //update dataset field options
            PTEMappingTableFieldOption.SetRange("Mapping Code", PTEMapping.Code);
            if PTEMappingTableFieldOption.FindSet() then
                repeat
                    PTEMigrDsTblFldOption.SetRange("Migration Dataset Code", PTEMigrationDataset.Code);
                    PTEMigrDsTblFldOption.SetRange("Source Table Name", PTEMappingTableFieldOption."Source Table Name");
                    PTEMigrDsTblFldOption.SetRange("Source Field Name", PTEMappingTableFieldOption."Source Field Name");
                    PTEMigrDsTblFldOption.SetRange("Source Option ID", PTEMappingTableFieldOption."Source Field Option");
                    if PTEMigrDsTblFldOption.FindFirst() then begin
                        PTEMigrDsTblFldOption.CalcFields("Target Table Name", "Target Field name");
                        if PTEMigrDsTblFldOption."Target Table name" = '' then
                            PTEMigrDsTblFldOption."Target Table name" := PTEMappingTableFieldOption."Target Table Name";
                        if PTEMigrDsTblFldOption."Target Field name" = '' then
                            PTEMigrDsTblFldOption."Target Field name" := PTEMappingTableFieldOption."Target Field Name";
                        if (PTEMigrDsTblFldOption."Target Option Name" <> '') and ((PTEMigrDsTblFldOption."Target Option ID" = 0) or (PTEMigrDsTblFldOption."Target Option ID" <> PTEMappingTableFieldOption."Target Field Option")) then
                            PTEMigrDsTblFldOption.Validate("Target Option ID", PTEMappingTableFieldOption."Target Field Option");
                        PTEMigrDatasetTableField.Modify();
                    end;
                until PTEMappingTableFieldOption.Next() = 0;

            //update dataset constant 
            PTEMappingTableField.SetRange(Constant, true);
            if PTEMappingTableField.FindSet() then
                repeat
                    PTEMigrDatasetTableField.Init();
                    PTEMigrDatasetTableField."Migration Dataset Code" := PTEMigrationDataset.Code;
                    PTEMigrDatasetTableField.Validate("Source table name", PTEMappingTableField."Source Table Name");
                    PTEMigrDatasetTableField.Validate("Mapping Type", PTEMigrDatasetTableField."Mapping Type"::ConstantToField);
                    PTEMigrDatasetTableField.Validate("Source Field Name", PTEMappingTableField."Source Field Name");
                    PTEMigrDatasetTableField.Validate("Target Field Name", PTEMappingTableField."Target Field Name");
                    PTEMigrDatasetTableField.Insert();
                    InsertAdditionalTables(PTEMigrDatasetTableField, PTEMappingTableField."Mapping Code")
                until PTEMappingTableField.Next() = 0;
        end;
    end;

    local procedure InsertAdditionalTables(PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field"; MappingCode: Code[20])
    var
        PTEMigrDsTableFieldAddTarget: Record PTEMigrDsTableFieldAddTarget;
        PTEMappingAddTargetField: Record PTEMappingAddTargetField;
    begin
        PTEMappingAddTargetField.SetRange("Mapping Code", MappingCode);
        PTEMappingAddTargetField.SetRange("Source Table Name", PTEMigrDatasetTableField."Source table name");
        PTEMappingAddTargetField.SetRange("Source Field Name", PTEMigrDatasetTableField."Source Field Name");

        if PTEMappingAddTargetField.FindSet() then
            repeat
                PTEMigrDsTableFieldAddTarget.Init();
                PTEMigrDsTableFieldAddTarget."Migration Dataset Code" := PTEMigrDatasetTableField."Migration Dataset Code";
                PTEMigrDsTableFieldAddTarget."Source table name" := PTEMigrDatasetTableField."Source table name";
                PTEMigrDsTableFieldAddTarget."Source Field Name" := PTEMigrDatasetTableField."Source Field Name";
                PTEMigrDsTableFieldAddTarget."Target Field Name" := PTEMappingAddTargetField."Additional Target Field";
                PTEMigrDsTableFieldAddTarget."Target table name" := PTEMigrDatasetTableField."Target table name";
                PTEMigrDsTableFieldAddTarget.Insert();
            until PTEMappingAddTargetField.Next() = 0;
    end;
}
