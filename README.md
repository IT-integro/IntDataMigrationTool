# Data Migration Tool

Data Migration Tool is used to quickly migrate data between Dynamics NAV 2009 and later versions to Business Central. The migration is performed in one step by using automatically generated SQL queries that are executed directly on the source or target server.
The main advantages of using Data Migration Tool are:

1. Complete data migration
2. Ability to launch a Business Central production version at any time
3. One-step migration of Dynamics NAV 2009 and later versions to Business Central
4. Migration of standard application data and add-on modules (e.g. Polish Localization)
5. Quick migration of large data volumes
6. Supported data mapping
7. Mapping validation check
8. Ability to export and import a mapping

> [!CAUTION]
> You can only use Data Migration Tool if **applications that contain Table Extensions are not used on the source side**.

> [!CAUTION]
> You can only use Data Migration Tool if the **multi-tenant environment is not used on the target side**.

Operation Diagram
![Operation Diagram](Schema.png "Operation Diagram")

Data Migration Tool can also be used when the target and source databases are located on the same server.

Data Migration Tool can be installed on any Business Central instance 22.3 and later versions. The condition is that the environment on which the instance is running (e.g. a container) has access to the migrated SQL servers (the source and target servers). Access can be provided via VPN. The speed of data transfer between the environment on which the application runs and SQL servers does not noticeably affect the migration process.

> [!TIP]
> After installing the application, for ease of use, we suggest setting the user role to **Data Migration Specialist**.

## Data migration steps

The steps to migrate data by using Data Migration Tool are listed below:

1. Define the databases involved in the migration process.
2. Get the metadata.
3. Verify the correctness of the downloaded metadata.
4. Create a migration dataset.
5. Save and use saved mappings.
6. Release the migration dataset.
7. Create a migration record.
8. Generate SQL queries.
9. Run SQL queries.

Each of the steps will be discussed in detail in the following sections.

## Database setup

The first step in the data migration process is to define the setup for the data used to access the source (NAV) and target (BC) SQL databases.

### Setup

To enter or modify database settings:

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **SQL Databases**, and then choose the related link.
2. On the **SQL Databases** page, fill in the following fields:
   - **Code** - Specifies the database code.
   - **Server Name** - Specifies the name of the server (or IP address) on which the defined database is located.
   - **Database Name** - Specifies the name of the database.
   - **User Name** - Specifies the name of the database user.
   - **Password** - Specifies the password of the database user account.
   - **Use Metadata Set Code** - Specifies the metadata code. This field is used in migration from versions earlier than NAV 2013 R2. For more information, see **Metadata download**.
   - **Forbidden Chars** - The field is completed automatically. Specifies characters that are not allowed in SQL table names.
   - **Application Version** - The field is completed automatically. Specifies the version of NAV or BC.

    > [!CAUTION]
    > The database user selected for migration must have permissions that allow them to read and modify all data in the database.

    > [!CAUTION]
    > On the **SQL Databases** page, create two separate records for the source and target SQL databases.

### Metadata download

The structure of NAV and BC objects is stored as metadata in the SQL database. Data Migration Tool uses this metadata to:

1. Create the necessary structures to easily set up table and field mappings.
2. Enable verification of the correctness of the mapping.
3. Generate SQL queries that are directly responsible for the migration process.

### Download metadata for Dynamics NAV 2013 R2 and later versions

To retrieve metadata from the database that supports system versions later than NAV 2013R2:

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **SQL Databases**, and then choose the related link.
2. On the **SQL Databases** page, select the database for which you want to retrieve metadata.
3. On the **Actions** tab, choose the **Get Metadata** action.
4. If the database settings were correctly defined, the metadata download process will start automatically.

The process of downloading metadata is quite complex and can take more than several minutes (depending on the complexity of the modification).
If the process is successful, the **Metadata Exists** field is selected automatically.

### Download metadata for Dynamics NAV 2009 to 2013 R2

