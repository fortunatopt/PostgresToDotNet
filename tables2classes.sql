-- FUNCTION: public.tables2classes(character varying)

-- DROP FUNCTION public.tables2classes(character varying);

CREATE OR REPLACE FUNCTION public.tables2classes(
	v_schema_name character varying)
    RETURNS character varying
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$

DECLARE v_cursor_tables record;
DECLARE v_classes VARCHAR;
BEGIN
   v_classes := E'\r\n\r\n' || '// Generated classes for the ' || v_schema_name || E' schema\r\n';
   FOR v_cursor_tables IN
    SELECT table_name FROM information_schema.tables where table_schema = v_schema_name and table_type = 'BASE TABLE'
   LOOP
   v_classes := v_classes || public.table2class(v_schema_name, v_cursor_tables.table_name) || E'\r\n\r\n';
   END LOOP;
   
   raise notice 'Value: %', v_classes;
  
   return v_classes;
END;
$BODY$;

ALTER FUNCTION public.tables2classes(character varying)
    OWNER TO postgres;
