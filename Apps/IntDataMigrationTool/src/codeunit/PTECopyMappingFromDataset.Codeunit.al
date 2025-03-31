codeunit 99014 "PTE Copy Mapping From Dataset"
{
    TableNo = "PTE Migration Dataset";

    trigger OnRun()
    begin
        if PTECopyMappingDialog.RunModal() = Action::OK then
            CreateNewMapping(PTECopyMappingDialog.GetMappingCode(), PTECopyMappingDialog.GetMappingDescription(), Rec);
    end;

    local procedure CreateNewMapping(MappingCode: Code[20]; MappingDescription: Text[150]; PTEMigrationDataset: Record "PTE Migration Dataset");
    var
        PTEMapping: Record "PTE Mapping";
        PTEMappingTable: Record "PTE Mapping Table";
        PTEMigrationDatasetTable: Record "PTE Migration Dataset Table";
    begin
        PTEMapping.Code := MappingCode;
        PTEMapping.Description := MappingDescription;
        PTEMapping.Insert(true);

        PTEMigrationDatasetTable.SetRange("Migration Dataset Code", PTEMigrationDataset.Code);
        if PTEMigrationDatasetTable.FindSet() then
            repeat
                PTEMappingTable.Reset();
                PTEMappingTable.Validate("Mapping Code", MappingCode);
                PTEMappingTable.Validate("Source Table Name", PTEMigrationDatasetTable."Source Table Name");
                PTEMappingTable.Validate("Target Table Name", PTEMigrationDatasetTable."Target table name");
                PTEMappingTable.Skip := PTEMigrationDatasetTable."Skip in Mapping";
                PTEMappingTable.Insert(true);

                CopyFieldMappings(PTEMappingTable, PTEMigrationDatasetTable);
            until PTEMigrationDatasetTable.Next() = 0;
    end;

    local procedure CopyFieldMappings(PTEMappingTable: Record "PTE Mapping Table"; PTEMigrationDatasetTable: Record "PTE Migration Dataset Table")
    var
        PTEMappingTableField: Record "PTE Mapping Table Field";
        PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field";
    begin
        PTEMigrDatasetTableField.SetRange("Migration Dataset Code", PTEMigrationDatasetTable."Migration Dataset Code");
        PTEMigrDatasetTableField.SetRange("Source table name", PTEMigrationDatasetTable."Source Table Name");
        if PTEMigrDatasetTableField.FindSet() then
            repeat
                PTEMappingTableField.Reset();
                PTEMappingTableField.Validate("Mapping Code", PTEMappingTable."Mapping Code");
                PTEMappingTableField.Validate("Source Table Name", PTEMappingTable."Source Table Name");
                PTEMappingTableField.Validate("Target Table Name", PTEMappingTable."Target Table Name");
                PTEMappingTableField.Validate("Source Field Name", PTEMigrDatasetTableField."Source Field Name");
                PTEMappingTableField.Validate("Target Field Name", PTEMigrDatasetTableField."Target Field name");
                PTEMappingTableField.Skip := PTEMigrDatasetTableField."Skip in Mapping";
                PTEMappingTableField.Constant := PTEMigrDatasetTableField."Mapping Type" = PTEMigrDatasetTableField."Mapping Type"::ConstantToField;
                PTEMappingTableField.Insert(true);

                CopyAdditionalFields(PTEMigrDatasetTableField, PTEMappingTable."Mapping Code");

                if not PTEMigrDatasetTableField."Skip in Mapping" then
                    CopyOptionMappings(PTEMappingTableField, PTEMigrDatasetTableField);
            until PTEMigrDatasetTableField.Next() = 0;
    end;

    local procedure CopyOptionMappings(PTEMappingTableField: Record "PTE Mapping Table Field"; PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field")
    var
        PTEMappingTableFieldOptions: Record "PTE Mapping Table Field Option";
        PTEMigrDsTblFldOption: Record "PTE Migr. Ds. Tbl. Fld. Option";
    begin
        PTEMigrDsTblFldOption.SetRange("Migration Dataset Code", PTEMigrDatasetTableField."Migration Dataset Code");
        PTEMigrDsTblFldOption.SetRange("Source table name", PTEMigrDatasetTableField."Source table name");
        PTEMigrDsTblFldOption.SetRange("Source Field Name", PTEMigrDatasetTableField."Source Field Name");
        if PTEMigrDsTblFldOption.FindSet() then
            repeat
                PTEMappingTableFieldOptions.Reset();
                PTEMappingTableFieldOptions.Validate("Mapping Code", PTEMappingTableField."Mapping Code");
                PTEMappingTableFieldOptions.Validate("Source Table Name", PTEMappingTableField."Source Table Name");
                PTEMappingTableFieldOptions.Validate("Source Field Name", PTEMappingTableField."Source Field Name");
                PTEMappingTableFieldOptions.Validate("Target Table Name", PTEMappingTableField."Target Table Name");
                PTEMappingTableFieldOptions.Validate("Target Field Name", PTEMappingTableField."Target Field Name");
                PTEMappingTableFieldOptions.Validate("Source Field Option", PTEMigrDsTblFldOption."Source Option ID");
                PTEMappingTableFieldOptions.Validate("Target Field Option", PTEMigrDsTblFldOption."Target Option ID");
                PTEMappingTableFieldOptions.Insert(true);
            until PTEMigrDsTblFldOption.Next() = 0;
    end;

    local procedure CopyAdditionalFields(PTEMigrDatasetTableField: Record "PTE Migr. Dataset Table Field"; MappingCode: Code[20])
    var
        PTEMappingAddTargetField: Record PTEMappingAddTargetField;
        PTEMigrDsTableFieldAddTarget: Record PTEMigrDsTableFieldAddTarget;
    begin
        PTEMigrDsTableFieldAddTarget.SetRange("Migration Dataset Code", PTEMigrDatasetTableField."Migration Dataset Code");
        PTEMigrDsTableFieldAddTarget.SetRange("Source table name", PTEMigrDatasetTableField."Source table name");
        PTEMigrDsTableFieldAddTarget.SetRange("Source Field Name", PTEMigrDatasetTableField."Source Field Name");

        if PTEMigrDsTableFieldAddTarget.FindSet() then
            repeat
                PTEMappingAddTargetField.Init();
                PTEMappingAddTargetField."Mapping Code" := MappingCode;
                PTEMappingAddTargetField."Source Table Name" := PTEMigrDatasetTableField."Source table name";
                PTEMappingAddTargetField."Source Field Name" := PTEMigrDatasetTableField."Source Field Name";
                PTEMappingAddTargetField."Additional Target Field" := PTEMigrDsTableFieldAddTarget."Target Field Name";
                PTEMappingAddTargetField."Target Table Name" := PTEMigrDsTableFieldAddTarget."Target table name";
                PTEMappingAddTargetField.Insert();
            until PTEMigrDsTableFieldAddTarget.Next() = 0;


    end;

    var
        PTECopyMappingDialog: Page "PTE Copy Mapping Dialog";
}
