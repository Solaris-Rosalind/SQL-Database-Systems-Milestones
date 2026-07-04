# Marathon Registration Database & Analytics System

**Snowflake-based ETL pipeline and analytics system for marathon race registration data — built in OSU Database Systems Development (A)**

---

## Overview

This project was completed as a final milestone in Database Systems Development at Oklahoma State University. Working in Snowflake, I designed and implemented a full ETL pipeline to normalize registration data from three inconsistently structured source tables (5K, Half Marathon, and Full Marathon) into a unified, third-normal-form relational schema.

The project is split into two milestones:

- **Milestone 1 — ETL & Normalization:** Data cleaning, deduplication, standardization, and schema design
- **Milestone 2 — Analytics & Reporting:** Complex analytical queries answering real business questions
- **Milestone 3 — Business Report:** Full written analysis of query results with data visualizations and actionable insights

---

## Milestone 1 — ETL Pipeline & Data Normalization

### The Problem
Three source tables (`REGISTRATIONS_5K`, `REGISTRATIONS_HALF`, `REGISTRATIONS_FULL`) contained registration data for different race distances, but each had:
- Inconsistent column naming (e.g. `FNAME`/`FIRST_NAME`/`GivenName`)
- Inconsistent gender encodings (`F`/`Female`/`Nonbinary`)
- Inconsistent t-shirt size formats (`Small`/`S`)
- Duplicate runner records
- Missing derived fields (distance, corral assignment)

### What I Built
- **Deduplication** using `ROW_NUMBER()` window functions to identify and remove duplicate runner entries
- **Data standardization** across all three source tables — normalizing gender values, shirt sizes, and column names into a consistent format
- **Business logic implementation** — corral assignment (A/B) based on projected finish time and gender, applied independently per distance
- **Master registration table** — a unified staging table combining all three normalized sources into a single consistent schema
- **3NF decomposition** — split the master table into `Runners` (runner profiles) and `RaceResults` (race-specific data) with proper primary and foreign keys

### Key Techniques
- Window functions (`ROW_NUMBER() OVER PARTITION BY`) for deduplication
- Conditional `CASE` statements for data standardization and business logic
- `ALTER TABLE` / `UPDATE` for schema evolution and in-place transformation
- Cross-table `INSERT INTO ... SELECT` for ETL loading
- Foreign key constraints for referential integrity

---

## Milestone 2 — Analytical Queries

Three complex business queries built on the normalized schema:

### 1. Merchandise Profitability per Race
> Which individual races generated the highest total profit from merchandise sales, and how does that compare to the number of items sold?

Uses multi-table JOINs across `RACES`, `MERCHANDISE`, and `RUNNER_PURCHASES` with `GROUP BY` and `ORDER BY` to rank races by profit margin.

### 2. Elite Runner Demographics by State
> Which states are producing the highest number of elite finishers (under 180 minutes), and what is the average finish time per state?

Uses multi-table JOINs, `WHERE` filtering, `GROUP BY` with `HAVING` to enforce minimum sample size, and `AVG()` aggregation.

### 3. Event Financial Efficiency
> For each race event, what was the net registration income after subtracting all expenses?

Uses a **Common Table Expression (CTE)** to pre-aggregate expenses, then joins against registration revenue data to calculate net income per event.

---

## Milestone 3 — Business Report

`Milestone_3_Business_Report.pdf` contains the complete writeup for the three analytical queries, including query logic explanations, result tables, and a data visualization (pie chart) for the elite runner demographics analysis.

### Key Findings
- **Chi-town Dash Marathon** generated the highest merchandise profit at $569K across 31,868 items sold
- **California** produced the most elite marathon finishers nationally (788), with an average finish time of 155.98 minutes
- **8 of 26 race events operated at a net loss** after expenses — identified using a CTE-based approach that prevented double-counting of expenses across roster joins

These findings demonstrate how SQL-driven analysis can surface actionable business insights: which race brands deserve larger merchandise investment, which geographic markets attract elite runners, and which events need operational cost review.

---

## Technologies Used
- **Snowflake** — cloud data warehouse
- **SQL** — DDL, DML, CTEs, window functions, aggregations, JOINs, subqueries

## Context
- Course: Database Systems Development (MSIS 3333), Oklahoma State University
- Final Grade: A
- Completed: Spring 2026
