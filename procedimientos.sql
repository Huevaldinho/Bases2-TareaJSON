

-- 1. Cree un procedimiento para generar la compra de productos para un cliente 
CREATE OR REPLACE PROCEDURE public.compraproducto(
	IN productosin json,
	IN idempleado_ integer,
	IN idcliente_ integer)
LANGUAGE 'plpgsql'
AS $BODY$
    DECLARE 

    BEGIN
    --Validar que exista el empleado
	if (productosIN is null or idEmpleado_ is null or idCliente_ is null) then
		raise notice 'Error, debe ingresar todos los parametros';
    elsif (select count(idEmpleado) from Empleado where idEmpleado=idEmpleado_)=0 then
        --No existe empleado con el idEmpleado_ ingresado
        raise notice 'Error, no existe empleado con el parametro ingresado.';

    elsif (select count(idCliente) from Cliente where idCliente=idCliente_)=0 then
        raise notice 'Error, no existe cliente con el parámetro ingresado.';

    --Validar que la lista de productos que trae productosIN existan en la tabla Producto y tengan una cantidad válida
    elsif (select count(infoProducto ->> 'nombre') from Producto where 
                infoProducto ->> 'nombre' not in (select productosIN -> 'productos' ->> 'nombre') and 
                Producto.cantidad <= (select (productosIN -> 'productos' ->> 'cantidad' )::integer
                                        where productosIN -> 'productos' ->> 'nombre' = infoProducto ->> 'nombre')
          )>0 then 
            raise notice 'Error, no existe o no hay cantidad suficiente para los productos ingresados.';
    else
        
		
		drop table if exists jsonTabla;
		CREATE TEMP TABLE jsonTabla AS
			SELECT nombre,cantidad,precio FROM (
			 select json_array_elements(productosIn->'productos')->>'nombre' as nombre,
				(json_array_elements(productosIn->'productos')->>'cantidad')::integer  as cantidad,
				(json_array_elements(productosIn->'productos')->>'precio')::integer  as precio
			) as datosJson;

        insert into Venta(idEmpleado,idCliente,productos,total) 
						  
				values (idEmpleado_,idCliente_,productosIN,( select sum(cantidad*precio) as total from jsonTabla));
						

		UPDATE Producto set cantidad =  cantidad - COALESCE((select cantidad from jsonTabla where nombre = infoProducto->>'nombre'),0);
         
		 Drop table jsonTabla;
        
    end if;
    
END $BODY$;

CALL CompraProducto('{ "productos":[
							{
								"nombre": "Helado de Fresa",
								"tipoPresentacion": "Cono",
								"sabor":[
									{"nombre": "Fresa"},
									{"nombre": "Vainilla"}
								],
								"azucar": 100,
								"numeroLote": 1,
								"fechaFabricacion": "2022-09-08",
								"precio": 600,
								"cantidad":2
							},
							{
								"nombre": "Helado Chocolate",
								"tipoPresentacion": "Paleta",
								"sabor":[
									{"nombre": "Chocolate"},
									{"nombre": "Oreo"}
								],
								"azucar": 500,
								"numeroLote": 2,
								"fechaFabricacion": "2022-09-08",
								"precio": 1000,
								"cantidad":3
							},
							{
								"nombre": "Helado de Coco",
								"tipoPresentacion": "Cono",
								"sabor":[
									{"nombre": "Coco"},
									{"nombre": "Caramelo"}
								],
								"azucar": 300,
								"numeroLote": 3,
								"fechaFabricacion": "2022-09-08",
								"precio": 500,
								"cantidad":5
							}
						]
					}',1,1);


-- 2. Cree un procedimiento que genere el pedido personalizado de un cliente 
CREATE OR REPLACE PROCEDURE generarPedido(idEmpleadoIN integer,idClienteIN integer,infoHelado json)

language plpgsql
as $generarPedido$
begin
	/*	Formato infoHelado
		'{ "nombre": "",
			"tipoPresentacion": "",
			"sabor":[
        		{"nombre": ""},
        		{"nombre": ""}
				]
		}'
	*/
	--El cliente puede pedir un helado de un sabor que no existe,
	--es decir, el cliente inventa un producto nuevo.
	--Despues lo podra comprar pero este procedimiento es solo para
	--crear el nuevo producto.

	--Todos los sabores cuestan lo mismo pero cada sabor se cobra individualmente.
	--Valida nulos
	if (idEmpleadoIN is null OR idClienteIN is null OR infoHelado is null ) then
		raise notice 'Error, debe ingresar todos los parametros.';
	--Valida cliente y empleado
	elsif (select idCliente from Cliente where idCliente=idClienteIN)=0 OR
	 (select idEmpleado from Empleado where idEmpleado=idEmpleadoIN)=0 then
		raise notice 'Error, no existe cliente o empleado con los parametros ingresados.';
	--Validar nombre repetido
	elsif (select count(idProducto) from Producto where infoProducto->>'nombre' = infoHelado->>'nombre')>0 then			
		raise notice 'Error, nombre de helado repetido.';
	--Valida sabores
	elsif json_array_length(infoHelado->'sabor')<1 then
		raise notice 'Error, debe ingresar al menos un sabor.';
	end if;

	insert into Producto (idEmpleado,infoProducto,cantidad ) values (idEmpleadoIN,(select json_build_object(
		'nombre' ,infoHelado->>'nombre' ,
		'tipoPresentacion',infoHelado->>'tipoPresentacion',
		--'sabor',(json_build_array(json_build_object('nombre',infoHelado->'sabor'->>'nombre'))),--esta linea no saca los nombres
		'sabor',(select infoHelado-'sabor'),
		'azucar',0,
		'numeroLote',0,
		'fechaFabricacion','',
		'precio',0 )
		),
		0);

end;$generarPedido$

select * from Empleado;
select * from Cliente;

call generarPedido(1,1,'{ 
				   "nombre": "Helado hechizo 3",
					"tipoPresentacion": "cono",
					"sabor":[
						{"nombre": "cacao"},
						{"nombre": "guacamole"}
						] }');
						  
select * from producto;



-- 3. Cree un procedimiento que busque productos por alguna de las características, obtenga el 
--precio y cantidades disponibles 

-- 4. Cree un procedimiento que obtenga los montos de ventas por productos, recibe como 
--parámetro fechas (opcionales), cliente(opcionales), producto(opcional) 
 
select json_build_object(
		'nombre' ,'Hola' ,
		'presentacion', 'presen5tacion',
		'sabor',((json_build_array(json_build_object('nombre','otro sabor')))),
		'azucar',0,
		'numeroLote',0,
		'fechaFabricacion','01/01/2022',
		'precio',0 );