# Guía de Configuración y Ejecución de un Pipeline de Datos en Azure

## Parte 1 – Configuración del Entorno

### Configuración de Azure
1. **Crear una cuenta nueva**: Usa un correo nuevo para obtener 30 días gratis con $200 de crédito.
2. **Crear un Grupo de Recursos (RG)**.
3. **Crear una Factoría de Datos (ADF)**.
4. **Crear una Cuenta de Almacenamiento**: Crear un contenedor llamado `bronze`.
5. **Crear Databricks**: Se crea automáticamente un RG para los recursos subyacentes.
6. **Crear Synapse**:
   - El nombre de la cuenta es el nombre de la cuenta de almacenamiento.
   - Si no aparece en la suscripción, configúralo manualmente mediante la URL y el nombre de la cuenta de almacenamiento.
   - **Nota**: Al configurar un workspace en Azure Synapse y seleccionar un sistema de archivos de Data Lake Storage Gen2, el "Nombre del sistema de archivos" es crucial. Actúa como un contenedor dentro de tu cuenta de almacenamiento donde se almacenan datos, logs y salidas de trabajos.
   - Elige un nombre relevante y significativo para el sistema de archivos.
7. **Crear Key Vault (KV)**.

### Configuración de SQL On-Prem
1. **Descargar SQL Server**.
2. **Descargar SSMS (SQL Server Management Studio)**.
   - Si no funciona, usa SQL Server Configuration Manager y ejecuta el servicio.
3. **Descargar AdventureWorks**.
4. **Mover la base de datos**: Copia la base de datos a `C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Backup`.
5. **Restaurar la base de datos**.
6. **Crear un script de inicio de sesión**: Ejecuta el script en la base de datos correcta y asigna permisos al usuario.
7. **Crear un secreto en Key Vault**: Almacena el nombre de usuario y la contraseña.
   - **Problema común**: "The operation is not allowed by RBAC".
   - **Solución**:
     1. En el Grupo de Recursos, ve a "Access Control (IAM)" -> "Add role assignment" -> Busca "Key Vault Administrator" y asigna el rol.
     2. Verifica el acceso en "View my access".
     3. Intenta crear el secreto nuevamente.

### Configuración de Power BI
1. **Descargar Power BI** desde Microsoft Store.
2. **Crear una cuenta de Office 365** si no tienes una.
3. **Alternativa**: Usar Power BI en Synapse si no tienes Windows.

---

## Parte 2 – Ingestión de Datos con ADF

### Conexión a SQL On-Prem
1. **Instalar Integration Runtime**: Configura un runtime autoalojado para conectar la máquina local con Azure.
2. **Crear un pipeline en ADF**:
   - Usa una actividad de copia de datos para conectar la base de datos local con Azure.
   - Configura el origen (SQL Server) y el destino (Azure Storage).
   - Usa Key Vault para autenticación.
3. **Problemas comunes**:
   - **Error de autenticación**: Cambia la autenticación del servidor en SSMS a "SQL Server and Windows Authentication".
   - **Error de certificado HTTPS**: Asegúrate de que la opción "Encrypt" sea opcional.

### Copia de Datos Masiva
1. **Crear un pipeline para copiar todas las tablas**:
   - Usa una actividad de búsqueda para listar todas las tablas en el esquema `SalesLT`.
   - Usa un bucle `foreach` para copiar cada tabla en formato Parquet.
   - Guarda los archivos en la estructura `bronze/Schema/Tablename/Tablename.parquet`.

---

## Parte 3 – Transformación de Datos con Databricks

### Montaje del Data Lake
1. **Crear un clúster en Databricks**.
2. **Montar el contenedor de Azure Storage**:
   - Usa el siguiente código para montar el contenedor `bronze`:
     ```python
     configs = {
       "fs.azure.account.auth.type": "CustomAccessToken",
       "fs.azure.account.custom.token.provider.class": spark.conf.get("spark.databricks.passthrough.adls.gen2.tokenProviderClassName")
     }
     dbutils.fs.mount(
       source = "abfss://<container-name>@<storage-account-name>.dfs.core.windows.net/",
       mount_point = "/mnt/<mount-name>",
       extra_configs = configs)
     ```
3. **Verificar el montaje**: Usa `dbutils.fs.ls("/mnt/bronze")` para confirmar.

### Transformación de Datos (Bronze a Silver)
1. **Crear un notebook en Databricks** para transformar los datos de `bronze` a `silver`.
2. **Cambiar tipos de datos**: Por ejemplo, convertir `ModifiedDate` a tipo fecha.
3. **Guardar en formato Delta**: Usa Delta Lake para manejar cambios de esquema y versiones.

### Transformación de Datos (Silver a Gold)
1. **Unir y agregar datos**: Crea tablas finales de hechos y dimensiones.
2. **Cambiar nombres de columnas**: Convierte nombres de PascalCase a snake_case.
3. **Modularizar el código**: Crea funciones reutilizables para transformaciones comunes.

---

## Parte 4 – Carga de Datos con Synapse Analytics

### Creación de una Base de Datos
1. **Crear una base de datos en Synapse**:
   - Usa un grupo de SQL sin servidor (serverless) para consultas ligeras.
   - Crea vistas sobre los datos en el Data Lake.

### Automatización con Pipelines
1. **Crear un pipeline en Synapse**:
   - Usa una actividad de procedimiento almacenado para crear vistas dinámicamente.
   - Configura permisos en el Data Lake para permitir el acceso desde Synapse.

---

## Parte 5 – Reportes con Power BI

### Conexión a Synapse
1. **Conectar Power BI a Synapse**:
   - Usa el endpoint de SQL sin servidor para importar datos.
   - Crea relaciones entre tablas para un análisis coherente.

### Creación de Visualizaciones
1. **Crear tarjetas y gráficos**:
   - Usa campos como `ProductID` para contar productos.
   - Usa `LineTotal` para mostrar ventas totales.
2. **Agregar filtros**: Usa segmentaciones para filtrar datos por categoría o género.

---

## Parte 6 – Seguridad y Gobierno con Entra ID

### Gestión de Accesos
1. **Crear un grupo de seguridad en Entra ID**:
   - Agrega miembros y asigna roles en IAM.
   - Usa grupos para gestionar permisos de manera eficiente.

---

## Parte 7 – Pruebas de Pipeline

### Automatización de Ejecución
1. **Configurar un trigger en ADF**:
   - Programa la ejecución del pipeline diariamente.
2. **Actualizar datos en SQL Server**:
   - Inserta nuevos registros en las tablas.
3. **Verificar actualizaciones en Power BI**:
   - Refresca los informes para ver los cambios.

---

## Eliminación de Recursos
1. **Eliminar el Grupo de Recursos**: Borra todos los recursos creados en Azure.
2. **Eliminar grupos de AD**: Limpia los grupos de seguridad si ya no son necesarios.