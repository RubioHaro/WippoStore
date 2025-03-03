create database wippodb;

use wippodb;

create table if not exists Usuario(
	ID_Usuario int(11) not null AUTO_INCREMENT,
    Correo_Electronico varchar(40) not null,
    Contraseña varchar(40) not null,
	Nombre varchar(15) not null,
    Apellido_Paterno varchar(15) not null,
    Apellido_Materno varchar(15) not null, 
    Telefono varchar(17),
    Tipo_Usuario varchar(1) not null,
    Estatus varchar(20) not null DEFAULT 'porActivar',
    RFC varchar(12),
    primary key(ID_Usuario),
    constraint Tipos_de_Usuario check (Tipo_Usuario = 'A' or Tipo_Usuario 
    = 'C' or Tipo_Usuario = 'V'),
    constraint Estado_usuario check (Estatus="Activo" or Estatus="porActivar")
)ENGINE=INNODB;

drop TABLE if exists TokensCorreo;
CREATE TABLE if not exists TokensCorreo(
    ID_Usuario INT(11) NOT NULL UNIQUE,
    token VARCHAR(40) NOT NULL UNIQUE,
    fecha VARCHAR(40) NOT NULL,
    FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario)
)ENGINE=INNODB;

drop PROCEDURE if exists addToken;
DELIMITER &&  
CREATE PROCEDURE addToken (in token VARCHAR(40), in ID_Usuario int)  
BEGIN  
    REPLACE INTO TokensCorreo(ID_Usuario, token, fecha) VALUES(ID_Usuario, token, now());
END &&  
DELIMITER ;  
-- Example: call addToken("1234", 1);

drop PROCEDURE if exists validateToken;
DELIMITER &&  
CREATE PROCEDURE validateToken (in user_token VARCHAR(40), in ID_Usuario_r int)  
BEGIN
    DECLARE tk Varchar(40);
    SELECT `token` INTO tk FROM `TokensCorreo` WHERE ID_Usuario = ID_Usuario_r limit 1;
    if(tk = user_token) then
        DELETE FROM `TokensCorreo` WHERE ID_Usuario = ID_Usuario_r;
        UPDATE Usuario  SET  Estatus = 'Activo'  WHERE ID_Usuario = ID_Usuario_r;
    end if;
END &&  
DELIMITER ;  

-- Example: call validateToken("1234", 1);


