
CREATE TABLE party_role (
	party_role_code VARCHAR NOT NULL, 
	party_role_name VARCHAR, 
	party_role_description VARCHAR, 
	PRIMARY KEY (party_role_code)
)


-- 2025-10-14 16:54:28,303 INFO [no key 0.00093s] ()
-- 2025-10-14 16:54:28,821 INFO 
CREATE TABLE party (
	party_id INTEGER NOT NULL, 
	party_name VARCHAR, 
	party_type_code VARCHAR, 
	begin_date DATE, 
	end_date DATE, 
	PRIMARY KEY (party_id)
)


-- 2025-10-14 16:54:28,822 INFO [no key 0.00195s] ()
-- 2025-10-14 16:54:29,073 INFO 
CREATE TABLE legal_jurisdiction (
	legal_jurisdiction_id INTEGER NOT NULL, 
	legal_jurisdiction_name VARCHAR, 
	legal_jurisdiction_description VARCHAR, 
	rules_preference_description VARCHAR, 
	PRIMARY KEY (legal_jurisdiction_id)
)


-- 2025-10-14 16:54:29,074 INFO [no key 0.00105s] ()
-- 2025-10-14 16:54:29,297 INFO 
CREATE TABLE account (
	account_id INTEGER NOT NULL, 
	account_type_code INTEGER, 
	account_name VARCHAR, 
	PRIMARY KEY (account_id)
)


-- 2025-10-14 16:54:29,298 INFO [no key 0.00120s] ()
-- 2025-10-14 16:54:29,620 INFO 
CREATE TABLE policy (
	policy_id INTEGER NOT NULL, 
	agreement_id INTEGER, 
	policy_number INTEGER, 
	effective_date DATE, 
	expiration_date DATE, 
	status_code VARCHAR, 
	geographic_location_id INTEGER, 
	PRIMARY KEY (policy_id), 
	FOREIGN KEY(agreement_id) REFERENCES agreement (agreement_id), 
	FOREIGN KEY(agreement_id) REFERENCES reinsurance_agreement (agreement_id), 
	FOREIGN KEY(geographic_location_id) REFERENCES geographic_location (geographic_location_id)
)


-- 2025-10-14 16:54:29,621 INFO [no key 0.00102s] ()
-- 2025-10-14 16:54:29,852 INFO 
CREATE TABLE reinsurance_agreement (
	reinsurance_agreement_id INTEGER NOT NULL, 
	agreement_id INTEGER, 
	PRIMARY KEY (reinsurance_agreement_id), 
	FOREIGN KEY(agreement_id) REFERENCES policy (policy_id), 
	FOREIGN KEY(agreement_id) REFERENCES agreement (agreement_id)
)


-- 2025-10-14 16:54:29,854 INFO [no key 0.00192s] ()
-- 2025-10-14 16:54:30,077 INFO 
CREATE TABLE event (
	event_id INTEGER NOT NULL, 
	PRIMARY KEY (event_id)
)


-- 2025-10-14 16:54:30,079 INFO [no key 0.00181s] ()
-- 2025-10-14 16:54:30,339 INFO 
CREATE TABLE coverage_part (
	coverage_part_code INTEGER NOT NULL, 
	coverage_part_name VARCHAR, 
	PRIMARY KEY (coverage_part_code)
)


-- 2025-10-14 16:54:30,340 INFO [no key 0.00132s] ()
-- 2025-10-14 16:54:30,572 INFO 
CREATE TABLE location_address (
	location_address_id INTEGER NOT NULL, 
	line_1_address VARCHAR, 
	line_2_address VARCHAR, 
	municipality_name VARCHAR, 
	state_code VARCHAR, 
	postal_code VARCHAR, 
	country_code VARCHAR, 
	begin_date DATE, 
	end_date DATE, 
	PRIMARY KEY (location_address_id)
)


-- 2025-10-14 16:54:30,574 INFO [no key 0.00215s] ()
-- 2025-10-14 16:54:30,796 INFO 
CREATE TABLE catastrophe (
	catastrophe_id INTEGER NOT NULL, 
	catastrophe_type_code INTEGER, 
	catastrophe_name VARCHAR, 
	industry_catastrophe_code INTEGER, 
	company_catastrophe_code INTEGER, 
	PRIMARY KEY (catastrophe_id)
)


-- 2025-10-14 16:54:30,798 INFO [no key 0.00412s] ()
-- 2025-10-14 16:54:31,072 INFO 
CREATE TABLE arbitration (
	arbitration_id INTEGER NOT NULL, 
	arbitration_description VARCHAR, 
	PRIMARY KEY (arbitration_id)
)


-- 2025-10-14 16:54:31,073 INFO [no key 0.00173s] ()
-- 2025-10-14 16:54:31,407 INFO 
CREATE TABLE court_jurisdiction (
	court_jurisdiction_id INTEGER NOT NULL, 
	court_id INTEGER, 
	jurisdiction_id INTEGER, 
	PRIMARY KEY (court_jurisdiction_id)
)


-- 2025-10-14 16:54:31,408 INFO [no key 0.00113s] ()
-- 2025-10-14 16:54:31,624 INFO 
CREATE TABLE assessment (
	assessment_id INTEGER NOT NULL, 
	begin_date DATE, 
	end_date DATE, 
	assessment_description VARCHAR, 
	assessment_reason_description VARCHAR, 
	PRIMARY KEY (assessment_id)
)


-- 2025-10-14 16:54:31,625 INFO [no key 0.00114s] ()
-- 2025-10-14 16:54:31,832 INFO 
CREATE TABLE staff_classification (
	staff_classification_code INTEGER NOT NULL, 
	staff_classification_name VARCHAR, 
	staff_classification_description VARCHAR, 
	PRIMARY KEY (staff_classification_code)
)


-- 2025-10-14 16:54:31,833 INFO [no key 0.00125s] ()
-- 2025-10-14 16:54:32,087 INFO 
CREATE TABLE line_of_business_group (
	line_of_business_group_id INTEGER NOT NULL, 
	line_of_business_group_name VARCHAR, 
	line_of_business_group_description VARCHAR, 
	PRIMARY KEY (line_of_business_group_id)
)


-- 2025-10-14 16:54:32,092 INFO [no key 0.00583s] ()
-- 2025-10-14 16:54:32,325 INFO 
CREATE TABLE insurance_class (
	insurance_class_id INTEGER NOT NULL, 
	insurance_class_name VARCHAR, 
	insurance_class_description VARCHAR, 
	PRIMARY KEY (insurance_class_id)
)


-- 2025-10-14 16:54:32,326 INFO [no key 0.00099s] ()
-- 2025-10-14 16:54:32,554 INFO 
CREATE TABLE coverage_type (
	coverage_type_id INTEGER NOT NULL, 
	coverage_type_name VARCHAR, 
	coverage_type_description VARCHAR, 
	PRIMARY KEY (coverage_type_id)
)


-- 2025-10-14 16:54:32,556 INFO [no key 0.00127s] ()
-- 2025-10-14 16:54:32,784 INFO 
CREATE TABLE coverage_group (
	coverage_group_id INTEGER NOT NULL, 
	coverage_group_name VARCHAR, 
	coverage_group_description VARCHAR, 
	PRIMARY KEY (coverage_group_id)
)


-- 2025-10-14 16:54:32,786 INFO [no key 0.00118s] ()
-- 2025-10-14 16:54:33,052 INFO 
CREATE TABLE coverage_limit_type (
	coverage_limit_type_id INTEGER NOT NULL, 
	coverage_limit_name VARCHAR, 
	coverage_limit_description VARCHAR, 
	PRIMARY KEY (coverage_limit_type_id)
)


-- 2025-10-14 16:54:33,054 INFO [no key 0.00190s] ()
-- 2025-10-14 16:54:33,269 INFO 
CREATE TABLE rating_territory (
	rating_territory_id INTEGER NOT NULL, 
	rating_territory_assigning_organization_id INTEGER, 
	rating_territory_code INTEGER, 
	rating_territory_code_set_identifier INTEGER, 
	PRIMARY KEY (rating_territory_id)
)


-- 2025-10-14 16:54:33,271 INFO [no key 0.00169s] ()
-- 2025-10-14 16:54:33,488 INFO 
CREATE TABLE state (
	state_code VARCHAR NOT NULL, 
	state_name VARCHAR, 
	PRIMARY KEY (state_code)
)


-- 2025-10-14 16:54:33,492 INFO [no key 0.00335s] ()
-- 2025-10-14 16:54:33,712 INFO 
CREATE TABLE company (
	company_id INTEGER NOT NULL, 
	company_code INTEGER, 
	company_name VARCHAR, 
	company_description VARCHAR, 
	PRIMARY KEY (company_id)
)


-- 2025-10-14 16:54:33,713 INFO [no key 0.00095s] ()
-- 2025-10-14 16:54:33,924 INFO 
CREATE TABLE person (
	person_id INTEGER NOT NULL, 
	party_id INTEGER, 
	prefix_name VARCHAR, 
	first_name VARCHAR, 
	middle_name VARCHAR, 
	last_name VARCHAR, 
	suffix_name VARCHAR, 
	full_legal_name VARCHAR, 
	nickname VARCHAR, 
	birth_date DATE, 
	birth_place_name VARCHAR, 
	gender_code VARCHAR, 
	PRIMARY KEY (person_id), 
	FOREIGN KEY(party_id) REFERENCES party (party_id)
)


-- 2025-10-14 16:54:33,925 INFO [no key 0.00108s] ()
-- 2025-10-14 16:54:34,140 INFO 
CREATE TABLE organization (
	organization_id INTEGER NOT NULL, 
	party_id INTEGER, 
	organization_type_code INTEGER, 
	organization_name VARCHAR, 
	alternate_name VARCHAR, 
	acronym_name VARCHAR, 
	industry_type_code VARCHAR, 
	industry_code VARCHAR, 
	dun_and_bradstreet_id VARCHAR, 
	organization_description VARCHAR, 
	PRIMARY KEY (organization_id), 
	FOREIGN KEY(party_id) REFERENCES party (party_id)
)


-- 2025-10-14 16:54:34,147 INFO [no key 0.00672s] ()
-- 2025-10-14 16:54:34,375 INFO 
CREATE TABLE grouping (
	grouping_id INTEGER NOT NULL, 
	party_id INTEGER, 
	grouping_name VARCHAR, 
	PRIMARY KEY (grouping_id), 
	FOREIGN KEY(party_id) REFERENCES party (party_id)
)


-- 2025-10-14 16:54:34,376 INFO [no key 0.00101s] ()
-- 2025-10-14 16:54:34,609 INFO 
CREATE TABLE party_relationship (
	party_relationship_id INTEGER NOT NULL, 
	party_id INTEGER, 
	related_party_id INTEGER, 
	relationship_type_code VARCHAR, 
	begin_date DATE, 
	end_date DATE, 
	PRIMARY KEY (party_relationship_id), 
	FOREIGN KEY(party_id) REFERENCES party (party_id), 
	FOREIGN KEY(related_party_id) REFERENCES party (party_id)
)


-- 2025-10-14 16:54:34,610 INFO [no key 0.00133s] ()
-- 2025-10-14 16:54:34,829 INFO 
CREATE TABLE legal_jurisdiction_party_identity (
	legal_jurisdiction_party_id INTEGER NOT NULL, 
	legal_jurisdiction_id INTEGER, 
	party_id INTEGER, 
	legal_identity_type_code VARCHAR, 
	legal_classification_code VARCHAR, 
	PRIMARY KEY (legal_jurisdiction_party_id), 
	FOREIGN KEY(legal_jurisdiction_id) REFERENCES legal_jurisdiction (legal_jurisdiction_id), 
	FOREIGN KEY(party_id) REFERENCES party (party_id)
)


-- 2025-10-14 16:54:34,831 INFO [no key 0.00193s] ()
-- 2025-10-14 16:54:35,066 INFO 
CREATE TABLE claim_party_role (
	claim_party_role_id INTEGER NOT NULL, 
	party_role_code VARCHAR, 
	begin_date DATE, 
	party_id INTEGER, 
	end_date DATE, 
	PRIMARY KEY (claim_party_role_id), 
	FOREIGN KEY(party_role_code) REFERENCES party_role (party_role_code), 
	FOREIGN KEY(party_id) REFERENCES party (party_id)
)


-- 2025-10-14 16:54:35,067 INFO [no key 0.00101s] ()
-- 2025-10-14 16:54:35,271 INFO 
CREATE TABLE party_preference (
	party_id INTEGER NOT NULL, 
	preferred_language_code INTEGER, 
	PRIMARY KEY (party_id), 
	FOREIGN KEY(party_id) REFERENCES party (party_id)
)


-- 2025-10-14 16:54:35,272 INFO [no key 0.00124s] ()
-- 2025-10-14 16:54:35,482 INFO 
CREATE TABLE account_party_role (
	account_party_role_id INTEGER NOT NULL, 
	account_id INTEGER, 
	party_role_code VARCHAR, 
	party_id INTEGER, 
	PRIMARY KEY (account_party_role_id), 
	FOREIGN KEY(account_id) REFERENCES account (account_id), 
	FOREIGN KEY(party_role_code) REFERENCES party_role (party_role_code), 
	FOREIGN KEY(party_id) REFERENCES party (party_id)
)


-- 2025-10-14 16:54:35,483 INFO [no key 0.00126s] ()
-- 2025-10-14 16:54:35,702 INFO 
CREATE TABLE insured_account (
	insured_account_id INTEGER NOT NULL, 
	account_id INTEGER, 
	PRIMARY KEY (insured_account_id), 
	FOREIGN KEY(account_id) REFERENCES account (account_id)
)


-- 2025-10-14 16:54:35,704 INFO [no key 0.00130s] ()
-- 2025-10-14 16:54:35,951 INFO 
CREATE TABLE provider (
	provider_id INTEGER NOT NULL, 
	party_role_code VARCHAR, 
	PRIMARY KEY (provider_id), 
	FOREIGN KEY(party_role_code) REFERENCES party_role (party_role_code)
)


-- 2025-10-14 16:54:35,952 INFO [no key 0.00110s] ()
-- 2025-10-14 16:54:36,209 INFO 
CREATE TABLE policy_relationship (
	policy_relationship_id INTEGER NOT NULL, 
	relationship_code INTEGER, 
	effective_date DATE, 
	policy_id INTEGER, 
	related_policy_id INTEGER, 
	expiration_date DATE, 
	PRIMARY KEY (policy_relationship_id), 
	FOREIGN KEY(policy_id) REFERENCES policy (policy_id), 
	FOREIGN KEY(related_policy_id) REFERENCES policy (policy_id)
)


