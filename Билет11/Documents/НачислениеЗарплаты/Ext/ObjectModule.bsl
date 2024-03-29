﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	
	Движения.ОсновныеНачисления.Записывать = Истина;
	Движения.ДополнительныеНачисления.Записывать = Истина;
	
	Для Каждого ТекСтрокаОсновныеНачисления Из ОсновныеНачисления Цикл
		Движение = Движения.ОсновныеНачисления.Добавить();
		Движение.Сторно = Ложь;
		Движение.ВидРасчета = ТекСтрокаОсновныеНачисления.ВидРасчета;
		Движение.ПериодДействияНачало = ТекСтрокаОсновныеНачисления.ДатаНачала;
		Движение.ПериодДействияКонец = КонецДня(ТекСтрокаОсновныеНачисления.ДатаОкончания);
		Движение.ПериодРегистрации = ПериодРегистрации;
		Движение.Сотрудник = ТекСтрокаОсновныеНачисления.Сотрудник;
		Движение.Подразделение = ТекСтрокаОсновныеНачисления.Подразделение;
		Движение.ГрафикРаботы = ТекСтрокаОсновныеНачисления.ГрафикиРаботы;
	КонецЦикла;

	Для Каждого ТекСтрокаДополнительныеНачисления Из ДополнительныеНачисления Цикл
		Движение = Движения.ДополнительныеНачисления.Добавить();
		Движение.Сторно = Ложь;
		Движение.ВидРасчета = ТекСтрокаДополнительныеНачисления.ВидРасчета;
		Движение.ПериодРегистрации = ПериодРегистрации;
		Движение.БазовыйПериодНачало = НачалоМесяца(ПериодРегистрации);
		Движение.БазовыйПериодКонец = КонецМесяца(ПериодРегистрации);
		Движение.Сотрудник = ТекСтрокаДополнительныеНачисления.Сотрудник;
		Движение.Подразделение = ТекСтрокаДополнительныеНачисления.Подразделение;
		Движение.Параметр1 = ТекСтрокаДополнительныеНачисления.Размер;
	КонецЦикла;

	Движения.Записать();
	
	РассчитатьОклад();
	РассчитатьПремию();
	
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!

	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	
КонецПроцедуры


