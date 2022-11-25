1.
Посчитайте, сколько компаний закрылось.

SELECT COUNT(id)
FROM company
WHERE status LIKE 'closed';

2.
Отобразите количество привлечённых средств для новостных компаний США.
Используйте данные из таблицы company.
Отсортируйте таблицу по убыванию значений в поле funding_total.

SELECT funding_total      
FROM company
WHERE country_code LIKE 'USA'
      AND category_code LIKE 'news'
ORDER BY funding_total DESC;

3.
Найдите общую сумму сделок по покупке одних компаний другими в долларах.
Отберите сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.

SELECT SUM(price_amount)
FROM acquisition
WHERE EXTRACT(YEAR FROM acquired_at) BETWEEN 2011 AND 2013
      AND term_code LIKE 'cash';
      
4.
Отобразите имя, фамилию и названия аккаунтов людей в твиттере, у которых названия аккаунтов начинаются на 'Silver'.

SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';

5.
Выведите на экран всю информацию о людях, у которых названия аккаунтов в твиттере содержат подстроку 'money', а фамилия начинается на 'K'.

SELECT *
FROM people
WHERE twitter_username LIKE '%money%'
      AND last_name LIKE 'K%';
      
6.
Для каждой страны отобразите общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране.
Страну, в которой зарегистрирована компания, можно определить по коду страны.
Отсортируйте данные по убыванию суммы.

SELECT country_code,
       SUM(funding_total) AS sum_funding
FROM company
GROUP BY country_code
ORDER BY sum_funding DESC;

7.
Составьте таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату.
Оставьте в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.

SELECT funded_at,
       MIN(raised_amount) AS min_rasied,
       MAX(raised_amount) AS max_raised
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount) <> 0
       AND MIN(raised_amount) <> MAX(raised_amount);
       
8.
Создайте поле с категориями:
- Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.
- Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.
- Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.
Отобразите все поля таблицы fund и новое поле с категориями.

SELECT *,
       CASE
           WHEN invested_companies < 20 THEN 'low_activity'
           WHEN invested_companies >= 20 AND invested_companies < 100 THEN 'middle_activity'
           WHEN invested_companies >= 100 THEN 'high_activity'
       END
FROM fund;

9.
Для каждой из категорий, назначенных в предыдущем задании,
посчитайте округлённое до ближайшего целого числа среднее количество инвестиционных раундов, в которых фонд принимал участие.
Выведите на экран категории и среднее число инвестиционных раундов.
Отсортируйте таблицу по возрастанию среднего.

SELECT 
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity,
       ROUND(AVG(investment_rounds)) as average_rounds
FROM fund
GROUP BY activity
ORDER BY average_rounds;

10.
Проанализируйте, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы.
Для каждой страны посчитайте минимальное,максимальное и среднее число компаний, в которые инвестировали фонды этой страны,
основанные с 2010 по 2012 год включительно.
Исключите страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю.
Выгрузите десять самых активных стран-инвесторов.
Отсортируйте таблицу по среднему количеству компаний от большего к меньшему, а затем по коду страны в лексикографическом порядке.

SELECT country_code,
       MIN(invested_companies) AS min_companies,
       MAX(invested_companies) AS max_companies,
       AVG(invested_companies) AS avg_companies
FROM fund
WHERE EXTRACT(YEAR FROM founded_at) BETWEEN 2010 AND 2012
      
GROUP BY country_code
HAVING MIN(invested_companies) <> 0
ORDER BY avg_companies DESC,
         country_code
         
LIMIT 10;

11.
Отобразите имя и фамилию всех сотрудников стартапов.
Добавьте поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна.

SELECT p.first_name,
       p.last_name,
       e.instituition
FROM people AS p
LEFT JOIN education AS e ON p.id = e.person_id;

12.
Для каждой компании найдите количество учебных заведений, которые окончили её сотрудники.
Выведите название компании и число уникальных названий учебных заведений.
Составьте топ-5 компаний по количеству университетов.

SELECT c.name,
       COUNT(DISTINCT e.instituition) AS uni_count
