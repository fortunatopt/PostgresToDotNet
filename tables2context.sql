-- FUNCTION: public.tables2context(character varying)

-- DROP FUNCTION public.tables2context(character varying);

CREATE OR REPLACE FUNCTION public.tables2context(
	v_schema_name character varying)
    RETURNS character varying
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE v_cursor_tables record;
DECLARE v_context VARCHAR;
DECLARE v_db_sets VARCHAR;
DECLARE v_entities VARCHAR;
BEGIN
   v_context = E'\r\n\r\n' || '#region SMS Context ' || v_schema_name;
   v_db_sets = E'\r\n';
   v_entities = '';
   
   FOR v_cursor_tables IN
    SELECT table_name FROM information_schema.tables where table_schema = v_schema_name and table_type = 'BASE TABLE'
   LOOP
    v_db_sets := v_db_sets || public.table2db_set(v_schema_name, v_cursor_tables.table_name);
	v_entities := v_entities || public.table2entity(v_schema_name, v_cursor_tables.table_name);
   END LOOP;
   
   v_context := v_context || v_db_sets || E'\r\n';
   
   v_context := v_context || E'\r\n' || '#endregion' || E'\r\n\r\n';   
   
   v_context := v_context || 'protected override void OnModelCreating(ModelBuilder modelBuilder)' ||  E'\r\n' || E'{';
   
   v_context := v_context || v_entities;
   
   v_context := v_context || E'\r\n' || '}' ||  E'\r\n';
      
   
   raise notice 'Value: %', v_context;
  
   return v_context;
END;
$BODY$;

ALTER FUNCTION public.tables2context(character varying)
    OWNER TO postgres;