create table if not exists Producto(
	ID_Producto int(11) not null AUTO_INCREMENT,
    Nombre varchar(30) not null,
    Precio int not null,
    Cantidad int,
    Categoria varchar(20) not null,
    Color varchar(20),
    Descripcion varchar(100) not null,
    Caracteristica_1 varchar (100) not null,
    Caracteristica_2 varchar (100) not null,
    Caracteristica_3 varchar (100) not null,
    Caracteristica_4 varchar (100),
    Caracteristica_5 varchar (100),
    imagen1 varchar(50),
    imagen2 varchar(50),
    iamgen3 varchar(50),
    ID_Usuario int(11) not null,
    Primary Key (ID_Producto, ID_Usuario),
    constraint Referencia_Producto_Usuario Foreign Key (ID_Usuario) references Usuario(ID_Usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    constraint Precio_Negativo check (Precio>0),
    constraint Cantidad_Negatvo check (Cantidad>0)
)ENGINE=INNODB;

create table if not exists Carrito(
	ID_Carrito int(11) not null AUTO_INCREMENT,
    ID_Usuario int(11) not null,
    Monto_Total int not null,
    primary key(ID_Carrito),
    constraint Referencia_Carrito_Usuario foreign key (ID_Usuario) references Usuario(ID_Usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    constraint Carrito_Monto_Negativo check (Monto_Total>0)
)ENGINE=INNODB;


drop PROCEDURE if exists updateCartTotal;
DELIMITER &&  
CREATE PROCEDURE updateCartTotal (in toADD int,in ID_Carrito int)  
BEGIN
    DECLARE total int;
    SELECT carrito.Monto_Total INTO total FROM carrito WHERE carrito.ID_Carrito = ID_Carrito;
    UPDATE `carrito` SET `Monto_Total` = (total + toADD) WHERE `carrito`.`ID_Carrito` = ID_Carrito;
END &&  
DELIMITER ;

drop PROCEDURE if exists addToCart;
DELIMITER &&  
CREATE PROCEDURE addToCart (in ID_Producto int, in ID_Usuario_r int, in Cantidad int)  
BEGIN
    DECLARE ìdCarrito int;
    DECLARE Total int;
    SELECT `ID_Carrito` INTO ìdCarrito FROM `Carrito` WHERE `ID_Usuario` = ID_Usuario_r limit 1;
    if(ìdCarrito IS NOT NULL) then
        INSERT INTO `CarritoContiene` (`ID_Carrito`, `ID_Producto`, `Cantidad`) VALUES (ìdCarrito, ID_Producto, Cantidad);
        SELECT (Producto.Precio * Cantidad) INTO Total FROM `Producto` WHERE `ID_Producto` = ID_Producto limit 1;
        call updateCartTotal(Total, ìdCarrito);
    end if;
END &&  
DELIMITER ;  

drop PROCEDURE if exists getCart;
DELIMITER &&  
CREATE PROCEDURE getCart (in ID_Usuario_r int)  
BEGIN
    SELECT carrito.ID_Carrito, carrito.ID_Usuario, carritocontiene.ID_Producto, carritocontiene.Cantidad, producto.Nombre, producto.Categoria, producto.Precio, producto.imagen1 
    FROM `carrito` INNER JOIN carritocontiene on carrito.ID_Carrito = carritocontiene.ID_Carrito INNER JOIN producto ON producto.ID_Producto = carritocontiene.ID_Producto where carrito.ID_Usuario = ID_Usuario_r;
END &&  
DELIMITER ;

drop PROCEDURE if exists removeFromCart;
DELIMITER &&  
CREATE PROCEDURE removeFromCart (in ID_Usuario_r int, in ID_Producto int)  
BEGIN
    DECLARE idCarrito int;
        SELECT `ID_Carrito` INTO idCarrito FROM `Carrito` WHERE `ID_Usuario` = ID_Usuario_r limit 1;
        if(idCarrito IS NOT NULL) then
            DELETE FROM `carritocontiene` WHERE `carritocontiene`.`ID_Carrito` = idCarrito AND `carritocontiene`.`ID_Producto` = ID_Producto;
    end if;

END &&  
DELIMITER ;

create table if not exists CarritoContiene(
	ID_Carrito int(11) not null,
    ID_Producto int(11) not null,
    Cantidad int not null,
    constraint Referencia_Carrito_Contiene_Carrito foreign key (ID_Carrito) references Carrito(ID_Carrito) ON DELETE CASCADE ON UPDATE CASCADE,
    constraint Referencia_Carrito_Contiene_Producto foreign key (ID_Producto) references Producto(ID_Producto) ON DELETE CASCADE ON UPDATE CASCADE,
    primary key (ID_Producto,ID_Carrito),
    constraint Carrito_Contenido_Negativo check (Cantidad>0)
)engine=innodb; 

create table if not exists Orden(
	ID_Orden int(11) not null AUTO_INCREMENT,
    Fecha date not null,
    Estatus varchar(20) not null,
    Monto_Total int not null,
    ID_Usuario int(11) not null,
    primary key(ID_Orden),
    constraint Referencia_Orden_Usuario foreign key (ID_Usuario) references Usuario(ID_Usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    constraint Monto_Negaivo check (Monto_Total>0),
    constraint Estado_orden check (Estatus="Pendiente" or Estatus="Enviado" or Estatus="Entregado")
);

create table if not exists Solicitar_Devolucion(
	Producto_ID_Usuario int(11) not null,
	Producto_ID_Producto int(11) not null,
    Usuario_ID_Usuario int(11) not null,
    Motivo varchar(50),
    Estatus	varchar(20) not null,
    Fecha_Solicitud date not null,
    constraint Referencia_Solicitar_Producto foreign key(Producto_ID_Usuario,Producto_ID_Producto) references  Producto(ID_Usuario,ID_Producto) ON DELETE CASCADE ON UPDATE CASCADE,
    constraint Referencia_Solicitar_Usuario foreign key(Usuario_ID_Usuario) references Usuario(ID_Usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    primary key (Producto_ID_Producto,Producto_ID_Usuario,Usuario_ID_Usuario),
    constraint Estatus_de_Devolucion check (Estatus = "Pendiente" or Estatus = "Devuelto" or Estatus = "Rechazado")
)ENGINE=INNODB;

create table if not exists Califica(
	Usuario_ID_Usuario int(11) not null,
    Producto_ID_Usuario int(11) not null,
    Producto_ID_Producto int(11) not null,
    Modelo varchar(30) not null,
    Calificacion int not null,
    Comentario varchar(70),
    constraint Referencia_Califica_Usuario foreign key (Usuario_ID_Usuario) references Usuario(ID_Usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    constraint Referencia_Califica_Producto foreign key (Producto_ID_Usuario,Producto_ID_Producto) references Producto(ID_Usuario,ID_Producto) ON DELETE CASCADE ON UPDATE CASCADE,
    primary key (Usuario_ID_Usuario,Producto_ID_Usuario,Producto_ID_Producto)
)engine=innodb;

create table if not exists Contiene(
	ID_Orden int(11) not null,
    ID_Producto int(11) not null,
    ID_Usuario int(11) not null,
    Cantidad int not null,
    constraint Referencia_Contiene_Orden foreign key (ID_Orden) references Orden(ID_Orden) ON DELETE CASCADE ON UPDATE CASCADE,
    constraint Referencia_Contiene_Producto foreign key (ID_Producto,ID_Usuario) references Producto(ID_Producto,ID_Usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    primary key (ID_Orden,ID_Producto,ID_Usuario),
    constraint Contenido_Negativo check (Cantidad>0)
)engine=innodb; 

create table if not exists Tarjeta_Registrada(
	ID_Tarjeta	varchar(30) not null,
    No_Tarjeta varchar(16) not null,
    Mes char(2) not null,
    Año char(2)  not null,
    ID_Usuario int(11) not null,
    primary key (No_Tarjeta),
    constraint Referencia_Tarjeta_Usuario foreign key (ID_Usuario) references Usuario(ID_Usuario) ON DELETE CASCADE ON UPDATE CASCADE
)engine=innodb;

create table if not exists Direccion(
	ID_Direccion int(11) not null AUTO_INCREMENT,
    Nombre_Calle varchar(30) not null,
    Num_ext int not null,
    Num_int int,
    Colonia varchar(20) not null,
    Municipio varchar(20) not null,
    Estado varchar(15) not null,
    CP char(5) not null,
    ID_Usuario int(11) not null,
    primary key(ID_Direccion,ID_Usuario),
    constraint Referencia_Direccion_Usuario foreign key (ID_Usuario) references Usuario(ID_Usuario) ON DELETE CASCADE ON UPDATE CASCADE
)engine=innodb;
