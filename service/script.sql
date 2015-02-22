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

select distinct gi.* from nserc_award ns, geocoded_institutions gi where ns."Institution-…tablissement" = gi."original address" AND gi."status code" = '200'

select * from awards limit 10;

DROP VIEW awards;
select * from awards where partner is not null and partner != institution limit 10 

CREATE MATERIALIZED VIEW awards AS
--CREATE VIEW awards AS
    SELECT cle as id,
    'NSERC' as data_type,
    nsa."Name-Nom" as name,
    nsa."FiscalYear-Exercice financier" as fiscal_year,
    nsa."Institution-…tablissement" as institution,
    (select distinct p."PartInstitution-…tablissement" from nserc_partner p where p.partorganizationid = nsa.organizationid) as partner,
    nsa.awardamount as award,
    nsa.applicationtitle as title,
    nsa.applicationsummary as summary,
    nsa.keyword as keywords
    
    FROM nserc_award nsa
    
    UNION ALL 

    SELECT cle as id,
    'SSHRC' as data_type,
    ssa."Name-Nom" as name, 
    ssa."FiscalYear-Exercice financier" as fiscal_year,
    ssa."institution" as institution,
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
--CREATE VIEW institutions AS
    SELECT DISTINCT nsa."Institution-…tablissement" as name,
    'I' as type,
    gi."returned address" as address,
    gi.latitude,
    gi.longitude,
    gi.geom
    FROM nserc_award nsa, geocoded_institutions gi
    where nsa."Institution-…tablissement" = gi."original address" AND gi.accuracy <= 3 AND gi."status code" = '200'
    
    UNION ALL 

    SELECT DISTINCT part."PartInstitution-…tablissement" as name,
    'P' as type,
    gi."returned address" as address,
    gi.latitude,
    gi.longitude,
    gi.geom
    FROM nserc_award nsa, nserc_partner part, geocoded_institutions gi
    where nsa.organizationid = part.partorganizationid AND part."PartInstitution-…tablissement" = gi."original address" AND gi.accuracy <= 3 AND gi."status code" = '200'

    UNION ALL
    
    SELECT ssa."Name-Nom" as name,
    'I' as type,
    gi."returned address" as address,
    gi.latitude,
    gi.longitude,
    gi.geom
    FROM sshrc_award ssa, geocoded_institutions gi
    where ssa."institution" = gi."original address" AND gi.accuracy <= 3 AND gi."status code" = '200'
    
WITH DATA;


select count(*) from institutions where geom is not null 


select * from awards limit 100





