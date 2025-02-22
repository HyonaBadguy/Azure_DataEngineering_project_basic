# Azure Data Engineering Pipeline: Real-Time Analytics Project  
Este proyecto demuestra un pipeline de datos integral en Azure, diseñado para analizar datos demográficos de clientes y tendencias de ventas en tiempo real.

## Descripción  
La solución extrae datos de clientes y ventas de una base de datos SQL local, los procesa en Azure y genera insights accionables mediante un dashboard de Power BI. Los análisis incluyen distribución de ventas por género, desempeño de categorías de productos y filtros por fecha, categoría y género.

### Objetivos del Negocio  
1. **Visualizar tendencias de ventas**: Por género y categoría de producto (unidades vendidas e ingresos).  
2. **Filtrado dinámico**: Permitir selección por fecha, categoría y género.  
3. **Dashboard intuitivo**: Acceso en tiempo real para stakeholders.  

## Arquitectura  
1. **Ingesta de Datos**:  
   - Azure Data Factory (ADF) extrae datos de SQL Server y los carga en Azure Data Lake Storage (ADLS).  
2. **Procesamiento**:  
   - Azure Databricks transforma los datos en capas estructuradas:  
     - **Bronce**: Datos crudos.  
     - **Plata**: Datos limpios y validados.  
     - **Oro**: Métricas agregadas para reportes.  
3. **Analítica y Visualización**:  
   - Azure Synapse Analytics almacena los datos procesados.  
   - Power BI se conecta a Synapse para crear dashboards interactivos.  
4. **Automatización**:  
   - Ejecución diaria del pipeline mediante programación en ADF.  

## Herramientas Utilizadas  
- **Movimiento de Datos**: Azure Data Factory  
- **Almacenamiento**: Azure Data Lake Storage (ADLS)  
- **Procesamiento**: Azure Databricks  
- **Almacén de Datos**: Azure Synapse Analytics  
- **Visualización**: Power BI  
- **Seguridad**: Azure Key Vault, Entra ID  

## Implementación  

### 1. Configuración en Azure  
- Crear un grupo de recursos con:  
  - ADF, ADLS (contenedores `bronze`, `silver`, `gold`), Databricks, Synapse y Key Vault.  

### 2. Pipeline de Datos  
- **Ingesta**: Usar ADF para copiar datos de SQL Server a ADLS `bronze`.  
- **Transformación**:  
  - Montar ADLS en Databricks.  
  - Desarrollar notebooks para limpiar datos (`bronze` → `silver`) y agregar métricas (`silver` → `gold`).  
- **Reportes**:  
  - Cargar datos de la capa `gold` en Synapse.  
  - Construir dashboards en Power BI con filtros interactivos.  

### 3. Automatización y Seguridad  
- Programar pipelines en ADF para actualizaciones diarias.  
- Configurar acceso por roles con Entra ID.  