-- 2025-10-14 16:54:36,210 INFO [no key 0.00163s] ()
-- 2025-10-14 16:54:36,424 INFO 
CREATE TABLE policy_event (
	policy_event_id INTEGER NOT NULL, 
	event_id INTEGER, 
	event_date DATE, 
	effective_date DATE, 
	event_type_code INTEGER, 
	event_sub_type_code INTEGER, 
	policy_id INTEGER, 
	PRIMARY KEY (policy_event_id), 
	FOREIGN KEY(event_id) REFERENCES event (event_id), 
	FOREIGN KEY(policy_id) REFERENCES policy (policy_id)
)


-- 2025-10-14 16:54:36,426 INFO [no key 0.00115s] ()
-- 2025-10-14 16:54:36,639 INFO 
CREATE TABLE policy_coverage_part (
	policy_coverage_part_id INTEGER NOT NULL, 
	coverage_part_code INTEGER, 
	policy_id INTEGER, 
	PRIMARY KEY (policy_coverage_part_id), 
	FOREIGN KEY(coverage_part_code) REFERENCES coverage_part (coverage_part_code), 
	FOREIGN KEY(policy_id) REFERENCES policy (policy_id)
)


-- 2025-10-14 16:54:36,640 INFO [no key 0.00096s] ()
-- 2025-10-14 16:54:36,962 INFO 
CREATE TABLE coverage (
	coverage_id INTEGER NOT NULL, 
	coverage_part_code INTEGER, 
	coverage_type_id INTEGER, 
	coverage_name VARCHAR, 
	coverage_description VARCHAR, 
	coverage_group_id INTEGER, 
	PRIMARY KEY (coverage_id), 
	FOREIGN KEY(coverage_part_code) REFERENCES coverage_part (coverage_part_code), 
	FOREIGN KEY(coverage_type_id) REFERENCES coverage_type (coverage_type_id), 
	FOREIGN KEY(coverage_group_id) REFERENCES coverage_group (coverage_group_id)
)


-- 2025-10-14 16:54:36,963 INFO [no key 0.00114s] ()
-- 2025-10-14 16:54:37,312 INFO 
CREATE TABLE policy_form (
	policy_form_id INTEGER NOT NULL, 
	policy_id INTEGER, 
	policy_form_number VARCHAR, 
	form_value VARCHAR, 
	PRIMARY KEY (policy_form_id), 
	FOREIGN KEY(policy_id) REFERENCES policy (policy_id)
)


-- 2025-10-14 16:54:37,313 INFO [no key 0.00099s] ()
-- 2025-10-14 16:54:37,654 INFO 
CREATE TABLE physical_location (
	physical_location_id INTEGER NOT NULL, 
	physical_location_name VARCHAR, 
	latitude_value FLOAT, 
	longitude_value FLOAT, 
	altitude_value FLOAT, 
	altitude_mean_sea_level_value FLOAT, 
	horizontal_accuracy_value FLOAT, 
	vertical_accuracy_value FLOAT, 
	travel_direction_description VARCHAR, 
	location_address_id INTEGER, 
	PRIMARY KEY (physical_location_id), 
	FOREIGN KEY(location_address_id) REFERENCES location_address (location_address_id)
)


-- 2025-10-14 16:54:37,656 INFO [no key 0.00188s] ()
-- 2025-10-14 16:54:37,855 INFO 
CREATE TABLE litigation (
	litigation_id INTEGER NOT NULL, 
	court_jurisdiction_id INTEGER, 
	litigation_description VARCHAR, 
	PRIMARY KEY (litigation_id), 
	FOREIGN KEY(court_jurisdiction_id) REFERENCES court_jurisdiction (court_jurisdiction_id)
)


-- 2025-10-14 16:54:37,856 INFO [no key 0.00141s] ()
-- 2025-10-14 16:54:38,094 INFO 
CREATE TABLE assessment_party_role (
	assessment_party_role_id INTEGER NOT NULL, 
	party_id INTEGER, 
	party_role_code VARCHAR, 
	assessment_id INTEGER, 
	begin_date DATE, 
	end_date DATE, 
	PRIMARY KEY (assessment_party_role_id), 
	FOREIGN KEY(party_id) REFERENCES party (party_id), 
	FOREIGN KEY(party_role_code) REFERENCES party_role (party_role_code), 
	FOREIGN KEY(assessment_id) REFERENCES assessment (assessment_id)
)


-- 2025-10-14 16:54:38,095 INFO [no key 0.00182s] ()
-- 2025-10-14 16:54:38,320 INFO 
CREATE TABLE assessment_result (
	assessment_result_id INTEGER NOT NULL, 
	assessment_id INTEGER, 
	assessment_result_type_code INTEGER, 
	PRIMARY KEY (assessment_result_id), 
	FOREIGN KEY(assessment_id) REFERENCES assessment (assessment_id)
)


-- 2025-10-14 16:54:38,321 INFO [no key 0.00103s] ()
-- 2025-10-14 16:54:38,666 INFO 
CREATE TABLE staff_role (
	staff_role_id INTEGER NOT NULL, 
	party_role_code VARCHAR, 
	PRIMARY KEY (staff_role_id), 
	FOREIGN KEY(party_role_code) REFERENCES party_role (party_role_code)
)


-- 2025-10-14 16:54:38,667 INFO [no key 0.00131s] ()
-- 2025-10-14 16:54:38,873 INFO 
CREATE TABLE claim_role (
	claim_role_id INTEGER NOT NULL, 
	party_role_code VARCHAR, 
	PRIMARY KEY (claim_role_id), 
	FOREIGN KEY(party_role_code) REFERENCES party_role (party_role_code)
)


-- 2025-10-14 16:54:38,873 INFO [no key 0.00094s] ()
-- 2025-10-14 16:54:39,217 INFO 
CREATE TABLE adjuster (
	adjuster_id INTEGER NOT NULL, 
	party_role_code VARCHAR, 
	PRIMARY KEY (adjuster_id), 
	FOREIGN KEY(party_role_code) REFERENCES party_role (party_role_code)
)


-- 2025-10-14 16:54:39,218 INFO [no key 0.00135s] ()
-- 2025-10-14 16:54:39,431 INFO 
CREATE TABLE staff_position (
	staff_position_id INTEGER NOT NULL, 
	staff_position_name VARCHAR, 
	staff_position_description VARCHAR, 
	staff_classification_code INTEGER, 
	PRIMARY KEY (staff_position_id), 
	FOREIGN KEY(staff_classification_code) REFERENCES staff_classification (staff_classification_code)
)


-- 2025-10-14 16:54:39,432 INFO [no key 0.00101s] ()
-- 2025-10-14 16:54:39,781 INFO 
CREATE TABLE staffing_organization (
	staffing_organization_id INTEGER NOT NULL, 
	party_role_code VARCHAR, 
	PRIMARY KEY (staffing_organization_id), 
	FOREIGN KEY(party_role_code) REFERENCES party_role (party_role_code)
)


-- 2025-10-14 16:54:39,783 INFO [no key 0.00124s] ()
-- 2025-10-14 16:54:40,046 INFO 
CREATE TABLE staff (
	staff_id INTEGER NOT NULL, 
	party_role_code VARCHAR, 
	PRIMARY KEY (staff_id), 
	FOREIGN KEY(party_role_code) REFERENCES party_role (party_role_code)
)


-- 2025-10-14 16:54:40,047 INFO [no key 0.00118s] ()
-- 2025-10-14 16:54:40,271 INFO 
CREATE TABLE business_event (
	business_event_id INTEGER NOT NULL, 
	event_id INTEGER, 
	PRIMARY KEY (business_event_id), 
	FOREIGN KEY(event_id) REFERENCES event (event_id)
)


-- 2025-10-14 16:54:40,271 INFO [no key 0.00097s] ()
-- 2025-10-14 16:54:40,500 INFO 
CREATE TABLE life_event (
	life_event_id INTEGER NOT NULL, 
	event_id INTEGER, 
	PRIMARY KEY (life_event_id), 
	FOREIGN KEY(event_id) REFERENCES event (event_id)
)


-- 2025-10-14 16:54:40,501 INFO [no key 0.00114s] ()
-- 2025-10-14 16:54:40,704 INFO 
CREATE TABLE claim_event (
	claim_event_id INTEGER NOT NULL, 
	event_id INTEGER, 
	PRIMARY KEY (claim_event_id), 
	FOREIGN KEY(event_id) REFERENCES event (event_id)
)


-- 2025-10-14 16:54:40,705 INFO [no key 0.00126s] ()
-- 2025-10-14 16:54:40,917 INFO 
CREATE TABLE line_of_business (
	line_of_business_id INTEGER NOT NULL, 
	line_of_business_name VARCHAR, 
	line_of_business_description VARCHAR, 
	line_of_business_code INTEGER, 
	line_of_business_group_id INTEGER, 
	insurance_class_id INTEGER, 
	PRIMARY KEY (line_of_business_id), 
	FOREIGN KEY(line_of_business_group_id) REFERENCES line_of_business_group (line_of_business_group_id), 
	FOREIGN KEY(insurance_class_id) REFERENCES insurance_class (insurance_class_id)
)


-- 2025-10-14 16:54:40,919 INFO [no key 0.00126s] ()
-- 2025-10-14 16:54:41,132 INFO 
CREATE TABLE person_profession (
	person_profession_id INTEGER NOT NULL, 
	person_id INTEGER, 
	profession_name VARCHAR, 
	PRIMARY KEY (person_profession_id), 
	FOREIGN KEY(person_id) REFERENCES person (person_id)
)


-- 2025-10-14 16:54:41,133 INFO [no key 0.00104s] ()
-- 2025-10-14 16:54:41,340 INFO 
CREATE TABLE household (
	household_id INTEGER NOT NULL, 
	grouping_id INTEGER, 
	PRIMARY KEY (household_id), 
	FOREIGN KEY(grouping_id) REFERENCES grouping (grouping_id)
)


-- 2025-10-14 16:54:41,342 INFO [no key 0.00127s] ()
-- 2025-10-14 16:54:41,556 INFO 
CREATE TABLE staff_work_assignment (
	staff_work_assignment_id INTEGER NOT NULL, 
	person_id INTEGER, 
	organization_id INTEGER, 
	grouping_id INTEGER, 
	begin_date DATE, 
	party_role_code INTEGER, 
	end_date DATE, 
	PRIMARY KEY (staff_work_assignment_id), 
	FOREIGN KEY(person_id) REFERENCES person (person_id), 
	FOREIGN KEY(organization_id) REFERENCES organization (organization_id), 
	FOREIGN KEY(grouping_id) REFERENCES grouping (grouping_id), 
	FOREIGN KEY(party_role_code) REFERENCES party_role (party_role_code)
)


-- 2025-10-14 16:54:41,557 INFO [no key 0.00105s] ()
-- 2025-10-14 16:54:41,772 INFO 
CREATE TABLE party_relationship_role (
	party_relationship_role_id INTEGER NOT NULL, 
	party_id INTEGER, 
	related_party_id INTEGER, 
	relationship_type_code INTEGER, 
	relationship_begin_date DATE, 
	party_role_code VARCHAR, 
	role_begin_date DATE, 
	PRIMARY KEY (party_relationship_role_id), 
	FOREIGN KEY(party_id) REFERENCES party_relationship (party_id), 
	FOREIGN KEY(related_party_id) REFERENCES party_relationship (related_party_id), 
	FOREIGN KEY(relationship_type_code) REFERENCES party_relationship (relationship_type_code), 
	FOREIGN KEY(relationship_begin_date) REFERENCES party_relationship (begin_date), 
	FOREIGN KEY(party_role_code) REFERENCES party_role (party_role_code)
)


-- 2025-10-14 16:54:41,774 INFO [no key 0.00187s] ()
-- 2025-10-14 16:54:42,043 INFO 
CREATE TABLE geographic_location (
	geographic_location_id INTEGER NOT NULL, 
	geographic_location_type_code VARCHAR, 
	location_code VARCHAR, 
	location_name VARCHAR, 
	location_number VARCHAR, 
	state_code VARCHAR, 
	parent_geographic_location_id INTEGER, 
	location_address_id INTEGER, 
	physical_location_identifier INTEGER, 
	PRIMARY KEY (geographic_location_id), 
	FOREIGN KEY(state_code) REFERENCES state (state_code), 
	FOREIGN KEY(parent_geographic_location_id) REFERENCES geographic_location (geographic_location_id), 
	FOREIGN KEY(location_address_id) REFERENCES location_address (location_address_id), 
	FOREIGN KEY(physical_location_identifier) REFERENCES physical_location (physical_location_id)
)


-- 2025-10-14 16:54:42,044 INFO [no key 0.00103s] ()
-- 2025-10-14 16:54:42,365 INFO 
CREATE TABLE account_role (
	account_role_id INTEGER NOT NULL, 
	provider_id VARCHAR, 
	PRIMARY KEY (account_role_id), 
	FOREIGN KEY(provider_id) REFERENCES provider (provider_id)
)


-- 2025-10-14 16:54:42,366 INFO [no key 0.00114s] ()
-- 2025-10-14 16:54:42,579 INFO 
CREATE TABLE agreement_role (
	agreement_role_id INTEGER NOT NULL, 
	provider_id INTEGER, 
	PRIMARY KEY (agreement_role_id), 
	FOREIGN KEY(provider_id) REFERENCES provider (provider_id)
)


-- 2025-10-14 16:54:42,580 INFO [no key 0.00091s] ()
-- 2025-10-14 16:54:42,804 INFO 
CREATE TABLE financial_service (
	financial_service_id INTEGER NOT NULL, 
	provider_id INTEGER, 
	PRIMARY KEY (financial_service_id), 
	FOREIGN KEY(provider_id) REFERENCES provider (provider_id)
)


-- 2025-10-14 16:54:42,805 INFO [no key 0.00154s] ()
-- 2025-10-14 16:54:43,067 INFO 
CREATE TABLE product (
	product_id INTEGER NOT NULL, 
	line_of_business_id INTEGER, 
	licensed_product_name VARCHAR, 
	product_description VARCHAR, 
	PRIMARY KEY (product_id), 
	FOREIGN KEY(line_of_business_id) REFERENCES line_of_business (line_of_business_id)
)


-- 2025-10-14 16:54:43,069 INFO [no key 0.00119s] ()
-- 2025-10-14 16:54:43,299 INFO 
CREATE TABLE party_assessment (
	party_assessment_id INTEGER NOT NULL, 
	person_id INTEGER, 
	assessment_id INTEGER, 
	party_id INTEGER, 
	PRIMARY KEY (party_assessment_id), 
	FOREIGN KEY(person_id) REFERENCES person (person_id), 
	FOREIGN KEY(assessment_id) REFERENCES assessment (assessment_id), 
	FOREIGN KEY(party_id) REFERENCES party (party_id)
)


-- 2025-10-14 16:54:43,300 INFO [no key 0.00094s] ()
-- 2025-10-14 16:54:43,510 INFO 
CREATE TABLE approval (
	approval_id INTEGER NOT NULL, 
	assessment_result_id INTEGER, 
	PRIMARY KEY (approval_id), 
	FOREIGN KEY(assessment_result_id) REFERENCES assessment_result (assessment_result_id)
)


