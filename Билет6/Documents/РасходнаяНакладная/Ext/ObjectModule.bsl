﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	

	МетодСписания = РегистрыСведений.УчетнаяПолитика.ПолучитьПоследнее(Дата).МетодСписания;
	Если Не ЗначениеЗаполнено(МетодСписания) Тогда
		Отказ = Истина;
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не задан метод списания партий!";
		Сообщение.Сообщить();
	КонецЕсли;
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	
	ОбработкаПроведенияОУ(Отказ, Режим);
	
	Движения.Управленческий.Записывать = Истина;
	Движения.Управленческий.Записать();
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрБухгалтерии.Управленческий");
	ЭлементБлокировки.УстановитьЗначение(ПланыВидовХарактеристик.ВидыСубконто.Склады, Склад);
	ЭлементБлокировки.УстановитьЗначение("Счет", ПланыСчетов.Управленческий.Товары);
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.ИсточникДанных = СписокНоменклатуры;
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных(ПланыВидовХарактеристик.ВидыСубконто.Номенклатура, "Номенклатура");
	Блокировка.Заблокировать();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура КАК Номенклатура,
	|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Количество) КАК Количество
	|ПОМЕСТИТЬ ВТ_ДанныеДок
	|ИЗ
	|	Документ.РасходнаяНакладная.СписокНоменклатуры КАК РасходнаяНакладнаяСписокНоменклатуры
	|ГДЕ
	|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	УправленческийОстатки.Субконто1 КАК Номенклатура,
	|	УправленческийОстатки.Субконто3 КАК Партия,
	|	УправленческийОстатки.КоличествоОстаток КАК КоличествоОстаток
	|ПОМЕСТИТЬ ВТ_ПартииСклада
	|ИЗ
	|	РегистрБухгалтерии.Управленческий.Остатки(
	|			&МоментВремени,
	|			Счет = &СчетТовары,
	|			&СубконтоНоменклатураСкладПартия,
	|			Субконто1 В
	|					(ВЫБРАТЬ
	|						ВТ_ДанныеДок.Номенклатура КАК Номенклатура
	|					ИЗ
	|						ВТ_ДанныеДок КАК ВТ_ДанныеДок)
	|				И Субконто2 = &Склад) КАК УправленческийОстатки
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Номенклатура,
	|	Партия
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ДанныеДок.Номенклатура КАК Номенклатура,
	|	ВТ_ДанныеДок.Номенклатура.Представление КАК НоменклатураПредставление,
	|	УправленческийОстатки.Субконто2 КАК Партия,
	|	ВТ_ДанныеДок.Количество КАК Количество,
	|	ЕСТЬNULL(ВТ_ПартииСклада.КоличествоОстаток, 0) КАК КоличествоПартии,
	|	УправленческийОстатки.СуммаОстаток КАК СуммаПартии
	|ИЗ
	|	ВТ_ДанныеДок КАК ВТ_ДанныеДок
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Управленческий.Остатки(
	|				&МоментВремени,
	|				,
	|				&СубконтоНоменклатураПартия,
	|				(Субконто1, Субконто2) В
	|					(ВЫБРАТЬ
	|						ВТ_ПартииСклада.Номенклатура КАК Номенклатура,
	|						ВТ_ПартииСклада.Партия КАК Партия
	|					ИЗ
	|						ВТ_ПартииСклада КАК ВТ_ПартииСклада)) КАК УправленческийОстатки
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_ПартииСклада КАК ВТ_ПартииСклада
	|			ПО УправленческийОстатки.Субконто1 = ВТ_ПартииСклада.Номенклатура
	|				И УправленческийОстатки.Субконто2 = ВТ_ПартииСклада.Партия
	|		ПО ВТ_ДанныеДок.Номенклатура = УправленческийОстатки.Субконто1
	|
	|УПОРЯДОЧИТЬ ПО
	|	УправленческийОстатки.Субконто2.МоментВремени УБЫВ
	|ИТОГИ
	|	МАКСИМУМ(Количество),
	|	СУММА(КоличествоПартии)
	|ПО
	|	Номенклатура";
	
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	Запрос.УстановитьПараметр("Склад", Склад);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	СубконтоНоменклатураПартия = Новый Массив;
	СубконтоНоменклатураПартия.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Номенклатура);
	СубконтоНоменклатураПартия.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Партии);
	Запрос.УстановитьПараметр("СубконтоНоменклатураПартия", СубконтоНоменклатураПартия);
	
	СубконтоНоменклатураСкладПартия = Новый Массив;
	СубконтоНоменклатураСкладПартия.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Номенклатура);
	СубконтоНоменклатураСкладПартия.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Склады);
	СубконтоНоменклатураСкладПартия.Добавить(ПланыВидовХарактеристик.ВидыСубконто.Партии);
	Запрос.УстановитьПараметр("СубконтоНоменклатураСкладПартия", СубконтоНоменклатураСкладПартия);
	
	Запрос.УстановитьПараметр("СчетТовары", ПланыСчетов.Управленческий.Товары);
	
	Если МетодСписания = Перечисления.УчетнаяПолитика.ФИФО Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, ".МоментВремени УБЫВ", ".МоментВремени");
	КонецЕсли;
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаНоменклатура = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаНоменклатура.Следующий() Цикл
		
		НеХватает = ВыборкаНоменклатура.Количество - ВыборкаНоменклатура.КоличествоПартии;
		Если НеХватает > 0 Тогда
			
			Отказ = Истина;
			
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = СтрШаблон("Не хватает товара (бух. учет) %1 в количестве %2", ВыборкаНоменклатура.НоменклатураПредставление, НеХватает);
			Сообщение.Сообщить();
			
		КонецЕсли;
		
		Если Отказ Тогда
			Продолжить;
		КонецЕсли;
		
		ВыборкаДетальныеЗаписи = ВыборкаНоменклатура.Выбрать();
		
		КоличествоСписать = ВыборкаНоменклатура.Количество;
		
		Пока КоличествоСписать > 0 И ВыборкаДетальныеЗаписи.Следующий() Цикл
			
			СписатьПоПартии = МИН(КоличествоСписать, ВыборкаДетальныеЗаписи.КоличествоПартии);
			СебестоимостьПартии = СписатьПоПартии / ВыборкаДетальныеЗаписи.КоличествоПартии * ВыборкаДетальныеЗаписи.СуммаПартии;
			
			КоличествоСписать = КоличествоСписать - СписатьПоПартии;
			
			// Вставить обработку выборки ВыборкаДетальныеЗаписи
			Движение = Движения.Управленческий.Добавить();
			Движение.СчетДт = ПланыСчетов.Управленческий.ПрибылиУбытки;
			Движение.СчетКт = ПланыСчетов.Управленческий.Товары;
			Движение.Период = Дата;
			Движение.Сумма = СебестоимостьПартии;
			Движение.КоличествоКт = СписатьПоПартии;
			Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Номенклатура] = ВыборкаДетальныеЗаписи.Номенклатура;
			Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Склады] = Склад;
			Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконто.Партии] = ВыборкаДетальныеЗаписи.Партия;
			
		КонецЦикла;
	КонецЦикла;
	
	Движения.Управленческий.Записывать = Истина;
	Движение = Движения.Управленческий.Добавить();
	Движение.СчетДт = ПланыСчетов.Управленческий.Покупатели;
	Движение.СчетКт = ПланыСчетов.Управленческий.ПрибылиУбытки;
	Движение.Период = Дата;
	Движение.Сумма = СуммаПоДокументу;
	
	//}}КОНСТРУКТОР_ЗАПРОСА_С_ОБРАБОТКОЙ_РЕЗУЛЬТАТА

	
	
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!

	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	