For versions earlier than Dynamics NAV 2013 R2, Microsoft used an undocumented way of compressing data in Blob fields, which makes it impossible to download metadata directly. To enable the download of metadata in this case:

1. Download the codeunit that allows you to export data from earlier versions of the system.

    - Choose the ![ ](search-small.png "Tell me what you want to do")  icon, enter **Application Metadata Set List**, and then choose the related link.
    - On the **Application Metadata Set List** page, run the **Get Export CU for NAV 2009** action.

2. Adjust the downloaded *Codeunit 90010 Export Objects Metadata* to your version of Dynamics NAV, then import it and compile. Use this codeunit to export the metadata to a file format that allows you to load it into Data Migration Tool.

3. Run the imported *Export Objects Metadata* codeunit and save the metadata file that is created.

4. Upload the metadata file into Data Migration Tool.

    * Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Application Metadata Set List**, and then choose the related link.
    * On the **Application Metadata Set List** page, create a new record and fill in the fields:
        **Code** - Specifies the code of metadata.
        **Description** - Specifies the description of metadata.
    * Run the **Import Metadata Set** action.
    * Select the file you exported in step 3 and import it.

5. Get the loaded metadata into the Data Migration Tool structure:

    * Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **SQL Databases**, and then choose the related link.
    * On the **Application Metadata Set List** page, select the database for which you want to retrieve metadata.
    * Expand the list in the **Use Metadata Set Code** field and select the metadata code you created in step 4.
    * Choose the **Get Metadata** action to import the data.

## Migration dataset

A migration dataset represents the collection of data that will be migrated from the source database to the target database. The set contains a list of source and target tables and a definition of source and target fields. Creating the correct migration dataset is critical to ensuring the migration process is correct.

### Create a migration dataset

To create or modify a migration dataset:

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Migration Datasets**, and then select the related link.
2. On the **Migration Datasets** page, create a new migration dataset or modify an existing one.
3. Enter the appropriate values in the **General** and **Migration Dataset Tables** sections.

The following sections contain a detailed description of each section of the **Migration Dataset Card**.

The **General** section contains the following fields:

- **Code** - Specifies the migration dataset code.
- **Source SQL Database Code** - Specifies the code of the source database (Dynamics NAV).
- **Target SQL Database Code** - Specifies the code for the target database (Business Central).
- **Description/Notes** - Specifies a description of the migration dataset.
- **Released** - Specifies whether the migration dataset has been released and can be used in the following steps of the migration process.

The **Migration Dataset Tables** section contains detailed setup for migrated tables and fields.

- **Source Table Name** - Specifies the name of the source table.
- **Target Table Name** - Specifies the name of the target table.
- **Description/Notes** - Specifies any description that the user enters as a comment supplementing the data.
- **Skip In Mapping** - Specifies whether a selected table will be excluded in the migration process.
- **Number Of Errors** - Specifies the number of errors in mapping validation.
- **Number of Warnings** - Specifies the number of warnings in  mapping validation.

#### Completing the migration dataset tables

You can fill in the migration dataset tables automatically or manually.

##### Complete migration dataset tables manually

To manually complete the list of tables to be migrated in the selected migration dataset in the **Migration Dataset Tables** section of the **Migration Dataset Card** page:

1. Use the AssistEdit button in the **Source Table Name** field to select the name of the source table.
2. Use the AssistEdit button in the **Target Table Name** field to select the name of the target table.

##### Auto-insert and complete migration dataset tables

To autopopulate the list of tables to be migrated in the selected migration dataset in the **Migration Dataset Tables** section of the **Migration Dataset Card** page:

1. On the **Migration Dataset Card** page of the selected dataset, choose the **Insert Tables** action.
2. Set up the following parameters:
    - **Insert option** - Specifies which tables are to be inserted. The following options are possible:
        * **All Tables** - The system will populate all source tables and then match the target tables.
        * **Tables Contain Data** - The system will populate the source tables that contain data (but only those with the **Data Per Company** parameter set to **Yes**) and then match the target tables.
        * **Common Tables Contain Data** - The system will populate the source tables that contain data (but only those with the **Data Per Company** parameter set to **No**) and then match the target tables.
    - **All Companies** - If the **Tables Contain Data** option is selected in the previous selection, the field specifies whether the system should insert tables containing data in any company.
    - **Selected Company** - If the **All Companies** option is not selected in the previous selection, specify which source company should be used by the system to determine whether the table contains data. 
