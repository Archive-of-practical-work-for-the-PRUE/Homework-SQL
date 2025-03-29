SELECT
	stud.name AS 'ФИО',
	disc.name AS 'Дисциплина',
	god.name AS 'Учебный год',
	SUBSTRING(sem.value, 1, 1) AS 'Семестр',
	ocen.name AS 'Оценка'
FROM doc__ekzamenacionnayavedomost ekz
JOIN doc__ekzamenacionnayavedomost_ocenki ekz_oc ON ekz_oc.pid = ekz.id
JOIN cat__is_godobucheniya god ON ekz.cat__is_godobucheniya_id = god.id
JOIN cat__disciplinyobucheniya disc ON ekz.disciplina = disc.id
JOIN cat__is_studenty stud ON ekz_oc.cat__is_studenty_id = stud.id
JOIN enum__semestry sem ON ekz.enum__semestry_id = sem.id
JOIN cat__ocenki ocen ON ekz_oc.rezultat = ocen.id
WHERE stud.id = (SELECT id FROM cat__is_studenty WHERE name = 'Себежко Александр Андреевич')
ORDER BY sem.index;