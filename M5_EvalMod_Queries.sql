-- 3 y 4) inserciones y consultas a la base de datos

-- ------------------------------
-- Proveedores
-- ------------------------------
INSERT INTO proveedores (nombre, direccion, telefono, email) VALUES
('Proveedor Uno', 'Av. Principal 123, Santiago', '987654321', 'contacto@proveedor1.cl'),
('Proveedor Dos', 'Calle Secundaria 456, Valparaíso', '912345678', 'ventas@proveedor2.cl'),
('Proveedor Tres', 'Ruta 5 Norte km 50, La Serena', '956789123', 'info@proveedor3.cl'),
('Proveedor Cuatro', 'Av. O’Higgins 789, Concepción', '923456789', 'soporte@proveedor4.cl'),
('Proveedor Cinco', 'Calle Los Robles 321, Antofagasta', '934567891', 'ventas@proveedor5.cl');

-- ------------------------------
-- Productos
-- ------------------------------
INSERT INTO productos (nombre, descripcion, precio) VALUES
('Laptop Gamer', 'Laptop con procesador Intel i7, 16GB RAM, 512GB SSD', 850000),
('Mouse Inalámbrico', 'Mouse óptico inalámbrico con 3 botones', 15000),
('Teclado Mecánico', 'Teclado mecánico retroiluminado RGB', 45000),
('Monitor 24"', 'Monitor LED Full HD 24 pulgadas', 120000),
('Silla Ergonómica', 'Silla de oficina ergonómica ajustable', 90000),
('Impresora Multifuncional', 'Impresora con escáner y WiFi', 75000),
('Smartphone 6.5"', 'Celular Android 6.5 pulgadas, 128GB almacenamiento', 220000),
('Tablet 10"', 'Tablet 10 pulgadas, 4GB RAM, 64GB almacenamiento', 150000),
('Auriculares Bluetooth', 'Audífonos inalámbricos con micrófono', 35000),
('Disco SSD 1TB', 'Disco sólido interno de 1TB NVMe', 120000),
('Cámara Web Full HD', 'Cámara web 1080p con micrófono integrado', 28000),
('Parlante Bluetooth', 'Parlante portátil con batería recargable', 45000),
('Fuente de Poder 650W', 'Fuente de poder certificada 80 Plus Bronze', 55000);

-- ------------------------------
-- Transacciones
-- ------------------------------
-- 1) Compramos 10 laptops al Proveedor Uno
INSERT INTO transacciones (tipo, producto_id, cantidad, proveedor_id) VALUES
(1, 1, 10, 1),
-- 2) Compramos 50 mouse inalámbricos al Proveedor Dos
(1, 2, 50, 2),
-- 3) Vendemos 2 laptops (resta del stock)
(2, 1, 2, 1),
-- 4) Vendemos 5 mouse (resta del stock)
(2, 2, 5, 2);

-- 5) Probamos los procedimientos almacenados para probar las transacciones SQL con COMMIT y ROLLBACK (generaré procedimientos almacenados para ello)
-- Compramos 15 laptops al Proveedor Uno
CALL registrar_compra(1, 15, 1);

-- Compramos 40 mouse al Proveedor Dos
CALL registrar_compra(2, 40, 2);

-- Compramos 25 teclados al Proveedor Tres
CALL registrar_compra(3, 25, 3);

-- Compramos 10 monitores al Proveedor Cuatro
CALL registrar_compra(4, 10, 4);

-- Compramos 30 auriculares al Proveedor Cinco
CALL registrar_compra(9, 30, 5);

-- Vendemos 5 laptops (stock suficiente)
CALL registrar_venta(1, 5, 1);

-- Vendemos 10 mouse (stock suficiente)
CALL registrar_venta(2, 10, 2);

-- Vendemos 3 monitores (stock suficiente)
CALL registrar_venta(4, 3, 4);

-- Vendemos 5 auriculares Bluetooth (stock suficiente)
CALL registrar_venta(9, 5, 5);

-- Vendemos 50 laptops, pero solo hay 10 disponibles (rollback)
CALL registrar_venta(1, 50, 1);

-- Vendemos 100 monitores, pero solo hay 7 disponibles (rollback)
CALL registrar_venta(4, 100, 4);

-- Vendemos 40 auriculares, pero solo quedan 25 disponibles (rollback)
CALL registrar_venta(9, 40, 5);

-- 6) Consultar el total de ventas del mes anterior (el join se encuentra en la vista generada para esto)
SELECT * FROM m5_evalmod.tr_venta WHERE MONTH(fecha_transaccion) = (MONTH(now()) - 1);