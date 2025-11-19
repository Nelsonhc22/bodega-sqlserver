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