3. Choose the **OK** button to start autopopulating the migration dataset tables.

#### Mapping migration dataset table fields

Each migration dataset table contains detailed settings for the source and target fields. When you add tables to a list in the **Migration Dataset Tables** section, the system automatically enters values in the source and target fields for a selected table. If all fields of the source and target tables have the same names and data types, the system will automatically apply the appropriate setup. However, if the field names are different, you will need to adjust the settings manually.
To check the list of fields:

1. In the **Migration Dataset Tables** section, select the line where the source and target tables have been specified.
2. Choose the **Fields** action to go to the **Migration Dataset Table Fields** table that contains the list of source and target fields for a selected table.
3. Complete or modify the field values.

- **Mapping Type** - Specifies the type of mapping. The following values are possible:
    * **Field to Field** - The value of the source field will be assigned to the target field. 
    * **Constant to Field**- Any fixed value can be assigned to the target field, e.g. when a new field has been added in the target table, to which you want to assign a fixed value.
- **Source Field Name** - Specifies the name of the source field from the source table. Use the AssistEdit button to select a field name in the list.
- **Target Field Name** - Specifies the name of the target field in the target table. Use the AssistEdit button to select a field name in the list.
- **No. of Target Field Proposals** - The field is calculated automatically and specifies the number of proposals for the target field names. If there is no field with the same name in the target table, the system attempts to find the name of the target field based on a part of the source name. For example, if the **Descirption 3** field was added to the source table during the modification process, it is likely that an extension of the table was added to the target table, where the field’s name is *ITI Description 3* (the extension prefix added). In this case, the system will not match the target field automatically (the value will be empty), but the value **No. of Target Field Proposals** will not be zero. Choose the non-zero value of the **No. of Target Field Proposals** field and select a field in the suggested field list.
- **Is Empty** - Specifies whether the value of the source field is populated in any record in the source database. This information helps you decide whether to migrate a selected source field when the target field is difficult to determine, or if the table field has been deleted in the target database. To ensure good performance of the applictaion, the values in the **Is Empty** field are not calculated automatically. Choose the **Get Empty Fields Count** action to calculate the values. After the value is calculated, you can select the **Is Empty field** value to view the number of empty and completed records. This can be helpful in making a decision when the field is not empty, but for example, it is filled in a few out of several thousand records.
- **Number of Errors** - Specifies the number of validation errors in a given mapping.
- **Number of Warnings** - Specifies the number of validation warnings in a given mapping.
- **Comments** - Specifies a comment you add to a given mapping.
- **Ignore Errors** - Specifies whether errors and warnings will be ignored in the field. By selecting the field, you can deliberately ignore the error or warning.
- **Skip in Mapping** - Specifies whether the field should be excluded in the migration process.

##### Completing the mapping options of data migration table fields

Fields that contain the **Option** data type require that the source options be mapped to the target options. All source options must be mapped to target options. If the field option names of the source and target table are the same, the system automatically performs the mapping. However, in the case of differences, the mapping must be done manually.
To view the mapping setup for table field options, on the **Migration Dataset Table FIelds** page, select the field that contains the **Option** data type, and then choose the **Options Mapping** action.

The action opens the **Migration Dataset Table Field Options** page that contains the option mapping settings:

- **Source Option ID** - Specifies the option identifier of the source field. Use the AssistEdit button to select an option ID from the list.
- **Source Option Name** - Specifies the name of the source field option. The value is auto-populated based on the identifier.
- **Target Option ID** - Specifies the option ID of the target field. Use the AssistEdit button to select an option ID from the list.
- **Target Option Name** - Specifies the name of the target field option. The value is auto-populated based on the identifier.

