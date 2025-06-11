-- Crear tabla de usuarios
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    usuario VARCHAR(50) UNIQUE NOT NULL,  -- El campo 'usuario' para identificar al usuario
    password VARCHAR(100) NOT NULL,       -- Contraseña (almacenada como hash seguro)
    
    -- Campos adicionales para completar la autenticacion
    is_active BOOLEAN DEFAULT TRUE,       -- Usuario activo (por defecto True)
    is_staff BOOLEAN DEFAULT FALSE,       -- ¿Es personal administrativo? (por defecto False)
    is_superuser BOOLEAN DEFAULT FALSE,   -- ¿Es superusuario? (por defecto False)
    
    -- Campos adicionales
    last_login TIMESTAMP,                 -- ultimo inicio de sesion
    date_joined TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Fecha en que el usuario se creo
    email VARCHAR(255) UNIQUE,            -- Correo electronico del usuario (opcional)
    
    CONSTRAINT email_check CHECK (email IS NULL OR email != '')
);

-- Crear tabla de sesiones (django_session)
CREATE TABLE django_session (
    session_key VARCHAR(40) PRIMARY KEY,
    session_data TEXT NOT NULL,
    expire_date TIMESTAMP NOT NULL
);

-- Crear tabla de datos
CREATE TABLE datos (
    id SERIAL PRIMARY KEY,
    tipo_registro VARCHAR(20) CHECK (tipo_registro IN ('mantenimiento', 'averia', 'consumo')) NOT NULL,
    kilometraje INTEGER NOT NULL,
    precio DECIMAL(10, 2),
    fecha DATE NOT NULL,
    detalles TEXT,
    usuario_id INTEGER NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Crear tabla de coches
CREATE TABLE coches (
    id SERIAL PRIMARY KEY,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    año INT CHECK (año BETWEEN 1900 AND 2025),
    motor VARCHAR(100),
    combustible VARCHAR(10) CHECK (combustible IN ('gasolina', 'diesel')),
    usuario_id INTEGER UNIQUE NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    
    -- Validacion básica para marcas populares (puedes omitir o ampliar esto segun motor)
    CHECK (marca IN (
        'Toyota', 'Ford', 'Volkswagen', 'Honda', 'Chevrolet', 'Nissan', 'BMW', 'Mercedes-Benz', 'Audi',
        'Hyundai', 'Kia', 'Peugeot', 'Renault', 'Fiat', 'Skoda', 'SEAT', 'Mazda', 'Subaru', 'Mitsubishi',
        'Tesla', 'Volvo', 'Jeep', 'Dodge', 'Ram', 'Chrysler', 'Buick', 'Cadillac', 'Lincoln', 'GMC',
        'Land Rover', 'Jaguar', 'Alfa Romeo', 'Maserati', 'Ferrari', 'Lamborghini', 'Porsche',
        'Aston Martin', 'Bentley', 'Rolls-Royce', 'Bugatti', 'McLaren', 'Lotus', 'Mini', 'Smart',
        'Citroën', 'DS Automobiles', 'Genesis', 'Infiniti', 'Acura', 'Daihatsu', 'Proton', 'Perodua',
        'Geely', 'Chery', 'BYD', 'NIO', 'Xpeng', 'Li Auto', 'Great Wall Motors', 'Haval', 'BAIC',
        'FAW', 'Hongqi', 'Roewe', 'MG (Morris Garages)', 'Lancia', 'Dacia', 'Tata Motors', 'Mahindra',
        'Maruti Suzuki', 'Scion', 'Pontiac', 'Saturn', 'Hummer', 'Daewoo', 'Oldsmobile', 'Isuzu',
        'Suzuki', 'Yugo', 'Zastava', 'Koenigsegg', 'Rimac', 'Fisker', 'Lucid Motors', 'Polestar',
        'Rivian', 'Ariel', 'Pagani', 'Spyker', 'Noble', 'De Tomaso', 'Saleen', 'Pininfarina',
        'SSC North America', 'Gumpert', 'Aptera', 'Bollinger Motors', 'Canoo', 'VinFast', 'Zenos',
        'Faraday Future', 'Rezvani', 'W Motors', 'TVR', 'Brilliance Auto', 'Luxgen', 'Togg',
        'Donkervoort', 'Hispano Suiza', 'Ginetta'
    ))
);

-- Insertar usuarios de prueba con contraseñas hasheadas
INSERT INTO usuarios (usuario, password, is_active, is_staff, is_superuser, email) VALUES
('juan', 'pbkdf2_sha256$1000000$tPElqMILDAAjL5e8boLnGe$e3K/g85W217Af31g9lwWvRHXr0vvDDOfd1+ZyBSlHno=', TRUE, FALSE, FALSE, 'juan@correo.com'),
('maria', 'pbkdf2_sha256$1000000$o28NgNUIGi9HEHiDWxuQpe$I8ZxxR8ogNPFA8mTlicaBiFABAXiJEASyrXWIGbDrG8=', TRUE, FALSE, FALSE, 'maria@correo.com');

-- Insertar datos para el usuario 'juan' (id = 1)
INSERT INTO datos (tipo_registro, kilometraje, precio, fecha, detalles, usuario_id) VALUES
('mantenimiento', 12000, 250.00, '2024-10-15', 'Cambio de aceite y filtro', 1),
('averia', 13500, 400.00, '2024-12-01', 'Fallo en el sistema de frenos', 1),
('consumo', 14000, 60.00, '2025-01-20', 'Llenado de combustible', 1);

-- Insertar datos para el usuario 'maria' (id = 2)
INSERT INTO datos (tipo_registro, kilometraje, precio, fecha, detalles, usuario_id) VALUES
('mantenimiento', 10000, 180.00, '2024-11-05', 'Revision general', 2),
('averia', 11000, 320.00, '2025-02-10', 'Problema en la caja de cambios', 2),
('consumo', 11500, 55.00, '2025-03-01', 'Repostaje en autopista', 2);

-- Insertar coche para Juan (usuario_id = 1)
INSERT INTO coches (marca, modelo, año, motor, combustible, usuario_id) VALUES
('Toyota', 'Corolla', 2020, '1.8L Hibrido', 'gasolina', 1);

-- Insertar coche para Maria (usuario_id = 2)
INSERT INTO coches (marca, modelo, año, motor, combustible, usuario_id) VALUES
('Volkswagen', 'Golf', 2019, '2.0 TDI', 'diesel', 2);