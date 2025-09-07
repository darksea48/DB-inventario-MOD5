# Sistema de Gestión de Inventario con MySQL

Este proyecto es una implementación de una base de datos en MySQL diseñada para gestionar un sistema de inventario, incluyendo productos, proveedores y transacciones de compra/venta. La lógica principal del negocio, como la actualización de stock y la validación de ventas, se maneja directamente en la base de datos a través de **Triggers** y **Procedimientos Almacenados** para garantizar la máxima integridad y rendimiento.

## 🎯 Objetivo

El propósito del sistema es administrar de manera integral el inventario de productos, las relaciones con proveedores y las transacciones, manteniendo el stock actualizado en tiempo real y previniendo inconsistencias en los datos, como vender productos sin existencias.

## ✨ Características Principales

  * **Gestión de Catálogos:** Permite registrar y administrar productos y proveedores de forma centralizada.
  * **Control de Transacciones:** Registra todas las operaciones de compra y venta, manteniendo un historial completo de movimientos.
  * **Automatización de Stock:** Un trigger actualiza la cantidad de productos en inventario automáticamente después de cada transacción.
  * **Validación de Ventas:** Un procedimiento almacenado valida la disponibilidad de stock antes de confirmar una venta. Si no hay suficientes existencias, la operación se anula (`ROLLBACK`).
  * **Consultas Simplificadas:** Utiliza Vistas SQL para ofrecer acceso rápido al estado del inventario y al historial detallado de transacciones.

## 📂 Esquema de la Base de Datos

El modelo se organiza en torno a las transacciones, que conectan los productos y los proveedores.

**Tablas Principales:**

  * `productos`: Catálogo de productos.
  * `cantidad_productos`: Stock disponible para cada producto.
  * `proveedores`: Información de los proveedores.
  * `tipo_transaccion`: Define si un movimiento es 'Compra' o 'Venta'.
  * `transacciones`: Historial de todas las compras y ventas.

**Diagrama de Relaciones Lógicas:**

```
[proveedores] 1--* [transacciones] *--1 [productos]
                          |               |
                          *--1 [tipo_transaccion]
                                          |
                                          *--1 [cantidad_productos]
```

## ⚙️ Lógica de Negocio y Automatización

La inteligencia del sistema reside en la propia base de datos, lo que garantiza que las reglas de negocio se apliquen sin importar desde qué aplicación se consuman los datos.

### Triggers

1.  **`productos_AFTER_INSERT`**:

      * **Evento:** Se dispara después de insertar un nuevo producto en la tabla `productos`.
      * **Acción:** Crea automáticamente una entrada en `cantidad_productos` para el nuevo producto, estableciendo su stock inicial en `0`.

2.  **`transacciones_AFTER_INSERT`**:

      * **Evento:** Se dispara después de registrar cualquier movimiento en la tabla `transacciones`.
      * **Acción:** Verifica si la transacción es una compra (`tipo = 1`) o una venta (`tipo = 2`) y actualiza el stock en `cantidad_productos`, sumando o restando la cantidad correspondiente.

### Procedimientos Almacenados

1.  **`registrar_compra(p_producto_id, p_cantidad, p_proveedor_id)`**:

      * **Propósito:** Encapsula la lógica para registrar una compra de productos.
      * **Acción:** Inserta un nuevo registro en la tabla `transacciones` con `tipo = 1`. El trigger `transacciones_AFTER_INSERT` se encarga de actualizar el stock.

2.  **`registrar_venta(p_producto_id, p_cantidad, p_proveedor_id)`**:

      * **Propósito:** Gestiona la venta de productos de forma segura.
      * **Acción:**
        1.  Inicia una transacción.
        2.  Verifica si la `cantidad` en `cantidad_productos` para el `p_producto_id` es suficiente.
        3.  **Si hay stock:** Inserta el registro en la tabla `transacciones` con `tipo = 2` y confirma la operación (`COMMIT`). El trigger se encarga de descontar el stock.
        4.  **Si no hay stock:** Cancela toda la operación (`ROLLBACK`) y lanza un error, evitando así la venta.

## 🚀 Cómo Empezar

### Prerrequisitos

  * Tener un servidor de MySQL o MariaDB en ejecución.
  * Una herramienta para gestionar la base de datos, como MySQL Workbench, DBeaver, o la línea de comandos de `mysql`.

### Instalación

1.  Clona este repositorio o descarga el archivo `sql_DDL_query.txt`.
2.  Conéctate a tu servidor de base de datos.
3.  Ejecuta el script `sql_DDL_query.txt` completo. Esto creará la base de datos `m5_evalmod`, las tablas, vistas, triggers y procedimientos almacenados.

## 📋 Ejemplos de Uso

Una vez que la base de datos esté configurada y tengas algunos productos y proveedores, puedes gestionar el inventario llamando a los procedimientos almacenados.

### Registrar una Compra

Para registrar la compra de 50 unidades del producto con `id = 1` al proveedor con `id = 1`:

```sql
CALL registrar_compra(1, 50, 1);
```

### Registrar una Venta

Para registrar la venta de 5 unidades del producto con `id = 1` (asumiremos que el `proveedor_id` en este contexto puede representar un cliente o punto de venta):

```sql
CALL registrar_venta(1, 5, 1);
```

*Si intentas vender más unidades de las que hay en stock, la base de datos devolverá un error y la transacción no se registrará.*

### Consultar el Inventario

Para ver el stock actual de todos los productos, puedes usar la vista `inventario`:

```sql
SELECT * FROM inventario;
```

### Consultar Historial de Transacciones

Para ver un historial legible de todos los movimientos:

```sql
SELECT * FROM tr_todas;
```
