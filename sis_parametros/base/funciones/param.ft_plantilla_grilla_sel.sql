--------------- SQL ---------------

CREATE OR REPLACE FUNCTION param.ft_plantilla_grilla_sel (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Parametros Generales
 FUNCION: 		param.ft_plantilla_grilla_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'param.tplantilla_grilla'
 AUTOR: 		 (egutierrez)
 FECHA:	        17-06-2019 21:25:26
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:
#ISSUE				FECHA				    AUTOR				DESCRIPCION
 #24				17-06-2019 21:25:26		EGS					Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'param.tplantilla_grilla'	
 #
 ***************************************************************************/

DECLARE

	v_consulta    		varchar;
	v_parametros  		record;
	v_nombre_funcion   	text;
	v_resp				varchar;
			    
BEGIN

	v_nombre_funcion = 'param.ft_plantilla_grilla_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'PM_PLGRI_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		egutierrez	
 	#FECHA:		17-06-2019 21:25:26
	***********************************/

	if(p_transaccion='PM_PLGRI_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						plgri.id_plantilla_grilla,
						plgri.estado_reg,
						plgri.codigo,
						plgri.configuracion,
						plgri.nombre,
						plgri.url_interface,
						plgri.id_usuario_reg,
						plgri.fecha_reg,
						plgri.id_usuario_ai,
						plgri.usuario_ai,
						plgri.id_usuario_mod,
						plgri.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
                        plgri.nombre||'' (''||usu1.cuenta||'')'' as desc_plantilla_grilla	
						from param.tplantilla_grilla plgri
						inner join segu.tusuario usu1 on usu1.id_usuario = plgri.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = plgri.id_usuario_mod
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'PM_PLGRI_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		egutierrez	
 	#FECHA:		17-06-2019 21:25:26
	***********************************/

	elsif(p_transaccion='PM_PLGRI_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_plantilla_grilla)
					    from param.tplantilla_grilla plgri
					    inner join segu.tusuario usu1 on usu1.id_usuario = plgri.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = plgri.id_usuario_mod
					    where ';
			
			--Definicion de la respuesta		    
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
			return v_consulta;

		end;
					
	else
					     
		raise exception 'Transaccion inexistente';
					         
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