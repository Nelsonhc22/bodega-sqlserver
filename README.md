Base de Datos Bodega - SQL Server

Sistema de gestión de inventario desarrollado como proyecto académico en SQL Server, con procedimientos almacenados y sistema de auditoría automática.

📋 Descripción del Proyecto

Este proyecto implementa un sistema completo de gestión de inventario para una bodega, desarrollado como parte de la asignatura de Administración de Bases de Datos. El sistema permite registrar productos, procesar pedidos y mantener un historial completo de todas las operaciones realizadas.

Características principales:
- ✅ Base de datos relacional con integridad referencial
- ✅ Procedimientos almacenados con validaciones de negocio
- ✅ Sistema de auditoría automática mediante triggers
- ✅ Control de inventario en tiempo real
- ✅ Consultas analíticas sobre base de datos Northwind

---

🎯 Objetivos del Proyecto

Objetivo General
Desarrollar una base de datos funcional en SQL Server que permita gestionar eficientemente el inventario de una bodega, demostrando competencias en diseño de bases de datos relacionales, programación de procedimientos almacenados y consultas SQL avanzadas.

### Objetivos Específicos

1. Diseñar la estructura de base de datos
   - Crear tablas con relaciones apropiadas
   - Implementar claves primarias y foráneas
   - Establecer restricciones de integridad

2. Desarrollar procedimientos almacenados
   - Validar datos antes de insertarlos
   - Controlar el inventario automáticamente
   - Manejar errores con mensajes informativos

3. Implementar sistema de auditoría
   - Registrar todas las operaciones realizadas
   - Capturar usuario, fecha y acción ejecutada
   - Facilitar el rastreo de cambios

4. Realizar consultas analíticas
   - Aplicar joins entre múltiples tablas
   - Utilizar funciones de agregación
   - Filtrar y ordenar datos eficientemente


🛠️ Tecnologías Utilizadas

- **SQL Server** (versión 2016 o superior)
- **SQL Server Management Studio (SSMS)** - Entorno de desarrollo
- **T-SQL** - Lenguaje de consultas y procedimientos
- **Git/GitHub** - Control de versiones

📁 Estructura del Repositorio
```
bodega-sqlserver/
│
├── Paso1_Base_y_Tablas_SSMS.sql       # Creación de BD y tablas
├── Paso2_Procedimientos.sql            # Procedimientos almacenados
├── Paso3_Trigger_Bitacora.sql          # Sistema de auditoría
├── Paso4_Consultas_Northwind.sql       # Consultas analíticas
├── Documento_Objetivos_y_Conexion.md   # Documentación técnica
└── README.md                           # Este archivo
```
---
🗃️ Estructura de la Base de Datos

Tabla PRODUCTO
Almacena la información de los productos disponibles en inventario.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| idprod | CHAR(7) | Código único del producto (PK) |
| descripcion | VARCHAR(25) | Nombre descriptivo del producto |
| existencias | INT | Cantidad disponible en inventario |
| precio | DECIMAL(10,2) | Precio de costo del producto |
| previo | DECIMAL(10,2) | Precio de venta al público |
| ganancia | CALCULADO | Margen de ganancia (previo - precio) |

Restricciones: El precio de venta debe ser mayor al precio de costo.

Tabla PEDIDO
Registra los pedidos realizados por los clientes.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| idpedido | CHAR(7) | Identificador único del pedido |
| idprod | CHAR(7) | Código del producto solicitado (FK) |
| cantidad | INT | Número de unidades pedidas |

Relaciones: Llave foránea hacia la tabla PRODUCTO.

Tabla BITACORA
Mantiene un registro histórico de todas las operaciones.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | INT IDENTITY | Identificador autoincremental (PK) |
| Accion | VARCHAR(50) | Tipo de operación (Insertar/Actualizar/Eliminar) |
| usuario | VARCHAR(100) | Usuario que realizó la operación |
| Fecha | DATETIME | Fecha y hora exacta de la operación |
| Producto | VARCHAR(100) | Producto afectado por la operación |
## 🔧 Funcionalidades Implementadas

Procedimientos Almacenados

 sp_InsertarProducto
Permite insertar nuevos productos validando que no existan duplicados por código o nombre.

Parámetros:
- `@idprod` - Código del producto
- `@descripcion` - Nombre del producto
- `@existencias` - Cantidad inicial
- `@precio` - Precio de costo
- `@previo` - Precio de venta