-- 2025-10-14 16:54:43,511 INFO [no key 0.00146s] ()
-- 2025-10-14 16:54:43,747 INFO 
CREATE TABLE channel_score (
	channel_score_id INTEGER NOT NULL, 
	assessment_result_id INTEGER, 
	PRIMARY KEY (channel_score_id), 
	FOREIGN KEY(assessment_result_id) REFERENCES assessment_result (assessment_result_id)
)


-- 2025-10-14 16:54:43,749 INFO [no key 0.00166s] ()
-- 2025-10-14 16:54:44,010 INFO 
CREATE TABLE customer_score (
	customer_score_id INTEGER NOT NULL, 
	assessment_result_id INTEGER, 
	PRIMARY KEY (customer_score_id), 
	FOREIGN KEY(assessment_result_id) REFERENCES assessment_result (assessment_result_id)
)


-- 2025-10-14 16:54:44,011 INFO [no key 0.00102s] ()
-- 2025-10-14 16:54:44,239 INFO 
CREATE TABLE risk_factor_score (
	risk_factor_score_id INTEGER NOT NULL, 
	assessment_result_id INTEGER, 
	PRIMARY KEY (risk_factor_score_id), 
	FOREIGN KEY(assessment_result_id) REFERENCES assessment_result (assessment_result_id)
)


-- 2025-10-14 16:54:44,240 INFO [no key 0.00111s] ()
-- 2025-10-14 16:54:44,447 INFO 
CREATE TABLE demographic_score (
	demographic_score_id INTEGER NOT NULL, 
	assessment_result_id INTEGER, 
	PRIMARY KEY (demographic_score_id), 
	FOREIGN KEY(assessment_result_id) REFERENCES assessment_result (assessment_result_id)
)


-- 2025-10-14 16:54:44,450 INFO [no key 0.00223s] ()
-- 2025-10-14 16:54:44,655 INFO 
CREATE TABLE underwriting_assignment (
	underwriting_assignment_id INTEGER NOT NULL, 
	assessment_result_id INTEGER, 
	PRIMARY KEY (underwriting_assignment_id), 
	FOREIGN KEY(assessment_result_id) REFERENCES assessment_result (assessment_result_id)
)


-- 2025-10-14 16:54:44,657 INFO [no key 0.00192s] ()
-- 2025-10-14 16:54:44,874 INFO 
CREATE TABLE credit_rating (
	credit_rating_id INTEGER NOT NULL, 
	assessment_result_id INTEGER, 
	PRIMARY KEY (credit_rating_id), 
	FOREIGN KEY(assessment_result_id) REFERENCES assessment_result (assessment_result_id)
)


-- 2025-10-14 16:54:44,876 INFO [no key 0.00119s] ()
-- 2025-10-14 16:54:45,099 INFO 
CREATE TABLE financial_valuation (
	financial_valuation_id INTEGER NOT NULL, 
	assessment_result_id INTEGER, 
	PRIMARY KEY (financial_valuation_id), 
	FOREIGN KEY(assessment_result_id) REFERENCES assessment_result (assessment_result_id)
)


-- 2025-10-14 16:54:45,100 INFO [no key 0.00102s] ()
-- 2025-10-14 16:54:45,320 INFO 
CREATE TABLE medical_condition (
	medical_condition_id INTEGER NOT NULL, 
	assessment_result_id INTEGER, 
	PRIMARY KEY (medical_condition_id), 
	FOREIGN KEY(assessment_result_id) REFERENCES assessment_result (assessment_result_id)
)


-- 2025-10-14 16:54:45,321 INFO [no key 0.00095s] ()
-- 2025-10-14 16:54:45,540 INFO 
CREATE TABLE financial_services_assessment (
	financial_services_assessment_id INTEGER NOT NULL, 
	assessment_result_id INTEGER, 
	PRIMARY KEY (financial_services_assessment_id), 
	FOREIGN KEY(assessment_result_id) REFERENCES assessment_result (assessment_result_id)
)


-- 2025-10-14 16:54:45,541 INFO [no key 0.00101s] ()
-- 2025-10-14 16:54:45,815 INFO 
CREATE TABLE fraud_assessment (
	fraud_assessment_id INTEGER NOT NULL, 
	assessment_result_id INTEGER, 
	PRIMARY KEY (fraud_assessment_id), 
	FOREIGN KEY(assessment_result_id) REFERENCES assessment_result (assessment_result_id)
)


-- 2025-10-14 16:54:45,816 INFO [no key 0.00102s] ()
-- 2025-10-14 16:54:46,083 INFO 
CREATE TABLE physical_object_assessment (
	physical_object_assessment_id INTEGER NOT NULL, 
	assessment_result_id INTEGER, 
	PRIMARY KEY (physical_object_assessment_id), 
	FOREIGN KEY(assessment_result_id) REFERENCES assessment_result (assessment_result_id)
)


-- 2025-10-14 16:54:46,090 INFO [no key 0.00672s] ()
-- 2025-10-14 16:54:46,427 INFO 
CREATE TABLE place_assessment (
	place_assessment_id INTEGER NOT NULL, 
	assessment_result_id INTEGER, 
	PRIMARY KEY (place_assessment_id), 
	FOREIGN KEY(assessment_result_id) REFERENCES assessment_result (assessment_result_id)
)


-- 2025-10-14 16:54:46,428 INFO [no key 0.00121s] ()
-- 2025-10-14 16:54:46,647 INFO 
CREATE TABLE claim_evaluation_result (
	claim_evaluation_result_id INTEGER NOT NULL, 
	assessment_result_id INTEGER, 
	PRIMARY KEY (claim_evaluation_result_id), 
	FOREIGN KEY(assessment_result_id) REFERENCES assessment_result (assessment_result_id)
)


-- 2025-10-14 16:54:46,648 INFO [no key 0.00131s] ()
-- 2025-10-14 16:54:46,916 INFO 
CREATE TABLE other_assessment_result (
	other_assessment_result_id INTEGER NOT NULL, 
	assessment_result_id INTEGER, 
	PRIMARY KEY (other_assessment_result_id), 
	FOREIGN KEY(assessment_result_id) REFERENCES assessment_result (assessment_result_id)
)


-- 2025-10-14 16:54:46,917 INFO [no key 0.00100s] ()
-- 2025-10-14 16:54:47,230 INFO 
CREATE TABLE buyer (
	buyer_id INTEGER NOT NULL, 
	provider_id INTEGER, 
	PRIMARY KEY (buyer_id), 
	FOREIGN KEY(provider_id) REFERENCES provider (provider_id)
)


-- 2025-10-14 16:54:47,231 INFO [no key 0.00094s] ()
-- 2025-10-14 16:54:47,556 INFO 
CREATE TABLE health_care_provider (
	health_care_provider_id INTEGER NOT NULL, 
	provider_id INTEGER, 
	PRIMARY KEY (health_care_provider_id), 
	FOREIGN KEY(provider_id) REFERENCES provider (provider_id)
)


-- 2025-10-14 16:54:47,557 INFO [no key 0.00113s] ()
-- 2025-10-14 16:54:47,764 INFO 
CREATE TABLE third_party_administrator (
	third_party_administrator_id INTEGER NOT NULL, 
	provider_id INTEGER, 
	PRIMARY KEY (third_party_administrator_id), 
	FOREIGN KEY(provider_id) REFERENCES provider (provider_id)
)


-- 2025-10-14 16:54:47,765 INFO [no key 0.00098s] ()
-- 2025-10-14 16:54:47,998 INFO 
CREATE TABLE mutual_fund_provider (
	mutual_fund_provider_id INTEGER NOT NULL, 
	provider_id INTEGER, 
	PRIMARY KEY (mutual_fund_provider_id), 
	FOREIGN KEY(provider_id) REFERENCES provider (provider_id)
)


-- 2025-10-14 16:54:47,999 INFO [no key 0.00105s] ()
-- 2025-10-14 16:54:48,215 INFO 
CREATE TABLE legal_adviser (
	legal_adviser_id INTEGER NOT NULL, 
	provider_id INTEGER, 
	PRIMARY KEY (legal_adviser_id), 
	FOREIGN KEY(provider_id) REFERENCES provider (provider_id)
)


-- 2025-10-14 16:54:48,216 INFO [no key 0.00089s] ()
-- 2025-10-14 16:54:48,429 INFO 
CREATE TABLE contractor (
	contractor_id INTEGER NOT NULL, 
	provider_id INTEGER, 
	PRIMARY KEY (contractor_id), 
	FOREIGN KEY(provider_id) REFERENCES provider (provider_id)
)


-- 2025-10-14 16:54:48,431 INFO [no key 0.00184s] ()
-- 2025-10-14 16:54:48,638 INFO 
CREATE TABLE auditor (
	auditor_id INTEGER NOT NULL, 
	provider_id INTEGER, 
	PRIMARY KEY (auditor_id), 
	FOREIGN KEY(provider_id) REFERENCES provider (provider_id)
)


-- 2025-10-14 16:54:48,639 INFO [no key 0.00107s] ()
-- 2025-10-14 16:54:48,851 INFO 
CREATE TABLE accountability (
	accountability_id INTEGER NOT NULL, 
	staff_role_id INTEGER, 
	PRIMARY KEY (accountability_id), 
	FOREIGN KEY(staff_role_id) REFERENCES staff_role (staff_role_id)
)


-- 2025-10-14 16:54:48,852 INFO [no key 0.00134s] ()
-- 2025-10-14 16:54:49,075 INFO 
CREATE TABLE manager (
	manager_id INTEGER NOT NULL, 
	staff_role_id INTEGER, 
	PRIMARY KEY (manager_id), 
	FOREIGN KEY(staff_role_id) REFERENCES staff_role (staff_role_id)
)


-- 2025-10-14 16:54:49,077 INFO [no key 0.00150s] ()
-- 2025-10-14 16:54:49,413 INFO 
CREATE TABLE team_leader (
	team_leader_id INTEGER NOT NULL, 
	staff_role_id INTEGER, 
	PRIMARY KEY (team_leader_id), 
	FOREIGN KEY(staff_role_id) REFERENCES staff_role (staff_role_id)
)


-- 2025-10-14 16:54:49,414 INFO [no key 0.00116s] ()
-- 2025-10-14 16:54:49,637 INFO 
CREATE TABLE team_member (
	team_member_id INTEGER NOT NULL, 
	staff_role_id INTEGER, 
	PRIMARY KEY (team_member_id), 
	FOREIGN KEY(staff_role_id) REFERENCES staff_role (staff_role_id)
)


-- 2025-10-14 16:54:49,638 INFO [no key 0.00100s] ()
-- 2025-10-14 16:54:49,851 INFO 
CREATE TABLE attorney (
	attorney_id INTEGER NOT NULL, 
	provider_id INTEGER, 
	PRIMARY KEY (attorney_id), 
	FOREIGN KEY(provider_id) REFERENCES provider (provider_id)
)


-- 2025-10-14 16:54:49,853 INFO [no key 0.00206s] ()
-- 2025-10-14 16:54:50,110 INFO 
CREATE TABLE claimant (
	claimant_id INTEGER NOT NULL, 
	claim_role_id INTEGER, 
	PRIMARY KEY (claimant_id), 
	FOREIGN KEY(claim_role_id) REFERENCES claim_role (claim_role_id)
)


-- 2025-10-14 16:54:50,111 INFO [no key 0.00180s] ()
-- 2025-10-14 16:54:50,343 INFO 
CREATE TABLE claim_representative (
	claim_representative_id INTEGER NOT NULL, 
	claim_role_id INTEGER, 
	PRIMARY KEY (claim_representative_id), 
	FOREIGN KEY(claim_role_id) REFERENCES claim_role (claim_role_id)
)


-- 2025-10-14 16:54:50,345 INFO [no key 0.00111s] ()
-- 2025-10-14 16:54:50,563 INFO 
CREATE TABLE claim_examiner (
	claim_examiner_id INTEGER NOT NULL, 
	claim_role_id INTEGER, 
	PRIMARY KEY (claim_examiner_id), 
	FOREIGN KEY(claim_role_id) REFERENCES claim_role (claim_role_id)
)


-- 2025-10-14 16:54:50,564 INFO [no key 0.00134s] ()
-- 2025-10-14 16:54:50,802 INFO 
CREATE TABLE victim (
	victim_id INTEGER NOT NULL, 
	claim_role_id INTEGER, 
	PRIMARY KEY (victim_id), 
	FOREIGN KEY(claim_role_id) REFERENCES claim_role (claim_role_id)
)


-- 2025-10-14 16:54:50,803 INFO [no key 0.00127s] ()
-- 2025-10-14 16:54:51,052 INFO 
CREATE TABLE claim_witness (
	claim_witness_id INTEGER NOT NULL, 
	claim_role_id INTEGER, 
	PRIMARY KEY (claim_witness_id), 
	FOREIGN KEY(claim_role_id) REFERENCES claim_role (claim_role_id)
)


-- 2025-10-14 16:54:51,053 INFO [no key 0.00092s] ()
-- 2025-10-14 16:54:51,283 INFO 
CREATE TABLE claim_administrator (
	claim_administrator_id INTEGER NOT NULL, 
	claim_role_id INTEGER, 
	PRIMARY KEY (claim_administrator_id), 
	FOREIGN KEY(claim_role_id) REFERENCES claim_role (claim_role_id)
)


-- 2025-10-14 16:54:51,283 INFO [no key 0.00095s] ()
-- 2025-10-14 16:54:51,505 INFO 
CREATE TABLE claimee (
	claimee_id INTEGER NOT NULL, 
	claim_role_id INTEGER, 
	PRIMARY KEY (claimee_id), 
	FOREIGN KEY(claim_role_id) REFERENCES claim_role (claim_role_id)
)


-- 2025-10-14 16:54:51,506 INFO [no key 0.00109s] ()
-- 2025-10-14 16:54:51,727 INFO 
CREATE TABLE claim_legal_expert (
	claim_legal_expert_id INTEGER NOT NULL, 
	claim_role_id INTEGER, 
	PRIMARY KEY (claim_legal_expert_id), 
	FOREIGN KEY(claim_role_id) REFERENCES claim_role (claim_role_id)
)


-- 2025-10-14 16:54:51,729 INFO [no key 0.00130s] ()
-- 2025-10-14 16:54:51,941 INFO 
CREATE TABLE loss_payee (
	loss_payee_id INTEGER NOT NULL, 
	claim_role_id INTEGER, 
	PRIMARY KEY (loss_payee_id), 
	FOREIGN KEY(claim_role_id) REFERENCES claim_role (claim_role_id)
)


