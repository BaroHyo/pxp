--------------- SQL ---------------

CREATE OR REPLACE FUNCTION wf.f_evaluar_regla_wf (
  f_regla text,
  p_id_estado_wf integer
)
RETURNS boolean AS
$body$
/*
Autor:  Rensi Arteaga Copari  KPLIAN
Fecha 04/06/2014
Descripcion:  procesa la regla de la arista regresa como resultado FALSE or TRUE


*/

DECLARE

v_tmp_plantilla      text;
v_prefijo            varchar;
v_columna            varchar;
v_columnas_consulta  varchar;
v_columna_nueva      varchar[];
v_registros			 record;



v_TIPO_PROCESO		 varchar;
v_NUM_TRAMITE		 varchar;
v_USUARIO_PREVIO	 varchar;	
v_ESTADO_ANTERIOR	 varchar;
v_OBS				 varchar;
v_CODIGO			 varchar;
v_ESTADO_ACTUAL 	 varchar;
v_FUNCIONARIO_PREVIO  varchar;
v_DEPTO_PREVIO  	 varchar;
v_PROCESO_MACRO      varchar;

v_sw_busqueda  boolean;
v_tabla					record;
v_tabla_hstore          hstore;
v_nombre_funcion  varchar;
v_resp  varchar;
v_i     integer;

v_template_evaluado    varchar;
 