##### Additional target fields

By default, one source table field is mapped to one target table field. However, in specific cases, you may want to move the value of the source table field to multiple target table fields. In this case:

1. On the **Migration Dataset Table Fields** page, choose the **Additional Target Fields** action.
2. Use the AssistEdit button to select the target fields you want to map to.

## Saving and using saved mappings

With Data Migration Tool, you can create mappings and export and import prepared mappings. This functionality speeds up the creation of migration dataset setup by applying a typical mapping that is specific to the application used in many organizations to prepared tables and fields.

### Creating a mapping

There are several ways to create a new mapping.

#### Creating a mapping manually

The mapping can be created entirely manually.

1. Choose the ![ ](search-small.png "Tell me what you want to do")  icon, enter **Mappings**, and then choose the related link.
2. To create a new mapping, fill in the following fields on the **Mappings** page:

- **Code** - Specifies the mapping code.
- **Description** - Specifies the description of the mapping.

3. Choose the **Tables** action to define the source and target tables. Fill in the fields:

- **Source Table Name** - Specifies the name of the source table.
- **Target Table Name** - Specifies the name of the target table.

4. To define field mappings, choose the **Fields** action and fill in the fields:

- **Source Field Name** - Specifies the name of the source field of the source table.
- **Target Field Name** - Specifies the target field name of the target table.

5. For fields with the **Option** type, choose the **Field Options** action and fill in the fields:

- **Source Field Option** - Specifies the identifier of the source option.
- **Target Field Option** - Specifies the identifier of the target option.

#### Creating a mapping from a migration dataset

The migration dataset can be saved as a mapping and used in another project or, for example, during a production migration to another environment.

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Migration Datasets**, and then select the related link.
2. On the **Migration Datasets** page, select the migration dataset for which you want to save the mapping and choose the **Edit** action.
3. On the **Migraton Dataset Card** page, choose the **Mapping/Create Mapping from Dataset** action.
4. Enter the **Code** and **Description** values for the new mapping and select the **OK** button.

The system will automatically create a mapping based on the data migration set.

#### Exporting and importing a mapping from a file

The created mapping can be exported to a file and then imported into another project or e.g. during a production migration.

##### Exporting a mapping

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Mappings**, and then choose the related link.
2. On the **Mappings** page, select the mapping you want to export to a file.
3. Then choose the **Export Mapping** action.

The mapping file will be saved in the location where files downloaded from your web browser are stored by default.

##### Importing a mapping

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Mappings**, and then choose the related link.
2. On the **Mappings** page, create a new mapping and fill in the fields:

- **Code** - Specifies the mapping code.
- **Description** - Specifies the description of the mapping.

3. Choose the **Import Mapping** action.
4. Select the file that contains the exported mapping.

The mapping file is loaded into the newly created mapping.

### Using a mapping

The mapping can be used in two ways

#### Inserting tables and field mapping setup into a migration dataset

To insert tables and field mapping settings into a new migration dataset:

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Migration Datasets**, and then select the related link.
2. On the **Migration Datasets** page, select the migration dataset to which you want to insert the mapping and choose the **Edit** action.
3. On the **Migraton Dataset Card** page, choose the **Mapping/Insert Mapping** action.
4. Select the mapping code that you want to insert into the selected migration dataset.
5. Select the **OK** button.

Mapping tables and setup contained in the selected mapping are inserted into the selected migration dataset.

#### Complete mapping setup in the existing migration dataset

The saved mapping can contain the mapping setup for the selected functionality or application (e.g. Polish Localization or HR & Payroll Manager).

To automate the process of table and field mapping, the selected mapping can be applied to the existing migration dataset setup. In this case, table field mapping setup will be completed automatically in the existing migration dataset without adding new tables.

