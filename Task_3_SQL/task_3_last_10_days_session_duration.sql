/*
1. Якщо сесія перетинає опівніч (open в один день, close в інший), весь час сесії зараховується до дати її початку (open_time). 
2. Сесії без події 'close' (NULL) ігноруються агрегатною функцією EXTRACT.
3. Назви колонок зведені статично, оскільки стандартний SQL не підтримує динамічні назви колонок на основі функцій дати.
*/

WITH session_time AS (
    -- Зведення подій open та close в один рядок для кожної сесії
    SELECT 
        id,
        id_user,
        MAX(CASE WHEN action = 'open' THEN date_action END) AS open_time,
        MAX(CASE WHEN action = 'close' THEN date_action END) AS close_time
    FROM users_sessions
    GROUP BY 
        id, 
        id_user
),

session_length_table AS (
    -- Розразунок тривалості у годинах та фільтрація останніх 10 днів
    SELECT 
        id_user,
        DATE(open_time) AS session_date, 
        EXTRACT(EPOCH FROM (close_time - open_time)) / 3600.0 AS session_hours -- EPOCH переводить весь інтервал у секунди, що уникає втрати хвилин
    FROM session_time
    WHERE DATE(open_time) >= CURRENT_DATE - INTERVAL '9 days' -- або CURRENT_DATE - 9
)

-- Звоедення днів у колонки через умовну агрегацію
SELECT 
    id_user, 
    SUM(CASE WHEN session_date = CURRENT_DATE - INTERVAL '9 days' THEN session_hours ELSE 0 END) AS day_minus_9,
    SUM(CASE WHEN session_date = CURRENT_DATE - INTERVAL '8 days' THEN session_hours ELSE 0 END) AS day_minus_8,
    SUM(CASE WHEN session_date = CURRENT_DATE - INTERVAL '7 days' THEN session_hours ELSE 0 END) AS day_minus_7,
    SUM(CASE WHEN session_date = CURRENT_DATE - INTERVAL '6 days' THEN session_hours ELSE 0 END) AS day_minus_6,
    SUM(CASE WHEN session_date = CURRENT_DATE - INTERVAL '5 days' THEN session_hours ELSE 0 END) AS day_minus_5,
    SUM(CASE WHEN session_date = CURRENT_DATE - INTERVAL '4 days' THEN session_hours ELSE 0 END) AS day_minus_4,
    SUM(CASE WHEN session_date = CURRENT_DATE - INTERVAL '3 days' THEN session_hours ELSE 0 END) AS day_minus_3,
    SUM(CASE WHEN session_date = CURRENT_DATE - INTERVAL '2 days' THEN session_hours ELSE 0 END) AS day_minus_2,
    SUM(CASE WHEN session_date = CURRENT_DATE - INTERVAL '1 day'  THEN session_hours ELSE 0 END) AS yesterday,
    SUM(CASE WHEN session_date = CURRENT_DATE THEN session_hours ELSE 0 END) AS today
FROM session_length_table
GROUP BY 
    id_user;
