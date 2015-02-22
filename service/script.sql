CREATE TABLE nserc_award (
    Cle numeric,
    "Name-Nom" varchar,
    "Department-DÈpartement" varchar,
    OrganizationID numeric,
    "Institution-…tablissement" varchar,
    ProvinceEN varchar,
    ProvinceFR varchar,
    CountryEN varchar,
    CountryFR varchar,
    "FiscalYear-Exercice financier" numeric,
    "CompetitionYear-AnnÈe de concours" numeric,
    AwardAmount numeric,
    ProgramID varchar,
    ProgramNaneEN varchar,
    ProgramNameFR varchar,
    GroupEN varchar,
    GroupFR varchar,
    CommitteeCode varchar,
    CommitteeNameEN varchar,
    CommitteeNameFR varchar,
    AreaOfApplicationCode varchar,
    AreaOfApplicationGroupEN varchar,
    AreaOfApplicationGroupFR varchar,
    AreaOfApplicationEN varchar,
    AreaOfApplicationFR varchar,
    ResearchSubjectCode varchar,
    ResearchSubjectGroupEN varchar,
    ResearchSubjectGroupFR varchar,
    ResearchSubjectEN varchar,
    ResearchSubjectFR varchar,
    installment varchar,
    Partie varchar,
    Nb_Partie varchar,
    ApplicationTitle varchar,
    Keyword varchar,
    ApplicationSummary varchar)

    CREATE INDEX nserc_award_adr_idx ON nserc_award("Institution-…tablissement");

    COPY nserc_award FROM '/home/user/NSERC_GRT_FYR2012_AWARD.csv' DELIMITERS ',' CSV HEADER encoding 'LATIN1';

    select * from nserc_award

CREATE TABLE nserc_co_applicant (
    Cle numeric,
    "CoApplicantName-NomCoApplicant" varchar,
    CoAppOrganizationID numeric,
    "CoAppInstitution-…tablissement" varchar,
    ProvinceEN varchar,
    ProvinceFR varchar,
    CountryEN varchar,
    CountryFR varchar,
    "FiscalYear-Exercice financier" numeric);
    
CREATE INDEX nserc_co_applicant_adr_idx ON nserc_co_applicant("CoAppInstitution-…tablissement");

    COPY nserc_co_applicant FROM '/home/user/NSERC_GRT_FYR2012_CO_APPLICATION.csv' DELIMITERS ',' CSV HEADER encoding 'LATIN1';

CREATE TABLE nserc_partner (
    Cle numeric,
    PartOrganizationID numeric,
    "PartInstitution-…tablissement" varchar,
    ProvinceEN varchar,
    ProvinceFR varchar,
    CountryEN varchar,
    CountryFR varchar,
    "FiscalYear-Exercice financier" numeric);

CREATE INDEX nserc_partner_adr_idx ON nserc_partner("PartInstitution-…tablissement");

    COPY nserc_partner FROM '/home/user/NSERC_GRT_FYR2012_PARTNER.csv' DELIMITERS ',' CSV HEADER encoding 'LATIN1';


    CREATE TABLE sshrc_award (
    cle numeric,
    "Name-Nom" varchar,
    role varchar,
    AwardAmount numeric,
    "FiscalYear-Exercice financier" numeric,
    Institution varchar,
    …tablissement varchar,
    Province_ID varchar,
    ProvinceEN varchar,
    ProvinceFR varchar,
    Competition_Year numeric,
    Title varchar,
    Keywords varchar,
    ProgramNameEN varchar,
    ProgramNameFR varchar,
    DisciplineEN varchar,
    DisciplineFR varchar,
    MainDisciplineEN varchar,
    MainDisciplineFR varchar,
    Area_of_ResearchEN varchar,
    Area_of_ResearchFR varchar);

CREATE INDEX sshrc_award_adr_idx ON sshrc_award(…tablissement);
    
  COPY sshrc_award FROM '/home/user/SSHRC_FYR2012_AWARD.csv' DELIMITERS ',' CSV HEADER encoding 'LATIN1';
select distinct ns."Institution-…tablissement" from nserc_award ns


select distinct ns."Institution-…tablissement" from nserc_award ns, cartodb_query c where ns."Institution-…tablissement" = c.university
--select DropGeometryColumn('public','geocoded_institutions','geom');

 CREATE TABLE geocoded_institutions (
    "original address" varchar,
    "returned address" varchar,
    latitude numeric,
    longitude numeric,
    accuracy numeric,
    "status code" varchar);
    
CREATE INDEX geocoded_institutions_adr_idx ON geocoded_institutions("original address");

  COPY geocoded_institutions FROM '/home/user/nserc_geocoded_institutions.csv' DELIMITERS ',' CSV HEADER 
  --encoding 'LATIN1';


  select distinct "…tablissement" from sshrc_award

  
  COPY geocoded_institutions FROM '/home/user/sshrc_geocoded_institutions.csv' DELIMITERS ',' CSV HEADER encoding 'LATIN1';
	--select count(*) from geocoded_institutions
  
  select distinct CONCAT("PartInstitution-…tablissement",',',provinceen,',',countryen) from nserc_partner where provinceen is null

  COPY geocoded_institutions FROM '/home/user/partner_geocoded_institutions.csv' DELIMITERS ',' CSV HEADER encoding 'LATIN1';


SELECT AddGeometryColumn ('public','geocoded_institutions','geom',4326,'POINT',2);
UPDATE geocoded_institutions SET geom=ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);

DROP MATERIALIZED VIEW awards;

