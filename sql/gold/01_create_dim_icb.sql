-- ===========================================================
-- NHS A&E Data Warehouse
-- Layer : Gold
-- Script: 01_create_dim_icb.sql
--
-- Purpose
-- Integrated Care Board Dimension
-- One record per NHS ICB.
-- ===========================================================

CREATE SCHEMA IF NOT EXISTS gold;

DROP TABLE IF EXISTS gold.dim_icb CASCADE;

CREATE TABLE gold.dim_icb
(
    icb_key         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    icb_code        VARCHAR(20) NOT NULL UNIQUE,

    icb_name        VARCHAR(255) NOT NULL,

    region_name     VARCHAR(255)
);