FROM company AS c
LEFT JOIN people AS p ON c.id = p.company_id
JOIN education AS e ON p.id = e.person_id
GROUP BY c.name
ORDER BY uni_count DESC
LIMIT 5;

13.
Составьте список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.

SELECT c.name
FROM company AS c
LEFT JOIN funding_round AS fr ON c.id = fr.company_id
WHERE c.status LIKE 'closed'
      AND fr.is_first_round = 1
      AND fr.is_last_round = 1
GROUP BY c.name;

14.
Составьте список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.

SELECT DISTINCT id
FROM people
WHERE company_id IN
(SELECT c.id
FROM company AS c
LEFT JOIN funding_round AS fr ON c.id = fr.company_id
WHERE c.status LIKE 'closed'
      AND fr.is_first_round = 1
      AND fr.is_last_round = 1
GROUP BY c.id);

15.
Составьте таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник.

SELECT DISTINCT p.id,
       instituition
FROM people AS p
JOIN education AS e ON p.id = e.person_id
WHERE company_id IN (SELECT c.id
                     FROM company AS c
                     LEFT JOIN funding_round AS fr ON c.id = fr.company_id
                     WHERE c.status LIKE 'closed'
                           AND fr.is_first_round = 1
                           AND fr.is_last_round = 1
                     GROUP BY c.id);
                     
16.
Посчитайте количество учебных заведений для каждого сотрудника из предыдущего задания.
При подсчёте учитывайте, что некоторые сотрудники могли окончить одно и то же заведение дважды.

SELECT p.id,
       COUNT(e.instituition)
FROM people AS p
JOIN education AS e ON p.id = e.person_id
WHERE company_id IN (SELECT c.id
                     FROM company AS c
                     LEFT JOIN funding_round AS fr ON c.id = fr.company_id
                     WHERE c.status LIKE 'closed'
                           AND fr.is_first_round = 1
                           AND fr.is_last_round = 1
                     GROUP BY c.id)
GROUP BY p.id;

17.
Дополните предыдущий запрос и выведите среднее число учебных заведений (всех, не только уникальных),
которые окончили сотрудники разных компаний.
Нужно вывести только одну запись, группировка здесь не понадобится.

SELECT AVG(count_uni)
FROM

(SELECT p.id,
       COUNT(e.instituition) AS count_uni
FROM people AS p
JOIN education AS e ON p.id = e.person_id
WHERE company_id IN (SELECT c.id
                     FROM company AS c
                     LEFT JOIN funding_round AS fr ON c.id = fr.company_id
                     WHERE c.status LIKE 'closed'
                           AND fr.is_first_round = 1
                           AND fr.is_last_round = 1
                     GROUP BY c.id) 
GROUP BY p.id) AS subquery;

18.
Напишите похожий запрос: выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Facebook*.
*(сервис, запрещённый на территории РФ)

SELECT AVG(count_uni)
FROM

(SELECT p.id,
       COUNT(e.instituition) AS count_uni
FROM people AS p
JOIN education AS e ON p.id = e.person_id
WHERE company_id IN (SELECT c.id
                     FROM company AS c
                     LEFT JOIN funding_round AS fr ON c.id = fr.company_id
                     WHERE c.name LIKE 'Facebook'
                     GROUP BY c.id) 
GROUP BY p.id) AS subquery;

19.
Составьте таблицу из полей:
name_of_fund — название фонда;
name_of_company — название компании;
amount — сумма инвестиций, которую привлекла компания в раунде.
В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно.

SELECT f.name AS name_of_fund,
       c.name AS name_of_company,
       fr.raised_amount AS amount
FROM investment AS i
LEFT JOIN company AS c ON i.company_id = c.id
LEFT JOIN fund as f ON i.fund_id = f.id
LEFT JOIN funding_round AS fr ON i.funding_round_id = fr.id
WHERE c.milestones > 6
      AND EXTRACT(YEAR FROM fr.funded_at) BETWEEN 2012 AND 2013;
      