-- 2025-10-14 16:54:51,943 INFO [no key 0.00237s] ()
-- 2025-10-14 16:54:52,147 INFO 
CREATE TABLE claim_expert (
	claim_expert_id INTEGER NOT NULL, 
	claim_role_id INTEGER, 
	PRIMARY KEY (claim_expert_id), 
	FOREIGN KEY(claim_role_id) REFERENCES claim_role (claim_role_id)
)


-- 2025-10-14 16:54:52,149 INFO [no key 0.00228s] ()
-- 2025-10-14 16:54:52,369 INFO 
CREATE TABLE claim_fraud_examiner (
	claim_fraud_examiner_id INTEGER NOT NULL, 
	claim_role_id INTEGER, 
	PRIMARY KEY (claim_fraud_examiner_id), 
	FOREIGN KEY(claim_role_id) REFERENCES claim_role (claim_role_id)
)


-- 2025-10-14 16:54:52,371 INFO [no key 0.00117s] ()
-- 2025-10-14 16:54:52,716 INFO 
CREATE TABLE driver (
	driver_id INTEGER NOT NULL, 
	claim_role_id INTEGER, 
	PRIMARY KEY (driver_id), 
	FOREIGN KEY(claim_role_id) REFERENCES claim_role (claim_role_id)
)


-- 2025-10-14 16:54:52,717 INFO [no key 0.00118s] ()
-- 2025-10-14 16:54:53,088 INFO 
CREATE TABLE patient (
	patient_id INTEGER NOT NULL, 
	claim_role_id INTEGER, 
	PRIMARY KEY (patient_id), 
	FOREIGN KEY(claim_role_id) REFERENCES claim_role (claim_role_id)
)


-- 2025-10-14 16:54:53,089 INFO [no key 0.00145s] ()
-- 2025-10-14 16:54:53,408 INFO 
CREATE TABLE inhouse_adjuster (
	inhouse_adjuster_id INTEGER NOT NULL, 
	adjuster_id INTEGER, 
	PRIMARY KEY (inhouse_adjuster_id), 
	FOREIGN KEY(adjuster_id) REFERENCES adjuster (adjuster_id)
)


-- 2025-10-14 16:54:53,410 INFO [no key 0.00216s] ()
-- 2025-10-14 16:54:53,629 INFO 
CREATE TABLE public_adjuster (
	public_adjuster_id INTEGER NOT NULL, 
	adjuster_id INTEGER, 
	PRIMARY KEY (public_adjuster_id), 
	FOREIGN KEY(adjuster_id) REFERENCES adjuster (adjuster_id)
)


-- 2025-10-14 16:54:53,630 INFO [no key 0.00111s] ()
-- 2025-10-14 16:54:53,869 INFO 
CREATE TABLE independent_adjuster (
	independent_adjuster_id INTEGER NOT NULL, 
	adjuster_id INTEGER, 
	PRIMARY KEY (independent_adjuster_id), 
	FOREIGN KEY(adjuster_id) REFERENCES adjuster (adjuster_id)
)


-- 2025-10-14 16:54:53,870 INFO [no key 0.00164s] ()
-- 2025-10-14 16:54:54,100 INFO 
CREATE TABLE staff_position_assignment (
	staff_position_assignment_id INTEGER NOT NULL, 
	person_id INTEGER, 
	organization_id INTEGER, 
	staff_position_id INTEGER, 
	begin_date DATE, 
	end_date DATE, 
	PRIMARY KEY (staff_position_assignment_id), 
	FOREIGN KEY(person_id) REFERENCES person (person_id), 
	FOREIGN KEY(organization_id) REFERENCES organization (organization_id), 
	FOREIGN KEY(staff_position_id) REFERENCES staff_position (staff_position_id)
)


-- 2025-10-14 16:54:54,101 INFO [no key 0.00121s] ()
-- 2025-10-14 16:54:54,428 INFO 
CREATE TABLE organization_unit (
	organization_unit_id INTEGER NOT NULL, 
	organization_id INTEGER, 
	organization_unit_name VARCHAR, 
	organization_unit_description VARCHAR, 
	industry_code INTEGER, 
	accounting_code INTEGER, 
	work_site_type_code INTEGER, 
	PRIMARY KEY (organization_unit_id), 
	FOREIGN KEY(organization_id) REFERENCES organization (organization_id)
)


-- 2025-10-14 16:54:54,429 INFO [no key 0.00124s] ()
-- 2025-10-14 16:54:54,653 INFO 
CREATE TABLE for_profit_organization (
	for_profit_organization_id INTEGER NOT NULL, 
	organization_id INTEGER, 
	PRIMARY KEY (for_profit_organization_id), 
	FOREIGN KEY(organization_id) REFERENCES organization (organization_id)
)


-- 2025-10-14 16:54:54,654 INFO [no key 0.00124s] ()
-- 2025-10-14 16:54:54,886 INFO 
CREATE TABLE government_organization (
	government_organization_id INTEGER NOT NULL, 
	organization_id INTEGER, 
	PRIMARY KEY (government_organization_id), 
	FOREIGN KEY(organization_id) REFERENCES organization (organization_id)
)


-- 2025-10-14 16:54:54,887 INFO [no key 0.00127s] ()
-- 2025-10-14 16:54:55,117 INFO 
CREATE TABLE not_for_profit_organization (
	not_for_profit_organization_id INTEGER NOT NULL, 
	organization_id INTEGER, 
	PRIMARY KEY (not_for_profit_organization_id), 
	FOREIGN KEY(organization_id) REFERENCES organization (organization_id)
)


-- 2025-10-14 16:54:55,120 INFO [no key 0.00272s] ()
-- 2025-10-14 16:54:55,348 INFO 
CREATE TABLE professional_group (
	professional_group_id INTEGER NOT NULL, 
	grouping_id INTEGER, 
	PRIMARY KEY (professional_group_id), 
	FOREIGN KEY(grouping_id) REFERENCES grouping (grouping_id)
)


-- 2025-10-14 16:54:55,349 INFO [no key 0.00095s] ()
-- 2025-10-14 16:54:55,753 INFO 
CREATE TABLE project (
	project_id INTEGER NOT NULL, 
	grouping_id INTEGER, 
	PRIMARY KEY (project_id), 
	FOREIGN KEY(grouping_id) REFERENCES grouping (grouping_id)
)


-- 2025-10-14 16:54:55,754 INFO [no key 0.00096s] ()
-- 2025-10-14 16:54:56,086 INFO 
CREATE TABLE team (
	team_id INTEGER NOT NULL, 
	grouping_id INTEGER, 
	PRIMARY KEY (team_id), 
	FOREIGN KEY(grouping_id) REFERENCES grouping (grouping_id)
)


-- 2025-10-14 16:54:56,087 INFO [no key 0.00139s] ()
-- 2025-10-14 16:54:56,302 INFO 
CREATE TABLE pre_qualification (
	pre_qualification_id INTEGER NOT NULL, 
	policy_event_id INTEGER, 
	PRIMARY KEY (pre_qualification_id), 
	FOREIGN KEY(policy_event_id) REFERENCES policy_event (policy_event_id)
)


-- 2025-10-14 16:54:56,302 INFO [no key 0.00096s] ()
-- 2025-10-14 16:54:56,538 INFO 
CREATE TABLE quote (
	quote_id INTEGER NOT NULL, 
	policy_event_id INTEGER, 
	PRIMARY KEY (quote_id), 
	FOREIGN KEY(policy_event_id) REFERENCES policy_event (policy_event_id)
)


-- 2025-10-14 16:54:56,540 INFO [no key 0.00209s] ()
-- 2025-10-14 16:54:56,767 INFO 
CREATE TABLE binding (
	binding_id INTEGER NOT NULL, 
	policy_event_id INTEGER, 
	PRIMARY KEY (binding_id), 
	FOREIGN KEY(policy_event_id) REFERENCES policy_event (policy_event_id)
)


-- 2025-10-14 16:54:56,769 INFO [no key 0.00194s] ()
-- 2025-10-14 16:54:57,026 INFO 
CREATE TABLE new_business (
	new_business_id INTEGER NOT NULL, 
	policy_event_id INTEGER, 
	PRIMARY KEY (new_business_id), 
	FOREIGN KEY(policy_event_id) REFERENCES policy_event (policy_event_id)
)


-- 2025-10-14 16:54:57,027 INFO [no key 0.00108s] ()
-- 2025-10-14 16:54:57,239 INFO 
CREATE TABLE endorsement (
	endorsement_id INTEGER NOT NULL, 
	policy_event_id INTEGER, 
	PRIMARY KEY (endorsement_id), 
	FOREIGN KEY(policy_event_id) REFERENCES policy_event (policy_event_id)
)


-- 2025-10-14 16:54:57,240 INFO [no key 0.00110s] ()
-- 2025-10-14 16:54:57,457 INFO 
CREATE TABLE cancel (
	cancel_id INTEGER NOT NULL, 
	policy_event_id INTEGER, 
	PRIMARY KEY (cancel_id), 
	FOREIGN KEY(policy_event_id) REFERENCES policy_event (policy_event_id)
)


-- 2025-10-14 16:54:57,458 INFO [no key 0.00122s] ()
-- 2025-10-14 16:54:57,674 INFO 
CREATE TABLE reinstatement (
	reinstatement_id INTEGER NOT NULL, 
	policy_event_id INTEGER, 
	PRIMARY KEY (reinstatement_id), 
	FOREIGN KEY(policy_event_id) REFERENCES policy_event (policy_event_id)
)


-- 2025-10-14 16:54:57,675 INFO [no key 0.00111s] ()
-- 2025-10-14 16:54:57,871 INFO 
CREATE TABLE renewal (
	renewal_id INTEGER NOT NULL, 
	policy_event_id INTEGER, 
	PRIMARY KEY (renewal_id), 
	FOREIGN KEY(policy_event_id) REFERENCES policy_event (policy_event_id)
)


-- 2025-10-14 16:54:57,872 INFO [no key 0.00117s] ()
-- 2025-10-14 16:54:58,089 INFO 
CREATE TABLE coverage_level (
	coverage_level_id INTEGER NOT NULL, 
	coverage_id INTEGER, 
	coverage_limit_type_id INTEGER, 
	maximum_per_person_amount FLOAT, 
	aggregate_limit_amount FLOAT, 
	maximum_per_claim_amount FLOAT, 
	deductible_rate FLOAT, 
	coverage_label_name VARCHAR, 
	PRIMARY KEY (coverage_level_id), 
	FOREIGN KEY(coverage_id) REFERENCES coverage (coverage_id), 
	FOREIGN KEY(coverage_limit_type_id) REFERENCES coverage_limit_type (coverage_limit_type_id)
)


-- 2025-10-14 16:54:58,090 INFO [no key 0.00194s] ()
-- 2025-10-14 16:54:58,301 INFO 
CREATE TABLE household_person (
	household_person_id INTEGER NOT NULL, 
	household_id INTEGER, 
	person_id INTEGER, 
	PRIMARY KEY (household_person_id), 
	FOREIGN KEY(household_id) REFERENCES household (household_id), 
	FOREIGN KEY(person_id) REFERENCES person (person_id)
)


-- 2025-10-14 16:54:58,302 INFO [no key 0.00116s] ()
-- 2025-10-14 16:54:58,518 INFO 
CREATE TABLE household_person_role (
	household_person_role_id INTEGER NOT NULL, 
	household_id INTEGER, 
	party_role_code VARCHAR, 
	begin_date DATE, 
	person_id INTEGER, 
	end_date DATE, 
	PRIMARY KEY (household_person_role_id), 
	FOREIGN KEY(household_id) REFERENCES household (household_id), 
	FOREIGN KEY(party_role_code) REFERENCES party_role (party_role_code), 
	FOREIGN KEY(person_id) REFERENCES person (person_id)
)


-- 2025-10-14 16:54:58,519 INFO [no key 0.00118s] ()
-- 2025-10-14 16:54:58,735 INFO 
CREATE TABLE communication_identity (
	communication_id INTEGER NOT NULL, 
	communication_type_code VARCHAR, 
	communication_value VARCHAR, 
	communication_qualifier_value VARCHAR, 
	geographic_location_id INTEGER, 
	PRIMARY KEY (communication_id), 
	FOREIGN KEY(geographic_location_id) REFERENCES geographic_location (geographic_location_id)
)


-- 2025-10-14 16:54:58,736 INFO [no key 0.00099s] ()
-- 2025-10-14 16:54:59,002 INFO 
CREATE TABLE insurable_object (
	insurable_object_id INTEGER NOT NULL, 
	insurable_object_type_code INTEGER, 
	geographic_location_id INTEGER, 
	PRIMARY KEY (insurable_object_id), 
	FOREIGN KEY(geographic_location_id) REFERENCES geographic_location (geographic_location_id)
)


-- 2025-10-14 16:54:59,003 INFO [no key 0.00132s] ()
-- 2025-10-14 16:54:59,219 INFO 
CREATE TABLE agreement (
	agreement_id INTEGER NOT NULL, 
	agreement_type_code INTEGER, 
	agreement_name VARCHAR, 
	agreement_original_inception_date DATE, 
	product_id INTEGER, 
	PRIMARY KEY (agreement_id), 
	FOREIGN KEY(product_id) REFERENCES product (product_id)
)


-- 2025-10-14 16:54:59,220 INFO [no key 0.00101s] ()
-- 2025-10-14 16:54:59,432 INFO 
CREATE TABLE financial_adviser (
	financial_adviser_id INTEGER NOT NULL, 
	financial_service_id INTEGER, 
	PRIMARY KEY (financial_adviser_id), 
	FOREIGN KEY(financial_service_id) REFERENCES financial_service (financial_service_id)
)


-- 2025-10-14 16:54:59,434 INFO [no key 0.00199s] ()
-- 2025-10-14 16:54:59,651 INFO 
CREATE TABLE financial_analyst (
	financial_analyst_id INTEGER NOT NULL, 
	financial_service_id INTEGER, 
	PRIMARY KEY (financial_analyst_id), 
	FOREIGN KEY(financial_service_id) REFERENCES financial_service (financial_service_id)
)


-- 2025-10-14 16:54:59,652 INFO [no key 0.00120s] ()
-- 2025-10-14 16:54:59,891 INFO 
CREATE TABLE account_provider (
	account_provider_id INTEGER NOT NULL, 
	financial_service_id INTEGER, 
	PRIMARY KEY (account_provider_id), 
	FOREIGN KEY(financial_service_id) REFERENCES financial_service (financial_service_id)
)


-- 2025-10-14 16:54:59,892 INFO [no key 0.00111s] ()
-- 2025-10-14 16:55:00,111 INFO 
CREATE TABLE prospect (
	prospect_id INTEGER NOT NULL, 
	account_role_id INTEGER, 
	PRIMARY KEY (prospect_id), 
	FOREIGN KEY(account_role_id) REFERENCES account_role (account_role_id)
)


