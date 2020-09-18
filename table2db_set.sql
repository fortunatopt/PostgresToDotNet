-- FUNCTION: public.table2db_set(character varying, character varying)

-- DROP FUNCTION public.table2db_set(character varying, character varying);

CREATE OR REPLACE FUNCTION public.table2db_set(
	v_schema_name character varying,
	v_table character varying)
    RETURNS character varying
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE v_cursor_columns record;
DECLARE v_cursor_top_columns record;
DECLARE v_column_name VARCHAR;
DECLARE v_column_name_pascal VARCHAR;
DECLARE v_class VARCHAR;
DECLARE v_type VARCHAR;
BEGIN
  select table_name INTO v_table from information_schema.tables where table_schema = v_schema_name
  and table_type = 'BASE TABLE'
  and table_name = v_table;
   v_class := E'\r\n';
   --public DbSet<TermUsageActive> TermUsageActive { get; set; }
   v_class := v_class || 'public DbSet<' || replace(initcap(replace(v_table, '_', ' ')), ' ', '') || '> ' || replace(initcap(replace(v_table, '_', ' ')), ' ', '') ||   E' { get; set; }';
      
   return v_class;
   
   RAISE NOTICE '%' , v_class;
  END;
$BODY$;

ALTER FUNCTION public.table2db_set(character varying, character varying)
    OWNER TO postgres;
