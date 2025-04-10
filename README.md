# Data Migration Tool for Business Central

## Overview

The **Data Migration Tool** enables fast and efficient migration of data from **Dynamics NAV 2009** and later versions to **Business Central**. Migration is performed in a single step by executing automatically generated SQL queries directly on the source or target SQL server.

## Key features

- **Complete data migration**
- **Launch Business Central production version at any time**
- **One-step migration** from Dynamics NAV 2009 and later versions
- **Migration of standard application data and add-on modules** (e.g., Polish Localization)
- **Quick migration of large data volumes**
- **Supported data mapping**
- **Mapping validation checks**
- **Ability to export and import mapping configurations**

> [!CAUTION]
> You can only use the Data Migration Tool if **applications containing Table Extensions are not used** on the source side.

> [!CAUTION]
> You can only use the Data Migration Tool if the **multi-tenant environment is not used** on the target side.

## Operation Diagram

![Operation Diagram](Schema.png "Operation Diagram")

The Data Migration Tool can also be used when the target and source databases are located on the same server.

## Installation Requirements

The Data Migration Tool can be installed on any Business Central instance version 22.3 or later. The instance must have access to the migrated SQL servers (source and target). Access can be provided via VPN. The speed of data transfer does not significantly affect the migration process.

> [!TIP]
> After installing the application, it is recommended to set the user role to **Data Migration Specialist** for easier operation.

## Data Migration Steps

The data migration process involves the following high-level steps:

1. Define the databases involved in the migration process.
2. Retrieve the metadata.
3. Verify metadata correctness.
4. Create a migration dataset.
5. Save and use mappings.
6. Release the migration dataset.
7. Create a migration record.
8. Generate SQL queries.
9. Execute SQL queries.

Each step is discussed in detail in the following sections.

## Database Setup

### Define Database Settings

To configure database settings:

1. Choose the **Search** icon, enter **SQL Databases**, and select the related link.
2. On the **SQL Databases** page, configure the following fields:
   - **Code**
   - **Server Name**
   - **Database Name**
   - **User Name**
   - **Password**
   - **Use Metadata Set Code** (for NAV versions earlier than 2013 R2)
   - **Forbidden Chars** (auto-populated)
   - **Application Version** (auto-populated)

> [!CAUTION]
> The database user must have permissions to read and modify all data in the database.

> [!CAUTION]
> Create two separate records for the source and target SQL databases.

### Metadata Download

Metadata describes the structure of NAV and BC objects in the SQL database. It is used to:

- Create mapping structures.
- Validate mappings.
- Generate SQL queries for migration.

#### Download Metadata for NAV 2013 R2 and Later

To retrieve metadata:

1. Search for and open **SQL Databases**.
2. Select the database.
3. Choose **Get Metadata**.

The process might take several minutes depending on database complexity.

#### Download Metadata for NAV 2009 to 2013 R2

For NAV versions earlier than 2013 R2:

1. Export metadata using a provided codeunit.
2. Adjust, import, and compile *Codeunit 90010 Export Objects Metadata*.
3. Run the codeunit and save the metadata file.
4. Import the metadata into the Data Migration Tool.
5. Link the metadata to the database and retrieve it.

## Migration Dataset

A migration dataset represents the data to be migrated. It includes source and target tables and fields.

### Create a Migration Dataset

To configure a migration dataset:

1. Search for **Migration Datasets**.
2. Create or modify a migration dataset.
3. Configure fields under **General** and **Migration Dataset Tables**.

#### Populate Migration Dataset Tables

You can manually or automatically insert tables.

- **Manual:** Select source and target tables manually.
- **Automatic:** Use **Insert Tables** to populate based on data presence.

#### Map Table Fields

- Configure source and target fields.
- Validate mapping errors and warnings.
- Handle `Option` type fields with option mappings.

##### Additional Target Fields

Map one source field to multiple target fields if required.

## Saving and Using Mappings

Mappings can be created manually, from datasets, or imported/exported as files.

- **Manual Mapping:** Define source/target tables and fields.
- **Mapping from Dataset:** Save dataset as a reusable mapping.
- **Import/Export Mapping:** Share mappings across projects.

Mappings can:

- Insert tables and field mappings into new datasets.
- Update existing migration datasets.

## Releasing the Migration Dataset

Before generating SQL queries, release the migration dataset to validate its settings.

If errors exist, fix them first. You can view errors and warnings by selecting their counters.

## Creating a Migration

Each migration defines:

- Source and target companies.
- Execution server (source or target).
- Whether to use transactions.

Configure migrations under **Migrations**.

## Generating and Administering SQL Queries

### Generate SQL Queries

To generate:

1. Open **Migrations**.
2. Select the migration.
3. Choose **Generate Queries**.

### View and Edit SQL Queries

- Preview linked server queries.
- Preview and edit data transfer queries.
- Download queries as text files.

> [!CAUTION]
> Data transfer queries include the linked server query at the start.

## Running and Monitoring Migrations

> [!CAUTION]
> Running migration deletes all data from target tables.

### Run All Queries

- Use **Execute In Background** for sequential execution.

### Run a Single Query

- Open generated queries and execute individually.

### Monitor Background Sessions

- View background sessions linked to migrations.
- Inspect session events and statuses.

### Review Migration Log

- Track executed queries.
- View errors, timestamps, and user details.
