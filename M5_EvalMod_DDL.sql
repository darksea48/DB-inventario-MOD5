-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema m5_evalmod
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema m5_evalmod
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `m5_evalmod` DEFAULT CHARACTER SET utf8mb3 ;
USE `m5_evalmod` ;

-- -----------------------------------------------------
-- Table `m5_evalmod`.`productos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `m5_evalmod`.`productos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `descripcion` MEDIUMTEXT NOT NULL,
  `precio` INT UNSIGNED NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `m5_evalmod`.`cantidad_productos`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `m5_evalmod`.`cantidad_productos` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `producto_id` INT NOT NULL,
  `cantidad` INT UNSIGNED NOT NULL DEFAULT '0',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `producto_id_UNIQUE` (`producto_id` ASC) VISIBLE,
  INDEX `fk_inventario_productos_idx` (`producto_id` ASC) INVISIBLE,
  CONSTRAINT `fk_inventario_productos`
    FOREIGN KEY (`producto_id`)
    REFERENCES `m5_evalmod`.`productos` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `m5_evalmod`.`proveedores`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `m5_evalmod`.`proveedores` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(100) NOT NULL,
  `direccion` VARCHAR(255) NOT NULL,
  `telefono` VARCHAR(20) NULL DEFAULT NULL,
  `email` VARCHAR(255) NULL DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `m5_evalmod`.`tipo_transaccion`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `m5_evalmod`.`tipo_transaccion` (
  `id_tipo` INT NOT NULL AUTO_INCREMENT,
  `transaccion` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id_tipo`))
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8mb3;

INSERT INTO tipo_transaccion (transaccion) VALUES
('Compra'),
('Venta');

-- -----------------------------------------------------
-- Table `m5_evalmod`.`transacciones`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `m5_evalmod`.`transacciones` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `tipo` INT NOT NULL,
  `fecha_transaccion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `producto_id` INT NOT NULL,
  `cantidad` INT UNSIGNED NOT NULL,
  `proveedor_id` INT NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `fk_transacciones_tipo_transaccion1_idx` (`tipo` ASC) VISIBLE,
  INDEX `fk_transacciones_proveedores1_idx` (`proveedor_id` ASC) VISIBLE,
  INDEX `fk_transacciones_productos1_idx` (`producto_id` ASC) VISIBLE,
  CONSTRAINT `fk_transacciones_productos1`
    FOREIGN KEY (`producto_id`)
    REFERENCES `m5_evalmod`.`productos` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_transacciones_proveedores1`
    FOREIGN KEY (`proveedor_id`)
    REFERENCES `m5_evalmod`.`proveedores` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_transacciones_tipo_transaccion1`
    FOREIGN KEY (`tipo`)
    REFERENCES `m5_evalmod`.`tipo_transaccion` (`id_tipo`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8mb3;

USE `m5_evalmod` ;

-- -----------------------------------------------------
-- Placeholder table for view `m5_evalmod`.`inventario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `m5_evalmod`.`inventario` (`id` INT, `nombre_prod` INT, `descripcion_prod` INT, `precio` INT, `stock` INT);

-- -----------------------------------------------------
-- Placeholder table for view `m5_evalmod`.`tr_compra`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `m5_evalmod`.`tr_compra` (`id` INT, `transaccion` INT, `fecha_transaccion` INT, `producto` INT, `proveedor` INT, `cantidad` INT);

-- -----------------------------------------------------
-- Placeholder table for view `m5_evalmod`.`tr_todas`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `m5_evalmod`.`tr_todas` (`id` INT, `transaccion` INT, `fecha_transaccion` INT, `producto` INT, `proveedor` INT, `cantidad` INT);

-- -----------------------------------------------------
-- Placeholder table for view `m5_evalmod`.`tr_venta`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `m5_evalmod`.`tr_venta` (`id` INT, `transaccion` INT, `fecha_transaccion` INT, `producto` INT, `proveedor` INT, `cantidad` INT);

-- -----------------------------------------------------
-- procedure registrar_compra
-- -----------------------------------------------------

DELIMITER $$
USE `m5_evalmod`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_compra`(
    IN p_producto_id INT,
    IN p_cantidad INT,
    IN p_proveedor_id INT
)
BEGIN
    -- Iniciamos la transacción
    START TRANSACTION;

    -- Insertar compra en transacciones (tipo = 1 → Compra)
    INSERT INTO transacciones (tipo, producto_id, cantidad, proveedor_id)
    VALUES (1, p_producto_id, p_cantidad, p_proveedor_id);

    -- Confirmar operación
    COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure registrar_venta
-- -----------------------------------------------------

DELIMITER $$
USE `m5_evalmod`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_venta`(
    IN p_producto_id INT,
    IN p_cantidad INT,
    IN p_proveedor_id INT
)
BEGIN
    DECLARE v_stock INT;

    -- Iniciamos la transacción
    START TRANSACTION;

    -- Verificar stock actual con bloqueo (FOR UPDATE)
    SELECT cantidad
    INTO v_stock
    FROM cantidad_productos
    WHERE producto_id = p_producto_id
    FOR UPDATE;

    -- Validar si hay stock suficiente
    IF v_stock >= p_cantidad THEN
        -- Insertar venta en transacciones (tipo = 2 → Venta)
        INSERT INTO transacciones (tipo, producto_id, cantidad, proveedor_id)
        VALUES (2, p_producto_id, p_cantidad, p_proveedor_id);

        -- Confirmar operación
        COMMIT;
    ELSE
        -- No hay suficiente stock → revertir
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Stock insuficiente para realizar la venta';
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- View `m5_evalmod`.`inventario`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `m5_evalmod`.`inventario`;
USE `m5_evalmod`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `m5_evalmod`.`inventario` AS select `m5_evalmod`.`productos`.`id` AS `id`,`m5_evalmod`.`productos`.`nombre` AS `nombre_prod`,`m5_evalmod`.`productos`.`descripcion` AS `descripcion_prod`,`m5_evalmod`.`productos`.`precio` AS `precio`,`m5_evalmod`.`cantidad_productos`.`cantidad` AS `stock` from (`m5_evalmod`.`productos` left join `m5_evalmod`.`cantidad_productos` on((`m5_evalmod`.`productos`.`id` = `m5_evalmod`.`cantidad_productos`.`producto_id`)));

-- -----------------------------------------------------
-- View `m5_evalmod`.`tr_compra`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `m5_evalmod`.`tr_compra`;
USE `m5_evalmod`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `m5_evalmod`.`tr_compra` AS select `m5_evalmod`.`transacciones`.`id` AS `id`,`m5_evalmod`.`tipo_transaccion`.`transaccion` AS `transaccion`,`m5_evalmod`.`transacciones`.`fecha_transaccion` AS `fecha_transaccion`,`m5_evalmod`.`productos`.`nombre` AS `producto`,`m5_evalmod`.`proveedores`.`nombre` AS `proveedor`,`m5_evalmod`.`transacciones`.`cantidad` AS `cantidad` from (((`m5_evalmod`.`transacciones` join `m5_evalmod`.`tipo_transaccion` on((`m5_evalmod`.`transacciones`.`tipo` = `m5_evalmod`.`tipo_transaccion`.`id_tipo`))) join `m5_evalmod`.`productos` on((`m5_evalmod`.`productos`.`id` = `m5_evalmod`.`transacciones`.`producto_id`))) join `m5_evalmod`.`proveedores` on((`m5_evalmod`.`proveedores`.`id` = `m5_evalmod`.`transacciones`.`proveedor_id`))) where (`m5_evalmod`.`tipo_transaccion`.`id_tipo` = 1);

-- -----------------------------------------------------
-- View `m5_evalmod`.`tr_todas`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `m5_evalmod`.`tr_todas`;
USE `m5_evalmod`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `m5_evalmod`.`tr_todas` AS select `m5_evalmod`.`transacciones`.`id` AS `id`,`m5_evalmod`.`tipo_transaccion`.`transaccion` AS `transaccion`,`m5_evalmod`.`transacciones`.`fecha_transaccion` AS `fecha_transaccion`,`m5_evalmod`.`productos`.`nombre` AS `producto`,`m5_evalmod`.`proveedores`.`nombre` AS `proveedor`,`m5_evalmod`.`transacciones`.`cantidad` AS `cantidad` from (((`m5_evalmod`.`transacciones` join `m5_evalmod`.`tipo_transaccion` on((`m5_evalmod`.`transacciones`.`tipo` = `m5_evalmod`.`tipo_transaccion`.`id_tipo`))) join `m5_evalmod`.`productos` on((`m5_evalmod`.`productos`.`id` = `m5_evalmod`.`transacciones`.`producto_id`))) join `m5_evalmod`.`proveedores` on((`m5_evalmod`.`proveedores`.`id` = `m5_evalmod`.`transacciones`.`proveedor_id`)));

-- -----------------------------------------------------
-- View `m5_evalmod`.`tr_venta`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `m5_evalmod`.`tr_venta`;
USE `m5_evalmod`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `m5_evalmod`.`tr_venta` AS select `m5_evalmod`.`transacciones`.`id` AS `id`,`m5_evalmod`.`tipo_transaccion`.`transaccion` AS `transaccion`,`m5_evalmod`.`transacciones`.`fecha_transaccion` AS `fecha_transaccion`,`m5_evalmod`.`productos`.`nombre` AS `producto`,`m5_evalmod`.`proveedores`.`nombre` AS `proveedor`,`m5_evalmod`.`transacciones`.`cantidad` AS `cantidad`, (`productos`.`precio` * `transacciones`.`cantidad`) AS `valor_total` from (((`m5_evalmod`.`transacciones` join `m5_evalmod`.`tipo_transaccion` on((`m5_evalmod`.`transacciones`.`tipo` = `m5_evalmod`.`tipo_transaccion`.`id_tipo`))) join `m5_evalmod`.`productos` on((`m5_evalmod`.`productos`.`id` = `m5_evalmod`.`transacciones`.`producto_id`))) join `m5_evalmod`.`proveedores` on((`m5_evalmod`.`proveedores`.`id` = `m5_evalmod`.`transacciones`.`proveedor_id`))) where (`m5_evalmod`.`tipo_transaccion`.`id_tipo` = 2);
USE `m5_evalmod`;

DELIMITER $$
USE `m5_evalmod`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `m5_evalmod`.`productos_AFTER_INSERT`
AFTER INSERT ON `m5_evalmod`.`productos`
FOR EACH ROW
BEGIN
	INSERT INTO cantidad_productos (producto_id) VALUES (NEW.id);
END$$

USE `m5_evalmod`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `m5_evalmod`.`transacciones_AFTER_INSERT`
AFTER INSERT ON `m5_evalmod`.`transacciones`
FOR EACH ROW
BEGIN
	DECLARE tipo_trans INT;

    -- Obtener el nombre del tipo de transacción
    SELECT id_tipo INTO tipo_trans
    FROM tipo_transaccion
    WHERE id_tipo = NEW.tipo;

    -- Si es Compra → sumar
    IF tipo_trans = 1 THEN
        UPDATE cantidad_productos
        SET cantidad = cantidad + NEW.cantidad
        WHERE producto_id = NEW.producto_id;
    END IF;

    -- Si es Venta → restar
    IF tipo_trans = 2 THEN
        UPDATE cantidad_productos
        SET cantidad = cantidad - NEW.cantidad
        WHERE producto_id = NEW.producto_id;
    END IF;
END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