CREATE MATERIALIZED VIEW awards AS
    SELECT cle as id,
    'NSERC' as data_type,
    'APPLICANT' as type,
    nsa."Name-Nom" as name,
    nsa."FiscalYear-Exercice financier" as fiscal_year,
    nsa."Institution-…tablissement" as institution,
    (select ST_AsGeoJSON(gi.geom)::varchar from geocoded_institutions gi where gi."original address" = nsa."Institution-…tablissement") as geo,
    (select gi."returned address" from geocoded_institutions gi where gi."original address" = nsa."Institution-…tablissement") as address,
    (select distinct p."PartInstitution-…tablissement" from nserc_partner p where p.partorganizationid = nsa.organizationid) as partner,
    nsa.awardamount as award,
    nsa.applicationtitle as title,
    nsa.applicationsummary as summary,
    nsa.keyword as keywords
    
    FROM nserc_award nsa

    UNION 

    SELECT DISTINCT co.cle as id,
    'NSERC' as data_type,
    'CO-APPLICANT' as type,
    co."CoApplicantName-NomCoApplicant" as name,
    co."FiscalYear-Exercice financier" as fiscal_year,
    co."CoAppInstitution-…tablissement" as institution,
    (select ST_AsGeoJSON(gi.geom)::varchar from geocoded_institutions gi where gi."original address" = co."CoAppInstitution-…tablissement") as geo,
    (select gi."returned address" from geocoded_institutions gi where gi."original address" = co."CoAppInstitution-…tablissement") as address,
    NULL as partner,
    nsa.awardamount as award,
    nsa.applicationtitle as title,
    nsa.applicationsummary as summary,
    nsa.keyword as keywords
    
    FROM nserc_award nsa, nserc_co_applicant co WHERE co.cle = nsa.cle
    
    UNION 

    SELECT cle as id,
    'SSHRC' as data_type,
    'APPLICANT' as type,
    ssa."Name-Nom" as name, 
    ssa."FiscalYear-Exercice financier" as fiscal_year,
    ssa."institution" as institution,
    (select ST_AsGeoJSON(gi.geom)::varchar from geocoded_institutions gi where gi."original address" = ssa."institution") as geo,
    (select gi."returned address" from geocoded_institutions gi where gi."original address" = ssa."institution") as address,
    NULL as partner,
    ssa.awardamount as award,
    ssa.title as title,
    'No summary available.' as summary,
    CONCAT(ssa.keywords, ' ', programnameen, ' ', 
    programnamefr, ' ', disciplineen, ' ', disciplinefr, ' ', 
    maindisciplineen , ' ', maindisciplinefr , ' ', 
    area_of_researchen , ' ', area_of_researchfr) as keywords

    FROM sshrc_award ssa
    
WITH DATA;

DROP VIEW institutions;

CREATE MATERIALIZED VIEW institutions AS
    SELECT DISTINCT nsa."Institution-…tablissement" as name,
    'I' as type,
    gi."returned address" as address,
    gi.latitude,
    gi.longitude,
    gi.geom
    FROM nserc_award nsa, geocoded_institutions gi
    where nsa."Institution-…tablissement" = gi."original address" AND gi.accuracy <= 3 AND gi."status code" = '200'
    
    UNION 

    SELECT DISTINCT part."PartInstitution-…tablissement" as name,
    'P' as type,
    gi."returned address" as address,
    gi.latitude,
    gi.longitude,
    gi.geom
    FROM nserc_award nsa, nserc_partner part, geocoded_institutions gi
    where nsa.organizationid = part.partorganizationid AND part."PartInstitution-…tablissement" = gi."original address" AND gi.accuracy <= 3 AND gi."status code" = '200'

    UNION
    
    SELECT ssa."Name-Nom" as name,
    'I' as type,
    gi."returned address" as address,
    gi.latitude,
    gi.longitude,
    gi.geom
    FROM sshrc_award ssa, geocoded_institutions gi
    where ssa."institution" = gi."original address" AND gi.accuracy <= 3 AND gi."status code" = '200'
    
WITH DATA;


DROP MATERIALIZED VIEW associations;

CREATE MATERIALIZED VIEW associations AS
	select a.id,
	(select "original address" from geocoded_institutions where "original address" = a.institution) as app_institution,
	(select ST_AsGeoJSON(geom)::varchar from geocoded_institutions where "original address" = a.institution) as app_geo,
	(select "original address" from geocoded_institutions where "original address" = co."CoAppInstitution-…tablissement") as coapp_institution,
	(select ST_AsGeoJSON(geom)::varchar from geocoded_institutions where "original address" = co."CoAppInstitution-…tablissement") as coapp_geo,
	ST_AsGeoJSON(ST_MakeLine(ARRAY[(select geom from geocoded_institutions where "original address" = a.institution), 
	(select geom from geocoded_institutions where "original address" = co."CoAppInstitution-…tablissement")]))::varchar as association_geo,
	a.keywords,
	a.title,
	a.summary,
	a.fiscal_year
	from awards a LEFT JOIN nserc_co_applicant co ON (co.cle = a.id) WHERE a.type != 'CO-APPLICANT' AND co.cle is not null AND a.institution != co."CoAppInstitution-…tablissement"

WITH DATA;

--Fix for '%Université de montréal%'
update geocoded_institutions set accuracy=1, "returned address"='Université de montréal, Chemin de la Rampe, Côte-des-Neiges, Montreal city, Montreal (06), Quebec, H3T 1J4, Canada',geom = ST_SetSRID(ST_MakePoint(-73.6145404514471, 45.50406785), 4326), latitude = 45.50406785, longitude = -73.6145404514471, "status code" = 200 where "original address" = 'Université de Montréal'
