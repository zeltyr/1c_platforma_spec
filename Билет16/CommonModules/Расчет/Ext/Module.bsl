﻿
Процедура РассчитатьОклад(Регистратор, ОсновныеНачисления) Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ОсновныеНачисленияДанныеГрафика.НомерСтроки КАК НомерСтроки,
		|	ЕСТЬNULL(ОсновныеНачисленияДанныеГрафика.ЗначениеПериодДействия, 0) КАК ЧасыПлан,
		|	ЕСТЬNULL(ОсновныеНачисленияДанныеГрафика.ЗначениеФактическийПериодДействия, 0) КАК ЧасыФакт,
		|	ОсновныеНачисленияДанныеГрафика.ЗначениеДниФактическийПериодДействия КАК ДниРаботы
		|ИЗ
		|	РегистрРасчета.ОсновныеНачисления.ДанныеГрафика(Регистратор = &Регистратор) КАК ОсновныеНачисленияДанныеГрафика";
	
	Запрос.УстановитьПараметр("Регистратор", Регистратор);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	
	
	Для каждого Движение Из ОсновныеНачисления Цикл
	
		Если Движение.ВидРасчета <> ПланыВидовРасчета.ОсновныеНачисления.Оклад Тогда
		
			Продолжить;
		
		КонецЕсли;
		
		Выборка.Сбросить();
		Если Выборка.НайтиСледующий(Движение.НомерСтроки, "НомерСтроки") Тогда
			
			Движение.Параметр2 = Выборка.ЧасыПлан;
			Движение.Параметр3 = Выборка.ЧасыФакт;
			
			Движение.ДниРаботы = Выборка.ДниРаботы;
			Если Выборка.ЧасыПлан <> 0 Тогда
				Движение.Результат = Выборка.ЧасыФакт / Выборка.ЧасыПлан * Движение.Параметр1;
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЦикла;

	ОсновныеНачисления.Записать();
	
КонецПроцедуры

Процедура РассчитатьКомпенсацию(Регистратор, ДополнительныеНачисления, ДопОтбор = Неопределено) Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ДополнительныеНачисленияБазаОсновныеНачисления.НомерСтроки КАК НомерСтроки,
	|	ДополнительныеНачисленияБазаОсновныеНачисления.ДниРаботыБаза КАК ДниРаботыБаза
	|ИЗ
	|	РегистрРасчета.ДополнительныеНачисления.БазаОсновныеНачисления(
	|			&Измерения,
	|			&Измерения,
	|			,
	|			Регистратор = &Регистратор
	|				И &ОтборПоСотрудникуИПодразделению) КАК ДополнительныеНачисленияБазаОсновныеНачисления";
	
	Измерения = Новый Массив;
	Измерения.Добавить("Сотрудник");
	Измерения.Добавить("Подразделение");
	Запрос.УстановитьПараметр("Измерения", Измерения);
	Запрос.УстановитьПараметр("Регистратор", Регистратор);
	
	Если ДопОтбор <> Неопределено Тогда
		ТекстДопУсловия = "Сотрудник В (&Сотрудники) И Подразделение В (&Подразделения)";
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ОтборПоСотрудникуИПодразделению", ТекстДопУсловия);
		Запрос.УстановитьПараметр("Сотрудники", ДопОтбор.Сотрудники);
		Запрос.УстановитьПараметр("Подразделения", ДопОтбор.Подразделения);
	Иначе
		Запрос.УстановитьПараметр("ОтборПоСотрудникуИПодразделению", Истина);
	КонецЕсли;
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();

	Для каждого Движение Из ДополнительныеНачисления Цикл
	
		Если Движение.ВидРасчета <> ПланыВидовРасчета.ДополнительныеНачисления.Компенсация Тогда
		
			Продолжить;
		
		КонецЕсли;
	
		Выборка.Сбросить();
		Если Выборка.НайтиСледующий(Движение.НомерСтроки, "НомерСтроки") Тогда
			
			Движение.Параметр2 = Выборка.ДниРаботыБаза;
			
			Движение.Результат = Движение.Параметр1 * Движение.Параметр2;
			
		КонецЕсли;
		
	КонецЦикла;

	ДополнительныеНачисления.Записать();
	
КонецПроцедуры