-- 2025-10-14 16:55:00,113 INFO [no key 0.00245s] ()
-- 2025-10-14 16:55:00,440 INFO 
CREATE TABLE customer (
	prospect_id INTEGER NOT NULL, 
	account_role_id INTEGER, 
	PRIMARY KEY (prospect_id), 
	FOREIGN KEY(account_role_id) REFERENCES account_role (account_role_id)
)


-- 2025-10-14 16:55:00,441 INFO [no key 0.00142s] ()
-- 2025-10-14 16:55:00,646 INFO 
CREATE TABLE occurrence (
	occurrence_id INTEGER NOT NULL, 
	catastrophic_event_indicator INTEGER, 
	geographic_location_id INTEGER, 
	occurrence_begin_date DATE, 
	occurrence_begin_time TIME, 
	occurrence_end_date DATE, 
	occurrence_end_time TIME, 
	PRIMARY KEY (occurrence_id), 
	FOREIGN KEY(geographic_location_id) REFERENCES geographic_location (geographic_location_id)
)


-- 2025-10-14 16:55:00,647 INFO [no key 0.00146s] ()
-- 2025-10-14 16:55:00,876 INFO 
CREATE TABLE subcontractor (
	subcontractor_id INTEGER NOT NULL, 
	contractor_id INTEGER, 
	PRIMARY KEY (subcontractor_id), 
	FOREIGN KEY(contractor_id) REFERENCES contractor (contractor_id)
)


-- 2025-10-14 16:55:00,878 INFO [no key 0.00269s] ()
-- 2025-10-14 16:55:01,170 INFO 
CREATE TABLE premium_auditor (
	premium_auditor_id INTEGER NOT NULL, 
	auditor_id INTEGER, 
	PRIMARY KEY (premium_auditor_id), 
	FOREIGN KEY(auditor_id) REFERENCES auditor (auditor_id)
)


-- 2025-10-14 16:55:01,184 INFO [no key 0.01369s] ()
-- 2025-10-14 16:55:01,388 INFO 
CREATE TABLE producer (
	producer_id INTEGER NOT NULL, 
	agreement_role_id INTEGER, 
	PRIMARY KEY (producer_id), 
	FOREIGN KEY(agreement_role_id) REFERENCES agreement_role (agreement_role_id)
)


-- 2025-10-14 16:55:01,389 INFO [no key 0.00134s] ()
-- 2025-10-14 16:55:01,718 INFO 
CREATE TABLE supplier (
	supplier_id INTEGER NOT NULL, 
	agreement_role_id INTEGER, 
	PRIMARY KEY (supplier_id), 
	FOREIGN KEY(agreement_role_id) REFERENCES agreement_role (agreement_role_id)
)


-- 2025-10-14 16:55:01,719 INFO [no key 0.00104s] ()
-- 2025-10-14 16:55:02,074 INFO 
CREATE TABLE channel_role (
	channel_role_id INTEGER NOT NULL, 
	agreement_role_id INTEGER, 
	PRIMARY KEY (channel_role_id), 
	FOREIGN KEY(agreement_role_id) REFERENCES agreement_role (agreement_role_id)
)


-- 2025-10-14 16:55:02,075 INFO [no key 0.00118s] ()
-- 2025-10-14 16:55:02,400 INFO 
CREATE TABLE service_provider (
	service_provider_id INTEGER NOT NULL, 
	agreement_role_id INTEGER, 
	PRIMARY KEY (service_provider_id), 
	FOREIGN KEY(agreement_role_id) REFERENCES agreement_role (agreement_role_id)
)


-- 2025-10-14 16:55:02,401 INFO [no key 0.00103s] ()
-- 2025-10-14 16:55:02,633 INFO 
CREATE TABLE financial_interest_role (
	financial_interest_role_id INTEGER NOT NULL, 
	agreement_role_id INTEGER, 
	PRIMARY KEY (financial_interest_role_id), 
	FOREIGN KEY(agreement_role_id) REFERENCES agreement_role (agreement_role_id)
)


-- 2025-10-14 16:55:02,634 INFO [no key 0.00124s] ()
-- 2025-10-14 16:55:02,854 INFO 
CREATE TABLE inpatient (
	inpatient_id INTEGER NOT NULL, 
	patient_id INTEGER, 
	PRIMARY KEY (inpatient_id), 
	FOREIGN KEY(patient_id) REFERENCES patient (patient_id)
)


-- 2025-10-14 16:55:02,855 INFO [no key 0.00116s] ()
-- 2025-10-14 16:55:03,092 INFO 
CREATE TABLE outpatient (
	outpatient_id INTEGER NOT NULL, 
	patient_id INTEGER, 
	PRIMARY KEY (outpatient_id), 
	FOREIGN KEY(patient_id) REFERENCES patient (patient_id)
)


-- 2025-10-14 16:55:03,093 INFO [no key 0.00110s] ()
-- 2025-10-14 16:55:03,319 INFO 
CREATE TABLE field_organization_unit (
	field_organization_unit_id INTEGER NOT NULL, 
	organization_unit_id INTEGER, 
	PRIMARY KEY (field_organization_unit_id), 
	FOREIGN KEY(organization_unit_id) REFERENCES organization_unit (organization_unit_id)
)


-- 2025-10-14 16:55:03,320 INFO [no key 0.00090s] ()
-- 2025-10-14 16:55:03,537 INFO 
CREATE TABLE administrative_organization_unit (
	administrative_organization_unit_id INTEGER NOT NULL, 
	organization_unit_id INTEGER, 
	PRIMARY KEY (administrative_organization_unit_id), 
	FOREIGN KEY(organization_unit_id) REFERENCES organization_unit (organization_unit_id)
)


-- 2025-10-14 16:55:03,540 INFO [no key 0.00299s] ()
-- 2025-10-14 16:55:03,807 INFO 
CREATE TABLE full_term (
	full_term_id INTEGER NOT NULL, 
	endorsement_id INTEGER, 
	PRIMARY KEY (full_term_id), 
	FOREIGN KEY(endorsement_id) REFERENCES endorsement (endorsement_id)
)


-- 2025-10-14 16:55:03,808 INFO [no key 0.00139s] ()
-- 2025-10-14 16:55:04,068 INFO 
CREATE TABLE mid_term (
	mid_term_id INTEGER NOT NULL, 
	endorsement_id INTEGER, 
	PRIMARY KEY (mid_term_id), 
	FOREIGN KEY(endorsement_id) REFERENCES endorsement (endorsement_id)
)


-- 2025-10-14 16:55:04,069 INFO [no key 0.00105s] ()
-- 2025-10-14 16:55:04,305 INFO 
CREATE TABLE audit (
	audit_id INTEGER NOT NULL, 
	endorsement_id INTEGER, 
	PRIMARY KEY (audit_id), 
	FOREIGN KEY(endorsement_id) REFERENCES endorsement (endorsement_id)
)


-- 2025-10-14 16:55:04,307 INFO [no key 0.00169s] ()
-- 2025-10-14 16:55:04,517 INFO 
CREATE TABLE pro_rata (
	pro_rata_id INTEGER NOT NULL, 
	cancel_id INTEGER, 
	PRIMARY KEY (pro_rata_id), 
	FOREIGN KEY(cancel_id) REFERENCES cancel (cancel_id)
)


-- 2025-10-14 16:55:04,519 INFO [no key 0.00225s] ()
-- 2025-10-14 16:55:04,865 INFO 
CREATE TABLE short_rate (
	short_rate_id INTEGER NOT NULL, 
	cancel_id INTEGER, 
	PRIMARY KEY (short_rate_id), 
	FOREIGN KEY(cancel_id) REFERENCES cancel (cancel_id)
)


-- 2025-10-14 16:55:04,868 INFO [no key 0.00271s] ()
-- 2025-10-14 16:55:05,083 INFO 
CREATE TABLE flat (
	flat_id INTEGER NOT NULL, 
	cancel_id INTEGER, 
	PRIMARY KEY (flat_id), 
	FOREIGN KEY(cancel_id) REFERENCES cancel (cancel_id)
)


-- 2025-10-14 16:55:05,084 INFO [no key 0.00134s] ()
-- 2025-10-14 16:55:05,288 INFO 
CREATE TABLE product_coverage (
	product_coverage_id INTEGER NOT NULL, 
	product_id INTEGER, 
	coverage_id INTEGER, 
	PRIMARY KEY (product_coverage_id), 
	FOREIGN KEY(product_id) REFERENCES product (product_id), 
	FOREIGN KEY(coverage_id) REFERENCES coverage (coverage_id)
)


-- 2025-10-14 16:55:05,289 INFO [no key 0.00102s] ()
-- 2025-10-14 16:55:05,519 INFO 
CREATE TABLE rating_territory_geographic_location (
	rating_territory_geographic_location_id INTEGER NOT NULL, 
	geographic_location_id INTEGER, 
	rating_territory_id INTEGER, 
	PRIMARY KEY (rating_territory_geographic_location_id), 
	FOREIGN KEY(geographic_location_id) REFERENCES geographic_location (geographic_location_id), 
	FOREIGN KEY(rating_territory_id) REFERENCES rating_territory (rating_territory_id)
)


-- 2025-10-14 16:55:05,520 INFO [no key 0.00126s] ()
-- 2025-10-14 16:55:05,749 INFO 
CREATE TABLE company_jurisdiction (
	company_jurisdiction_id INTEGER NOT NULL, 
	company_id INTEGER, 
	geographic_location_id INTEGER, 
	PRIMARY KEY (company_jurisdiction_id), 
	FOREIGN KEY(company_id) REFERENCES company (company_id), 
	FOREIGN KEY(geographic_location_id) REFERENCES geographic_location (geographic_location_id)
)


-- 2025-10-14 16:55:05,750 INFO [no key 0.00115s] ()
-- 2025-10-14 16:55:05,979 INFO 
CREATE TABLE party_communication (
	party_communication_id INTEGER NOT NULL, 
	party_id INTEGER, 
	communication_id INTEGER, 
	party_locality_code INTEGER, 
	begin_date DATE, 
	end_date DATE, 
	preference_sequence_number INTEGER, 
	preference_day_and_time_group_code INTEGER, 
	party_routing_description VARCHAR, 
	PRIMARY KEY (party_communication_id), 
	FOREIGN KEY(party_id) REFERENCES party (party_id), 
	FOREIGN KEY(communication_id) REFERENCES communication_identity (communication_id)
)


-- 2025-10-14 16:55:05,980 INFO [no key 0.00111s] ()
-- 2025-10-14 16:55:06,198 INFO 
CREATE TABLE claim (
	claim_id INTEGER NOT NULL, 
	occurrence_id INTEGER, 
	catastrophe_id INTEGER, 
	insurable_object_id INTEGER, 
	company_claim_number INTEGER, 
	company_subclaim_number INTEGER, 
	claim_description VARCHAR, 
	claim_open_date DATE, 
	claim_close_date DATE, 
	claim_reopen_date DATE, 
	claim_status_code VARCHAR, 
	claim_reported_date DATE, 
	claims_made_date DATE, 
	entry_in_to_claims_made_program_date DATE, 
	PRIMARY KEY (claim_id), 
	FOREIGN KEY(occurrence_id) REFERENCES occurrence (occurrence_id), 
	FOREIGN KEY(catastrophe_id) REFERENCES catastrophe (catastrophe_id), 
	FOREIGN KEY(insurable_object_id) REFERENCES insurable_object (insurable_object_id)
)


-- 2025-10-14 16:55:06,199 INFO [no key 0.00111s] ()
-- 2025-10-14 16:55:06,411 INFO 
CREATE TABLE insurable_object_party_role (
	insurable_object_party_role_id INTEGER NOT NULL, 
	insurable_object_id INTEGER, 
	party_role_code VARCHAR, 
	effective_date DATE, 
	party_id INTEGER, 
	expiration_date DATE, 
	PRIMARY KEY (insurable_object_party_role_id), 
	FOREIGN KEY(insurable_object_id) REFERENCES insurable_object (insurable_object_id), 
	FOREIGN KEY(party_role_code) REFERENCES party_role (party_role_code), 
	FOREIGN KEY(party_id) REFERENCES party (party_id)
)


-- 2025-10-14 16:55:06,412 INFO [no key 0.00112s] ()
-- 2025-10-14 16:55:06,628 INFO 
CREATE TABLE agreement_party_role (
	agreement_party_role_id INTEGER NOT NULL, 
	agreement_id INTEGER, 
	party_role_code VARCHAR, 
	effective_date DATE, 
	party_id INTEGER, 
	expiration_date DATE, 
	PRIMARY KEY (agreement_party_role_id), 
	FOREIGN KEY(agreement_id) REFERENCES agreement (agreement_id), 
	FOREIGN KEY(party_role_code) REFERENCES party_role (party_role_code), 
	FOREIGN KEY(party_id) REFERENCES party (party_id)
)


-- 2025-10-14 16:55:06,630 INFO [no key 0.00118s] ()
-- 2025-10-14 16:55:06,841 INFO 
CREATE TABLE account_agreement (
	account_agreement_id INTEGER NOT NULL, 
	account_id INTEGER, 
	agreement_id INTEGER, 
	PRIMARY KEY (account_agreement_id), 
	FOREIGN KEY(account_id) REFERENCES account (account_id), 
	FOREIGN KEY(agreement_id) REFERENCES agreement (agreement_id)
)


-- 2025-10-14 16:55:06,842 INFO [no key 0.00133s] ()
-- 2025-10-14 16:55:07,061 INFO 
CREATE TABLE agency_contract (
	agency_contract_id INTEGER NOT NULL, 
	agreement_id INTEGER, 
	PRIMARY KEY (agency_contract_id), 
	FOREIGN KEY(agreement_id) REFERENCES agreement (agreement_id)
)


-- 2025-10-14 16:55:07,063 INFO [no key 0.00187s] ()
-- 2025-10-14 16:55:07,277 INFO 
CREATE TABLE commercial_agreement (
	commercial_agreement_id INTEGER NOT NULL, 
	agreement_id INTEGER, 
	PRIMARY KEY (commercial_agreement_id), 
	FOREIGN KEY(agreement_id) REFERENCES agreement (agreement_id)
)


-- 2025-10-14 16:55:07,278 INFO [no key 0.00128s] ()
-- 2025-10-14 16:55:07,493 INFO 
CREATE TABLE brokerage_contract (
	brokerage_contract_id INTEGER NOT NULL, 
	agreement_id INTEGER, 
	PRIMARY KEY (brokerage_contract_id), 
	FOREIGN KEY(agreement_id) REFERENCES agreement (agreement_id)
)


-- 2025-10-14 16:55:07,494 INFO [no key 0.00113s] ()
-- 2025-10-14 16:55:07,723 INFO 
CREATE TABLE financial_account_agreement (
	financial_account_agreement_id INTEGER NOT NULL, 
	agreement_id INTEGER, 
	PRIMARY KEY (financial_account_agreement_id), 
	FOREIGN KEY(agreement_id) REFERENCES agreement (agreement_id)
)


