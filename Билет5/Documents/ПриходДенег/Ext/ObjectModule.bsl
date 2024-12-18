﻿
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	ОбработкаПроведенияОУ(Отказ, РежимПроведения);
	
КонецПроцедуры


Процедура ОбработкаПроведенияОУ(Отказ, РежимПроведения)

	//Старая методика.
	Движения.Взаиморасчеты.Записывать = Истина;
	Движения.Взаиморасчеты.Записать();
	
	//блокировка данных
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрНакопления.Взаиморасчеты");
	ЭлементБлокировки.УстановитьЗначение("Контрагент", Контрагент);
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	Блокировка.Заблокировать();
	
	//запрос получения данных
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВзаиморасчетыОстатки.Проект КАК Проект,
		|	ВзаиморасчетыОстатки.Проект.Валюта КАК Валюта,
		|	ВзаиморасчетыОстатки.СуммаРубОстаток КАК СуммаРубОстаток,
		|	ВзаиморасчетыОстатки.СуммаВалОстаток КАК СуммаВалОстаток
		|ПОМЕСТИТЬ Вт_Остатки
		|ИЗ
		|	РегистрНакопления.Взаиморасчеты.Остатки(
		|			&МоментВремени,
		|			Контрагент = &Контрагент
		|				И Проект <> ЗНАЧЕНИЕ(Справочник.Проекты.Аванс)) КАК ВзаиморасчетыОстатки
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Валюта
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Вт_Остатки.Проект КАК Проект,
		|	Вт_Остатки.Валюта КАК Валюта,
		|	Вт_Остатки.СуммаРубОстаток КАК СуммаРуб,
		|	Вт_Остатки.СуммаВалОстаток КАК СуммаВал,
		|	Вт_Остатки.Проект.Представление КАК ПроектПредставление,
		|	Вт_Остатки.Валюта.Представление КАК ВалютаПредставление,
		|	ЕСТЬNULL(КурсыВалютСрезПоследних.Курс, 0) КАК Курс
		|ИЗ
		|	Вт_Остатки КАК Вт_Остатки
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КурсыВалют.СрезПоследних(
		|				&Период,
		|				Валюта В
		|					(ВЫБРАТЬ
		|						Вт_Остатки.Валюта КАК Валюта
		|					ИЗ
		|						Вт_Остатки КАК Вт_Остатки)) КАК КурсыВалютСрезПоследних
		|		ПО Вт_Остатки.Валюта = КурсыВалютСрезПоследних.Валюта";
	
	Запрос.УстановитьПараметр("Контрагент", Контрагент);
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	Запрос.УстановитьПараметр("Период", Дата);
	
	ОсталосьСписать = СуммаПоДокументу;
	Рубль = Справочники.Валюты.РоссийскийРубль;
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() И ОсталосьСписать > 0 Цикл 
		
		//4. Контроля остатков нет.
		Если Выборка.Курс = 0 И Выборка.Валюта <> Рубль Тогда 
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = "По проекту " + Выборка.ПроектП + " для валюты " + Выборка.ВалютаП + " не задан курс";
			Сообщение.Сообщить();
			Отказ = Истина;
		КонецЕсли; 
		Курс = ?(Выборка.Курс = 0, 1, Выборка.Курс);
		Если Отказ Тогда 
			Продолжить;
		КонецЕсли;
		
		СуммаСписанияРуб = Мин(ОсталосьСписать, Выборка.СуммаРуб);
		Если СуммаСписанияРуб = Выборка.СуммаРуб Тогда 
			СуммаСписанияВал = Выборка.СуммаВал;
		Иначе 
			СуммаСписанияВал = СуммаСписанияРуб / Курс;
		КонецЕсли;

		
		//5.1 Формирование движений. Погашение долгов
		Движение = Движения.Взаиморасчеты.ДобавитьРасход();
		Движение.Период = Дата;
		Движение.Контрагент = Контрагент;
		Движение.Проект = Выборка.Проект;
		Движение.СуммаРуб = СуммаСписанияРуб;
		Движение.СуммаВал = СуммаСписанияВал;
		
		ОсталосьСписать = ОсталосьСписать - Движение.СуммаРуб;
	КонецЦикла;
		
	
	//5.2 Формирование движений. Зачисление аванса
	Если Не Отказ И ОсталосьСписать > 0 Тогда 
		Движение = Движения.Взаиморасчеты.ДобавитьРасход();
		Движение.Период = Дата;
		Движение.Контрагент = Контрагент;
		Движение.Проект = Справочники.Проекты.Аванс;
		Движение.СуммаРуб = ОсталосьСписать;
		Движение.СуммаВал = 0;
	КонецЕсли;
	

	
КонецПроцедуры	