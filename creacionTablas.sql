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

/*
--INSERTAR DATOS A PIE
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

*/