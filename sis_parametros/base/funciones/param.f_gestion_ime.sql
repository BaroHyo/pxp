--------------- SQL ---------------

CREATE OR REPLACE FUNCTION param.f_gestion_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Parametros Generales
 FUNCION: 		param.f_gestion_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'param.tgestion'
 AUTOR: 		 (admin)
 FECHA:	        05-02-2013 09:56:59
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:	
 AUTOR:			
 FECHA:		
***************************************************************************/

DECLARE

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_gestion	integer;
    
    v_fecha_ini date;
    v_fecha_fin date;
    v_cont integer;
    v_anho integer;
			    
BEGIN

    v_nombre_funcion = 'param.f_gestion_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'PM_GES_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		05-02-2013 09:56:59
	***********************************/

	if(p_transaccion='PM_GES_INS')then
    
           begin
            --vallida que la gestion dea unica
            
            IF exists(select 1 from param.tgestion where gestion = v_parametros.gestion) THEN
            
              raise exception 'La gestion ya existe';
              
            END IF;
           
           
        	--Sentencia de la insercion
        	insert into param.tgestion(
			id_moneda_base,
			id_empresa,
			estado_reg,
			estado,
			gestion,
			fecha_reg,
			id_usuario_reg,
			id_usuario_mod,
			fecha_mod
          	) values(
			v_parametros.id_moneda_base,
			v_parametros.id_empresa,
			'activo',
			v_parametros.estado,
			v_parametros.gestion,
			now(),
			p_id_usuario,
			null,
			null
							
			)RETURNING id_gestion into v_id_gestion;
            
            --inserta en la tabla periodo
            
            v_cont =1;
            
            WHILE v_cont <= 12 LOOP
            
             -- obtiene primer del mes correspondiente a la fecha_ini
                        
             v_fecha_ini= ('01-'||v_cont||'-'||v_parametros.gestion)::date;
             -- obtiene el ultimo dia del mes correspondiente a la fecha_fin
           
             v_fecha_fin=(date_trunc('MONTH', v_fecha_ini) + INTERVAL '1 MONTH - 1 day')::date;
             
             INSERT INTO 
                          param.tperiodo
                        (
                          id_usuario_reg,
                          id_usuario_mod,
                          fecha_reg,
                          fecha_mod,
                          estado_reg,
                        
                          periodo,
                          id_gestion,
                          fecha_ini,
                          fecha_fin
                        ) 
                        VALUES (
                          p_id_usuario,
                          NULL,
                          now(),
                          NULL,
                          'activo',
                          v_cont,
                          v_id_gestion,
                          v_fecha_ini,
                          v_fecha_fin
                        );
            
               v_cont=v_cont+1;
            
            END LOOP;
            
            
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Gestion almacenado(a) con exito (id_gestion'||v_id_gestion||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_gestion',v_id_gestion::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'PM_GES_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		05-02-2013 09:56:59
	***********************************/

	elsif(p_transaccion='PM_GES_MOD')then

		begin
			--Sentencia de la modificacion
			update param.tgestion set
			id_moneda_base = v_parametros.id_moneda_base,
			id_empresa = v_parametros.id_empresa,
			estado = v_parametros.estado,
			gestion = v_parametros.gestion,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now()
			where id_gestion=v_parametros.id_gestion;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Gestion modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_gestion',v_parametros.id_gestion::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'PM_GES_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		05-02-2013 09:56:59
	***********************************/

	elsif(p_transaccion='PM_GES_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from param.tgestion
            where id_gestion=v_parametros.id_gestion;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Gestion eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_gestion',v_parametros.id_gestion::varchar);
              
            --Devuelve la respuesta
            return v_resp;

		end;
        
        
        
        /*********************************    
 	#TRANSACCION:  'PM_GETGES_ELI'
 	#DESCRIPCION:	Recuepra el id_gestion segun la fecha
 	#AUTOR:		admin	
 	#FECHA:		05-02-2013 09:56:59
	***********************************/

	elsif(p_transaccion='PM_GETGES_ELI')then

		begin
            --todavia no se considera la existencia de multiples empresas
        
            v_anho = (date_part('year', v_parametros.fecha))::integer;
			
            select 
             ges.id_gestion
             into v_id_gestion
            from param.tgestion ges
            where ges.gestion = v_anho
            limit 1 offset 0;
            
            IF v_id_gestion is null THEN
            
              raise exception 'No se tiene una gestion configurada para la fecha %',v_parametros.fecha; 
            
            END IF;
       
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','id_gestion recuperado'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_gestion',v_id_gestion::varchar);
           
              
            --Devuelve la respuesta
            return v_resp;

		end;
        
         
	else
     
    	raise exception 'Transaccion inexistente: %',p_transaccion;

	end if;

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