-- 2025-10-14 16:55:07,724 INFO [no key 0.00109s] ()
-- 2025-10-14 16:55:07,937 INFO 
CREATE TABLE derivative_contract (
	derivative_contract_id INTEGER NOT NULL, 
	agreement_id INTEGER, 
	PRIMARY KEY (derivative_contract_id), 
	FOREIGN KEY(agreement_id) REFERENCES agreement (agreement_id)
)


-- 2025-10-14 16:55:07,938 INFO [no key 0.00097s] ()
-- 2025-10-14 16:55:08,165 INFO 
CREATE TABLE intermediary_agreement (
	intermediary_agreement_id INTEGER NOT NULL, 
	agreement_id INTEGER, 
	PRIMARY KEY (intermediary_agreement_id), 
	FOREIGN KEY(agreement_id) REFERENCES agreement (agreement_id)
)


-- 2025-10-14 16:55:08,167 INFO [no key 0.00168s] ()
-- 2025-10-14 16:55:08,384 INFO 
CREATE TABLE group_agreement (
	group_agreement_id INTEGER NOT NULL, 
	agreement_id INTEGER, 
	PRIMARY KEY (group_agreement_id), 
	FOREIGN KEY(agreement_id) REFERENCES agreement (agreement_id)
)


-- 2025-10-14 16:55:08,386 INFO [no key 0.00221s] ()
-- 2025-10-14 16:55:08,615 INFO 
CREATE TABLE commutation_agreement (
	commutation_agreement_id INTEGER NOT NULL, 
	agreement_id INTEGER, 
	PRIMARY KEY (commutation_agreement_id), 
	FOREIGN KEY(agreement_id) REFERENCES agreement (agreement_id)
)


-- 2025-10-14 16:55:08,616 INFO [no key 0.00121s] ()
-- 2025-10-14 16:55:08,831 INFO 
CREATE TABLE provider_agreement (
	provider_agreement_id INTEGER NOT NULL, 
	agreement_id INTEGER, 
	PRIMARY KEY (provider_agreement_id), 
	FOREIGN KEY(agreement_id) REFERENCES agreement (agreement_id)
)


-- 2025-10-14 16:55:08,832 INFO [no key 0.00113s] ()
-- 2025-10-14 16:55:09,174 INFO 
CREATE TABLE individual_agreement (
	individual_agreement_id INTEGER NOT NULL, 
	agreement_id INTEGER, 
	PRIMARY KEY (individual_agreement_id), 
	FOREIGN KEY(agreement_id) REFERENCES agreement (agreement_id)
)


-- 2025-10-14 16:55:09,175 INFO [no key 0.00097s] ()
-- 2025-10-14 16:55:09,387 INFO 
CREATE TABLE auto_repair_shop_contract (
	auto_repair_shop_contract_id INTEGER NOT NULL, 
	agreement_id INTEGER, 
	PRIMARY KEY (auto_repair_shop_contract_id), 
	FOREIGN KEY(agreement_id) REFERENCES agreement (agreement_id)
)


-- 2025-10-14 16:55:09,389 INFO [no key 0.00162s] ()
-- 2025-10-14 16:55:09,616 INFO 
CREATE TABLE staffing_agreement (
	staffing_agreement_id INTEGER NOT NULL, 
	agreement_id INTEGER, 
	PRIMARY KEY (staffing_agreement_id), 
	FOREIGN KEY(agreement_id) REFERENCES agreement (agreement_id)
)


-- 2025-10-14 16:55:09,618 INFO [no key 0.00190s] ()
-- 2025-10-14 16:55:09,855 INFO 
CREATE TABLE policy_coverage_detail (
	policy_coverage_detail_id INTEGER NOT NULL, 
	effective_date DATE, 
	policy_id INTEGER, 
	coverage_part_code INTEGER, 
	coverage_id INTEGER, 
	insurable_object_id INTEGER, 
	expiration_date DATE, 
	coverage_inclusion_exclusion_code INTEGER, 
	coverage_description VARCHAR, 
	PRIMARY KEY (policy_coverage_detail_id), 
	FOREIGN KEY(policy_id) REFERENCES policy (policy_id), 
	FOREIGN KEY(coverage_part_code) REFERENCES policy_coverage_part (coverage_part_code), 
	FOREIGN KEY(coverage_id) REFERENCES coverage (coverage_id), 
	FOREIGN KEY(insurable_object_id) REFERENCES insurable_object (insurable_object_id)
)


-- 2025-10-14 16:55:09,857 INFO [no key 0.00149s] ()
-- 2025-10-14 16:55:10,080 INFO 
CREATE TABLE agreement_assessment (
	agreement_assessment_id INTEGER NOT NULL, 
	agreement_id INTEGER, 
	assessment_id INTEGER, 
	PRIMARY KEY (agreement_assessment_id), 
	FOREIGN KEY(agreement_id) REFERENCES agreement (agreement_id), 
	FOREIGN KEY(assessment_id) REFERENCES assessment (assessment_id)
)


-- 2025-10-14 16:55:10,082 INFO [no key 0.00109s] ()
-- 2025-10-14 16:55:10,404 INFO 
CREATE TABLE object_assessment (
	object_assessment_id INTEGER NOT NULL, 
	insurable_object_id INTEGER, 
	assessment_id INTEGER, 
	PRIMARY KEY (object_assessment_id), 
	FOREIGN KEY(insurable_object_id) REFERENCES insurable_object (insurable_object_id), 
	FOREIGN KEY(assessment_id) REFERENCES assessment (assessment_id)
)


-- 2025-10-14 16:55:10,405 INFO [no key 0.00111s] ()
-- 2025-10-14 16:55:10,777 INFO 
CREATE TABLE agent (
	agent_id INTEGER NOT NULL, 
	producer_id INTEGER, 
	PRIMARY KEY (agent_id), 
	FOREIGN KEY(producer_id) REFERENCES producer (producer_id)
)


-- 2025-10-14 16:55:10,778 INFO [no key 0.00100s] ()
-- 2025-10-14 16:55:11,010 INFO 
CREATE TABLE broker (
	broker_id INTEGER NOT NULL, 
	producer_id INTEGER, 
	PRIMARY KEY (broker_id), 
	FOREIGN KEY(producer_id) REFERENCES producer (producer_id)
)


-- 2025-10-14 16:55:11,011 INFO [no key 0.00117s] ()
-- 2025-10-14 16:55:11,335 INFO 
CREATE TABLE managing_general_agent (
	managing_general_agent_id INTEGER NOT NULL, 
	producer_id INTEGER, 
	PRIMARY KEY (managing_general_agent_id), 
	FOREIGN KEY(producer_id) REFERENCES producer (producer_id)
)


-- 2025-10-14 16:55:11,336 INFO [no key 0.00098s] ()
-- 2025-10-14 16:55:11,545 INFO 
CREATE TABLE insured (
	insured_id INTEGER NOT NULL, 
	financial_interest_role_id INTEGER, 
	PRIMARY KEY (insured_id), 
	FOREIGN KEY(financial_interest_role_id) REFERENCES financial_interest_role (financial_interest_role_id)
)


-- 2025-10-14 16:55:11,546 INFO [no key 0.00120s] ()
-- 2025-10-14 16:55:11,768 INFO 
CREATE TABLE insurer (
	insurer_id INTEGER NOT NULL, 
	financial_interest_role_id INTEGER, 
	PRIMARY KEY (insurer_id), 
	FOREIGN KEY(financial_interest_role_id) REFERENCES financial_interest_role (financial_interest_role_id)
)


-- 2025-10-14 16:55:11,768 INFO [no key 0.00100s] ()
-- 2025-10-14 16:55:11,998 INFO 
CREATE TABLE additional_interest (
	additional_interest_id INTEGER NOT NULL, 
	financial_interest_role_id INTEGER, 
	PRIMARY KEY (additional_interest_id), 
	FOREIGN KEY(financial_interest_role_id) REFERENCES financial_interest_role (financial_interest_role_id)
)


-- 2025-10-14 16:55:12,001 INFO [no key 0.00265s] ()
-- 2025-10-14 16:55:12,219 INFO 
CREATE TABLE territory (
	territory_id INTEGER NOT NULL, 
	field_organization_unit_id INTEGER, 
	PRIMARY KEY (territory_id), 
	FOREIGN KEY(field_organization_unit_id) REFERENCES field_organization_unit (field_organization_unit_id)
)


-- 2025-10-14 16:55:12,220 INFO [no key 0.00122s] ()
-- 2025-10-14 16:55:12,539 INFO 
CREATE TABLE department (
	department_id INTEGER NOT NULL, 
	administrative_organization_unit_id INTEGER, 
	PRIMARY KEY (department_id), 
	FOREIGN KEY(administrative_organization_unit_id) REFERENCES administrative_organization_unit (administrative_organization_unit_id)
)


-- 2025-10-14 16:55:12,540 INFO [no key 0.00115s] ()
-- 2025-10-14 16:55:12,762 INFO 
CREATE TABLE vehicle (
	vehicle_id INTEGER NOT NULL, 
	insurable_object_id INTEGER, 
	vehicle_model_year INTEGER, 
	vehicle_model_name VARCHAR, 
	vehicle_driving_wheel_quantity INTEGER, 
	vehicle_make_name VARCHAR, 
	vehicle_identification_number VARCHAR, 
	PRIMARY KEY (vehicle_id), 
	FOREIGN KEY(insurable_object_id) REFERENCES insurable_object (insurable_object_id)
)


-- 2025-10-14 16:55:12,763 INFO [no key 0.00102s] ()
-- 2025-10-14 16:55:13,022 INFO 
CREATE TABLE manufactured_object (
	manufactured_object_id INTEGER NOT NULL, 
	insurable_object_id INTEGER, 
	PRIMARY KEY (manufactured_object_id), 
	FOREIGN KEY(insurable_object_id) REFERENCES insurable_object (insurable_object_id)
)


-- 2025-10-14 16:55:13,023 INFO [no key 0.00131s] ()
-- 2025-10-14 16:55:13,353 INFO 
CREATE TABLE farm_equipment (
	farm_equipment_id INTEGER NOT NULL, 
	insurable_object_id INTEGER, 
	PRIMARY KEY (farm_equipment_id), 
	FOREIGN KEY(insurable_object_id) REFERENCES insurable_object (insurable_object_id)
)


-- 2025-10-14 16:55:13,354 INFO [no key 0.00107s] ()
-- 2025-10-14 16:55:13,590 INFO 
CREATE TABLE body_object (
	body_object_id INTEGER NOT NULL, 
	insurable_object_id INTEGER, 
	PRIMARY KEY (body_object_id), 
	FOREIGN KEY(insurable_object_id) REFERENCES insurable_object (insurable_object_id)
)


-- 2025-10-14 16:55:13,591 INFO [no key 0.00106s] ()
-- 2025-10-14 16:55:13,811 INFO 
CREATE TABLE workers_comp_class (
	workers_comp_class_id INTEGER NOT NULL, 
	insurable_object_id INTEGER, 
	PRIMARY KEY (workers_comp_class_id), 
	FOREIGN KEY(insurable_object_id) REFERENCES insurable_object (insurable_object_id)
)


-- 2025-10-14 16:55:13,812 INFO [no key 0.00098s] ()
-- 2025-10-14 16:55:14,082 INFO 
CREATE TABLE structure (
	structure_id INTEGER NOT NULL, 
	insurable_object_id INTEGER, 
	PRIMARY KEY (structure_id), 
	FOREIGN KEY(insurable_object_id) REFERENCES insurable_object (insurable_object_id)
)


-- 2025-10-14 16:55:14,083 INFO [no key 0.00145s] ()
-- 2025-10-14 16:55:14,450 INFO 
CREATE TABLE transportation_class (
	transportation_class_id INTEGER NOT NULL, 
	insurable_object_id INTEGER, 
	PRIMARY KEY (transportation_class_id), 
	FOREIGN KEY(insurable_object_id) REFERENCES insurable_object (insurable_object_id)
)


-- 2025-10-14 16:55:14,451 INFO [no key 0.00117s] ()
-- 2025-10-14 16:55:14,660 INFO 
CREATE TABLE product_license (
	product_license_id INTEGER NOT NULL, 
	company_jurisdiction_id INTEGER, 
	effective_date DATE, 
	expiration_date DATE, 
	PRIMARY KEY (product_license_id), 
	FOREIGN KEY(company_jurisdiction_id) REFERENCES company_jurisdiction (company_jurisdiction_id)
)


-- 2025-10-14 16:55:14,662 INFO [no key 0.00195s] ()
-- 2025-10-14 16:55:14,877 INFO 
CREATE TABLE policy_limit (
	policy_limit_id INTEGER NOT NULL, 
	policy_coverage_detail_id INTEGER, 
	limit_type_code INTEGER, 
	limit_basis_code INTEGER, 
	limit_value FLOAT, 
	PRIMARY KEY (policy_limit_id), 
	FOREIGN KEY(policy_coverage_detail_id) REFERENCES policy_coverage_detail (policy_coverage_detail_id)
)


-- 2025-10-14 16:55:14,879 INFO [no key 0.00202s] ()
-- 2025-10-14 16:55:15,204 INFO 
CREATE TABLE policy_deductible (
	policy_deductible_identifier INTEGER NOT NULL, 
	policy_coverage_detail_id INTEGER, 
	deductible_type_code INTEGER, 
	deductible_basis_code INTEGER, 
	deductible_value FLOAT, 
	PRIMARY KEY (policy_deductible_identifier), 
	FOREIGN KEY(policy_coverage_detail_id) REFERENCES policy_coverage_detail (policy_coverage_detail_id)
)


-- 2025-10-14 16:55:15,205 INFO [no key 0.00096s] ()
-- 2025-10-14 16:55:15,549 INFO 
CREATE TABLE policy_amount (
	policy_amount_id INTEGER NOT NULL, 
	policy_id INTEGER, 
	policy_coverage_detail_id INTEGER, 
	insurable_object_id INTEGER, 
	geographic_location_id INTEGER, 
	earning_begin_date DATE, 
	earning_end_date DATE, 
	insurance_type_code INTEGER, 
	amount_type_code INTEGER, 
	policy_amount FLOAT, 
	PRIMARY KEY (policy_amount_id), 
	FOREIGN KEY(policy_id) REFERENCES policy (policy_id), 
	FOREIGN KEY(policy_coverage_detail_id) REFERENCES policy_coverage_detail (policy_coverage_detail_id), 
	FOREIGN KEY(insurable_object_id) REFERENCES insurable_object (insurable_object_id), 
	FOREIGN KEY(geographic_location_id) REFERENCES geographic_location (geographic_location_id)
)


