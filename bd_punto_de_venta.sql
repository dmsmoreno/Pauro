/*create database punto_de_venta;*/
drop database punto_De_venta;

CREATE DATABASE punto_de_venta;


/*USE punto_de_venta;	*/
use punto_De_venta_pauro;

CREATE TABLE clientes
(
id INTEGER(11) PRIMARY KEY,
nombre VARCHAR(50) NOT NULL,
direccion VARCHAR(50),
telefono VARCHAR(10)
)engine = InnoDB;

CREATE TABLE articulos
(
id INTEGER (11) PRIMARY KEY AUTO_INCREMENT,
nombre VARCHAR(100) UNIQUE NOT NULL,
medida VARCHAR(15) NOT NULL,
stock DECIMAL(10,2)
)engine = InnoDB;


CREATE TABLE usuarios
(
id VARCHAR(20) PRIMARY KEY,
nombre VARCHAR(50) NOT NULL,
contrasena VARCHAR(32) NOT NULL,
rol VARCHAR(20)
)engine = InnoDB;

CREATE TABLE ventas
(
id INTEGER(11) PRIMARY KEY AUTO_INCREMENT,
fecha DATE NOT NULL,
id_cliente INTEGER(11) default null,
id_usuario VARCHAR(10),
FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
)engine = InnoDB;


CREATE TABLE categorias
(
id INTEGER(11) PRIMARY KEY AUTO_INCREMENT,
nombre VARCHAR(20) UNIQUE NOT NULL
)engine = InnoDB;

CREATE TABLE productos
(
id INTEGER (11) PRIMARY KEY AUTO_INCREMENT,
codigo VARCHAR(10) UNIQUE NOT NULL,
nombre VARCHAR(100) UNIQUE NOT NULL,
precio DECIMAL(10,2) NOT NULL,
id_categoria INTEGER(11) NOT NULL,
FOREIGN KEY (id_categoria) REFERENCES categorias(id)
);

CREATE TABLE detalle_ventas
(
id INTEGER(11) PRIMARY KEY AUTO_INCREMENT,
precio DECIMAL(10,2) NOT NULL,
id_producto INTEGER(11) NOT NULL,
cantidad DECIMAL(10,2) NOT NULL,
id_venta INTEGER(11) NOT NULL,
FOREIGN KEY (id_producto) REFERENCES productos(id),
FOREIGN KEY (id_venta) REFERENCES ventas(id)
)engine = InnoDB;

CREATE TABLE detalle_productos
(
id INTEGER(11) PRIMARY KEY AUTO_INCREMENT,
cantidad DECIMAL(10,2) NOT NULL,
id_producto INTEGER(11),
id_articulo INTEGER(11),
FOREIGN KEY (id_producto) REFERENCES productos(id),
FOREIGN KEY (id_articulo) REFERENCES articulos(id)
)engine = InnoDB;

CREATE TABLE proveedores 
(
id INTEGER(11) PRIMARY KEY AUTO_INCREMENT,
razon_social VARCHAR(50) NULL,
tipo_documento VARCHAR(15) NULL,
num_documento VARCHAR(11) UNIQUE NULL,
telefono VARCHAR(10) NULL
)engine = InnoDB;

CREATE TABLE compras
(
id INTEGER(11) PRIMARY KEY AUTO_INCREMENT,
comprobante VARCHAR(15) NOT NULL,
num_comprobante INTEGER(11) NOT NULL,
descripcion VARCHAR(25) NOT NULL,
fecha DATE NOT NULL,
id_proveedor INTEGER(11),
id_usuario VARCHAR(10),
FOREIGN KEY (id_proveedor) REFERENCES proveedores(id),
FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
)engine = InnoDB;

