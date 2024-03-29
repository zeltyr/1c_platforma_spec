﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	
	Движения.ВзаиморасчетыСКонтрагентами.Записывать = Истина;
	Движения.ВзаиморасчетыСКонтрагентами.Записать();
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрНакопления.ВзаиморасчетыСКонтрагентами");
	ЭлементБлокировки.УстановитьЗначение("Контрагент", Контрагент);
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	Блокировка.Заблокировать(); 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВзаиморасчетыСКонтрагентамиОстатки.Проект КАК Проект,
		|	ВзаиморасчетыСКонтрагентамиОстатки.СуммаОстаток КАК СуммаОстаток,
		|	ЕСТЬNULL(КурсыВалютСрезПоследних.Курс, 0) КАК Курс
		|ИЗ
		|	РегистрНакопления.ВзаиморасчетыСКонтрагентами.Остатки(
		|			&МоментВремени,
		|			Контрагент = &Контрагент
		|				И Проект <> ЗНАЧЕНИЕ(Справочник.Проекты.ПустаяСсылка)) КАК ВзаиморасчетыСКонтрагентамиОстатки
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.КурсыВалют.СрезПоследних(&МоментВремени, ) КАК КурсыВалютСрезПоследних
		|		ПО ВзаиморасчетыСКонтрагентамиОстатки.Проект.Валюта = КурсыВалютСрезПоследних.Валюта
		|
		|УПОРЯДОЧИТЬ ПО
		|	ВзаиморасчетыСКонтрагентамиОстатки.Проект.ДатаОплаты";
	
	Запрос.УстановитьПараметр("Контрагент", Контрагент);
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	СуммаСписать = СуммаПоДокументу;
	Пока СуммаСписать > 0 И Выборка.Следующий() Цикл
		
		Курс = ?(Выборка.Курс = 0, 1, Выборка.Курс);
		
		СуммаПоПроектуВРублях = Окр(Выборка.СуммаОстаток * Курс, 2);
		СписатьПоПроектуВРублях = МИН(СуммаСписать, СуммаПоПроектуВРублях);
		СписатьПоПроекту = ?(СписатьПоПроектуВРублях = СуммаПоПроектуВРублях, Выборка.СуммаОстаток, СписатьПоПроекту / Курс);
		
		СуммаСписать = СуммаСписать - СписатьПоПроектуВРублях;
		
		Движение = Движения.ВзаиморасчетыСКонтрагентами.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Контрагент = Контрагент;
		Движение.Проект = Выборка.Проект;
		Движение.Сумма = СписатьПоПроекту;
		
	КонецЦикла;
	
	Если СуммаСписать > 0 Тогда
		
		Движение = Движения.ВзаиморасчетыСКонтрагентами.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Контрагент = Контрагент;
		Движение.Проект = Справочники.Проекты.ПустаяСсылка();
		Движение.Сумма = СуммаСписать;
		
	КонецЕсли;
	
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!

	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	
КонецПроцедуры
