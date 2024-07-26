
duckdb -c "
INSTALL httpfs;
LOAD httpfs;
COPY (
    SELECT 
        column01 as Price, 
        CAST(column02 as Date) as TransferDate, 
        column03 as PostCode, 
        column11 as Town, 
        column12 as District, 
        column13 as County,
        CASE column06 
            WHEN 'F' THEN 'Free'
            WHEN 'L' THEN 'Lease'
            ELSE NULL END AS Duration,
        CASE column04
            WHEN 'D' THEN 'Detached'
            WHEN 'S' THEN 'Semi'
            WHEN 'T' THEN 'Terraced'
            WHEN 'F' THEN 'Flats'
            WHEN 'O' THEN 'Other'
            ELSE NULL END AS PropertyType, 
        CASE column05
            WHEN 'Y' THEN true
            WHEN 'N' THEN false 
            ELSE NULL END AS NewBuild,
        CASE column14
            WHEN 'A' THEN 'std'
            WHEN 'B' THEN 'add'
            ELSE NULL END AS Category,
    FROM read_csv('http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-complete.csv',
    header = false)
    -- Order by date for compression
    ORDER BY TransferDate, Price, Category, NewBuild, PropertyType, Duration
    ) to STDOUT (
    FORMAT PARQUET, 
    COMPRESSION ZSTD, 
    ROW_GROUP_SIZE 1_000_000
    );"