CREATE TABLE detalle_compras
(
id INTEGER(11) PRIMARY KEY AUTO_INCREMENT,
/*stock INTEGER(11) NOT NULL*/
cantidad DECIMAL(10,2) NOT NULL,
/**medida VARCHAR(10) NOT NULL,*/
precio DECIMAL(10,2) NOT NULL,
id_articulo INTEGER(11),
id_compra INTEGER(11),
FOREIGN KEY (id_articulo) REFERENCES articulos(id),
FOREIGN KEY (id_compra)	REFERENCES compras(id)
)engine = InnoDB;


CREATE VIEW vista_productos 
AS SELECT 
productos.codigo,
productos.nombre,
productos.precio,
categorias.nombre AS nombre_categoria
FROM productos,categorias where productos.id_categoria = categorias.id;

CREATE VIEW vista_detalle_productos 
AS SELECT 
detalle_productos.id,
productos.codigo, 
productos.nombre, 
articulos.nombre AS nombre_articulo, 
CONCAT(detalle_productos.cantidad,' - ',articulos.medida) AS cantidad
FROM productos, articulos, detalle_productos
WHERE (productos.id = detalle_productos.id_producto AND articulos.id = detalle_productos.id_articulo) ;

CREATE VIEW vista_clientes AS
SELECT * FROM clientes;

CREATE VIEW vista_usuarios AS
SELECT * FROM usuarios;	

CREATE VIEW vista_proveedores AS
SELECT * FROM proveedores;

CREATE VIEW vista_categorias AS
SELECT * FROM categorias;

CREATE VIEW vista_articulos AS
SELECT * FROM articulos;

/**********************************************************/
SET GLOBAL log_bin_trust_function_creators = 1;
/**********************************************************/



/*******************************************************************



/***********************************************************************************/
SET SQL_SAFE_UPDATES=0;
/***********************************************************************************/

/*---------------------------------------------------------------------------------------*/
INSERT INTO usuarios(id,nombre,contrasena,rol) VALUES (1234,'MATIXA',MD5('1234'),'ADMINISTRADOR');
/*---------------------------------------------------------------------------------------*/



/*-----------------------------------------------------------------------*/
/*Esta tabla crea el detalle del ingreso o actualiacion del inventario.*/
CREATE TABLE ajuste_inventario 
(
	id INTEGER PRIMARY KEY AUTO_INCREMENT, 
    id_articulo INTEGER,
    id_usuario VARCHAR(20),
    descripcion VARCHAR(100) NOT NULL, 
    fecha DATE NOT NULL,
    FOREIGN KEY (id_articulo) REFERENCES articulos(id),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
);
/*------------------------------------------------------------------------*/





/*---------------------------------------------------------------------------------*/



/*-----------------------------------------------------------------------
/*------------------------------------------------------------------------------------------*/





/**
Consulta reporte ventas version 1.0
//SELECT  SUM(detalle_ventas.cantidad)AS cantidad,
//				productos.nombre,
//				productos.precio * SUM(detalle_ventas.cantidad)AS precio,
//				date_format(ventas.fecha,'%d/%m/%Y') AS fecha,
//				productos.precio AS valor_unitario
//FROM    productos,ventas,detalle_ventas
//WHERE   ventas.id = detalle_ventas.id_venta
//		AND productos.id = detalle_ventas.id_producto
//       AND ventas.fecha >= $P{fecha_inicio}   
//      AND ventas.fecha <=  $P{fecha_fin}  
//GROUP BY detalle_ventas.id_producto,fecha
**/



/**********************************************************/
SET GLOBAL log_bin_trust_function_creators = 1;
/**********************************************************/
delimiter $ 
CREATE FUNCTION actualizarStock(id_articulo INTEGER, cantidad_articulo decimal(10,2)) RETURNS Decimal(10,2)
BEGIN 

DECLARE stock_inicial decimal(10,2);
DECLARE stock_ingreso decimal(10,2);

SET stock_ingreso = cantidad_articulo;

SELECT stock INTO stock_inicial FROM articulos WHERE id = id_articulo;

/*UPDATE  articulos SET stock  = stock_inicial + stock_ingreso WHERE id = id_articulo;**/