Ejemplo de uso:
```sql
EXEC sp_InsertarProducto 'PROD001', 'Laptop HP', 10, 500.00, 750.00
```

Validaciones:
- ✅ Verifica que el código no exista
- ✅ Verifica que el nombre no esté duplicado
- ✅ Muestra mensajes de error apropiados

 sp_RealizarPedido
Procesa pedidos de productos verificando disponibilidad de stock y actualizando inventario automáticamente.

Parámetros:
- `@idpedido` - Identificador del pedido
- `@idprod` - Código del producto
- `@cantidad` - Unidades solicitadas

Ejemplo de uso:
```sql
EXEC sp_RealizarPedido 'PED001', 'PROD001', 2
```

Validaciones:
- ✅ Verifica que el producto exista
- ✅ Verifica stock suficiente
- ✅ Actualiza existencias automáticamente
- ✅ Registra el pedido en la tabla PEDIDO

### Sistema de Auditoría

El trigger `tr_Auditoria_Producto` se ejecuta automáticamente después de cualquier operación INSERT, UPDATE o DELETE sobre la tabla PRODUCTO.

Funcionalidad:
- Captura el tipo de operación realizada
- Registra el usuario del sistema que ejecutó la operación
- Almacena fecha y hora exacta
- Guarda el nombre del producto afectado

Consultar el historial:
```sql
SELECT * FROM BITACORA ORDER BY Fecha DESC
```


 📊 Consultas Analíticas (Northwind)

El proyecto incluye consultas avanzadas sobre la base de datos de ejemplo Northwind:

1. **Productos por categoría:** Cuenta el número de productos en cada categoría
2. **Detalle de ventas:** Muestra vendedor, fecha, producto y cantidad vendida
3. **Top vendedores:** Lista vendedores con ventas superiores a $100,000


Como ejecutamos el Paso4_Consultas_Northwind.sql 

Nosotros para ejecutar las consultas instalamos la base de datos Northwind y la descargamos de el script oficial de Microsoft:
https://raw.githubusercontent.com/microsoft/sql-server-samples/master/samples/databases/northwind-pubs/instnwnd.sql

creamos la base de datos:
   CREATE DATABASE Northwind
   GO

y ejecutamos el script descargado en la base de datos Northwind para luego ejecutar el archivo nuevo agregado de  `Paso4_Consultas_Northwind.sql`


# Taller 2: Procedimientos, Triggers y Consultas Analíticas


## 📋 Requisitos Previos

Antes de ejecutar este taller, **DEBES tener completado el Taller 1**:

### Taller 1 debe incluir:
- ✅ Base de datos `TiendaGrupo` creada
- ✅ 5 tablas creadas:
  - Categorias
  - Productos
  - Clientes
  - Pedidos
  - DetallePedidos
- ✅ Datos de ejemplo insertados

**Script del Taller 1:** `base_tienda01.sql`

## 🚀 Cómo Ejecutar (Desde Cero)

### Paso 1: Ejecutar Taller 1 (si aún no lo has hecho)

```sql
-- Abre SQL Server Management Studio (SSMS)
-- File → Open → File
-- Selecciona: base_tienda01.sql
-- Presiona: F5 (o Ctrl+A y F5)
-- Espera a que termine (2 minutos aprox)
```

**Verifica que se creó correctamente:**
```sql
USE master;
SELECT name FROM sys.databases WHERE name = 'TiendaGrupo';
```

Si ves `TiendaGrupo` en el resultado, continúa al Paso 2.

---

### Paso 2: Ejecutar Script Principal (OBLIGATORIO)

**Archivo:** `Taller2-completo.sql`

```sql
-- Abre SQL Server Management Studio (SSMS)
-- File → Open → File
-- Selecciona: Taller2-completo.sql.sql
```

---

### Paso 3: Ejecutar Pruebas (RECOMENDADO)

**Archivo:** `Taller2-guia-pruebas.sql`


### Paso 4: Ejecutar Vistas (OPCIONAL)

**Archivo:** `Taller2Vistas.sql`