BEGIN
   
  /*
                   DICIONARIO
  
  
  PROCESO_MACRO
  TIPO_PROCESO
  NUM_TRAMITE
  USUARIO_PREVIO
  ESTADO_ANTERIOR
  OBS
  ESTADO_ACTUAL
  CODIGO
  FUNCIONARIO_PREVIO
  DEPTO_PREVIO 
  
 
  
  
  
  */             
                v_prefijo = 'tabla';
                v_tmp_plantilla = p_plantilla;
                v_template_evaluado = p_plantilla;
                v_nombre_funcion = 'wf.f_evaluar_regla_wf';
                
                -- raise exception '--b   %',v_tmp_plantilla;
                
                --obtenemos datos basicos
                
                 select 
                    tpw.codigo,
                    tpw.nombre,
                    tpw.descripcion,
                    tpw.tabla,
                    pw.nro_tramite,
                    pm.nombre as nombre_proceso_macro
                  into
                    v_registros
                  from  wf.tproceso_wf pw 
                  inner join wf.ttipo_proceso tpw  on tpw.id_tipo_proceso = pw.id_tipo_proceso 
                  inner join wf.tproceso_macro pm  on pm.id_proceso_macro = tpw.id_proceso_macro
                  where pw.id_proceso_wf = p_id_proceso_wf;
  
  
         		 ------------------------------------------------------------------------
                 --  RECUPERAMOS LOS NOMBRES DE LAS PALABRAS CLAVE DE LA PLANTILLA QUE
                 --  HACEN REFERENCIA A LA TABLA DE TIPO PROCESO
                 -------------------------------------------------------------------------
                 
                 IF  v_registros.tabla != '' and v_registros.tabla is not null THEN
                      LOOP
                            --resetemaos el sw de busquedas
                            v_sw_busqueda = FALSE; 
                            
                            
                             -- buscar palabras clave en la plantilla
            
                            v_columna  =  substring(v_tmp_plantilla from '%#"#{$'||v_prefijo||'.%#}#"%' for '#'); 
                            
                            --limpia la cadena original para no repetir la bsuqueda
                            v_tmp_plantilla = replace( v_tmp_plantilla, v_columna, '----');
                           
                            --deja solo el nombre de la variable
                            v_columna= split_part(v_columna,'{$'||v_prefijo||'.',2);
                            v_columna= split_part( v_columna,'}',1);
                            
                            
                            IF(v_columna != '' and v_columna is not null )  THEN
                               v_columna_nueva = array_append(v_columna_nueva,v_columna);
                               --marcamos la bancera para seguir buscando
                               v_sw_busqueda = TRUE;	
                               
                            END IF;
                            
                            
                            --si no se agrego nada mas tenemos la busqueda
                            IF not v_sw_busqueda THEN
                           
                                exit;
                           
                           END IF;

                      END LOOP;
                      
                  END IF;
                  
                
                  -----------------------------------------
                  --  Evaluar diccionario
                  -----------------------------------------
                  
                  /*
                  
                  PROCESO_MACRO
                  TIPO_PROCESO
                  NUM_TRAMITE
                  USUARIO_PREVIO
                  ESTADO_ANTERIOR
                  OBS
                  ESTADO_ACTUAL
                  CODIGO
                  FUNCIONARIO_PREVIO
                  DEPTO_PREVIO
                  
                  */
                  
                  v_OBS				= p_obs ;
                  v_PROCESO_MACRO   = v_registros.nombre_proceso_macro;
                  v_TIPO_PROCESO    = v_registros.nombre;
                  v_NUM_TRAMITE     = v_registros.nro_tramite;
                  
                  -- p_id_estado_anterior
                  
                  select 
                    tew.nombre_estado,
                    f.desc_funcionario1,
                    d.nombre
                  into
                    v_ESTADO_ANTERIOR,
                    v_FUNCIONARIO_PREVIO,
                    v_DEPTO_PREVIO
                  from  wf.testado_wf ew
                  inner join wf.ttipo_estado  tew on tew.id_tipo_estado = ew.id_tipo_estado
                  left join orga.vfuncionario f on f.id_funcionario = ew.id_funcionario
                  left join param.tdepto      d on d.id_depto = ew.id_depto
                  where ew.id_estado_wf = p_id_estado_anterior;
                  
                  
                  select 
                  te.nombre_estado
                  into
                  v_ESTADO_ACTUAL
                  from wf.ttipo_estado te
                  where te.id_tipo_estado = p_id_tipo_estado_actual;
                  
                  
                  
                  -- obtener usuario
                  
                  select 
                    u.desc_persona
                  into
                    v_USUARIO_PREVIO
                  
                  from
                  segu.vusuario u where u.id_usuario = p_id_usuario;
                  
                 ----------------------------------------------------------------------------
                 --  Obtener valores de las palabras clave que hacen referencia a latabla
                 ---------------------------------------------------------------------------
                 
                  v_columnas_consulta=v_columna_nueva::varchar;
                  v_columnas_consulta=replace(v_columnas_consulta,'{','');
                  v_columnas_consulta=replace(v_columnas_consulta,'}','');
                 
                 --  solo si existe tabla de referencia
                IF  v_registros.tabla != '' and v_registros.tabla is not null and v_columnas_consulta != '' and v_columnas_consulta is not null THEN
                      
                      execute  'select '||v_columnas_consulta ||
                                 ' from '||v_registros.tabla|| ' where '
                                ||v_registros.tabla||'.id_proceso_wf='|| p_id_proceso_wf ||'' into v_tabla;
                                
                    
                     
                     
                       --------------------------------------------------
                       --  REMPLAZAR valores obtenidos en la plantilla
                       --------------------------------------------------
                       v_i = 1;
                       v_tabla_hstore =  hstore(v_tabla);
                       
                       
                       
                       --subsituye los nombre de variable encontradas en la plantilla por los valores obtenidos de la tabla
                       WHILE (v_i <= array_length(v_columna_nueva, 1)) LOOP
                       
                            --sin espacios
                            v_template_evaluado = replace(v_template_evaluado, '{$tabla.'||v_columna_nueva[v_i]||'}',( v_tabla_hstore->v_columna_nueva[v_i])::varchar);
                            v_i = v_i +1;
                      
                       END LOOP;
                       
                END IF; 
                 
              --------------------------------------------------
              --  REMPLAZAR valores del dicionario
              --------------------------------------------------
             
              
              
             
              v_template_evaluado = replace(v_template_evaluado, '{TIPO_PROCESO}',COALESCE(v_TIPO_PROCESO,''));
              v_template_evaluado = replace(v_template_evaluado, '{NUM_TRAMITE}',COALESCE(v_NUM_TRAMITE,''));
              v_template_evaluado = replace(v_template_evaluado, '{USUARIO_PREVIO}',COALESCE(v_USUARIO_PREVIO,''));
              v_template_evaluado = replace(v_template_evaluado, '{ESTADO_ANTERIOR}',COALESCE(v_ESTADO_ANTERIOR,''));
              v_template_evaluado = replace(v_template_evaluado, '{OBS}',v_OBS);
              v_template_evaluado = replace(v_template_evaluado, '{FUNCIONARIO_PREVIO}', COALESCE(v_FUNCIONARIO_PREVIO,''));
              v_template_evaluado = replace(v_template_evaluado, '{DEPTO_PREVIO}',COALESCE(v_DEPTO_PREVIO,''));
              v_template_evaluado = replace(v_template_evaluado, '{PROCESO_MACRO}',COALESCE(v_PROCESO_MACRO,''));
              v_template_evaluado = replace(v_template_evaluado, '{ESTADO_ACTUAL}',COALESCE(v_ESTADO_ACTUAL,''));
              
              
              
              return  v_template_evaluado;
           
           
           
EXCEPTION
WHEN OTHERS THEN
			v_resp='';
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
			v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
			v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
			raise exception '%',v_resp;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;