/*
Tarea JSON || Bases de Datos II
Por: Felipe Obando & Sebastián Bermúdez
12 de septiembre del 2022
*/

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


-- 3. Cree un procedimiento que busque productos por alguna de las características, obtenga el 
--precio y cantidades disponibles 
CREATE OR REPLACE FUNCTION productosXnombre(
	nombre_ character varying
)
RETURNS setof busquedaProductos
LANGUAGE plpgsql as $pX$

BEGIN
	--El ingreso nulo del parámetro lo valida postgres, no permite llamar la función 
	if (select count(idproducto) from Producto where infoProducto->>'nombre'=nombre_)=0 then
		raise notice 'No existe coincidencias de producto con el nombre ingresado';
	else
		return query 
		select infoProducto->>'precio' as precio, cantidad from Producto
		where infoproducto->>'nombre' = nombre_;
	end if;


END; $pX$

CREATE OR REPLACE FUNCTION productosXtipoPresentacion(
	tipoPresentacion_ character varying
)
RETURNS setof busquedaProductos
LANGUAGE plpgsql as $pXtp$

BEGIN
	--El ingreso nulo del parámetro lo valida postgres, no permite llamar la función 
	if (select count(idproducto) from Producto where infoProducto->>'tipoPresentacion'=tipoPresentacion_)=0 then
		raise notice 'No existe coincidencias de producto con el tipo de presentacion ingresado';
	else
		return query 
		select infoProducto->>'precio' as precio, cantidad from Producto
		where infoproducto->>'tipoPresentacion' = tipoPresentacion_;
	end if;


	end; $pXtp$

CREATE OR REPLACE FUNCTION productosXnumeroLote(
	numeroLote_ character varying
)
RETURNS setof busquedaProductos
LANGUAGE plpgsql as $pX$

BEGIN
	--El ingreso nulo del parámetro lo valida postgres, no permite llamar la función 
	if (select count(idproducto) from Producto where infoProducto->>'numeroLote'=numeroLote_)=0 then
		raise notice 'No existe coincidencias de producto con el numero de lote ingresado';
	else
		return query 
		select infoProducto->>'precio' as precio, cantidad from Producto
		where infoproducto->>'numeroLote' = numeroLote_;
	end if;


END; $pX$

CREATE OR REPLACE FUNCTION productosXfechaFabricacion(
	fechaFabricacion_ character varying
)
RETURNS setof busquedaProductos
LANGUAGE plpgsql as $pX$

BEGIN
	--El ingreso nulo del parámetro lo valida postgres, no permite llamar la función 
	if (select count(idproducto) from Producto where infoProducto->>'fechaFabricacion'=fechaFabricacion_)=0 then
		raise notice 'No existe coincidencias de producto con el nombre ingresado';
	else
		return query 
		select infoProducto->>'precio' as precio, cantidad from Producto
		where infoproducto->>'fechaFabricacion' = fechaFabricacion_;
	end if;


END; $pX$
-- 4. Cree un procedimiento que obtenga los montos de ventas por productos, recibe como 
--parámetro fechas (opcionales), cliente(opcionales), producto(opcional) 
CREATE OR REPLACE FUNCTION montosVentaXProducto(
	fecha_ DATE DEFAULT NULL,
	idCliente_ INTEGER DEFAULT NULL,
	nombreProducto_ character varying DEFAULT NULL
)
RETURNS integer
LANGUAGE plpgsql as $mvXp$
DECLARE
	montoFinal integer;
	
BEGIN
	CREATE TEMP TABLE productosVendidos AS
		SELECT fecha, nombre, precio, cantidad FROM (
			SELECT 
			(json_array_elements(productos->'productos')->>'fechaFabricacion')::date as fecha,
			(json_array_elements(productos->'productos')->>'nombre')::character varying as nombre,
			(json_array_elements(productos->'productos')->>'precio')::integer as precio,
			(json_array_elements(productos->'productos')->>'cantidad')::integer as cantidad
			from Venta
		) as infoProductos;
		
	IF (fecha_ is null --con nada
		and idCliente_ is null
		and nombreProducto_ is null	
		) then
		select sum(precio*cantidad) from productosVendidos into montoFinal;
	
	ELSIF (fecha_ is not null  --con fecha
		and idCliente_ is null
		and nombreProducto_ is null	
		) then
			
			IF (fecha_ > NOW()) then
				raise notice 'La fecha no es válida';
				select 0 into montoFinal;
			ELSE
				select sum(precio*cantidad) from productosVendidos into montoFinal where fecha = fecha_;
			END IF;
		
	ELSIF (fecha_ is null  --con idCliente
		and idCliente_ is not null
		and nombreProducto_ is null	
		) then
			IF (select count(idCliente) from Cliente where idCliente=idCliente_)=0 then--no existe el cliente
				raise notice 'No existe el cliente ingresado';
				select 0 into montoFinal;
			ELSE
				select sum(precios) from 
					(select (json_array_elements(productos->'productos')->>'precio')::integer 
					 as precios from Venta where idCliente = 1)
				as preciosTotales into montoFinal;
			END IF;
		
	ELSIF (fecha_ is null  --con nombreProducto
		and idCliente_ is null
		and nombreProducto_ is not null	
		) then
			select sum(precio*cantidad) from productosVendidos into montoFinal where nombre = nombreProducto_;
	
	END IF;
		
		drop table productosVendidos;
		
		return montoFinal;
	
	
END; $mvXp$