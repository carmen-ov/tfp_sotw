## This is a test scripts for the PUDL data.

install.packages(c("arrow", "dplyr", "ggplot2"))

library(arrow)
library(dplyr)

## Open a remote parquet from PUDL's s3 >> key command open_dataset()
generators <- open_dataset(
  sources = "s3://pudl.catalyst.coop/nightly/out_eia__yearly_generators.parquet",
  format = "parquet"
)

## Get what I want from the PUDL parquet I just pulled
df <- generators %>%
  filter(technology_description == "Nuclear") %>%
  select(
    ## Variables I want
    .data =
        report_date,
        plant_id_eia,
        generator_id,
        capacity_mw
  ) %>%
  collect()

View(df)

## This is what it would look like if I took the whole parquet
# df <- generators %>%
#    collect()


## TEST GETTING FIGURE 1 ##

## Get the form 923 dta I need
form_923 <- open_dataset(
  sources = "s3://pudl.catalyst.coop/nightly/out_eia923__monthly_generation_fuel_combined.parquet",
  format = "parquet"
  )

df_923 <- form_923 %>%
  select(
      fuel_type_code_pudl,
      energy_source_code,
      fuel_consumed_for_electricity_mmbtu,
      plant_id_eia, 
      report_date, 
      prime_mover_code, 
      net_generation_mwh,
      utility_name_eia,
      plant_name_eia
  ) %>%
  collect()

df_923_by_plant <- df_923 %>%
  group_by(plant_id_eia, report_date) %>%
  summarise(
    total_generation_mwh = sum(net_generation_mwh, na.rm = TRUE),
    total_fuel_mmbtu = sum(fuel_consumed_for_electricity_mmbtu, na.rm = TRUE),
    plant_heat_rate = total_fuel_mmbtu/total_generation_mwh,
    .groups = "drop"
  )

summary(df_923_by_plant$plant_heat_rate)
