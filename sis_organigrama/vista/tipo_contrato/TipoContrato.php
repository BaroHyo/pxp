<?php
/**
*@package pXP
*@file gen-TipoContrato.php
*@author  (admin)
*@date 14-01-2014 19:23:02
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema

  ISSUE              FECHA:	        AUTOR:           DESCRIPCION:	
 #18                23/05/2019      EGS              se agrego el campo considerar_planilla 
 #15				19/06/2019		MZM				 Adicion de campo indefinido
 * */

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.TipoContrato=Ext.extend(Phx.gridInterfaz,{

	constructor:function(config){
		this.maestro=config.maestro;
    	//llama al constructor de la clase padre
		Phx.vista.TipoContrato.superclass.constructor.call(this,config);
		this.init();
		this.load({params:{start:0, limit:this.tam_pag}})
	},
			
	Atributos:[
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_tipo_contrato'
			},
			type:'Field',
			form:true 
		},
		{
			config:{
				name: 'codigo',
				fieldLabel: 'Código',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				maxLength:20
			},
				type:'TextField',
				filters:{pfiltro:'tipcon.codigo',type:'string'},
				id_grupo:1,
				grid:true,
				form:true
		},
		{
			config:{
				name: 'nombre',
				fieldLabel: 'Nombre',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				maxLength:200
			},
				type:'TextField',
				filters:{pfiltro:'tipcon.nombre',type:'string'},
				id_grupo:1,
				grid:true,
				form:true
		},
		{	//#18
                config:{
                       name:'considerar_planilla',
                       fieldLabel:'Considera Planilla',
                       allowBlank:false,
                       emptyText:'...',
                       typeAhead: true,
                       triggerAction: 'all',
                       lazyRender:true,
                       mode: 'local',                       
                       gwidth: 100,
                       store:new Ext.data.ArrayStore({
                    fields: ['ID', 'valor'],
                    data :    [['no','no'],    
                            ['si','si']]
                                
                    }),
                    valueField:'ID',
                    displayField:'valor',
                   },
                   type:'ComboBox',
                   valorInicial: 'no',
                   id_grupo:0,                   
                   grid:true,
                   form:true
         },
         {	//#15
                config:{
                       name:'indefinido',
                       fieldLabel:'Ctto Indefinido',
                       allowBlank:false,
                       emptyText:'...',
                       typeAhead: true,
                       triggerAction: 'all',
                       lazyRender:true,
                       mode: 'local',                       
                       gwidth: 100,
                       store:new Ext.data.ArrayStore({
                    fields: ['ID', 'valor'],
                    data :    [['no','no'],    
                            ['si','si']]
                                
                    }),
                    valueField:'ID',
                    displayField:'valor',
                   },
                   type:'ComboBox',
                   valorInicial: 'no',
                   id_grupo:0,                   
                   grid:true,
                   form:true
         },
		{
			config:{
				name: 'estado_reg',
				fieldLabel: 'Estado Reg.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:10
			},
				type:'TextField',
				filters:{pfiltro:'tipcon.estado_reg',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'usr_reg',
				fieldLabel: 'Creado por',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4
			},
				type:'NumberField',
				filters:{pfiltro:'usu1.cuenta',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'fecha_reg',
				fieldLabel: 'Fecha creación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
							format: 'd/m/Y', 
							renderer:function (value,p,record){return value?value.dateFormat('d/m/Y H:i:s'):''}
			},
				type:'DateField',
				filters:{pfiltro:'tipcon.fecha_reg',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'fecha_mod',
				fieldLabel: 'Fecha Modif.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
							format: 'd/m/Y', 
							renderer:function (value,p,record){return value?value.dateFormat('d/m/Y H:i:s'):''}
			},
				type:'DateField',
				filters:{pfiltro:'tipcon.fecha_mod',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'usr_mod',
				fieldLabel: 'Modificado por',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4
			},
				type:'NumberField',
				filters:{pfiltro:'usu2.cuenta',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		}
	],
	tam_pag:50,	
	title:'Tipo Contrato',
	ActSave:'../../sis_organigrama/control/TipoContrato/insertarTipoContrato',
	ActDel:'../../sis_organigrama/control/TipoContrato/eliminarTipoContrato',
	ActList:'../../sis_organigrama/control/TipoContrato/listarTipoContrato',
	id_store:'id_tipo_contrato',
	fields: [
		{name:'id_tipo_contrato', type: 'numeric'},
		{name:'codigo', type: 'string'},
		{name:'nombre', type: 'string'},
		{name:'estado_reg', type: 'string'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
		{name:'considerar_planilla', type: 'string'},//#18
		{name:'indefinido', type: 'string'},//#15
	],
	sortInfo:{
		field: 'id_tipo_contrato',
		direction: 'ASC'
	},
	bdel:true,
	bsave:true
	}
)
</script>
		
		