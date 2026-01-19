#  Global Air Transport Network
## Structural Fragility & Risk Analysis

---

##  Business Problem

Global air transport networks appear **vast and resilient**, yet they are often **structurally fragile beneath the surface**.

This project answers one business‑critical question:

> **“If one node fails, how much of the global air transport network is at risk?”**

The analysis focuses on **single‑point‑of‑failure (SPOF) risk** driven by:

- Airport hub concentration  
- Country‑level dependency  
- Airline operational hub reliance  
- Aircraft fleet standardisation  

This is a **structural risk assessment**, not a forecasting or simulation exercise.

---

##  Project Objective

To **identify and quantify hidden systemic fragility** in the global air transport network by analysing:

- Concentration of routes across airports  
- Country dependence on a single hub  
- Airline reliance on primary operational hubs  
- Fleet concentration around a single aircraft family  

> **Outcome:** a decision‑ready **risk narrative**, not a theoretical model.

---

##  What This Project Is *Not*

This project intentionally avoids:

- Demand forecasting  
- Delay prediction  
- Revenue or profitability modelling  
- Passenger flow simulation  
- Machine learning without clear business justification  

**Design principle:** explainability, credibility, and interview safety.

---

## Data Sources

Open, *OpenFlights* datasets covering:

- Airports  
- Airlines  
- Routes  
- Aircraft / equipment  
- Countries  

> Data was treated as **messy, real‑world operational data**, not pre‑cleaned analytics data.

---

## End‑to‑End Pipeline

```text
Raw Excel Files
   ↓
Data Audit (Excel)
   ↓
Data Cleaning (Excel + Power Query)
   ↓
CSV Export (Locked Schemas)
   ↓
MySQL Ingestion (LOAD DATA INFILE)
   ↓
Star Schema Modelling
   ↓
SQL EDA & Risk Metrics
   ↓
Power BI Executive Dashboard
```

Each step was **intentionally separated** to ensure:

- Traceability  
- Reproducibility  
- Auditability  

---

## Phase 1 — Data Audit (Excel)

Initial audit focused on **structural integrity**, not descriptive statistics.

### Key Checks

- Duplicate identifiers  
- Orphan airport references in routes  
- Invalid airline references  
- Directional vs bidirectional routes  
- Multi‑equipment route definitions  
- Missing or malformed codes  

### Key Findings

- Routes are **directional**  
- Many routes list **multiple aircraft types**  
- Orphaned airport references exist  
- Aircraft **equipment codes** are more reliable than model names  

---

## Phase 2 — Data Cleaning

### Airports

- Removed unused attributes (timezone, DST, altitude, etc.)  
- Enforced unique `airport_id`  
- Temporarily retained `country_name` for mapping  

### Airlines

- Normalised IATA / ICAO codes  
- Preserved inactive airlines (important for historical structure)  
- Removed malformed identifiers  

### Countries

- Created a clean country dimension  
- Introduced ISO‑2 and ISO‑3 codes  
- Assigned surrogate `country_id`  

### Aircraft

- Identified duplicate aircraft names with identical equipment codes  
- Treated **equipment code** as the business key  

### Routes

- Removed NULL source/destination rows  
- Preserved directional routes  
- Split multi‑equipment routes into row‑level representations  
- Retained raw equipment strings for fleet risk analysis  

---

## Phase 3 — CSV Standardisation

All datasets were exported as **single‑sheet CSVs** to avoid:

- Excel type coercion  
- Hidden formatting  
- Ambiguous schema definitions  

### Prepared Files

```text
dim_country.csv
dim_airline.csv
dim_airport.csv
dim_aircraft.csv
fact_routes.csv
```

---

## Phase 4 — MySQL Ingestion

### Ingestion Method

- Used `LOAD DATA INFILE` (server‑side)  
- Files placed in `secure_file_priv`  
- Avoided MySQL Workbench import wizard  

> **Why:** reproducibility, control, and production realism.

### Real‑World Handling

- Empty strings converted using `NULLIF()`  
- Type mismatches handled at load time  
- Multi‑value fields preserved intentionally  

---

## Phase 5 — Dimensional Modelling (Star Schema)

### Dimensions

#### `dim_country`

- `country_id` (surrogate key)  
- `country_name`  
- `iso_code_2`  
- `iso_code_3`  

#### `dim_airline`

- `airline_id` (business key)  
- `airline_name`  
- `iata`  
- `icao`  
- `active_flag`  

#### `dim_airport`

- `airport_id` (business key)  
- `airport_name`  
- `city`  
- `latitude` / `longitude`  
- `country_id`  

#### `dim_aircraft`

- `equipment_code` (business key)  
- `aircraft_family`  

### Fact Table — `fact_routes`

**Grain:**  
One *directional route* operated by *one airline*, possibly using *multiple aircraft types*.

#### Key Fields

- `airline_id`  
- `source_airport_id`  
- `destination_airport_id`  
- `equipment_code` (multi‑valued text preserved)  

---

## Analytical Focus (SQL EDA)

All metrics were designed to align **strictly with business risk**.

### Airport & Country Risk

- Total routes per airport  
- Global airport connectivity rank  
- Country dependency on top‑1 airport  
- Country risk classification *(High / Medium / Low)*  

### Airline Operational Risk

- Primary hub identification  
- Top‑1 hub dependency ratio  
- Operational SPOF classification  

### Fleet Concentration Risk

- Primary aircraft family per airline  
- Top‑1 fleet dependency ratio  
- Fleet‑based SPOF classification  

---

## Power BI Dashboard Structure

### Page 1 — Executive Overview

**Purpose:** Where is the global air network structurally fragile?

- KPI cards (airports, airlines, risk percentages)  
- Top global hubs  
- Country risk split  
- Executive insight summary  

### Page 2 — Airport & Country SPOF Risk

**Purpose:** Which airports and countries represent single points of failure?

- Top global airports by connectivity  
- Country dependency on top‑1 airport  
- Conditional risk highlighting  
- Country‑level vulnerability insights  

### Page 3 — Airline Operational Risk

**Purpose:** Are airlines operationally fragile despite network size?

- Airline hub dependency analysis  
- Risk classification by dependency ratio  
- Distribution of airline risk levels  
- Insights on hidden operational fragility  

### Page 4 — Fleet Concentration Risk

**Purpose:** What breaks if an aircraft family is grounded?

- Fleet risk distribution  
- Airlines with extreme fleet concentration  
- Technical SPOF identification  
- Systemic risk insights  

---

## Key Business Insights

- Large networks can still be **structurally fragile**  
- Over **50% of countries** depend on a single airport for connectivity  
- Airlines may appear diversified but rely heavily on:
  - One operational hub, or  
  - One aircraft family  
- Fleet standardisation creates **technical single‑point‑of‑failure risk**  

---

## Tools Used

- **Excel** — data audit & initial cleaning  
- **Power Query** — controlled transformations  
- **MySQL** — ingestion, modelling, SQL EDA  
- **Power BI** — executive dashboards & storytelling  