20.
Выгрузите таблицу, в которой будут такие поля:
- название компании-покупателя;
- сумма сделки;
- название компании, которую купили;
- сумма инвестиций, вложенных в купленную компанию;
- доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
Не учитывайте те сделки, в которых сумма покупки равна нулю.
Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы.
Отсортируйте таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке.
Ограничьте таблицу первыми десятью записями.

WITH
buyer AS (SELECT name AS buyer_name,
                 id
          FROM company
          WHERE id IN (SELECT acquiring_company_id
                       FROM acquisition)),
sold AS (SELECT name AS sold_name,
                funding_total,
                id
          FROM company
          WHERE id IN (SELECT acquired_company_id
                       FROM acquisition))

SELECT buyer.buyer_name,
       a.price_amount,
       sold.sold_name,
       sold.funding_total,
       ROUND(a.price_amount / sold.funding_total)     
FROM acquisition AS a
LEFT JOIN buyer ON a.acquiring_company_id = buyer.id
LEFT JOIN sold ON a.acquired_company_id = sold.id
WHERE a.price_amount <> 0
      AND sold.funding_total <> 0
ORDER BY a.price_amount DESC, sold.sold_name
LIMIT 10;

21.
Выгрузите таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно.
Проверьте, что сумма инвестиций не равна нулю.
Выведите также номер месяца, в котором проходил раунд финансирования.

SELECT c.name,
       EXTRACT(MONTH FROM fr.funded_at) AS month
       
FROM company AS c
JOIN funding_round AS fr ON c.id = fr.company_id

WHERE c.category_code LIKE 'social'
      AND fr.raised_amount <> 0
      AND EXTRACT(YEAR FROM fr.funded_at) BETWEEN 2010 AND 2013;
      
22.
Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. Сгруппируйте данные по номеру месяца и получите таблицу, в которой будут поля:
- номер месяца, в котором проходили раунды;
- количество уникальных названий фондов из США, которые инвестировали в этом месяце;
- количество компаний, купленных за этот месяц;
- общая сумма сделок по покупкам в этом месяце.

WITH
i AS (SELECT EXTRACT(MONTH FROM fr.funded_at) AS month,
             COUNT(DISTINCT f.name) AS count_of_fund
      FROM funding_round AS fr
      JOIN investment AS i ON fr.id = i.funding_round_id
      JOIN fund AS f ON i.fund_id = f.id
      WHERE f.country_code LIKE 'USA'
            AND EXTRACT(YEAR FROM fr.funded_at) BETWEEN 2010 AND 2013
      GROUP BY month),

a AS (SELECT EXTRACT(MONTH FROM acquired_at) AS month,
             COUNT(acquired_company_id) AS count_of_acquired,
             SUM(price_amount) AS sum_of_acquired
      FROM acquisition
      WHERE EXTRACT(YEAR FROM acquired_at) BETWEEN 2010 AND 2013
      GROUP BY month)


SELECT i.month,
       count_of_fund,
       count_of_acquired,
       sum_of_acquired
       
FROM i 
JOIN a ON i.month = a.month;

23.
Составьте сводную таблицу и выведите среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах.
Данные за каждый год должны быть в отдельном поле.
Отсортируйте таблицу по среднему значению инвестиций за 2011 год от большего к меньшему.

WITH

t11 AS (SELECT c.country_code,
               AVG(funding_total) AS avg_2011
               FROM company AS c
               WHERE EXTRACT(YEAR FROM c.founded_at) = 2011
               GROUP BY c.country_code),

t12 AS (SELECT c.country_code,
               AVG(funding_total) AS avg_2012
               FROM company AS c
               WHERE EXTRACT(YEAR FROM c.founded_at) = 2012
               GROUP BY c.country_code),

t13 AS (SELECT c.country_code,
               AVG(funding_total) AS avg_2013
               FROM company AS c
               WHERE EXTRACT(YEAR FROM c.founded_at) = 2013
               GROUP BY c.country_code)
               
SELECT t11.country_code,
       t11.avg_2011,
       t12.avg_2012,
       t13.avg_2013
FROM t11
JOIN t12 ON t11.country_code = t12.country_code
JOIN t13 ON t11.country_code = t13.country_code
ORDER BY t11.avg_2011 DESC;