To complete the existing mapping in the migration dataset:

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Migration Datasets**, and then select the related link.
2. On the **Migration Datasets** page, select the migration dataset to which you want to apply the saved mapping and choose the **Edit** action.
3. On the **Migraton Dataset Card** page, select the **Mapping/Update Mapping** action.
4. Select the mapping code you want to apply to the selected migration dataset.
5. Select the **OK** button.

## Releasing the migration dataset

Before you can use the settings in the migration dataset to generate SQL queries, you must release the migration set that you created. During this process, the system automatically validates the migration dataset settings.It is not possible to release migration dataset if it contains errors.

To release the migration dataset you created:

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Migration Datasets**, and then select the related link.
2. On the **Migration Datasets** page, select the migration dataset you want to release and choose the **Edit** action.
3. On the **Migraton Dataset Card** page, choose the **Release** action.
4. If the migration dataset contains no errors, the **Released** field is selected.

If the migration dataset contains errors, resolve all error messages and try to release the migration dataset again.
The number of errors and extensions can be viewed in the **Errors & Warnings** section in the fields:

- **Number of Errors** - Specifies the total number of errors in the migration dataset.
- **Number of Warnings** - Specifies the total number of warnings in the migration dataset.
- **Number of Skipped Errors** - Specifies the total number of errors in the migration dataset for which the **Skip Errors** field is checked in the mapping setup.
- **Number of Skipped Warnings** - Specifies the total number of warnings in the migration dataset for which the **Skip Errors** field is checked in the mapping setup.

To access the list of errors or warnings, click the number representing the value.

The **Number of Errors** and **Number of Warnings** fields are also displayed in the **Migration Dataset Tables** section and in the field and field options setup.

## Creating a migration

With Data Migration Tool, you can create setup to run the migration independently for each source and target company.

To create a new migration:

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Migrations**, and then choose the related link.
2. On the **Migrations** page, create a new migration or modify an existing one.
3. Fill in the fields:

    * **Code** - Specifies the migration code.
    * **Executed** - Specifies whether the migration has been run. The field is automatically completed by the system.
    * **Generated Queries** - Specifies whether SQL queries have been generated for the migration.
    * **Migration Dataset Code** - Specifies which migration dataset to use to generate SQL queries.
    * **Source SQL Database Code** - Specifies the source SQL database code. The field is auto-populated based on the migration dataset code.
    * **Source Company Name** - Specifies the name of the source company from which the data will be retrieved.
    * **Target SQL Database Code** - Specifies the code of the target SQL database. The field is auto-populated based on the migration dataset code.
    * **Target Company Name** - Specifies the name of the source company to which the data will be inserted.
    * **Execute on** - Specifies on which server SQL queries will be run. There are two options to choose from: **Target** - Queries will run on the target server, **Source** - Queries will run on the source server. The **Target** option is selected by default.
    * **Do Not Use Transaction** - Specifies whether queries will be executed in transactions. If SQL servers do not support distributed transactions, the field must be selected.

## Generating and administering SQL queries

Before you can start the migration process, you need to generate SQL queries.

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Migrations**, and then choose the related link.
2. On the **Migrations** page, select the migration for which you want to generate SQL queries.
3. Choose the **Generate Queries** action to generate SQL queries.

The system will start generating SQL queries. If the process is successful, the **Generated Queries** field will be selected automatically.

### Generated SQL queries

To check which SQL queries were generated:

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Migrations**, and then choose the related link.
2. On the **Migrations** page, select the migration for which the **Generated Queries** field is selected.
3. Choose the **Related/Queries** action.
4. The **Migration SQL Queries** page contains non-editable fields:

    * **Query No** - Specifies the number of the generated SQL query for the migration.
    * **Description** - Specifies an automatically generated query description Source Table Name -> Target Table Name.
    * **Executed** - Specifies whether the query was run.
    * **Modified** - Specifies whether the query has been manually modified.
    * **Running in Bacground Session** - Specifies whether the query is currently running in the remote session.

### Preview of generated SQL queries

Data Migration Tool generates two types of SQL queries:
- SQL linked server queries,
- data transfer queries.

