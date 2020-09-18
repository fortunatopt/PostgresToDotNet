-- FUNCTION: public.table2entity(character varying, character varying)

-- DROP FUNCTION public.table2entity(character varying, character varying);

CREATE OR REPLACE FUNCTION public.table2entity(
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
DECLARE v_entity VARCHAR;
DECLARE v_type VARCHAR;
BEGIN
	v_entity = E'\r\n' || '    modelBuilder.Entity<' || replace(initcap(replace(v_table, '_', ' ')), ' ', '') || '>().HasKey(k => new { ';

	FOR v_cursor_columns IN
	SELECT kcu.table_schema, kcu.table_name, tco.constraint_name, kcu.ordinal_position AS position, kcu.column_name as key_column
	FROM information_schema.table_constraints tco
	JOIN information_schema.key_column_usage kcu
     ON kcu.constraint_name = tco.constraint_name
     AND kcu.constraint_schema = tco.constraint_schema
     AND kcu.constraint_name = tco.constraint_name
	WHERE tco.constraint_type = 'PRIMARY KEY'
	 AND kcu.table_schema = v_schema_name
	 AND kcu.table_name = v_table
	ORDER BY position
   
   LOOP
	v_column_name := v_cursor_columns.key_column;

	IF position('_' in v_cursor_columns.key_column) = 1 THEN
		v_column_name_pascal :=  '_' || replace(initcap(replace(ltrim(v_cursor_columns.key_column, '_'), '_', ' ')), ' ', '');
	ELSE
		v_column_name_pascal := replace(initcap(replace(v_cursor_columns.key_column, '_', ' ')), ' ', '');
	END IF;
	
	v_entity := v_entity || 'k.' || v_column_name_pascal || ', ';    
      
   END LOOP;

	v_entity = LEFT(v_entity, LENGTH(v_entity) - 2);
	v_entity := v_entity || ' });';
   
   --RAISE NOTICE '%' , v_entity;
   
   return v_entity;
  END;
$BODY$;

ALTER FUNCTION public.table2entity(character varying, character varying)
    OWNER TO postgres;
