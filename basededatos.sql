-- ====================================================================
-- SCRIPT PARA CREAR LA BASE DE DATOS Y TABLAS DE TIENDA DE TECNOLOGÍA
-- ====================================================================
-- Elimina la base de datos si ya existe para empezar desde cero.
DROP DATABASE IF EXISTS tienda_tecnologia;

-- Crea la base de datos.
CREATE DATABASE tienda_tecnologia;

-- Selecciona la base de datos recién creada para trabajar sobre ella.
USE tienda_tecnologia;

-- ====================================================================
-- 1. CREACIÓN DE TABLAS (ORDENADAS POR DEPENDENCIA)
-- ====================================================================

-- Tabla de Categorías (no tiene dependencias)
CREATE TABLE Categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

-- Tabla de Clientes (no tiene dependencias)
CREATE TABLE Clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    fecha_registro DATE NOT NULL
);

-- Tabla de Productos (depende de Categorias)
CREATE TABLE Productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    categoria_id INT,
    FOREIGN KEY (categoria_id) REFERENCES Categorias(id) ON DELETE SET NULL
);

-- Tabla de Ventas (depende de Clientes)
CREATE TABLE Ventas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATETIME NOT NULL,
    cliente_id INT,
    total DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES Clientes(id) ON DELETE RESTRICT
);

-- Tabla de Detalle de Ventas (depende de Ventas y Productos)
-- Esta es una tabla intermedia para una relación muchos a muchos.
CREATE TABLE Detalle_Ventas (
    venta_id INT,
    producto_id INT,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (venta_id, producto_id), -- Clave primaria compuesta
    FOREIGN KEY (venta_id) REFERENCES Ventas(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES Productos(id) ON DELETE RESTRICT
);

-- ====================================================================
-- 2. INSERCIÓN DE DATOS DE EJEMPLO (ORDENADOS POR DEPENDENCIA)
-- ====================================================================

-- Insertar Categorías
INSERT INTO Categorias (nombre, descripcion) VALUES
('Laptops', 'Portátiles de alto rendimiento y para uso general.'),
('Smartphones', 'Teléfonos inteligentes de última generación.'),
('Periféricos', 'Teclados, ratones, webcams y más.'),
('Monitores', 'Monitores de alta resolución y para gaming.');

-- Insertar Clientes
INSERT INTO Clientes (nombre, apellido, email, telefono, fecha_registro) VALUES
('Ana', 'García', 'ana.garcia@email.com', '600111222', '2024-03-15'),
('Luis', 'Martínez', 'luis.martinez@email.com', '611222333', '2024-05-20'),
('Carla', 'Sánchez', 'carla.sanchez@email.com', '622333444', '2025-01-10');

-- Insertar Productos
INSERT INTO Productos (nombre, descripcion, precio, stock, categoria_id) VALUES
('Laptop Pro X1', 'Laptop de 15 pulgadas, 16GB RAM, 512GB SSD', 1200.00, 15, 1),
('Laptop Gamer G5', 'Laptop para gaming, RTX 4060, 144Hz', 1550.50, 10, 1),
('Smartphone Z', 'Pantalla OLED de 6.7 pulgadas, 128GB', 899.99, 30, 2),
('Teclado Mecánico RGB', 'Teclado con switches rojos y retroiluminación RGB', 85.00, 50, 3),
('Mouse Inalámbrico Ergo', 'Mouse ergonómico para largas horas de uso', 45.50, 60, 3),
('Monitor Curvo 27"', 'Monitor QHD 1440p de 27 pulgadas y 165Hz', 320.00, 25, 4);

-- Insertar Ventas
-- Nota: El total se calcula manualmente para este ejemplo. En un sistema real, esto podría ser
-- manejado por un trigger o por la lógica de la aplicación.
INSERT INTO Ventas (fecha, cliente_id, total) VALUES
('2025-05-15 10:30:00', 1, 1245.50), -- Ana compra una Laptop Pro X1 y un Mouse
('2025-05-22 14:00:00', 2, 899.99),  -- Luis compra un Smartphone Z
('2025-06-01 18:45:00', 1, 405.00);   -- Ana vuelve a comprar, un monitor y un teclado

-- Insertar Detalles de las Ventas
-- Venta 1 (ID=1)
INSERT INTO Detalle_Ventas (venta_id, producto_id, cantidad, precio_unitario) VALUES
(1, 1, 1, 1200.00), -- 1x Laptop Pro X1
(1, 5, 1, 45.50);   -- 1x Mouse Inalámbrico Ergo

-- Venta 2 (ID=2)
INSERT INTO Detalle_Ventas (venta_id, producto_id, cantidad, precio_unitario) VALUES
(2, 3, 1, 899.99); -- 1x Smartphone Z

-- Venta 3 (ID=3)
INSERT INTO Detalle_Ventas (venta_id, producto_id, cantidad, precio_unitario) VALUES
(3, 6, 1, 320.00), -- 1x Monitor Curvo 27"
(3, 4, 1, 85.00);   -- 1x Teclado Mecánico RGB


-- ====================================================================
-- SCRIPT FINALIZADO
-- Puedes probar con una consulta para verificar que todo funciona.
-- ====================================================================

-- Ejemplo de consulta: Ver los detalles de todas las ventas.
SELECT
    v.id AS venta_id,
    v.fecha,
    CONCAT(c.nombre, ' ', c.apellido) AS cliente,
    p.nombre AS producto,
    dv.cantidad,
    dv.precio_unitario
FROM Ventas v
JOIN Clientes c ON v.cliente_id = c.id
JOIN Detalle_Ventas dv ON v.id = dv.venta_id
JOIN Productos p ON dv.producto_id = p.id
ORDER BY v.id, p.nombre;
