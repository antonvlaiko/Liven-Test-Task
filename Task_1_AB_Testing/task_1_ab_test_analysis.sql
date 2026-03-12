SELECT 
    split_group,
    system,
    
    -- Унікальні користувачі
    COUNT(DISTINCT id_user) AS Total_users,
    
    -- Усі спроби оплат (успішні та відхилені)
    COUNT(CASE WHEN successful_payment IN (0, 1) THEN id_user END) AS Total_transactions_attempts, 
    
    -- Успішні транзакції
    COUNT(CASE WHEN successful_payment = 1 THEN id_user END) AS Successful_transactions,
    
    -- Унікальні платники
    COUNT(DISTINCT CASE WHEN successful_payment = 1 THEN id_user END) AS Paying_users,
    
    -- Загальний дохід (Revenue)
    SUM(CASE WHEN successful_payment = 1 THEN amount ELSE 0 END) AS Total_revenue,
    
    -- Середній дохід на одного користувача (ARPU)
    SUM(CASE WHEN successful_payment = 1 THEN amount ELSE 0 END) / COUNT(DISTINCT id_user) AS ARPU,
        
    -- Середній дохід на одного платника (ARPPU)
    SUM(CASE WHEN successful_payment = 1 THEN amount ELSE 0 END) / 
        NULLIF(COUNT(DISTINCT CASE WHEN successful_payment = 1 THEN id_user END), 0) AS ARPPU,
        
    -- Максимальний платіж
    MAX(CASE WHEN successful_payment = 1 THEN amount END) AS Max_payment,
    
    -- Мінімальний платіж
    MIN(CASE WHEN successful_payment = 1 THEN amount END) AS Min_payment,
    
    -- Середній платіж (Середній чек)
    AVG(CASE WHEN successful_payment = 1 THEN amount END) AS Avg_payment,
    
    -- Медіанний платіж
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CASE WHEN successful_payment = 1 THEN amount END) AS Median_payment

FROM raw_data
-- Фільтрація цільової аудиторії тесту
WHERE date_reg >= '2021-07-24' 
  AND platform = 'mobile' 
  AND system IN ('Android', 'iOS')
-- Групування за групою тесту та ОС
GROUP BY 
    split_group, 
    system
ORDER BY 
    system, 
    split_group;
