CREATE TABLE CRM 
(
	organization varchar,
	country varchar,
	lattitude varchar,
	longtitude varchar,
	industry varchar,
	organization_size varchar,
	owner varchar,
	lead_acquisition_date varchar,
	product varchar,
	status varchar,
	status_sequence numeric,
	stage varchar,
	stage_sequence numeric,
	deal_value numeric,
	probability_perc numeric,
	expected_close_date varchar,
	actual_close_date varchar
)

set datestyle = DMY

alter table crm
alter column lead_acquisition_date type date 
	using(lead_acquisition_date::date),
alter column expected_close_date type date 
	using(expected_close_date::date),
alter column actual_close_date type date 
	using(actual_close_date::date)


select * from crm