-- 2025-10-14 16:55:15,550 INFO [no key 0.00121s] ()
-- 2025-10-14 16:55:15,766 INFO 
CREATE TABLE claim_coverage (
	claim_coverage_id INTEGER NOT NULL, 
	claim_id INTEGER, 
	policy_coverage_detail_id INTEGER, 
	PRIMARY KEY (claim_coverage_id), 
	FOREIGN KEY(claim_id) REFERENCES claim (claim_id), 
	FOREIGN KEY(policy_coverage_detail_id) REFERENCES policy_coverage_detail (policy_coverage_detail_id)
)


-- 2025-10-14 16:55:15,767 INFO [no key 0.00137s] ()
-- 2025-10-14 16:55:16,111 INFO 
CREATE TABLE claim_folder (
	claim_folder_id INTEGER NOT NULL, 
	claim_id INTEGER, 
	claim_folder_label_name VARCHAR, 
	PRIMARY KEY (claim_folder_id), 
	FOREIGN KEY(claim_id) REFERENCES claim (claim_id)
)


-- 2025-10-14 16:55:16,115 INFO [no key 0.00376s] ()
-- 2025-10-14 16:55:16,343 INFO 
CREATE TABLE arbitration_party_role (
	arbitration_party_id INTEGER NOT NULL, 
	arbitration_id INTEGER, 
	party_id INTEGER, 
	party_role_code VARCHAR, 
	begin_date DATE, 
	claim_id INTEGER, 
	end_date DATE, 
	PRIMARY KEY (arbitration_party_id), 
	FOREIGN KEY(arbitration_id) REFERENCES arbitration (arbitration_id), 
	FOREIGN KEY(party_id) REFERENCES party (party_id), 
	FOREIGN KEY(party_role_code) REFERENCES party_role (party_role_code), 
	FOREIGN KEY(claim_id) REFERENCES claim (claim_id)
)


-- 2025-10-14 16:55:16,344 INFO [no key 0.00092s] ()
-- 2025-10-14 16:55:16,570 INFO 
CREATE TABLE claim_litigation (
	claim_litigation_id INTEGER NOT NULL, 
	claim_id INTEGER, 
	litigation_id INTEGER, 
	PRIMARY KEY (claim_litigation_id), 
	FOREIGN KEY(claim_id) REFERENCES claim (claim_id), 
	FOREIGN KEY(litigation_id) REFERENCES litigation (litigation_id)
)


-- 2025-10-14 16:55:16,571 INFO [no key 0.00100s] ()
-- 2025-10-14 16:55:16,795 INFO 
CREATE TABLE claim_arbitration (
	claim_arbitration_id INTEGER NOT NULL, 
	claim_id INTEGER, 
	arbitration_id INTEGER, 
	PRIMARY KEY (claim_arbitration_id), 
	FOREIGN KEY(claim_id) REFERENCES claim (claim_id), 
	FOREIGN KEY(arbitration_id) REFERENCES arbitration (arbitration_id)
)


-- 2025-10-14 16:55:16,796 INFO [no key 0.00125s] ()
-- 2025-10-14 16:55:17,071 INFO 
CREATE TABLE litigation_party_role (
	litigation_party_id INTEGER NOT NULL, 
	litigation_id INTEGER, 
	party_id INTEGER, 
	party_role_code VARCHAR, 
	begin_date DATE, 
	claim_id INTEGER, 
	end_date DATE, 
	PRIMARY KEY (litigation_party_id), 
	FOREIGN KEY(litigation_id) REFERENCES litigation (litigation_id), 
	FOREIGN KEY(party_id) REFERENCES party (party_id), 
	FOREIGN KEY(party_role_code) REFERENCES party_role (party_role_code), 
	FOREIGN KEY(claim_id) REFERENCES claim (claim_id)
)


-- 2025-10-14 16:55:17,073 INFO [no key 0.00122s] ()
-- 2025-10-14 16:55:17,326 INFO 
CREATE TABLE claim_assessment (
	claim_assessment_id INTEGER NOT NULL, 
	claim_id INTEGER, 
	assessment_id INTEGER, 
	PRIMARY KEY (claim_assessment_id), 
	FOREIGN KEY(claim_id) REFERENCES claim (claim_id), 
	FOREIGN KEY(assessment_id) REFERENCES assessment (assessment_id)
)


-- 2025-10-14 16:55:17,327 INFO [no key 0.00105s] ()
-- 2025-10-14 16:55:17,575 INFO 
CREATE TABLE employment_agreement (
	employment_agreement_id INTEGER NOT NULL, 
	staffing_agreement_id INTEGER, 
	PRIMARY KEY (employment_agreement_id), 
	FOREIGN KEY(staffing_agreement_id) REFERENCES staffing_agreement (staffing_agreement_id)
)


-- 2025-10-14 16:55:17,577 INFO [no key 0.00111s] ()
-- 2025-10-14 16:55:17,791 INFO 
CREATE TABLE consultant_contract (
	consultant_contract_id INTEGER NOT NULL, 
	staffing_agreement_id INTEGER, 
	PRIMARY KEY (consultant_contract_id), 
	FOREIGN KEY(staffing_agreement_id) REFERENCES staffing_agreement (staffing_agreement_id)
)


-- 2025-10-14 16:55:17,793 INFO [no key 0.00171s] ()
-- 2025-10-14 16:55:18,062 INFO 
CREATE TABLE third_party_staffing_agreement (
	third_party_staffing_agreement_id INTEGER NOT NULL, 
	staffing_agreement_id INTEGER, 
	PRIMARY KEY (third_party_staffing_agreement_id), 
	FOREIGN KEY(staffing_agreement_id) REFERENCES staffing_agreement (staffing_agreement_id)
)


-- 2025-10-14 16:55:18,063 INFO [no key 0.00123s] ()
-- 2025-10-14 16:55:18,431 INFO 
CREATE TABLE regional_office (
	regional_office_id INTEGER NOT NULL, 
	territory_id INTEGER, 
	PRIMARY KEY (regional_office_id), 
	FOREIGN KEY(territory_id) REFERENCES territory (territory_id)
)


-- 2025-10-14 16:55:18,432 INFO [no key 0.00101s] ()
-- 2025-10-14 16:55:18,762 INFO 
CREATE TABLE automobile (
	automobile_id INTEGER NOT NULL, 
	vehicle_id INTEGER, 
	PRIMARY KEY (automobile_id), 
	FOREIGN KEY(vehicle_id) REFERENCES vehicle (vehicle_id)
)


-- 2025-10-14 16:55:18,764 INFO [no key 0.00179s] ()
-- 2025-10-14 16:55:19,066 INFO 
CREATE TABLE van (
	van_id INTEGER NOT NULL, 
	vehicle_id INTEGER, 
	PRIMARY KEY (van_id), 
	FOREIGN KEY(vehicle_id) REFERENCES vehicle (vehicle_id)
)


-- 2025-10-14 16:55:19,067 INFO [no key 0.00128s] ()
-- 2025-10-14 16:55:19,308 INFO 
CREATE TABLE motorcycle (
	motorcycle_id INTEGER NOT NULL, 
	vehicle_id INTEGER, 
	PRIMARY KEY (motorcycle_id), 
	FOREIGN KEY(vehicle_id) REFERENCES vehicle (vehicle_id)
)


-- 2025-10-14 16:55:19,309 INFO [no key 0.00108s] ()
-- 2025-10-14 16:55:19,637 INFO 
CREATE TABLE recreational_vehicle (
	recreational_vehicle_id INTEGER NOT NULL, 
	vehicle_id INTEGER, 
	PRIMARY KEY (recreational_vehicle_id), 
	FOREIGN KEY(vehicle_id) REFERENCES vehicle (vehicle_id)
)


-- 2025-10-14 16:55:19,639 INFO [no key 0.00160s] ()
-- 2025-10-14 16:55:19,866 INFO 
CREATE TABLE construction_vehicle (
	construction_vehicle_id INTEGER NOT NULL, 
	vehicle_id INTEGER, 
	PRIMARY KEY (construction_vehicle_id), 
	FOREIGN KEY(vehicle_id) REFERENCES vehicle (vehicle_id)
)


-- 2025-10-14 16:55:19,868 INFO [no key 0.00193s] ()
-- 2025-10-14 16:55:20,128 INFO 
CREATE TABLE watercraft (
	watercraft_id INTEGER NOT NULL, 
	vehicle_id INTEGER, 
	PRIMARY KEY (watercraft_id), 
	FOREIGN KEY(vehicle_id) REFERENCES vehicle (vehicle_id)
)


-- 2025-10-14 16:55:20,129 INFO [no key 0.00101s] ()
-- 2025-10-14 16:55:20,359 INFO 
CREATE TABLE boat (
	boat_id INTEGER NOT NULL, 
	vehicle_id INTEGER, 
	PRIMARY KEY (boat_id), 
	FOREIGN KEY(vehicle_id) REFERENCES vehicle (vehicle_id)
)


-- 2025-10-14 16:55:20,361 INFO [no key 0.00120s] ()
-- 2025-10-14 16:55:20,569 INFO 
CREATE TABLE truck (
	truck_id INTEGER NOT NULL, 
	vehicle_id INTEGER, 
	PRIMARY KEY (truck_id), 
	FOREIGN KEY(vehicle_id) REFERENCES vehicle (vehicle_id)
)


-- 2025-10-14 16:55:20,570 INFO [no key 0.00134s] ()
-- 2025-10-14 16:55:20,800 INFO 
CREATE TABLE bus (
	bus_id INTEGER NOT NULL, 
	vehicle_id INTEGER, 
	PRIMARY KEY (bus_id), 
	FOREIGN KEY(vehicle_id) REFERENCES vehicle (vehicle_id)
)


-- 2025-10-14 16:55:20,801 INFO [no key 0.00112s] ()
-- 2025-10-14 16:55:21,076 INFO 
CREATE TABLE trailer (
	trailer_id INTEGER NOT NULL, 
	vehicle_id INTEGER, 
	PRIMARY KEY (trailer_id), 
	FOREIGN KEY(vehicle_id) REFERENCES vehicle (vehicle_id)
)


-- 2025-10-14 16:55:21,077 INFO [no key 0.00114s] ()
-- 2025-10-14 16:55:21,297 INFO 
CREATE TABLE tractor (
	tractor_id INTEGER NOT NULL, 
	farm_equipment_id INTEGER, 
	PRIMARY KEY (tractor_id), 
	FOREIGN KEY(farm_equipment_id) REFERENCES farm_equipment (farm_equipment_id)
)


-- 2025-10-14 16:55:21,299 INFO [no key 0.00189s] ()
-- 2025-10-14 16:55:21,641 INFO 
CREATE TABLE combine (
	combine_id INTEGER NOT NULL, 
	farm_equipment_id INTEGER, 
	PRIMARY KEY (combine_id), 
	FOREIGN KEY(farm_equipment_id) REFERENCES farm_equipment (farm_equipment_id)
)


-- 2025-10-14 16:55:21,642 INFO [no key 0.00122s] ()
-- 2025-10-14 16:55:21,861 INFO 
CREATE TABLE milking_machine (
	milking_machine_id INTEGER NOT NULL, 
	farm_equipment_id INTEGER, 
	PRIMARY KEY (milking_machine_id), 
	FOREIGN KEY(farm_equipment_id) REFERENCES farm_equipment (farm_equipment_id)
)


-- 2025-10-14 16:55:21,865 INFO [no key 0.00478s] ()
-- 2025-10-14 16:55:22,097 INFO 
CREATE TABLE animal (
	animal_id INTEGER NOT NULL, 
	body_object_id INTEGER, 
	PRIMARY KEY (animal_id), 
	FOREIGN KEY(body_object_id) REFERENCES body_object (body_object_id)
)


-- 2025-10-14 16:55:22,098 INFO [no key 0.00151s] ()
-- 2025-10-14 16:55:22,431 INFO 
CREATE TABLE commercial_structure (
	commercial_structure_id INTEGER NOT NULL, 
	structure_id INTEGER, 
	PRIMARY KEY (commercial_structure_id), 
	FOREIGN KEY(structure_id) REFERENCES structure (structure_id)
)


-- 2025-10-14 16:55:22,434 INFO [no key 0.00368s] ()
-- 2025-10-14 16:55:22,653 INFO 
CREATE TABLE combination_structure (
	combination_structure_id INTEGER NOT NULL, 
	structure_id INTEGER, 
	PRIMARY KEY (combination_structure_id), 
	FOREIGN KEY(structure_id) REFERENCES structure (structure_id)
)


-- 2025-10-14 16:55:22,654 INFO [no key 0.00110s] ()
-- 2025-10-14 16:55:22,869 INFO 
CREATE TABLE residential_structure (
	residential_structure_id INTEGER NOT NULL, 
	structure_id INTEGER, 
	PRIMARY KEY (residential_structure_id), 
	FOREIGN KEY(structure_id) REFERENCES structure (structure_id)
)


-- 2025-10-14 16:55:22,870 INFO [no key 0.00120s] ()
-- 2025-10-14 16:55:23,094 INFO 
CREATE TABLE scheduled_item (
	scheduled_item_id INTEGER NOT NULL, 
	transportation_class_id INTEGER, 
	PRIMARY KEY (scheduled_item_id), 
	FOREIGN KEY(transportation_class_id) REFERENCES transportation_class (transportation_class_id)
)


-- 2025-10-14 16:55:23,096 INFO [no key 0.00208s] ()
-- 2025-10-14 16:55:23,320 INFO 
CREATE TABLE property_in_transit (
	property_in_transit_id INTEGER NOT NULL, 
	transportation_class_id INTEGER, 
	PRIMARY KEY (property_in_transit_id), 
	FOREIGN KEY(transportation_class_id) REFERENCES transportation_class (transportation_class_id)
)


-- 2025-10-14 16:55:23,321 INFO [no key 0.00095s] ()
-- 2025-10-14 16:55:23,660 INFO 
CREATE TABLE freight_group (
	freight_group_id INTEGER NOT NULL, 
	transportation_class_id INTEGER, 
	PRIMARY KEY (freight_group_id), 
	FOREIGN KEY(transportation_class_id) REFERENCES transportation_class (transportation_class_id)
)


-- 2025-10-14 16:55:23,661 INFO [no key 0.00112s] ()
-- 2025-10-14 16:55:23,874 INFO 
CREATE TABLE household_content (
	household_content_id INTEGER NOT NULL, 
	transportation_class_id INTEGER, 
	household_id INTEGER, 
	PRIMARY KEY (household_content_id), 
	FOREIGN KEY(transportation_class_id) REFERENCES transportation_class (transportation_class_id), 
	FOREIGN KEY(household_id) REFERENCES household (household_id)
)


