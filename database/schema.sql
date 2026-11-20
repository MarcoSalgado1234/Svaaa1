
DROP DATABASE IF EXISTS svaaa;
CREATE DATABASE svaaa CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE svaaa;


CREATE TABLE usuarios (
    id_usuario        INT AUTO_INCREMENT PRIMARY KEY,
    nombre            VARCHAR(100) NOT NULL,
    email             VARCHAR(120) NOT NULL UNIQUE,
    password_hash     VARCHAR(255) NOT NULL,
    telefono          VARCHAR(20),
    fecha_nacimiento  DATE NOT NULL,
    rol               ENUM('cliente','mayorista','repartidor','admin') NOT NULL DEFAULT 'cliente',
    activo            TINYINT(1) NOT NULL DEFAULT 1,
    fecha_registro    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


CREATE TABLE categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(60) NOT NULL UNIQUE,
    es_alcohol   TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE origenes (
    id_origen INT AUTO_INCREMENT PRIMARY KEY,
    nombre    VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE marcas (
    id_marca INT AUTO_INCREMENT PRIMARY KEY,
    nombre   VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE productos (
    id_producto         INT AUTO_INCREMENT PRIMARY KEY,
    nombre              VARCHAR(120) NOT NULL,
    id_marca            INT NOT NULL,
    id_categoria        INT NOT NULL,
    id_origen           INT NOT NULL,
    presentacion        VARCHAR(60) NOT NULL,
    graduacion          DECIMAL(4,1) NOT NULL DEFAULT 0,
    descripcion         TEXT,
    emoji               VARCHAR(8) DEFAULT '🍺',
    precio              DECIMAL(10,2) NOT NULL,          
    piezas_por_caja     INT NOT NULL DEFAULT 12,
    precio_caja         DECIMAL(10,2) NOT NULL,          
    precio_caja_mayoreo DECIMAL(10,2) NOT NULL,          
    stock               INT NOT NULL DEFAULT 0,          
    stock_minimo        INT NOT NULL DEFAULT 24,
    es_artesanal        TINYINT(1) NOT NULL DEFAULT 0,
    activo              TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT fk_prod_marca FOREIGN KEY (id_marca) REFERENCES marcas(id_marca),
    CONSTRAINT fk_prod_cat   FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
    CONSTRAINT fk_prod_orig  FOREIGN KEY (id_origen) REFERENCES origenes(id_origen),
    CONSTRAINT chk_stock CHECK (stock >= 0)
) ENGINE=InnoDB;

CREATE TABLE promociones (
    id_promocion INT AUTO_INCREMENT PRIMARY KEY,
    titulo       VARCHAR(100) NOT NULL,
    descripcion  VARCHAR(255) NOT NULL,
    id_categoria INT NULL,
    porcentaje   DECIMAL(5,2) NOT NULL DEFAULT 0,
    vigente_desde DATE NOT NULL,
    vigente_hasta DATE NOT NULL,
    activa       TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT fk_promo_cat FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
) ENGINE=InnoDB;


CREATE TABLE zonas_cobertura (
    id_zona        INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(80) NOT NULL,
    codigo_postal  VARCHAR(5) NOT NULL UNIQUE,
    costo_envio    DECIMAL(8,2) NOT NULL,
    tiempo_min     INT NOT NULL,                         
    activa         TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE direcciones (
    id_direccion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario   INT NOT NULL,
    calle        VARCHAR(120) NOT NULL,
    numero       VARCHAR(15) NOT NULL,
    colonia      VARCHAR(80) NOT NULL,
    codigo_postal VARCHAR(5) NOT NULL,
    referencias  VARCHAR(200),
    CONSTRAINT fk_dir_usr FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB;


CREATE TABLE pedidos (
    id_pedido     INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario    INT NOT NULL,
    modalidad     ENUM('apartado','domicilio') NOT NULL,
    id_direccion  INT NULL,
    id_zona       INT NULL,
    metodo_pago   ENUM('efectivo','transferencia') NOT NULL,
    estatus       ENUM('recibido','preparando','en_camino','entregado','cancelado') NOT NULL DEFAULT 'recibido',
    subtotal      DECIMAL(10,2) NOT NULL,
    descuento     DECIMAL(10,2) NOT NULL DEFAULT 0,
    costo_envio   DECIMAL(10,2) NOT NULL DEFAULT 0,
    total         DECIMAL(10,2) NOT NULL,
    fecha         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ped_usr  FOREIGN KEY (id_usuario)   REFERENCES usuarios(id_usuario),
    CONSTRAINT fk_ped_dir  FOREIGN KEY (id_direccion) REFERENCES direcciones(id_direccion),
    CONSTRAINT fk_ped_zona FOREIGN KEY (id_zona)      REFERENCES zonas_cobertura(id_zona)
) ENGINE=InnoDB;

CREATE TABLE detalle_pedido (
    id_detalle      INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido       INT NOT NULL,
    id_producto     INT NOT NULL,
    tipo_unidad     ENUM('pieza','caja') NOT NULL,
    cantidad        INT NOT NULL,
    piezas_totales  INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    mayoreo         TINYINT(1) NOT NULL DEFAULT 0,
    importe         DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_det_ped  FOREIGN KEY (id_pedido)   REFERENCES pedidos(id_pedido) ON DELETE CASCADE,
    CONSTRAINT fk_det_prod FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
) ENGINE=InnoDB;

CREATE TABLE historial_estatus (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido    INT NOT NULL,
    estatus      VARCHAR(20) NOT NULL,
    fecha        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_hist_ped FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_prod_busqueda ON productos(nombre, activo);
CREATE INDEX idx_ped_usuario   ON pedidos(id_usuario, fecha);


INSERT INTO usuarios (nombre, email, password_hash, telefono, fecha_nacimiento, rol) VALUES
('Administrador Martínez', 'admin@svaaa.com',
 'pbkdf2:sha256:1000000$SoeTqAqdLfDlpNiZ$adc5babd6a44e551a0eca451b6282aa819f28544e97774614ed918b91a3affe3',
 '8711000001', '1985-03-12', 'admin'),
('Cliente Demo', 'cliente@svaaa.com',
 'pbkdf2:sha256:1000000$t4vPZfoeaZj2HKt0$64d0daa3e4320b36b56bc0e5dc2ea392d328248459e063ba88d8ca04a6a153ef',
 '8711000002', '1995-06-20', 'cliente'),
('Mayorista Demo', 'mayorista@svaaa.com',
 'pbkdf2:sha256:1000000$9Vfqn2hSaWGOpIAZ$3a8412bb855f93a6ce222e981a9b444e836885df9676c177e511b74632565af1',
 '8711000003', '1988-11-02', 'mayorista');

INSERT INTO categorias (nombre, es_alcohol) VALUES
('Cerveza comercial',1),('Cerveza artesanal',1),('Cerveza internacional',1),
('Refrescos',0),('Botanas',0),('Abarrotes',0);

INSERT INTO origenes (nombre) VALUES
('México'),('Estados Unidos'),('Alemania'),('Bélgica'),('Irlanda'),('Países Bajos');

INSERT INTO marcas (nombre) VALUES
('Corona'),('Tecate'),('Modelo'),('Victoria'),('Minerva'),('Cucapá'),('Calavera'),
('Heineken'),('Paulaner'),('Guinness'),('Leffe'),('Coca-Cola'),('Sabritas'),('La Costeña');

INSERT INTO productos
(nombre,id_marca,id_categoria,id_origen,presentacion,graduacion,descripcion,emoji,precio,piezas_por_caja,precio_caja,precio_caja_mayoreo,stock,stock_minimo,es_artesanal) VALUES
('Corona Extra',1,1,1,'Botella 355 ml',4.5,'Cerveza clara tipo lager, ligera y refrescante. La favorita para acompañar con limón.','🍺',22.00,24,480.00,440.00,240,48,0),
('Tecate Roja',2,1,1,'Lata 355 ml',4.5,'Lager de cuerpo ligero, ideal para el calor del norte.','🥫',20.00,24,432.00,396.00,300,48,0),
('Modelo Especial',3,1,1,'Lata 355 ml',4.4,'Pilsner de sabor suave y balanceado.','🥫',24.00,24,520.00,480.00,180,48,0),
('Victoria',4,1,1,'Botella 355 ml',4.0,'Cerveza estilo Viena de color ámbar y sabor tostado.','🍺',22.00,24,480.00,445.00,36,48,0),
('Minerva Pale Ale',5,2,1,'Botella 355 ml',5.5,'Pale ale artesanal con notas cítricas y amargor medio. Producida en Guadalajara.','🍻',45.00,12,500.00,455.00,96,24,1),
('Cucapá Obscura',6,2,1,'Botella 355 ml',5.0,'Cerveza oscura artesanal de Baja California con notas de caramelo y café.','🍻',48.00,12,540.00,490.00,72,24,1),
('Calavera IPA',7,2,1,'Botella 355 ml',6.5,'IPA artesanal mexicana con lúpulo intenso y final amargo.','🍻',52.00,12,580.00,530.00,60,24,1),
('Heineken',8,3,6,'Botella 330 ml',5.0,'Lager premium holandesa de sabor equilibrado.','🍺',34.00,24,760.00,700.00,120,24,0),
('Paulaner Hefe-Weissbier',9,3,3,'Botella 500 ml',5.5,'Cerveza de trigo alemana, turbia, con notas de plátano y clavo.','🍺',68.00,12,780.00,720.00,48,12,0),
('Guinness Draught',10,3,5,'Lata 440 ml',4.2,'Stout irlandesa cremosa con notas de café tostado.','🍺',62.00,24,1380.00,1280.00,72,24,0),
('Leffe Blonde',11,3,4,'Botella 330 ml',6.6,'Cerveza de abadía belga, dulce y especiada.','🍺',72.00,24,1600.00,1500.00,18,24,0),
('Coca-Cola 600 ml',12,4,1,'Botella 600 ml',0,'Refresco de cola clásico.','🥤',18.00,12,200.00,185.00,200,48,0),
('Sabritas Original 170 g',13,5,1,'Bolsa 170 g',0,'Papas fritas con sal.','🍟',32.00,10,290.00,270.00,80,20,0),
('Chiles Jalapeños La Costeña',14,6,1,'Lata 220 g',0,'Chiles jalapeños en escabeche.','🌶️',19.00,24,420.00,390.00,100,24,0);

INSERT INTO promociones (titulo, descripcion, id_categoria, porcentaje, vigente_desde, vigente_hasta) VALUES
('Mayoreo desde 3 cajas','Compra 3 o más cajas del mismo producto y paga el precio especial de mayoreo.',NULL,0,'2026-01-01','2026-12-31'),
('Semana artesanal','Descubre la cerveza artesanal mexicana con 10% de descuento en piezas sueltas.',2,10,'2026-11-01','2026-11-30'),
('Fin de año','Refrescos y botanas para tu fiesta con 5% de descuento.',4,5,'2026-12-01','2026-12-31');


INSERT INTO zonas_cobertura
(nombre, codigo_postal, costo_envio, tiempo_min)
VALUES
('La Guayulera', '25180', 30.00, 30),
('Bellavista', '25060', 35.00, 35),
('La Minita', '25170', 40.00, 40),
('El Tanquecito', '25190', 45.00, 45),
('Valle de las Flores Popular', '25150', 50.00, 50);

INSERT INTO direcciones (id_usuario, calle, numero, colonia, codigo_postal, referencias) VALUES
(2,'Av. Morelos','123','Centro','27000','Casa blanca, portón negro');

SELECT 'Base de datos SVAAA creada correctamente' AS resultado;