Процедура РассчитатьОклад()

	 	//{{КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ОсновныеНачисления.Сотрудник КАК Сотрудник,
		|	ОсновныеНачисления.Подразделение КАК Подразделение,
		|	ОсновныеНачисления.НомерСтроки КАК НомерСтроки
		|ПОМЕСТИТЬ ВТ_ДанныеДок
		|ИЗ
		|	РегистрРасчета.ОсновныеНачисления КАК ОсновныеНачисления
		|ГДЕ
		|	ОсновныеНачисления.Регистратор = &Регистратор
		|	И ОсновныеНачисления.ВидРасчета = &Оклад
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Подразделение,
		|	Сотрудник
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ОсновныеНачисленияФактическийПериодДействия.НомерСтроки КАК НомерСтроки,
		|	СУММА(РабочееВремяСотрудниковОбороты.ЗначениеОборот) КАК ЗначениеОборот
		|ПОМЕСТИТЬ ВТ_ОтработаноФакт
		|ИЗ
		|	РегистрРасчета.ОсновныеНачисления.ФактическийПериодДействия(
		|			Регистратор = &Регистратор
		|				И ВидРасчета = &Оклад) КАК ОсновныеНачисленияФактическийПериодДействия
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрНакопления.РабочееВремяСотрудников.Обороты(
		|				&НачалоПериода,
		|				&ОкончаниеПериода,
		|				День,
		|				(Подразделение, Сотрудник) В
		|					(ВЫБРАТЬ
		|						ВТ_ДанныеДок.Подразделение КАК Подразделение,
		|						ВТ_ДанныеДок.Сотрудник КАК Сотрудник
		|					ИЗ
		|						ВТ_ДанныеДок КАК ВТ_ДанныеДок)) КАК РабочееВремяСотрудниковОбороты
		|		ПО ОсновныеНачисленияФактическийПериодДействия.Сотрудник = РабочееВремяСотрудниковОбороты.Сотрудник
		|			И ОсновныеНачисленияФактическийПериодДействия.Подразделение = РабочееВремяСотрудниковОбороты.Подразделение
		|			И (РабочееВремяСотрудниковОбороты.Период МЕЖДУ ОсновныеНачисленияФактическийПериодДействия.ПериодДействияНачало И ОсновныеНачисленияФактическийПериодДействия.ПериодДействияКонец)
		|
		|СГРУППИРОВАТЬ ПО
		|	ОсновныеНачисленияФактическийПериодДействия.НомерСтроки
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_ДанныеДок.НомерСтроки КАК НомерСтроки,
		|	ЕСТЬNULL(ВТ_ОтработаноФакт.ЗначениеОборот, 0) КАК ЧасыФакт,
		|	ЕСТЬNULL(СведенияОСотрудникахСрезПоследних.Оклад, 0) КАК ТарифнаяСтавка
		|ИЗ
		|	ВТ_ДанныеДок КАК ВТ_ДанныеДок
		|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ОтработаноФакт КАК ВТ_ОтработаноФакт
		|		ПО ВТ_ДанныеДок.НомерСтроки = ВТ_ОтработаноФакт.НомерСтроки
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СведенияОСотрудниках.СрезПоследних(
		|				&НачалоПериода,
		|				(Подразделение, Сотрудник) В
		|					(ВЫБРАТЬ
		|						ВТ_ДанныеДок.Подразделение КАК Подразделение,
		|						ВТ_ДанныеДок.Сотрудник КАК Сотрудник
		|					ИЗ
		|						ВТ_ДанныеДок КАК ВТ_ДанныеДок)) КАК СведенияОСотрудникахСрезПоследних
		|		ПО ВТ_ДанныеДок.Подразделение = СведенияОСотрудникахСрезПоследних.Подразделение
		|			И ВТ_ДанныеДок.Сотрудник = СведенияОСотрудникахСрезПоследних.Сотрудник";
	
	Запрос.УстановитьПараметр("НачалоПериода", НачалоМесяца(ПериодРегистрации));
	Запрос.УстановитьПараметр("Оклад", ПланыВидовРасчета.ОсновныеНачисления.Оклад);
	Запрос.УстановитьПараметр("ОкончаниеПериода", КонецМесяца(ПериодРегистрации));
	Запрос.УстановитьПараметр("Регистратор", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Для каждого Движение Из Движения.ОсновныеНачисления Цикл
	
		Если Движение.ВидРасчета <> ПланыВидовРасчета.ОсновныеНачисления.Оклад Тогда
		
			Продолжить;
		
		КонецЕсли;
		
		Выборка.Сбросить();
		Если Выборка.НайтиСледующий(движение.НомерСтроки, "НомерСтроки") Тогда
			
			Движение.Параметр1 = Выборка.ЧасыФакт;
			Движение.Параметр2 = Выборка.ТарифнаяСтавка;
			
			Движение.Результат = Движение.Параметр1 * Движение.Параметр2; 
		
		КонецЕсли;
		
	КонецЦикла;

	Движения.ОсновныеНачисления.Записать();
	
КонецПроцедуры

Процедура РассчитатьПремию()

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ДополнительныеНачисленияБазаОсновныеНачисления.НомерСтроки КАК НомерСтроки,
		|	ЕСТЬNULL(ДополнительныеНачисленияБазаОсновныеНачисления.РезультатБаза, 0) КАК База
		|ИЗ
		|	РегистрРасчета.ДополнительныеНачисления.БазаОсновныеНачисления(&Измерения, &Измерения, , Регистратор = &Регистратор) КАК ДополнительныеНачисленияБазаОсновныеНачисления";
	Измерения = Новый Массив;
	Измерения.Добавить("Сотрудник");
	Измерения.Добавить("Подразделение");
	Запрос.УстановитьПараметр("Измерения", Измерения);
	Запрос.УстановитьПараметр("Регистратор", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();

	
	Для каждого Движение Из Движения.ДополнительныеНачисления Цикл
	
		Если Движение.ВидРасчета <> ПланыВидовРасчета.ДополнительныеНачисления.Премия Тогда
		
			Продолжить;
		
		КонецЕсли;
		
		Выборка.Сбросить();
		Если Выборка.НайтиСледующий(движение.НомерСтроки, "НомерСтроки") Тогда
			
			Движение.Параметр2 = Выборка.База;
			
			Движение.Результат = Движение.Параметр1/100 * Движение.Параметр2; 
		
		КонецЕсли;
		
	
	КонецЦикла;

	Движения.ДополнительныеНачисления.Записать(,Истина);
	
КонецПроцедуры
