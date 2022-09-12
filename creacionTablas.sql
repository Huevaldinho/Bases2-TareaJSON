/*
Tarea JSON || Bases de Datos II
Por: Felipe Obando & Sebastián Bermúdez
12 de septiembre del 2022
*/

CREATE TABLE Persona(
    idPersona serial not null primary key,
    infoPersona JSON
);
CREATE TABLE Empleado(
    idEmpleado serial not null primary key
) INHERITS(Persona);
CREATE TABLE Cliente(
    idCliente serial not null primary key
) INHERITS(Persona);
CREATE TABLE Producto(
    idProducto serial not null primary key,
    idEmpleado integer REFERENCES Empleado(idEmpleado),
    infoProducto JSON,
    cantidad integer not null
);
CREATE TABLE Venta(
    idVenta serial not null primary key,
    idEmpleado integer REFERENCES Empleado(idEmpleado),
    idCliente integer REFERENCES Cliente(idCliente),
    productos JSON,
    total integer
);
CREATE TYPE busquedaProductos AS( --para la búsqueda de productos
	precioBuscado text,
	cantidadBuscada int
);
/*
--INSERTAR DATOS A PIE y LLAMADAS A FUNCIONES
--Cliente
INSERT INTO Cliente(infoPersona) VALUES('{
    "nombre": "Felipe",
    "apellidos":"Obando",
    "email":"felipe@gmail.com",
    "cedula":"1234"
}');

--Empleado
INSERT INTO Empleado(infoPersona) VALUES('{
    "nombre": "Sebastian",
    "apellidos":"Hermes",
    "email":"hermes@gmail.com",
    "cedula":"4231"
}');

--Producto
Insert into  Producto(idEmpleado,infoProducto,cantidad
) VALUES (1,'{
    "nombre": "Helado de Fresa",
    "tipoPresentacion": "helado",
    "sabor":[
        {"nombre": "fresa"},
        {"nombre": "vainilla"}
    ],
    "azucar": 100,
    "numeroLote": 1,
    "fechaFabricacion": "2022-09-08",
    "precio": 500
}',10);


Insert into  Producto(idEmpleado,infoProducto,cantidad
) VALUES (1,'{
								"nombre": "Helado Chocolate",
								"tipoPresentacion": "Paleta",
								"sabor":[
									{"nombre": "Chocolate"},
									{"nombre": "Oreo"}
								],
								"azucar": 500,
								"numeroLote": 2,
								"fechaFabricacion": "2022-09-08",
								"precio": 1000
							}',300);
Insert into  Producto(idEmpleado,infoProducto,cantidad
) VALUES (1,'{
								"nombre": "Helado de Coco",
								"tipoPresentacion": "Cono",
								"sabor":[
									{"nombre": "Coco"},
									{"nombre": "Caramelo"}
								],
								"azucar": 300,
								"numeroLote": 3,
								"fechaFabricacion": "2022-09-08",
								"precio": 500
							}',50);

call generarPedido(1,1,'{ 
				   "nombre": "Helado hechizo 3",
					"tipoPresentacion": "cono",
					"sabor":[
						{"nombre": "cacao"},
						{"nombre": "guacamole"}
						] }');
						  

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
					}',1,
					1);

*/