RETURN stock_inicial + stock_ingreso;  

end$ 
delimiter ;


/*********************************************************************/


DELIMITER $

CREATE FUNCTION obtenerStock(id_articulo INTEGER) RETURNS decimal(10,2)
BEGIN 

DECLARE stock_inicial decimal(10,2);


SELECT stock INTO stock_inicial FROM articulos WHERE id = id_articulo;

/*UPDATE  articulos SET stock  = stock_inicial + stock_ingreso WHERE id = id_articulo;*/

RETURN stock_inicial;  

end $
DELIMITER ;

/******************************************************************************/




/*---------------------------------------------------------------------------------------------------------------*/
DELIMITER $
CREATE  FUNCTION restarStock(id_articulo INTEGER,id_producto INT,cantidad_del_producto decimal) RETURNS decimal(10,2)
BEGIN 

DECLARE stock_inicial decimal(10,2);
DECLARE cantidad_articulo_en_producto decimal(10,2);

/*SELECT detalle_productos.cantidad INTO cantidad_articulo_en_producto FROM detalle_productos, articulos, productos WHERE productos.id = detalle_productos.id_producto AND articulos.id = detalle_productos.id_articulo;*/

SELECT detalle_productos.cantidad INTO cantidad_articulo_en_producto FROM detalle_productos WHERE detalle_productos.id_producto = id_producto AND  detalle_productos.id_articulo = id_articulo;

SELECT stock INTO stock_inicial FROM articulos WHERE id = id_articulo;

/*UPDATE  articulos SET stock  = stock_inicial + stock_ingreso WHERE id = id_articulo;**/

RETURN stock_inicial - cantidad_articulo_en_producto * cantidad_del_producto;  

end $
DELIMITER ;
/*--------------------------------------------------------------------------------------------------------------*/

/***********************************************************************************/

/*---------------------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------------------*/



/*-----------------------------------------------------------------------*/
/*Esta tabla crea el detalle del ingreso o actualiacion del inventario.*/

/*------------------------------------------------------------------------*/



/*---------------------------------------------------------------------------------*/
DELIMITER $
CREATE  FUNCTION sumarStock(id_articulo INTEGER, cantidad decimal) RETURNS decimal(10,2)
BEGIN 

DECLARE stock_inicial decimal;

/*SELECT detalle_productos.cantidad INTO cantidad_articulo_en_producto FROM detalle_productos, articulos, productos WHERE productos.id = detalle_productos.id_producto AND articulos.id = detalle_productos.id_articulo;*/

SELECT stock INTO stock_inicial FROM articulos WHERE id = id_articulo;

/*UPDATE  articulos SET stock  = stock_inicial + stock_ingreso WHERE id = id_articulo;**/

RETURN stock_inicial + cantidad;  

end $
DELIMITER ;

/*---------------------------------------------------------------------------------*/



/*------------------------------------------------------------------------------------*/
DELIMITER $
CREATE  FUNCTION restarStockSinProducto(id_articulo INT, cantidad decimal) RETURNS decimal(10,2)
BEGIN 

DECLARE stock_inicial decimal(10,2);
/*DECLARE cantidad_articulo_en_producto INT;

/*SELECT detalle_productos.cantidad INTO cantidad_articulo_en_producto FROM detalle_productos, articulos, productos WHERE productos.id = detalle_productos.id_producto AND articulos.id = detalle_productos.id_articulo;*/

/*SELECT detalle_productos.cantidad INTO cantidad_articulo_en_producto FROM detalle_productos WHERE detalle_productos.id_producto = id_producto AND  detalle_productos.id_articulo = id_articulo;*/

SELECT stock INTO stock_inicial FROM articulos WHERE id = id_articulo;

/*UPDATE  articulos SET stock  = stock_inicial + stock_ingreso WHERE id = id_articulo;**/

RETURN stock_inicial - cantidad;  

end $
DELIMITER ;
/*------------------------------------------------------------------------------------------*/


