

-- 1. Cree un procedimiento para generar la compra de productos para un cliente 
CREATE PROCEDURE CompraProducto(productosIN JSON,idEmpleado_ integer, idCliente_ integer)
LANGUAGE 'plpgsql' AS $CompraProducto$
    DECLARE 

    BEGIN
    --Validar que exista el empleado
    if (select count(idEmpleado) from Empleado where idEmpleado=idEmpleado_)=0 then
        --No existe empleado con el idEmpleado_ ingresado
        raise notice 'Error, no existe empleado con el parametro ingresado.';

    elsif (select count(idCliente) from Cliente where idCliente=idCliente_)=0 then
        raise notice 'Error, no existe cliente con el parámetro ingresado.';

    --Validar que la lista de productos que trae productosIN existan en la tabla Producto y tengan una cantidad válida
    elsif (select infoProducto ->> 'nombre' from Producto where infoProducto ->> 'nombre' not in 
          (select productosIN -> 'productos' ->> 'nombre') and 
                Producto.cantidad >= (select productosIN -> 'productos' ->> 'cantidad' 
                where productosIN -> 'productos' ->> 'nombre' = infoProducto ->> 'nombre')::integer
          )>0 then 
            raise notice 'Error, no existe o no hay cantidad suficiente para los productos ingresados.';
    else
        
        Insert into Venta(idEmpleado, idCliente,productos,total) values (
            idEmpleado_,idCliente_,productosIN,(select sum((productosIN->'productos'->>'precio')::integer))
        );
        UPDATE table Producto
        
    end if;
    
END $CompraProducto$;

CALL CompraProducto();


-- 2. Cree un procedimiento que genere el pedido personalizado de un cliente 
CREATE PROCEDURE generarPedido()

language plpgsql
as $generarPedido$
begin




end;$generarPedido$
-- 3. Cree un procedimiento que busque productos por alguna de las características, obtenga el 
--precio y cantidades disponibles 

-- 4. Cree un procedimiento que obtenga los montos de ventas por productos, recibe como 
--parámetro fechas (opcionales), cliente(opcionales), producto(opcional) 
 
