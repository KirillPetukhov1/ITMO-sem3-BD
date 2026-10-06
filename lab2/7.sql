/*
Вывести список студентов, имеющих одинаковые имена, но не совпадающие ид.
*/

SELECT л.ИД,
       л.ФАМИЛИЯ,
       л.ИМЯ,
       л.ОТЧЕСТВО
FROM Н_ЛЮДИ AS л
WHERE EXISTS (
    SELECT 1
    FROM Н_УЧЕНИКИ AS у
    WHERE у.ЧЛВК_ИД = л.ИД
)
AND EXISTS (
    SELECT 1
    FROM Н_ЛЮДИ AS другой
    WHERE другой.ИМЯ = л.ИМЯ
        AND другой.ИД <> л.ИД
        AND EXISTS (
            SELECT 1
            FROM Н_УЧЕНИКИ AS у2
            WHERE у2.ЧЛВК_ИД = другой.ИДs
        )
)
ORDER BY л.ИМЯ, л.ИД;