```sql
-- Abre SQL Server Management Studio (SSMS)
-- File → Open → File
-- Selecciona: Taller2Vistas.sql

---

## 📊 Contenido del Taller 2

### Procedimientos Almacenados

#### `sp_InsertarProducto`
Inserta un nuevo producto con validaciones:
```sql
EXEC dbo.sp_InsertarProducto 
    @p_Nombre = N'Producto Nuevo',
    @p_IdCategoria = 1,
    @p_Precio = 50.00,
    @p_Stock = 20;
```

**Validaciones:**
- No permite productos duplicados
- Verifica que la categoría exista
- Valida precio positivo
- Valida stock no negativo

#### `sp_RealizarPedido`
Realiza un pedido y actualiza automáticamente el stock:
```sql
EXEC dbo.sp_RealizarPedido 
    @p_IdCliente = 1,
    @p_IdProducto = 5,
    @p_Cantidad = 10;
```

**Validaciones:**
- Verifica que el producto exista
- Verifica que el cliente exista
- Valida stock suficiente
- Actualiza stock automáticamente

---

### Triggers de Auditoría

Se ejecutan automáticamente cuando:

1. **tr_Auditoria_Insert** - Se inserta un producto
2. **tr_Auditoria_Update** - Se actualiza un producto
3. **tr_Auditoria_Delete** - Se elimina un producto

Registran automáticamente en tabla `BITACORA`:
- Acción realizada
- Fecha y hora
- Usuario del sistema
- Nombre del producto

---

### Consultas Analíticas

#### 1. Productos por Categoría
```sql
SELECT 
    c.Nombre AS Categoria,
    COUNT(p.IdProducto) AS TotalProductos,
    SUM(p.Stock) AS StockTotal
FROM dbo.Categorias c
LEFT JOIN dbo.Productos p ON c.IdCategoria = p.IdCategoria
WHERE c.Activo = 1
GROUP BY c.Nombre
ORDER BY TotalProductos DESC;
```

#### 2. Detalles de Ventas
```sql
SELECT 
    cl.NombreCompleto AS Cliente,
    prod.Nombre AS Producto,
    dp.Cantidad,
    dp.PrecioUnitario
FROM dbo.Pedidos ped
INNER JOIN dbo.Clientes cl ON ped.IdCliente = cl.IdCliente
INNER JOIN dbo.DetallePedidos dp ON ped.IdPedido = dp.IdPedido
INNER JOIN dbo.Productos prod ON dp.IdProducto = prod.IdProducto
ORDER BY ped.FechaPedido DESC;
```

#### 3. Historial de Auditoría
```sql
SELECT 
    IdAuditoria,
    Accion,
    FechaAccion,
    Usuario,
    NombreProducto
FROM dbo.BITACORA
ORDER BY FechaAccion DESC;
```

---

### Vistas (Complementarias)

#### `vw_CategoriasProductos` (Kevin)
Muestra categorías con sus productos asociados.

#### `vw_ResumenInventario`
Resumen de inventario por categoría.

#### `vw_VentasPorCliente`
Resumen de ventas por cliente.

---


## ✅ Verificación de Éxito

Después de ejecutar TODO, verifica:

### 1. Tabla BITACORA existe
```sql
SELECT COUNT(*) FROM dbo.BITACORA;
```

### 2. Procedimientos existen
```sql
EXEC sp_InsertarProducto ...  -- Debe funcionar
EXEC sp_RealizarPedido ...    -- Debe funcionar
```

### 3. Triggers funcionan
```sql
-- Inserta un producto
EXEC dbo.sp_InsertarProducto @p_Nombre = N'Test', @p_IdCategoria = 1, @p_Precio = 10, @p_Stock = 5;

-- Verifica que se registró en BITACORA
SELECT * FROM dbo.BITACORA ORDER BY IdAuditoria DESC;
```

### 4. Consultas retornan datos
```sql
SELECT * FROM dbo.Categorias;  -- Debe mostrar datos
SELECT * FROM dbo.Productos;   -- Debe mostrar datos
SELECT * FROM dbo.Pedidos;     -- Puede estar vacío
```

---

## 📝 Notas Importantes

1. **Todo en una BD:** Ambos talleres usan la misma BD `TiendaGrupo`
2. **Sin modificaciones:** El Taller 2 NO modifica el Taller 1, solo agrega cosas nuevas
3. **Orden importante:** Ejecuta los scripts EN ORDEN (principal → pruebas → vistas)
4. **Triggers automáticos:** Se ejecutan sin que hagas nada especial
5. **Auditoría:** La tabla BITACORA crece con cada operación


