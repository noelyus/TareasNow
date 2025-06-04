-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 26-05-2025 a las 17:27:02
-- Versión del servidor: 10.4.28-MariaDB
-- Versión de PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `tfg_db`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `agregar_alumnos_a_asignaturas` (`p_id_alumno` INT, `p_id_asignatura` INT)   BEGIN
    INSERT INTO usuariosxasignaturas (id, id_asignatura, id_usuario)
    VALUES (NULL, p_id_asignatura, p_id_alumno);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `completar_tareas` (IN `p_id_tarea` INT, IN `p_id_alumno` INT, IN `p_comentarioA` TEXT)   BEGIN
    INSERT INTO entregas_completas (id, id_entrega, id_usuario, fecha_entrega, ComentarioAlumno, Comentarioprofesor, nota )
    VALUES (NULL, p_id_tarea, p_id_alumno, NOW(), p_comentarioA, NULL, NULL);
Delete from tareas_incompletas where id_tarea = p_id_tarea and id_usuario = p_id_alumno;
Select id, id_entrega, id_usuario, fecha_entrega, ComentarioAlumno from entregas_completas
where id_usuario = p_id_alumno AND id_entrega = p_id_tarea;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `creador_tareas` (IN `p_titulo` VARCHAR(255), IN `p_descripcion` VARCHAR(1000), IN `p_fecha_limite` DATETIME, IN `p_id_asignatura` INT, IN `p_id_creador` INT)  COMMENT 'formatoFecha(YYYY-MM-DD HH:MM:SS)' BEGIN
    INSERT INTO tarea (descripcion, fecha_limite, id, id_asignatura, id_creador, titulo)
    VALUES (p_descripcion, p_fecha_limite, NULL, p_id_asignatura, p_id_creador, p_titulo);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_tareas` (IN `p_id_tarea` INT)   BEGIN
    delete from archivos where id_tarea = p_id_tarea;
    delete from archivos_entregas where id_tarea = p_id_tarea;
    DELETE FROM tareasasign WHERE id_tarea = p_id_tarea;
    DELETE FROM entregas_completas WHERE id_entrega = p_id_tarea;
    DELETE FROM tareas_incompletas WHERE id_tarea = p_id_tarea;
    DELETE FROM tarea WHERE id = p_id_tarea;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `incluir_notas` (IN `p_id_tarea` INT, IN `p_id_alumno` INT, IN `p_nota` INT)   BEGIN
    update  entregas_completas set nota = p_nota where id_usuario = p_id_alumno and id_entrega = p_id_tarea;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `incluir_usuarios_a_tareas_incompletas` (IN `p_id_asignatura` INT(6), IN `p_id_tarea` INT(5), IN `p_id_creador` INT)   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_id_usuario INT;

    DECLARE c CURSOR FOR
        SELECT id_usuario FROM usuariosxasignaturas WHERE id_asignatura = p_id_asignatura;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN c;

    leer_loop: LOOP
        FETCH c INTO v_id_usuario;
        IF done THEN
            LEAVE leer_loop;
        END IF;

        INSERT INTO tareas_incompletas (id, id_tarea, id_usuario)
        VALUES (NULL, p_id_tarea, v_id_usuario);
    END LOOP;
INSERT INTO tareasasign (id, id_creador, id_usuario, id_tarea) values (NULL, p_id_creador, v_id_usuario, p_id_tarea);
    CLOSE c;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `aplicacionesxcurso`
--

CREATE TABLE `aplicacionesxcurso` (
  `id` int(11) NOT NULL,
  `id_aplicacion` int(11) NOT NULL,
  `id_curso` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `aplicacionesxcurso`
--

INSERT INTO `aplicacionesxcurso` (`id`, `id_aplicacion`, `id_curso`) VALUES
(5, 3, 5),
(6, 4, 5),
(7, 5, 7),
(9, 3, 7),
(10, 4, 7);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `aplicaciones_disp`
--

CREATE TABLE `aplicaciones_disp` (
  `id` int(11) NOT NULL,
  `imagen_id` int(11) NOT NULL,
  `nombre` varchar(30) NOT NULL,
  `descripcion` varchar(50) NOT NULL,
  `ruta_icono` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `aplicaciones_disp`
--

INSERT INTO `aplicaciones_disp` (`id`, `imagen_id`, `nombre`, `descripcion`, `ruta_icono`) VALUES
(3, 3, 'LIbreOffice', 'Aplicacion con paquete de editor de texto , presen', '../assets/images/libre_office_logo-2481654439.png'),
(4, 2, 'Zoom', 'Aplicacion para videoconferencias en tiempo real', '../assets/images/zoom.jpg'),
(5, 1, 'VisualStudioCode', 'Aplicacion para edicion de codigo', '../assets/images/vscode.png');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `archivos`
--

CREATE TABLE `archivos` (
  `id` int(11) NOT NULL,
  `id_tarea` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `ruta` varchar(200) NOT NULL,
  `nombre` varchar(65) NOT NULL,
  `id_tipo` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `archivos_entregas`
--

CREATE TABLE `archivos_entregas` (
  `id` int(11) NOT NULL,
  `id_entrega` int(11) DEFAULT NULL,
  `id_tipo` int(11) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `nombre` varchar(70) DEFAULT NULL,
  `ruta` varchar(100) DEFAULT NULL,
  `id_tarea` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `archivos_tareas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `archivos_tareas` (
`id` int(11)
,`id_tarea` int(11)
,`id_usuario` int(11)
,`nombre` varchar(65)
,`ruta` varchar(200)
,`tipo` varchar(25)
,`titulo_tarea` varchar(50)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asignatura`
--

CREATE TABLE `asignatura` (
  `id` int(11) NOT NULL,
  `nombre` varchar(45) DEFAULT NULL,
  `id_curso` int(11) DEFAULT NULL,
  `id_profesor` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `asignatura`
--

INSERT INTO `asignatura` (`id`, `nombre`, `id_curso`, `id_profesor`) VALUES
(7, 'Programacion', 7, 2),
(8, 'Redes ', 5, 2);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `asignaturasasign`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `asignaturasasign` (
`nombre` varchar(50)
,`id_usuario` int(11)
,`tipo` varchar(15)
,`asignatura` varchar(45)
,`id_asignatura` int(11)
,`id_profesor` int(11)
,`curso` varchar(60)
,`nivel` int(11)
,`id_curso` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `asignaturas_cursos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `asignaturas_cursos` (
`nombre_curso` varchar(60)
,`nivel` int(11)
,`id_curso` int(11)
,`asignatura_nombre` varchar(45)
,`id_profesor` int(11)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `curso`
--

CREATE TABLE `curso` (
  `id` int(11) NOT NULL,
  `nombre` varchar(60) DEFAULT NULL,
  `nivel` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `curso`
--

INSERT INTO `curso` (`id`, `nombre`, `nivel`) VALUES
(5, 'Administracion de Sistemas Informaticos en Red', 1),
(6, 'Administracion de Sistemas Informaticos en Red', 2),
(7, 'Desarrollo de Aplicaciones Multiplataforma', 1),
(8, 'Desarrollo de Aplicaciones Multiplataforma', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entregas_completas`
--

CREATE TABLE `entregas_completas` (
  `id` int(11) NOT NULL,
  `id_entrega` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `nota` int(11) DEFAULT NULL,
  `fecha_entrega` datetime NOT NULL,
  `ComentarioAlumno` text DEFAULT NULL,
  `Comentarioprofesor` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `imagenes`
--

CREATE TABLE `imagenes` (
  `id` int(11) NOT NULL,
  `nombre` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `imagenes`
--

INSERT INTO `imagenes` (`id`, `nombre`) VALUES
(1, 'vscodevnc-img'),
(2, 'zoomvnc-img'),
(3, 'libreofficevnc-img');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `profesores_asignaturas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `profesores_asignaturas` (
`id_profesor` int(11)
,`nombre_profesor` varchar(50)
,`nombre_asignatura` varchar(45)
,`id_asignatura` int(11)
,`nombre_curso` varchar(60)
,`nivel_curso` int(11)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles_usuarios`
--

CREATE TABLE `roles_usuarios` (
  `id` int(11) NOT NULL,
  `tipo` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `roles_usuarios`
--

INSERT INTO `roles_usuarios` (`id`, `tipo`) VALUES
(1, 'alumno'),
(2, 'profesor'),
(3, 'admin');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sesiones_stream`
--

CREATE TABLE `sesiones_stream` (
  `id` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `ip_usuario` varchar(19) NOT NULL,
  `app` varchar(35) NOT NULL,
  `estado` varchar(12) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tarea`
--

CREATE TABLE `tarea` (
  `id` int(11) NOT NULL,
  `titulo` varchar(50) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `id_creador` int(11) DEFAULT NULL,
  `id_asignatura` int(11) DEFAULT NULL,
  `fecha_limite` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `tarea`
--
DELIMITER $$
CREATE TRIGGER `detector_tareas_nuevas` AFTER INSERT ON `tarea` FOR EACH ROW BEGIN
    CALL incluir_usuarios_a_tareas_incompletas(NEW.id_asignatura, NEW.id, NEW.id_creador);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tareasasign`
--

CREATE TABLE `tareasasign` (
  `id` int(11) NOT NULL,
  `id_creador` int(11) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_tarea` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tareas_incompletas`
--

CREATE TABLE `tareas_incompletas` (
  `id` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_tarea` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `tareas_puntuadas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `tareas_puntuadas` (
`nombre_alumno` varchar(50)
,`id_usuario` int(11)
,`id_tarea` int(11)
,`titulo` varchar(50)
,`nota` int(11)
,`fecha_entrega` datetime
,`nombre_asignatura` varchar(45)
,`id_asignatura` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `tareas_puntuadas_profesor`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `tareas_puntuadas_profesor` (
`id_alumno` int(11)
,`nombre_alumno` varchar(50)
,`correo_alumno` varchar(75)
,`id_tarea` int(11)
,`nombre_tarea` varchar(50)
,`nota` int(11)
,`id_entregado` int(11)
,`id_profesor` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `tareas_sin_puntuar`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `tareas_sin_puntuar` (
`id_alumno` int(11)
,`nombre_alumno` varchar(50)
,`correo_alumno` varchar(75)
,`id_tarea` int(11)
,`nombre_tarea` varchar(50)
,`nota` int(11)
,`id_entregado` int(11)
,`id_profesor` int(11)
,`id_asignatura` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `tareas_sin_terminar`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `tareas_sin_terminar` (
`id_entrega_incompleta` int(11)
,`id_tarea` int(11)
,`id_de_alumno` int(11)
,`nombre_alumno` varchar(50)
,`fecha_limite` datetime
,`id_creador` int(11)
,`titulo_tarea` varchar(50)
,`nombre_asignatura` varchar(45)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipos_archivos`
--

CREATE TABLE `tipos_archivos` (
  `id` int(11) NOT NULL,
  `tipo` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipos_archivos`
--

INSERT INTO `tipos_archivos` (`id`, `tipo`) VALUES
(1, 'pdf'),
(3, 'jpg'),
(4, 'mp3'),
(5, 'ogg'),
(6, 'mp4'),
(7, 'webm');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id` int(11) NOT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `correo` varchar(75) DEFAULT NULL,
  `id_rol` int(11) DEFAULT NULL,
  `contrasenia` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id`, `nombre`, `correo`, `id_rol`, `contrasenia`) VALUES
(1, 'Alumno', 'alumno@prueba', 1, '1'),
(2, 'Profesor', 'profe@prueba', 2, '1'),
(3, 'Admin', 'admin@prueba', 3, '1'),
(4, 'Noe', 'noe@noe', 1, '1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuariosxasignaturas`
--

CREATE TABLE `usuariosxasignaturas` (
  `id` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `id_asignatura` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuariosxasignaturas`
--

INSERT INTO `usuariosxasignaturas` (`id`, `id_usuario`, `id_asignatura`) VALUES
(7, 1, 7),
(8, 4, 8);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `usuarios_cursos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `usuarios_cursos` (
`id_curso` int(11)
,`nombre` varchar(50)
,`id_usuario` int(11)
,`curso` varchar(60)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `usuarios_x_aplicaciones`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `usuarios_x_aplicaciones` (
`id_aplicacion` int(11)
,`curso_id` int(11)
,`nombre_app` varchar(30)
,`id_imagen` int(11)
,`ruta_icono` varchar(250)
,`nombre_curso` varchar(60)
,`nivel` int(11)
,`nombre_usuario` varchar(50)
,`id_usuario` int(11)
,`id_rol` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_asignatura`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_asignatura` (
`id_asignatura` int(11)
,`nombre_asignatura` varchar(45)
,`id_curso` int(11)
,`nombre_curso` varchar(60)
,`nivel` int(11)
,`id_profesor` int(11)
,`nombre` varchar(50)
,`correo` varchar(75)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_tarea`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_tarea` (
`id_tarea` int(11)
,`id_asignatura` int(11)
,`titulo_tarea` varchar(50)
,`descripcion` text
,`fecha_limite` datetime
,`asignatura` varchar(45)
,`curso` varchar(60)
,`nivel_curso` int(11)
,`creador_tarea` varchar(50)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_archivos_entregas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_archivos_entregas` (
`id_de_archivo` int(11)
,`id_entrega` int(11)
,`extension` varchar(25)
,`id_alumno` int(11)
,`nombre_alumno` varchar(50)
,`nombre_archivo` varchar(70)
,`ruta_archivo` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_tareas_terminadas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_tareas_terminadas` (
`nombre_alumno` varchar(50)
,`id_usuario` int(11)
,`id_tarea` int(11)
,`titulo` varchar(50)
,`id_entrega_completa` int(11)
,`nota` int(11)
,`fecha_entrega` datetime
,`Comentarioalumno` text
,`Comentarioprofesor` text
,`nombre_asignatura` varchar(45)
,`id_asignatura` int(11)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `archivos_tareas`
--
DROP TABLE IF EXISTS `archivos_tareas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `archivos_tareas`  AS SELECT `a`.`id` AS `id`, `a`.`id_tarea` AS `id_tarea`, `a`.`id_usuario` AS `id_usuario`, `a`.`nombre` AS `nombre`, `a`.`ruta` AS `ruta`, `e`.`tipo` AS `tipo`, `t`.`titulo` AS `titulo_tarea` FROM ((`archivos` `a` join `tipos_archivos` `e` on(`a`.`id_tipo` = `e`.`id`)) join `tarea` `t` on(`a`.`id_tarea` = `t`.`id`)) ORDER BY `a`.`id_tarea` ASC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `asignaturasasign`
--
DROP TABLE IF EXISTS `asignaturasasign`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `asignaturasasign`  AS SELECT `u`.`nombre` AS `nombre`, `u`.`id` AS `id_usuario`, `r`.`tipo` AS `tipo`, `a`.`nombre` AS `asignatura`, `a`.`id` AS `id_asignatura`, `a`.`id_profesor` AS `id_profesor`, `c`.`nombre` AS `curso`, `c`.`nivel` AS `nivel`, `c`.`id` AS `id_curso` FROM ((((`usuario` `u` join `usuariosxasignaturas` `h` on(`u`.`id` = `h`.`id_usuario`)) join `roles_usuarios` `r` on(`u`.`id_rol` = `r`.`id`)) join `asignatura` `a` on(`a`.`id` = `h`.`id_asignatura`)) join `curso` `c` on(`a`.`id_curso` = `c`.`id`)) ORDER BY `u`.`id` ASC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `asignaturas_cursos`
--
DROP TABLE IF EXISTS `asignaturas_cursos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `asignaturas_cursos`  AS SELECT `c`.`nombre` AS `nombre_curso`, `c`.`nivel` AS `nivel`, `c`.`id` AS `id_curso`, `a`.`nombre` AS `asignatura_nombre`, `a`.`id_profesor` AS `id_profesor` FROM (`curso` `c` join `asignatura` `a` on(`a`.`id_curso` = `c`.`id`)) ORDER BY `c`.`id` ASC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `profesores_asignaturas`
--
DROP TABLE IF EXISTS `profesores_asignaturas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `profesores_asignaturas`  AS SELECT `u`.`id` AS `id_profesor`, `u`.`nombre` AS `nombre_profesor`, `a`.`nombre` AS `nombre_asignatura`, `a`.`id` AS `id_asignatura`, `c`.`nombre` AS `nombre_curso`, `c`.`nivel` AS `nivel_curso` FROM ((`usuario` `u` join `asignatura` `a` on(`u`.`id` = `a`.`id_profesor`)) join `curso` `c` on(`a`.`id_curso` = `c`.`id`)) ORDER BY `u`.`id` ASC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `tareas_puntuadas`
--
DROP TABLE IF EXISTS `tareas_puntuadas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tareas_puntuadas`  AS SELECT `v_tareas_terminadas`.`nombre_alumno` AS `nombre_alumno`, `v_tareas_terminadas`.`id_usuario` AS `id_usuario`, `v_tareas_terminadas`.`id_tarea` AS `id_tarea`, `v_tareas_terminadas`.`titulo` AS `titulo`, `v_tareas_terminadas`.`nota` AS `nota`, `v_tareas_terminadas`.`fecha_entrega` AS `fecha_entrega`, `v_tareas_terminadas`.`nombre_asignatura` AS `nombre_asignatura`, `v_tareas_terminadas`.`id_asignatura` AS `id_asignatura` FROM `v_tareas_terminadas` WHERE `v_tareas_terminadas`.`nota` is not null ;

-- --------------------------------------------------------

--
-- Estructura para la vista `tareas_puntuadas_profesor`
--
DROP TABLE IF EXISTS `tareas_puntuadas_profesor`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tareas_puntuadas_profesor`  AS SELECT `s`.`id_usuario` AS `id_alumno`, `u`.`nombre` AS `nombre_alumno`, `u`.`correo` AS `correo_alumno`, `s`.`id_entrega` AS `id_tarea`, `t`.`titulo` AS `nombre_tarea`, `s`.`nota` AS `nota`, `s`.`id` AS `id_entregado`, `t`.`id_creador` AS `id_profesor` FROM ((`entregas_completas` `s` join `tarea` `t` on(`s`.`id_entrega` = `t`.`id`)) join `usuario` `u` on(`s`.`id_usuario` = `u`.`id`)) WHERE `s`.`nota` is not null ;

-- --------------------------------------------------------

--
-- Estructura para la vista `tareas_sin_puntuar`
--
DROP TABLE IF EXISTS `tareas_sin_puntuar`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tareas_sin_puntuar`  AS SELECT `s`.`id_usuario` AS `id_alumno`, `u`.`nombre` AS `nombre_alumno`, `u`.`correo` AS `correo_alumno`, `s`.`id_entrega` AS `id_tarea`, `t`.`titulo` AS `nombre_tarea`, `s`.`nota` AS `nota`, `s`.`id` AS `id_entregado`, `t`.`id_creador` AS `id_profesor`, `t`.`id_asignatura` AS `id_asignatura` FROM ((`entregas_completas` `s` join `tarea` `t` on(`s`.`id_entrega` = `t`.`id`)) join `usuario` `u` on(`s`.`id_usuario` = `u`.`id`)) WHERE `s`.`nota` is null ;

-- --------------------------------------------------------

--
-- Estructura para la vista `tareas_sin_terminar`
--
DROP TABLE IF EXISTS `tareas_sin_terminar`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tareas_sin_terminar`  AS SELECT `i`.`id` AS `id_entrega_incompleta`, `i`.`id_tarea` AS `id_tarea`, `i`.`id_usuario` AS `id_de_alumno`, `u`.`nombre` AS `nombre_alumno`, `t`.`fecha_limite` AS `fecha_limite`, `t`.`id_creador` AS `id_creador`, `t`.`titulo` AS `titulo_tarea`, `a`.`nombre` AS `nombre_asignatura` FROM (((`tareas_incompletas` `i` join `usuario` `u` on(`i`.`id_usuario` = `u`.`id`)) join `tarea` `t` on(`i`.`id_tarea` = `t`.`id`)) join `asignatura` `a` on(`t`.`id_asignatura` = `a`.`id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `usuarios_cursos`
--
DROP TABLE IF EXISTS `usuarios_cursos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `usuarios_cursos`  AS SELECT DISTINCT `asignaturasasign`.`id_curso` AS `id_curso`, `asignaturasasign`.`nombre` AS `nombre`, `asignaturasasign`.`id_usuario` AS `id_usuario`, `asignaturasasign`.`curso` AS `curso` FROM `asignaturasasign` ORDER BY `asignaturasasign`.`id_usuario` ASC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `usuarios_x_aplicaciones`
--
DROP TABLE IF EXISTS `usuarios_x_aplicaciones`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `usuarios_x_aplicaciones`  AS SELECT `a`.`id` AS `id_aplicacion`, `c`.`id` AS `curso_id`, `a`.`nombre` AS `nombre_app`, `a`.`imagen_id` AS `id_imagen`, `a`.`ruta_icono` AS `ruta_icono`, `c`.`nombre` AS `nombre_curso`, `c`.`nivel` AS `nivel`, `u`.`nombre` AS `nombre_usuario`, `u`.`id` AS `id_usuario`, `u`.`id_rol` AS `id_rol` FROM ((((`aplicaciones_disp` `a` join `aplicacionesxcurso` `x` on(`x`.`id_aplicacion` = `a`.`id`)) join `curso` `c` on(`x`.`id_curso` = `c`.`id`)) join `usuarios_cursos` `h` on(`h`.`id_curso` = `c`.`id`)) join `usuario` `u` on(`h`.`id_usuario` = `u`.`id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_asignatura`
--
DROP TABLE IF EXISTS `vista_asignatura`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_asignatura`  AS SELECT `a`.`id` AS `id_asignatura`, `a`.`nombre` AS `nombre_asignatura`, `a`.`id_curso` AS `id_curso`, `c`.`nombre` AS `nombre_curso`, `c`.`nivel` AS `nivel`, `a`.`id_profesor` AS `id_profesor`, `u`.`nombre` AS `nombre`, `u`.`correo` AS `correo` FROM ((`asignatura` `a` join `curso` `c` on(`a`.`id_curso` = `c`.`id`)) join `usuario` `u` on(`a`.`id_profesor` = `u`.`id`)) ORDER BY `a`.`id` ASC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_tarea`
--
DROP TABLE IF EXISTS `vista_tarea`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_tarea`  AS SELECT `t`.`id` AS `id_tarea`, `t`.`id_asignatura` AS `id_asignatura`, `t`.`titulo` AS `titulo_tarea`, `t`.`descripcion` AS `descripcion`, `t`.`fecha_limite` AS `fecha_limite`, `a`.`nombre` AS `asignatura`, `c`.`nombre` AS `curso`, `c`.`nivel` AS `nivel_curso`, `u`.`nombre` AS `creador_tarea` FROM (((`tarea` `t` join `asignatura` `a` on(`t`.`id_asignatura` = `a`.`id`)) join `curso` `c` on(`a`.`id_curso` = `c`.`id`)) join `usuario` `u` on(`t`.`id_creador` = `u`.`id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_archivos_entregas`
--
DROP TABLE IF EXISTS `v_archivos_entregas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_archivos_entregas`  AS SELECT `a`.`id` AS `id_de_archivo`, `a`.`id_entrega` AS `id_entrega`, `t`.`tipo` AS `extension`, `a`.`id_usuario` AS `id_alumno`, `u`.`nombre` AS `nombre_alumno`, `a`.`nombre` AS `nombre_archivo`, `a`.`ruta` AS `ruta_archivo` FROM ((`archivos_entregas` `a` join `tipos_archivos` `t` on(`a`.`id_tipo` = `t`.`id`)) join `usuario` `u` on(`a`.`id_usuario` = `u`.`id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_tareas_terminadas`
--
DROP TABLE IF EXISTS `v_tareas_terminadas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_tareas_terminadas`  AS SELECT `u`.`nombre` AS `nombre_alumno`, `u`.`id` AS `id_usuario`, `t`.`id` AS `id_tarea`, `t`.`titulo` AS `titulo`, `e`.`id` AS `id_entrega_completa`, `e`.`nota` AS `nota`, `e`.`fecha_entrega` AS `fecha_entrega`, `e`.`ComentarioAlumno` AS `Comentarioalumno`, `e`.`Comentarioprofesor` AS `Comentarioprofesor`, `a`.`nombre` AS `nombre_asignatura`, `a`.`id` AS `id_asignatura` FROM (((`usuario` `u` join `entregas_completas` `e` on(`u`.`id` = `e`.`id_usuario`)) join `tarea` `t` on(`t`.`id` = `e`.`id_entrega`)) join `asignatura` `a` on(`a`.`id` = `t`.`id_asignatura`)) ORDER BY `u`.`id` ASC ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `aplicacionesxcurso`
--
ALTER TABLE `aplicacionesxcurso`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_aplicacion` (`id_aplicacion`),
  ADD KEY `id_curso` (`id_curso`);

--
-- Indices de la tabla `aplicaciones_disp`
--
ALTER TABLE `aplicaciones_disp`
  ADD PRIMARY KEY (`id`),
  ADD KEY `imagen_id` (`imagen_id`);

--
-- Indices de la tabla `archivos`
--
ALTER TABLE `archivos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_entrega` (`id_tarea`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_tipo` (`id_tipo`);

--
-- Indices de la tabla `archivos_entregas`
--
ALTER TABLE `archivos_entregas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_tipo` (`id_tipo`),
  ADD KEY `id_entrega` (`id_entrega`),
  ADD KEY `id_tarea` (`id_tarea`);

--
-- Indices de la tabla `asignatura`
--
ALTER TABLE `asignatura`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_curso` (`id_curso`),
  ADD KEY `id_profesor` (`id_profesor`);

--
-- Indices de la tabla `curso`
--
ALTER TABLE `curso`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `entregas_completas`
--
ALTER TABLE `entregas_completas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_entrega` (`id_entrega`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `imagenes`
--
ALTER TABLE `imagenes`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `roles_usuarios`
--
ALTER TABLE `roles_usuarios`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `sesiones_stream`
--
ALTER TABLE `sesiones_stream`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `tarea`
--
ALTER TABLE `tarea`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_creador` (`id_creador`),
  ADD KEY `id_asignatura` (`id_asignatura`);

--
-- Indices de la tabla `tareasasign`
--
ALTER TABLE `tareasasign`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_creador` (`id_creador`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_tarea` (`id_tarea`);

--
-- Indices de la tabla `tareas_incompletas`
--
ALTER TABLE `tareas_incompletas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_entrega` (`id_tarea`);

--
-- Indices de la tabla `tipos_archivos`
--
ALTER TABLE `tipos_archivos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_rol` (`id_rol`);

--
-- Indices de la tabla `usuariosxasignaturas`
--
ALTER TABLE `usuariosxasignaturas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_asignatura` (`id_asignatura`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `aplicacionesxcurso`
--
ALTER TABLE `aplicacionesxcurso`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `aplicaciones_disp`
--
ALTER TABLE `aplicaciones_disp`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `archivos`
--
ALTER TABLE `archivos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `archivos_entregas`
--
ALTER TABLE `archivos_entregas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT de la tabla `asignatura`
--
ALTER TABLE `asignatura`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `curso`
--
ALTER TABLE `curso`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `entregas_completas`
--
ALTER TABLE `entregas_completas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT de la tabla `imagenes`
--
ALTER TABLE `imagenes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `sesiones_stream`
--
ALTER TABLE `sesiones_stream`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tarea`
--
ALTER TABLE `tarea`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=90;

--
-- AUTO_INCREMENT de la tabla `tareasasign`
--
ALTER TABLE `tareasasign`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT de la tabla `tareas_incompletas`
--
ALTER TABLE `tareas_incompletas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- AUTO_INCREMENT de la tabla `tipos_archivos`
--
ALTER TABLE `tipos_archivos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `usuariosxasignaturas`
--
ALTER TABLE `usuariosxasignaturas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `aplicacionesxcurso`
--
ALTER TABLE `aplicacionesxcurso`
  ADD CONSTRAINT `aplicacionesxcurso_ibfk_2` FOREIGN KEY (`id_aplicacion`) REFERENCES `aplicaciones_disp` (`id`),
  ADD CONSTRAINT `aplicacionesxcurso_ibfk_3` FOREIGN KEY (`id_curso`) REFERENCES `curso` (`id`);

--
-- Filtros para la tabla `aplicaciones_disp`
--
ALTER TABLE `aplicaciones_disp`
  ADD CONSTRAINT `aplicaciones_disp_ibfk_1` FOREIGN KEY (`imagen_id`) REFERENCES `imagenes` (`id`);

--
-- Filtros para la tabla `archivos`
--
ALTER TABLE `archivos`
  ADD CONSTRAINT `archivos_ibfk_3` FOREIGN KEY (`id_tipo`) REFERENCES `tipos_archivos` (`id`),
  ADD CONSTRAINT `archivos_ibfk_4` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id`),
  ADD CONSTRAINT `archivos_ibfk_5` FOREIGN KEY (`id_tarea`) REFERENCES `tarea` (`id`);

--
-- Filtros para la tabla `archivos_entregas`
--
ALTER TABLE `archivos_entregas`
  ADD CONSTRAINT `archivos_entregas_ibfk_1` FOREIGN KEY (`id_entrega`) REFERENCES `entregas_completas` (`id`),
  ADD CONSTRAINT `archivos_entregas_ibfk_2` FOREIGN KEY (`id_tipo`) REFERENCES `tipos_archivos` (`id`),
  ADD CONSTRAINT `archivos_entregas_ibfk_3` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id`),
  ADD CONSTRAINT `archivos_entregas_ibfk_4` FOREIGN KEY (`id_tarea`) REFERENCES `tarea` (`id`);

--
-- Filtros para la tabla `asignatura`
--
ALTER TABLE `asignatura`
  ADD CONSTRAINT `asignatura_ibfk_1` FOREIGN KEY (`id_profesor`) REFERENCES `usuario` (`id`),
  ADD CONSTRAINT `asignatura_ibfk_2` FOREIGN KEY (`id_curso`) REFERENCES `curso` (`id`);

--
-- Filtros para la tabla `entregas_completas`
--
ALTER TABLE `entregas_completas`
  ADD CONSTRAINT `entregas_completas_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id`),
  ADD CONSTRAINT `entregas_completas_ibfk_2` FOREIGN KEY (`id_entrega`) REFERENCES `tarea` (`id`);

--
-- Filtros para la tabla `sesiones_stream`
--
ALTER TABLE `sesiones_stream`
  ADD CONSTRAINT `sesiones_stream_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id`);

--
-- Filtros para la tabla `tarea`
--
ALTER TABLE `tarea`
  ADD CONSTRAINT `tarea_ibfk_1` FOREIGN KEY (`id_creador`) REFERENCES `usuario` (`id`),
  ADD CONSTRAINT `tarea_ibfk_2` FOREIGN KEY (`id_asignatura`) REFERENCES `asignatura` (`id`);

--
-- Filtros para la tabla `tareasasign`
--
ALTER TABLE `tareasasign`
  ADD CONSTRAINT `tareasasign_ibfk_1` FOREIGN KEY (`id_tarea`) REFERENCES `tarea` (`id`),
  ADD CONSTRAINT `tareasasign_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id`),
  ADD CONSTRAINT `tareasasign_ibfk_3` FOREIGN KEY (`id_creador`) REFERENCES `usuario` (`id`);

--
-- Filtros para la tabla `tareas_incompletas`
--
ALTER TABLE `tareas_incompletas`
  ADD CONSTRAINT `tareas_incompletas_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id`),
  ADD CONSTRAINT `tareas_incompletas_ibfk_2` FOREIGN KEY (`id_tarea`) REFERENCES `tarea` (`id`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`id_rol`) REFERENCES `roles_usuarios` (`id`);

--
-- Filtros para la tabla `usuariosxasignaturas`
--
ALTER TABLE `usuariosxasignaturas`
  ADD CONSTRAINT `usuariosxasignaturas_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id`),
  ADD CONSTRAINT `usuariosxasignaturas_ibfk_2` FOREIGN KEY (`id_asignatura`) REFERENCES `asignatura` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
