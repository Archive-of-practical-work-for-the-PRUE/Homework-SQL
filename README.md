# Практическая работа 3 - Расписание для группы
## Описание задачи
Необходимо создать SQL-представление в базе данных `student` MariaDB на 35гб для отображения рассписания для группы (ПИ1/23б) за 2 семестр 2 курса. Данные должны включать:
- Дата
- Дни недели
- Дисциплина
- Номер пары
- Тип занятия
- Корпус
- Аудитория
- Преподаватель

## Ожидаемый результат

Запрос должен вернуть примерно следующие данные для студента:

| Дата              | Дни недели       | Дисциплина | Номер пары | Тип занятия | Корпус   | Аудитория | Преподаватель             |
|-------------------|------------------|------------|------------|-------------| -------  | ----------| --------------------------|
| 2025.02.22        | Понедельник      | Математика | 1          | Лекция      | 3 корпус | 233       | Акирова Алексей Андреевич |

## SQL представление 
```sql
SELECT
	dnizan.den AS 'Дата',
	nedel.value AS 'Дни недели',
	disc.name AS 'Дисциплина',
	zan.para AS 'Номер пары',
	zan.vidnagruzki AS 'Тип занятия',
	korp.name AS 'Корпус',
	kab.name AS 'Аудитория',
	prepod.name AS 'Преподаватель'
FROM doc__raspisaniegroups_dnizanyatiy dnizan
JOIN doc__raspisaniegroups rasp_grp ON dnizan.pid = rasp_grp.id
JOIN cat__akademicheskayagruppa grp ON grp.id = rasp_grp.cat__akademicheskayagruppa_id
JOIN doc__raspisaniegroups_zanyatiya zan ON zan.pid = dnizan.pid
JOIN enum__dninedeli nedel ON nedel.index = zan.nomerdnyanedeli - 1
JOIN cat__disciplinyobucheniya disc ON disc.id = zan.disciplina
JOIN cat__pomescheniya kab ON kab.id = zan.cat__pomescheniya_id
JOIN cat__korpusa korp ON korp.id = kab.cat__korpusa_id
JOIN cat__prepodavateli prepod ON prepod.id = zan.cat__prepodavateli_id
WHERE grp.nomergruppy LIKE 'ПИ1/23б' AND rasp_grp.polugodie = '2' AND rasp_grp.enum__kurs_id = 'Курс2' AND zan.klyuchstroki = dnizan.klyuchstroki
ORDER BY dnizan.den, zan.para;
```