-- 2025-10-14 16:55:23,875 INFO [no key 0.00096s] ()
-- 2025-10-14 16:55:24,095 INFO 
CREATE TABLE claim_offer (
	claim_offer_id INTEGER NOT NULL, 
	claim_folder_id INTEGER, 
	arbitration_id INTEGER, 
	litigation_id INTEGER, 
	settlement_offer_amount FLOAT, 
	settlement_offer_provision_description VARCHAR, 
	PRIMARY KEY (claim_offer_id), 
	FOREIGN KEY(claim_folder_id) REFERENCES claim_folder (claim_folder_id), 
	FOREIGN KEY(arbitration_id) REFERENCES arbitration (arbitration_id), 
	FOREIGN KEY(litigation_id) REFERENCES litigation (litigation_id)
)


-- 2025-10-14 16:55:24,096 INFO [no key 0.00108s] ()
-- 2025-10-14 16:55:24,426 INFO 
CREATE TABLE claim_folder_document (
	claim_folder_document_id INTEGER NOT NULL, 
	claim_folder_id INTEGER, 
	document_sequence_number INTEGER, 
	document_link_value INTEGER, 
	PRIMARY KEY (claim_folder_document_id), 
	FOREIGN KEY(claim_folder_id) REFERENCES claim_folder (claim_folder_id)
)


-- 2025-10-14 16:55:24,427 INFO [no key 0.00118s] ()
-- 2025-10-14 16:55:24,673 INFO 
CREATE TABLE branch_office (
	branch_office_id INTEGER NOT NULL, 
	regional_office_id INTEGER, 
	PRIMARY KEY (branch_office_id), 
	FOREIGN KEY(regional_office_id) REFERENCES regional_office (regional_office_id)
)


-- 2025-10-14 16:55:24,674 INFO [no key 0.00141s] ()
-- 2025-10-14 16:55:24,889 INFO 
CREATE TABLE dwelling (
	dwelling_id INTEGER NOT NULL, 
	residential_structure_id INTEGER, 
	PRIMARY KEY (dwelling_id), 
	FOREIGN KEY(residential_structure_id) REFERENCES residential_structure (residential_structure_id)
)


-- 2025-10-14 16:55:24,891 INFO [no key 0.00245s] ()
-- 2025-10-14 16:55:25,121 INFO 
CREATE TABLE mobile_home (
	mobile_home_id INTEGER NOT NULL, 
	residential_structure_id INTEGER, 
	PRIMARY KEY (mobile_home_id), 
	FOREIGN KEY(residential_structure_id) REFERENCES residential_structure (residential_structure_id)
)


-- 2025-10-14 16:55:25,123 INFO [no key 0.00145s] ()
-- 2025-10-14 16:55:25,346 INFO 
CREATE TABLE premium (
	premium_id INTEGER NOT NULL, 
	policy_amount_id INTEGER, 
	PRIMARY KEY (premium_id), 
	FOREIGN KEY(policy_amount_id) REFERENCES policy_amount (policy_amount_id)
)


-- 2025-10-14 16:55:25,347 INFO [no key 0.00095s] ()
-- 2025-10-14 16:55:25,592 INFO 
CREATE TABLE tax (
	tax_id INTEGER NOT NULL, 
	policy_amount_id INTEGER, 
	PRIMARY KEY (tax_id), 
	FOREIGN KEY(policy_amount_id) REFERENCES policy_amount (policy_amount_id)
)


-- 2025-10-14 16:55:25,593 INFO [no key 0.00103s] ()
-- 2025-10-14 16:55:25,803 INFO 
CREATE TABLE surcharge (
	surcharge_id INTEGER NOT NULL, 
	policy_amount_id INTEGER, 
	PRIMARY KEY (surcharge_id), 
	FOREIGN KEY(policy_amount_id) REFERENCES policy_amount (policy_amount_id)
)


-- 2025-10-14 16:55:25,804 INFO [no key 0.00116s] ()
-- 2025-10-14 16:55:26,058 INFO 
CREATE TABLE fee (
	fee_id INTEGER NOT NULL, 
	policy_amount_id INTEGER, 
	PRIMARY KEY (fee_id), 
	FOREIGN KEY(policy_amount_id) REFERENCES policy_amount (policy_amount_id)
)


-- 2025-10-14 16:55:26,059 INFO [no key 0.00132s] ()
-- 2025-10-14 16:55:26,273 INFO 
CREATE TABLE direct_policy_amount (
	direct_policy_amount_id INTEGER NOT NULL, 
	policy_amount_id INTEGER, 
	PRIMARY KEY (direct_policy_amount_id), 
	FOREIGN KEY(policy_amount_id) REFERENCES policy_amount (policy_amount_id)
)


-- 2025-10-14 16:55:26,274 INFO [no key 0.00098s] ()
-- 2025-10-14 16:55:26,504 INFO 
CREATE TABLE assumed_policy_amount (
	assumed_policy_amount_id INTEGER NOT NULL, 
	policy_amount_id INTEGER, 
	PRIMARY KEY (assumed_policy_amount_id), 
	FOREIGN KEY(policy_amount_id) REFERENCES policy_amount (policy_amount_id)
)


-- 2025-10-14 16:55:26,505 INFO [no key 0.00116s] ()
-- 2025-10-14 16:55:26,710 INFO 
CREATE TABLE ceded_policy_amount (
	ceded_policy_amount_id INTEGER NOT NULL, 
	policy_amount_id INTEGER, 
	PRIMARY KEY (ceded_policy_amount_id), 
	FOREIGN KEY(policy_amount_id) REFERENCES policy_amount (policy_amount_id)
)


-- 2025-10-14 16:55:26,712 INFO [no key 0.00195s] ()
-- 2025-10-14 16:55:26,913 INFO 
CREATE TABLE credit_policy_amount (
	credit_policy_amount_id INTEGER NOT NULL, 
	policy_amount_id INTEGER, 
	PRIMARY KEY (credit_policy_amount_id), 
	FOREIGN KEY(policy_amount_id) REFERENCES policy_amount (policy_amount_id)
)


-- 2025-10-14 16:55:26,915 INFO [no key 0.00260s] ()
-- 2025-10-14 16:55:27,139 INFO 
CREATE TABLE debit_policy_amount (
	debit_policy_amount_id INTEGER NOT NULL, 
	policy_amount_id INTEGER, 
	PRIMARY KEY (debit_policy_amount_id), 
	FOREIGN KEY(policy_amount_id) REFERENCES policy_amount (policy_amount_id)
)


-- 2025-10-14 16:55:27,140 INFO [no key 0.00137s] ()
-- 2025-10-14 16:55:27,560 INFO 
CREATE TABLE claim_amount (
	claim_amount_id INTEGER NOT NULL, 
	claim_id INTEGER, 
	claim_offer_id INTEGER, 
	event_date DATE, 
	insurance_type_code INTEGER, 
	amount_type_code INTEGER, 
	claim_amount FLOAT, 
	PRIMARY KEY (claim_amount_id), 
	FOREIGN KEY(claim_id) REFERENCES claim (claim_id), 
	FOREIGN KEY(claim_offer_id) REFERENCES claim_offer (claim_offer_id)
)


-- 2025-10-14 16:55:27,562 INFO [no key 0.00204s] ()
-- 2025-10-14 16:55:27,766 INFO 
CREATE TABLE credit_claim_amount (
	credit_claim_amount_id INTEGER NOT NULL, 
	claim_amount_id INTEGER, 
	PRIMARY KEY (credit_claim_amount_id), 
	FOREIGN KEY(claim_amount_id) REFERENCES claim_amount (claim_amount_id)
)


-- 2025-10-14 16:55:27,767 INFO [no key 0.00107s] ()
-- 2025-10-14 16:55:27,995 INFO 
CREATE TABLE debit_claim_amount (
	debit_claim_amount_id INTEGER NOT NULL, 
	claim_amount_id INTEGER, 
	PRIMARY KEY (debit_claim_amount_id), 
	FOREIGN KEY(claim_amount_id) REFERENCES claim_amount (claim_amount_id)
)


-- 2025-10-14 16:55:27,996 INFO [no key 0.00100s] ()
-- 2025-10-14 16:55:28,204 INFO 
CREATE TABLE direct_claim_amount (
	direct_claim_amount_id INTEGER NOT NULL, 
	claim_amount_id INTEGER, 
	PRIMARY KEY (direct_claim_amount_id), 
	FOREIGN KEY(claim_amount_id) REFERENCES claim_amount (claim_amount_id)
)


-- 2025-10-14 16:55:28,205 INFO [no key 0.00106s] ()
-- 2025-10-14 16:55:28,429 INFO 
CREATE TABLE assumed_claim_amount (
	assumed_claim_amount_id INTEGER NOT NULL, 
	claim_amount_id INTEGER, 
	PRIMARY KEY (assumed_claim_amount_id), 
	FOREIGN KEY(claim_amount_id) REFERENCES claim_amount (claim_amount_id)
)


-- 2025-10-14 16:55:28,431 INFO [no key 0.00121s] ()
-- 2025-10-14 16:55:28,744 INFO 
CREATE TABLE ceded_claim_amount (
	ceded_claim_amount_id INTEGER NOT NULL, 
	claim_amount_id INTEGER, 
	PRIMARY KEY (ceded_claim_amount_id), 
	FOREIGN KEY(claim_amount_id) REFERENCES claim_amount (claim_amount_id)
)


-- 2025-10-14 16:55:28,746 INFO [no key 0.00145s] ()
-- 2025-10-14 16:55:28,964 INFO 
CREATE TABLE claim_reserve (
	claim_reserve_id INTEGER NOT NULL, 
	claim_amount_id INTEGER, 
	PRIMARY KEY (claim_reserve_id), 
	FOREIGN KEY(claim_amount_id) REFERENCES claim_amount (claim_amount_id)
)


-- 2025-10-14 16:55:28,964 INFO [no key 0.00090s] ()
-- 2025-10-14 16:55:29,176 INFO 
CREATE TABLE claim_payment (
	claim_payment_id INTEGER NOT NULL, 
	claim_amount_id INTEGER, 
	PRIMARY KEY (claim_payment_id), 
	FOREIGN KEY(claim_amount_id) REFERENCES claim_amount (claim_amount_id)
)


-- 2025-10-14 16:55:29,177 INFO [no key 0.00097s] ()
-- 2025-10-14 16:55:29,499 INFO 
CREATE TABLE recovery (
	recovery_id INTEGER NOT NULL, 
	claim_amount_id INTEGER, 
	PRIMARY KEY (recovery_id), 
	FOREIGN KEY(claim_amount_id) REFERENCES claim_amount (claim_amount_id)
)


-- 2025-10-14 16:55:29,502 INFO [no key 0.00242s] ()
-- 2025-10-14 16:55:29,725 INFO 
CREATE TABLE loss_reserve (
	loss_reserve_id INTEGER NOT NULL, 
	claim_reserve_id INTEGER, 
	PRIMARY KEY (loss_reserve_id), 
	FOREIGN KEY(claim_reserve_id) REFERENCES claim_reserve (claim_reserve_id)
)


-- 2025-10-14 16:55:29,726 INFO [no key 0.00111s] ()
-- 2025-10-14 16:55:29,971 INFO 
CREATE TABLE expense_reserve (
	expense_reserve_id INTEGER NOT NULL, 
	claim_reserve_id INTEGER, 
	PRIMARY KEY (expense_reserve_id), 
	FOREIGN KEY(claim_reserve_id) REFERENCES claim_reserve (claim_reserve_id)
)


-- 2025-10-14 16:55:29,972 INFO [no key 0.00119s] ()
-- 2025-10-14 16:55:30,295 INFO 
CREATE TABLE loss_payment (
	loss_payment_id INTEGER NOT NULL, 
	claim_payment_id INTEGER, 
	PRIMARY KEY (loss_payment_id), 
	FOREIGN KEY(claim_payment_id) REFERENCES claim_payment (claim_payment_id)
)


-- 2025-10-14 16:55:30,297 INFO [no key 0.00243s] ()
-- 2025-10-14 16:55:30,581 INFO 
CREATE TABLE expense_payment (
	expense_payment_id INTEGER NOT NULL, 
	claim_payment_id INTEGER, 
	PRIMARY KEY (expense_payment_id), 
	FOREIGN KEY(claim_payment_id) REFERENCES claim_payment (claim_payment_id)
)


-- 2025-10-14 16:55:30,583 INFO [no key 0.00162s] ()
-- 2025-10-14 16:55:30,805 INFO 
CREATE TABLE loss_recovery (
	loss_recovery_id INTEGER NOT NULL, 
	recovery_id INTEGER, 
	PRIMARY KEY (loss_recovery_id), 
	FOREIGN KEY(recovery_id) REFERENCES recovery (recovery_id)
)


-- 2025-10-14 16:55:30,807 INFO [no key 0.00141s] ()
-- 2025-10-14 16:55:31,054 INFO 
CREATE TABLE salvage (
	salvage_id INTEGER NOT NULL, 
	recovery_id INTEGER, 
	PRIMARY KEY (salvage_id), 
	FOREIGN KEY(recovery_id) REFERENCES recovery (recovery_id)
)


-- 2025-10-14 16:55:31,056 INFO [no key 0.00132s] ()
-- 2025-10-14 16:55:31,297 INFO 
CREATE TABLE reinsurance_recovery (
	reinsurance_recovery_id INTEGER NOT NULL, 
	recovery_id INTEGER, 
	PRIMARY KEY (reinsurance_recovery_id), 
	FOREIGN KEY(recovery_id) REFERENCES recovery (recovery_id)
)


-- 2025-10-14 16:55:31,298 INFO [no key 0.00121s] ()
-- 2025-10-14 16:55:31,505 INFO 
CREATE TABLE expense_recovery (
	expense_recovery_id INTEGER NOT NULL, 
	recovery_id INTEGER, 
	PRIMARY KEY (expense_recovery_id), 
	FOREIGN KEY(recovery_id) REFERENCES recovery (recovery_id)
)


-- 2025-10-14 16:55:31,506 INFO [no key 0.00122s] ()
-- 2025-10-14 16:55:31,714 INFO 
CREATE TABLE deductible_recovery (
	deductible_recovery_id INTEGER NOT NULL, 
	recovery_id INTEGER, 
	PRIMARY KEY (deductible_recovery_id), 
	FOREIGN KEY(recovery_id) REFERENCES recovery (recovery_id)
)


-- 2025-10-14 16:55:31,715 INFO [no key 0.00104s] ()
-- 2025-10-14 16:55:32,067 INFO 
CREATE TABLE subrogation (
	subrogation_id INTEGER NOT NULL, 
	recovery_id INTEGER, 
	PRIMARY KEY (subrogation_id), 
	FOREIGN KEY(recovery_id) REFERENCES recovery (recovery_id)
)


-- 2025-10-14 16:55:32,068 INFO [no key 0.00124s] ()
-- 2025-10-14 16:55:32,281 INFO COMMIT
-- 2025-10-14 16:56:27,930 INFO Python Server ready to receive messages
-- 2025-10-14 16:56:27,930 INFO Received command c on object id p0
