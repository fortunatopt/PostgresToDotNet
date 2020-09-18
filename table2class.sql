-- FUNCTION: public.table2class(character varying, character varying)

-- DROP FUNCTION public.table2class(character varying, character varying);

CREATE OR REPLACE FUNCTION public.table2class(
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
   v_class := E'\r\n' || '/// <summary>';
   v_class := v_class || E'\r\n' || '/// Class for table '|| v_table;
   v_class := v_class || E'\r\n' || '/// <summary>';
   v_class := v_class || E'\r\n' || '[Table("' || v_table || '", Schema = "' || v_schema_name ||  '")]' || E'\r\n';
   v_class := v_class || 'public class ' || replace(initcap(replace(v_table, '_', ' ')), ' ', '') || ' {' ||  E'\r\n';
   FOR v_cursor_columns IN
    SELECT column_name as column, is_nullable as isnull, data_type as type, character_maximum_length as size
    FROM information_schema.columns
    WHERE table_schema = v_schema_name
    AND table_name   = v_table
   LOOP
      --typeS
    IF    v_cursor_columns.type='character varying' THEN v_type:= 'string';
    ELSIF v_cursor_columns.type='character' and v_cursor_columns.size=1 THEN v_type:= 'char';
    ELSIF v_cursor_columns.type='character' and v_cursor_columns.size<>1 THEN v_type:= 'string';
    ELSIF v_cursor_columns.type='timestamp with time zone' THEN v_type:= 'DateTime';
    ELSIF v_cursor_columns.type='timestamp without time zone' THEN v_type:= 'DateTime';
        
    ELSIF v_cursor_columns.type='int8'        THEN v_type:= 'Int64';
    ELSIF v_cursor_columns.type='bigint'      THEN v_type:= 'long';
    ELSIF v_cursor_columns.type='bool'        THEN v_type:= 'Boolean';
    ELSIF v_cursor_columns.type='boolean'	  THEN v_type:= 'Boolean';
    ELSIF v_cursor_columns.type='bytea'       THEN v_type:= 'Byte[]';
    ELSIF v_cursor_columns.type='date'        THEN v_type:= 'DateTime';
    ELSIF v_cursor_columns.type='float8'      THEN v_type:= 'Double';
    ELSIF v_cursor_columns.type='int4'        THEN v_type:= 'Int32';
    ELSIF v_cursor_columns.type='integer'     THEN v_type:= 'int';
    ELSIF v_cursor_columns.type='smallint'    THEN v_type:= 'short';
    ELSIF v_cursor_columns.type='money'       THEN v_type:= 'Decimal';
    ELSIF v_cursor_columns.type='numeric'     THEN v_type:= 'Decimal';
    ELSIF v_cursor_columns.type='float4'      THEN v_type:= 'Single';
    ELSIF v_cursor_columns.type='int2'        THEN v_type:= 'Int16';
    ELSIF v_cursor_columns.type='text'        THEN v_type:= 'String';
    ELSIF v_cursor_columns.type='time'        THEN v_type:= 'DateTime';
    ELSIF v_cursor_columns.type='timetz'      THEN v_type:= 'DateTime';
    ELSIF v_cursor_columns.type='timestamp'   THEN v_type:= 'DateTime';
    ELSIF v_cursor_columns.type='timestamptz' THEN v_type:= 'DateTime';
    ELSIF v_cursor_columns.type='interval'    THEN v_type:= 'TimeSpan';
    ELSIF v_cursor_columns.type='varchar'     THEN v_type:= 'String';
    ELSIF v_cursor_columns.type='inet'        THEN v_type:= 'IPAddress';
    ELSIF v_cursor_columns.type='bit'         THEN v_type:= 'Boolean';
    ELSIF v_cursor_columns.type='uuid'        THEN v_type:= 'Guid';
    ELSIF v_cursor_columns.type='array'       THEN v_type:= 'Array';
    ELSE v_type:= 'ORIG: ' || v_cursor_columns.type;
    END IF;
      
    --ATRIBUTES
    v_column_name := v_cursor_columns.column;
	IF position('_' in v_cursor_columns.column) = 1 THEN
		v_column_name_pascal :=  '_' || replace(initcap(replace(ltrim(v_cursor_columns.column, '_'), '_', ' ')), ' ', '');
	ELSE
		v_column_name_pascal := replace(initcap(replace(v_cursor_columns.column, '_', ' ')), ' ', '');
	END IF;
    --PROPERTIES
    --v_class := v_class || v_cursor_columns.isnull || E'\r\n';
	v_class := v_class || '    [Column("' || v_cursor_columns.column || '")]' || E'\r\n';
    v_class := v_class || '    public ';
    IF v_cursor_columns.isnull = 'YES' THEN
        v_class := v_class || 'Nullable<' || v_type || '>';
    ELSE
        v_class := v_class || v_type;
    END IF;
    v_class := v_class || ' ' || v_column_name_pascal || ' { get; set; }' || E'\r\n';
      
   END LOOP;
   v_class := v_class || '}';
   
   return v_class;
   
   RAISE NOTICE '%' , v_class;
  END;
$BODY$;

ALTER FUNCTION public.table2class(character varying, character varying)
    OWNER TO postgres;