КонецПроцедуры

Процедура ОбработкаПроведенияОУ(Отказ, Режим)
	
	Движения.ОстаткиНоменклатуры.Записывать = Истина;
	Движения.ОстаткиНоменклатуры.Записать();

	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура КАК Номенклатура,
		|	СУММА(РасходнаяНакладнаяСписокНоменклатуры.Количество) КАК Количество,
		|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура.ВидНоменклатуры = &Стеллаж КАК ЭтоСтеллаж
		|ПОМЕСТИТЬ ВТ_ДанныеДок
		|ИЗ
		|	Документ.РасходнаяНакладная.СписокНоменклатуры КАК РасходнаяНакладнаяСписокНоменклатуры
		|ГДЕ
		|	РасходнаяНакладнаяСписокНоменклатуры.Ссылка = &Ссылка
		|
		|СГРУППИРОВАТЬ ПО
		|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура,
		|	РасходнаяНакладнаяСписокНоменклатуры.Номенклатура.ВидНоменклатуры = &Стеллаж
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Номенклатура,
		|	ЭтоСтеллаж
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВложенныйЗапрос.Номенклатура КАК Номенклатура,
		|	СУММА(ВложенныйЗапрос.Количество) КАК Количество
		|ПОМЕСТИТЬ ВТ_ТаблицаДляСписания
		|ИЗ
		|	(ВЫБРАТЬ
		|		СоставСтелажей.Комплектующая КАК Номенклатура,
		|		ВТ_ДанныеДок.Количество * СоставСтелажей.Количество КАК Количество
		|	ИЗ
		|		ВТ_ДанныеДок КАК ВТ_ДанныеДок
		|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.СоставСтелажей КАК СоставСтелажей
		|			ПО ВТ_ДанныеДок.Номенклатура = СоставСтелажей.Стеллаж
		|	ГДЕ
		|		ВТ_ДанныеДок.ЭтоСтеллаж
		|	
		|	ОБЪЕДИНИТЬ ВСЕ
		|	
		|	ВЫБРАТЬ
		|		ВТ_ДанныеДок.Номенклатура,
		|		ВТ_ДанныеДок.Количество
		|	ИЗ
		|		ВТ_ДанныеДок КАК ВТ_ДанныеДок
		|	ГДЕ
		|		НЕ ВТ_ДанныеДок.ЭтоСтеллаж) КАК ВложенныйЗапрос
		|
		|СГРУППИРОВАТЬ ПО
		|	ВложенныйЗапрос.Номенклатура
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_ТаблицаДляСписания.Номенклатура КАК Номенклатура,
		|	ВТ_ТаблицаДляСписания.Количество КАК Количество,
		|	&Склад КАК Склад,
		|	&Период КАК Период,
		|	&ВидДвижения КАК ВидДвижения
		|ИЗ
		|	ВТ_ТаблицаДляСписания КАК ВТ_ТаблицаДляСписания";
	
	Запрос.УстановитьПараметр("ВидДвижения", ВидДвиженияНакопления.Расход);
	Запрос.УстановитьПараметр("Период", Дата);
	Запрос.УстановитьПараметр("Склад", Склад);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Стеллаж", Перечисления.ВидыНоменклатуры.Стелаж);
	
	РезультатЗапроса = Запрос.Выполнить();
	ДВижения.ОстаткиНоменклатуры.Загрузить(РезультатЗапроса.Выгрузить());
	
	Движения.ОстаткиНоменклатуры.БлокироватьДляИзменения = Истина;
	Движения.ОстаткиНоменклатуры.Записать();
	
	
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ОстаткиНоменклатурыОстатки.Склад.Представление КАК СкладПредставление,
		|	ОстаткиНоменклатурыОстатки.Номенклатура.Представление КАК НоменклатураПредставление,
		|	-ОстаткиНоменклатурыОстатки.КоличествоОстаток КАК КоличествоОстаток
		|ИЗ
		|	РегистрНакопления.ОстаткиНоменклатуры.Остатки(
		|			&Граница,
		|			Номенклатура В
		|					(ВЫБРАТЬ
		|						ВТ_ТаблицаДляСписания.Номенклатура КАК Номенклатура
		|					ИЗ
		|						ВТ_ТаблицаДляСписания КАК ВТ_ТаблицаДляСписания)
		|				И Склад = &Склад) КАК ОстаткиНоменклатурыОстатки
		|ГДЕ
		|	ОстаткиНоменклатурыОстатки.КоличествоОстаток < 0";
	
	
	Запрос.УстановитьПараметр("Граница", Новый Граница(МоментВремени(), ВидГраницы.Включая));
	Рез = Запрос.Выполнить();
	Выборка = Рез.Выбрать();
	Пока Выборка.Следующий() Цикл
		Отказ = Истина;
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СтрШаблон("НЕ хвататет товара (опер. учет) %1 на складе %2 в количестве %3", Выборка.НоменклатураПредставление, Выборка.СкладПредставление, Выборка.КОличествоОстаток);
		Сообщение.Сообщить();
	КонецЦикла;

	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!

	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	
КонецПроцедуры


Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	СуммаПоДокументу = СписокНоменклатуры.Итог("Сумма");
	
КонецПроцедуры

