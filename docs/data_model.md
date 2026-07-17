Data Model Document
NHS A&E Analytics Engineering Platform
Database: PostgreSQL
Architecture: Medallion (Bronze → Silver → Gold)
Modelling Approach: Kimball Star Schema
________________________________________
1. Purpose
This document describes the logical and physical data model used within the NHS A&E Analytics Engineering Platform.
The warehouse transforms NHS England monthly Accident & Emergency attendance publications into a dimensional model optimised for analytical workloads and Power BI reporting.
The Gold layer is designed around a star schema consisting of one central fact table and three conformed dimensions.

===================================================================================================================================================================================
2. Overall Architecture
Raw NHS CSV Files
        │
        ▼
Bronze Schema
(Raw Ingestion)
        │
        ▼
Silver Schema
(Cleaned & Enriched)
        │
        ▼
Gold Schema
(Dimensional Model)
        │
        ▼
Power BI

=================================================================================================================================================================================

3. Star Schema
                 dim_date
                     │
                     │
                     │
dim_provider ─── fact_ae_monthly ─── dim_icb
The warehouse follows a classic star schema.
•	One fact table 
•	Three dimensions 
•	Integer surrogate keys 
•	Foreign key relationships 
•	Fully denormalised dimensions for reporting performance 

=================================================================================================================================================================================

4. Fact Table
fact_ae_monthly
Granularity:
One row per provider per reporting month.
Primary Key
fact_id
Foreign Keys
provider_key
date_key
icb_key
Measures

|Column	                |Description
attendances	            Total A&E attendances
emergency_admissions	Admissions via A&E
seen_within_4hrs	    Patients seen within four hours
pct_seen_within_4hrs	Percentage seen within four hours
waits_over_12hrs	    12-hour waits
	
=================================================================================================================================================================================

5. Provider Dimension
dim_provider
Contains one record for every provider appearing across the full twelve-month dataset.
Primary Key
provider_key
Natural Key
provider_code
Attributes
|Column	        |Description
provider_code	NHS provider code
provider_name	NHS organisation name
provider_type	Derived provider classification

active_flag	Indicates provider appears in reporting period

=================================================================================================================================================================================

Provider Type
Unlike the source data, this warehouse introduces a derived attribute:
provider_type
Possible values:
•	Major Emergency Department 
•	Single Specialty A&E 
•	Minor Injury Unit / UTC 
•	Specialist Provider 
This classification enables like-for-like performance comparisons and prevents misleading benchmarking between fundamentally different provider types.

=================================================================================================================================================================================

6. Date Dimension
dim_date
Contains one record per reporting month.
Primary Key
date_key

Attributes

|Column	          |Description
reporting_month	   Month name
month_number	   Numeric month
year	           Calendar year
quarter	           Financial quarter
financial_year	   NHS financial year
	
=================================================================================================================================================================================

7. ICB Dimension
dim_icb
Stores Integrated Care Board metadata.
Primary Key
icb_key

Attributes 

|Column	    |Description
icb_code	 NHS ICB code
icb_name	 ICB name
nhs_region	 NHS England region

================================================================================================================================================================================	

8. Relationships
|Parent    	    |Child              |Relationship
dim_provider	fact_ae_monthly	    1 : Many
dim_date	    fact_ae_monthly	    1 : Many
dim_icb	        fact_ae_monthly	    1 : Many

All foreign key constraints are enforced within PostgreSQL.

=================================================================================================================================================================================

9. Surrogate Keys
The Gold layer uses integer surrogate keys instead of natural keys.
Benefits include:
•	Faster joins 
•	Stable relationships 
•	Simplified Power BI modelling 
•	Isolation from changes in NHS provider codes 
Natural identifiers remain available as descriptive attributes.

=================================================================================================================================================================================

10. Data Lineage
NHS England CSV
        │
Python ETL
        │
Bronze Tables
        │
SQL Transformations
        │
Silver Tables
        │
Star Schema
        │
Power BI


=================================================================================================================================================================================

11. Business Rules
The warehouse applies several business rules during modelling.

Provider Classification
Providers are categorised according to the types of A&E activity they report.
Missing Reference Data
Providers absent from the NHS reference mapping are retained and assigned an UNMAPPED placeholder rather than being discarded.
Numeric Standardisation
Numeric fields are converted to appropriate PostgreSQL numeric types after removing commas, percentage symbols, and placeholder values.
Provider Dimension Construction
The provider dimension is generated from all twelve reporting months rather than a single snapshot to accommodate provider churn.

=================================================================================================================================================================================

12. Design Decisions
|Decision	                         |Reason
Star schema                           Optimised for analytics and Power BI
Medallion architecture                Separates ingestion, cleansing, and reporting
Surrogate keys                        Improves join performance
Derived provider_type	              Enables meaningful benchmarking
Full historical provider dimension	  Prevents missing providers from later months
Validation before loading             Ensures data quality before entering warehouse