When the migration is triggered, the linked server query is executed first, followed by one or more data transfer queries.

#### SQL linked server queries

To edit or preview a SQL linked server query:

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Migrations**, and then choose the related link.
2. On the **Migrations** page, select the migration for which the **Generated Queries** field is selected.
3. Choose the **Related/Edit Linked Server Query** action to preview and edit a query. 

On the Edit Linked Server Query page you can make modifications to the displayed query.
To save your changes, choose the **Save** action.

#### Data transfer queries

To edit or preview the SQL query responsible for data transfer:

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Migrations**, and then choose the related link.
2. On the **Migrations** page, select the migration for which the **Generated Queries** field is selected.
3. Choose the **Related/Queries** action.
4. Select the query you want to preview or edit.
5. Choose the **Edit Query Text** action to preview and edit the query.

The **Edit SQL Query** page allows you to make modifications to the displayed query.
To save your changes, choose the **Save** action.

### Downloading the generated SQL queries

With Data Migration Tool you can run generated SQL queries. However, for various reasons, you may need to download the queries in a text file.

#### Downloading SQL queries

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Migrations**, and then choose the related link.
2. On the **Migrations** page, select the migration for which the **Generated Queries** field is selected.
3. Choose the **Related/Queries** action.
4. Select one or more queries that you want to download.
5. Choose the **Download Query Text** action to download the content of the queries to a text file.

> [!CAUTION]
> Data transfer queries you download contain the content of the linked server query at the beginning of the file.

## Running and monitoring migration

With Data Migration Tool you can run and monitor the execution of generated SQL queries.

> [!CAUTION]
> Running the migration deletes all existing data from the migrated tables in the target database.

#### Running data migration

To run all generated queries sequentially for the selected migration:

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Migrations**, and then choose the related link.
2. On the **Migrations** page, select the migration you want to run for which the **Generated Queries** field is selected.
3. Choose the **Execute In Background** action.
4. The system will start running queries sequentially in a background session.

### Running a single query

To run a single generated query for a selected migration:

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Migrations**, and then choose the related link.
2. On the **Migrations** page, select the migration for which the query should be run and for which the **Generated Queries** field is selected.
4. Choose the **Related/Queries** action to go to the list of generated SQL queries.
5. On the **Migration SQL Queries** page select the query you want to run.
5. Choose the **Execute In Background** action.
4. The system will start runnnig the query in a background session.

### Monitoring background sessions running SQL queries

To monitor the status of background sessions

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Migrations**, and then choose the related link.
2. On the **Migrations** page, select the migration that you want to monitor.
3. Choose the **Related/Migration Background Sessions** action.
4. The **Migr. Background Sessions** page contains the following fields:

    - **Migration Code** - Specifies the data migration code.
    - **Query No** - Specifies the number of the SQL query.
    - **Session Unique ID** - Specifies a unique session ID.
    - **Is Active** - Specifies whether the session is active.
    - **No Of Session Events** - Specifies the number of events (errors) of the session.
    - **Last Comment** - Specifies the last session error message. "Session event not found" means that the session ended correctly.

### Log of executed SQL queries

To monitor the status of executed queries

1. Choose the ![ ](search-small.png "Tell me what you want to do") icon, enter **Migrations**, and then choose the related link.
2. On the **Migrations** page, select the migration that you want to monitor.
3. Choose the **Related/Log Entries** action.
4. The **Migration Log Entries** page contains the following fields:

    - **Entry No** - Specifies the sequence number of the record.
    - **Error Description** - Specifies a description of the error that occurred during the execution of the query.
    - **Executed by User ID** - Specifies the identifier of the user who ran the query.
    - **Starting Date Time** - Specifies the date and time of running the query.
    - **Ending Date Time** - Specifies the date and time when query execution ends.
    - **Migration Code** - Specifies the data migration code.
    - **Query No** - Specifies the number of the SQL query.
    - **Query Description** - Specifies the description of the SQL query (Source Table Name - > Target Table Name).
